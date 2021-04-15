function [ifrspec]=vg_xdbaseFFTonIFRs(dbase);

dbase.ifrspec=[];
bplot=0;
%This function gets the IFRs for all bouts and computes average power
%spectrum.
minboutlength=.75;%in seconds

%for power spectrum of IFRs
pad=2^20;fftcount=0;fftspecsum=zeros(pad, 1);fftspecsumtime=fftspecsum;
fs=40000;sbs=10;%amt to subsample fs/sbs;

c = sum(ismember('IncludeInterbout', dbase.title));
if c>14
    [boutISI nonsongISI boutspiketimes nonsongspiketimes interboutspiketimes]=dbaseBoutNonsongISI(dbase, 0, 0, 1, dbase.indx);
else
    [boutISI nonsongISI boutspiketimes nonsongspiketimes interboutspiketimes]=dbaseBoutNonsongISI(dbase, 0, 0, 0, dbase.indx);
end
[allspiketimes]=dbaseGetRaster(dbase, dbase.indx);
for i=[1:3];
    if i==1;spks=boutspiketimes;end
    if i==2;spks=interboutspiketimes;end
    if i==3;spks=nonsongspiketimes;
        if isempty(concatenate(spks))
            spks=interboutspiketimes;
        end
    end
    if i==4;spks=allspiketimes;end
    
    z=size(spks);
    clear allspks;count=0;
    for zz=1:z(1);
        for zzz=1:z(2);
            if ~isempty(spks{zz,zzz}) && sum(diff(spks{zz,zzz}))>minboutlength;
                count=count+1;
                allspks{count}=spks{zz,zzz};
            end
        end
    end
    tottime=0;fftcount=0;fftspecsum=zeros(pad, 1);fftspecsumtime=zeros(pad, 1);fftspec_nodmnsum=zeros(pad,1);bpifrspecsum=zeros(pad,1);
    for a=1:length(allspks);
        tempspiketimes=round(fs*cumsum(diff(allspks{a})));
        %Below get post bout IFR (pbIFR);
        tempIFR=zeros(1,ceil(tempspiketimes(end)));%ceil(dbase.FileLength(i)));
        for c=1:length(tempspiketimes)-1
            tempIFR((ceil(tempspiketimes(c)):ceil(tempspiketimes(c+1))))=fs/(tempspiketimes(c+1)-tempspiketimes(c));
        end
        %subsample by sbs
        tempIFR=tempIFR(1:sbs:end);
        t=tempIFR-mean(tempIFR);%mean subtract for fft

        
%Band pass for GP neurons for Area X recordings         
        Hd_lp = FIR_lp_75;b = coeffs(Hd_lp);Hd_lp = b.Numerator;hp_b = [1 -1]; hp_a = [1 -.9988];
        lpifr=filtfilt(Hd_lp,1,t);
        bpifr = filter(hp_b,hp_a,lpifr);
        bpifr=bpifr-mean(bpifr);
      
        bpifrspec=abs(fft(bpifr,pad));
        
    
        fftspec=[(abs(fft(t,pad)))];
        
        fftspec_nodmn=[(abs(fft(tempIFR,pad)))];
        
        %important you have to square to get power
        bpifrspec=bpifrspec.^2;
        fftspec=fftspec.^2;
        fftspec_nodmn=fftspec_nodmn.^2;
        fftcount=fftcount+1;
        %fftspecsum=fftspecsum+(fftspec./sum(fftspec))';
        fftspecsum=fftspecsum+fftspec';
        fftspec_nodmnsum=fftspec_nodmnsum+fftspec_nodmn';
        fftspecsumtime=fftspecsumtime+fftspec';
        tottime=tottime+length(t)/(fs/sbs);
        bpifrspecsum=bpifrspecsum+bpifrspec';
    end
    %add up all the spectra and divide by total amt of time
    bpspec=bpifrspecsum/tottime;
    fftspec_nodmn=fftspec_nodmn/fftcount;
    fftspecmean=fftspecsum/fftcount;
    fftspecmeantime=fftspecsumtime/tottime;
    spec_nodmn=fftspec_nodmnsum/tottime;
    totalpowertime=sum(.5*sum(fftspecmeantime));
    %fftspecmeantime=fftspecmeantime/(totalpowertime);
    
    keepHz(1)=2000;keepHz(2)=ceil(keepHz(1)*pad/(40000/sbs));
    keepHz25=25;keepHz25(2)=ceil(keepHz25(1)*pad/(40000/sbs));
    keepHzlow(1)=1;keepHzlow(2)=ceil(keepHzlow(1)*pad/(40000/sbs));
    ndx1_25=[keepHzlow(2):keepHz25(2)];
    xplot=linspace(0,40000/sbs,pad);
    xplot=xplot(1:keepHz(2));%up to 150Hz
    fftspecmeannl=fftspecmean/(.5*sum(fftspecmean));
    power1_25=sum(fftspecmeannl(ndx1_25));
    power1_25time=sum(fftspecmeantime(ndx1_25));%/(.5*sum(fftspecmeantime));
    spec=fftspecmean(1:keepHz(2));
    specnl=fftspecmeannl(1:keepHz(2));
    spectime=fftspecmeantime(1:keepHz(2));
    spec_nodmn=spec_nodmn(1:keepHz(2));
    bpspec=bpspec(1:keepHz(2));
    if bplot;
        figure;plot(xplot,spec)
        xlim([-1 50]); %ylim([0,6e-4]);
        xlabel('Frequency'); ylabel('Power');title([dbase.title num2str(i)]);
    end
    if i==1;
        ifrspec.bpspecbout=bpspec;
        ifrspec.specbout=spec;
        ifrspec.specboutnl=specnl;
        ifrspec.power1_25.bout=power1_25;
        ifrspec.power1_25time.bout=power1_25time;
        ifrspec.specbouttime=spectime;
        ifrspec.specbouttime_nodmn=spec_nodmn;
        ifrspec.totpowertime.bout=totalpowertime;
    end
    if i==2;
        ifrspec.bpspecinterbout=bpspec;
        ifrspec.specinterbout=spec;
        ifrspec.specinterboutnl=specnl;
        ifrspec.power1_25.interbout=power1_25;
        ifrspec.specinterbouttime=spectime;
        ifrspec.power1_25time.interbout=power1_25time;
        ifrspec.totpowertime.interbout=totalpowertime;
        ifrspec.specinterbouttime_nodmn=spec_nodmn;
        
    end
    if i==3;
        ifrspec.bpspecnonsong=bpspec;
        ifrspec.specnonsong=spec;
        ifrspec.specnonsongnl=specnl;
        ifrspec.power1_25.nonsong=power1_25;
        ifrspec.specnonsongtime=spectime;
        ifrspec.power1_25time.nonsong=power1_25time;
        ifrspec.specnonsongtime_nodmn=spec_nodmn;
        
        ifrspec.totpowertime.nonsong=totalpowertime;
    end
    if i==4;
        ifrspec.bpspecall=bpspec;
        ifrspec.specall=spec;
        ifrspec.specallnl=specnl;
        ifrspec.power1_25.all=power1_25;
        ifrspec.alltime=spectime;
        ifrspec.power1_25time.all=power1_25time;
        ifrspec.totpowertime.all=totalpowertime;
        ifrspec.specalltime_nodmn=spec_nodmn;
    end
    
    ifrspec.xplot=xplot;
end
