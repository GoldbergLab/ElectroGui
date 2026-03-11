function [transformed_data, transformed_fs, labels] = egx_SpectroPCA(data, fs, transform, params)
% Transform data using a spectrogram PCA
%
% Arguments:
%   data = Nx1 audio data
%   fs = sampling rate opf the audio in Hz
%   transform = a structure representing a PCA transform with the fields
%       coeff       (PCA coefficients)
%       mu          (PCA means)
%       flim        (frequency limits used when creating the spectrograms)
%       fs          (sampling rate used when creating the spectrograms)
%       PCA_window  (size in time of spectrogram chunk per PCA observation)
%       PCA_step    (time slide distance of PCA chunk window)
%   params = transform parameters in the form of a struct with 
%       the following fields:
%        - Name => a cell array of parameter names
%        - Values => a cell array of values formatted as strings
%
% Outputs:
%   transformed_data = a NxC vector of transformed data, where N is the 
%       number of time points returned, and C is the dimensionality of the
%       output data, or the default transformer parameter struct if 
%       'params' was passed in for the data argument.
%   labels = a cell array of zero or more strings to put on the axes of the
%       transformed data plot
% 

% Define the label for the y-axis of the transformed data plot
labels = {'PCA axis 1', 'PCA axis 2', 'PCA axis 3'};

% Define default parameter values here (you can add/change/remove 
%   parameters depending on what your transformer needs)
defaultParams.Names = {'NFFT', 'windowSize (must be >= NFFT)', 'Frequency limits (Hz)',  'Number of spectrogram time points', 'Number of dimensions to return'};
defaultParams.Values = {'512', '512',                          '[50, 7500]',             '1000',                              '3'};

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
% NFFT = str2double(params.Values{1});
% spectrogram_window = str2double(params.Values{2});
flim = str2double(params.Values{3});
nT = str2double(params.Values{4});
nDims = str2double(params.Values{5});

% Make sure settings are compatible with loaded transform
if transform.fs ~= fs
    error('Sampling rate must match the sampling rate used in the original transform')
end
if transform.flim ~= flim
    error('flim must match the frequency limits used in the original transform')
end

%% Create the spectrogram
power = getAudioSpectrogram(data, fs, flim, nT);

%% Transform the data - (currently, this does nothing - change it to transform the data as you see fit)

nT = size(power, 2);
% nF = size(power, 1);

vecs = [];

for t = 1:transform.PCA_step:(nT-transform.PCA_window)
    win = power(:, t:(t+transform.PCA_window));
    vecs = vertcat(vecs, win(:)'); %#ok<AGROW>
end

transformed_data = (vecs - transform.mu) * transform.coeff(:, 1:nDims);
transformed_fs = fs * length(data) / (nT * PCA_step);