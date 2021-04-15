function dbase=vgm_BurstAnalysis(dbase,prc)

% This function takes a dbase and makes the field BurstAnalysis: burst and pauses.

% Note: m stands for the analysis where bursts are considered to have any
% number of spikes (not just 2). isi that are shorter than threshold (2 spikes) are
% called elementary bursts. 

% what percentiles to use for bursts and pauses
Prctileburst = prc;
Prctilepause = 100-prc;

% the window to use after fdbk onset
winsize = 0.075;

% calculate the burst and pause isi thresholds. use interbout if nonsong has too few 
if length(dbase.ISI.nonsong) > 100
    threshburst = prctile(dbase.ISI.nonsong,Prctileburst);   %define burst
    threshpause = prctile(dbase.ISI.nonsong,Prctilepause);   %define pause
else
    threshburst = prctile(dbase.ISI.interbout,Prctileburst);   %define burst
    threshpause = prctile(dbase.ISI.interbout,Prctilepause);   %define pause
end

% calculate for the nonsong period: comments here apply for interbout,
% bout, hit, and escapes below as well. 
if length(dbase.ISI.nonsong) > 100
    nonsong.isi = dbase.ISI.nonsong;    % isi during nonsong
else
    nonsong.isi = dbase.ISI.interbout;
end
nonsong.time = sum(nonsong.isi);
nonsongooind = diff([0 nonsong.isi < threshburst 0]);  %indexing
nonsong.Nmburst = sum(nonsongooind > 0.5);
nonsong.Rmburst = nonsong.Nmburst/nonsong.time; % rate of m bursts (Hz)
nonsong.Npause = sum(nonsong.isi > threshpause);    % number of pauses in nonsong
nonsong.Rpause = nonsong.Npause/nonsong.time;   % rate of pauses (Hz) in nonsong period

% calculate for the interbout period
interbout.isi = dbase.ISI.interbout;
interbout.time = sum(interbout.isi);
interboutooind = diff([0 interbout.isi < threshburst 0]);
interbout.Nmburst = sum(interboutooind > 0.5);
interbout.Rmburst = interbout.Nmburst/interbout.time;
interbout.Npause = sum(interbout.isi > threshpause);
interbout.Rpause = interbout.Npause/interbout.time;

% calculate for the bout period
bout.isi = dbase.ISI.bout;
bout.time = sum(bout.isi);
boutooind = diff([0 bout.isi < threshburst 0]);
bout.Nmburst = sum(boutooind > 0.5);
bout.Rmburst = bout.Nmburst/bout.time;
bout.Npause = sum(bout.isi > threshpause);
bout.Rpause = bout.Npause/bout.time;

% calculate for the bout period with the hit and escape regions excluded
boutnohitesc.isi = dbase.ISI.boutnohitesc;
boutnohitesc.time = sum(boutnohitesc.isi);
boutnohitescooind = diff([0 boutnohitesc.isi < threshburst 0]);
boutnohitesc.Nmburst = sum(boutnohitescooind > 0.5);
boutnohitesc.Rmburst = boutnohitesc.Nmburst/boutnohitesc.time;
boutnohitesc.Npause = sum(boutnohitesc.isi > threshpause);
boutnohitesc.Rpause = boutnohitesc.Npause/boutnohitesc.time;

% calculate for outside song (nonsong and interbout)
outsong.isi = [dbase.ISI.nonsong dbase.ISI.interbout];
outsong.time = sum(outsong.isi);
outsongooind = diff([0 outsong.isi < threshburst 0]);
outsong.Nmburst = sum(outsongooind > 0.5);
outsong.Rmburst = outsong.Nmburst/outsong.time;
outsong.Npause = sum(outsong.isi > threshpause);
outsong.Rpause = outsong.Npause/outsong.time;

% infrastructure for bursts and pauses during hits and escapes (window: see above)
% parameters to use for making a triginfo for hits and escapes
bplot=0;
xl=winsize/2;
binsize=.025;
latency = 0.0875;

dbase=vgm_GetBursts(dbase,Prctileburst);
dbase=vgm_GetPauses(dbase,Prctilepause);

hittrigger = dbase.hitsyllstarts+dbase.fdbkdelays+latency;
esctrigger = dbase.catchsyllstarts+median(dbase.fdbkdelays)+latency;
othertrigger = concatenate(dbase.boutsyllstarttimes)+median(dbase.fdbkdelays)+latency;

exclude_default=sort([dbase.filestarttimes dbase.fileendtimes concatenate(dbase.stimtimes)]);
Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
exclude = [exclude_default Zstarttimes];
exclude_other = [exclude_default Zstarttimes dbase.hitsyllstarts+dbase.fdbkdelays...
    dbase.hitsyllstarts+dbase.fdbkdelays+0.3 dbase.catchsyllstarts+median(dbase.fdbkdelays)...
    dbase.catchsyllstarts+median(dbase.fdbkdelays)+0.3];

events_burstonsets = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctileburst)]).burstonsets);
events_burstoffsets = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctileburst)]).burstoffsets);

events_pausestarts = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctilepause)]).pausestarts);
events_pausestops = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctilepause)]).pausestops);

% hits:bursts
t.hitburstonsets = vgm_MakeTrigInfoFlex(hittrigger, events_burstonsets, exclude,dbase, bplot,xl,binsize);
t.hitburstoffsets = vgm_MakeTrigInfoFlex(hittrigger, events_burstoffsets, exclude,dbase, bplot,xl,binsize);

% escapes:bursts
t.escburstonsets = vgm_MakeTrigInfoFlex(esctrigger, events_burstonsets, exclude,dbase, bplot,xl,binsize);
t.escburstoffsets = vgm_MakeTrigInfoFlex(esctrigger, events_burstoffsets, exclude,dbase, bplot,xl,binsize);

% others:bursts
t.otherburstonsets = vgm_MakeTrigInfoFlex(othertrigger, events_burstonsets, exclude_other,dbase, bplot,xl,binsize);
t.otherburstoffsets = vgm_MakeTrigInfoFlex(othertrigger, events_burstoffsets, exclude_other,dbase, bplot,xl,binsize);

% hits:pauses
t.hitpausestarts = vgm_MakeTrigInfoFlex(hittrigger, events_pausestarts, exclude,dbase, bplot,xl,binsize);
t.hitpausestops = vgm_MakeTrigInfoFlex(hittrigger, events_pausestops, exclude,dbase, bplot,xl,binsize);

% escapes:pauses
t.escpausestarts = vgm_MakeTrigInfoFlex(esctrigger, events_pausestarts, exclude,dbase, bplot,xl,binsize);
t.escpausestops = vgm_MakeTrigInfoFlex(esctrigger, events_pausestops, exclude,dbase, bplot,xl,binsize);

% others:pauses
t.otherpausestarts = vgm_MakeTrigInfoFlex(othertrigger, events_pausestarts, exclude_other,dbase, bplot,xl,binsize);
t.otherpausestops = vgm_MakeTrigInfoFlex(othertrigger, events_pausestops, exclude_other,dbase, bplot,xl,binsize);

hit.burstonsets.events = t.hitburstonsets.events;
hit.burstonsets.trigStarts = t.hitburstonsets.trigStarts;
hit.burstoffsets.events = t.hitburstoffsets.events;
esc.burstonsets.events = t.escburstonsets.events;
esc.burstonsets.trigStarts = t.escburstonsets.trigStarts;
esc.burstoffsets.events = t.escburstoffsets.events;
other.burstonsets.events = t.otherburstonsets.events;
other.burstonsets.trigStarts = t.otherburstonsets.trigStarts;
other.burstoffsets.events = t.otherburstoffsets.events;
hit.burstonsets.time = winsize*length(t.hitburstonsets.events);
esc.burstonsets.time = winsize*length(t.escburstonsets.events);
other.burstonsets.time = winsize*length(t.otherburstonsets.events);

hit.pausestarts.events = t.hitpausestarts.events;
hit.pausestarts.trigStarts = t.hitpausestarts.trigStarts;
hit.pausestops.events = t.hitpausestops.events;
esc.pausestarts.events = t.escpausestarts.events;
esc.pausestarts.trigStarts = t.escpausestarts.trigStarts;
esc.pausestops.events = t.escpausestops.events;
other.pausestarts.events = t.otherpausestarts.events;
other.pausestarts.trigStarts = t.otherpausestarts.trigStarts;
other.pausestops.events = t.otherpausestops.events;
hit.pausestarts.time = winsize*length(t.hitpausestarts.events);
esc.pausestarts.time = winsize*length(t.escpausestarts.events);
other.pausestarts.time = winsize*length(t.otherpausestarts.events);

allburstonsets = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctileburst)]).burstonsets);
allburstoffsets = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctileburst)]).burstoffsets);

allpausestarts = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctilepause)]).pausestarts);
allpauseends = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctilepause)]).pausestops);
allpausedurs = concatenate(dbase.BurstAnalysis.(['p' num2str(Prctilepause)]).pausedurs);

% calculate burst and pause values for the windows after hits
for j = 1:length(hit.burstonsets.events)
    hit.nburstonsets(j) = length(hit.burstonsets.events{j});
    hit.nburstoffsets(j) = length(hit.burstoffsets.events{j});
    if hit.nburstonsets(j) == 0 && hit.nburstoffsets(j) == 0
        if any(allburstonsets - (hit.burstonsets.trigStarts(j)-xl) < 0 &...
            allburstoffsets - (hit.burstonsets.trigStarts(j)+xl) > 0)
            hit.burstflank(j) = 1;
        else
            hit.burstflank(j) = 0;
        end
    else
        hit.burstflank(j) = 0;
    end
end
hit.pburst = sum(hit.nburstonsets ~= 0 | hit.nburstoffsets ~= 0 | hit.burstflank ~= 0)/length(hit.burstonsets.events);    


for j = 1:length(hit.pausestarts.events)
    hit.npausestarts(j) = length(hit.pausestarts.events{j});
    hit.npauseends(j) = length(hit.pausestops.events{j});
    if hit.npausestarts(j) == 0 && hit.npauseends(j) == 0
        if any(allpausestarts - (hit.pausestarts.trigStarts(j)-xl) < 0 &...
            allpauseends - (hit.pausestarts.trigStarts(j)+xl) > 0)
            hit.pauseflank(j) = 1;
        else
            hit.pauseflank(j) = 0;
        end
    else
        hit.pauseflank(j) = 0;
    end
end
hit.ppause = sum(hit.npausestarts ~= 0 | hit.npauseends ~= 0 | hit.pauseflank ~= 0)/length(hit.pausestarts.events);

% calculation of median longest pause in hit windows
spiketimes = concatenate(dbase.spiketimes);
ht = hit.pausestarts.trigStarts;
for j = 1:length(ht)
    ind_middle = find(spiketimes > ht(j)-xl & spiketimes < ht(j)+xl);
    ind_left = find(spiketimes < ht(j)-xl, 1, 'last');
    ind_right = find(spiketimes > ht(j)+xl, 1, 'first');
    ind = [ind_left ind_middle ind_right];
    tempspiketimes = spiketimes(ind);
    tempisi = diff(tempspiketimes);
    maxpause(j) = max(tempisi); 
end
medlgstpause = median(maxpause);
if length(dbase.ISI.nonsong) > 100
    prc_medlgstpause = 100*sum(nonsong.isi<medlgstpause)/length(nonsong.isi);
else
    prc_medlgstpause = 100*sum(interbout.isi<medlgstpause)/length(interbout.isi);
end
hit.medlgstpause = medlgstpause;
hit.prc_medlgstpause = prc_medlgstpause;


% calculate burst and pause values for the windows after escapes
for j = 1:length(esc.burstonsets.events)
    esc.nburstonsets(j) = length(esc.burstonsets.events{j});
    esc.nburstoffsets(j) = length(esc.burstoffsets.events{j});
    if esc.nburstonsets(j) == 0 && esc.nburstoffsets(j) == 0
        if any(allburstonsets - (esc.burstonsets.trigStarts(j)-xl) < 0 &...
            allburstoffsets - (esc.burstonsets.trigStarts(j)+xl) > 0)
            esc.burstflank(j) = 1;
        else
            esc.burstflank(j) = 0;
        end
    else
        esc.burstflank(j) = 0;
    end
end
esc.pburst = sum(esc.nburstonsets ~= 0 | esc.nburstoffsets ~= 0 | esc.burstflank ~= 0)/length(esc.burstonsets.events);    


for j = 1:length(esc.pausestarts.events)
    esc.npausestarts(j) = length(esc.pausestarts.events{j});  
    esc.npauseends(j) = length(esc.pausestops.events{j}); 
    if esc.npausestarts(j) == 0 && esc.npauseends(j) == 0
        if any(allpausestarts - (esc.pausestarts.trigStarts(j)-xl) < 0 &...
            allpauseends - (esc.pausestarts.trigStarts(j)+xl) > 0)
            esc.pauseflank(j) = 1;
        else
            esc.pauseflank(j) = 0;
        end
    else
        esc.pauseflank(j) = 0;
    end
end
esc.ppause = sum(esc.npausestarts ~= 0 | esc.npauseends ~= 0 | esc.pauseflank ~= 0)/length(esc.pausestarts.events);


% calculate burst and pause values for the windows for others
for j = 1:length(other.burstonsets.events)
    other.nburstonsets(j) = length(other.burstonsets.events{j});
    other.nburstoffsets(j) = length(other.burstoffsets.events{j});
    if other.nburstonsets(j) == 0 && other.nburstoffsets(j) == 0
        if any(allburstonsets - (other.burstonsets.trigStarts(j)-xl) < 0 &...
            allburstoffsets - (other.burstonsets.trigStarts(j)+xl) > 0)
            other.burstflank(j) = 1;
        else
            other.burstflank(j) = 0;
        end
    else
        other.burstflank(j) = 0;
    end
end
other.pburst = sum(other.nburstonsets ~= 0 | other.nburstoffsets ~= 0 | other.burstflank ~= 0)/length(other.burstonsets.events);    

for j = 1:length(other.pausestarts.events)
    other.npausestarts(j) = length(other.pausestarts.events{j}); 
    other.npauseends(j) = length(other.pausestops.events{j}); 
    if other.npausestarts(j) == 0 && other.npauseends(j) == 0
        if any(allpausestarts - (other.pausestarts.trigStarts(j)-xl) < 0 &...
            allpauseends - (other.pausestarts.trigStarts(j)+xl) > 0)
            other.pauseflank(j) = 1;
        else
            other.pauseflank(j) = 0;
        end
    else
        other.pauseflank(j) = 0;
    end
end
other.ppause = sum(other.npausestarts ~= 0 | other.npauseends ~= 0 | other.pauseflank ~= 0)/length(other.pausestarts.events);

% bootstrap to calculate if probability of bursting after escapes is
% significantly higher than during other parts of the song

count = 0;
N = 10000;
Nesc = length(esc.burstonsets.events);
Nother = length(other.burstonsets.events);
for i = 1:N
    ind_rand = randi(Nother,1,Nesc);
    
    p_rand = sum(other.nburstonsets(ind_rand) ~= 0 | other.nburstoffsets(ind_rand) ~= 0 | other.burstflank(ind_rand) ~= 0)/Nesc;    
    if esc.pburst <= p_rand
        count = count+1;
    end
end
esc.pval = count/N;

% bootstrap to calculate if probability of pausing after hits is
% significantly higher than during other parts of the song

count = 0;
N = 1000;
Nhit = length(hit.pausestarts.events);
Nother = length(other.pausestarts.events);
for i = 1:N
    ind_rand = randi(Nother,1,Nhit);
    p_rand = sum(other.npausestarts(ind_rand) ~= 0 | other.npauseends(ind_rand) ~= 0 | other.pauseflank(ind_rand) ~= 0)/Nhit;
    if hit.ppause <= p_rand
        count = count+1;
    end
end
hit.pval = count/N;

% transfer the calculated values to dbase.BurstAnalysis for output
dbase.BurstAnalysis.(['p' num2str(prc)]).Prctileburst = Prctileburst;
dbase.BurstAnalysis.(['p' num2str(prc)]).Prctilepause = Prctilepause;
dbase.BurstAnalysis.(['p' num2str(prc)]).threshburst = threshburst;
dbase.BurstAnalysis.(['p' num2str(prc)]).threshpause = threshpause;
dbase.BurstAnalysis.(['p' num2str(prc)]).nonsong = nonsong;
dbase.BurstAnalysis.(['p' num2str(prc)]).interbout = interbout;
dbase.BurstAnalysis.(['p' num2str(prc)]).bout = bout;
dbase.BurstAnalysis.(['p' num2str(prc)]).boutnohitesc = boutnohitesc;
dbase.BurstAnalysis.(['p' num2str(prc)]).outsong = outsong;
dbase.BurstAnalysis.(['p' num2str(prc)]).hit = hit;
dbase.BurstAnalysis.(['p' num2str(prc)]).esc = esc;
dbase.BurstAnalysis.(['p' num2str(prc)]).other = other;
end





