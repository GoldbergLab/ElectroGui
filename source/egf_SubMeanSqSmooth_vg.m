function [y, label] = egf_SubMeanSqSmooth_vg(a,fs,params)

defaultParams.Names = {'Smoothing window (ms)'};
defaultParams.Values = {'1'};

label = 'Smoothed data';
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

num = str2double(params.Values{1});
num = round(num/1000*fs);
% y = smooth(a.^2,num);
b = a-mean(a);
y = smooth(b.^2, num);
