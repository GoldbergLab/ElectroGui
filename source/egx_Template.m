function [transformed_data, transformed_fs, labels] = egx_Template(data, fs, transform, params)
% Template for creating ElectroGui transformer functions
%
% Arguments:
%   data = an arbirary data type to be transformed, or the string 'params'
%   fs = sampling rate opf the data in Hz
%   transform = some kind of data defining the transform to be done, such
%       as a PCA coefficients matrix, or trained ML weights.
%   params = optionally, transform parameters in the form of a struct with 
%       the following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   transformed_data = a NxC vector of transformed data, where N is the 
%       number of time points returned, and C is the dimensionality of the
%       output data, or the default transformer parameter struct if 
%       'params' was passed in for the data argument.
%   transformed_fs = the output sampling rate of the transformed data, 
%       which may or may not be different from the input sampling rate.
%   labels = a cell array of zero or more strings to put on the axes of the
%       transformed data plot
% 
% Modify the following code to create a new transformer function.
% To make it available from within electro_gui, save it in the electro_gui
% source code folder with a name beginning with 'egx_' and ending with '.m'

% Define the label for the y-axis of the transformed data plot
labels = {'X-axis label', 'Y-axis label'};

% Define default parameter values here (you can add/change/remove 
%   parameters depending on what your transformer needs)
defaultParams.Names = {'ParameterName1', 'ParameterName2', 'ParameterName3'};
defaultParams.Values = {'400', '9000', '80'};

% If the character array 'params' is passed instead of a data array, simply
%   return the 
if istext(data) && strcmp(data, 'params')
    transformed_data = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

% Extract the parameters provided
val1 = str2double(params.Values{1});
val2 = str2double(params.Values{2});
val3 = str2double(params.Values{3});

%% Transform the data - (currently, this does nothing - change it to transform the data as you see fit)
transformed_data = data;
transformed_fs = fs;