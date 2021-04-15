function [trigInfo]=vg_dbaseMonteCarloMotifCorrRate(trigInfo, bplot1);

% %this function quantiifes the p value of correlation of PSTH of
% %spikes/bursts/pauses with certain syll.  may be useful to use
% %with sorted rasters matlab exprort-->triginfo.

bshuff=1;
binsize=.01;
numshuff=100;
syllname=trigInfo.motif;
dur.stop=trigInfo.dataStop{1};
dur.start=trigInfo.dataStart{1};
dur.dur=dur.stop-dur.start;
dur.warpstop=2*abs(trigInfo.dataStart{1})+floor(100*median(trigInfo.motifdurs))/100;

sylldur=median(trigInfo.currTrigOffset);%burstISI=y(1);pauseISI=y(2);

for bWarp=[0 1];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Generate Real Data (rd) Histograms
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    edges=[dur.start:binsize:dur.stop];rdmat=[];count=0;
    sylledges=edges(1:end-1);
    warpedges=[dur.start:binsize:dur.warpstop];
    for i=1:length(trigInfo.eventOnsets{1})
        spks{i}=trigInfo.eventOnsets{1}{i};
        warp=(sylldur/trigInfo.currTrigOffset(i));
        if warp>0.7 && warp<1/.7 %&& warp*dur.dur/2>sylldur% && ~isempty(spks{i}) &&
            %compute IFR for full duration of each rendition
            warpval(i)=(sylldur/trigInfo.currTrigOffset(i));
            if bWarp;
                spks{i}=spks{i}*warpval(i);
                temprd=histc(spks{i},warpedges);zz=size(temprd);
            else
                temprd=histc(spks{i},edges);zz=size(temprd);
                %                 if zz(1)>zz(2);temprd=temprd';end;
            end
            rdmat=[rdmat;temprd];
            count=count+1;%count is sylls w/o spks
        end
    end
    if isempty(rdmat);rdmat=zeros(i,length(edges));end
    rd=mean(rdmat)/binsize;%gives rate histogram
    rd=rd(1:end-1);
    rdstd=std(rdmat)/binsize;
    rdstd=rdstd(1:end-1);
    %convert std to standard error
    rdste=rdstd/sqrt(size(rdmat,1));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Generate shuffled histograms

    tempstdev2=[];
    %         if ~isfield(trigInfo,'shuffmeanrate') && bshuff;

    ratemin=[];ratemax=[];%fd for "fake data"
    if bshuff;
        for r=1:numshuff

            fdmat=[];phaseshifts=dur.dur*rand(1,length(trigInfo.eventOnsets{1}));
            %fake data rate histogram
            spks=[];fd=0;
            for i=1:length(trigInfo.eventOnsets{1})% i is looping through each row of raster
                if warpval(i)>0.7 && warpval(i)<1/.7;
                    tmpspks=trigInfo.eventOnsets{1}{i};
                    if ~isempty(tmpspks);
                        tmpspks=tmpspks+phaseshifts(i);
                        tmpspks(find(tmpspks>dur.stop))=sort(tmpspks(find(tmpspks>dur.stop))-dur.dur);%wrap around
                        tempfd=histc(tmpspks,edges);
                        fd=fd+tempfd';%add up all the rows to get the fake histogram for this shuffnum
                    end
                end
            end
            fd=(fd/(length(phaseshifts)))/binsize;%gives rate histogram (count is sylls w/o spks)

            %Get mins and maxes of rates, burstonsets and pauseonsets for present
            %random rendition
            if fd==0;fd=zeros(1,length(rd));end
            ratemin=[ratemin min(fd(1:end-1))];%ratemin is the min of each of the shuffled hists
            ratemax=[ratemax max(fd(1:end-1))];%ratemax is the max of each of the shuffled hists
        end

        trigInfo.shuffled.ratemin=ratemin;
        trigInfo.shuffled.ratemax=ratemax;

    end

    %For min and max (1 of each)
    if ~isempty(rd)
        pval.minrate=mean(ratemin<min(rd));%mean of 0s and 1s will yield the pvalue.
        pval.maxrate=mean(ratemax>max(rd));
        [yo ndx.min]=min(rd);
        [yo ndx.max]=max(rd);
        corrtime.min=edges(ndx.min);
        corrtime.max=edges(ndx.max);




        trigInfo.edges=edges(1:end-1);trigInfo.rd=rd;trigInfo.rdstd=rdstd;


        %eliminate min/max corrtimes if p>.05
        if pval.minrate>.05;corrtime.min=[];end
        if pval.maxrate>.05;corrtime.max=[];end

        if bWarp;
            trigInfo.warped.pval.minrate=pval.minrate;
            trigInfo.warped.pval.maxrate=pval.maxrate;
            trigInfo.warped.corrtime=corrtime;
            trigInfo.warped.meanrate=rd;
            trigInfo.warped.edges=edges(1:end-1);

        else
            trigInfo.notwarped.pval.minrate=pval.minrate;
            trigInfo.notwarped.pval.maxrate=pval.maxrate;
            trigInfo.notwarped.corrtime=corrtime;
            trigInfo.notwarped.meanrate=rd;
            trigInfo.notwarped.edges=edges(1:end-1);
        end
    else
        trigInfo.warped.meanrate=zeros(1,length(edges)-1);
    end
end
end
