%%
%make three folders and call them here

%this folder has all your nondromic dbases that were not error related
fold{1}='C:\Users\jesseg\Desktop\NewLab\VTA paper\VTA other dbases\';

%this folder has your nondromic error dbases
fold{2}='C:\Users\jesseg\Desktop\NewLab\VTA paper\VTA error\';

%this folder has your adromic dbases
fold{3}='C:\Users\jesseg\Desktop\NewLab\VTA paper\VTA adromic\';

%set up color scheme
cy{1}='k';cy{2}='r'; cy{3}='g';

%%

for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');i
            load([fold{y} contents(i).name]);
            dbase.dbasePathNameJesse=[fold{y} contents(i).name];
            dbase.dbasePathNameVikram=[];
            dbase.title=contents(i).name;

            %initial analyses to extract eventTimes
            dbase=vg_dbaseGetIndices(dbase);
            dbase=vg_dbaseBoutNonsongISI(dbase,dbase.indx);
            [filestarttimes fileendtimes dbase.syllstarttimes dbase.syllendtimes dbase.sylldurs preintrvl postintrvl allintrvls dbase.syllnames] = dbaseGetSylls(dbase);
            dbase.filestarttimes=filestarttimes;dbase.fileendtimes=fileendtimes;
            dbase.allsyllnames=cell2mat(concatenate(dbase.syllnames));

            %spike train analyses including ISI distrubtions
            [dbase]=vg_dbaseBoutNonsongISI(dbase,dbase.indx);%Get interspike interval (ISI)
            lag=1;%Lag, in seconds, of how far out you want to plot
            bplot=0; %if you want to plot the autocorr; 0 if you don't want to
            [dbase]=vg_dbaseSpikeTrainAutocorrelation(dbase,lag, bplot);


            %infrastructure for error-related analyses -- below we define
            %mediafdbk time as zero
            dbase.allsyllstarts=concatenate(dbase.syllstarttimes);
            dbase.allsyllends=concatenate(dbase.syllendtimes);
            dbase.allsyllnames=concatenate(concatenate(dbase.syllnames));
            dbase.allfdbks=concatenate(dbase.fdbktimes);
            dbase.hitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.fdbksyll));%
            dbase.catchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==lower(dbase.fdbksyll)));
            d=[];
            for j=1:length(dbase.hitsyllstarts);
                delay=dbase.allfdbks-dbase.hitsyllstarts(j);
                [tmpdelay ndx]=min(abs(delay));%(find(delay>0));
                d=[d delay(ndx)];
            end
            dbase.fdbkdelays=d;%all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses

            %below get triginfos (raster data) for various events and
            %triggers
            binsize=.025;xl=1.05;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
            bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping

            %below exlude any event that has filestarts, fileends, or stims within the xlim
            exclude=sort([dbase.filestarttimes dbase.fileendtimes concatenate(dbase.stimtimes)]);
            %
            %             %Fix nonsense with dbase.moveonsets orientation
            %             zz=size(dbase.moveonsets);
            %             if zz(1)>zz(2);dbase.moveonsets=dbase.moveonsets';dbase.moveoffsets=dbase.moveoffsets';end
            %             clear zval;
            %             for zzzz=1:length(dbase.moveonsets);zval(zzzz)=length(dbase.moveonsets{zzzz});end
            %             [maxmove maxmovendx]=max(zval);
            %             zz=size(dbase.moveonsets{maxmovendx});
            %             if zz(1)>zz(2);
            %                 for i=1:length(dbase.moveonsets);dbase.moveonsets{i}=dbase.moveonsets{i}';dbase.moveoffsets{i}=dbase.moveoffsets{i}';end
            %             end

            %moveons and moveoffs aligned spikes
            trigger=concatenate(dbase.moveonsets);
            events=concatenate(dbase.spiketimes);
            dbase.trigInfomoveonsbin25=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigger=concatenate(dbase.moveoffsets);
            dbase.trigInfomoveoffsbin25=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            %First hit sylls moves
            trigger=dbase.hitsyllstarts+median(dbase.fdbkdelays);
            events=concatenate(dbase.moveonsets);
            dbase.trigInfomovehitbin25=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            %Hit syll spikes (time 0 is the time of the fdbk)
            events=concatenate(dbase.spiketimes);
            dbase.trigInfohitbin25=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            %catch sylls moves
            trigger=dbase.catchsyllstarts+median(dbase.fdbkdelays);
            events=concatenate(dbase.moveonsets);
            dbase.trigInfomovecatchbin25=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);
            events=concatenate(dbase.spiketimes);
            dbase.trigInfocatchbin25=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            %moveons with song excluded
            exclude=sort([exclude concatenate(dbase.syllstarttimes) concatenate(dbase.syllendtimes)]);
            dbase.trigInfomoveonsbin25no_song=vg_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            %now mishits - potentially mainfig 3
            %for mishit analysis set xl to 0.5
            xl=.5;%this might reduce how many we exclude
            dbase=jg_vta_dbasegetmishits(dbase);%THIS CODE ASSUMES ALL Zs ARE LABELED
            trigger=dbase.mishittimes;
            events=concatenate(dbase.spiketimes);
            exclude=sort([dbase.filestarttimes dbase.fileendtimes concatenate(dbase.stimtimes)]);
            dbase.trigInfoMishitsbin25=vg_MakeTrigInfoFlexLocalExclude(trigger, events, exclude,dbase, 0, xl,binsize);

            %hit history code
            % dbase=vg_hithistory(dbase);
            save(dbase.dbasePathNameJesse,'dbase');

        end
    end
end

%%
%Supp Fig 1
%look for zscore of error response
bplot1=0;
allz=[];allmz=[];allmzoff=[];allmznosong=[];
for y=[1:3];s=5;
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);

            h=dbase.trigInfohitbin25;c=dbase.trigInfocatchbin25;

            df=c.rd-h.rd;df=smooth(df,s)';%below define difference histogram (df) (comparing HIT vs CATCH trial)
            %dbase=rmfield(dbase,'errorzscore');%below remove errorzscore because it used to be a value; we're gonna make it a field below
            dbase.errorzscore.bin25s5.rd=zscore(df);%this gets the zscore of the diff histogram ; bin25s5 is the binsize and smooth val
            dbase.errorzscore.bin25s5.edges=h.edges;

            %below we are pulling out a single value related to the catch-error response
            dbase.errorzscore.bin25s5.errorndx=[0 .1];%this is the timewindow that we are examining the zscore
            dbase.errorzscore.bin25s5.errormeanval=mean(dbase.errorzscore.bin25s5.rd(find(h.edges>=0 & h.edges<=.1)));
            dbase.errorzscore.bin25s5.errorpeakval=max(dbase.errorzscore.bin25s5.rd(find(h.edges>=0 & h.edges<=.1)));

            %below we are looking at movements on HIT vs CATCH
            %             dbase.movezscore=rmfield(dbase.movezscore,'bin25s5');dbase.moveoffzscore=rmfield(dbase.moveoffzscore,'bin25s5');
            dbase.movezscore.bin25s5.rd=zscore(smooth(dbase.trigInfomoveonsbin25.rd,s)');
            dbase.moveoffzscore.bin25s5.rd=zscore(smooth(dbase.trigInfomoveoffsbin25.rd,s)');

            if bplot1
                figure;plot(zscore(df));title(num2str(i));
                save(dbase.dbasePathNameJesse,'dbase');
                figure;
                subplot(2,1,1);stairs(c.edges,c.rd);hold on; stairs(h.edges,h.rd,'r');xlim([h.edges(1),h.edges(end)]);
                subplot(2,1,2);stairs(h.edges,zscore(df));ylim([-4 4]);xlim([h.edges(1),h.edges(end)]);
            end
            allz=[allz;zscore(df)];
            allmz=[allmz;dbase.movezscore.bin25s5.rd];
            allmzoff=[allmzoff;dbase.moveoffzscore.bin25s5.rd];

            if ~isempty(dbase.trigInfomoveonsbin25no_song)
                dbase.movezscorenosong.bin25s5=zscore(smooth(dbase.trigInfomoveonsbin25no_song.rd,s)');
                allmznosong=[allmznosong;dbase.movezscorenosong.bin25s5];
            end
        end
    end
end

figure;
imagesc(h.edges,[1:size(allz,1)],allz);caxis([-2 4]);xlim([-1 1]);colorbar;title('allz');
title('error zscore');
figure;
imagesc(h.edges,[1:size(allmz,1)],allmz);caxis([-2 4]);xlim([-1 1]);colorbar;title('allmz');
title('moveons zscore');
%%
%Supp fig 1
%below for populuatoin analysis (histogram and scatterplot of error and movement zscores
%error
errorxndx=find(h.edges>0.025 & h.edges<=.1);%this sets the bins you want to analyze to generate the bimodal distribution
peakzs=max(allz(:,errorxndx)');
meanzs=mean(allz(:,errorxndx)');

dist=histc(peakzs,edges);figure;stairs(edges,dist);
dist=histc(meanzs,edges);figure;stairs(edges,dist,'r');

%moveons

movexndx=find(h.edges>-.05 & h.edges<=.12);

peakmzs=max(allmz(:,movexndx)');
meanmzs=mean(allmz(:,movexndx)');

figure;plot(meanzs,peakmzs,'o','color',cy{y});

%%
%Supp Fig 2 - standard spike train analyses
%CVisi, spikewidht, ifrautocorr, spiketrainautocorr, prctile(ISI,99);
%prctile(isi, 1);

for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');i
            load([fold{y} contents(i).name]);
            %             [dbase] = dbasespikewidth(dbase);
            lag=1;bplot=0;
            [dbase]=vg_dbaseSpikeTrainAutocorrelation(dbase,lag, bplot);
            save(dbase.dbasePathNameJesse,'dbase');
        end
    end
end



%song vs nonsong

%%
figure;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            subplot(2,2,1);hold on; plot(dbase.rates.bout,dbase.rates.interbout,'o','color',cy{y});
            subplot(2,2,1);xlabel('dbase.rates.bout');ylabel('dbase.rates.interbout')
            subplot(2,2,2);hold on;plot(std(dbase.boutISI)/mean(dbase.boutISI),(std(dbase.interboutISI)/mean(dbase.interboutISI)),'o','color',cy{y})
            subplot(2,2,2);xlabel('cvisi bout');ylabel('cvisi interbout');
            subplot(2,2,3);hold on;plot(1/prctile(dbase.boutISI,95),1/prctile(dbase.boutISI,5),'o','color',cy{y});
            subplot(2,2,3);xlabel('Peak rate');ylabel('Min rate');


            % subplot(2,2,4);plot(
        end
    end
end

%%
playing around with autocrrelations below






for y=[2];
    contents=dir(fold{y});
    for i=3:length(contents);i
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);

            figure;plot(dbase.spiketrainautocorr.edges,dbase.spiketrainautocorr.nlnallsong);title(i);
        end
    end
end

%%

autcorr=[];
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);i
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
%             dbase=vg_dbaseBoutNonsongISI(dbase,dbase.indx);
            dbase=vg_dbaseSpikeTrainAutocorrelation(dbase,1, 0);
%             save(dbase.dbasePathNameJesse,'dbase');
            autcorr=[autcorr;dbase.spiketrainautocorr.nlnallsong];
        end
    end
end

figure;
imagesc(dbase.spiketrainautocorr.edges,[1:size(autcorr,1)],autcorr);colorbar;caxis([0, 4])




