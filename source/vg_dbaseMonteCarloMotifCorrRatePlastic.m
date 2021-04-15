function [trigInfo]=vg_dbaseMonteCarloMotifCorrRatePlastic(trigInfo, presyll,bplot1);

% %this function quantiifes the p value of correlation of PSTH of
% %spikes/bursts/pauses with certain syll.  may be useful to use
% %with sorted rasters matlab exprort-->triginfo.
bshuff=1;
binsize=.01;
numshuff=1000;
syllname=trigInfo.trigOptions.includeSyllList;
dur.stop=trigInfo.dataStop{1};
dur.start=trigInfo.dataStart{1};
dur.dur=dur.stop-dur.start;
dur.warpstop=abs(trigInfo.dataStart{1})+floor(100*median(trigInfo.motifdurs))/100;

sylldur=median(trigInfo.currTrigOffset);%burstISI=y(1);pauseISI=y(2);

for bWarp=[0 1];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Generate Real Data (rd) Histograms
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    edges=[dur.start:binsize:dur.stop];rdmat=[];count=0;
    warpedges=[dur.start:binsize:dur.warpstop];
    for i=1:length(trigInfo.eventOnsets{1})
        spks{i}=trigInfo.eventOnsets{1}{i};
        warp=(sylldur/trigInfo.currTrigOffset(i));
        if warp>0.7 && warp<1/.7 %&& warp*dur.dur/2>sylldur% && ~isempty(spks{i}) &&
            %compute IFR for full duration of each rendition
            if bWarp;
                warpval(i)=(sylldur/trigInfo.currTrigOffset(i));
                spks{i}=spks{i}*warpval(i);
                temprd=histc(spks{i},warpedges);zz=size(temprd);
            else
                temprd=histc(spks{i},edges);zz=size(temprd);
                if zz(1)>zz(2);temprd=temprd';end;
                rdmat=[rdmat;temprd];
            else
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
        if bshuff;
            fdmat=[];phaseshifts=dur.dur*rand(1,length(trigInfo.eventOnsets{1}));
            for r=1:numshuff
                warp=(sylldur/trigInfo.currTrigOffset(i));
                if warp>0.7 && warp<1/.7
                    %fake data rate histogram
                    spks=[];fd=0;ratemin=[];ratemax=[];%fd for "fake data"
                    for i=1:length(trigInfo.eventOnsets{1})% i is looping through each row of raster
                        tmpspks=trigInfo.eventOnsets{1}{i};
                        if ~isemtpy(tmpspks);
                            tmpspks=tmpspks+phaseshifts(r);
                            tmpspks(find(tmpspks>dur.stop))=sort(tmpspks(find(tmpspks>dur.stop))-dur.dur);
                            tempfd=histc(tmpskps,edges);
                            fd=fd+tempfd;%add up all the rows to get the fake histogram for this shuffnum

                        end

                        if bWarp
                        end

                    end
                    fd=(fd/(length(phaseshifts)))/binsize;%gives rate histogram (count is sylls w/o spks)
                    if ~bWarp;
                        fd=fd(1:end-1);%eliminates the last bin representing #spks==dur.stop
                    else

                    end


                    fdmat=[fdmat;fd];
                    %Get mins and maxes of rates, burstonsets and pauseonsets for present
                    %random rendition
                    if isempty(fd);fd=zeros(1,length(rd));end
                    ratemin=[ratemin min(fd)];%ratemin is the min of each of the shuffled hists
                    ratemax=[ratemax max(fd)];%ratemax is the max of each of the shuffled hists

                end
                trigInfo.p595=[prctile(ratemin,5) prctile(ratemax,95)];p595=trigInfo.p595;
                stdev2=mean(tempstdev2);
                trigInfo.shuffled.ratemin=ratemin;
                trigInfo.shuffled.ratemax=ratemax;
                else
                    p595=trigInfo.p595;
                    ratemin=trigInfo.shuffled.ratemin;
                    ratemax=trigInfo.shuffled.ratemax;
                    ci199=trigInfo.ci199;
            end

            %For min and max (1 of each)
            if ~isempty(rd)
                [yo ndx.min]=min(rd(syllbins));
                [yo ndx.max]=max(rd(syllbins));
                pval.minrate=mean(ratemin<min(rd(syllbins)));%mean of 0s and 1s will yield the pvalue.
                pval.maxrate=mean(ratemax>max(rd(syllbins)));
                corrtime.min=edges(ndx.min);
                corrtime.max=edges(ndx.max);

                %Below get the time at which the correlations occurred
                % if pval.minrate<.05;
                if corrtime.max>-0.001 && corrtime.max<sylldur
                    corrtime.max=sylledges(ndx.max)/sylldur;
                elseif corrtime.max<0
                    corrtime.max=sylledges(ndx.max);
                else
                    corrtime.max=100+sylledges(ndx.max)-sylldur;
                end

                if corrtime.min>-.001 && corrtime.min<sylldur
                    corrtime.min=sylledges(ndx.min)/sylldur;
                elseif corrtime.min<0
                    corrtime.min=sylledges(ndx.min);
                else
                    corrtime.min=100+sylledges(ndx.min)-sylldur;
                end

                %For all minima and maxima
                syllrd=rd(syllbins);
                ndx.minima = find(syllrd(1:end-1)>ci199(1) & syllrd(2:end)<=ci199(1));
                ndx.maxima = find(syllrd(1:end-1)<ci199(2) & syllrd(2:end)>=ci199(2));
                ndx.maxima=1+ndx.maxima;

                corrtime.minima=sylledges(ndx.minima);
                corrtime.maxima=sylledges(ndx.maxima);

                %below put in units of real time pre syll(-.06-0); syllnlized time intrasyll (0-1)
                %and real time post syll (100.00-100.06) (added 100 as label for postsyll)
                %for minima
                insyllndx=(find(corrtime.minima>-.001 & corrtime.minima<sylldur));
                postsyllndx=find(corrtime.minima>sylldur);
                corrtime.minima(insyllndx)=corrtime.minima(insyllndx)/sylldur;
                if ~isempty(postsyllndx);
                    corrtime.minima(postsyllndx)=100+corrtime.minima(postsyllndx)-sylldur;
                end
                %now for maxima
                insyllndx=(find(corrtime.maxima>-.001 & corrtime.maxima<sylldur));
                postsyllndx=find(corrtime.maxima>sylldur);
                corrtime.maxima(insyllndx)=corrtime.maxima(insyllndx)/sylldur;
                if ~isempty(postsyllndx);
                    corrtime.maxima(postsyllndx)=100+corrtime.maxima(postsyllndx)-sylldur;
                end
                trigInfo.edges=edges(1:end-1);trigInfo.rd=rd;trigInfo.rdstd=rdstd;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %Plotting
                %Plot real data histogram with p=.05 lines for max and mins
                if bplot1;
                    %                 h=figure;errorbar(edges(1:end-1),rd, rdstd);
                    %                 hold on; plot([dur.start-binsize/2,dur.stop-binsize/2], [p595(1),p595(1)],'r');
                    %                 hold on; plot([dur.start-binsize/2,dur.stop-binsize/2], [p595(2),p595(2)],'r');
                    %                 xlim([dur.start-binsize/2,dur.stop-binsize/2]);
                    %                 title(['Syll ' syllname ' pmax= ' num2str(pval.maxrate) ' pmin= ' num2str(pval.minrate) ' corrtime.max=' num2str(corrtime.max) ' corrtime.min=' num2str(corrtime.min)]);
                    %                 hold on; plot([0,0],[min(rd),max(rd)],'k');hold on; plot([sylldur,sylldur],[min(rd),max(rd)],'k');

                    %Now figure for maxima minima
                    h=figure;errorbar(edges(1:end-1),rd, rdstd);
                    hold on; plot([dur.start-binsize/2,dur.stop-binsize/2], [ci199(1),ci199(1)],'r');
                    hold on; plot([dur.start-binsize/2,dur.stop-binsize/2], [ci199(2),ci199(2)],'r');
                    xlim([dur.start-binsize/2,dur.stop-binsize/2]);
                    title([syllname ' maxima=' num2str(corrtime.maxima) ' minima=' num2str(corrtime.minima)]);
                    hold on; plot([0,0],[min(rd),max(rd)],'k');hold on; plot([sylldur,sylldur],[min(rd),max(rd)],'k');
                    xlim([presyll,sylldur+abs(presyll)]);

                end

                %eliminate min/max corrtimes if p>.05
                if pval.minrate>.05;corrtime.min=[];end
                if pval.maxrate>.05;corrtime.max=[];end

                if bWarp;
                    trigInfo.warped.pval.minrate=pval.minrate;
                    trigInfo.warped.pval.maxrate=pval.maxrate;
                    trigInfo.warped.corrtime=corrtime;
                    trigInfo.warped.meanrate=syllrd;
                    trigInfo.warped.edges=edges(syllbins);
                else
                    trigInfo.notwarped.pval.minrate=pval.minrate;
                    trigInfo.notwarped.pval.maxrate=pval.maxrate;
                    trigInfo.notwarped.corrtime=corrtime;
                    trigInfo.notwarped.meanrate=syllrd;
                    trigInfo.notwarped.edges=edges(syllbins);
                end

            else
                trigInfo.warped.meanrate=zeros(1,length(edges)-1);
            end
        end
    end
end