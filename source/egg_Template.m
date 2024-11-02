function [segmentTimes, segmentTitles] = egg_Template(sound, amplitude, fs, threshold, params)
% Template for creating ElectroGui segmenter functions
%
% Arguments:
%   sound = a vector of sound data to be segmented
%   amplitude = a vector of sound amplitudes (provided for speed, so the 
%       amplitude function doesn't have to be run repeatedly
%   fs = sampling rate in Hz
%   threshold = a threshold to use in the segmentation algorithm
%   params = optionally, filter parameters in the form of a struct with the
%       following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   segmentTimes = a Nx2 array of onset and offset times of segments 
%   segmentTitles = a 1xN cell array of segment titles
% 
% Modify the following code to create a new segmenter function.
% To make it available from within electro_gui, save it in the electro_gui
% source code folder with a name beginning with 'egg_' and ending with '.m'

% Define default parameter names and values here
defaultParams.Names = {};
defaultParams.Values = {};

segmentTitles = {};

if istext(sound) && strcmp(sound, 'params')
    segmentTimes = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

% ADD YOUR CODE TO SEGMENT AUDIO BELOW
segmentTimes = [];