function [out] = running_estimation(data,fs) 

window_size = fix(0.010*fs);
window_move = fix(0.004*fs);
peaks = [30 25];
for i=1:(length(data)-window_size)/(window_move)
range = (1+(i-1)*window_move):(window_size+(i-1)*window_move);
data_window = data(range);
data_fft = abs(fft(data_window));
p_correct = sum([data_fft(10:10:220);data_fft(9:10:219);data_fft(11:10:221)]);
p_wrong = sum([data_fft(5:10:215);data_fft(4:10:214);data_fft(6:10:216)]);
p_total = sum(data_fft);
out(i) = (p_correct-p_wrong)/p_total;
%ratio(i) = sum(data_fft(29:31))-sum(data_fft(24:26));
end
plot(1:length(out),out,'.-');
end