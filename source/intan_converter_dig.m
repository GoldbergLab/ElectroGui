
% Anindita Das, July 2018
% Reads Intan files and saves into text files with date and time
% Splits each 1 min Intan channel data into 3 '20 sec' txt files
% uses the bird id and the date, time and filename extracted from rhd file to create the .txt file
% name



% first goes into the directory and extracts date, time, bird id info from the first
% rhd file. It then loops through all the rhd files in that folder and
% creates 20 sec data txt files for all 16+1 channels in each rhd file in
% that directory. One directory correspondes to one recording session and
% so time stamp is contiguous across the rhd files in that directory. Hence
% all time stamps in the txt files is calculated based on the time of the
% first rhd file and the incremental time step of the t_amplifier array.



path_input = ...
    uigetdir('D:\STN\INTAN\', 'Select RHD data folder for extraction');  % directory where the rhd files to be analysed are stored

path_output = sprintf('%s%s', path_input, '\Data_extracted\');   %new directory where extracted files will be stored
mkdir(path_output);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extracts bird id, time and date info from the first RHD file in the directory

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
time_first = sprintf('%d:%02u:%f', hour_first, minute_first, second_first); %extract time from rhd file


date_string = sprintf('20%s%s%s', year,month, day);
%time_string = sprintf('%s%s%s', first_rhd_file((numel(first_rhd_file)-4-5):(numel(first_rhd_file)-4-4)), first_rhd_file((numel(first_rhd_file)-4-3):(numel(first_rhd_file)-4-2)),first_rhd_file((numel(first_rhd_file)-4-1):(numel(first_rhd_file)-4)));
birdid = first_rhd_file(1:4); %extract bird id from rhd file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The next section is for parsing a single RHD file amplifier data into txt files with
%  each of the 16+3 channels subdivided into 20 sec data
file_count=1;
amplifier_file_count=1;
rhd_file_count=1;
buffer_time = 5; % time before and after digital song detect for which all ephys and song data will be extracted

for j = 1:numel(Intan_file_dir)    % goes through all rhd files in one directory (one recording session)
    
    read_Intan_RHD2000_file_AD(path_input, Intan_file_dir(j).name);       %reads *rhd files into matlab 
    
    rhd_file = Intan_file_dir(j).name;
    hour_filename = str2double(rhd_file((numel(rhd_file)-4-5):(numel(rhd_file)-4-4)));
    minute_filename = str2double(rhd_file((numel(rhd_file)-4-3):(numel(rhd_file)-4-2)));
    second_filename = str2double(rhd_file((numel(rhd_file)-4-1):(numel(rhd_file)-4)));
    time_filename = sprintf('%d:%02u:%f', hour_filename,  minute_filename, second_filename); %extract time from rhd file
    
    %parameters
    fs = frequency_parameters.amplifier_sample_rate; % sampling frequency 
    sfs = 20;  %split file size should be 20 sec
    sfn = (round(numel(t_amplifier)/fs))/sfs;  % counts split file number for one channel depending on total time per rhd file
    channel_count = 16;      % change this only if your experimental setup uses higher channel count!!
    delta_t=1/fs;
    unit = 1e-6;     % conversion factor (Intan amplifier data is in microvolt, digital and analog inputs are in Volts)
    
      % for every channel recorded in a single rhd file, the first time is identical
    
    %%writing the song file on chan 0, efference copy on chan 17, digital input on
    %%chan 18
    
    for k = ((buffer_time*fs)+1):numel(board_dig_in_data)
        if board_dig_in_data(k) > 0
           
            hour=hour_first;
            minute=minute_first;
            second=second_first;
            time=time_first;  
            
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
        songfile_name = sprintf('%s_d0000%02u_%sT%s_chan0.txt',birdid,file_count,date_string, time_string);
        full_songfile_name = fullfile(path_output,songfile_name);
        
        effcopyfile_name = sprintf('%s_d0000%02u_%sT%s_chan17.txt',birdid,file_count,date_string, time_string);
        full_effcopyfile_name = fullfile(path_output,effcopyfile_name);
        
        digfile_name = sprintf('%s_d0000%02u_%sT%s_chan18.txt',birdid,file_count,date_string, time_string);
        full_digfile_name = fullfile(path_output,digfile_name);
        
        songfileID = fopen(full_songfile_name,'w');
        
        effcopyfileID = fopen(full_effcopyfile_name,'w');
        
        digfileID = fopen(full_digfile_name,'w');
        
        fprintf(songfileID,'%s\t%s\r\n', date, time);
        fprintf(songfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(songfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        
        fprintf(effcopyfileID,'%s\t%s\r\n', date, time);
        fprintf(effcopyfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(effcopyfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        
        fprintf(digfileID,'%s\t%s\r\n', date, time);
        fprintf(digfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(digfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        end
        
        fprintf(songfileID,'%f\r\n', board_adc_data(1,(k-(buffer_time*fs)):(k+(buffer_time*fs)));
        fprintf(effcopyfileID,'%f\r\n', board_adc_data(2,(k-(buffer_time*fs)):(k+(buffer_time*fs)));
        fprintf(digfileID,'%f\r\n', board_dig_in_data(1,(k-(buffer_time*fs)):(k+(buffer_time*fs)));
        
        k = k+(buffer_time*fs)+1;   % ensure that the tracking of digital signal starts after the buffer time to avoid over-writing in cases where a second signal is generated (Labview bug!)
        
    
        
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
        songfile_name = sprintf('%s_d0000%02u_%sT%s_chan0.txt',birdid,file_count,date_string, time_string);
        full_songfile_name = fullfile(path_output,songfile_name);
        
        effcopyfile_name = sprintf('%s_d0000%02u_%sT%s_chan17.txt',birdid,file_count,date_string, time_string);
        full_effcopyfile_name = fullfile(path_output,effcopyfile_name);
        
        digfile_name = sprintf('%s_d0000%02u_%sT%s_chan18.txt',birdid,file_count,date_string, time_string);
        full_digfile_name = fullfile(path_output,digfile_name);
        
        songfileID = fopen(full_songfile_name,'w');
        
        effcopyfileID = fopen(full_effcopyfile_name,'w');
        
        digfileID = fopen(full_digfile_name,'w');
        
        fprintf(songfileID,'%s\t%s\r\n', date, time);
        fprintf(songfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(songfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        
        fprintf(effcopyfileID,'%s\t%s\r\n', date, time);
        fprintf(effcopyfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(effcopyfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        
        fprintf(digfileID,'%s\t%s\r\n', date, time);
        fprintf(digfileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
        fprintf(digfileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
        
        
        if n == sfn
            fprintf(songfileID,'%f\r\n', board_adc_data(1,(((n-1)*sfs*fs)+1):numel(t_amplifier)));
            fprintf(effcopyfileID,'%f\r\n', board_adc_data(2,(((n-1)*sfs*fs)+1):numel(t_amplifier)));
            fprintf(digfileID,'%f\r\n', board_dig_in_data(1,(((n-1)*sfs*fs)+1):numel(t_amplifier)));
        else
            fprintf(songfileID,'%f\r\n', board_adc_data(1,(((n-1)*sfs*fs)+1):(((n-1)*sfs+sfs)*fs)));
            fprintf(effcopyfileID,'%f\r\n', board_adc_data(2,(((n-1)*sfs*fs)+1):(((n-1)*sfs+sfs)*fs)));
            fprintf(digfileID,'%f\r\n', board_dig_in_data(1,(((n-1)*sfs*fs)+1):(((n-1)*sfs+sfs)*fs)));
        end
        fclose(songfileID);
        fclose(effcopyfileID);
        fclose(digfileID);
        
        file_count=file_count+1;
    end
    
    
    %%writing the amplifier data files
    
    for i = 1:channel_count
        amplifier_file_count=rhd_file_count;
        hour=hour_first;
        minute=minute_first;
        second=second_first;
        time=time_first;   % for every channel recorded in a single rhd file, the first time identical
        for n = 1:sfn  % sub-channel file number
            second=second_first+t_amplifier((((n-1)*sfs)*fs)+1);    %update time
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
            
            file_name = sprintf('%s_d0000%02u_%sT%s_chan%d.txt',birdid,amplifier_file_count,date_string, time_string,i);
            full_file_name = fullfile(path_output,file_name);
            fileID = fopen(full_file_name,'w');
            fprintf(fileID,'%s\t%s\r\n', date, time);
            fprintf(fileID,'%s\t%s%d\r\n', Intan_file_dir(j).name, 'Sub file', n);
            fprintf(fileID,'%s%f\r\n\r\n', 'delta_t = ', delta_t);
            if n == sfn
                fprintf(fileID,'%f\r\n', amplifier_data(i,(((n-1)*sfs*fs)+1):numel(t_amplifier))*unit);
            else
                fprintf(fileID,'%f\r\n', amplifier_data(i,(((n-1)*sfs*fs)+1):(((n-1)*sfs+sfs)*fs))*unit);
            end
            fclose(fileID);
            amplifier_file_count=amplifier_file_count+1;
        end
    end
    rhd_file_count=rhd_file_count+sfn;
end





