function trigInfo=vg_MakeTrigInfoFlexMonteCarlo(trigger, events, exclude,dbase, bplot);

%This function is unfinished trash
exclude=sort([exclude dbase.filestarttimes dbase.fileendtimes]);

s=1;

xl=.2;
binsize=.01;
count=0;
for i=1:length(trigger);
    tempexclude=exclude(find(exclude>=trigger(i)-xl));
    tempexclude=tempexclude(find(tempexclude<=trigger(i)+xl+binsize));
    if isempty(tempexclude);
        count=count+1;
        tempevents=events(find(events>trigger(i)-xl & events<=trigger(i)+xl+binsize));
        t.events{count}=tempevents-trigger(i);
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
t.rdmn=t.rd-mean(t.rd);
trigInfo=t;

%montecarlo below
for r=1:numshuff
    for zz=1:size(t.events,2);
        spks{zz}=t.events+rand(1)*
    
    
    allevents=concatenate(t.events);
edges=[-xl:binsize:xl+binsize];
dist=histc(allevents,edges);
dist=dist/(count);dist=dist/binsize;
dist=dist(1:end-1);edges=edges(1:end-1);
    
    
end
    

