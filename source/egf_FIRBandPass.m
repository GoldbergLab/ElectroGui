function [snd, label] = egf_FIRBandPass(a, fs, params)
% ElectroGui filter

label = 'Band-pass filtered';
defaultParams.Names = {'Lower frequency','Higher frequency','Order'};
defaultParams.Values = {'400','9000','80'};

if ischar(a) && strcmp(a, 'params')
    snd = defaultParams;
    return
end

if ~exist('params', 'var') || isempty(params)
    params = defaultParams;
end

freq1 = str2double(params.Values{1});
freq2 = str2double(params.Values{2});
ord = str2double(params.Values{3});

b = fir1(ord,[freq1 freq2]/(fs/2));
snd = filtfilt(b, 1, a);