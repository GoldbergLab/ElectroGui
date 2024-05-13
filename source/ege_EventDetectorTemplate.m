function [events, labels] = ege_EventDetectorTemplate(data, fs, threshold, params)
% Template for creating ElectroGui event detector functions
%
% Arguments:
%   data = a Nx1 vector of channel data to be filtered, or the string
%       'params'
%   fs = sampling rate in Hz
%   threshold = a threshold value for detecting events
%   params = optionally, filter parameters in the form of a struct with the
%       following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   events = a 1xP cell array, where P is the number of "event parts" 
%       (discrete timestamps that together form one "event"), and the
%       contents of each cell are 1xN vectors of event times expressed as
%       sample numbers, where N is the number of detected events. If 
%       'params' was passed in for the data argument, then simply return 
%       the default parameters.
%   labels = 1xP a cell array of strings representing labels for each of 
%       the P event parts
% 
% Modify the following code to create a new event detector function.
% To make it available from within electro_gui, save it in the electro_gui
% source code folder with a name beginning with 'ege_' and ending with '.m'

% Names and values for default parameters (change these to ones necessary
%   for your event detector
defaultParams.Names = {'Param1', 'Peak search window (ms)','Addition Criteria (variables: zenith, nadir, duration(nadir-zenith secs), isiNadir, isiZenith)(ex. zenith < 1)'};
defaultParams.Values = {'77', '[-.5,.5]','abs(duration)>0 & height<Inf'};

% Event part labels (change this to ones relevant to your detector)
labels = {'Zenith','Nadir'};

% Check if the user passed in 'params' instead of data
if ischar(data) && strcmp(data,'params')
    % Return default parameters instead of events
    events = defaultParams;
    return
end

% If no params were provided, use the default ones
if ~exist('params', 'var') || isempty(params)
    params = defaultParams;
end

% Extract/evaluate parameters - they will arrive as strings, and will need
% to be processed into a form useful for your event detector
param1 = str2double(params.Values{1});
param2 = round((eval(params.Values{2})/1000)*fs);
param3 = eval(params.Values{3});

% Change the code below to search for events and return them:
events = {[1, 2, 3], [1, 2, 3]};