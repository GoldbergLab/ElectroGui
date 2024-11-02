function [events, labels] = ege_ThresholdCrossings(data, fs, thres, params)
% ElectroGui event detector
% Finds threshold crossings

defaultParams.Names = {};
defaultParams.Values = {};

labels = {'Positive slope','Negative slope'};
if istext(data) && strcmp(data, 'params')
    events = defaultParams;
    return
elseif ~exist('params', 'var')
    % Use default parameters if none are provided
    params = defaultParams;
else
    % Fill any missing params with defaults
    params = electro_gui.applyDefaultPluginParams(params, defaultParams);
end


events{1} = find(data(1:end-1)<thres & data(2:end)>=thres);
events{2} = find(data(1:end-1)>thres & data(2:end)<=thres);