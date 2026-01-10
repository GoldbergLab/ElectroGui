function [data, fs, dateandtime, label, props] = egl_RHDLoader(filename, ~)
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

% Get timestamp
dateandtime = 0;
% Define label for data
label = 'Voltage';

[channelType, channelNum, filename] = parseRHDChannelSuffix(filename);
amp = false;
aux = false;
adc = false;
digin = false;
digout = false;
switch channelType
    case 'AMP'
        amp = true;
    case 'AUX'
        aux = true;
    case 'ADC'
        adc = true;
    case 'DI'
        digin = true;
    case 'DO'
        digout = true;
    otherwise
        error('Invalid channel type: %s', channelType)
end

[data, fs] = readRHDChannel(filename, 'Amp', amp, 'Aux', aux, 'ADC', adc, 'DigIn', digin, 'DigOut', digout);

switch channelType
    case 'AMP'
        field = 'amplifier_data';
    case 'AUX'
        field = 'aux_input_data';
    case 'ADC'
        field = 'adc_data';
    case 'DI'
        field = 'board_dig_in_data';
    case 'DO'
        field = 'board_dig_out_data';
    otherwise
        error('Invalid channel type: %s', channelType)
end

if ~isfield(data, field)
    error('Could not find %s data in RHD file: %s (when looking for field %s)', channelType, filename, field);
end
data = data.(field);

% Zero index to one index:
channelNum = channelNum + 1;

data = data(channelNum, :)';

props = [];

function [channelType, channelNum, filename] = parseRHDChannelSuffix(filename)
% Extract special RHD channel suffix. Filename must end like so (number at 
%   the end is the channel number):
% FILENAME.AMP12
% FILENAME.AUX2
% FILENAME.ADC2
% FILENAME.DI2
% FILENAME.DO2

parts = strsplit(filename, '.');
if length(parts) < 2
    error('Invalid RHD channel file specification: %s', filename);
end

suffix = parts{end};

channelNumIdx = regexp(suffix, '([0-9]+)', 'tokenExtents');
if isempty(channelNumIdx)
    error('Invalid RHD channel file specification: %s', filename);
end
channelNumIdx = channelNumIdx{1};

if ~isvector(channelNumIdx)
    error('Invalid RHD channel file specification: %s', filename);
end    

try
    channelNum = suffix(channelNumIdx(1):channelNumIdx(2));
catch
    error('Invalid RHD channel file specification: %s', filename);
end

channelNum = str2double(channelNum);
if isnan(channelNum)
    error('Invalid RHD channel file specification: %s', filename);
end

channelType = suffix(1:channelNumIdx(1)-1);

filename = join(parts(1:end-1), '.');
filename = filename{1};