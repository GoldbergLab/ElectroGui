function dbase=rcm_dbaseSpikeTrainAutocorrelation(dbase,lag,bPlot1,varargin)

if isempty(varargin);
    binsize=.01;
 
else
    binsize=varargin{1};
   
end
smoothWin = 5;
binms = 1000*binsize;

%This is the one that works!!
%smooth


totspikes=0;
dist=0;
edges=0:binsize:lag;
num=1000*lag;
for bnlizebyrate=[0 1];
    format long;
    for type=[1 2 3]
        if type==1;spiketimes=cumsum(dbase.boutISI);end
        if type==2;spiketimes=cumsum(dbase.nonsongISI);end
        if type==3;spiketimes=cumsum(dbase.interboutISI);end
        if type==4;spiketimes=concatenate(dbase.spiketimes);end
        % fix for when there's no non song data: 
        if isempty(spiketimes); spiketimes = cumsum(dbase.interboutISI);end
        
        dist=0;
        for n=1:num % this to make sure inter-num_spike-interval exceeds lag (assumes ISI>=1ms)
            if n==1
                val=diff(spiketimes);
            else
                val=spiketimes(1+n:end)-spiketimes(1:end-n); % each loop computes inter-n_spike-interval
            end
            [tempdist]=histc(val,edges);
            dist=[dist+tempdist];
        end

        dist=dist/(length(spiketimes)*binsize);
        if bPlot1 && type==1
            figure;plot(edges,smooth(dist,smoothWin),'b');
            title(dbase.title(1:3));
            xlim([0,lag]);
        end

        if bPlot1 && type==2
            hold on;plot(edges,smooth(dist,smoothWin),'g');
            title(dbase.title(1:3));
            xlim([0,lag]);
        end
        if bPlot1 && type==3
            hold on;plot(edges,smooth(dist,smoothWin),'r');
            title(dbase.title(1:3));
            xlim([0,lag]);
        end

        if bPlot1 && type==4
            hold on;plot(edges,smooth(dist/dbase.rates.all,smoothWin),'k');
            title(dbase.title(1:3));
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

