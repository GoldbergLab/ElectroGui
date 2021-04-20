
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

%%IMPORTANT!! On the command window make an array named acc_array=[x x x x]
%%where x = 0 or 1 according to whether each of the four headstages recorded from in the Intan files
%%have an accelerometer or not. Do this BEFORE running the script.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path_input = ...
    uigetdir('D:\STN\INTAN\', 'Select RHD data folder for extraction');  % directory where the rhd files to be analysed are stored


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extracts time and date info from the first RHD file in the directory

Intan_file_dir = dir(fullfile(path_input, '*.rhd')); % Goes to the folder where all the rhd files for one recording session is stored
first_rhd_file = Intan_file_dir(1).name;   % extracts name of first file for date and time
month = first_rhd_file((numel(first_rhd_file)-11-3):(numel(first_rhd_file)-11-2));
day = first_rhd_file((numel(first_rhd_file)-11-1):(numel(first_rhd_file)-11));
year = first_rhd_file((numel(first_rhd_file)-11-5):(numel(first_rhd_file)-11-4));
date = sprintf('%s/%s/20%s', month, day, year); %extract date from rhd file
rhd_file_first = Intan_file_dir(1).name;


%The time from the first RHD file in the directory is used to compute
%subsequent times for the txt files

hour_first = str2double(rhd_file_first((numel(rhd_file_first)-4-5):(numel(rhd_file_first)-4-4)));
minute_first = str2double(rhd_file_first((numel(rhd_file_first)-4-3):(numel(rhd_file_first)-4-2)));
second_first = str2double(rhd_file_first((numel(rhd_file_first)-4-1):(numel(rhd_file_first)-4)));
time_first = sprintf('%d:%02u:%02u', hour_first, minute_first, second_first); %extract time from rhd file


date_string = sprintf('20%s%s%s', year,month, day);
%time_string = sprintf('%s%s%s', first_rhd_file((numel(first_rhd_file)-4-5):(numel(first_rhd_file)-4-4)), first_rhd_file((numel(first_rhd_file)-4-3):(numel(first_rhd_file)-4-2)),first_rhd_file((numel(first_rhd_file)-4-1):(numel(first_rhd_file)-4)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The next section is for parsing a single RHD file amplifier data with song signal into txt
% files and saving in separate folders according to the headstage it was
% recorded from

buffer_start =2 ; % time (sec) before analog signal crosses threshold first time in one adc channel data file
buffer_end = 10;  % time (sec) after first threshold crossing of analog signal
file_count=1;

acc_present=0; %(variable to check if accelerometer signal is present.)


for j = 1:numel(Intan_file_dir)    % goes through all rhd files in one directory (one recording session)
    
    read_Intan_RHD2000_file_AD(path_input, Intan_file_dir(j).name);       %reads *rhd files into matlab
    
    rhd_file = Intan_file_dir(j).name;
    hour_filename = str2double(rhd_file((numel(rhd_file)-4-5):(numel(rhd_file)-4-4)));
    minute_filename = str2double(rhd_file((numel(rhd_file)-4-3):(numel(rhd_file)-4-2)));
    second_filename = str2double(rhd_file((numel(rhd_file)-4-1):(numel(rhd_file)-4)));
    time_filename = sprintf('%d:%02u:%02u', hour_filename,  minute_filename, second_filename); %extract time from rhd file
    
    %parameters
    fs = frequency_parameters.amplifier_sample_rate; % sampling frequency Hz
    channel_count = 16; %(figure out a way to NOT hard code this)rhd files don't save the number of headstages being recorded from, but all amp channels are saved as a continuous series
    delta_t=1/fs;
    unit = 1e-6;     % conversion factor (Intan amplifier data is in microvolt, digital and analog inputs are in Volts)
    total_headstage = size(amplifier_channels,2)/channel_count;
    headstage_count=1;
    
    if j==1
        motif_number_array=zeros(1,total_headstage);   % needs to be initialized only once
    end
    
    n_acc=0; % used later to keep track of headstages with acc based on the acc_array input by user before running this script
    if (j==1) && (exist('aux_input_channels')== 1)
        acc_present=1
        number_aux = size(aux_input_channels, 2);
        fs_aux = frequency_parameters.aux_input_sample_rate;
    end
    % for every channel recorded in a single rhd file, the first time is identical
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%writing the song file on chan 0, efference copy on chan 17
    
    for n = 1:total_headstage
        
        path_output = sprintf('%s%sHeadstage%d', path_input, '\Data_extracted\',headstage_count);   %new directory where extracted files will be stored
        mkdir(path_output);
        
        motif_number=motif_number_array(n);
        %k=(buffer_start*fs)+1;
        k=1;
        
        if (acc_present == 1) && (acc_array(n)==1)
            n_acc=n_acc+1;
        end
        
        while k < numel(board_adc_data(2*n-1,:))   %going through the analog channel for song
            hour=hour_first;
            minute=minute_first;
            second=second_first;
            time=time_first;
            
            if board_adc_data((2*n-1),k) > 0.01 %|| abs((amplifier_data(1,k)*unit)) > 0.003  %checks for stims if it is NOT a song file
             
           
                motif_number=motif_number+1;
                motif_number_array(n)=motif_number;
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
                
                second=second_first+t_amplifier(k);    %update time
                if second >= 60
                    minute=minute+floor(second./60);
                    second = rem(second,60);
                end
                if minute >= 60
                    hour=hour+floor(minute ./60);
                    minute = rem(minute,60);
                end
                
                time = sprintf('%d:%02u:%f', hour, minute, second);  %this gets updated within the text file
                time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file
                songfile_name = sprintf('d0000%03u_%sT%s_chan0.txt',motif_number_array(n),date_string, time_string);
                full_songfile_name = fullfile(path_output,songfile_name);
                
                effcopyfile_name = sprintf('d0000%03u_%sT%s_chan17.txt',motif_number_array(n),date_string, time_string);
                full_effcopyfile_name = fullfile(path_output,effcopyfile_name);
                
                
                songfileID = fopen(full_songfile_name,'w');
                
                effcopyfileID = fopen(full_effcopyfile_name,'w');
                
                
                fprintf(songfileID,'%s\t%s\r\n', date, time);
                fprintf(songfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                fprintf(songfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                
                fprintf(effcopyfileID,'%s\t%s\r\n', date, time);
                fprintf(effcopyfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                fprintf(effcopyfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                
                if k > (numel(board_adc_data(2*n-1,:))- buffer_end*fs) %&& k >(numel(board_adc_data(2*n-1,:))- buffer_start*fs)
                    fprintf(songfileID,'%f\r\n', board_adc_data((2*n-1),(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:)))));
                    fprintf(effcopyfileID,'%f\r\n', board_dig_in_data((2*n-1),(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:)))));
                elseif k <(buffer_start*fs+1)
                    fprintf(songfileID,'%f\r\n', board_adc_data((2*n-1),k:(k+(buffer_end*fs))));
                    fprintf(effcopyfileID,'%f\r\n', board_dig_in_data((2*n-1),k:(k+(buffer_end*fs))));
                else
                    fprintf(songfileID,'%f\r\n', board_adc_data((2*n-1),(k-(buffer_start*fs)):(k+(buffer_end*fs))));
                    fprintf(effcopyfileID,'%f\r\n', board_dig_in_data((2*n-1),(k-(buffer_start*fs)):(k+(buffer_end*fs))));
                end
                
                fclose(songfileID);
                fclose(effcopyfileID);
                %file_count_anlg=file_count_anlg+1;
                %                 file_count=file_count+1;
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%% This section writes the accelerometer data if present
                %%%% for the coresponding song-containg section
                
                if (acc_present == 1) && (acc_array(n)==1)
                    
                    k_aux= round(fs_aux*(k/fs));   % since sampling freq of analg chans and acc chans are different
                    if k_aux < 1
                        k_aux=1;
                    end
                    hour=hour_first;
                    minute=minute_first;
                    second=second_first;
                    time=time_first;
                    
                    second=second_first+t_aux_input(k_aux);    %update time
                    if second >= 60
                        minute=minute+floor(second./60);
                        second = rem(second,60);
                    end
                    if minute >= 60
                        hour=hour+floor(minute ./60);
                        minute = rem(minute,60);
                    end
                    
                    time = sprintf('%d:%02u:%f', hour, minute, second);  %this gets updated within the text file
                    time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file
                    
                    accfile1_name = sprintf('d0000%03u_%sT%s_chan18.txt',motif_number_array(n),date_string, time_string);
                    full_accfile1_name = fullfile(path_output,accfile1_name);
                    
                    accfile2_name = sprintf('d0000%03u_%sT%s_chan19.txt',motif_number_array(n),date_string, time_string);
                    full_accfile2_name = fullfile(path_output,accfile2_name);
                    
                    accfile3_name = sprintf('d0000%03u_%sT%s_chan20.txt',motif_number_array(n),date_string, time_string);
                    full_accfile3_name = fullfile(path_output,accfile3_name);
                    
                    
                    accfile1ID = fopen(full_accfile1_name,'w');
                    accfile2ID = fopen(full_accfile2_name,'w');
                    accfile3ID = fopen(full_accfile3_name,'w');
                    
                    
                    fprintf(accfile1ID,'%s\t%s\r\n', date, time);
                    fprintf(accfile1ID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                    fprintf(accfile1ID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                    
                    
                    fprintf(accfile2ID,'%s\t%s\r\n', date, time);
                    fprintf(accfile2ID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                    fprintf(accfile2ID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                    
                    
                    fprintf(accfile3ID,'%s\t%s\r\n', date, time);
                    fprintf(accfile3ID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                    fprintf(accfile3ID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                    
                    if k > (numel(board_adc_data(2*n-1,:))- buffer_end*fs) %&& k >(numel(board_adc_data(2*n-1,:))- buffer_start*fs)
                        fprintf(accfile1ID,'%f\r\n', aux_input_data((3*n_acc-2),(k_aux-(buffer_start*fs_aux)):(numel(aux_input_data((3*n_acc-2),:)))));
                        fprintf(accfile2ID,'%f\r\n', aux_input_data((3*n_acc-1),(k_aux-(buffer_start*fs_aux)):(numel(aux_input_data((3*n_acc-1),:)))));
                        fprintf(accfile3ID,'%f\r\n', aux_input_data((3*n_acc),(k_aux-(buffer_start*fs_aux)):(numel(aux_input_data((3*n_acc),:)))));
                    elseif k <(numel(board_adc_data(2*n-1,:))- buffer_start*fs)
                        fprintf(accfile1ID,'%f\r\n', aux_input_data((3*n_acc-2),k_aux:(k_aux+(buffer_end*fs_aux))));
                        fprintf(accfile2ID,'%f\r\n', aux_input_data((3*n_acc-1),k_aux:(k_aux+(buffer_end*fs_aux))));
                        fprintf(accfile3ID,'%f\r\n', aux_input_data((3*n_acc),k_aux:(k_aux+(buffer_end*fs_aux))));
                    else
                        fprintf(accfile1ID,'%f\r\n', aux_input_data((3*n_acc-2),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux))));
                        fprintf(accfile2ID,'%f\r\n', aux_input_data((3*n_acc-1),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux))));
                        fprintf(accfile3ID,'%f\r\n', aux_input_data((3*n_acc),(k_aux-(buffer_start*fs_aux)):(k_aux+(buffer_end*fs_aux))));
                    end
                    
                    fclose(accfile1ID);
                    fclose(accfile2ID);
                    fclose(accfile3ID);
                    
                    %file_count_acc=file_count_acc+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                %%writing the amplifier data files for the song-containing
                %%section
                
                amplifier_file_count=1;
                for i = (channel_count*(n-1)+1):(channel_count*n)
                    hour=hour_first;
                    minute=minute_first;
                    second=second_first;
                    time=time_first;   % for every channel recorded in a single rhd file, the first time identical
                    
                    second=second_first+t_amplifier(k);    %update time
                    if second >= 60
                        minute=minute+floor(second./60);
                        second = rem(second,60);
                    end
                    if minute >= 60
                        hour=hour+floor(minute./60);
                        minute = rem(minute,60);
                    end
                    time = sprintf('%d:%02u:%f', hour, minute, second);  %this gets updated within the text file
                    time_string= sprintf('%s%s%s',num2str(hour_filename), num2str(minute_filename),num2str(second_filename,'% 10.0f')); %this is only for labelling txt files and does not get updated for the same rhd file
                    
                    file_name = sprintf('d0000%03u_%sT%s_chan%d.txt',motif_number_array(n),date_string, time_string,amplifier_file_count);
                    full_file_name = fullfile(path_output,file_name);
                    fileID = fopen(full_file_name,'w');
                    
                    fprintf(fileID,'%s\t%s\r\n', date, time);
                    fprintf(fileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Motif file', motif_number);
                    fprintf(fileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                    
                    if k > (numel(board_adc_data(2*n-1,:))- buffer_end*fs) %&& k >(numel(board_adc_data(2*n-1,:))- buffer_start*fs)
                        fprintf(fileID,'%f\r\n', amplifier_data(i,(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:))))*unit);
                    elseif k <(numel(board_adc_data(2*n-1,:))- buffer_start*fs)
                        fprintf(fileID,'%f\r\n', amplifier_data(i,k:(k+(buffer_end*fs)))*unit);
                    else
                        fprintf(fileID,'%f\r\n', amplifier_data(i,(k-(buffer_start*fs)):(k+(buffer_end*fs)))*unit);
                    end
                    
                    fclose(fileID);
                    amplifier_file_count=amplifier_file_count+1;
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                k_step =(buffer_end*fs)+1;   % to avoid over-writing....
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






