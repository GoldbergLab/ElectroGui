function [data, fs, timestamp, label, props] = egl_AudioRead(filename, loadData)
% ElectroGui file loader
% Reads any audio files (even extracts audio from video files)
% Extracts date and time information from the file info

if loadData
    [data, fs] = audioread(filename);
    if size(data, 2) > 1
        warning('Audio file %s has multiple tracks - discarding all except first one', filename);
        data = data(:, 1);
    end
    fileInfo = dir(filename);
    timestamp = datenum(fileInfo(1).date);
    label = 'Sound level';
else
    data = [];
    fs = [];
    timestamp = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];