function [dbase]=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif)

%This function takes dbase and generates (and saves) trigInfo file for all motifs within that dbase.

%MAKE SURE THAT MOTIF DURATION IS LESS THAN presyll
bplot=1;
binsize=.025;
% binsize=.01; % variable
minmotifnum=5;%min # of motifs to do trigInfo analysis
spiketimes=dbase.spiketimes;
presyll=.3;%the xlim before the non warped motif onset and after nonwarped motif offset in seconds
%first not warped
for m=1:size(motif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif{m});
    trigInfo.dataStart{1}=-presyll;
    trigInfo.motif=motif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    acceptmaxdur=trigInfo.allmotifdurs(find(trigInfo.allmotifdurs<(1/.7)*motifdur));
    trigInfo.dataStop{1}=floor(100*(max(acceptmaxdur)+presyll))/100;%integer multiple of binsize
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
                    trigInfo.motifstarts(count)=motifstarts{i}(j);
                    trigInfo.motifends(count)=motifends{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-presyll & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);

                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes;
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
    dbase.trigInfomotif{m}.notwarped=trigInfo;
    if count>minmotifnum;
        % [dbase.trigInfomotif{m}]=vg_dbaseMonteCarloMotifCorrRate(trigInfo,bplot);
    end
end

%xlim pre and post for the non-warped

%now warp below
for m=1:size(motif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif{m});
    trigInfo.dataStart{1}=-presyll;
    trigInfo.motif=motif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    trigInfo.dataStop{1}=floor(100*(median(trigInfo.allmotifdurs)+presyll+binsize))/100;%integer multiple of binsize
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
                    trigInfo.warp(count)=warp;
                    trigInfo.motifstarts(count)=motifstarts{i}(j);
                    trigInfo.motifends(count)=motifends{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-presyll & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes*warp;%this is the warp correction
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
    dbase.trigInfomotif{m}.warped=trigInfo;
    if count>minmotifnum;
%          [dbase.trigInfomotif{m}]=vg_dbaseMonteCarloMotifCorrRate(trigInfo,bplot);
    end

end

%Now for fdbkmotif
presyll=.3;%the xlim before the non warped motif onset and after nonwarped motif offset in seconds
for m=1:size(fdbkmotif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, fdbkmotif{m});
    trigInfo.dataStart{1}=-presyll;
    if m == 2
        trigInfo.dataStart{1}=-0.5;
    end
    presyll = -trigInfo.dataStart{1};
    trigInfo.motif=fdbkmotif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    acceptmaxdur=trigInfo.allmotifdurs(find(trigInfo.allmotifdurs<(1/.7)*motifdur));
    trigInfo.dataStop{1}=floor(100*(max(acceptmaxdur)+presyll))/100;%integer multiple of binsize
    if m == 2
        trigInfo.dataStop{1}=0.5;
    end
    
        
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
                    trigInfo.motifstarts(count)=motifstarts{i}(j);
                    trigInfo.motifends(count)=motifends{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-presyll & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);

                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes;
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
    dbase.trigInfofdbkmotif{m}.notwarped=trigInfo;
    if count>minmotifnum;
        % [dbase.trigInfomotif{m}]=vg_dbaseMonteCarloMotifCorrRate(trigInfo,bplot);
    end
end

%xlim pre and post for the non-warped
presyll=.3;
%now warp below
for m=1:size(fdbkmotif,2)
    clear trigInfo;
    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, fdbkmotif{m});

    trigInfo.dataStart{1}=-presyll;
    if m == 2
        trigInfo.dataStart{1}=-0.5;
    end
    presyll = -trigInfo.dataStart{1};
    trigInfo.motif=fdbkmotif{m};
    trigInfo.allmotifdurs=concatenate(motifdurs);
    motifdur=median(trigInfo.allmotifdurs);
    trigInfo.dataStop{1}=floor(100*(median(trigInfo.allmotifdurs)+presyll+binsize))/100;%integer multiple of binsize
    if m == 2
        trigInfo.dataStop{1}=0.5;
    end
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
                    trigInfo.warp(count)=warp;
                    trigInfo.motifstarts(count)=motifstarts{i}(j);
                    trigInfo.motifends(count)=motifends{i}(j);
                    trigInfo.currTrigOffset(count)=motifends{i}(j)-motifstarts{i}(j);
                    tempsyllspiketimes=spiketimes{i}(find(spiketimes{i}>motifstarts{i}(j)-presyll & spiketimes{i}<motifstarts{i}(j)+postsyll));
                    tempsyllspiketimes= tempsyllspiketimes-motifstarts{i}(j);
                    trigInfo.motifdurs(count)=motifends{i}(j)-motifstarts{i}(j);
                    trigInfo.eventOnsets{1}{count}=tempsyllspiketimes*warp;%this is the warp correction
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
    dbase.trigInfofdbkmotif{m}.warped=trigInfo;
    if count>minmotifnum;
%          [dbase.trigInfomotif{m}]=vg_dbaseMonteCarloMotifCorrRate(trigInfo,bplot);
    end
end
dbase.motif=motif;
dbase.fdbkmotif=fdbkmotif;
