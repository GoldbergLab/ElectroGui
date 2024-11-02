function [IFR, label] = egf_IFR(a,fs,params)
% ElectroGui function algorithm
% Inverts data

defaultParams.Names = {};
defaultParams.Values = {};

label = 'Firing rate (Hz)';
if istext(a) && strcmp(a, 'params')
    IFR = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

IFR = zeros(size(a));
f = find(a);
for c = 1:length(f)-1
    IFR(f(c):f(c+1)) = fs/(f(c+1)-f(c));
end
