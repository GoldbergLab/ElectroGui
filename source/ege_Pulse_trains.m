function [events, labels] = ege_Pulse_trains(data, fs, thres, params)
% ElectroGui event detector
% Finds spikes in data

defaultParams.Names = {'Pulse interval threshold (ms)'};
defaultParams.Values = {'3'};

labels = {'On','Off'};
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

pint = str2num(params.Values{1})/1000*fs;

if thres >= 0
    evon = find(data(1:end-1)<thres & data(2:end)>=thres);
    evoff = find(data(1:end-1)>=thres & data(2:end)<thres);
else
    evon = find(data(1:end-1)>thres & data(2:end)<=thres);
    evoff = find(data(1:end-1)<=thres & data(2:end)>thres);
end

ev = union(evon,evoff);
if isempty(ev)
    events{1} = [];
    events{2} = [];
else
    f = diff(ev)>pint;
    f = [1; f; 1];
    events{1} = ev(find(f(1:end-1)==1));
    events{2} = ev(find(f(2:end)==1))+1;
end
