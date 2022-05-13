function [dbase]=dbaseMakeTrigInfoEntropySparsenessM(dbase);

%This function takes dbase and generates trigInfo file for all
%sylls within that dbase and computes entroyp sparseness across all sylls

%Make sure presyll > sylldur (so if you're doing motif presyll should be
%large
presyll=.06;%the xlim +/- syll onset
bpo=0;%this will add the lags computed for bence's spikewarping
if bpo; load('C:\Users\jesseg1\Desktop\Bence\lag.mat');
    
    for y=1:10;
        if strcmp(dbase.title, lag.name{y});
            trigInfo.bencelag=lag.shifts{y}/1000;                       
        end
    end    
end;

trigInfo.presyll=presyll;
count=0;minsyllnum=3;entropy.allpsth=[];
[dbase excludedfiles]=dbaseExcludeDatada(dbase);
[spiketimes]=dbaseGetRaster(dbase, dbase.indx);
allsylls=unique(concatenate(concatenate(dbase.SegmentTitles)));
for s=1:length(allsylls);
    if length(find(concatenate(concatenate(dbase.SegmentTitles))==allsylls(s)))>=minsyllnum;
        count=count+1;
        trigInfo.title=dbase.title;
        %min # of sylls to do trigInfo analysis
        
        trigInfo.eventOnsets{1}=[];
        trigInfo.currTrigOffset=[];
        trigInfo.trigOptions.includeSyllList=allsylls(s);
        [namedsyllstarttimes namedsyllendtimes namedsyll_durs] = dbaseGetNamedSylls(dbase, allsylls(s));
        syllspiketimes=[];tempsyllspiketimes=[];countSylls=0;%???????
        for i=1:length(dbase.Times)
            if ~isempty(namedsyllstarttimes{i}) && ~isempty(spiketimes{i})
                for j=1:length(namedsyllstarttimes{i})
                    countSylls=countSylls+1;
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>namedsyllstarttimes{i}(j)-presyll & spiketimes{i}<namedsyllendtimes{i}(j)+presyll));
                    trigInfo.eventOnsets{1}{countSylls}=tempsyllspiketimes-namedsyllstarttimes{i}(j);
                    trigInfo.currTrigOffset(countSylls)=namedsyllendtimes{i}(j)-namedsyllstarttimes{i}(j);
                end
            end
        end
        
        trigInfo.dataStop{1}=presyll+max(concatenate(namedsyll_durs));
        trigInfo.dataStart{1}=-presyll;
        
        if bpo
            for i=1:length(trigInfo.bencelag);
                trigInfo.eventOnsets{1}{i}=trigInfo.eventOnsets{1}{i}+trigInfo.bencelag(i);
            end
        end
        [trigInfo]=dbaseMonteCarloSyllCorrRatePlastic(trigInfo, 0);
        entropy.psth{s}=trigInfo.warped.meanrate(7:end-1);
        entropy.allpsth=[entropy.allpsth entropy.psth{s}];
    end
end
if count>1
    p=entropy.allpsth/sum(entropy.allpsth);
    e=0;
    for i=1:length(p);
        if p(i)~=0;
            e=e+p(i)*log10(p(i));
        end
    end
    entropy.allpsthnl=p;
    entropy.sparsendx=1+e/log10(length(p));
    dbase.entropy3ms=entropy;
    
end

end


