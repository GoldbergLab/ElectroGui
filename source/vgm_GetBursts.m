function [dbase]=vgm_GetBursts(dbase,prc)

%this fucntion gets bursts onsets and offsets via threshold crossings.
%not 100% sure that works with the pad at the end

if length(dbase.ISI.nonsong) > 100
    thres = prctile(dbase.ISI.nonsong,prc);   %define burst
else
    thres = prctile(dbase.ISI.interbout,prc);   %define burst   
end

% thres=prctile(dbase.allnonISI,prc);
data=[];

spiketimes=dbase.spiketimes;
for j=1:length(spiketimes)
    data=[thres+.001 diff(spiketimes{j}) thres+.001];%pad the diff(spks) with vals>thres to ensure =#brst.strts&stops
    onsetndx = find(data(1:end-1)>thres & data(2:end)<=thres);
    offsetndx = find(data(1:end-1)<=thres & data(2:end)>thres);
    
    burstonsets{j}=spiketimes{j}(onsetndx);
    burstoffsets{j}=spiketimes{j}(offsetndx);
    datas{j}=data;
    
    tbspks=[];
    for i=1:length(onsetndx)
        tempbspks=spiketimes{j}(onsetndx(i):offsetndx(i));
        tbspks=[tbspks tempbspks];
    end
    bspks{j}=tbspks;
end


dbase.BurstAnalysis.(['p' num2str(prc)]).burstspiketimes=bspks;
dbase.BurstAnalysis.(['p' num2str(prc)]).burstonsets=burstonsets;
dbase.BurstAnalysis.(['p' num2str(prc)]).burstoffsets=burstoffsets;
dbase.BurstAnalysis.(['p' num2str(prc)]).burstthres=thres;
end