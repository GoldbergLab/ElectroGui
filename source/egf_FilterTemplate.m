function [filteredData, label] = egf_FilterTemplate(data, fs, params)
% Template for creating ElectroGui filter functions
%
% Arguments:
%   data = a Nx1 vector of channel data to be filtered, or the string
%       'params'
%   fs = sampling rate in Hz
%   params = optionally, filter parameters in the form of a struct with the
%       following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   filteredData = a Nx1 vector of filtered channel data, or the default
%       filter parameter struct if 'params' was passed in for the data
%       argument.
%   label = a string to put on the y-axis of the filtered channel data plot
% 
% Modify the following code to create a new filter function.
% To make it available from within electro_gui, save it in the electro_gui
% source code folder with a name beginning with 'egf_' and ending with '.m'

% Define the label for the y-axis of the filtered data plot
label = 'Y-axis label';

% Define default parameter values here (you can add/change/remove 
%   parameters depending on what your filter needs)
defaultParams.Names = {'ParameterName1', 'ParameterName2', 'ParameterName3'};
defaultParams.Values = {'400', '9000', '80'};

% If the character array 'params' is passed instead of a data array, simply
%   return the 
if ischar(data) && strcmp(data, 'params')
    filteredData = defaultParams;
    return
end

% If no parameters provided, use defaults
if ~exist('params', 'var') || isempty(params)
    params = defaultParams;
end

% Extract the parameters provided
val1 = str2double(params.Values{1});
val2 = str2double(params.Values{2});
val3 = str2double(params.Values{3});

%% Filter the data - (currently, this does nothing - change it to filter the data as you see fit)
filteredData = data;