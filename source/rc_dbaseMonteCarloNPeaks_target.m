function tf=rc_dbaseMonteCarloNPeaks_target(dbase,tf)

% reset random number generator for reproducible behavior
rng(0); 

if isempty(tf.edges)
    return
end

binsize=tf.edges(2)-tf.edges(1);
s = 3;
edges=tf.edges;


numtrig=size(tf.events,2);
rds=smooth(tf.rd,s);

motifdur = dbase.motifdur;
targetT = dbase.targetT;

% compute real histogram\
rd = 1;
for i=1:numtrig% i is looping through each row of raster
        spks = tf.events{i}; % for target aligned rasters
        % make sure only look within motif
        spks=spks(find(spks<=edges(end)));
        spks=spks(find(spks>=edges(1)));        
        temprd=histc(spks,edges); 
        if ~isempty(temprd);
            rd=rd+temprd;
        end
end
rd = rd/numtrig/binsize;
rds = smooth(rd,s);

% % remove rasters outside [-0.5,0.5]
% rd_motif = rd(edges>=-0.5 & edges<=0.5);
% rd = rd(edges>=-0.5 & edges<=0.5);
% rds = rds(edges>=-0.5 & edges<=0.5);
% edges = edges(edges>=-0.5 & edges<=0.5);
% dur=edges(end)-edges(1);

% remove rasters outside motif
rd_motif = rd(edges>=-targetT & edges<=motifdur-targetT);
rd = rd(edges>=-targetT & edges<=motifdur-targetT);
rds = rds(edges>=-targetT & edges<=motifdur-targetT);
edges = edges(edges>=-targetT & edges<=motifdur-targetT);
dur=edges(end)-edges(1);

ratemin=[];ratemins=[];ratemax=[];ratemaxs=[];
moddepths = [];fstds = [];  fmeans = []; fdall = []; fprom = [];
for r=1:1000
    %fake data rate histogram
    fd=0;%fd for "fake data"
    for i=1:numtrig% i is looping through each row of raster

        spks = tf.events{i}; % for target aligned rasters
        % make sure only look within motif
        spks=spks(find(spks<=edges(end)));
        spks=spks(find(spks>=edges(1)));        
        spks = spks + dur*rand(1);
        spks(find(spks>edges(end)))=spks(find(spks>edges(end)))-dur;%wrap around
        spks=sort(spks);
        tempfd=histc(spks,edges); 
        if ~isempty(tempfd);
%         zz=size(tempfd);if zz(2)>zz(1);tempfd=tempfd';end
            fd=fd+tempfd;
        end%fix matrix dimensions HERE 
    end

    fd=fd/numtrig/binsize;%gives rate histogram
    fd=fd(1:end-1);%eliminates the last bin representing #spks==dur.stop
    fstd = std(fd);
    fmean = mean(fd);
    fstds = [fstds fstd];
    fmeans = [fmeans fmean];
    ratemin=[ratemin min(fd)];ratemax=[ratemax max(fd)];

    fds=smooth(fd,s);
    [pks,locs,w,p] = findpeaks(fds,'MinPeakDistance',5);
    fprom = [fprom;p];
    fdall = [fdall fds];
%     if r>990
%     figure();plot(fds);
%     end
    ratemins=[ratemins min(fds)];ratemaxs=[ratemaxs max(fds)];
    moddepths = [moddepths (max(fds)-min(fds))/(max(fds)+min(fds))];  
end

% rds_motif = rds;
% [~,i_min_motif] = min(rds_motif);
% t_min = edges(i_min_motif);
% [~,i_max_motif] = max(rds_motif);
% t_max = edges(i_max_motif);
% tf.t_min_motif = t_min+binsize/2;
% tf.t_max_motif = t_max+binsize/2;
% minimum = min(rds_motif);
% maximum = max(rds_motif);
% p_min = sum(ratemins<minimum)/1000;
% p_max = sum(ratemaxs>maximum)/1000;
% tf.p_min_motif = p_min;
% tf.p_max_motif = p_max;

[pks,indpks] = findpeaks(rds,'MinPeakDistance',5);
[trofs,indtrofs] = findpeaks(-rds,'MinPeakDistance',5);

[maximum,i_max] = max(pks);
t_max = edges(indpks(i_max));
[minimum,i_min] = max(trofs);
minimum=-minimum;
t_min = edges(indtrofs(i_min));
tf.t_min_motif = t_min+binsize/2;
tf.t_max_motif = t_max+binsize/2;
p_min = sum(ratemins<minimum)/1000;
p_max = sum(ratemaxs>maximum)/1000;
if ~(maximum==max(rds))
    p_max=1;
end
if ~(minimum==min(rds))
    p_min=1;
end
tf.p_min_motif = p_min;
tf.p_max_motif = p_max;


fdmean = mean(fdall);
fdstd = std(fdall);
thresh = fdmean + 2*fdstd;
threshLo = fdmean - 2*fdstd;
threshs = fmeans + 2*fstds;
threshsLo = fmeans - 2*fstds;
tf.npeaks1 = length(find(pks>prctile(ratemaxs,95)));

tf.time_peaks = edges(indpks(find(pks>prctile(ratemaxs,95))));
tf.rate_peaks = pks(find(pks>prctile(ratemaxs,95)));
tf.time_trofs = edges(indtrofs(find(-trofs<prctile(ratemins,5))));
tf.rate_trofs = -trofs((find(-trofs<prctile(ratemins,5))));
% tf.npeaks2 = length(find(pks>prctile(rds,50)));
% tf.npeaks = length(find(pks>thresh));
% tf.ntrofs = length(find(-trofs<threshLo));
% tf.npeakss = length(find(pks>prctile(threshs,95)));
% tf.ntrofss = length(find(-trofs<prctile(threshsLo,5)));
% [pks,locs,w,p] = findpeaks(rds,'MinPeakDistance',5,'MinPeakProminence',prctile(fprom,95));
[pks,locs,w,p] = findpeaks(rds,'MinPeakDistance',5);
tf.npeaksProm = length(pks);
tf.meanProm = mean(p(pks>prctile(ratemaxs,95)));
end