function trigInfo=vg_MakeTrigInfoFlexWarped(trigger, events, exclude,dbase, bplot);

%This function flexibly makes trigInfos (eg for syllonset aligned spike raster
%Trigger - what you are aligning the event to (syllon)
%Event (e.g.) spikes
%exclude are the other events that must be excluded from the raster

exclude=sort([exclude dbase.filestarttimes dbase.fileendtimes]);

s=3;

xl=.2;
binsize=.01;
count=0;
for i=1:length(trigger);
    tempexclude=exclude(find(exclude>=trigger(i)-xl));
    tempexclude=tempexclude(find(tempexclude<=trigger(i)+xl+binsize));
    if isempty(tempexclude);
        count=count+1;
        tempevents=events(find(events>trigger(i)-xl & events<=trigger(i)+xl+binsize));
        t.events{i}=tempevents-trigger(i);
    end
end
allevents=concatenate(t.events);
edges=[-xl:binsize:xl+binsize];
dist=histc(allevents,edges);
dist=dist/(count);dist=dist/binsize;
dist=dist(1:end-1);edges=edges(1:end-1);
if bplot;
    figure;plot(edges,smooth(dist,s),'k');
    xlim([edges(1) edges(end)]);
    title([dbase.title '-' num2str(count) '-triggers']);
end

t.edges=edges;
t.rd=dist;
trigInfo=t;