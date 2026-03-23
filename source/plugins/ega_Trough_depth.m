function [troughDepths, label] = ega_Trough_depth(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Trough_depth: Minimum value within each spike's waveform window
% usage:  [troughDepths, label] = ega_Trough_depth(channelData, fs,
%                                     eventTimes, eventPartIdx,
%                                     windowSamples)
%
% where,
%    channelData is the full channel signal (1D array)
%    fs is the sampling rate in Hz
%    eventTimes is a cell array of event sample indices, one per event part
%    eventPartIdx is which event part to analyze
%    windowSamples is [preSamples, postSamples] defining the waveform
%       extraction window around each event
%
%    troughDepths is the minimum signal value within each spike's window.
%       For typical extracellular spikes with a negative-going trough, this
%       captures the depth of the trough. Paired with ega_Peak_amplitude,
%       these two features often separate units well on wire bundles.
%    label is a string describing this feature for axis labeling
%
% See also: ega_Peak_amplitude, ega_AP_amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Trough depth';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
troughDepths = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    troughDepths(spikeIdx) = min(waveform);
end
