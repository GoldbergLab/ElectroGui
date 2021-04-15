function dbase = vgm_getwinrates(dbase, windur)

% this fucntion generates the firing rate using ISIs and a specified
% window. It counts the number of spikes in randomly chosen windows of
% duration windur and calculates the mean rate
N = 10000;
fs = 40000;

if isfield(dbase.ISI, 'bout')
    if ~isempty(dbase.ISI.bout)
        ISI = dbase.ISI.bout;
        spiketimes = [0 cumsum(ISI)];
        tlim = floor(fs*(spiketimes(end)-windur));
        tstart = randi(tlim,1,N)/fs;
        tend = tstart+windur;
        winnum = 0;
        for k = 1:N
            winnum = winnum + sum(spiketimes > tstart(k) & spiketimes < tend(k));
        end
        NumMean = winnum/N;
        rate = NumMean/windur;
        dbase.rates.bout_win = rate;
    end
end

if isfield(dbase.ISI, 'nonsong')
    if ~isempty(dbase.ISI.nonsong)
        ISI = dbase.ISI.nonsong;
        spiketimes = [0 cumsum(ISI)];
        tlim = floor(fs*(spiketimes(end)-windur));
        tstart = randi(tlim,1,N)/fs;
        tend = tstart+windur;
        winnum = 0;
        for k = 1:N
            winnum = winnum + sum(spiketimes > tstart(k) & spiketimes < tend(k));
        end
        NumMean = winnum/N;
        rate = NumMean/windur;
        dbase.rates.nonsong_win = rate;
    end
end

if isfield(dbase.ISI, 'interbout')
    if ~isempty(dbase.ISI.interbout)
        ISI = dbase.ISI.interbout;
        spiketimes = [0 cumsum(ISI)];
        tlim = floor(fs*(spiketimes(end)-windur));
        if tlim > 0
            tstart = randi(tlim,1,N)/fs;
            tend = tstart+windur;
            winnum = 0;
            for k = 1:N
                winnum = winnum + sum(spiketimes > tstart(k) & spiketimes < tend(k));
            end
            NumMean = winnum/N;
            rate = NumMean/windur;
            dbase.rates.interbout_win = rate;
        end
    end
end

if isfield(dbase.ISI, 'boutnohitesc')
    if ~isempty(dbase.ISI.boutnohitesc)
        ISI = dbase.ISI.boutnohitesc;
        spiketimes = [0 cumsum(ISI)];
        tlim = floor(fs*(spiketimes(end)-windur));
        if tlim>0
            tstart = randi(tlim,1,N)/fs;
            tend = tstart+windur;
            winnum = 0;
            for k = 1:N
                winnum = winnum + sum(spiketimes > tstart(k) & spiketimes < tend(k));
            end
            NumMean = winnum/N;
            rate = NumMean/windur;
            dbase.rates.boutnohitesc_win = rate;
        end
    end
end

if isfield(dbase.ISI, 'nonsongnoZ')
    if ~isempty(dbase.ISI.nonsongnoZ)
        ISI = dbase.ISI.nonsongnoZ;
        spiketimes = [0 cumsum(ISI)];
        tlim = floor(fs*(spiketimes(end)-windur));
        tstart = randi(tlim,1,N)/fs;
        tend = tstart+windur;
        winnum = 0;
        for k = 1:N
            winnum = winnum + sum(spiketimes > tstart(k) & spiketimes < tend(k));
        end
        NumMean = winnum/N;
        rate = NumMean/windur;
        dbase.rates.nonsongnoZ_win = rate;
    end
end


end