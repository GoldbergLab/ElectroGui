function [peakAmplitudes, label] = ega_Peak_amplitude(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Peak_amplitude: Signed peak amplitude of each spike waveform
% usage:  [peakAmplitudes, label] = ega_Peak_amplitude(channelData, fs,
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
%    peakAmplitudes is the signed peak value (sample with maximum absolute
%       value) within each spike's waveform window. Positive for upward
%       spikes, negative for downward spikes.
%    label is a string describing this feature for axis labeling
%
% Unlike ega_AP_amplitude which returns unsigned peak-to-trough range,
%   this returns the signed extremum, which helps distinguish upward vs
%   downward threshold crossings and can separate inverted secondary units.
%
% See also: ega_AP_amplitude, ega_Trough_depth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Peak amplitude (signed)';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
peakAmplitudes = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    [maxVal, ~] = max(waveform);
    [minVal, ~] = min(waveform);

    % Return whichever extremum has greater absolute value, with sign
    if abs(maxVal) >= abs(minVal)
        peakAmplitudes(spikeIdx) = maxVal;
    else
        peakAmplitudes(spikeIdx) = minVal;
    end
end
