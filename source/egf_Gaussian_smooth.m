function [y, label] = egf_Gaussian_smooth(a, fs, params)

defaultParams.Names = {'Gaussian half-width sigma (ms)','Kernel half-length in stdev'};
defaultParams.Values = {'5','3'};

label = 'Gaussian-smoothed data';
if istext(a) && strcmp(a, 'params')
    y = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

sig = str2double(params.Values{1})/1000;
num = str2double(params.Values{2});

t = -round(sig*num*fs):round(sig*num*fs);
t = t/fs;
k = exp(-t.^2/sig.^2)';

[y, c] = xcorr(a,k);
y = y(c>=-round(sig*num*fs) & c<length(a)-round(sig*num*fs));
