% This function taks a trigInfo and generates pre-target modulation depth,
% as well as expected modulation depth using random 'target' times which
% are outside the target time, or excluding [-prewin,prewin] relative to
% target. 
% new field generated: tf.moddepth

function [tf] = rc_dbaseTargetTimeAnalysis(dbase,tf)
    fdbktimes = concatenate(tf.fdbkOnsets{1});
    motifdur = median(tf.motifdurs);
    targetT = median(fdbktimes(fdbktimes>0 & fdbktimes<motifdur));
    
    prewin = 0.1; % [-100,0]ms window for pretarget modulation. default binsize = 4ms.
    newbinsize = 0.01;
    edges = tf.edges;
    rd = tf.rd;
    s =3;
    % here test if the max/min firing happens within pre-target window
    rds = smooth(rd,s);
    rds_motif = rds(edges>=0 & edges<=motifdur);
    edges_motif = edges(edges>=0 & edges<=motifdur);
    [~,i_min_motif] = min(rds_motif);
    t_min = edges_motif(i_min_motif);
    [~,i_max_motif] = max(rds_motif);
    t_max = edges_motif(i_max_motif);
    tf.t_min_motif = t_min;
    tf.t_max_motif = t_max;
    
    if t_max<targetT && t_max>=targetT-prewin
        tf.bPretargetMaxRate = 1;
    else
        tf.bPretargetMaxRate = 0;
    end
    
    if t_min<targetT && t_min>=targetT-prewin
        tf.bPretargetMinRate = 1;
    else
        tf.bPretargetMinRate = 0;
    end
    
    tf.nSigModulation.pretarget = length(find(tf.time_peaks<targetT&tf.time_peaks>=targetT-prewin))...
        +length(find(tf.time_trofs<targetT&tf.time_trofs>=targetT-prewin));

    events = tf.eventOnsets{1};
    offsets = tf.currTrigOffset;
    n_fakes = 1000;
    meanrate = dbase.rates.bout;
    rd_target = rate_dist(events,offsets,targetT,prewin,newbinsize);
    rds_target = smooth(rd_target,s);
    maxrate_pretarget = max(rds_target);
    minrate_pretarget = min(rds_target);
    moddepth = (maxrate_pretarget-minrate_pretarget)/meanrate;

    fModdepth = zeros([n_fakes,1]);
    bPreFtargetMaxRate = zeros([n_fakes,1]);
    bPreFtargetMinRate = zeros([n_fakes,1]);
    nSigModulationf = zeros([n_fakes,1]);
    for i_fake = 1:n_fakes
        fTargetT = rand(1)*motifdur;
        while abs(targetT-fTargetT)<prewin
            fTargetT = rand(1)*motifdur;
        end
        
        if t_max<fTargetT && t_max>=fTargetT-prewin
            bPreFtargetMaxRate(i_fake) = 1;
        else
            bPreFtargetMaxRate(i_fake) = 0;
        end
        
        if t_min<fTargetT && t_min>=fTargetT-prewin
            bPreFtargetMinRate(i_fake) = 1;
        else
            bPreFtargetMinRate(i_fake) = 0;
        end
        
        nSigModulationf(i_fake) = length(find(tf.time_peaks<fTargetT&tf.time_peaks>=fTargetT-prewin))...
        +length(find(tf.time_trofs<fTargetT&tf.time_trofs>=fTargetT-prewin));
        
        frd_target = rate_dist(events,offsets,fTargetT,prewin,newbinsize);
        frds_target = smooth(frd_target,s);
        fmax = max(frds_target);
        fmin = min(frds_target);
        fModdepth(i_fake) = (fmax-fmin)/meanrate;
    end
    

    tf.bPreFtargetMaxRate = bPreFtargetMaxRate;
    tf.bPreFtargetMinRate = bPreFtargetMinRate;
    tf.moddepth.pretarget = moddepth;
    tf.moddepth.preftarget = fModdepth;
    tf.nSigModulation.preftarget = nSigModulationf;
end

function rate = windrate(events,offsets,tStart,win)
    rate = 0;
    for i = 1:length(events)
        rate = rate + sum( (events{i}>=tStart & events{i}<tStart+win)...
            | (events{i} < (win+tStart-offsets(i)) &events{i}>0) );
    end
    rate = rate/length(events)/win;
end


function rates = windrates(events,offsets,tStart,win)
    rates = zeros([length(events),1]);
    for i = 1:length(events)
        rates(i) = sum( (events{i}>=tStart & events{i}<tStart+win)...
            | events{i}< (win+tStart-offsets(i)))/win;
    end
end

function rd = rate_dist(events,offsets,targetT,prewin,binsize)
    allevents = concatenate(events);
    edges = targetT-prewin:binsize:targetT-binsize;
    rd = histc(allevents,edges);
    rd = rd/length(events);
    rd = rd/binsize;
    rd = rd(1:end-1);
end
    
    