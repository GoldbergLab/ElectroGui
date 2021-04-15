function dbase = rc_dbaseMakeStimRasters(dbase,binsize)
    dbase = rcm_dbaseGetIndices(dbase);
    stimtimes = concatenate(dbase.stimtimes);
    df_trig = [1 diff(stimtimes)];
    % trigger finds stim times that are not followed by another stim within
    % burst threshold bth = 10ms
    bth = 0.01;
    trigger = stimtimes(df_trig>bth);
    events = concatenate(dbase.spiketimes);
    filestarttimes = dbase.filestarttimes;
    fileendtimes = dbase.fileendtimes;
    ind_overlap = dbase.filestarttimes(2:end)-dbase.fileendtimes(1:end-1) > eps;
    ind_overlap_start = [true ind_overlap];
    ind_overlap_end = [ind_overlap true];
    filestarttimes_exclude = filestarttimes(ind_overlap_start);
    fileendtimes_exclude = fileendtimes(ind_overlap_end);
    exclude = sort([filestarttimes_exclude fileendtimes_exclude]);
    bplot = 0;
    xl = 1.03;
%     binsize = 0.025;
    trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    %trigInfo = vgm_MonteCarloFlex(trigInfo);
    dbase.trigInfoStimSpikes = trigInfo;
    
    trigger = concatenate(dbase.stimtimes);
    events = concatenate(dbase.spiketimes);
    thresh = 0.01;
    isi = diff(trigger);
    
    b_isi_burst = (isi<thresh);
    
    f = find(diff([0,b_isi_burst,0]==1));
    p = f(1:2:end-1);  % Start indices
    trigger_burst = trigger(p);
    bplot = 0;
    xl = 1.25;
%     binsize = 0.01;
    trigInfo = vgm_MakeTrigInfoFlex(trigger_burst, events, exclude,dbase, bplot,xl,binsize);
%     trigInfo=vgm_MonteCarloFlex(trigInfo);
    dbase.trigInfoStimBurstSpikes = trigInfo;
    
end