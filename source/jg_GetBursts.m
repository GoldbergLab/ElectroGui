function [dbase]=jg_GetBursts(dbase,prct);

%this fucntion gets bursts onsets and offsets via threshold crossings.
%not 100% sure that works with the pad at the end

thres=prctile(dbase.allnonISI,prct);
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


dbase.burstspiketimes=bspks;
dbase.burstonsets=burstonsets;
dbase.burstoffsets=burstoffsets;
dbase.burstthres=thres;