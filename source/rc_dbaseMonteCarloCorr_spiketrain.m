function [trigInfo]=rc_dbaseMonteCarloCorr_spiketrain(trigInfo,varargin)

%stdev is the width of the gaussian
if isempty(varargin)
stdevms = [20];
else
stdevms = varargin{1};
end

% downsample to 1000hz
subsample=10;
fs=40000/subsample;
perimotif=0; %This is the time to take before and after the motif (like a pad)

n_repeats = 1000; % monte carlo N
% exclude empty trigInfos

% round to .1 sec
dur.stop=round(10*trigInfo.dataStop{1})/10;
dur.start=round(10*trigInfo.dataStart{1})/10;
duration=dur.stop-dur.start;
dur.dur=duration;

median_dur=median(trigInfo.currTrigOffset);
n_motifs=length(trigInfo.eventOnsets{1});

% random offset in samples used for monte carlo
phaseshifts=ceil((fs*median_dur-2)*rand(1,n_motifs));
phaseshifts2 = ceil((fs*median_dur-2)*rand(n_repeats,n_motifs));

for stdev_in_ms = stdevms
    stdev_in_s = stdev_in_ms/1000;
    stdev = stdev_in_s*fs;wsize=stdev;

    for bWarp = [1]
        n_usemotif = min(n_motifs,100);
        ifr=[];fifr=[];burstifr=[];pauseifr=[];pausendx=[];brstndx=[];pauseifr=[];fburstifr=[];fpauseifr=[];
        fifr2 = zeros(n_repeats,n_usemotif,ceil(fs*median_dur));
        for i=1:n_usemotif%length(trigInfo.eventOnsets{1})
            spks{i}=trigInfo.eventOnsets{1}{i};
            warp=(median_dur/trigInfo.currTrigOffset(i));
            if ~isempty(spks{i}) && warp>0.7 && warp<1/.7
                %compute IFR for full duration of each rendition
                tempspks=ceil(fs*(spks{i})); % do not shift spike time to have 0 start
                if bWarp
                    warpval(i)=(median_dur/trigInfo.currTrigOffset(i));
                    tempspks=round(tempspks*warpval(i));
                else
                    warpval(i)=1;
                end
                tempspks=tempspks(tempspks>0);
                %
                tempIFR=zeros(1,ceil(fs*median_dur));
                tempIFR(tempspks)=1;
                tempIFR=tempIFR(1:ceil(fs*median_dur));
%                                 figure;plot(tempIFR);ylim([-1,2]);

                trigInfo.warpedspikeTimes{i}=tempspks/40000;

                tempIFR=smoothts(tempIFR,'g',wsize,stdev);
%                                 hold on; plot(tempIFR,'r');

                %%%%%%%%%%%%%%%%%%%%%%%%%%
                %2. For regular ifr cross corrs
                %ndx out from center of ifr trace (this is the syll onset)
%                 tempIFR=tempIFR((floor(length(tempIFR)/2)-fs*presyll):(floor(length(tempIFR)/2+fs*sylldur)));
                %demean step for IFR cc
%                 tempIFR=[tempIFR mean(tempIFR)];
                tempIFR=tempIFR(1:floor(fs*(median_dur+perimotif)));

                tempIFR=tempIFR-mean(tempIFR);
%                                 hold on; plot(tempIFR); 
                ifr=[ifr;tempIFR];
                %shuffle
                try
                    ftempIFR=[tempIFR(phaseshifts(i):end) tempIFR(1:phaseshifts(i))];
                    for i_repeat = 1:n_repeats
                        fifr2(i_repeat,i,:)=[tempIFR(phaseshifts2(i_repeat,i):end) tempIFR(1:phaseshifts2(i_repeat,i))];
                    end
                catch
                    disp(phaseshifts(i));
                end
                fifr=[fifr; ftempIFR];
            end
        end
        if ~isempty(ifr)
            if max(max(ifr))>.01 && max(max(fifr))>.01;
                n_trials=size(ifr,1);spikecount=0;spikecc=zeros(1,.5*n_trials*(n_trials-1));spikefcc=spikecc;
                spikefcc2 = zeros(n_repeats,.5*n_trials*(n_trials-1));

                % using matlab function
                [R,P,RL,RU] = corrcoef(ifr');
                trigInfo.cc = .5*(sum(sum(R))-sum(diag(R)))/(.5*n_trials*(n_trials-1));
                trigInfo.pvalcc = .5*(sum(sum(P))-sum(diag(P)))/(.5*n_trials*(n_trials-1));
                trigInfo.lowercc = .5*(sum(sum(RL))-sum(diag(RL)))/(.5*n_trials*(n_trials-1));
                trigInfo.uppercc = .5*(sum(sum(RU))-sum(diag(RU)))/(.5*n_trials*(n_trials-1));

                %Compute pairwise correlation coefficients

                if n_trials>1
                    for i=1:n_trials-1
                        for j=i+1:n_trials
                            if max(ifr(i,:))>.01 && max(ifr(j,:))>.01
                                spikecount=spikecount+1;
                                spikecc(spikecount)=(ifr(i,:)*ifr(j,:)')/sqrt((ifr(i,:)*ifr(i,:)')*(ifr(j,:)*ifr(j,:)'));
                                spikefcc(spikecount)=(fifr(i,:)*fifr(j,:)')/sqrt((fifr(i,:)*fifr(i,:)')*(fifr(j,:)*fifr(j,:)'));
                                for i_repeat = 1:n_repeats
                                    x = reshape(fifr2(i_repeat,i,:),1,[]);
                                    y = reshape(fifr2(i_repeat,j,:),1,[]);
                                    spikefcc2(i_repeat,spikecount) = (x*y')/sqrt((x*x')*(y*y'));
                                end
                            end
                        end
                    end
                end
                spikecc=spikecc(1:spikecount);
                spikefcc=spikefcc(1:spikecount);
                spikefcc2 = spikefcc2(:,1:spikecount);
                if bWarp
                    if spikecount>0
                        trigInfo.(['spikecc' num2str(stdev_in_ms)]) = spikecc;
                        trigInfo.(['spikefcc' num2str(stdev_in_ms)])=spikefcc;
                        if ~isempty(spikecc(~isnan(spikecc))) && ~isempty(spikefcc(~isnan(spikefcc)))
                            [h trigInfo.pval.warped.(['spikecc' num2str(stdev_in_ms)])]=kstest2(spikecc,spikefcc);
                            trigInfo.pval.warped.(['altspikecc' num2str(stdev_in_ms)])= sum(mean(abs(spikecc))<mean(abs(spikefcc2),2))/n_repeats;%new test);
                        else
                            trigInfo.pval.warped.(['spikecc' num2str(stdev_in_ms)])=[];
                        end
                    else
                        trigInfo.(['spikecc' num2str(stdev_in_ms)])=[];
                        trigInfo.(['spikefcc' num2str(stdev_in_ms)])=[];
                    end
                else %if notwarped
                    if spikecount>0
                        trigInfo.notwarped.(['spikecc' num2str(stdev_in_ms)])=spikecc;
                        trigInfo.notwarped.(['spikefcc' num2str(stdev_in_ms)])=spikefcc;
                        if ~isempty(spikecc(~isnan(spikecc))) && ~isempty(spikefcc(~isnan(spikefcc)))
                            [h trigInfo.notwarped.pval.(['spikecc' num2str(stdev_in_ms)])]=kstest2(spikecc,spikefcc);
                        else
                            trigInfo.notwarped.pval.(['spikecc' num2str(stdev_in_ms)])=[];
                        end
                    else
                        trigInfo.notwarped.(['spikecc' num2str(stdev_in_ms)])=[];
                        trigInfo.notwarped.(['spikefcc' num2str(stdev_in_ms)])=[];
                    end
                end

            end%if max(max(ifr))>0;
        end
        %end
    end
end
%     title([trigInfo.title ' ' num2str(trigInfo.bencecc)])