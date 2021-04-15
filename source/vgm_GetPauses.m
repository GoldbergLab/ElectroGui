function [dbase]=vgm_GetPauses(dbase,prc)

%[pauseintrvl]=GetPauseIntrvlPrctile(spiketimes, percentileISI); if you
%want to choose your pauseintrvl based on the "percentileISI" of the ISI
%distribution (ie if you want the 95th percentile of the long ISIs.)

if length(dbase.ISI.nonsong) > 100
    pausedef = prctile(dbase.ISI.nonsong,prc);   %define pause
else
    pausedef = prctile(dbase.ISI.interbout,prc);   %define pause  
end

% pausedef=prctile(dbase.allnonISI,prc);

spiketimes=dbase.spiketimes;
for j=1:length(spiketimes)
    for i=1:length(dbase.spiketimes{j})
        if length(dbase.spiketimes{j})>2
            pausestarts{j}=spiketimes{j}(find(diff(spiketimes{j})>pausedef));
            pausestops{j}=spiketimes{j}(1+find(diff(spiketimes{j})>pausedef));
        end
        pausedurs{j}=pausestops{j}-pausestarts{j};
    end
end

dbase.BurstAnalysis.(['p' num2str(prc)]).pausestarts=pausestarts;
dbase.BurstAnalysis.(['p' num2str(prc)]).pausestops=pausestops;
dbase.BurstAnalysis.(['p' num2str(prc)]).pausedurs=pausedurs;
dbase.BurstAnalysis.(['p' num2str(prc)]).pausedef=pausedef;

end

