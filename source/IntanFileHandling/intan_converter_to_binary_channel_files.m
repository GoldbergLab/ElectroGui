function intan_converter_to_binary_channel_files(acc_array, acc_present, path_input, start_index, verbose)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% intan_converter_to_binary_channel_files: Convert Intan .rhd files to
%   individual binary .nc channel files
% usage:  [<output args>] = <function name>(<input args>)
%
% where,
%    acc_array is a 1xN array of boolean values, where N is the number of
%       headstages in the .rhd files. Each value in the array indicates
%       whether or not the headstage at that index has accelerometer data.
%    acc_present is a boolean value that indicates whether or not there are
%       any accelerometers present? I guess? Seems redundant.
%    path_input is an optional char array representing a path to a
%       directory in which to look (non-recursively) for .rhd files. If
%       this argument is omitted, or is an empty array, then the user will
%       be prompted to select a directory in a popup.
%
% This function takes Intan .rhd files and splits them into individual
%   binary .nc channel files. Within the rhd search directory, it creates a
%   "Data Extracted" folder, and within that N "HeadstageK" directories,
%   where K is the headstage number, which goes from 1 to N, the number of
%   headstages. For example: 
%
%   path_input
%       Data Extracted
%           Headstage1
%               convertedNcFile1.nc
%               convertedNcFile2.nc
%               ...
%               convertedNcFileN.nc
%           Headstage2
%               convertedNcFile1.nc
%               convertedNcFile2.nc
%               ...
%               convertedNcFileN.nc
%
%   Within each Headstage directory, it will write the
%   converted .nc files. These .nc files are designed to be loaded into
%   electro_gui using the 'egl_Intan_Nc.m' loader script.
%
% See also: egl_Intan_Nc, writeIntanNcFile, 
%   read_Intan_RHD2000_file_to_struct
%
% Version: 1.0
% Author:  Intan Technologies, Anindita Das, Vikram Gadagkar, Brian Kardon,
%   possibly others
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Brian Kardon, modified April 2021 to write .nc binary files instead of .txt files

% Anindita Das, July 2018, edited on August 2019 for 'song-searching'.
% Reads and extracts Intan files and saves into text files with date and time
% Checks the value of analog signal and whenever it crosses a threshold (say time t), it saves the 2 analog channel data
% accelerator data if present and 16 amplifier channel data for (t-5)s to(t+5) sec.
% uses the date, time and filename extracted from rhd file to create the
% .txt file name

% first goes into the directory and extracts date & time info from the first
% rhd file. It then loops through all the rhd files in that folder and
% looks through the analog channel data first.
% One directory correspondes to one recording session/day and
% so time stamp is contiguous across the rhd files (t_amplifier data) in that directory. Hence
% all time stamps in the txt files is calculated based on the time of the
% first rhd file and the incremental time step of the t_amplifier array.

% Modified for multiple headstages with accelerometers.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('start_index', 'var')
    start_index = 1;
end
if ~exist('verbose', 'var')
    verbose = 0;
end
if ~exist('path_input', 'var') || isempty(path_input)
    path_input = ...
        uigetdir('.', 'Select RHD data folder for extraction');  % directory where the rhd files to be analysed are stored
end
fprintf('Looking for rhd files in: \n\t ''%s''\n', path_input);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extracts time and date info from the first RHD file in the directory

Intan_file_dir = dir(fullfile(path_input, '*.rhd')); % Goes to the folder where all the rhd files for one recording session is stored
first_rhd_file = Intan_file_dir(1).name;   % extracts name of first file for date and time
month = first_rhd_file((numel(first_rhd_file)-11-3):(numel(first_rhd_file)-11-2));
day = first_rhd_file((numel(first_rhd_file)-11-1):(numel(first_rhd_file)-11));
year = first_rhd_file((numel(first_rhd_file)-11-5):(numel(first_rhd_file)-11-4));
rhd_file_first = Intan_file_dir(1).name;
year = 2000 + str2double(year);
month = str2double(month);
day = str2double(day);


%The time from the first RHD file in the directory is used to compute
%subsequent times for the txt files

hour_first = str2double(rhd_file_first((numel(rhd_file_first)-4-5):(numel(rhd_file_first)-4-4)));
minute_first = str2double(rhd_file_first((numel(rhd_file_first)-4-3):(numel(rhd_file_first)-4-2)));
second_first = str2double(rhd_file_first((numel(rhd_file_first)-4-1):(numel(rhd_file_first)-4)));
time_first = sprintf('%d:%02u:%02u', hour_first, minute_first, second_first); %extract time from rhd file


date_string = sprintf('%04d%02d%02d', year, month, day);
%time_string = sprintf('%s%s%s', first_rhd_file((numel(first_rhd_file)-4-5):(numel(first_rhd_file)-4-4)), first_rhd_file((numel(first_rhd_file)-4-3):(numel(first_rhd_file)-4-2)),first_rhd_file((numel(first_rhd_file)-4-1):(numel(first_rhd_file)-4)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The next section is for parsing a single RHD file amplifier data with song signal into txt
% files and saving in separate folders according to the headstage it was
% recorded from

buffer_start =2 ; % time (sec) before analog signal crosses threshold first time in one adc channel data file
buffer_end = 10;  % time (sec) after first threshold crossing of analog signal
file_count=1;

% acc_present=0; %(variable to check if accelerometer signal is present.)


for file_num = start_index:numel(Intan_file_dir)    % goes through all rhd files in one directory (one recording session)
    fprintf('Reading rhd file %d of %d\n', file_num, numel(Intan_file_dir));
    
    data = read_Intan_RHD2000_file_to_struct(path_input, Intan_file_dir(file_num).name, verbose);       %reads *rhd files into a data struct.
    
    rhd_file = Intan_file_dir(file_num).name;
    hour_filename = str2double(rhd_file((numel(rhd_file)-4-5):(numel(rhd_file)-4-4)));
    minute_filename = str2double(rhd_file((numel(rhd_file)-4-3):(numel(rhd_file)-4-2)));
    second_filename = str2double(rhd_file((numel(rhd_file)-4-1):(numel(rhd_file)-4)));
    time_filename = sprintf('%d:%02u:%02u', hour_filename,  minute_filename, second_filename); %extract time from rhd file
    
    %parameters
    fs = data.frequency_parameters.amplifier_sample_rate; % sampling frequency Hz
    channel_count = 16; %(figure out a way to NOT hard code this)rhd files don't save the number of headstages being recorded from, but all amp channels are saved as a continuous series
    delta_t=1/fs;
    unit = 1e-6;     % conversion factor (Intan amplifier data is in microvolt, digital and analog inputs are in Volts)
    total_headstage = size(data.amplifier_channels,2)/channel_count;
    headstage_count=1;
    
    if file_num==start_index
        motif_number_array=zeros(1,total_headstage);   % needs to be initialized only once
    end
    
    n_acc=0; % used later to keep track of headstages with acc based on the acc_array input by user before running this script
    if (file_num==start_index) && (isfield(data, 'aux_input_channels'))
        acc_present=1;
        number_aux = size(data.aux_input_channels, 2);
        fs_aux = data.frequency_parameters.aux_input_sample_rate;
    end
    % for every channel recorded in a single rhd file, the first time is identical
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%writing the song file on chan 0, efference copy on chan 17
    
    for headstage_num = 1:total_headstage
        fprintf('\tHandling headstage %d of %d\n', headstage_num, total_headstage);

        path_output = sprintf('%s%sHeadstage%d', path_input, '\Data_extracted\',headstage_count);   %new directory where extracted files will be stored
        [success, msg, err] = mkdir(path_output);
        if ~success
            error('Error while making headstage subfolder:\n%s\n%s', err, msg);
        end
        
        motif_number=motif_number_array(headstage_num);
        %k=(buffer_start*fs)+1;
        k=1;
        
        if (acc_present == 1) && (acc_array(headstage_num)==1)
            n_acc=n_acc+1;
        end
        
        while k < numel(data.board_adc_data(headstage_num,:))   %going through the analog channel for song
            hour=hour_first;
            minute=minute_first;
            second=second_first;
            

            if abs(data.board_adc_data(headstage_num,k)) > 0.3 %|| abs((data.amplifier_data(1,k)*unit)) > 0.003  %checks for stims if it is NOT a song file************* 

                motif_number=motif_number+1;
                motif_number_array(headstage_num)=motif_number;
                %k
%                 fprintf ('headstage number= %f\n', n);
%                 fprintf ('motif number = %f\n', motif_number);
%                 fprintf ('time point (k) = %f\n', k);
%                 fprintf ('time step (k_step) = %f\n', k_step);
%                 fprintf ('rhd file number being analyzed = %f\n', file_count);
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%this section first writes the song and eff copy data for
                %%the song-containing section of the rhd file being
                %%analyzed
                
                second=second_first+data.t_amplifier(k);    %update time
                if second >= 60
                    minute=minute+floor(second./60);
                    second = rem(second,60);
                end
                if minute >= 60
                    hour=hour+floor(minute ./60);
                    minute = rem(minute,60);
                end
                
                songChannel = 0;
                effCopyChannel = 17;
                
                time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file
                songfile_name = sprintf('d0000%04u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string, songChannel);
                full_songfile_name = fullfile(path_output,songfile_name);
                
                effcopyfile_name = sprintf('d0000%04u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string, effCopyChannel); %Changed to pad w/ 4 zeros (line 208 as well)
                full_effcopyfile_name = fullfile(path_output,effcopyfile_name);
                
                songData.timeVector = abs([year, month, day, hour, minute, second]);
                songData.metaData = sprintf('%s\t%s%d\r\n', Intan_file_dir(file_num).name, 'Motif file', motif_number);
                songData.deltaT = delta_t;
                
                % If no digital signals are present (typically DAF EC
                % signal) then don't bother recording them. Because it
                % won't work. Because they aren't there.
                recordEffCopy = isfield(data, 'board_dig_in_data');
                
                if recordEffCopy
                    effCopyData = songData;
                end
                
                if k > (numel(data.board_adc_data(headstage_num,:))- buffer_end*fs) %&& k >(numel(data.board_adc_data(2*n-1,:))- buffer_start*fs)
                    songData.data = data.board_adc_data((headstage_num),(k-(buffer_start*fs)):(numel(data.board_adc_data(headstage_num,:))));
                    if recordEffCopy
                        effCopyData.data = data.board_dig_in_data((headstage_num),(k-(buffer_start*fs)):(numel(data.board_adc_data(headstage_num,:))));
                    end
                elseif k <(buffer_start*fs+1)
                    songData.data =       data.board_adc_data((headstage_num),1:(k+(buffer_end*fs)));
                    if recordEffCopy
                        effCopyData.data = data.board_dig_in_data((headstage_num),1:(k+(buffer_end*fs)));
                    end
                else
                    songData.data = data.board_adc_data((headstage_num),(k-(buffer_start*fs)):(k+(buffer_end*fs)));
                    if recordEffCopy
                        effCopyData.data = data.board_dig_in_data((headstage_num),(k-(buffer_start*fs)):(k+(buffer_end*fs)));
                    end
                end
                
                writeIntanNcFile(full_songfile_name,    songData.timeVector,    songData.deltaT,    songChannel,    songData.metaData,    songData.data,    true);
                if recordEffCopy
                    writeIntanNcFile(full_effcopyfile_name, effCopyData.timeVector, effCopyData.deltaT, effCopyChannel, effCopyData.metaData, effCopyData.data, true);
                end
                
                fprintf('\t\tWriting chunk: %f seconds\n', length(songData.data)/fs);
                
                %file_count_anlg=file_count_anlg+1;
                %                 file_count=file_count+1;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% This section writes the accelerometer data if present
                %%%% for the coresponding song-containg section
                
                if (acc_present == 1) && (acc_array(headstage_num)==1)
                    
                    k_aux= round(fs_aux*(k/fs));   % since sampling freq of analg chans and acc chans are different
                    if k_aux < 1
                        k_aux=1;
                    end
                    hour=hour_first;
                    minute=minute_first;
                    second=second_first+data.t_aux_input(k_aux);    %update time
                    
                    if second >= 60
                        minute=minute+floor(second./60);
                        second = rem(second,60);
                    end
                    if minute >= 60
                        hour=hour+floor(minute ./60);
                        minute = rem(minute,60);
                    end
                    
                    acc1Channel = 18;
                    acc2Channel = 19;
                    acc3Channel = 20;
                    
                    time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file
                    
                    accfile1_name = sprintf('d0000%03u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string, acc1Channel);
                    full_accfile1_name = fullfile(path_output,accfile1_name);
                    
                    accfile2_name = sprintf('d0000%03u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string, acc2Channel);
                    full_accfile2_name = fullfile(path_output,accfile2_name);
                    
                    accfile3_name = sprintf('d0000%03u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string, acc3Channel);
                    full_accfile3_name = fullfile(path_output,accfile3_name);
                    
                    acc1.timeVector = abs([year, month, day, hour, minute, second]);
                    acc1.metaData = sprintf('%s\t%s%d\r\n', Intan_file_dir(file_num).name, 'Motif file', motif_number);
                    acc1.deltaT = delta_t;
                    
                    acc2 = acc1;
                    acc3 = acc1;
                    
                    if k > (numel(data.board_adc_data(headstage_num,:))- buffer_end*fs) %&& k >(numel(data.board_adc_data(2*n-1,:))- buffer_start*fs)
                        acc1.data = data.aux_input_data((3*n_acc-2),(k_aux-(buffer_start*fs_aux)):(numel(data.aux_input_data((3*n_acc-2),:))));
                        acc2.data = data.aux_input_data((3*n_acc-1),(k_aux-(buffer_start*fs_aux)):(numel(data.aux_input_data((3*n_acc-1),:))));
                        acc3.data = data.aux_input_data((3*n_acc),(k_aux-(buffer_start*fs_aux)):(numel(data.aux_input_data((3*n_acc),:))));
                    elseif k <(buffer_start*fs+1)
                        acc1.data = data.aux_input_data((3*n_acc-2),1:(k_aux+(buffer_end*fs_aux)));
                        acc2.data = data.aux_input_data((3*n_acc-1),1:(k_aux+(buffer_end*fs_aux)));
                        acc3.data = data.aux_input_data((3*n_acc),1:(k_aux+(buffer_end*fs_aux)));
                    else
                        acc1.data = data.aux_input_data((3*n_acc-2),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux)));
                        acc2.data = data.aux_input_data((3*n_acc-1),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux)));
                        acc3.data = data.aux_input_data((3*n_acc),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux)));
                    end
                    
                    writeIntanNcFile(full_accfile1_name, acc1.timeVector, acc1.deltaT, acc1Channel, acc1.metaData, acc1.data, true);
                    writeIntanNcFile(full_accfile2_name, acc2.timeVector, acc2.deltaT, acc2Channel, acc2.metaData, acc2.data, true);
                    writeIntanNcFile(full_accfile3_name, acc3.timeVector, acc3.deltaT, acc3Channel, acc3.metaData, acc3.data, true);

                    %file_count_acc=file_count_acc+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%writing the amplifier data files for the song-containing
                %%section
                
                amplifier_file_count=1;
                for chan = (channel_count*(headstage_num-1)+1):(channel_count*headstage_num)
                    hour=hour_first;
                    minute=minute_first;
                    second=second_first+data.t_amplifier(k);    %update time
                    if second >= 60
                        minute=minute+floor(second./60);
                        second = rem(second,60);
                    end
                    if minute >= 60
                        hour=hour+floor(minute./60);
                        minute = rem(minute,60);
                    end
                    time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file

                    file_name = sprintf('d0000%03u_%sT%s_chan%d.nc',motif_number_array(headstage_num),date_string, time_string,amplifier_file_count);
                    full_file_name = fullfile(path_output,file_name);

                    otherChannel.timeVector = abs([year, month, day, hour, minute, second]);
                    otherChannel.metaData = sprintf('%s\t%s%d\r\n', Intan_file_dir(file_num).name, 'Motif file', motif_number);
                    otherChannel.deltaT = delta_t;
                    
                    if k > (numel(data.board_adc_data(headstage_num,:))- buffer_end*fs) %&& k >(numel(data.board_adc_data(2*n-1,:))- buffer_start*fs)
                        otherChannel.data = data.amplifier_data(chan,(k-(buffer_start*fs)):(numel(data.board_adc_data(headstage_num,:))))*unit;
                    elseif k <(buffer_start*fs+1)
                        otherChannel.data = data.amplifier_data(chan,1:(k+(buffer_end*fs)))*unit;
                    else
                        otherChannel.data = data.amplifier_data(chan,(k-(buffer_start*fs)):(k+(buffer_end*fs)))*unit;
                    end
                    
                    writeIntanNcFile(full_file_name, otherChannel.timeVector, otherChannel.deltaT, chan, otherChannel.metaData, otherChannel.data, true);

                    amplifier_file_count=amplifier_file_count+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                k_step =(buffer_end*fs)+20;   % to avoid over-writing....
                k=k+k_step;
            else
                k_step=(0.05*fs)+1;     %%%step jump when it doesn't find song signal (keeping this large enough to save time and small enough to avoid missing anything)
                k=k+k_step;
            end
        end
        headstage_count = headstage_count+1;
        
    end
    file_count=file_count+1;
end






