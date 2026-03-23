function [isiValues, label] = ega_Following_ISI(channelData, fs, eventTimes, eventPartIdx, windowSamples)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ega_Following_ISI: Time until the next spike
% usage:  [isiValues, label] = ega_Following_ISI(channelData, fs,
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
%    isiValues is the time in seconds from each spike to the next spike.
%       The last spike gets Inf since there is no following spike.
%       Combined with ega_Preceding_ISI, this is useful for detecting
%       bursts and for identifying refractory period violations that
%       indicate multi-unit contamination.
%    label is a string describing this feature for axis labeling
%
% See also: ega_Preceding_ISI, ega_Preceding_logISI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

label = 'Following ISI (s)';

spikeSamples = eventTimes{eventPartIdx};

if ~isempty(spikeSamples)
    isiValues = [(spikeSamples(2:end) - spikeSamples(1:end-1)) / fs; Inf];
else
    isiValues = [];
end
