function [y, label] = egf_HB_detect_filt(a, fs, params)

defaultParams.Names  = {};
defaultParams.Values = {};

label = 'Median-filter difference';

if istext(a) && strcmp(a, 'params')
    y = defaultParams;
    return
end

% Median filter difference
y = medfilt1(a, 500) - medfilt1(a, 2000);

end
