function dbase = ad_ephys_analysis(dbase, foldname, name_dbase, bMovement, bBOS)
    disp(name_dbase);

    % set path for where the dbase file is located and make the title field    
    dbase.dbasePathNameAD=[foldname name_dbase];
    dbase.title=name_dbase;
%     if isempty(strfind(dbase.PathName,'C:\'))
%         dbase.PathName = ['C:\Users\ad943\Documents\Data analysis\' dbase.PathName(7:end)];
%     end
%     ind_VP = strfind(dbase.PathName, 'VP');
%     if isempty(ind_VP)
%         ind_VP = strfind(dbase.PathName, 'BF birds'); 
%         if isempty(ind_VP)
%             disp(['check pathname: ' dbase.title])
%         return
%         end
%         ind_VP = ind_VP + 6;
%     end
    dbase.BirdID = name_dbase(6:9); % dbase.PathName(ind_VP+3:ind_VP+6); 
%     dbase.BirdID = '2810';
  
        
    %make motif and fdbkmotif
    BirdIDMotif ={...
                '3120' {'abcde'};...
                '0318' {'iabc'};...
                };      
            
    BirdIDfdbkMotif ={...
                '3120' {'abcdE',};...
                '0318' {'iabC'};...
                };
                
                
%     %make the BirdIDMoveThresh field
%     BirdIDMoveThresh ={...
%                 '2442' '0.0044064';...
%                 };
    
    % make the fdbksyll field
    BirdIDfdbksyll = {'3120' 'E';...
                      '0318' 'C';... 
                      };
    
%     dbaseIDcatchsyllBOS = {'077' 'o';...
%                       };           
                  
%     dbaseIDfdbksyllBOS = {'077' 'V';...
%                       }; 
                  
%     BirdIDMotifBOS ={...
%                 '149' {'iiiabyde'};...
%                 };
                  
%     BirdIDfdbkMotifBOS ={...
%                 '149' {'iiiabYde'};...
%                 };        
            
%     dbaseISfdbkdelayBOS = {'103' 0.1;...
%                       };
                  
    TF = strcmp(dbase.BirdID, BirdIDfdbksyll);
    ind_fdbk = find(TF(:,1));
    fdbksyll = BirdIDfdbksyll{ind_fdbk,2};
    dbase.fdbksyll = fdbksyll;
    dbase.catchsyll = lower(dbase.fdbksyll);
    % for when target changed
    ind_hitsyll = strfind(name_dbase, 'hitting');
    if ~isempty(ind_hitsyll)
        dbase.fdbksyll = name_dbase(ind_hitsyll+7);
        dbase.catchsyll = lower(dbase.fdbksyll);
    end
    
%     % for second target (lower fdbk probability)
%     TF2 = strcmp(dbase.BirdID, BirdIDfdbksyll2);
%     ind_fdbk2 = find(TF2(:,1));
%     if ~isempty(ind_fdbk2)
%         fdbksyll2 = BirdIDfdbksyll2{ind_fdbk2,2};
%         dbase.fdbksyll2 = fdbksyll2;
%     end
    
    % set motif and fdbkmotif
    TF3 = strcmp(dbase.BirdID, BirdIDMotif);
    ind_motif = find(TF3(:,1));
    if ~isempty(ind_motif)
        motif = BirdIDMotif{ind_motif,2};
        dbase.motif = motif;
    end
    TF4 = strcmp(dbase.BirdID, BirdIDfdbkMotif);
    ind_fdbkmotif = find(TF4(:,1));
    if ~isempty(ind_motif)
        fdbkmotif = BirdIDfdbkMotif{ind_fdbkmotif,2};
        dbase.fdbkmotif = fdbkmotif;
    end
    
%     if bBOS    
%         % BOS playback catch/fdbk syll names
%         TF5 = strcmp(dbase.num, dbaseIDfdbksyllBOS);
%         ind_fdbk = find(TF5(:,1));
%         fdbksyll = dbaseIDfdbksyllBOS{ind_fdbk,2};
%         dbase.BOSfdbksyll = fdbksyll;
%         dbase.fdbksyll = fdbksyll;
% 
%         TF6 = strcmp(dbase.num, dbaseIDcatchsyllBOS);
%         ind_fdbk = find(TF6(:,1));
%         catchsyll = dbaseIDcatchsyllBOS{ind_fdbk,2};
%         dbase.BOScatchsyll = catchsyll;
%         dbase.catchsyll = catchsyll;
%         
%         TF7 = strcmp(dbase.num, BirdIDMotifBOS);
%         ind_fdbk = find(TF7(:,1));
%         BOSmotif = BirdIDMotifBOS{ind_fdbk,2};
%         dbase.BOSmotif = BOSmotif;
%         dbase.motif = BOSmotif;
%         
%         TF8 = strcmp(dbase.num, BirdIDfdbkMotifBOS);
%         ind_fdbk = find(TF8(:,1));
%         BOSfdbkmotif = BirdIDfdbkMotifBOS{ind_fdbk,2};
%         dbase.BOSfdbkmotif = BOSfdbkmotif;     
%         dbase.fdbkmotif = BOSfdbkmotif;
%         
%         % get timing of target by efference copy
%         
%     end
    
    % remove all sylls not named. for bird 3308. RC 1/18/18
    %dbase = rc_dbaseRemoveEmptySylls(dbase);
    
    dbase=rcm_dbaseGetIndices(dbase);
    dbase=rc_dbaseGetUnusables(dbase);
            
    dbase=vgm_dbaseBoutNonsongISI(dbase,dbase.indx);    
    [filestarttimes, fileendtimes, dbase.syllstarttimes, dbase.syllendtimes,...
        dbase.sylldurs, preintrvl, postintrvl, allintrvls, dbase.syllnames]...
        = vgm_dbaseGetSylls(dbase);
    dbase.filestarttimes=filestarttimes;
    dbase.fileendtimes=fileendtimes;
    dbase.allsyllnames=cell2mat(concatenate(dbase.syllnames));
    ind_i = zeros(1,length(dbase.allsyllnames));
    ind_i(strfind(dbase.allsyllnames,'i')) = 1;
    dbase.motifsyllnames=dbase.allsyllnames(~ind_i);
    allstarttimes = cell2mat(dbase.syllstarttimes);
    dbase.motifstarttimes = allstarttimes(~ind_i);

    dbase = vgm_dbaseMakeBoutSylls(dbase);
%     dbase = rc_dbasespikewidth(dbase,1);
    dbase = rcm_ISIdist(dbase,0);
    
    
%     % BOS related fields
%     if bBOS
%         dbase = rc_dbaseMakeBOSSylls(dbase);
%     end

%     lag=0.25;%Lag, in seconds, of how far out you want to plot
%     bplot1=0; %if you want to plot the autocorr; 0 if you don't want to
%     for binsize = [0.005 0.01 0.025 0.05]
%         [dbase] = rcm_dbaseSpikeTrainAutocorrelation(dbase, lag, bplot1, binsize);
%     end
    
    % infrastructure for error-related analyses -- below we define
    % medianfdbk time as zero
    dbase.allsyllstarts=concatenate(dbase.syllstarttimes);
    dbase.allsyllends=concatenate(dbase.syllendtimes);
    dbase.allsyllnames=concatenate(concatenate(dbase.syllnames));
    dbase.allfdbks=concatenate(dbase.fdbktimes);
    dbase.hitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.fdbksyll));
    dbase.hitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.fdbksyll));
    dbase.catchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.catchsyll));
    dbase.catchsyllends=dbase.allsyllends(find(dbase.allsyllnames==dbase.catchsyll)); 
    
  
    % first target: calculate delays from syll onset to fdbk onset
    d=[];
    cent = 0.025;
    for j=1:length(dbase.hitsyllstarts);
        ind_fdbk = find((dbase.allfdbks+cent)-dbase.hitsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.hitsyllends(j) < 0);
        if length(ind_fdbk) ~= 1 && ~bBOS
            error(['check fdbktimes in ' dbase.title])
        end
        delay = dbase.allfdbks(ind_fdbk) - dbase.hitsyllstarts(j);
        d = [d delay];
    end
    dbase.fdbkdelays=d; %all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses

%     % fields specific to second target
%     if isfield(dbase,'fdbksyll2')
%         dbase.hitsyllstarts2=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.fdbksyll2));
%         dbase.hitsyllends2 = dbase.allsyllends(find(dbase.allsyllnames==dbase.fdbksyll2));
%         dbase.catchsyllstarts2=dbase.allsyllstarts(find(dbase.allsyllnames==lower(dbase.fdbksyll2)));
%         dbase.catchsyllends2=dbase.allsyllends(find(dbase.allsyllnames==lower(dbase.fdbksyll2))); 
%         d2=[];
%         cent2 = 0.025;
%         for j=1:length(dbase.hitsyllstarts2);
%             ind_fdbk2 = find((dbase.allfdbks+cent2)-dbase.hitsyllstarts2(j) > 0 & (dbase.allfdbks+cent2)-dbase.hitsyllends2(j) < 0);
%             if length(ind_fdbk2) ~= 1
%                 error(['check fdbktimes in ' dbase.title '; hitsyll2 no. ' num2str(j)])
%             end
%             delay2 = dbase.allfdbks(ind_fdbk2) - dbase.hitsyllstarts2(j);
%             d2 = [d2 delay2];
%         end
%         dbase.fdbkdelays2=d2;
%     end    
%     
%     % fields specific to BOS
%     if bBOS
%         if strcmp(dbase.num,'091')
%             dbase.BOShitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOSfdbksyll|dbase.allsyllnames=='W'));
%             dbase.BOShitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.BOSfdbksyll|dbase.allsyllnames=='W'));
%             dbase.BOScatchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOScatchsyll));
%             dbase.BOScatchsyllends=dbase.allsyllends(find(dbase.allsyllnames==dbase.BOScatchsyll));
%         else
%             dbase.BOShitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOSfdbksyll));
%             dbase.BOShitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.BOSfdbksyll));
%             dbase.BOScatchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOScatchsyll));
%             dbase.BOScatchsyllends=dbase.allsyllends(find(dbase.allsyllnames==dbase.BOScatchsyll));
%         end
%         dbase.fdbkdelays = zeros(length(dbase.hitsyllends),1);
%         dbasedir = 'C:\Users\GLab\Box Sync\VP_dbases\sortedRCandPavel\';
%         dbase2name = dir([dbasedir dbase.num '*']);
%         dbase2 = load([dbasedir dbase2name.name]);
%         dbase.fdbkdelays = median(dbase2.dbase.fdbkdelays) * ones(1,length(dbase.hitsyllends));
%         if strcmp(dbase.num,'118')
%             dbase.fdbkdelays = 0.275* ones(1,length(dbase.hitsyllends));
%         end
%         dbase.catchdelays = dbase.fdbkdelays;
%     end
    
    % forced fdbk
    dbase.Zsyllstarts = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
    dbase.Zsyllends = dbase.allsyllends(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
    dZ=[];
    cent = 0.025;
    for j=1:length(dbase.Zsyllstarts);
        ind_Z = find((dbase.allfdbks+cent)-dbase.Zsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.Zsyllends(j) < 0);
        if length(ind_Z) ~= 1 && ~bBOS
            error(['check Z times in ' dbase.title ' Z number ' num2str(j)])
        end
        delayZ = dbase.allfdbks(ind_Z) - dbase.Zsyllstarts(j);
        dZ = [dZ delayZ];
    end
    dbase.Zfdbkdelays=dZ;%all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses
    
%     if ~bBOS
    dbase = vgm_dbaseMakeMidBoutEnd(dbase);
%     end
    dbase = vgm_getwinrates(dbase, 0.075);    
    % code from jesse
    if ~bBOS
        lag=.3;
        bPlot1 = 0;
        binsize = 0.00025;
        thres = 250;
        dbase = rcm_dbaseSpikeTrainAutocorrelation(dbase,lag,bPlot1,binsize);
        [dbase.ifrspec]=xdbaseFFTonIFRs2(dbase);
        [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
        [dbase]=xsdbaseBurstDetector(dbase,thres); 
    end
    

    %below exlude any event that has filestarts, fileends, or stims within the xlim
            
%     %% To NOT exclude filestarttimes and fileendtimes that overlap
    filestarttimes = dbase.filestarttimes;
    fileendtimes = dbase.fileendtimes;
    ind_overlap = dbase.filestarttimes(2:end)-dbase.fileendtimes(1:end-1) > eps;
    ind_overlap_start = [true ind_overlap];
    ind_overlap_end = [ind_overlap true];
    filestarttimes_exclude = filestarttimes(ind_overlap_start);
    fileendtimes_exclude = fileendtimes(ind_overlap_end);

    %To NOT exclude boutstarts and boutends that overlap
    boutstarts = concatenate(dbase.boutstarts);
    boutends = concatenate(dbase.boutends);
    ind_overlap_bout = boutstarts(2:end)-boutends(1:end-1) > eps;
    ind_overlap_bout_start = [true ind_overlap_bout];
    ind_overlap_bout_end = [ind_overlap_bout true];
    boutstarts_exclude = boutstarts(ind_overlap_bout_start);
    boutends_exclude = boutends(ind_overlap_bout_end);

    exclude_default=sort([filestarttimes_exclude fileendtimes_exclude concatenate(dbase.stimtimes)]);
    Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
    Istarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'I' | dbase.allsyllnames == 'i');
    Lstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'L' | dbase.allsyllnames == 'l');
    Qstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Q' | dbase.allsyllnames == 'q');
    
    %% now make all the trigInfos!
%     % all syll onset, including syll names and syll duration.
    dbase = rcm_dbaseMakeTrigInfosyll(dbase);
%     
%     % motif aligned triginfo
    [dbase]=rcm_dbaseMakeTrigInfomotif(dbase,dbase.motif,dbase.fdbkmotif);
    [dbase]=rcm_dbaseMakeTrigInfomotif_caseInsensitive(dbase,dbase.motif);    
    tf = dbase.trigInfomotifCaseI.notwarped{1};
    fdbktimes = concatenate(tf.fdbkOnsets{1});
    motifdur = median(tf.motifdurs);
    targetT = median(fdbktimes(fdbktimes>0 & fdbktimes<motifdur));
    dbase.targetT = targetT;
    dbase.motifdur = motifdur;
%     
    binsize=.025;
    xl=1.05;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
    bplot=0;%change this to 1 if you want to plot each raster

    %Hits midbout
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts_midbout+dbase.fdbkdelays_midbout;
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoFhit_midbout = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    if ~isempty(dbase.trigInfoFhit_midbout.edges)
        dbase.trigInfoFhit_midbout = vgm_MonteCarloFlex(dbase.trigInfoFhit_midbout);
    end

    %Hits that terminate bout
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts_endbout+dbase.fdbkdelays_endbout;
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoFhit_endbout = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    if ~isempty(dbase.trigInfoFhit_endbout.edges)
        dbase.trigInfoFhit_endbout = vgm_MonteCarloFlex(dbase.trigInfoFhit_endbout);
    end

    %Catches midbout
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts_midbout+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfocatch_midbout = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    if ~isempty(dbase.trigInfocatch_midbout.edges)
        dbase.trigInfocatch_midbout = vgm_MonteCarloFlex(dbase.trigInfocatch_midbout);
    end

    %Catches that terminate bout
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts_endbout+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfocatch_endbout = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    if ~isempty(dbase.trigInfocatch_endbout.edges)
        dbase.trigInfocatch_endbout = vgm_MonteCarloFlex(dbase.trigInfocatch_endbout);
    end

    %Hit syll spikes (time 0 is the time of the median fdbk)
    clear trigger events exclude;
    xl=1.05;%
    bplot=0;%
    trigger = dbase.hitsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    for binsize = [0.005,0.01,.02,0.025,0.3]
    	trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo); 
%         % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);        
        dbase.(['trigInfohitbin' num2str(binsize*1000)]) = trigInfo; 
    end
    %Hit syll spikes (time 0 is the time of the actual fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+dbase.fdbkdelays; % no median here
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    for binsize = [0.005,0.01,.02,0.025,0.3]
    	trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo); 
%         % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
        dbase.(['trigInfoFhitbin' num2str(binsize*1000)]) = trigInfo; 
    end
   
    %Catch syll spikes
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    for binsize = [0.005,0.01,.02,0.025,0.3]
    	trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo); 
%         % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);        
        dbase.(['trigInfocatchbin' num2str(binsize*1000)]) = trigInfo; 
    end    

    % target 2:
    if isfield(dbase,'fdbksyll2') && ~isempty(dbase.hitsyllstarts2)
        binsize=.025;
        xl=1.05;%
        bplot=0;%
        
        %Hit syll spikes (time 0 is the time of the actual fdbk)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+dbase.fdbkdelays2; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo); 
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo); 
            dbase.(['trigInfoFhit2bin' num2str(binsize*1000)]) = trigInfo; 
        end

        %Hit syll spikes (time 0 is the time of the median fdbk)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo); 
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo); 
            dbase.(['trigInfohit2bin' num2str(binsize*1000)]) = trigInfo; 
        end

        %Catch syll spikes
        clear trigger events exclude;
        trigger = dbase.catchsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo); 
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo); 
            dbase.(['trigInfocatch2bin' num2str(binsize*1000)]) = trigInfo; 
        end
    end
    
    if bBOS
        clear trigger events exclude;
        xl=1.05;%
        bplot=0;%
        trigger = dbase.BOShitsyllstarts + median(dbase.fdbkdelays);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo); 
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo); 
            dbase.(['trigInfoBOShitbin' num2str(binsize*1000)]) = trigInfo; 
        end

        clear trigger events exclude;
        xl=1.05;%
        bplot=0;%
        trigger = dbase.BOScatchsyllstarts + median(dbase.catchdelays);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo); 
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo); 
            dbase.(['trigInfoBOScatchbin' num2str(binsize*1000)]) = trigInfo; 
        end
    end

    %Hit syll spikes (time 0 is the time of the median fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfohitbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfohitbin05 = vgm_MonteCarloFlex(dbase.trigInfohitbin05);

    %Hit syll spikes (time 0 is the time of the actual fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+dbase.fdbkdelays; % no median here
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoFhitbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoFhitbin05 = vgm_MonteCarloFlex(dbase.trigInfoFhitbin05);

    %Catch syll spikes
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfocatchbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfocatchbin05 = vgm_MonteCarloFlex(dbase.trigInfocatchbin05);

    %Z spikes
    if ~isempty(dbase.Zsyllstarts) && ~bBOS
        binsize=.025;
        xl=1.025;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
        bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping

        clear trigger events exclude;
        trigger = dbase.Zsyllstarts+dbase.Zfdbkdelays;
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfoZbin25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoZbin25 = vgm_MonteCarloFlex(dbase.trigInfoZbin25);
        
        binsize=.01;
        xl=1.025;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
        bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping

        clear trigger events exclude;
        trigger = dbase.Zsyllstarts+dbase.Zfdbkdelays;
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfoZbin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoZbin10 = vgm_MonteCarloFlex(dbase.trigInfoZbin25);        
    end

    % Song syll onsets and offsets
    % Trigger: song syllable onsets and offsets
    % Events: spikes
    % Exclude: default + Z
    % all bout syll onset and offsets
    xl=0.325;
    bplot=0;
    clear trigger events exclude;
    events = concatenate(dbase.spiketimes);
    exclude= sort([exclude_default Zstarttimes Istarttimes Lstarttimes]);
    for binsize = [0.005, 0.025]
        trigger=dbase.motifstarttimes;
        dbase.(['trigInfoBoutSyllOnsetsSpikes' num2str(binsize*1000)])=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.(['trigInfoBoutSyllOnsetsSpikes' num2str(binsize*1000)]) = vgm_MonteCarloFlex(dbase.(['trigInfoBoutSyllOnsetsSpikes' num2str(binsize*1000)]));
        dbase.(['trigInfoBoutSyllOnsetsSpikes' num2str(binsize*1000)]) = vgm_reliability(dbase,dbase.(['trigInfoBoutSyllOnsetsSpikes' num2str(binsize*1000)]),'bout');
        trigger=dbase.motifstarttimes;
        dbase.(['trigInfoBoutSyllOffsetsSpikes' num2str(binsize*1000)]) =vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.(['trigInfoBoutSyllOffsetsSpikes' num2str(binsize*1000)]) = vgm_MonteCarloFlex(dbase.(['trigInfoBoutSyllOffsetsSpikes' num2str(binsize*1000)]));
        dbase.(['trigInfoBoutSyllOffsetsSpikes' num2str(binsize*1000)]) = vgm_reliability(dbase,dbase.(['trigInfoBoutSyllOffsetsSpikes' num2str(binsize*1000)]),'bout');
    end
    
    xl = 0.325;
    bplot = 0;
    clear trigger events exclude;
    trigger=concatenate(dbase.boutsyllstarttimes);
    events = concatenate(dbase.spiketimes);
    exclude=[exclude_default Zstarttimes boutstarts_exclude boutends_exclude];
    for binsize = [0.005,0.01,.02,0.025,0.3]
        trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.(['trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds' num2str(binsize*1000)]) = trigInfo;
    end
    trigger=concatenate(dbase.boutsyllendtimes);
    for binsize = [0.005,0.01,.02,0.025,0.3]
        trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.(['trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds' num2str(binsize*1000)]) = trigInfo;
    
    end
    
    
    binsize=.025;
    xl = 1.05;
    bplot = 0;

    % Song syll onsets and offsets
    % Trigger: song syllable onsets and offsets
    % Events: spikes
    % Exclude: default + Z
    clear trigger events exclude;
    trigger=concatenate(dbase.boutsyllstarttimes);
    events = concatenate(dbase.spiketimes);
    exclude=[exclude_default Zstarttimes];
    dbase.trigInfoBoutSyllOnsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutSyllOnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikes);
    dbase.trigInfoBoutSyllOnsetsSpikes = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikes,'bout');
    trigger=concatenate(dbase.boutsyllendtimes);
    dbase.trigInfoBoutSyllOffsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutSyllOffsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikes);
    dbase.trigInfoBoutSyllOffsetsSpikes = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikes,'bout');

    binsize=.025;
    xl = 0.325;
    bplot = 0;
    

    % Song syll onsets and offsets no bout ons and offs 
    % Trigger: song syllable onsets and offsets 
    % Events: spikes
    % Exclude: default + Z start + bout onsets and offsets
    clear trigger events exclude;
    trigger=concatenate(dbase.boutsyllstarttimes);
    events = concatenate(dbase.spiketimes);
    exclude=[exclude_default Zstarttimes boutstarts_exclude boutends_exclude];
    dbase.trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds);
    dbase.trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikesNoBoutStartsBoutEnds,'bout');
    trigger=concatenate(dbase.boutsyllendtimes);
    dbase.trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds);
    dbase.trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikesNoBoutStartsBoutEnds,'bout');

    % histogram centered on feedback time.

    xl=1.05;%
    bplot=0;%
    %Hit syll spikes (time 0 is the time of the actual fdbk)
    clear trigger events exclude;
    triggerHit = dbase.hitsyllstarts+median(dbase.fdbkdelays);
    triggerCatch = dbase.catchsyllstarts+median(dbase.fdbkdelays);
    trigger = [triggerHit triggerCatch];
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    for binsize = [0.01]
        trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo); 
%         trigInfo = rc_dbaseMonteCarloNPeaks_target(dbase,trigInfo);
        dbase.(['trigInfoTargetbin' num2str(binsize*1000)]) = trigInfo; 
    end
    
    % bout offset [-1,1]
    clear trigger events exclude;
    xl=1.05;%
    bplot=0;%
    binsize = 0.004;
    boutends = concatenate(dbase.boutends);
    trigger = boutends;
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoBoutend = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutend.rate500 = mean(dbase.trigInfoBoutend.rd(dbase.trigInfoBoutend.edges>0&dbase.trigInfoBoutend.edges<0.5));
    dbase.trigInfoBoutend.rate1000 = mean(dbase.trigInfoBoutend.rd(dbase.trigInfoBoutend.edges>0&dbase.trigInfoBoutend.edges<1));
%     dbase.trigInfoBoutend.rate1to2k = mean(dbase.trigInfoBoutend.rd(dbase.trigInfoBoutend.edges>1&dbase.trigInfoBoutend.edges<2));
    dbase.trigInfoBoutend.ratio500 = dbase.trigInfoBoutend.rate500/dbase.rates.bout;
    dbase.trigInfoBoutend.ratio1000 = dbase.trigInfoBoutend.rate1000/dbase.rates.bout;
%     dbase.trigInfoBoutend.ratio1to2k = dbase.trigInfoBoutend.rate1to2k/dbase.rates.bout;
    
    % bout onset [-1,1]
    clear trigger events exclude;
    xl=1.05;%
    bplot=0;%
    binsize = 0.004;
    boutstarts = concatenate(dbase.boutstarts);
    trigger = boutstarts;
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoBoutstart = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoBoutstart.rate500 = mean(dbase.trigInfoBoutstart.rd(dbase.trigInfoBoutstart.edges>0&dbase.trigInfoBoutstart.edges<0.5));
    dbase.trigInfoBoutstart.rate1000 = mean(dbase.trigInfoBoutstart.rd(dbase.trigInfoBoutstart.edges>0&dbase.trigInfoBoutstart.edges<1));
    dbase.trigInfoBoutstart.ratio500 = dbase.trigInfoBoutstart.rate500/dbase.rates.bout;
    dbase.trigInfoBoutstart.ratio1000 = dbase.trigInfoBoutstart.rate1000/dbase.rates.bout;

    % new binsize for BFvta neuron
    binsize = .01;
    xl = 1.05;
    bplot = 0;
    %Hit syll spikes (time 0 is the time of the median fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfohitbin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfohitbin10 = vgm_MonteCarloFlex(dbase.trigInfohitbin10);

    %Hit syll spikes (time 0 is the time of the actual fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+dbase.fdbkdelays; % no median here
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoFhitbin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoFhitbin10 = vgm_MonteCarloFlex(dbase.trigInfoFhitbin10);

    %Catch syll spikes
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfocatchbin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfocatchbin10 = vgm_MonteCarloFlex(dbase.trigInfocatchbin10);
    if isfield(dbase,'fdbksyll2') && ~isempty(dbase.hitsyllstarts2)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfohit2bin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfohit2bin10 = vgm_MonteCarloFlex(dbase.trigInfohit2bin10);

        %Hit syll spikes (time 0 is the time of the actual fdbk)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+dbase.fdbkdelays2; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfoFhit2bin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoFhit2bin10 = vgm_MonteCarloFlex(dbase.trigInfoFhit2bin10);

        %Catch syll spikes
        clear trigger events exclude;
        trigger = dbase.catchsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfocatch2bin10 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfocatch2bin10 = vgm_MonteCarloFlex(dbase.trigInfocatch2bin10);
    end
    
    
% new binsize for timing neuron 5ms
    binsize = .005;
    xl = 1.05;
    bplot = 0;
    %Hit syll spikes (time 0 is the time of the median fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfohitbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfohitbin05 = vgm_MonteCarloFlex(dbase.trigInfohitbin05);

    %Hit syll spikes (time 0 is the time of the actual fdbk)
    clear trigger events exclude;
    trigger = dbase.hitsyllstarts+dbase.fdbkdelays; % no median here
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfoFhitbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfoFhitbin05 = vgm_MonteCarloFlex(dbase.trigInfoFhitbin05);

    %Catch syll spikes
    clear trigger events exclude;
    trigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
    events = concatenate(dbase.spiketimes);
    exclude = exclude_default;
    dbase.trigInfocatchbin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
    dbase.trigInfocatchbin05 = vgm_MonteCarloFlex(dbase.trigInfocatchbin05);
    if isfield(dbase,'fdbksyll2') && ~isempty(dbase.hitsyllstarts2)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfohit2bin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfohit2bin05 = vgm_MonteCarloFlex(dbase.trigInfohit2bin05);

        %Hit syll spikes (time 0 is the time of the actual fdbk)
        clear trigger events exclude;
        trigger = dbase.hitsyllstarts2+dbase.fdbkdelays2; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfoFhit2bin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoFhit2bin05 = vgm_MonteCarloFlex(dbase.trigInfoFhit2bin05);

        %Catch syll spikes
        clear trigger events exclude;
        trigger = dbase.catchsyllstarts2+median(dbase.fdbkdelays2);
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        dbase.trigInfocatch2bin05 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfocatch2bin05 = vgm_MonteCarloFlex(dbase.trigInfocatch2bin05);
    end    
    
    
    

% %     entroyp sparseness across all sylls
%     [dbase]=dbaseMakeTrigInfoEntropySparsenessM(dbase);
% %     modulation depth
%     dbase = rc_dbase_modulationdepth(dbase);
%     
%     tf = dbase.trigInfomotifCaseI.notwarped{1};
%     fdbktimes = concatenate(tf.fdbkOnsets{1});
%     motifdur = median(tf.motifdurs);
%     targetT = median(fdbktimes(fdbktimes>0 & fdbktimes<motifdur));
%     dbase.targetT = targetT;
%     dbase.motifdur = motifdur;
%     tf = dbase.trigInfoTargetbin10;
%     tf = rcm_dbaseTargetTimeAnalysis(dbase,tf);
%     dbase.trigInfoTargetbin10 = tf;
    
    
    if bBOS
        [dbase]=rcm_dbaseMakeTrigInfomotif(dbase,dbase.BOSmotif,dbase.BOSfdbkmotif);
        dbase = rc_dbaseBOS_playbacktimes(dbase);
    end
    %     make triginfo by efference copy detected events
    if bBOS
        clear trigger events exclude;
        trigger = dbase.hittimes_BB; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
%             % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
            dbase.(['trigInfoFhitBBbin' num2str(binsize*1000)]) = trigInfo;
        end
        clear trigger events exclude;
        trigger = dbase.hittimes_DAF; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
            dbase.(['trigInfoFhitDAFbin' num2str(binsize*1000)]) = trigInfo;
        end    
        clear trigger events exclude;
        trigger = dbase.catchtimes_BOS; % no median here
        events = concatenate(dbase.spiketimes);
        exclude = exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            % trigInfo = rc_dbaseMonteCarloNPeaks(trigInfo);
            dbase.(['trigInfocatchBOSbin' num2str(binsize*1000)]) = trigInfo;
        end
    end
    
    % movement analysis 
    if bMovement
        dbase = rc_dbaseGetMoveThresh(dbase);
        dbase = rcm_dbaseGetMoveRasterNoPresort(dbase);
        dbase = vgm_fusedoublemoves(dbase);
        dbase = vgm_dbaseMakeBoutMoves(dbase);
        
        xl = 0.325;
        bplot = 0;
        clear trigger events exclude;
        trigger=concatenate(dbase.boutmoveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutMoveOnsetsSpikesxl300' num2str(binsize*1000)]) = trigInfo;
        end
        trigger=concatenate(dbase.boutmoveoffsets);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutMoveOffsetsSpikesxl300' num2str(binsize*1000)]) = trigInfo;           
        end
        %% 
        xl = 1.05;
        bplot = 0;
        clear trigger events exclude;
        trigger=dbase.hitsyllstarts+median(dbase.fdbkdelays);
        events = concatenate(dbase.moveonsets);
        exclude=exclude_default;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfohitMovebin' num2str(binsize*1000)]) = trigInfo;
        end
        trigger=dbase.hitsyllstarts+dbase.fdbkdelays;
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoFhitMovebin' num2str(binsize*1000)]) = trigInfo;
        end
        trigger=dbase.catchsyllstarts+median(dbase.fdbkdelays);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfocatchMovebin' num2str(binsize*1000)]) = trigInfo;
        end

        xl = 1.05;
        bplot = 0;
        clear trigger events exclude;
        trigger=concatenate(dbase.boutmoveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes boutstarts_exclude boutends_exclude]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds' num2str(binsize*1000)]) = trigInfo;
        end
        %% 
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes dbase.allsyllstarts dbase.allsyllends]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOnsetsSpikesNoSylls' num2str(binsize*1000)]) = trigInfo;
        end
        trigger=concatenate(dbase.moveoffsets);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOffsetsSpikesNoSylls' num2str(binsize*1000)]) = trigInfo; 
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOnsetsSpikes' num2str(binsize*1000)]) = trigInfo; 
        end
        trigger=concatenate(dbase.moveoffsets);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOffsetsSpikes' num2str(binsize*1000)]) = trigInfo; 
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.boutsyllstarttimes) concatenate(dbase.boutsyllendtimes)]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOnsetsSpikesNoBoutSylls' num2str(binsize*1000)]) = trigInfo; 
        end
        trigger=concatenate(dbase.moveoffsets);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoMoveOffsetsSpikesNoBoutSylls' num2str(binsize*1000)]) = trigInfo; 
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.boutmoveonsets);
        events = concatenate(dbase.spiketimes);
        exclude = sort([exclude_default Zstarttimes]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutMoveOnsetsSpikes' num2str(binsize*1000)]) = trigInfo; 
        end
        trigger=concatenate(dbase.boutmoveoffsets);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutMoveOffsetsSpikes' num2str(binsize*1000)]) = trigInfo; 
        end
        
        
        xl = 0.225;
        clear trigger events exclude;
        trigger=Zstarttimes;
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoZOnsetsSpikesNoMoveOnsetsOffsets' num2str(binsize*1000)]) = trigInfo;
        end
        
        trigger=Zstarttimes;
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default concatenate(dbase.moveonsets)]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoZOnsetsSpikesNoMoveOnsets' num2str(binsize*1000)]) = trigInfo;
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.boutsyllstarttimes);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) boutstarts_exclude boutends_exclude]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds' num2str(binsize*1000)]) = trigInfo;
        end
        trigger=concatenate(dbase.boutsyllendtimes);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds' num2str(binsize*1000)]) = trigInfo;
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.boutsyllstarttimes);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutSyllOnsetsSpikesNoMoves' num2str(binsize*1000)]) = trigInfo;
        end
        
        clear trigger events exclude;
        trigger=concatenate(dbase.boutsyllendtimes);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
        for binsize = [0.005,0.01,.02,0.025,0.3]
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.(['trigInfoBoutSyllOffsetsSpikesNoMoves' num2str(binsize*1000)]) = trigInfo;
        end
        
        %% 4. Movement onsets and offset within song no boutons and offs
        % Trigger: movement onsets and offsets
        % Events: spikes
        % Exclude: bout onsets and offsets
        % default + Z
        xl = 0.325;
        binsize = 0.025;
        clear trigger events exclude;
        trigger=concatenate(dbase.boutmoveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes boutstarts_exclude boutends_exclude]);
        trigInfo =vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo);
        dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds=trigInfo;
        if ~isempty(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds.edges)
            trigInfo = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds);
            dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,trigInfo,'bout');
        end
        trigger=concatenate(dbase.boutmoveoffsets);
        trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        trigInfo = vgm_MonteCarloFlex(trigInfo);
        dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds = trigInfo;
        if ~isempty(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds.edges)
            trigInfo = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds);
            dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,trigInfo,'bout');
        end
        %% 7. Song syll onsets and offsets no movements
        % Trigger: song syllables onsets and offsets
        % Events: spikes
        % Exclude: default + Z + move onsets and offsets
        clear trigger events exclude;
        trigger=concatenate(dbase.boutsyllstarttimes);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
        dbase.trigInfoBoutSyllOnsetsSpikesNoMoves = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutSyllOnsetsSpikesNoMoves.edges)
            dbase.trigInfoBoutSyllOnsetsSpikesNoMoves = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikesNoMoves);
            dbase.trigInfoBoutSyllOnsetsSpikesNoMoves = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikesNoMoves,'bout');
        end
        trigger=concatenate(dbase.boutsyllendtimes);
        dbase.trigInfoBoutSyllOffsetsSpikesNoMoves=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutSyllOffsetsSpikesNoMoves.edges)
            dbase.trigInfoBoutSyllOffsetsSpikesNoMoves = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikesNoMoves);
            dbase.trigInfoBoutSyllOffsetsSpikesNoMoves = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikesNoMoves,'bout');
        end

        % 8. Song syll onsets and offsets no movements and no boutons
        % and offs
        % Trigger: song syllables onsets and offsets
        % Events: spikes
        % Exclude: default + Z + move onsets and offsets + bout onsets
        % and offsets
        clear trigger events exclude;
        trigger=concatenate(dbase.boutsyllstarttimes);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) boutstarts_exclude boutends_exclude]);
        dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds.edges)
            dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds);
            dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds,'bout');
        end
        trigger=concatenate(dbase.boutsyllendtimes);
        dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds.edges)
            dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds);
            dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds,'bout');
        end


        % 9. Movement onsets and offsets outside any vocalizations
        % Trigger: movement onsets and offsets 
        % Events: spikes
        % Exclude: default + Z + all syll onsets and all syll offsets
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes dbase.allsyllstarts dbase.allsyllends]);
        dbase.trigInfoMoveOnsetsSpikesNoSylls=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOnsetsSpikesNoSylls = vgm_MonteCarloFlex(dbase.trigInfoMoveOnsetsSpikesNoSylls);
        dbase.trigInfoMoveOnsetsSpikesNoSylls = vgm_reliability(dbase,dbase.trigInfoMoveOnsetsSpikesNoSylls,'silent');
        trigger=concatenate(dbase.moveoffsets);
        dbase.trigInfoMoveOffsetsSpikesNoSylls=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOffsetsSpikesNoSylls = vgm_MonteCarloFlex(dbase.trigInfoMoveOffsetsSpikesNoSylls);
        dbase.trigInfoMoveOffsetsSpikesNoSylls = vgm_reliability(dbase,dbase.trigInfoMoveOffsetsSpikesNoSylls,'silent');

        % 1. All movement onsets and offsets
        % Trigger: all movement onsets and offsets 
        % Events: spikes
        % Exclude: default + Z
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes]);
        dbase.trigInfoMoveOnsetsSpikes = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoMoveOnsetsSpikes);
        dbase.trigInfoMoveOnsetsSpikes = vgm_reliability(dbase,dbase.trigInfoMoveOnsetsSpikes,'all');
        trigger=concatenate(dbase.moveoffsets);
        dbase.trigInfoMoveOffsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOffsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoMoveOffsetsSpikes);
        dbase.trigInfoMoveOffsetsSpikes = vgm_reliability(dbase,dbase.trigInfoMoveOffsetsSpikes,'all');

        % 2. Movement onsets and offsets outside song
        % Trigger: movement onsets and offsets 
        % Events: spikes
        % Exclude: default + Z + bout syll onsets and bout syll offsets
        clear trigger events exclude;
        trigger=concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude=sort([exclude_default Zstarttimes concatenate(dbase.boutsyllstarttimes) concatenate(dbase.boutsyllendtimes)]);
        dbase.trigInfoMoveOnsetsSpikesNoBoutSylls=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOnsetsSpikesNoBoutSylls = vgm_MonteCarloFlex(dbase.trigInfoMoveOnsetsSpikesNoBoutSylls);
        dbase.trigInfoMoveOnsetsSpikesNoBoutSylls = vgm_reliability(dbase,dbase.trigInfoMoveOnsetsSpikesNoBoutSylls,'silent');
        trigger=concatenate(dbase.moveoffsets);
        dbase.trigInfoMoveOffsetsSpikesNoBoutSylls=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        dbase.trigInfoMoveOffsetsSpikesNoBoutSylls = vgm_MonteCarloFlex(dbase.trigInfoMoveOffsetsSpikesNoBoutSylls);
        dbase.trigInfoMoveOffsetsSpikesNoBoutSylls = vgm_reliability(dbase,dbase.trigInfoMoveOffsetsSpikesNoBoutSylls,'silent');

        % 3. Movement onsets and offset within song
        % Trigger: movement onsets and offsets
        % Events: spikes
        % default + Z
        clear trigger events exclude;
        trigger=concatenate(dbase.boutmoveonsets);
        events = concatenate(dbase.spiketimes);
        exclude = sort([exclude_default Zstarttimes]);
        dbase.trigInfoBoutMoveOnsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutMoveOnsetsSpikes.edges)
            dbase.trigInfoBoutMoveOnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOnsetsSpikes);
            dbase.trigInfoBoutMoveOnsetsSpikes = vgm_reliability(dbase,dbase.trigInfoBoutMoveOnsetsSpikes,'bout');
        end
        trigger=concatenate(dbase.boutmoveoffsets);
        dbase.trigInfoBoutMoveOffsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
        if ~isempty(dbase.trigInfoBoutMoveOffsetsSpikes.edges)
            dbase.trigInfoBoutMoveOffsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOffsetsSpikes);
            dbase.trigInfoBoutMoveOffsetsSpikes = vgm_reliability(dbase,dbase.trigInfoBoutMoveOffsetsSpikes,'bout');
        end


        if isfield(dbase,'trigInfoMoveOnsetsSpikesNoSylls')
            % 1. All movement onsets and offsets
            % Trigger: all movement onsets and offsets 
            % Events: spikes
            % Exclude: default + Z
            clear trigger events exclude;
            trigger=concatenate(dbase.moveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Qstarttimes Zstarttimes]);
            dbase.trigInfoMoveOnsetsSpikes25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfoMoveOnsetsSpikes25 = vgm_MonteCarloFlex(dbase.trigInfoMoveOnsetsSpikes25);
            dbase.trigInfoMoveOnsetsSpikes25 = vgm_reliability(dbase,dbase.trigInfoMoveOnsetsSpikes25,'all');
            trigger=concatenate(dbase.moveoffsets);
            dbase.trigInfoMoveOffsetsSpikes25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfoMoveOffsetsSpikes25 = vgm_MonteCarloFlex(dbase.trigInfoMoveOffsetsSpikes25);
            dbase.trigInfoMoveOffsetsSpikes25 = vgm_reliability(dbase,dbase.trigInfoMoveOffsetsSpikes25,'all');

            % 2. Movement onsets and offsets outside song
            % Trigger: movement onsets and offsets 
            % Events: spikes
            % Exclude: default + Z + bout syll onsets and bout syll offsets
            clear trigger events exclude;
            trigger=concatenate(dbase.moveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Qstarttimes Zstarttimes concatenate(dbase.boutsyllstarttimes) concatenate(dbase.boutsyllendtimes)]);
            trigInfo = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.trigInfoMoveOnsetsSpikesNoBoutSylls25 = vgm_reliability(dbase,trigInfo,'silent');
            trigger=concatenate(dbase.moveoffsets);
            trigInfo=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            trigInfo = vgm_MonteCarloFlex(trigInfo);
            dbase.trigInfoMoveOffsetsSpikesNoBoutSylls25 = vgm_reliability(dbase,trigInfo,'silent');

            % 3. Movement onsets and offset within song
            % Trigger: movement onsets and offsets
            % Events: spikes
            % default + Z
            clear trigger events exclude;
            trigger=concatenate(dbase.boutmoveonsets);
            events = concatenate(dbase.spiketimes);
            exclude = sort([exclude_default Zstarttimes Qstarttimes]);
            dbase.trigInfoBoutMoveOnsetsSpikes25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOnsetsSpikes25.edges)
                dbase.trigInfoBoutMoveOnsetsSpikes25 = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOnsetsSpikes25);
                dbase.trigInfoBoutMoveOnsetsSpikes25 = vgm_reliability(dbase,dbase.trigInfoBoutMoveOnsetsSpikes25,'bout');
            end
            trigger=concatenate(dbase.boutmoveoffsets);
            dbase.trigInfoBoutMoveOffsetsSpikes25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOffsetsSpikes25.edges)
                dbase.trigInfoBoutMoveOffsetsSpikes25 = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOffsetsSpikes25);
                dbase.trigInfoBoutMoveOffsetsSpikes25 = vgm_reliability(dbase,dbase.trigInfoBoutMoveOffsetsSpikes25,'bout');
            end

            % 4. Movement onsets and offset within song no boutons and offs
            % Trigger: movement onsets and offsets
            % Events: spikes
            % Exclude: bout onsets and offsets
            % default + Z
            clear trigger events exclude;
            trigger=concatenate(dbase.boutmoveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Zstarttimes Qstarttimes boutstarts_exclude boutends_exclude]);
            dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25.edges)
                dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25 = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25);
                dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25 = vgm_reliability(dbase,dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds25,'bout');
            end
            trigger=concatenate(dbase.boutmoveoffsets);
            dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25.edges)
                dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25 = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25);
                dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25 = vgm_reliability(dbase,dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds25,'bout');
            end
            % 7. Song syll onsets and offsets no movements
            % Trigger: song syllables onsets and offsets
            % Events: spikes
            % Exclude: default + Z + move onsets and offsets
            clear trigger events exclude;
            trigger=concatenate(dbase.boutsyllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Zstarttimes Qstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
            dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25.edges)
                dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25 = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25);
                dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25 = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikesNoMoves25,'bout');
            end
            trigger=concatenate(dbase.boutsyllendtimes);
            dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25.edges)
                dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25 = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25);
                dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25 = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikesNoMoves25,'bout');
            end
            % 8. Song syll onsets and offsets no movements and no boutons
            % and offs
            % Trigger: song syllables onsets and offsets
            % Events: spikes
            % Exclude: default + Z + move onsets and offsets + bout onsets
            % and offsets
            clear trigger events exclude;
            trigger=concatenate(dbase.boutsyllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Zstarttimes Qstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) boutstarts_exclude boutends_exclude]);
            dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25.edges)
                dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25 = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25);
                dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25 = vgm_reliability(dbase,dbase.trigInfoBoutSyllOnsetsSpikesNoMovesBoutStartsBoutEnds25,'bout');
            end
            trigger=concatenate(dbase.boutsyllendtimes);
            dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25.edges)
                dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25 = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25);
                dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25 = vgm_reliability(dbase,dbase.trigInfoBoutSyllOffsetsSpikesNoMovesBoutStartsBoutEnds25,'bout');
            end
            % 9. Movement onsets and offsets outside any vocalizations
            % Trigger: movement onsets and offsets 
            % Events: spikes
            % Exclude: default + Z + all syll onsets and all syll offsets
            clear trigger events exclude;
            trigger=concatenate(dbase.moveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Zstarttimes Qstarttimes dbase.allsyllstarts dbase.allsyllends]);
            dbase.trigInfoMoveOnsetsSpikesNoSylls25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfoMoveOnsetsSpikesNoSylls25 = vgm_MonteCarloFlex(dbase.trigInfoMoveOnsetsSpikesNoSylls25);
            dbase.trigInfoMoveOnsetsSpikesNoSylls25 = vgm_reliability(dbase,dbase.trigInfoMoveOnsetsSpikesNoSylls25,'silent');
            trigger=concatenate(dbase.moveoffsets);
            dbase.trigInfoMoveOffsetsSpikesNoSylls25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfoMoveOffsetsSpikesNoSylls25 = vgm_MonteCarloFlex(dbase.trigInfoMoveOffsetsSpikesNoSylls25);
            dbase.trigInfoMoveOffsetsSpikesNoSylls25 = vgm_reliability(dbase,dbase.trigInfoMoveOffsetsSpikesNoSylls25,'silent');

        end
    end