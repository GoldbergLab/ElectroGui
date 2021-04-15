function dbase=vg_dbasepairsIFRxcorr(dbase);

%This function computes the xcorr of termIFR vs DLM IFR during bouts
[boutstart boutend]=dbaseSingingISI(dbase, dbase.tindx);
[t ifr,indx dbase]=dbaseGetRaster(dbase, dbase.tindx);
[d ifr,indx dbase]=dbaseGetRaster(dbase, dbase.dindx);
fs=dbase.Fs;minbout=.4;cx=[];
filestarttimes=dbase.Times2*(3600*24);
minbout=.6;
bplot1=1;
xl=.5;
cc=[];p=[];
boutstarts=concatenate(boutstart);boutends=concatenate(boutend);
ds=concatenate(d);ts=concatenate(t);
%yoyo you must concatenate bouts
%NOte you are going to use the concatenated bouttimes and go through files
%based on if bouttimes are greater than filestarttimes and less than
%filestarttimes+1;
sbs=10;
for i=1:length(boutstarts);
    boutds=ds(find(ds>boutstarts(i) & ds<boutends(i)));
    boutts=ts(find(ts>boutstarts(i) & ts<boutends(i)));
    boutds=round(fs*(boutds-boutstarts(i)));
    boutts=round(fs*(boutts-boutstarts(i)));
    if length(boutts)>5 && length(boutds)>5
        temptIFR=zeros(1,round(fs*(boutends(i)-boutstarts(i))));
        temptIFR(round(length(temptIFR)/2):end)=-1;
        tempdIFR=temptIFR;
        for c=1:length(boutts)-1
            temptIFR((boutts(c):boutts(c+1)))=fs/(boutts(c+1)-boutts(c));
        end
        for c=1:length(boutds)-1
            tempdIFR((boutds(c):boutds(c+1)))=fs/(boutds(c+1)-boutds(c));
        end
        ndx=max([boutts(1) boutds(1)]):min([boutts(end) boutds(end)]);
        if length(ndx)/fs>minbout
            temptIFR=temptIFR(ndx);tempdIFR=tempdIFR(ndx);

            [tempcc pp]=corrcoef(temptIFR,tempdIFR);
            cc=[cc tempcc(2)];
            p=[p pp(2)];



            [c lags] = xcorr(tempdIFR-mean(tempdIFR),temptIFR-mean(temptIFR),'coeff');
            xcndx=find(lags>=-xl*fs & lags<=xl*fs);
            lags=lags(xcndx);
            %figure;plot(lags/fs,c(xcndx));title(num2str(i));
            cx=[cx; c(xcndx)];

            %get range of half-widths

        end
    end
end
dbase.ifrcorrcoef.bout.cx=cx;
dbase.ifrcorrcoef.bout.lags=lags/fs;
dbase.ifrcorrcoef.bout.cc=cc;
dbase.ifrcorrcoef.bout.p=p;
dbase.ifrcorrcoef.bout.lagrange=[];
%
%Below do bUnusable files for nonsong
cc=[];p=[];cx=[];
for i=1:length(dbase.Properties.Names{1})
    if strcmp(dbase.Properties.Names{1}{i},'bUnusable')
        unusables=i;
    end
end
for i=1:length(dbase.Times)-1
    if dbase.Properties.Values{i}{unusables} && length(d{i})>10 && length(t{i})>10 && isempty(find(boutstarts>filestarttimes(i) & boutstarts<filestarttimes(i+1)));

        temptIFR=zeros(1,dbase.FileLength(i));
        tspks=round(fs*(t{i}-filestarttimes(i)));
        dspks=round(fs*(d{i}-filestarttimes(i)));
        for c=1:length(tspks)-1
            temptIFR((tspks(c):tspks(c+1)))=fs/(tspks(c+1)-tspks(c));
        end
        tempdIFR=zeros(1,dbase.FileLength(i));
        for c=1:length(dspks)-1
            tempdIFR((dspks(c):dspks(c+1)))=fs/(dspks(c+1)-dspks(c));
        end
        if bplot1;         figure;plot(tempdIFR);hold on; plot(temptIFR,'k');title(num2str(i));end
        [tempcc pp]=corrcoef(tempdIFR,temptIFR);
        cc=[cc tempcc(2)];
        p=[p pp(2)];

        [c lags] = xcorr(tempdIFR-mean(tempdIFR),temptIFR-mean(temptIFR),'coeff');
        xcndx=find(lags>=-xl*fs & lags<=xl*fs);
        lags=lags(xcndx);
        if bplot1; figure;plot(lags/fs,c(xcndx));title(num2str(i));end
        cx=[cx; c(xcndx)];

    end
end
dbase.ifrcorrcoef.nonsong.cc=cc;
dbase.ifrcorrcoef.nonsong.p=p;
dbase.ifrcorrcoef.nonsong.cx=cx;
dbase.ifrcorrcoef.nonsong.lags=lags/fs;
