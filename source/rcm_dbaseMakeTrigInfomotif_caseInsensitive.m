function [dbase]=rcm_dbaseMakeTrigInfomotif_caseInsensitive(dbase,motif)

%This function takes dbase and generates (and saves) trigInfo file for all motifs within that dbase.

%MAKE SURE THAT MOTIF DURATION IS LESS THAN presyll
% bplot=1;
binsize=.004;
minmotifnum=1;%min # of motifs to do trigInfo analysis
spiketimes=dbase.spiketimes;
perimotif=0.3;%the xlim before the non warped motif onset and after nonwarped motif offset in seconds
dbase.trigInfomotifCaseI = {};
dbase.trigInfomotifCaseI.warped = {};
dbase.trigInfomotifCaseI.notwarped = {};

%first not warped
for m=1:size(motif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = rc_dbaseGetNamedMotifs_caseInsensitive(dbase, motif{m});
    trigInfo.dataStart{1}=-perimotif;
    trigInfo.motif=motif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    acceptmaxdur=trigInfo.allmotifdurs(find(trigInfo.allmotifdurs<(1/.7)*motifdur));
    trigInfo.dataStop{1}=floor(100*(max(acceptmaxdur)+perimotif))/100;%integer multiple of binsize
    postsyll=trigInfo.dataStop{1};
    edges=[trigInfo.dataStart{1}:binsize:trigInfo.dataStop{1}];
    count=0;rdmat=[];
    for i=1:length(dbase.Times)
        if ~isempty(motifstarts{i}) && ~isempty(spiketimes{i})
            for j=1:length(motifstarts{i})
                thismotifdur=motifends{i}(j)-motifstarts{i}(j);
                warp=(motifdur/thismotifdur);
                if warp>0.7 && warp<1/.7
                    count=count+1;
                    trigInfo.filemotifnum{count} = [i,j];
                    trigInfo.motifstart(count) = motifstarts{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-perimotif & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);
                    tempfdbktimes = dbase.fdbktimes{i};
                    tempfdbktimes = tempfdbktimes(find(tempfdbktimes>motifstarts{i}(j)-perimotif & tempfdbktimes<motifstarts{i}(j)+postsyll));
                    tempfdbktimes = tempfdbktimes-motifstarts{i}(j);
                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes;
                    trigInfo.fdbkOnsets{1}{count} = tempfdbktimes;
                    temprd=histc(trigInfo.eventOnsets{1}{count},edges);
                    rdmat=[rdmat;temprd];
                end
            end
        end
    end
    rd=mean(rdmat)/binsize;%gives rate histogram
    rd=rd(1:end-1);
    rdstd=std(rdmat)/binsize;
    rdstd=rdstd(1:end-1);
    %convert std to standard error
    rdste=rdstd/sqrt(size(rdmat,1));
    trigInfo.edges=edges(1:end-1);
    trigInfo.rd=rd;
    trigInfo.rdmat = rdmat;
%     dbase.trigInfomotif{i_trigInfo}.notwarped = trigInfo;
    if count>minmotifnum
        i_trigInfo = length(dbase.trigInfomotifCaseI.notwarped)+1;
        trigInfo = rcm_dbaseSpikeTrainMotifPowerSpectrum(trigInfo,0);
        %trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
        %trigInfo = rc_dbaseTargetTimeAnalysis(dbase,trigInfo);
        dbase.trigInfomotifCaseI.notwarped{i_trigInfo} = rc_dbaseMonteCarloCorr_spiketrain(trigInfo);
    end
end

%xlim pre and post for the non-warped

%now warp below
for m=1:size(motif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = rc_dbaseGetNamedMotifs_caseInsensitive(dbase, motif{m});
    trigInfo.dataStart{1}=-perimotif;
    trigInfo.motif=motif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    trigInfo.warpedDur = motifdur;
    trigInfo.dataStop{1}=floor(100*(median(trigInfo.allmotifdurs)+perimotif+binsize))/100;%integer multiple of binsize
    edges=[trigInfo.dataStart{1}:binsize:trigInfo.dataStop{1}];
    postsyll=trigInfo.dataStop{1};
    count=0;rdmat=[];
    for i=1:length(dbase.Times)
        if ~isempty(motifstarts{i}) && ~isempty(spiketimes{i})
            for j=1:length(motifstarts{i})
                thismotifdur=motifends{i}(j)-motifstarts{i}(j);
                warp=(motifdur/thismotifdur);
                if warp>0.7 && warp<1/.7
                    count=count+1;
                    trigInfo.filemotifnum{count} = [i,j];
                    trigInfo.motifstart(count) = motifstarts{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-perimotif & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);
                    tempfdbktimes = dbase.fdbktimes{i};
                    tempfdbktimes = tempfdbktimes(find(tempfdbktimes>motifstarts{i}(j)-perimotif & tempfdbktimes<motifstarts{i}(j)+postsyll));
                    tempfdbktimes = tempfdbktimes-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes*warp;%this is the warp correction
                    trigInfo.fdbkOnsets{1}{count} = tempfdbktimes*warp;                   
                    temprd=histc(trigInfo.eventOnsets{1}{count},edges);
                    rdmat=[rdmat;temprd];
                end
            end
        end
    end
    rd=mean(rdmat)/binsize;%gives rate histogram
    rd=rd(1:end-1);
    rdstd=std(rdmat)/binsize;
    rdstd=rdstd(1:end-1);
    %convert std to standard error
    rdste=rdstd/sqrt(size(rdmat,1));
    trigInfo.edges=edges(1:end-1);
    trigInfo.rd=rd;
    trigInfo.rdmat = rdmat;
    if count>minmotifnum
        i_trigInfo = length(dbase.trigInfomotifCaseI.warped)+1;
        %trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
        trigInfo = rcm_dbaseSpikeTrainMotifPowerSpectrum(trigInfo,0);
        %trigInfo = rc_dbaseTargetTimeAnalysis(dbase,trigInfo);
        dbase.trigInfomotifCaseI.warped{i_trigInfo} = rc_dbaseMonteCarloCorr_spiketrain(trigInfo);
    end
end

%% find out highest crosscorr in WARPED triginfos
% warped
% max_crosscorr = -1;
% dbase.motifcc.i_trig = 1;
% for i_trig = 1:length(dbase.trigInfomotif.notwarped)
%     trigInfo = dbase.trigInfomotif.notwarped{i_trig};
%     if mean(trigInfo.spikecc20)>max_crosscorr
%         max_crosscorr = mean(trigInfo.spikecc20);
%         dbase.motifcc.motif = trigInfo.motif;
%         dbase.motifcc.i_trig = i_trig;
%     end
% end
% dbase.motifcc.cc20 = max_crosscorr;
% if max_crosscorr == -1
%     disp([dbase.title ' warped, has crosscorr val of -1?']);
% end
% 
% % not warped
% max_crosscorr = -1;
% dbase.motifcc.notwarped.i_trig = 1;
% for i_trig = 1:length(dbase.trigInfomotif.notwarped)
%     trigInfo = dbase.trigInfomotif.notwarped{i_trig};
%     if mean(trigInfo.notwarped.spikecc20)>max_crosscorr
%         max_crosscorr = mean(trigInfo.notwarped.spikecc20);
%         dbase.motifcc.notwarped.motif = trigInfo.motif;
%         dbase.motifcc.notwarped.i_trig = i_trig;
%     end
% end
% dbase.motifcc.notwarped.cc20 = max_crosscorr;
% if max_crosscorr == -1
%     disp([dbase.title ' not warped, has crosscorr val of -1?']);
% end
