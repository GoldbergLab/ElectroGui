function [dbase]=jg_GetPauses(dbase,prct);

%[pauseintrvl]=GetPauseIntrvlPrctile(spiketimes, percentileISI); if you
%want to choose your pauseintrvl based on the "percentileISI" of the ISI
%distribution (ie if you want the 95th percentile of the long ISIs.)

pausedef=prctile(dbase.allnonISI,prct);
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

dbase.pausestarts=pausestarts;
dbase.pausestops=pausestops;
dbase.pausedurs=pausedurs;
dbase.pausedef=pausedef;

