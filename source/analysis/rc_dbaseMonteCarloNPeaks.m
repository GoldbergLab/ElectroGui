function trigInfo=rc_dbaseMonteCarloNPeaks(trigInfo)

% reset random number generator for reproducible behavior
rng(0); 

if isempty(trigInfo.edges)
    return
end

binsize=diff(trigInfo.edges);
binsize=binsize(1);
s = floor(0.02/binsize);
s = max(s,3);
edges=trigInfo.edges;

if isfield(trigInfo,'eventOnsets') 
    numtrig=size(trigInfo.eventOnsets{1},2);
else
    numtrig=size(trigInfo.events,2);
end
rds=smooth(trigInfo.rd,s);
if isfield(trigInfo,'currTrigOffset')
    median_dur = median(trigInfo.currTrigOffset);
else
    median_dur = 2; % for target aligned rasters, take 2 secs
end
% 
binsize = 0.004;
s = 3;
edges = -0.1:binsize:median_dur+0.1;
% 

% compute real histogram\
rd = 1;
for i=1:numtrig% i is looping through each row of raster
    if isfield(trigInfo,'eventOnsets')    
        spks=trigInfo.eventOnsets{1}{i};
    else
        spks = trigInfo.events{i}+1; % for target aligned rasters
    end
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

% remove rasters outside motif
rds = rds(edges>=0 & edges <= median_dur);
edges = edges(edges>=0 & edges <= median_dur);
dur=edges(end)-edges(1);

ratemin=[];ratemins=[];ratemax=[];ratemaxs=[];
moddepths = [];fstds = [];  fmeans = []; fdall = []; fprom = [];
for r=1:1000
    %fake data rate histogram
    fd=0;%fd for "fake data"
    for i=1:numtrig% i is looping through each row of raster
        if isfield(trigInfo,'eventOnsets')    
            spks=trigInfo.eventOnsets{1}{i};
        else
            spks = trigInfo.events{i}+1; % for target aligned rasters
        end
        % make sure only look within motif
        spks=spks(find(spks<=edges(end)));
        spks=spks(find(spks>=edges(1)));        
        spks=spks+dur*rand(1);
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
%     fds=smooth(fd,s)';
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
% figure();plot(rds);
[pks,indpks] = findpeaks(rds,'MinPeakDistance',5);
[trofs,indtrofs] = findpeaks(-rds,'MinPeakDistance',5);
fdmean = mean(fdall);
fdstd = std(fdall);
thresh = fdmean + 2*fdstd;
threshLo = fdmean - 2*fdstd;
threshs = fmeans + 2*fstds;
threshsLo = fmeans - 2*fstds;
trigInfo.npeaks1 = length(find(pks>prctile(ratemaxs,95)));
if ~isfield(trigInfo,'eventOnsets') 
    edges = edges - 1; % for target aligned rasters
end
trigInfo.time_peaks = edges(indpks(find(pks>prctile(ratemaxs,95))));
trigInfo.rate_peaks = pks(find(pks>prctile(ratemaxs,95)));
trigInfo.time_trofs = edges(indtrofs(find(-trofs<prctile(ratemins,5))));
trigInfo.rate_trofs = -trofs((find(-trofs<prctile(ratemins,5))));
% trigInfo.npeaks2 = length(find(pks>prctile(rds,50)));
% trigInfo.npeaks = length(find(pks>thresh));
% trigInfo.ntrofs = length(find(-trofs<threshLo));
% trigInfo.npeakss = length(find(pks>prctile(threshs,95)));
% trigInfo.ntrofss = length(find(-trofs<prctile(threshsLo,5)));
% [pks,locs,w,p] = findpeaks(rds,'MinPeakDistance',5,'MinPeakProminence',prctile(fprom,95));
[pks,locs,w,p] = findpeaks(rds,'MinPeakDistance',5);
trigInfo.npeaksProm = length(pks);
trigInfo.meanProm = mean(p(pks>prctile(ratemaxs,95)));
end