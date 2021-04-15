function [ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);

%the 3 is b/c this one has spiketimes constructed from boutspiketimes from
%dbasesingingisi; it will then demean on a bout by bout basis, then
%concatenate the ifrs--but it will hpf at x hz first

%lag is in seconds--then gets converted to samples.  This is the correct
%spiketrain autocorrelation function!  Only uses bouts that are longer than
%2xlag.
fs=40000;
lag=fs*lag;%convert lag to samples
bplot1=0;
bhighpass=0;

for bsinging=[1];

    binterbout=0;
    if bsinging && ~binterbout
        [boutstart boutend boutspiketimes]=dbaseSingingISI(dbase, dbase.indx);
    end
    if ~bsinging && sum(ismember('IncludeInterbout',dbase.title))>15 && ~binterbout
        [boutstart boutend shit interboutspiketimes]=dbaseSingingISI(dbase, dbase.indx);
        boutspiketimes=interboutspiketimes;
    end
    if ~bsinging && sum(ismember('IncludeInterbout',dbase.title))<16 && ~binterbout
        [catsilentisis catcallisis silentspiketimes]=dbaseSilentCallsISI(dbase, dbase.indx);
        boutspiketimes=silentspiketimes;
    end

    if binterbout
        [boutstart boutend shit interboutspiketimes]=dbaseSingingISI(dbase, dbase.indx);
        boutspiketimes=interboutspiketimes;
    end

    if ~bsinging && length(concatenate(boutspiketimes))<100;
        [boutstart boutend shit interboutspiketimes]=dbaseSingingISI(dbase, dbase.indx);
        boutspiketimes=[interboutspiketimes];
    end
    z=size(boutspiketimes);time=0;count=0;autcorr=zeros(1,2*lag+1);time={[]};

    series=boutspiketimes;totepochlength=0;
    z=size(series);a=[];
    for j=1:z(1)
        for r=1:z(2)
            spks=fs*series{j,r};%
            if ~isempty(spks)
                spks=1+(spks-spks(1));%spks in  samples
                epochlength=ceil((max(spks)));%epochlength in samples
                if epochlength>2*lag
                    tempIFR=zeros(1,epochlength);
                    for c=1:length(spks)-1
                        tempIFR(ceil(spks(c)):ceil(spks(c+1)))=fs/(spks(c+1)-spks(c));
                    end
                    tempIFR=tempIFR-mean(tempIFR);
                    %Below use hanning high pass on signal
                    if bhighpass
                        params.Names={'Cutoff frequency (Hz)','Order'};params.Values={'8','40'};
                        [signal lab] = egf_HanningHighPass(tempIFR,fs,params);
                        a=[a signal];
                    else
                        signal=tempIFR;
                        a=[a signal];
                    end

                end
            end
        end
    end

    a=a(1:min([length(a) 1000000]));

    [tempautocorr lags]=xcorr(a, lag, 'coeff');

    data=tempautocorr;

    %Get autocorr half widht in seconds
    thres=.5;
    offsetndx = find(data(1:end-1)>thres & data(2:end)<=thres);
    onsetndx = find(data(1:end-1)<thres & data(2:end)>=thres);
    if length(onsetndx>1)
        onsetndx=median(onsetndx);
        offsetndx=median(offsetndx);
    end
    autocorr_halfwidth=(offsetndx-onsetndx)/fs;

    if bplot1 && isempty(data(isnan(data)));
        plot(lags/fs,data);
        title([dbase.title '--' num2str(autocorr_halfwidth)]);xlabel('Lag (seconds)');ylabel('Power');
        ylim([0,1]);xlim([-.1,.1]);
    end

    if length(a)<20000;
        sampledata=a;
    else
        sampledata=a(1:20000);
    end

    if isempty(sampledata);
        henry='go_fuck';
    end

    variance=var(a);

    if bsinging
        ifrautocorr.bout.ifr=tempautocorr;
        ifrautocorr.bout.halfwidth = autocorr_halfwidth;
        ifrautocorr.bout.lags =lags;
        ifrautocorr.bout.fs = fs;
        ifrautocorr.bout.sampledata= sampledata;
        ifrautocorr.bout.variance=variance;

    else
        ifrautocorr.nonsong.ifr=tempautocorr;
        ifrautocorr.nonsong.halfwidth = autocorr_halfwidth;
        ifrautocorr.nonsong.lags =lags;
        ifrautocorr.nonsong.fs = fs;
        ifrautocorr.nonsong.sampledata= sampledata;
        ifrautocorr.nonsong.variance=variance;
    end
end