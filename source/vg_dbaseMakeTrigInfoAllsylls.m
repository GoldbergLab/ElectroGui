function [dbase]=vg_dbaseMakeTrigInfoAllsylls(dbase,bplot);



minsyllnum=5;%min # of sylls to do trigInfo analysis
presyll=.5;%the xlim +/- syll onset
bwarp=0;

[dbase excludedfiles]=dbaseExcludeDatada(dbase);
[spiketimes]=dbaseGetRaster(dbase, dbase.indx);
allsylls=unique(concatenate(concatenate(dbase.SegmentTitles)));
for s=1:length(allsylls);
    clear trigInfo;trigInfo.title=dbase.title;trigInfo.dataStop{1}=presyll;trigInfo.dataStart{1}=-presyll;
    if ~isfield(dbase, 'boutISI');[trigInfo.boutISI]=dbaseBoutNonsongISI(dbase, 0, 0, 0, dbase.indx);else; trigInfo.boutISI=dbase.boutISI;end

    if length(find(concatenate(concatenate(dbase.SegmentTitles))==allsylls(s)))>=minsyllnum;
        trigInfo.trigOptions.includeSyllList=allsylls(s);
        [namedsyllstarttimes namedsyllendtimes namedsyll_durs] = dbaseGetNamedSylls(dbase, allsylls(s));
        syllspiketimes=[];tempsyllspiketimes=[];count=0;sylldur=median(concatenate(namedsyll_durs));

        for i=1:length(dbase.Times)
            if ~isempty(namedsyllstarttimes{i}) && ~isempty(spiketimes{i})
                for j=1:length(namedsyllstarttimes{i})
                    count=count+1;
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>namedsyllstarttimes{i}(j)-presyll & spiketimes{i}<namedsyllstarttimes{i}(j)+presyll));
                    tempsyllspiketimes= tempsyllspiketimes-namedsyllstarttimes{i}(j);
                    trigInfo.currTrigOffset(count)=namedsyllendtimes{i}(j)-namedsyllstarttimes{i}(j);

                    if bwarp;warpval=(sylldur/trigInfo.currTrigOffset(count));tempsyllspiketimes=(tempsyllspiketimes*warpval);end

                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes;
                end
            end
        end
        if count>minsyllnum;
            [dbase.trigInfosyll{s}]=V_dbaseMonteCarloSyllCorrRatePlastic(trigInfo, bplot);
            %[dbase.sylltrigInfo{s}]=dbaseMonteCarloMotifCorr_IFR_Plastic(trigInfo);
            rmfield(dbase.trigInfosyll{s},'boutISI');
        end
    end

end
dbase.allsylls=allsylls;
