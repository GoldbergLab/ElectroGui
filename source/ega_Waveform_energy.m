function [energyValues, label] = ega_Waveform_energy(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Waveform_energy: RMS energy of each spike's waveform
% usage:  [energyValues, label] = ega_Waveform_energy(channelData, fs,
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
%    energyValues is the root-mean-square of the signal within each spike's
%       window. This captures overall spike "size" in a way that is robust
%       to waveform shape variations. Useful for separating real spikes
%       from low-energy noise transients.
%    label is a string describing this feature for axis labeling
%
% See also: ega_AP_amplitude, ega_Peak_amplitude
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Waveform energy (RMS)';

spikeSamples = eventTimes{eventPartIdx};
numSpikes = length(spikeSamples);
energyValues = zeros(size(spikeSamples));
numChannelSamples = length(channelData);

for spikeIdx = 1:numSpikes
    windowStart = max(1, spikeSamples(spikeIdx) - windowSamples(1));
    windowEnd = min(numChannelSamples, spikeSamples(spikeIdx) + windowSamples(2));
    waveform = channelData(windowStart:windowEnd);

    energyValues(spikeIdx) = sqrt(mean(waveform .^ 2));
end
