% clear;
% 
% foldname = 'C:\Users\GLab\Box Sync\VP_dbases\sortedRCandPavel\';
% % foldname = 'C:\Users\GLab\Box Sync\VP_dbases\VPpretargetPlot\PretargetBurst\';
% % foldname = 'C:\Users\GLab\Box Sync\VP_dbases\forBOS\';
% % foldname = 'D:\Box Sync\VP_dbases\sortedRCandPavel\';
% contents=dir(foldname);
% dbases_all = []; % This holds processed dbases.
% n_dbases = length(contents)-2;
% 
% %% load dbases from files
% for i_dbase = 1:n_dbases
%     name_dbase = contents(i_dbase+2).name;
%     num = str2num(dbase.title(1:3));
%     if sum(indx_time ==num)
%         continue
%     end
% %     disp(name_dbase);
%     load([foldname name_dbase]);
%     disp(dbase.title);
%     dbases_all{i_dbase} = dbase;
% end

%% generate matrix where each row is rds from one neuron
edges = dbase.trigInfoTargetbin10.edges;
% rds_all = zeros(n_dbases,length(edges));
rds_all = [];
for i_dbase = 1:n_dbases
    dbase = dbases_all{i_dbase};
    num = str2num(dbase.title(1:3));
    if ~sum(indx_time ==num)
        continue
    end
    trigInfo = dbase.trigInfocatchbin10;
    rds_all = [rds_all; trigInfo.rds];
end

% make matrices for plotting
% this is row vector with the sum of raw firing rates
sum_rds_all = sum(rds_all);
% this is matrix with each row normalized to its max (highest rate=1)
norm_rds_all = rds_all./max(rds_all,[],2);
% this is row vector with sum of above normalized rates
sum_norm_rds_all = sum(norm_rds_all);
% select only neurons with motif offset more than 0.2 sec before/after target
rc_vBG_targetTiming;
%% exclude neurons with late target
norm_rds_all_long = norm_rds_all(find(t2onset>0.2&t2offset>0.2)',:);
sum_norm_rds_all_long = sum(norm_rds_all_long);
% select only neurons with firing rate 
norm_rds_all_SongModulated = norm_rds_all(find(bpeaks)',:);
sum_norm_rds_all_SongModulated = sum(norm_rds_all_SongModulated);
% combine both conditions: long motifs with song modulation
norm_rds_songmod_long = norm_rds_all(find(t2onset>0.2 & t2offset>0.2 &bpeaks)',:);
sum_norm_rds_songmod_long = sum(norm_rds_songmod_long);

%% plot sum of all neurons
figure;
ymax = max(sum_rds_all);
stairs(edges, sum_rds_all, 'LineWidth', 2);
 hr = patch([0 0.05 0.05 0],...
                     [0 0 ymax ymax], [1 0.4488 0.4488], 'EdgeColor', 'none');
                     set(hr, 'FaceAlpha', 0.5)
% ylim([5000,8000]);
xlim([-1,1]);

%% plot all neurons sum, normalized
figure;

ymax = max(sum_norm_rds_all);
stairs(edges, sum_norm_rds_all, 'LineWidth', 2);
 hr = patch([0 0.05 0.05 0],...
                     [0 0 ymax ymax], [1 0.4488 0.4488], 'EdgeColor', 'none');
                     set(hr, 'FaceAlpha', 0.5)
% ylim([65,80]);
xlim([-.5,.5]);
title('Sum of target aligned rate histogram (normalized)');
xlabel('time (s)')
ylabel('sum of normalized firing (AU)')
%% plot all neurons sum, normalized, longer than 0.2 after target
figure;

ymax = max(sum_norm_rds_all_long);
stairs(edges, sum_norm_rds_all_long, 'LineWidth', 2);
 hr = patch([0 0.05 0.05 0],...
                     [0 0 ymax ymax], [1 0.4488 0.4488], 'EdgeColor', 'none');
                     set(hr, 'FaceAlpha', 0.5)
ylim([45,60]);
xlim([-1,1]);

%% plot all neurons sum, normalized, with rate peaks in motif
figure;

ymax = max(sum_norm_rds_all_SongModulated);
stairs(edges, sum_norm_rds_all_SongModulated, 'LineWidth', 2);
 hr = patch([0 0.05 0.05 0],...
                     [0 0 ymax ymax], [1 0.4488 0.4488], 'EdgeColor', 'none');
                     set(hr, 'FaceAlpha', 0.5)
ylim([45,65]);
xlim([-0.5,0.5]);

%% plot all neurons sum, normalized, with rate peaks in motif, long
figure;

ymax = max(sum_norm_rds_songmod_long);
stairs(edges, sum_norm_rds_songmod_long, 'LineWidth', 2);
 hr = patch([0 0.05 0.05 0],...
                     [0 0 ymax ymax], [1 0.4488 0.4488], 'EdgeColor', 'none');
                     set(hr, 'FaceAlpha', 0.5)
ylim([25,40]);
xlim([-0.5,0.5]);
title('Sum of target aligned rate histogram (normalized)');
xlabel('time (s)')
ylabel('sum of normalized firing (AU)')


%% population plot of rates in target window
n_fakes = 32;
target_rates = [];
fake_rates = [];
target_spkcts = [];
fake_spkcts = [];
for i_dbase = 1:n_dbases
    num = str2num(dbase.title(1:3));
    if sum(indx_time ==num)
        continue
    end
    dbase = dbases_all{i_dbase};
    tf = dbase.trigInfomotifCaseI.warped{1};
    target_rates = [target_rates tf.target_rate/tf.meanrate_motif];
    fake_rates = [fake_rates mean(tf.fake_rates/tf.meanrate_motif)];
    target_spkcts = [target_spkcts tf.target_spikects'];
    fake_spkcts = [fake_spkcts reshape(tf.fake_spikects,1,[])];
end
% fake_rates = reshape(fake_rates,[],1);
%%
target_mean = mean(target_rates);
target_std = std(target_rates);
fake_mean = mean(fake_rates);
fake_std = std(fake_rates);

means = [target_mean fake_mean];
stds = [target_std fake_std];
figure
errorbar(means,stds);
xlim([0,3]);
labels = {'target', 'non-target'};
set(gca, 'XTick', 1:2, 'XTickLabel', labels)


%%
figure;
rates = [target_rates fake_rates];
r_label = 'target';
f_label = 'nontgt';
rf_labels = [repmat(r_label,length(target_rates),1);...
    repmat(f_label,length(fake_rates),1)];
boxplot(rates,rf_labels);
%%
figure;
boxplot([target_rates,fake_rates(1:length(target_rates))],'Notch','on','Labels',{'target','non target'})