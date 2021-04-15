function [trigInfo]=rcm_dbaseSpikeTrainMotifPowerSpectrum(trigInfo,varargin)

if isempty(varargin)
    bPlot = 0;
else
    bPlot = varargin{1};
end

%stdev is the width of the gaussian

% %this function quantiifes the p value of correlation of PSTH of
% %spikes/bursts/pauses with certain syll.  may be useful to use
% %with sorted rasters matlab exprort-->triginfo.
subsample=10;
% downsample to 1000hz
fs=40000/subsample;
T = 1/fs;
L = 2^18;
t = (0:L-1)*T;
f = fs*(0:(L/2))/L;

perimotif=0; %This is the time to take before and after the motif (like a pad)

% round to .1 sec
dur.stop=round(10*trigInfo.dataStop{1})/10;
dur.start=round(10*trigInfo.dataStart{1})/10;
duration=dur.stop-dur.start;
dur.dur=duration;

median_dur=median(trigInfo.currTrigOffset);
n_motifs=length(trigInfo.eventOnsets{1});

% random offset in samples used for monte carlo
% phaseshifts=ceil(fs*median_dur*rand(1,n_motifs));



for bWarp = [0]
    spikeMatrix=[];fspikeM=[];burstifr=[];pauseifr=[];pausendx=[];brstndx=[];pauseifr=[];fburstifr=[];fpauseifr=[];
    P1all = [];P1powerall=[];
    for i=1:n_motifs%length(trigInfo.eventOnsets{1})
        spks{i}=trigInfo.eventOnsets{1}{i};
        warp=(median_dur/trigInfo.currTrigOffset(i));
        if ~isempty(spks{i}) && warp>0.7 && warp<1/.7
            %compute IFR for full duration of each rendition
            tempspks=ceil(fs*(-dur.start+spks{i})); %shift spike time to have 0 start
            if bWarp
                warpval(i)=(median_dur/trigInfo.currTrigOffset(i));
                tempspks=round(tempspks*warpval(i));
            else
                warpval(i)=1;
            end
            tempspks=tempspks(tempspks>0);
            trigInfo.warpedspikeTimes{i}=tempspks/40000;
            %
%             tempSpiketrain=zeros(1,L);
%             tempSpiketrain(tempspks)=1;
            %                 figure;plot(tempIFR);ylim([-1,2]);
            tempIFR = zeros(1,floor(fs*(median_dur+perimotif)));
            for c = 1:length(tempspks)-1
                tempIFR((ceil(tempspks(c)):ceil(tempspks(c+1))))=fs/(tempspks(c+1)-tempspks(c)); 
            end
            tempIFR=tempIFR(1:floor(fs*(median_dur+perimotif)));

            tempIFR = tempIFR-mean(tempIFR);
            IFR = zeros(1,L);
            IFR(1:length(tempIFR)) = tempIFR;
            % smooth IFR by 10ms window
            IFR = smooth(IFR,fs*0.01);
            
            if max(IFR)==0
                continue
            end
            Y = fft(IFR);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);
            % need row vector for P1!
            P1 = P1';
            P1all = [P1all;P1/sum(P1)];
            
%             Ypower = fft(P1);
%             P2power = abs(Ypower/L);
%             P1power = P2power(1:L/2+1);
%             P1power(2:end-1) = 2*P1power(2:end-1);
%             P1powerall = [P1powerall;P1power];
            
            %shuffle
%             ftempSpiketrain=[tempSpiketrain(phaseshifts(i):end) tempSpiketrain(1:phaseshifts(i))];
%             fspikeM=[fspikeM; ftempSpiketrain];
        end
    end
    
    P1mean = sum(P1all,1)/size(P1all,1);
%     P1powermean = sum(P1powerall,1)/size(P1all,1);
%     if bPlot
%         figure;plot(f,P1mean);xlim([0,100]);
% %         figure;plot(f,P1powermean);xlim([0,100]);
%     end
    trigInfo.fftYmeanSpectrum = P1mean;
    trigInfo.fftXfreqs = f;
    % Hz below which to cut
    freq_cutoff = 3;
    ind_cutoff = min(find(f>freq_cutoff));
    [max_power, ind_maxp] = max(P1mean(ind_cutoff:end));  
    trigInfo.fftPeakFreq = f(ind_maxp+ind_cutoff-1);
    trigInfo.fftPeakPower = max_power;
    
    % on rate histogram
    rd = trigInfo.rd;
    rd = rd - mean(rd);
    rd = smooth(rd,3);
    edges = trigInfo.edges;
    binsize = edges(2)-edges(1);
    fs = 1/binsize;
    T = 1/fs;
    L = length(rd);
    t = (0:L-1)*T;
    f = fs*(0:(L/2))/L;
    Y = fft(rd);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    P1 = P1';
    trigInfo.fftPSTHSpectrum = P1;
    freq_cutoff = 3;
    ind_cutoff = min(find(f>freq_cutoff));
    [max_power, ind_maxp] = max(P1(ind_cutoff:end));  
    trigInfo.fftPeakFreqPSTH = f(ind_maxp+ind_cutoff-1);
    trigInfo.fftPeakPowerPSTH = max_power;
    if bPlot
        figure;plot(edges,rd)
        figure;plot(f,P1)
    end
end

%     title([trigInfo.title ' ' num2str(trigInfo.bencecc)])