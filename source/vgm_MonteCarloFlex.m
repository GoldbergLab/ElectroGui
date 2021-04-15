function trigInfo=vgm_MonteCarloFlex(trigInfo)

if isempty(trigInfo.edges)
    return
end

binsize=diff(trigInfo.edges);
binsize=binsize(1);
s=3;
edges=trigInfo.edges;
dur=edges(end)-edges(1);
numtrig=size(trigInfo.events,2);
trigInfo.rds=smooth(trigInfo.rd,s)';
ratemin=[];ratemins=[];ratemax=[];ratemaxs=[];
fd_all = zeros([1000,length(edges)]);
for r=1:1000
    %fake data rate histogram
    fd=0;%fd for "fake data"
    for i=1:numtrig% i is looping through each row of raster
        spks=trigInfo.events{i};
        spks=spks(find(spks<=edges(end)));
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
    fd_all(r,:) = fd;
    fd=fd(1:end-1);%eliminates the last bin representing #spks==dur.stop
    
    ratemin=[ratemin min(fd)];ratemax=[ratemax max(fd)];
    fds=smooth(fd,s)';
    ratemins=[ratemins min(fds)];ratemaxs=[ratemaxs max(fds)];
end
trigInfo.pval.minrate=mean(ratemin<=min(trigInfo.rd));%mean of 0s and 1s will yield the pvalue.
trigInfo.pval.maxrate=mean(ratemax>=max(trigInfo.rd));
trigInfo.pval.minrates=mean(ratemins<=min(trigInfo.rds));
trigInfo.pval.maxrates=mean(ratemaxs>=max(trigInfo.rds));

trigInfo.fd.pct95max = prctile(fd_all,95);
trigInfo.fd.pct5min = prctile(fd_all,5);
trigInfo.fd.pct99max = prctile(fd_all,99);
trigInfo.fd.pct1min = prctile(fd_all,1);

[yo ndx.min]=min(trigInfo.rd);[yo ndx.max]=max(trigInfo.rd);
[yo ndxs.min]=min(trigInfo.rds);[yo ndxs.max]=max(trigInfo.rds);

trigInfo.s=s;
trigInfo.corrtime.min=edges(ndx.min);
trigInfo.corrtime.max=edges(ndx.max);
trigInfo.corrtime.mins=edges(ndxs.min);
trigInfo.corrtime.maxs=edges(ndxs.max);
trigInfo.moddepth=(max(trigInfo.rd)-min(trigInfo.rd))/mean(trigInfo.rd);

end