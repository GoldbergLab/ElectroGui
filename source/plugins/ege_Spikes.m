function [events, labels] = ege_Spikes(data, fs, thres, params)
% ElectroGui event detector
% Finds spikes in data

defaultParams.Names = {'Refractory period (ms)'};
defaultParams.Values = {'1'};

labels = {'Spikes'};
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

rp = str2num(params.Values{1})/1000;

if thres >= 0
    events{1} = find(data(1:end-1)<thres & data(2:end)>=thres);
else
    events{1} = find(data(1:end-1)>thres & data(2:end)<=thres);
end

f = find(events{1}(2:end)-events{1}(1:end-1)<rp*fs);
events{1}(f+1) = [];