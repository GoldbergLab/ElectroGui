function [y, label] = egf_Rectify(a, fs, params)

defaultParams.Names = {'Power (e.g. 1 for absolute value, 2 for squared value)'};
defaultParams.Values = {'2'};

label = 'Rectified data';
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
y = abs(a).^num;