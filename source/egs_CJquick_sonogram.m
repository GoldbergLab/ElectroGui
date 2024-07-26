function ispower = egs_CJquick_sonogram(ax,wv,fs,params)
% ElectroGui spectrum algorithm

freqwinSize = 512; % NFFT - controls frequency resolution
timewindowSize = 256; % window size of time in samples
overlapPercent = 75; % Overlap percentage for sliding window
windowOverlap = overlapPercent/100;
windowOverlap = floor(windowOverlap*timewindowSize);

if isstr(ax) & strcmp(ax,'params')
    ispower.Names = {};
    ispower.Values = {};
    return
end
bck = get(ax,'units');
freqRange = get(ax,'ylim');
% The spectrogram

[S,F,t] = specgram(wv, freqwinSize, fs, timewindowSize,windowOverlap);
% Old code inherited from AAquick_sonogram
ndx = find((F>=freqRange(1)) & (F<=freqRange(2)));
p = 2*log(abs(S(ndx,:))+eps)+20;
f = linspace(freqRange(1),freqRange(2),size(p,1));

set(ax,'units',bck);

xl = xlim;
imagesc(linspace(xl(1),xl(2),size(p,2)),f,p);

ispower = 1;