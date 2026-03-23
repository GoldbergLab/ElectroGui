function [ispower, timeResolution, spectrogram_handle] = egs_CJquick_sonogram(ax, wv, fs, params)
% ElectroGui spectrum algorithm

timeResolution = 0;
spectrogram_handle = [];

defaultParams.Names = {};
defaultParams.Values = {};

if istext(ax) && strcmp(ax, 'params')
    ispower = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

freqwinSize = 512; % NFFT - controls frequency resolution
timewindowSize = 256; % window size of time in samples
overlapPercent = 75; % Overlap percentage for sliding window
windowOverlap = overlapPercent/100;
windowOverlap = floor(windowOverlap*timewindowSize);

bck = get(ax,'units');
freqRange = get(ax,'ylim');
% The spectrogram

[S,F,t] = specgram(wv, freqwinSize, fs, timewindowSize,windowOverlap);
% Old code inherited from AAquick_sonogram
ndx = find((F>=freqRange(1)) & (F<=freqRange(2)));
p = 2*log(abs(S(ndx,:))+eps)+20;
f = linspace(freqRange(1),freqRange(2),size(p,1));

set(ax,'units',bck);

xl = xlim(ax);
spectrogram_handle = imagesc(ax, linspace(xl(1),xl(2),size(p,2)),f,p);

ispower = 1;