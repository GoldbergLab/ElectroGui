function [segs, segNames] = egg_DA_segmenter_old(sound, amplitude, fs, threshold, params)
% ElectroGui segmenter

defaultParams.Names = {'Minimum duration (ms)','Minimum interval (ms)','Buffer (ms)'};
defaultParams.Values = {'7', '7','0'};

% This algorithm does not generate segment names
segNames = {};

if istext(sound) && strcmp(sound, 'params')
    segs = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

min_stop = str2double(params.Values{1})/1000;
min_dur = str2double(params.Values{2})/1000;
buff = str2double(params.Values{3})/1000;

% Find threshold crossing points
f = [];
amplitude = [0; amplitude; 0];
f(:,1) = find(amplitude(1:end-1)<threshold & amplitude(2:end)>=threshold)-1;
f(:,2) = find(amplitude(1:end-1)>=threshold & amplitude(2:end)<threshold)-1;
amplitude = amplitude(2:end-1);

% Eliminate VERY short syllables
i = f(:,2)-f(:,1)>min_dur/2*fs;
f = f(i,:);

% Add buffer
f(:,1) = f(:,1) - buff*fs;
f(f(:,1)<1) = 1;
f(:,2) = f(:,2) + buff*fs;
f(f(:,2)>length(amplitude)) = length(amplitude);

% Eliminate short syllables
i = f(:,2)-f(:,1)>min_dur*fs;
f = f(i,:);

if isempty(f)
    segs = zeros(0,2);
    return
end

% Eliminate short intervals
if size(f,1)>1
    i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
    f = [f([1; i(1:end-1)+1],1) f(i,2)];
end


segs = round(f);