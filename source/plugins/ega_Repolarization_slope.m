function [slopes, label] = ega_Repolarization_slope(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Repolarization_slope: Slope from trough back toward baseline
% usage:  [slopes, label] = ega_Repolarization_slope(channelData, fs,
%                               eventTimes, eventPartIdx, windowSamples)
%
% where,
%    channelData is the full channel signal (1D array)
%    fs is the sampling rate in Hz
%    eventTimes is a cell array of event sample indices, one per event part
%    eventPartIdx is which event part to analyze
%    windowSamples is [preSamples, postSamples] defining the waveform
%       extraction window around each event
%
%    slopes is the repolarization slope for each spike, measured as the
%       linear slope (in signal units per ms) from the trough to the
%       subsequent peak within the waveform window. Different cell types
%       have different repolarization dynamics, and noise artifacts tend
%       to have abnormal slopes, making this useful for spike sorting.
%    label is a string describing this feature for axis labeling
%
% See also: ega_AP_width, ega_Half_width
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Repolarization slope (units/ms)';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
slopes = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    [~, troughIdx] = min(waveform);
    troughIdx = troughIdx(1);

    % Find the peak that follows the trough (repolarization target)
    waveformAfterTrough = waveform(troughIdx:end);
    if length(waveformAfterTrough) < 2
        slopes(spikeIdx) = 0;
        continue;
    end

    [peakVal, peakIdx] = max(waveformAfterTrough);
    peakIdx = peakIdx(1);

    % Slope from trough to subsequent peak, in signal units per ms
    troughVal = waveform(troughIdx);
    durationMs = (peakIdx - 1) / fs * 1000;  % peakIdx is relative to trough

    if durationMs > 0
        slopes(spikeIdx) = (peakVal - troughVal) / durationMs;
    else
        slopes(spikeIdx) = 0;
    end
end
