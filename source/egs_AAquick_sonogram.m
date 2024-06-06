function [ispower, timeResolution, spectrogram_handle] = egs_AAquick_sonogram(ax,wv,fs,params)
% ElectroGui spectrum algorithm
% Aaron Andalman's algorithm that accounts for screen resolution

defaultParams.Names = {'NFFT', 'windowSize (must be >= NFFT)'};
defaultParams.Values = {'512', '512'};

if ischar(ax) && strcmp(ax, 'params')
    ispower = defaultParams;
    return
end

if ~exist('params', 'var') || isempty(params)
    params = defaultParams;
end

originalAxesUnits = ax.Units;

NFFT = str2double(params.Values{1});
nCourse = 1;
windowSize = str2double(params.Values{2});
freqRange = get(ax,'ylim');

%determine size of axis relative to size of the signal,
%use this to adapt the window overlap and downsampling of the signal.
%no need to worry about size of fftwindow, this doesn't effect speed.
ax.Units = 'pixels';
pixSize = ax.Position;
numPixels = pixSize(3) / nCourse;
numWindows = length(wv) / windowSize;
if(numWindows < numPixels)
    %If we have more pixels than ffts, then increase the overlap
    %of fft windows accordingly.
    ratio = ceil(numPixels/numWindows);
    windowOverlap = min(.999, 1 - (1/ratio));
    windowOverlap = floor(windowOverlap*windowSize);
else
    %If we have more ffts then pixels, then we can do things, we can
    %downsample the signal, or we can skip signal between ffts.
    %Skipping signal mean we may miss bits of song altogether.
    %Decimating throws away high frequency information.
    ratio = floor(numWindows/numPixels);
    %windowOverlap = -1*ratio;
    %windowOverlap = floor(windowOverlap*windowSize);
    windowOverlap = 0;
    wv = decimate(wv, ratio);
    fs = fs / ratio;
end


% Temporal resolution of the spectrogram, in seconds
timeResolution = (windowSize - windowOverlap) / fs;

%Compute the spectrogram
%[S,F,T,P] = spectrogram(sss,windowSize,windowOverlap,NFFT,Fs);
[S,F,t] = specgram(wv, NFFT, fs, windowSize, windowOverlap);

ndx = find((F>=freqRange(1)) & (F<=freqRange(2)));

%The spectrogram
p = 2*log(abs(S(ndx,:))+eps)+20;
f = linspace(freqRange(1),freqRange(2),size(p,1));

set(ax,'units',originalAxesUnits);

xl = xlim(ax);
spectrogram_handle = imagesc(ax, linspace(xl(1),xl(2),size(p,2)),f,p);

ispower = 1;