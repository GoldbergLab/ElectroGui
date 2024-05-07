function [snd, label] = egf_FIRBandPass(a, fs, params)
% ElectroGui filter

label = 'Band-pass filtered';
defaultParams.Names = {'Lower frequency','Higher frequency','Order'};
defaultParams.Values = {'400','9000','80'};

if ischar(a) && strcmp(a, 'params')
    snd = defaultParams;
    return
end

% If no parameters provided, use defaults
if ~exist('params', 'var') || isempty(params)
    params = defaultParams;
end

freq1 = str2double(params.Values{1});
freq2 = str2double(params.Values{2});
ord = str2double(params.Values{3});

% Make sure parameters were numbers
if isnan(freq1)
    error('Invalid frequency cutoff value: %s (must be a number)', params.Values{1});
end
if isnan(freq2)
    error('Invalid frequency cutoff value: %s (must be a number)', params.Values{2});
end
if isnan(ord)
    error('Invalid frequency cutoff value: %s (must be a number)', params.Values{3});
end

try
    % Attempt to generate filter coefficients
    b = fir1(ord,[freq1 freq2]/(fs/2));
catch ME
    % Frequency cutoffs out of range
    if strcmp(ME.identifier, 'signal:fir1:FreqsOutOfRange')
        error('Invalid frequency cutoffs for FIRBandPass for sampling rate %f: [%f, %f]. Frequencies must be between 0 and %f', fs, freq1, freq2, fs/2);
    else
    end
end

% Filter sound
snd = filtfilt(b, 1, a);