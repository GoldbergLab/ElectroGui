function dbase=xsdbaseBurstDetector(dbase,thres);

if ~isfield(dbase.rates,'bouttime')
    [boutISI nonsongISI boutspiketimes nonsongspiketimes interboutspiketimes interboutISI edges boutdist nonsongdist bouttime silenttime interbouttime]=dbaseBoutNonsongISI(dbase, 0, 0, 0, dbase.indx);
    dbase.rates.bouttime=sum(concatenate(bouttime));
    dbase.rates.interbouttime=sum(concatenate(interbouttime));
    dbase.rates.silenttime=sum(concatenate(silenttime));
end
thres=1/thres;
for type=[1,2];
    if type==1;data=cumsum(dbase.boutISI);end
    if type==2;data=cumsum(dbase.nonsongISI);end
    if type==3;data=cumsum(dbase.interboutISI);end
    
    data=[thres+.001 diff(data) thres+.001];%pad the diff(spks) with vals>thres to ensure =#brst.strts&stops
    onsetndx = find(data(1:end-1)>thres & data(2:end)<=thres);
    offsetndx = find(data(1:end-1)<thres & data(2:end)>=thres);
    burstisis=[];
    for o=1:length(onsetndx);
        burstisis=[burstisis data((onsetndx(o)+1):offsetndx(o))];
    end
    rateinburst=mean(1./burstisis);
    
    
    if type==1
        dbase.rates.burstdetector.thres=thres;
        dbase.rates.burstdetector.bout.spikesperburst=1+(offsetndx-onsetndx);
        dbase.rates.burstdetector.bout.burstrate=length(onsetndx)/dbase.rates.bouttime;
        dbase.rates.burstdetector.bout.fraction=length(dbase.boutISI(dbase.boutISI(2:end)<=thres | dbase.boutISI(1:end-1)<=thres))/length(dbase.boutISI);
        dbase.rates.burstdetector.bout.rateinburst=rateinburst;
    end
    
    if type==2
        
        dbase.rates.burstdetector.thres=thres;
        dbase.rates.burstdetector.nonsong.spikesperburst=1+(offsetndx-onsetndx);
        dbase.rates.burstdetector.nonsong.burstrate=length(onsetndx)/dbase.rates.silenttime;
        dbase.rates.burstdetector.nonsong.fraction=length(dbase.nonsongISI(dbase.nonsongISI(2:end)<=thres | dbase.nonsongISI(1:end-1)<=thres))/length(dbase.nonsongISI);
        dbase.rates.burstdetector.nonsong.rateinburst=rateinburst;
        
    end
    
    if type==3
        
        dbase.rates.burstdetector.thres=thres;
        dbase.rates.burstdetector.interbout.spikesperburst=1+(offsetndx-onsetndx);
        dbase.rates.burstdetector.interbout.burstrate=length(onsetndx)/dbase.rates.interbouttime;
        dbase.rates.burstdetector.interbout.fraction=length(dbase.interboutISI(dbase.interboutISI(2:end)<=thres | dbase.interboutISI(1:end-1)<=thres))/length(dbase.interboutISI);
        dbase.rates.burstdetector.interbout.rateinburst=rateinburst;
        
    end
end


