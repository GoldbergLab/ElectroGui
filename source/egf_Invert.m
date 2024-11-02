function [inv, label] = egf_Invert(a, fs, params)
% ElectroGui function algorithm
% Inverts data

defaultParams.Names = {};
defaultParams.Values = {};

label = 'Inverted data';
if istext(a) && strcmp(a, 'params')
    inv = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

inv = -a;