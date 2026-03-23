function [halfWidths, label] = ega_Half_width(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Half_width: Width at half-maximum amplitude for each spike
% usage:  [halfWidths, label] = ega_Half_width(channelData, fs,
%                                   eventTimes, eventPartIdx,
%                                   windowSamples)
%
% where,
%    channelData is the full channel signal (1D array)
%    fs is the sampling rate in Hz
%    eventTimes is a cell array of event sample indices, one per event part
%    eventPartIdx is which event part to analyze
%    windowSamples is [preSamples, postSamples] defining the waveform
%       extraction window around each event
%
%    halfWidths is the duration (in ms) of each spike at half its
%       peak-to-trough amplitude. This is measured as the time between the
%       first and last crossings of the half-amplitude level on the
%       dominant deflection (whichever of peak or trough has greater
%       absolute value). More robust than peak-to-trough time because it
%       is less sensitive to noise at the extrema.
%    label is a string describing this feature for axis labeling
%
% See also: ega_AP_width, ega_AP_amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Half-width (ms)';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
halfWidths = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    [maxVal, maxIdx] = max(waveform);
    [minVal, minIdx] = min(waveform);

    % Determine the dominant deflection direction
    if abs(maxVal) >= abs(minVal)
        % Positive-going spike: measure width of peak
        peakIdx = maxIdx(1);
        baseline = minVal;
        peakVal = maxVal;
    else
        % Negative-going spike: measure width of trough
        peakIdx = minIdx(1);
        baseline = maxVal;
        peakVal = minVal;
    end

    halfLevel = (baseline + peakVal) / 2;

    % Find crossings of the half-amplitude level
    if peakVal > baseline
        aboveHalf = waveform >= halfLevel;
    else
        aboveHalf = waveform <= halfLevel;
    end

    % Find the first and last samples that cross the half-amplitude level
    crossingSamples = find(aboveHalf);
    if length(crossingSamples) >= 2
        halfWidths(spikeIdx) = (crossingSamples(end) - crossingSamples(1)) / fs * 1000;
    else
        halfWidths(spikeIdx) = 0;
    end
end
