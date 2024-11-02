function [snd, label] = egf_FIRBandPass(a, fs, params)
% ElectroGui filter

defaultParams.Names = {'Lower frequency','Higher frequency','Order'};
defaultParams.Values = {'400','9000','80'};

label = 'Band-pass filtered';
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
        freq1_modified = max(freq1, 1);
        freq2_modified = min(freq2, fs/2 - 1);
        warning('Invalid frequency cutoffs for FIRBandPass for sampling rate %d Hz: [%d, %d] Hz. Frequencies must be between 0 and %d Hz. Adjusting frequency cutoffs to [%d, %d] Hz.', fs, freq1, freq2, fs/2, freq1_modified, freq2_modified);
        b = fir1(ord,[freq1_modified freq2_modified]/(fs/2));
    else
        rethrow(ME);
    end
end

% Filter sound
snd = filtfilt(b, 1, a);