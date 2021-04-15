%% white noise signal
%%%% 1 %%%%%%%
%control the WN signals amplitude by the multiplier which is set as 0.1
%here. Increasing it too much increases the sound amplitude, but beware of
%clipping. MATLAB will show you warning if it clips.
%%%%% 2 %%%%%%
% vary the 1st argument to control the length of the file.

t=0.06;   %% added by AD, 50 ms duration
fs=44100;%sampling frequency in Hz (arduino wav requirement)

x = 0.1*randn(round(fs*t),1);
%% filter params
f_start=1500;%start frequency
f_finish=8000;%end frequency
[y1,d1] = bandpass(x,[f_start f_finish],fs,'ImpulseResponse','iir','Steepness',0.99);%filter the white noise
% notice the parameter steepness=0.95, you may vary it and check the PSD
% what happens
pspectrum(y1,fs)%plot PSD
%% now you're ready
stereovec=[y1,y1];
audiowrite(['test_stereo2.wav'],stereovec,fs,'BitsPerSample',16)%write to wav file
