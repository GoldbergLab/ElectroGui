function trigInfo=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, varargin)

%This function flexibly makes trigInfos (eg for syllonset aligned spike raster
%Trigger - what you are aligning the event to (syllon)
%Event (e.g.) spikes
%exclude are the other events that must be excluded from the raster

% exclude=sort([exclude dbase.filestarttimes dbase.fileendtimes]);

s=3;

if isempty(varargin);
xl=.3;binsize=.01;
else
xl=varargin{1};
binsize=varargin{2};
end

count=0;
for i=1:length(trigger);
    tempexclude=exclude(find(exclude>=trigger(i)-xl));
    tempexclude=tempexclude(find(tempexclude<=trigger(i)+xl+binsize));
    if isempty(tempexclude);
        count=count+1;
        tempevents=events(find(events>trigger(i)-xl & events<=trigger(i)+xl+binsize));
        t.events{count}=tempevents-trigger(i);
        t.trigStarts(count) = trigger(i);
    end
end

edges=-xl:binsize:xl+binsize;
if count == 0
    edges = [];
    dist = [];
else
    allevents=concatenate(t.events);
    dist=histc(allevents,edges);
    dist=dist/(count);dist=dist/binsize;
    dist=dist(1:end-1);edges=edges(1:end-1);
end
    
if bplot;
    figure;plot(edges,smooth(dist,s),'k');
    if ~isempty(edges); xlim([edges(1) edges(end)]); end
    title([dbase.title '-' num2str(count) '-triggers'], 'Interpreter', 'None');
end

t.edges=edges;
t.rd=dist;
t.rdmn=t.rd-mean(t.rd);
trigInfo=t;