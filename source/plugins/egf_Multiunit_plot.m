function [y, label] = egf_Multiunit_plot(a, fs, params)

defaultParams.Names = {'Rectification exponent (e.g. 2 for squared signal)','Gaussian half-width sigma (ms)','Kernel half-length in stdev'};
defaultParams.Values = {'2','5','3'};

label = 'Gaussian-smoothed data';
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

rec = str2double(params.Values{1});
sig = str2double(params.Values{2})/1000;
num = str2double(params.Values{3});

a = abs(a.^rec);

t = -round(sig*num*fs):round(sig*num*fs);
t = t/fs;
k = exp(-t.^2/sig.^2)';

num_edges = ceil(length(a)/0.5e6)+1;
edges = round(linspace(0,length(a),num_edges));
y = [];

for j = 1:length(edges)-1
    [y_part, c] = xcorr(a(edges(j)+1:edges(j+1)),k);
    y_part = y_part(c>=-round(sig*num*fs) & c<edges(j+1)-edges(j)-round(sig*num*fs));
    y = [y; y_part];
end