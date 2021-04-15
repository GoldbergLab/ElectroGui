function [events labels] = ege_ThresholdCrossings(data,fs,thres,params)
% ElectroGui event detector
% Finds threshold crossings

labels = {'Positive slope'};
if isstr(data) & strcmp(data,'params')
    events.Names = {};
    events.Values = {};
    return
end

events{1} = find(data(1:end-1)<thres & data(2:end)>=thres);