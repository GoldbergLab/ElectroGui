function [events, labels] = ege_Template(data, fs, thres, params)
% ElectroGui event detector
% Template for creating electro_gui event detector plugins
%   Save this as ege_<<detector name>>.m and edit it to detect events as 
%   you please.
%   
%   Below is some skeleton code that may or may not be useful, feel free to 
%       delete or change it to suit your purposes.

% Define some default parameters
defaultParams.Names = {'Param1', 'Param2', 'Param3'};
defaultParams.Values = {'[-.5,.5]','wheeee', '1112.7'};

% Define the labels for each event part
labels = {'EventPart1','EventPart2'};

% Boilerplate code to get default parameters, don't remove or change unless
% you know what you're doing
if ischar(data) && strcmp(data,'params')
    % User passed the string "params"
    % This is a query for default params - return them
    events = defaultParams;
    return
elseif ~exist('params', 'var')
    % Use default parameters if none are provided
    params = defaultParams;
else
    % Fill any missing params with defaults
    params = electro_gui.applyDefaultPluginParams(params, defaultParams);
end

% Delete this and actually detect events here:
% Array of times for first event part
events{1} = [22, 77, 100];
% Array of times for second event part
events{2} = [23, 78, 101];
% And so on, if you want more event parts
