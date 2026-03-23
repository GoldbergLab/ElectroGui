function [symmetryRatios, label] = ega_Spike_symmetry(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Spike_symmetry: Ratio of pre-trough to post-trough duration
% usage:  [symmetryRatios, label] = ega_Spike_symmetry(channelData, fs,
%                                       eventTimes, eventPartIdx,
%                                       windowSamples)
%
% where,
%    channelData is the full channel signal (1D array)
%    fs is the sampling rate in Hz
%    eventTimes is a cell array of event sample indices, one per event part
%    eventPartIdx is which event part to analyze
%    windowSamples is [preSamples, postSamples] defining the waveform
%       extraction window around each event
%
%    symmetryRatios is the ratio of the time from the pre-trough peak to
%       the trough, divided by the time from the trough to the post-trough
%       peak. A value of 1.0 means the spike is symmetric. Values < 1
%       mean the depolarization phase is faster than repolarization.
%       Different waveform shapes produce different symmetry ratios, making
%       this useful for separating spike classes.
%    label is a string describing this feature for axis labeling
%
% See also: ega_AP_width, ega_Half_width, ega_Repolarization_slope
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Spike symmetry (pre/post ratio)';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
symmetryRatios = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    [~, troughIdx] = min(waveform);
    troughIdx = troughIdx(1);

    % Find peak before the trough (depolarization)
    waveformBeforeTrough = waveform(1:troughIdx);
    if isempty(waveformBeforeTrough)
        preTroughDuration = 0;
    else
        [~, prePeakIdx] = max(waveformBeforeTrough);
        preTroughDuration = troughIdx - prePeakIdx(end);
    end

    % Find peak after the trough (repolarization)
    waveformAfterTrough = waveform(troughIdx:end);
    if length(waveformAfterTrough) < 2
        postTroughDuration = 0;
    else
        [~, postPeakIdx] = max(waveformAfterTrough);
        postTroughDuration = postPeakIdx(1) - 1;  % relative to trough
    end

    % Compute symmetry ratio (pre / post)
    if postTroughDuration > 0
        symmetryRatios(spikeIdx) = preTroughDuration / postTroughDuration;
    else
        symmetryRatios(spikeIdx) = Inf;
    end
end
