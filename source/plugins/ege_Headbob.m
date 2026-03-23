function [events, labels] = ege_Headbob(data, fs, ~, params)
% ElectroGui event detector
% Template for creating electro_gui event detector plugins
%   Save this as ege_<<detector name>>.m and edit it to detect events as 
%   you please.
%   
%   Below is some skeleton code that may or may not be useful, feel free to 
%       delete or change it to suit your purposes.

% Define some default parameters
defaultParams.Names = {};
defaultParams.Values = {};

% Define the labels for each event part
labels = {'Onset', 'Offset'};

% Boilerplate code to get default parameters, don't remove or change unless
% you know what you're doing
if ischar(data) && strcmp(data,'params')
    % User passed the string "params"
    % This is a query for default params - return them
    events = defaultParams;
    return
elseif ~exist('params', 'var')
    % Use default parameters if none are provided
    params = defaultParams; %#ok<*NASGU>
else
    % Fill any missing params with defaults
    params = electro_gui.applyDefaultPluginParams(params, defaultParams);
end

% Detect headbobs
hb_struct = make_headbob_struct([], [], [], 'AccelFs', fs, 'Data', data);

% Record onsets
events{1} = [hb_struct.onset]';
% Record offsets
events{2} = [hb_struct.offset]';