function [snd, lab] = egf_HanningHighPass(a, fs, params)
% ElectroGui filter
% Code from Aaron Andalman

defaultParams.Names = {'Cutoff frequency (Hz)','Order'};
defaultParams.Values = {'750','80'};

lab = 'High-pass filtered';
if istext(a) && strcmp(a, 'params')
    snd = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

cutoff = str2double(params.Values{1});
ord = str2double(params.Values{2});

prstFilt3.order = ord; %80 sufficient for 44100Hz of lower
prstFilt3.win = hann(prstFilt3.order+1);
prstFilt3.cutoff = cutoff; %Hz
prstFilt3.fs = 44100;
prstFilt3.hpf = fir1(prstFilt3.order, prstFilt3.cutoff/(prstFilt3.fs/2), 'high', prstFilt3.win);
snd = filtfilt(prstFilt3.hpf, 1, a);