% Anindita Das, 2018
% Goes to the directory for the wav files of the day and extracts time info
% one by one
% Compares the time stamp of first wav file with the time stamp on the rhd
% files. Stops comparison when the right file is found and moves it to
% another directory (create a folder appropriately). Exit loop and extract
% time from next wav file. Continue comparison from next rhd file.
% Finally, delete files left behind in the original rhd data folder.


path_input = ...
    uigetdir('C:\Users\Goldberg Lab\Documents\Labview\Labview_Song_Recordings\', 'Select correct folder to access wav files');  % directory where the wav files for the day are stored

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extracts bird id, time and date info from the first wav file in the directory

LabviewSong_file_dir = dir(fullfile(path_input, '*.wav')); % lists all the wav files for that day

name_firstwav_file = LabviewSong_file_dir(1).name;

month = name_firstwav_file((numel(name_firstwav_file)-13-4):(numel(name_firstwav_file)-13-3));
day = name_firstwav_file((numel(name_firstwav_file)-13-1):(numel(name_firstwav_file)-13));
date = sprintf ('%s%s%s', month, '_', day);
birdid = name_firstwav_file(1:9); %extract bird id from wav file

Intandirname = sprintf ('%s%s%s%s%s','C:\Users\Goldberg Lab\Documents\Intan\Data\', birdid,'\', date, '\');

path_output = sprintf('%s%s', Intandirname, '\Data_sorted\');   %new directory where selected rhd files will be stored
mkdir(path_output);

Intandata_file_dir = dir(fullfile(Intandirname, '*.rhd')); % lists all the rhd in a folder

for j = 1:numel(LabviewSong_file_dir)
    
    name_wav_file = LabviewSong_file_dir(j).name;
    hour_wav = str2double(name_wav_file((numel(name_wav_file)-4-7):(numel(name_wav_file)-4-6)));
    minute_wav = str2double(name_wav_file((numel(name_wav_file)-4-4):(numel(name_wav_file)-4-3)));
    second_wav = str2double(name_wav_file((numel(name_wav_file)-4-1):(numel(name_wav_file)-4)));
    
    for i = 2:numel (Intandata_file_dir)
        
        currentrhdfilename = Intandata_file_dir(i).name;
        hour_rhd = str2double(currentrhdfilename((numel(currentrhdfilename)-4-5):(numel(currentrhdfilename)-4-4)));
        minute_rhd = str2double(currentrhdfilename((numel(currentrhdfilename)-4-3):(numel(currentrhdfilename)-4-2)));
        second_first = str2double(currentrhdfilename((numel(currentrhdfilename)-4-1):(numel(currentrhdfilename)-4)));
        
        if hour_wav == hour_rhd
            if minute_wav == minute_rhd
                if second_wav >= second_rhd
                    movefile Intandata_file_dir(i) path_output
                end
            else
                break;
            end
        else
            break;
        end
    end
end

    
    
    