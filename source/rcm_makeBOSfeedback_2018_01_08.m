%% This is to cut out a broadband (bb) part of the song to use for feedback

clear
loaddata = 1;
fdbk_dur = 0.050;

%PARAMETERS TO UPDATE

%Bird ID
BirdID = '2925';
%path of the audio file that acquisitiongui recorded
path_bb = 'G:\data\Ruidong\2925\2018-02-01\';

%filename of the audio file from which you want to extract the broadband
%part of the song
filename_bb = '2925_d000005_20180201T145312chan0.dat';

%The start time of the broadband part in the file (can use electro_gui to find the exact time)
bb_start = 6.17;
bb_end = bb_start+fdbk_dur;

%Path to save broadband snippet file 
path_save = 'G:\data\Ruidong\2925\';

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

%% This is to make the distorted (with both DAF and BB) and undistorted BOS motifs and snippets for playback

clear
loaddata = 1;
fdbk_dur = 0.050;
motif_dur = 2.0;

%PARAMETERS TO UPDATE

%Bird ID
BirdID = '2925';

%The path for the acquisitiongui audio file with the undistorted motif
path_esc = 'G:\data\Ruidong\2925\2018-02-01\';

%The filename of the audio file with the undistorted motif
filename_esc = '2925_d000005_20180201T145312chan0.dat';

%The start time for the undistorted motif in the file (make it 2 sec long)
starttime_esc =5.8;
endtime_esc = starttime_esc+motif_dur;

%The target time in the undistorted motif
trgt_start = 6.4;
trgt_end = trgt_start+fdbk_dur;

%The path for the acquisitiongui audio file with the distorted (BB) motif
path_hit_bb = 'G:\data\Ruidong\2925\2018-02-01\';

%The filename of the audio file with the distorted (BB) motif
filename_hit_bb = '2925_d000011_20180201T160230chan0.dat';

%The start time of the feedback in the distorted (BB) motif file
fdbk_bb_start = 5.895;
fdbk_bb_end = fdbk_bb_start+fdbk_dur;

%The path for the acquisitiongui audio file with the distorted (DAF) motif
path_hit_daf = 'G:\data\Ruidong\2911\2018-01-08\';

%The filename of the audio file with the distorted (DAF) motif
filename_hit_daf = '2911_d000058_20180108T142449chan0.dat';

%The start time of the feedback in the distorted (DAF) motif file
fdbk_daf_start = 5.2;
fdbk_daf_end = fdbk_daf_start+fdbk_dur;

%Path to save motif and snippet files
path_save = 'G:\data\Ruidong\2911\';

% CODE

%Extract the audio data from the file for the undistorted motif
file_esc = [path_esc filename_esc];
[data_esc fs dateandtime label props] = egl_AA_daq(file_esc, loaddata);

%Extract the audio data from the file for the distorted (BB) motif
file_hit_bb = [path_hit_bb filename_hit_bb];
[data_hit_bb fs dateandtime label props] = egl_AA_daq(file_hit_bb, loaddata);

%Extract the audio data from the file for the distorted (DAF) motif
file_hit_daf = [path_hit_daf filename_hit_daf];
[data_hit_daf fs dateandtime label props] = egl_AA_daq(file_hit_daf, loaddata);

%Extract the undistorted motif 
datacrop_esc = data_esc(fs*starttime_esc:fs*endtime_esc);

%Extract the feedback snippet from the distorted (BB) motif
fdbk_bb_snippet = data_hit_bb(fs*fdbk_bb_start:fs*fdbk_bb_end);

%Extract the feedback snippet from the distorted (DAF) motif
fdbk_daf_snippet = data_hit_daf(fs*fdbk_daf_start:fs*fdbk_daf_end);

%Replace the target portion of the undistorted motif with the feedback
%snippet obtained from the distorted (BB) motif
data_dis_bb = data_esc;
data_dis_bb(fs*trgt_start:fs*trgt_end) = fdbk_bb_snippet;

%Extract the distorted (BB) motif
datacrop_dis_bb = data_dis_bb(fs*starttime_esc:fs*endtime_esc);

%Replace the target portion of the undistorted motif with the feedback
%snippet obtained from the distorted (DAF) motif
data_dis_daf = data_esc;
data_dis_daf(fs*trgt_start:fs*trgt_end) = fdbk_daf_snippet;

%Extract the distorted (DAF) motif
datacrop_dis_daf = data_dis_daf(fs*starttime_esc:fs*endtime_esc);

%Extract the target snippet from the undistorted motif 
esc_snippet = data_esc(fs*trgt_start:fs*trgt_end);

%Names of the saved motif and snippet files
savename_BOS_undis_motif = [path_save BirdID '_BOS_undis_motif'];
savename_BOS_dis_bb_motif = [path_save BirdID '_BOS_dis_bb_motif'];
savename_BOS_dis_daf_motif = [path_save BirdID '_BOS_dis_daf_motif'];
savename_BOS_undis_snippet = [path_save BirdID '_BOS_undis_snippet'];
savename_BOS_dis_bb_snippet = [path_save BirdID '_BOS_dis_bb_snippet'];
savename_BOS_dis_daf_snippet = [path_save BirdID '_BOS_dis_daf_snippet'];

%Save the motif and snippet files
save(savename_BOS_undis_motif, 'datacrop_esc', '-ascii', '-double', '-tabs');
save(savename_BOS_dis_bb_motif, 'datacrop_dis_bb', '-ascii', '-double', '-tabs');
save(savename_BOS_dis_daf_motif, 'datacrop_dis_daf', '-ascii', '-double', '-tabs');
save(savename_BOS_undis_snippet, 'esc_snippet', '-ascii', '-double', '-tabs');
save(savename_BOS_dis_bb_snippet, 'fdbk_bb_snippet', '-ascii', '-double', '-tabs');
save(savename_BOS_dis_daf_snippet, 'fdbk_daf_snippet', '-ascii', '-double', '-tabs');
