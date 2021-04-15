function dbase=vgm_hithistory(dbase)

%This function tests if the magnitude of the positive prediction error
%signal (the peaks following escapes) depends on the recent history of
%hits.

% mid-bout and end-bouts

window=[0 0.1]; %the window after trigger in which to gather spikes
xl=.5;
binsize=.01;
bplot = 0;

hitsyllstarts = dbase.hitsyllstarts;
hitsyllstarts_midbout = dbase.hitsyllstarts_midbout;
hitsyllstarts_endbout = dbase.hitsyllstarts_endbout;
hitsyllstarts_moves = dbase.hitsyllstarts_moves;
hitsyllstarts_nomoves = dbase.hitsyllstarts_nomoves;

escapesyllstarts = dbase.catchsyllstarts;
escapesyllstarts_midbout = dbase.catchsyllstarts_midbout;
escapesyllstarts_endbout = dbase.catchsyllstarts_endbout;
escapesyllstarts_moves = dbase.catchsyllstarts_moves;
escapesyllstarts_nomoves = dbase.catchsyllstarts_nomoves;

Zsyllstarts = dbase.Zsyllstarts;

fdbkdelays = dbase.fdbkdelays;
fdbkdelays_midbout = dbase.fdbkdelays_midbout;
fdbkdelays_endbout = dbase.fdbkdelays_endbout;
fdbkdelays_moves = dbase.fdbkdelays_moves;
fdbkdelays_nomoves = dbase.fdbkdelays_nomoves;


filestarttimes = dbase.filestarttimes;
fileendtimes = dbase.fileendtimes;
ind_overlap = dbase.filestarttimes(2:end)-dbase.fileendtimes(1:end-1) > eps;
ind_overlap_start = [true ind_overlap];
ind_overlap_end = [ind_overlap true];
filestarttimes_exclude = filestarttimes(ind_overlap_start);
fileendtimes_exclude = fileendtimes(ind_overlap_end);

exclude_default=sort([filestarttimes_exclude fileendtimes_exclude concatenate(dbase.stimtimes)]);

Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
exclude = exclude_default;

%Hits
events=concatenate(dbase.spiketimes);
trigger=hitsyllstarts+fdbkdelays;
t.hits=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

for i=1:length(t.hits.events)
    hitnum(i)=length(find(t.hits.events{i}>window(1) & t.hits.events{i}<window(2)));
    firstspike = t.hits.events{i}(find(t.hits.events{i} < window(1),1,'last'));
    if isempty(firstspike)
        firstspike = t.hits.edges(1);
    end
    lastspike = t.hits.events{i}(find(t.hits.events{i} > window(2),1,'first'));
    if isempty(lastspike)
        lastspike = t.hits.edges(end);
    end
    middlespikes = t.hits.events{i}(t.hits.events{i} > window(1) & t.hits.events{i} < window(2));
    if isempty(middlespikes)
        hitifrmean(i) = 1/(lastspike-firstspike);
    else
        hitifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
    end 
end

%Hits midbout
events=concatenate(dbase.spiketimes);
trigger=hitsyllstarts_midbout+fdbkdelays_midbout;
t.hits_midbout=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.hits_midbout.edges)
    for i=1:length(t.hits_midbout.events)
        hitnum_midbout(i)=length(find(t.hits_midbout.events{i}>window(1) & t.hits_midbout.events{i}<window(2)));
        firstspike = t.hits_midbout.events{i}(find(t.hits_midbout.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.hits_midbout.edges(1);
        end
        lastspike = t.hits_midbout.events{i}(find(t.hits_midbout.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.hits_midbout.edges(end);
        end
        middlespikes = t.hits_midbout.events{i}(t.hits_midbout.events{i} > window(1) & t.hits_midbout.events{i} < window(2));
        if isempty(middlespikes)
            hit_midboutifrmean(i) = 1/(lastspike-firstspike);
        else
            hit_midboutifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end 
    end
else
    hitnum_midbout = [];
    hit_midboutifrmean = [];
end

%Hits endbout
events=concatenate(dbase.spiketimes);
trigger=hitsyllstarts_endbout+fdbkdelays_endbout;
t.hits_endbout=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.hits_endbout.edges)
    for i=1:length(t.hits_endbout.events)
        hitnum_endbout(i)=length(find(t.hits_endbout.events{i}>window(1) & t.hits_endbout.events{i}<window(2)));
        firstspike = t.hits_endbout.events{i}(find(t.hits_endbout.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.hits_endbout.edges(1);
        end
        lastspike = t.hits_endbout.events{i}(find(t.hits_endbout.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.hits_endbout.edges(end);
        end
        middlespikes = t.hits_endbout.events{i}(t.hits_endbout.events{i} > window(1) & t.hits_endbout.events{i} < window(2));
        if isempty(middlespikes)
            hit_endboutifrmean(i) = 1/(lastspike-firstspike);
        else
            hit_endboutifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    hitnum_endbout = [];
    hit_endboutifrmean = [];
end

%Escapes
trigger=escapesyllstarts+median(fdbkdelays);
t.escapes=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

for i=1:length(t.escapes.events)
    escapenum(i)=length(find(t.escapes.events{i}>window(1) & t.escapes.events{i}<window(2)));
    firstspike = t.escapes.events{i}(find(t.escapes.events{i} < window(1),1,'last'));
    if isempty(firstspike)
        firstspike = t.escapes.edges(1);
    end
    lastspike = t.escapes.events{i}(find(t.escapes.events{i} > window(2),1,'first'));
    if isempty(lastspike)
        lastspike = t.escapes.edges(end);
    end
    middlespikes = t.escapes.events{i}(t.escapes.events{i} > window(1) & t.escapes.events{i} < window(2));
    if isempty(middlespikes)
        escapeifrmean(i) = 1/(lastspike-firstspike);
    else
        escapeifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
    end
end

%Escapes midbout
trigger=escapesyllstarts_midbout+median(fdbkdelays);
t.escapes_midbout = vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.escapes_midbout.edges)
    for i=1:length(t.escapes_midbout.events)
        escapenum_midbout(i)=length(find(t.escapes_midbout.events{i}>window(1) & t.escapes_midbout.events{i}<window(2)));
        firstspike = t.escapes_midbout.events{i}(find(t.escapes_midbout.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.escapes_midbout.edges(1);
        end
        lastspike = t.escapes_midbout.events{i}(find(t.escapes_midbout.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.escapes_midbout.edges(end);
        end
        middlespikes = t.escapes_midbout.events{i}(t.escapes_midbout.events{i} > window(1) & t.escapes_midbout.events{i} < window(2));
        if isempty(middlespikes)
            escape_midboutifrmean(i) = 1/(lastspike-firstspike);
        else
            escape_midboutifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    escapenum_midbout = [];
    escape_midboutifrmean = [];
end
%Escapes endbout
trigger=escapesyllstarts_endbout+median(fdbkdelays);
t.escapes_endbout = vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.escapes_endbout.edges)
    for i=1:length(t.escapes_endbout.events)
        escapenum_endbout(i)=length(find(t.escapes_endbout.events{i}>window(1) & t.escapes_endbout.events{i}<window(2)));
        firstspike = t.escapes_endbout.events{i}(find(t.escapes_endbout.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.escapes_endbout.edges(1);
        end
        lastspike = t.escapes_endbout.events{i}(find(t.escapes_endbout.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.escapes_endbout.edges(end);
        end
        middlespikes = t.escapes_endbout.events{i}(t.escapes_endbout.events{i} > window(1) & t.escapes_endbout.events{i} < window(2));
        if isempty(middlespikes)
            escape_endboutifrmean(i) = 1/(lastspike-firstspike);
        else
            escape_endboutifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    escapenum_endbout = [];
    escape_endboutifrmean = [];
end

%Zs
if ~isempty(dbase.Zsyllstarts)
    trigger=Zsyllstarts;
    t.Zs=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl, binsize);
    
    for i=1:length(t.Zs.events)
        Znum(i)=length(find(t.Zs.events{i}>window(1) & t.Zs.events{i}<window(2)));
        firstspike = t.Zs.events{i}(find(t.Zs.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.Zs.edges(1);
        end
        lastspike = t.Zs.events{i}(find(t.Zs.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.Zs.edges(end);
        end
        middlespikes = t.Zs.events{i}(t.Zs.events{i} > window(1) & t.Zs.events{i} < window(2));
        if isempty(middlespikes)
            Zifrmean(i) = 1/(lastspike-firstspike);
        else
            Zifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
    
end

% with and without movement

%Hits with movements
trigger=hitsyllstarts_moves+fdbkdelays_moves;
t.hits_moves=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.hits_moves.edges)
    for i=1:length(t.hits_moves.events)
        hitnum_moves(i)=length(find(t.hits_moves.events{i}>window(1) & t.hits_moves.events{i}<window(2)));
        firstspike = t.hits_moves.events{i}(find(t.hits_moves.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.hits_moves.edges(1);
        end
        lastspike = t.hits_moves.events{i}(find(t.hits_moves.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.hits_moves.edges(end);
        end
        middlespikes = t.hits_moves.events{i}(t.hits_moves.events{i} > window(1) & t.hits_moves.events{i} < window(2));
        if isempty(middlespikes)
            hit_movesifrmean(i) = 1/(lastspike-firstspike);
        else
            hit_movesifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    hitnum_moves = [];
    hit_movesifrmean = [];
end

%Hits with NO movements
trigger=hitsyllstarts_nomoves+fdbkdelays_nomoves;
t.hits_nomoves=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.hits_nomoves.edges)
    for i=1:length(t.hits_nomoves.events)
        hitnum_nomoves(i)=length(find(t.hits_nomoves.events{i}>window(1) & t.hits_nomoves.events{i}<window(2)));
        firstspike = t.hits_nomoves.events{i}(find(t.hits_nomoves.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.hits_nomoves.edges(1);
        end
        lastspike = t.hits_nomoves.events{i}(find(t.hits_nomoves.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.hits_nomoves.edges(end);
        end
        middlespikes = t.hits_nomoves.events{i}(t.hits_nomoves.events{i} > window(1) & t.hits_nomoves.events{i} < window(2));
        if isempty(middlespikes)
            hit_nomovesifrmean(i) = 1/(lastspike-firstspike);
        else
            hit_nomovesifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    hitnum_nomoves = [];
    hit_nomovesifrmean = [];
end

%Escapes with movements
trigger=escapesyllstarts_moves+median(fdbkdelays);
t.escapes_moves=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.escapes_moves.edges)
    for i=1:length(t.escapes_moves.events)
        escapenum_moves(i)=length(find(t.escapes_moves.events{i}>window(1) & t.escapes_moves.events{i}<window(2)));
        firstspike = t.escapes_moves.events{i}(find(t.escapes_moves.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.escapes_moves.edges(1);
        end
        lastspike = t.escapes_moves.events{i}(find(t.escapes_moves.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.escapes_moves.edges(end);
        end
        middlespikes = t.escapes_moves.events{i}(t.escapes_moves.events{i} > window(1) & t.escapes_moves.events{i} < window(2));
        if isempty(middlespikes)
            escape_movesifrmean(i) = 1/(lastspike-firstspike);
        else
            escape_movesifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    escapenum_moves = [];
    escape_movesifrmean = [];
end

%Escapes with NO movements
trigger=escapesyllstarts_nomoves+median(fdbkdelays);
t.escapes_nomoves=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl,binsize);

if ~isempty(t.escapes_nomoves.edges)
    for i=1:length(t.escapes_nomoves.events)
        escapenum_nomoves(i)=length(find(t.escapes_nomoves.events{i}>window(1) & t.escapes_nomoves.events{i}<window(2)));
        firstspike = t.escapes_nomoves.events{i}(find(t.escapes_nomoves.events{i} < window(1),1,'last'));
        if isempty(firstspike)
            firstspike = t.escapes_nomoves.edges(1);
        end
        lastspike = t.escapes_nomoves.events{i}(find(t.escapes_nomoves.events{i} > window(2),1,'first'));
        if isempty(lastspike)
            lastspike = t.escapes_nomoves.edges(end);
        end
        middlespikes = t.escapes_nomoves.events{i}(t.escapes_nomoves.events{i} > window(1) & t.escapes_nomoves.events{i} < window(2));
        if isempty(middlespikes)
            escape_nomovesifrmean(i) = 1/(lastspike-firstspike);
        else
            escape_nomovesifrmean(i) = ((middlespikes(1)-window(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (window(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(window(2)-window(1));
        end
    end
else
    escapenum_nomoves = [];
    escape_nomovesifrmean = [];
end

%Updating the dbase with new fields
dbase.historyanalysis.hitnum = hitnum;
dbase.historyanalysis.hitifrmean = hitifrmean;
dbase.historyanalysis.hitnum_midbout = hitnum_midbout;
dbase.historyanalysis.hit_midboutifrmean = hit_midboutifrmean;
dbase.historyanalysis.hitnum_endbout = hitnum_endbout;
dbase.historyanalysis.hit_endboutifrmean = hit_endboutifrmean;
dbase.historyanalysis.hitnum_moves = hitnum_moves;
dbase.historyanalysis.hit_movesifrmean = hit_movesifrmean;
dbase.historyanalysis.hitnum_nomoves = hitnum_nomoves;
dbase.historyanalysis.hit_nomovesifrmean = hit_nomovesifrmean;
dbase.historyanalysis.escapenum = escapenum;
dbase.historyanalysis.escapeifrmean = escapeifrmean;
dbase.historyanalysis.escapenum_midbout = escapenum_midbout;
dbase.historyanalysis.escape_midboutifrmean = escape_midboutifrmean;
dbase.historyanalysis.escapenum_endbout = escapenum_endbout;
dbase.historyanalysis.escape_endboutifrmean = escape_endboutifrmean;
dbase.historyanalysis.escapenum_moves = escapenum_moves;
dbase.historyanalysis.escape_movesifrmean = escape_movesifrmean;
dbase.historyanalysis.escapenum_nomoves = escapenum_nomoves;
dbase.historyanalysis.escape_nomovesifrmean = escape_nomovesifrmean;

if ~isempty(dbase.Zsyllstarts)
    dbase.historyanalysis.Znum = Znum;
    dbase.historyanalysis.Zifrmean = Zifrmean;
end
dbase.historyanalysis.window = window;
end



