function [data, fs, dateandtime, label, props] = egl_Template(filename, ~)
% Brian Kardon
% ElectroGui file loader template
% This is a template to help you create your own electro_gui loader.
% Save this file as egl_<<loader name>>.m and edit the code to load in
%   files
% Inputs should be:
%   filename - the path to the file to be loaded
% It should output
%   data - a timeseries of data loaded from the file
%   fs - the sampling rate in Hz
%   dateandtime - a timestamp for the file
%   label - what the y-axis label should be when plotting this data
%   props - deprecated - don't use this output

% Load data
data = loadFunctionGoesHere(filename);
% Get sampling rate
fs = somehowGetSamplingRate();
% Get timestamp
dateandtime = getTimeStampSomehow();
% Define label for data
label = 'Voltage';
