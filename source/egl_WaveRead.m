function [data, fs, dateandtime, label, props] = egl_WaveRead(filename, loaddata)
% ElectroGui file loader
% Reads wavefiles
% Extracts date and time information from the file info

if loaddata == 1
    [data fs] = audioread(filename);
    if size(data, 2) > 1
        warning('Audio has multiple channels - discarding all except channel 1');
        data = data(:, 1);
    end
    mt = dir(filename);
    dateandtime = datenum(mt(1).date);
    label = 'Sound level';
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];