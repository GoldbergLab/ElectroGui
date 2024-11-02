function [ispower, timeResolution, spectrogram_handle] = egs_SonogramTemplate(ax, data, fs, params)
% Template for creating ElectroGui filter functions
%
% Arguments:
%   ax = an axes handle to plot the sonogram on
%   data = a Nx1 vector of sound data to be sonogrammed
%   fs = sampling rate in Hz
%   params = optionally, filter parameters in the form of a struct with the
%       following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   isPower = a boolean value indicating whether or not the sonogram 
%       represents a power spectrum
%   timeResolution = the shortest-time feature that can be resolved in the 
%       sonogram
%   spectrogram_handle = a handle to the new sonogram graphics object
% 
% Modify the following code to create a new sonogram function.
% To make it available from within electro_gui, save it in the electro_gui
% source code folder with a name beginning with 'egs_' and ending with '.m'

timeResolution = NaN;
spectrogram_handle = gobjects().empty;

defaultParams.Names = {};
defaultParams.Values = {};

if istext(ax) && strcmp(ax, 'params')
    ispower = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

% ADD YOUR CODE TO CREATE A SPECTROGRAM BELOW
