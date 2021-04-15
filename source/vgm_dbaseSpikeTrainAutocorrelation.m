function dbase=vgm_dbaseSpikeTrainAutocorrelation(dbase,lag,bPlot1,varargin)

if isempty(varargin);
    binsize=.01;
 
else
    binsize=varargin{1};
   
end
s = 5;
binms = 1000*binsize;

%This is the one that works!!
%smooth


totspikes=0;
dist=0;
edges=0:binsize:lag;
num=1000*lag;
for bnlizebyrate=[0 1];
    format long;
    for type=[1 2 3 4]
        if type==1;spiketimes=cumsum(dbase.boutISI);end
        if type==2;spiketimes=cumsum(dbase.nonsongISI);end
        if type==3;spiketimes=cumsum(dbase.interboutISI);end
%        if type==4;spiketimes=[cumsum(dbase.boutISI) cumsum(dbase.nonsongISI) cumsum(dbase.interboutISI)];end
        if type==4;spiketimes=concatenate(dbase.spiketimes);end
        
        
        dist=0;
        for n=1:num;
            if n==1
                val=diff(spiketimes);
            else
                val=spiketimes(1+n:end)-spiketimes(1:end-n);
            end
            [tempdist]=histc(val,edges);
                   if bPlot1; hold on; plot(edges,tempdist);end
            dist=[dist+tempdist];
        end

        dist=dist/(length(spiketimes)*binsize);
        if bPlot1 && type==1
            figure;plot(edges,smooth(dist,s),'b');
            title(dbase.title);
            xlim([0,lag]);
        end

        if bPlot1 && type==2
            hold on;plot(edges,smooth(dist,s),'g');
            title(dbase.title);
            xlim([0,lag]);
        end
        if bPlot1 && type==3
            hold on;plot(edges,smooth(dist,s),'r');
            title(dbase.title);
            xlim([0,lag]);
        end

        if bPlot1 && type==4
            hold on;plot(edges,smooth(dist/dbase.rates.all,s),'k');
            title(dbase.title);
            xlim([0,lag]);
        end

        if type==1
            if bnlizebyrate
                dbase.spiketrainautocorr.nlbout=dist/dbase.rates.bout;
            else
                dbase.spiketrainautocorr.bout=dist;
            end
            dbase.spiketrainautocorr.edges=edges;
        end


        if type==2
            if bnlizebyrate
                dbase.spiketrainautocorr.nlnonsong=dist/dbase.rates.silent;
            else
                dbase.spiketrainautocorr.nonsong=dist;
            end
            dbase.spiketrainautocorr.edges=edges;
        end


        if type==3
            if bnlizebyrate
                dbase.spiketrainautocorr.nlinterbout=dist/dbase.rates.interbout;
            else
                dbase.spiketrainautocorr.interbout=dist;
            end
            dbase.spiketrainautocorr.edges=edges;
        end

        if type==4
            if bnlizebyrate
                dbase.spiketrainautocorr.(['nlnallsong' num2str(binms) 'ms'])=dist/dbase.rates.all;
            else
                dbase.spiketrainautocorr.(['allsong' num2str(binms) 'ms'])=dist;
            end
            dbase.spiketrainautocorr.(['edges' num2str(binms) 'ms'])=edges;
        end
    end

end

