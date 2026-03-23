function [y, label] = egf_DetrendSqSmooth_vg(a,fs,params)

defaultParams.Names = {'Smoothing window (ms)'};
defaultParams.Values = {'1'};

label = 'Smoothed data';
if istext(a) && strcmp(a, 'params')
    y = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

num = str2double(params.Values{1});
num = round(num/1000*fs);

smoothms=60;
s=(smoothms/1000)*fs;
N = length(a);
as = smooth(a,0.001*fs);
BP = [1:10000:(N-10000) N];
y_dt = detrend(as, 'linear', BP);
ysmooth = smooth(y_dt.^2, s);
y = sqrt(ysmooth);



