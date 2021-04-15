%% This is to cut out a broadband (bb) part of the song to use for feedback

clear
loaddata = 1;
fdbk_dur = 1.3;

%PARAMETERS TO UPDATE

%Bird ID
BirdID = '3120';
%path of the audio file that acquisitiongui recorded
path_bb = 'D:\STN\INTAN\3351\bouts\';

%filename of the audio file from which you want to extract the broadband
%part of the song
filename_bb = '3120_d0000104_20180924T101420_chan0.txt';

%The start time of the broadband part in the file (can use electro_gui to find the exact time)
bb_start = 3.9;
bb_end = bb_start+fdbk_dur;

%Path to save broadband snippet file 
path_save = 'D:\STN\INTAN\3351\';

% CODE

%Extract the audio data from the acquisitiongui file 
file_bb = [path_bb filename_bb];
[data_bb fs dateandtime label props] = egl_AA_daq(file_bb, loaddata);

%Crop the data to get the broadband snippet
bb_snippet = data_bb(fs*bb_start:fs*bb_end);

%Name of the saved snippet file
savename_bb_snippet = [path_save BirdID '_BOS_bb_snippet'];

%Save the broadband snippet file
save(savename_bb_snippet, 'bb_snippet', '-ascii', '-double', '-tabs')

%% This is to make the distorted (with both DAF and BB) and undistorted BOS motifs and snippets for playback, RC
%% modified to read wav files, AD, 2018

clear
loaddata = 1;
motif_dur = 1.2;
fs=40000;

%PARAMETERS TO UPDATE

%Bird ID
BirdID = '3133';

%The path for the matlab file with the undistorted motif
path_esc = 'D:\STN\INTAN\3133\';

%The filename of the mat file with the undistorted motif
filename_esc = '3133_43402.42245174_10_29_11_44_05.wav';

%The start time for the undistorted motif in the file (make it 2 sec long)
starttime_esc =7.1;
endtime_esc = starttime_esc+motif_dur;

%Path to save motif and snippet files
path_save = 'D:\STN\INTAN\3133\';

% CODE

%Extract the audio data from the file for the undistorted motif
file_esc = [path_esc filename_esc];
%[data_esc fs dateandtime label props] = egl_AA_daq(file_esc, loaddata);

%Extract the audio data from the electrogui file 
[data_esc fs dateandtime label props] = egl_WaveRead(file_esc, loaddata);

%data=load(file_esc);
%data_esc=data.rec(1).Data;

%Extract the undistorted motif 
datacrop_esc = data_esc(fs*starttime_esc:fs*endtime_esc);

%Names of the saved motif and snippet files
savename_BOS_dis_motif = [path_save BirdID '_BOS_undis_motif'];

%Save the motif and snippet files
save(savename_BOS_dis_motif, 'datacrop_esc', '-ascii', '-double', '-tabs');

