function [snd, lab] = egf_Unfiltered(a, fs, params)
% ElectroGui filter
% Does not filter sound

defaultParams.Names = {};
defaultParams.Values = {};

lab = 'Unfiltered';
if istext(a) && strcmp(a, 'params')
    snd = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

snd = a;