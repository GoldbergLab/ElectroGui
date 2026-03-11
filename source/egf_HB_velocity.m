function [y, label] = egf_HB_velocity(a, fs, params)

defaultParams.Names  = {};
defaultParams.Values = {};

label = 'Median-filter difference';

if istext(a) && strcmp(a, 'params')
    y = defaultParams;
    return
end

% Median filter difference
b = fir1(480,[1 20]/(fs/2));
%convert approximately to m/s^2 using 340 mV / 9.8 m/s^2
acc_signal = (a*980)/34;
tmov= linspace(0,length(acc_signal)/fs,length(acc_signal));
vel = filtfilt(b,1,acc_signal);
vel = vel-mean(vel);
vel = cumtrapz(tmov,vel);
y = vel-medfilt1(vel,afs*0.5);
end
