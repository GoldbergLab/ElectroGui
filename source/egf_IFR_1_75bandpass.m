function [IFR, label] = egf_IFR_1_75bandpass(a, fs, params)
% ElectroGui function algorithm

defaultParams.Names = {};
defaultParams.Values = {};

label = 'Firing rate (Hz)';
if istext(a) && strcmp(a, 'params')
    IFR = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

Hd_lp = FIR_lp_75;
b = coeffs(Hd_lp);

IFR = zeros(size(a));
f = find(a);
for c = 1:length(f)-1
    IFR(f(c):f(c+1)) = fs/(f(c+1)-f(c));
end

z=size(a);
%subsample by sbs
IFR=IFR(1:10:end);
%bandpass filter--first low pass with FIR then high pass with RC IIR
Hd_lp = b.Numerator;
lpifr=filtfilt(Hd_lp,1,IFR-mean(IFR));
%dmitriy's rc hp filter (IIR)
hp_b = [1 -1]; hp_a = [1 -.9988];
bpifr = filter(hp_b,hp_a,lpifr);
bpifr=[bpifr bpifr(end) bpifr(end)];
t=1/4000:1/4000:length(bpifr)/4000;
t10=1/40000:1/40000:length(bpifr)/4000;
IFR=interp1(t,bpifr,t10,'spline');
IFR=IFR(1:z(2));


