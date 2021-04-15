function [y label] = egf_DetrendSqSmooth(a,fs,params)

label = 'Smoothed data';
if isstr(a) & strcmp(a,'params')
    y.Names = {'Smoothing window (ms)'};
    y.Values = {'1'};
    return
end


num = str2num(params.Values{1});
num = round(num/1000*fs);



smoothms=60;
s=(smoothms/1000)*fs;
N = length(a);
as = smooth(a,0.001*fs);
BP = [1:10000:(N-10000) N];
y_dt = detrend(as, 'linear', BP);
ysmooth = smooth(y_dt.^2, s);
y = sqrt(ysmooth);



