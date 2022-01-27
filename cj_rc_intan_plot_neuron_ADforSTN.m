function hf = cj_rc_intan_plot_neuron_ADforSTN(dbase,ichan,ifile_event,eventonset,eventoffset,rasterduration)
% AD: for my purposes, evenonset is the start of the motif/target/movement onset that corresponds to the raster I am plotting, eventoffset is the time before event onset 
%that I am plotting, rasterduration is the time from event onset of raster that I am plotting
%ifile_event is the file number within dbase that has the example event of interest.
%% run in matlab newer than 2013b

% fig1 = rc_make_longplot(dbase,ifile_bout,ichan,boutoffset,boutduration);

% fig2 = plot_single_call_warble(dbase,ichan,ifile_call,calloffset,1,ifile_warble,warbleoffset);
% 
% fig3 = plot_single(dbase,ichan,ifile_call,calloffset,1,ifile_move,moveoffset);

%%
hf = figure;
set(hf, 'units', 'inches', 'Position', [1 1 8 6])
set(hf,'color','w')
climit = [16.5,26.5];
%dbase=rcm_dbaseGetIndicesIntan(dbase); %AD, may NOT need to run this again as my dbases are already analyzed?

%% first, long plot on top
% fig1 = rc_make_longplot(dbase,ifile_bout,ichan,boutoffset,boutduration);

fs_hs = dbase.Fs;
fs_accl = 5000;
nsamples = 0;
boutduration = eventoffset+rasterduration; %rasterduration*2; %AD
nsamples_accl = floor(boutduration * fs_accl);
nsamples_spikes = nsamples_accl*4;
path_name = dbase.PathName;

if strcmp(path_name(1),'F')
    path_name(1)='D';
end

cfiles = dbase.ChannelFiles;
afiles = dbase.SoundFiles;
[data_spike, ~] = egl_Intan_Nc([path_name '\' cfiles{ichan}(ifile_event).name],1); %Changing intan file reader from txt reader to nc reader CBJ 12/8/2021
%data_accl = rc_intan_loadaccl(dbase,ifile_event,path_name); % this function by RC will get the combined acc trace 
[data_audio, ~] = egl_Intan_Nc([path_name '\' afiles(ifile_event).name],1);


boutoffset = eventonset-eventoffset; %AD
isample_start = boutoffset*fs_hs+1;
isample_startz = boutoffset*fs_accl+1;
data_audio = data_audio(isample_start:isample_start+nsamples_spikes-1);
data_spike_aligned = data_spike(isample_start:isample_start+nsamples_spikes-1);
%data_accl_aligned = data_accl(isample_startz:isample_startz+nsamples_accl-1);
[FunctionParams, ~] = egf_FIRBandPass('params'); %************************** FIRBandPass doesnt do anything
FunctionParams.Value(1)=600;
FunctionParams.Value(2)=8000;
[data_spike_aligned, ~] = egf_FIRBandPass(data_spike_aligned,fs_hs,FunctionParams); %************************** FIRBandPass doesnt do anything

% plot spectrogram, 0.85-0.97
subplot('Position', [0.13 0.88 0.7750 0.1])
ax = gca;
params = egs_AAquick_sonogram('params');
xlim([0,boutduration]);
ylim([500,6000]);
egs_AAquick_sonogram(ax,data_audio,20000,params);
colormap('jet')
Colormap = colormap;
Colormap(1,:) = 0;
colormap(Colormap);
set(gca,'clim',climit)
set(gca,'ydir','normal')
% xt = get(gca,'ytick');
% set(gca,'yticklabel',xt/1000);
% ylabel('Frequency (kHz)');
set(gca,'xtick',[])
set(gca,'ytick',[])

% % plot accl from bird one
% moveOnsets = dbase.moveonsets{ifile_event}-dbase.filestarttimes(ifile_event);
% subplot('Position', [0.13 0.82 0.7750 0.05])
% edges = 1:nsamples_accl;
% plot(edges,data_accl_aligned, 'k', 'LineWidth', 1); hold on;
% ylimit = ylim;
% for i_move = 1:length(moveOnsets)
%     x = moveOnsets(i_move);
%     x = (x-boutoffset)*fs_accl;
%     line([x,x],[ylimit(1),ylimit(2)],'Color','g','LineWidth', 1);
% end
% xlim([1,nsamples_accl])
% % ylim([-3e-4,2e-4]);
% set(gca, 'YTick', [])
% set(gca, 'XTick', [])
% axis off

% plot spikes from bird one
% subplot('Position', [0.13 0.76 0.7750 0.05]) %use this when plotting
% accelerometer
subplot('Position', [0.13 0.82 0.7750 0.05])  %use this when not plotting accelerometer
edges = 1:nsamples_spikes;
plot(edges,data_spike_aligned, 'k', 'LineWidth', 1)
xlim([1,nsamples_spikes])
ylim([-3e-4,1.5e-4]);
set(gca, 'YTick', [])
set(gca, 'XTick', [])
axis off

% % plot IFR
% subplot('Position', [0.13 0.7 0.7750 0.05])
% 
% t_spikes = dbase.EventTimes{ichan}{1,ifile_event};
% selected = dbase.EventIsSelected{ichan}{2,ifile_event};
% t_spikes = t_spikes(selected==1);
% if isempty(t_spikes)
%     t_spikes = 1;
% end
% a = zeros(t_spikes(end),1);
% a(t_spikes)=1;
% params = 0;
% [IFR label] = egf_IFR(a,fs_hs,params);
% edges =linspace(0,t_spikes(end)/fs_hs,t_spikes(end));
% plot(edges,IFR,'k', 'LineWidth', 2);hold on;
% xlim([boutoffset,boutoffset+boutduration])
% ylimit = ylim;
% ylim([0,min(ylimit(2),1200)]);
% set(gca,'ytick',[0,1200])
% set(gca,'xtick',[boutoffset,boutoffset+boutduration])
% xticklabels({'0','5'});
% box off;
% ylabel('IFR(Hz)');


% %% now second plot
% % fig2 = plot_single_call_warble(dbase,ichan,ifile_call,calloffset,1,ifile_warble,warbleoffset);
% duration = 1;
% % function hf = plot_single_call_warble(dbase,ichan,ifile_call,calloffset,1,ifile_warble,warbleoffset)
% 
% %#ok<*AGROW>
% fs_hs = dbase.Fs;
% fs_accl = 5000;
% data_spike_combined = [];
% data_audio_combined = [];
% data_accl_combined = [];
% 
% cfiles = dbase.ChannelFiles;
% afiles = dbase.SoundFiles;
% path_name = dbase.PathName;
% if strcmp(path_name(1),'Y')
%     path_name(1)='B';
% end
% 
% nsamples = 0;
% nsamples_accl = floor(duration * fs_accl);
% nsamples_spikes = nsamples_accl*4;
% ifile = ifile_call;
% while nsamples < nsamples_spikes
%     [data_spike, ~] = egl_HC_ad([path_name '\' cfiles{ichan}(ifile).name],1);
%     [data_audio, ~] = egl_HC_ad([path_name '\' afiles(ifile).name],1);
% %     data_accl = rc_intan_loadaccl(dbase,ifile);
%     
%     data_spike_combined = [data_spike_combined data_spike]; 
%     data_audio_combined = [data_audio_combined data_audio];
% %     data_accl_combined = [data_accl_combined data_accl];
%     
%     if nsamples == 0
%         nsamples = length(data_audio_combined) - calloffset*fs_hs;
%     else
%         nsamples = nsamples + length(data_audio_combined);
%     end
%     ifile = ifile + 1;
% end
% ifile = ifile_call;
% 
% [data_spike_warble, ~] = egl_HC_ad([path_name '\' cfiles{ichan}(ifile_warble).name],1);
% [data_audio_warble, ~] = egl_HC_ad([path_name '\' afiles(ifile_warble).name],1);
% 
% isample_start = calloffset*fs_hs+1;
% isample_startz = warbleoffset*fs_hs+1;
% isample_start_spikemove = warbleoffset*fs_hs+1;
% 
% data_spike_aligned = data_spike_combined(isample_start:isample_start+nsamples_spikes-1);
% data_spike_warble_aligned = data_spike_warble(isample_start_spikemove:isample_start_spikemove+nsamples_spikes-1);
% [FunctionParams, ~] = egf_FIRBandPass('params');
% FunctionParams.Value(1)=900;
% FunctionParams.Value(2)=8000;
% [data_spike_aligned, ~] = egf_FIRBandPass(data_spike_aligned,fs_hs,FunctionParams);
% [data_spike_warble_aligned,~] = egf_FIRBandPass(data_spike_warble_aligned,fs_hs,FunctionParams);
% % data_accl_aligned = data_accl_combined(isample_startz:isample_startz+nsamples_accl-1);
% % data_accl_aligned = data_accl(isample_startz:isample_startz+nsamples_accl-1);
% 
% data_audio = data_audio_combined(isample_start:isample_start+nsamples_spikes-1);
% data_audio_warble = data_audio_warble(isample_startz:isample_startz+nsamples_spikes-1);
% %% plot spectrogram
% % hf = figure;
% % set(hf, 'units', 'inches', 'Position', [1 1 6 4])
% 
% % plot spectrogram, 0.65
% subplot('Position', [0.13 0.58 0.21 0.09])
% ax = gca;
% params = egs_AAquick_sonogram('params');
% xlim([0,duration]);
% ylim([500,7500]);
% egs_AAquick_sonogram(ax,data_audio,20000,params);
% colormap('jet');
% Colormap = colormap;
% Colormap(1,:) = 0;
% colormap(Colormap);
% set(gca,'clim',climit)
% set(gca,'ydir','normal')
% % xt = get(gca,'ytick');
% % set(gca,'yticklabel',xt/1000);
% % ylabel('Frequency (kHz)');
% set(gca,'xtick',[])
% set(gca,'ytick',[])
% %% dbase
% 
% % plot spikes from bird one: 0.73-0.85
% subplot('Position', [0.13 0.52 0.21 0.05])
% edges = 1:nsamples_spikes;
% plot(edges,data_spike_aligned, 'k', 'LineWidth', 1)
% xlim([1,nsamples_spikes])
% set(gca, 'YTick', [])
% set(gca, 'XTick', [])
% axis off
% 
% % plot movement trace
% % moveOnsets = dbase.moveonsets{ifile_warble}-dbase.filestarttimes(ifile_warble);
% 
% subplot('Position', [0.4125 0.58 0.21 0.09])
% ax = gca;
% params = egs_AAquick_sonogram('params');
% xlim([0,duration]);
% ylim([500,7500]);
% egs_AAquick_sonogram(ax,data_audio_warble,20000,params);
% colormap('jet');
% Colormap = colormap;
% Colormap(1,:) = 0;
% colormap(Colormap);
% set(gca,'clim',climit)
% set(gca,'ydir','normal')
% % xt = get(gca,'ytick');
% % set(gca,'yticklabel',xt/1000);
% % ylabel('Frequency (kHz)');
% set(gca,'xtick',[])
% set(gca,'ytick',[])
% 
% 
% % plot spikes for move
% subplot('Position', [0.4125 0.52 0.21 0.05])
% edges = 1:nsamples_spikes;
% plot(edges,data_spike_warble_aligned, 'k', 'LineWidth', 1)
% xlim([1,nsamples_spikes])
% set(gca, 'YTick', [])
% set(gca, 'XTick', [])
% axis off
% 
% %% make triginfo for syll
% bSorted = 1;
% syll = 'c';
% % dbase = dbaseGetCallsBoutNonBout(dbase,[0.01,1],bSorted);
% iSpike = find(strcmp(dbase.Properties.Names{1},['bBigS' num2str(ichan)]));
% bSelected = [];
% pv = dbase.Properties.Values;
% for iFile = 1:length(pv)
%     if pv{iFile}{iSpike}
%         bSelected = [bSelected iFile];
%     end
% end
% allsyllstarttimes = concatenate(dbase.syllstarttimes(bSelected));
% allsyllendtimes = concatenate(dbase.syllendtimes(bSelected));
% 
% allsyllnames = cell2mat(concatenate(dbase.syllnames(bSelected)));
% trigger = allsyllstarttimes(strfind(allsyllnames,syll));
% 
% consets1 = allsyllstarttimes(strfind(allsyllnames,syll));
% coffsets1 = allsyllendtimes(strfind(allsyllnames,syll));
% % consets2 = concatenate(db2.cstarttimes);
% % coffsets2 = concatenate(db2.cendtimes);
% 
% % dbase call, dbase spk
% tf = dbaseTrigInfoFlex(dbase,consets1,coffsets1,ichan); 
% % tf2 = dbaseTrigInfoFlex(db2,consets1,coffsets1,ichan2); 
% % plot rasters, 0.26-0.56; 0.26 - 0.40; 0.41 - 0.56
% 
% subplot('Position', [0.13 0.17 0.21 0.33])
% plotrasters(tf,0);
% ylabel('Call #');
% 
% %% plot histogram, 0.1-0.25; 0.13-0.33
% subplot('Position', [0.13 0.05 0.21 0.1])
% ax = gca;
% set(gca, 'LineWidth', 1)
% set(gca, 'Box', 'On')
% tf.rds = smooth(tf.rd,3);
% 
% stairs(tf.edges,tf.rds,'k','LineWidth', 2); hold on;
% box off
% ylimit_syll = ylim;
% ylimit_syll(1)=0;
% if ylimit_syll(2) < 100
%     ylimit_syll(2) = ylimit_syll(2)*2;
% end
% line([0,0],ylimit_syll,'color','g', 'LineWidth', 1)
% 
% xlim([-.5,.5]);
% xlabel('Time (s)');
% ylabel('Rate (Hz)');
% % ylim([-4,8])
% xlabel('Time from call onsets (s)')
% 
% %%% now for syll ends
% 
% %% make triginfo for move
% bSorted = 1;
% 
% syll = 'w';
% consets1 = allsyllstarttimes(strfind(allsyllnames,syll));
% coffsets1 = allsyllendtimes(strfind(allsyllnames,syll));
% 
% % dbase call, dbase spk
% tf = dbaseTrigInfoFlex(dbase,consets1,coffsets1,ichan); 
% 
% subplot('Position', [0.4125 0.17 0.21 0.33])
% plotrasters(tf,0);
% ylabel('Warble #');
% % yticks([]);
% 
% %% plot histogram, 0.1-0.25; 0.13-0.33
% subplot('Position', [0.4125 0.05 0.21 0.1])
% ax = gca;
% set(gca, 'LineWidth', 1)
% set(gca, 'Box', 'On')
% tf.rds = smooth(tf.rd,3);
% 
% stairs(tf.edges,tf.rds,'k','LineWidth', 2); hold on;
% box off
% line([0,0],ylimit_syll,'color','g', 'LineWidth', 1)
% ylim(ylimit_syll);
% 
% xlim([-0.5,0.5]);
% xlabel('Time (s)');
% ylabel('Rate (Hz)');
% % ylim([-4,8]);
% xlabel('Time from warble onsets (s)')
% 
% %% plot move
% 
% 
% fs_hs = dbase.Fs;
% fs_accl = 5000;
% data_spike_combined = [];
% data_audio_combined = [];
% data_accl_combined = [];
% 
% cfiles = dbase.ChannelFiles;
% afiles = dbase.SoundFiles;
% path_name = dbase.PathName;
% if strcmp(path_name(1),'Y')
%     path_name(1)='B';
% end
% 
% nsamples = 0;
% nsamples_accl = floor(duration * fs_accl);
% nsamples_spikes = nsamples_accl*4;
% ifile = ifile_call;
% while nsamples < nsamples_spikes
%     [data_spike, ~] = egl_HC_ad([path_name '\' cfiles{ichan}(ifile).name],1);
%     [data_audio, ~] = egl_HC_ad([path_name '\' afiles(ifile).name],1);
% %     data_accl = rc_intan_loadaccl(dbase,ifile);
%     data_spike_combined = [data_spike_combined data_spike]; 
%     data_audio_combined = [data_audio_combined data_audio];
% %     data_accl_combined = [data_accl_combined data_accl];
%     if nsamples == 0
%         nsamples = length(data_audio_combined) - calloffset*fs_hs;
%     else
%         nsamples = nsamples + length(data_audio_combined);
%     end
%     ifile = ifile + 1;
% end
% ifile = ifile_call;
% 
% [data_spike_move, ~] = egl_HC_ad([path_name '\' cfiles{ichan}(ifile_move).name],1);
% data_accl = rc_intan_loadaccl(dbase,ifile_move);
% 
% isample_start = calloffset*fs_hs+1;
% isample_startz = moveoffset*fs_accl+1;
% isample_start_spikemove = moveoffset*fs_hs+1;
% 
% data_spike_aligned = data_spike_combined(isample_start:isample_start+nsamples_spikes-1);
% data_spike_move_aligned = data_spike_move(isample_start_spikemove:isample_start_spikemove+nsamples_spikes-1);
% [FunctionParams, ~] = egf_FIRBandPass('params');
% FunctionParams.Value(1)=900;
% FunctionParams.Value(2)=8000;
% [data_spike_aligned, ~] = egf_FIRBandPass(data_spike_aligned,fs_hs,FunctionParams);
% [data_spike_move_aligned,~] = egf_FIRBandPass(data_spike_move_aligned,fs_hs,FunctionParams);
% % data_accl_aligned = data_accl_combined(isample_startz:isample_startz+nsamples_accl-1);
% data_accl_aligned = data_accl(isample_startz:isample_startz+nsamples_accl-1);
% 
% data_audio = data_audio_combined(isample_start:isample_start+nsamples_spikes-1);
% 
% % plot movement trace
% moveOnsets = dbase.moveonsets{ifile_move}-dbase.filestarttimes(ifile_move);
% 
% subplot('Position', [0.695 0.58 0.21 0.09])
% edges = 1:nsamples_accl;
% plot(edges,data_accl_aligned, 'k', 'LineWidth', 1);
% ylimit = ylim;
% for i_move = 1:length(moveOnsets)
%     x = moveOnsets(i_move);
%     x = (x-moveoffset)*fs_accl;
%     line([x,x],[ylimit(1),ylimit(2)],'Color','b');
% end
% xlim([1,nsamples_accl])
% % ylim([-3e-4,2e-4]);
% set(gca, 'YTick', [])
% set(gca, 'XTick', [])
% axis off
% 
% % plot spikes for move
% subplot('Position', [0.695 0.52 0.21 0.05])
% edges = 1:nsamples_spikes;
% plot(edges,data_spike_move_aligned, 'k', 'LineWidth', 1)
% xlim([1,nsamples_spikes])
% set(gca, 'YTick', [])
% set(gca, 'XTick', [])
% axis off
% % % plot instantaneous firing rate: 0.6-0.72
% %% make triginfo for syll
% bSorted = 1;
% syll = 'c';
% % dbase = dbaseGetCallsBoutNonBout(dbase,[0.01,1],bSorted);
% iSpike = find(strcmp(dbase.Properties.Names{1},['bBigS' num2str(ichan)]));
% bSelected = [];
% pv = dbase.Properties.Values;
% % for iFile = ifile_call-50:ifile_call+50
% for iFile = 1:length(pv)
%     if pv{iFile}{iSpike}
%         bSelected = [bSelected iFile];
%     end
% end
% allsyllstarttimes = concatenate(dbase.syllstarttimes(bSelected));
% allsyllendtimes = concatenate(dbase.syllendtimes(bSelected));
% 
% allsyllnames = cell2mat(concatenate(dbase.syllnames(bSelected)));
% trigger = allsyllstarttimes(strfind(allsyllnames,syll));
% 
% consets1 = allsyllstarttimes(strfind(allsyllnames,syll));
% coffsets1 = allsyllendtimes(strfind(allsyllnames,syll));
% % consets2 = concatenate(db2.cstarttimes);
% % coffsets2 = concatenate(db2.cendtimes);
% 
% %%% now for syll ends
% 
% %% make triginfo for move
% bSorted = 1;
% 
% allmovestarttimes = concatenate(dbase.moveonsets(bSelected));
% allmoveendtimes = concatenate(dbase.moveoffsets(bSelected));
% allmovedur = concatenate(dbase.movedurs(bSelected));
% idx_dur = allmovedur < 0.5 & allmovedur > 0.075;
% 
% consets1 = allmovestarttimes(idx_dur);
% coffsets1 = allmoveendtimes(idx_dur);
% 
% 
% 
% % consets2 = concatenate(db2.cstarttimes);
% % coffsets2 = concatenate(db2.cendtimes);
% 
% % dbase call, dbase spk
% tf = dbaseTrigInfoFlex(dbase,consets1,coffsets1,ichan); 
% % tf2 = dbaseTrigInfoFlex(db2,consets1,coffsets1,ichan2); 
% % plot rasters, 0.26-0.56; 0.26 - 0.40; 0.41 - 0.56
% 
% subplot('Position', [0.695 0.17 0.21 0.33])
% plotrasters(tf,0);
% ylabel('Move #');
% % yticks([]);
% % dbase call, db2 spk
% % 
% % % plot rasters, 0.26-0.56; 0.26 - 0.40; 0.41 - 0.56
% % subplot('Position', [0.13 0.25 0.15 0.15])
% % plotrasters(tf2)
% % ylabel('Syllable #');
% 
% %% plot histogram, 0.1-0.25; 0.13-0.33
% subplot('Position', [0.695 0.05 0.21 0.1])
% ax = gca;
% set(gca, 'LineWidth', 1)
% set(gca, 'Box', 'On')
% tf.rds = smooth(tf.rd,3);
% 
% stairs(tf.edges,tf.rds,'k','LineWidth', 2); hold on;
% line([0,0],ylimit_syll,'color','g', 'LineWidth', 1)
% ylim(ylimit_syll);
% box off
% xlim([-0.5,0.5]);
% xlabel('Time (s)');
% ylabel('Rate (Hz)');
% % ylim([-4,8]);
% xlabel('Time from movement onsets (s)')
% 
% 
% set(findobj(gcf,'type','axes'),'FontName','Arial','FontSize',7,'FontWeight','Bold');
% % FUNCTION ENDS
% end
% 
% function plotrasters(tf,bReverse)
% set(gca, 'LineWidth', 1)
% set(gca, 'Box', 'On')
% lineheight=1;
% events = tf.events;
% 
% [sortedOffsets, indexByDur] = sort(tf.currTrigOffset-tf.trigStarts);
% if bReverse
%     [sortedOffsets, indexByDur] = sort(tf.currTrigOffset-tf.trigStarts,'descend');
% end
% nSylls = length(events);
% if nSylls < 10
%     return
% end
% maxSylls = 250; % this number determines how many epochs are plotted!
% if nSylls>maxSylls
%     randomKeep = sort(randsample(nSylls,maxSylls));
%     nSylls = maxSylls;
%     indexByDur = indexByDur(randomKeep);
%     sortedOffsets = sortedOffsets(randomKeep);
% end
% 
% 
% for i=1:nSylls
%     iSyllSorted = indexByDur(i);
%     spks=events{1,iSyllSorted};
%     % onset and boutoffset lines
%     if ~bReverse
%         line([sortedOffsets(i),sortedOffsets(i)],[i-1,i-1+lineheight],'color','r', 'LineWidth', 2)
%         line([0,0],[i-1,i-1+lineheight],'color','g', 'LineWidth', 2)
%     else
%         line([sortedOffsets(i),sortedOffsets(i)],[i-1,i-1+lineheight],'color','g', 'LineWidth', 2)
%         line([0,0],[i-1,i-1+lineheight],'color','r', 'LineWidth', 2)
%     end
%     if ~isempty(spks)
%         for j=1:length(spks)
%             line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 1)
%         end
%     end
% end
% xlim([-.5,.5]);
% xticks([]);
% ylim([1,nSylls]);
% yticks([nSylls]);
% end