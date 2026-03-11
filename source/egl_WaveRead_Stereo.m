function [data, fs, dateandtime, label, props] = egl_WaveRead_Stereo(filename, loaddata)
% ElectroGui file loader
% Reads wavefiles, and loads as a 2D array if stereo data is present
% Extracts date and time information from the file info
arguments
    filename
    loaddata = true
end

if loaddata == 1
    [data, fs] = audioread(filename);
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