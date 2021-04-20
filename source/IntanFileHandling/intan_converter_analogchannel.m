
% Anindita Das, July 2018, edited for multiple headstages on April 2019
% Reads and extracts Intan files and saves into text files with date and time
% Checks the value of analog signal and whenever it crosses a threshold (say time t), it saves the 2 analog channel data
% and 16 amplifier channel data for (t-3)s to(t+5) sec.
% uses the date, time and filename extracted from rhd file to create the
% .txt file name


% first goes into the directory and extracts date & time info from the first
% rhd file. It then loops through all the rhd files in that folder and
% looks through the analog channel data first.
% One directory correspondes to one recording session/day and
% so time stamp is contiguous across the rhd files (t_amplifier data) in that directory. Hence
% all time stamps in the txt files is calculated based on the time of the
% first rhd file and the incremental time step of the t_amplifier array.


clear all;
path_input = ...
    uigetdir('D:\STN\INTAN\', 'Select RHD data folder for extraction');  % directory where the rhd files to be analysed are stored



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

buffer_start =5 ; % time (sec) before analog signal crosses threshold first time in one adc channel data file
buffer_end = 5;  % time (sec) after first threshold crossing of analog signal
file_count=1;
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
    k=0;
    % for every channel recorded in a single rhd file, the first time is identical
    
    %%writing the song file on chan 0, efference copy on chan 17
    
    for n = 1:total_headstage
        
        
        path_output = sprintf('%s%sHeadstage%d', path_input, '\Data_extracted\',headstage_count);   %new directory where extracted files will be stored
        mkdir(path_output);
        
        motif_number=0;
        k=(buffer_start*fs)+1;
        
        while k < numel(board_adc_data(2*n-1,:))
            hour=hour_first;
            minute=minute_first;
            second=second_first;
            time=time_first;
            
            if board_adc_data((2*n-1),k) > 0.1
                
                motif_number=motif_number+1;
                fprintf ('headstage number= %f\n', n);
                fprintf ('motif number = %f\n', motif_number);
                fprintf ('time point (k) = %f\n', k);
                fprintf ('time step (k_step) = %f\n', k_step);
                fprintf ('rhd file number being analyzed = %f\n', file_count);
                
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
                songfile_name = sprintf('Headstage%d_d0000%02u_%sT%s_chan0.txt',n,motif_number,date_string, time_string);
                full_songfile_name = fullfile(path_output,songfile_name);
                
                effcopyfile_name = sprintf('Headstage%d_d0000%02u_%sT%s_chan17.txt',n,motif_number,date_string, time_string);
                full_effcopyfile_name = fullfile(path_output,effcopyfile_name);
                
                
                songfileID = fopen(full_songfile_name,'w');
                
                effcopyfileID = fopen(full_effcopyfile_name,'w');
                
                
                fprintf(songfileID,'%s\t%s\r\n', date, time);
                fprintf(songfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', motif_number);
                fprintf(songfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                
                fprintf(effcopyfileID,'%s\t%s\r\n', date, time);
                fprintf(effcopyfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', motif_number);
                fprintf(effcopyfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                
                if k < (numel(board_adc_data(2*n-1,:))- buffer_end*fs)
                    fprintf(songfileID,'%f\r\n', board_adc_data((2*n-1),(k-(buffer_start*fs)):(k+(buffer_end*fs))));
                    fprintf(effcopyfileID,'%f\r\n', board_adc_data((2*n),(k-(buffer_start*fs)):(k+(buffer_end*fs))));
                else
                    fprintf(songfileID,'%f\r\n', board_adc_data((2*n-1),(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:)))));
                    fprintf(effcopyfileID,'%f\r\n', board_adc_data((2*n),(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:)))));
                end
                
                fclose(songfileID);
                fclose(effcopyfileID);
                
                %                 file_count=file_count+1;
                
                
                
                %%writing the amplifier data files
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
                    
                    file_name = sprintf('Headstage%d_d0000%02u_%sT%s_chan%d.txt',n,motif_number,date_string, time_string,amplifier_file_count);
                    full_file_name = fullfile(path_output,file_name);
                    fileID = fopen(full_file_name,'w');
                    
                    fprintf(fileID,'%s\t%s\r\n', date, time);
                    fprintf(fileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', motif_number);
                    fprintf(fileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
                    if k < (numel(board_adc_data(2*n-1,:))- buffer_end*fs)
                        fprintf(fileID,'%f\r\n', amplifier_data(i,(k-(buffer_start*fs)):(k+(buffer_end*fs)))*unit);
                    else
                        fprintf(fileID,'%f\r\n', amplifier_data(i,(k-(buffer_start*fs)):(numel(board_adc_data(2*n-1,:))))*unit);
                    end
                    
                    fclose(fileID);
                    amplifier_file_count=amplifier_file_count+1;
                end
                k_step =(buffer_end*fs)+1;   % to avoid over-writing....
                k=k+k_step;
            else
                k_step=(0.1*fs)+1;
                k=k+k_step;
            end
        end
        headstage_count = headstage_count+1;
        
    end
    file_count=file_count+1;
end






