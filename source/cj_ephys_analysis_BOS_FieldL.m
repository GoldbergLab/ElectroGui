    function dbase = cj_ephys_analysis_BOS_FieldL(dbase,name_dbase, bMovement, bBOS)
    disp(name_dbase);
    % set path for where the dbase data is located and make the title field
    % for the dbase
    dbase_pathname = dbase.PathName;

    foldname = fullfile(dbase_pathname, '\')
    dbase.dbasePathNameAD=[foldname name_dbase];
    dbase.title=name_dbase;
    
    dbase.BirdID = name_dbase(6:9);
    
        %identify motif and fdbkmotif for each bird 
    BirdIDMotif ={...
        '0874' {'abcd'};...
        '0871' {'abcd'};...
        '0834' {'abcd'};...
        '0680' {'abcde'};...
        '0915' {'abcd'};...
        '0816' {'abcde'};...
        };

    BirdIDfdbkMotif ={...
        '0874' {'abCd'};...
        '0871' {'abCd'};...
        '0834' {'abcD'};...
        '0680' {'abcdE'};...
        '0915' {'abCd'};...
        '0816' {'aBcde'};...
        };
    
        % make the fdbksyll field
        BirdIDfdbksyll = {'3120' 'E';...
        '0874' 'C';...
        '0871' 'C';...
        '0834' 'D';...
        '0680' 'E';...
        '0915' 'C';...
        '0816' 'B';...
        };
    
         % Identify BOS syllables and motif for each bird
        dbaseIDcatchsyllBOS = {'0871' 'e';...
                          };

        dbaseIDfdbksyllBOS = {'0871' 'E';...
                          };

        BirdIDMotifBOS ={...
                    '0871' {'qwer'};...
                    };

        BirdIDfdbkMotifBOS ={...
                    '0871' {'qwEr'};...
                    };

%         dbaseISfdbkdelayBOS = {'103' 0.1;...
%                           };
    % get hit and catch syll
    TF = strcmp(dbase.BirdID, BirdIDfdbksyll);
    ind_fdbk = find(TF(:,1));
    fdbksyll = BirdIDfdbksyll{ind_fdbk,2};
    dbase.fdbksyll = fdbksyll;
    dbase.catchsyll = lower(dbase.fdbksyll);
    %%% for when target changed
%     ind_hitsyll = strfind(name_dbase, 'hitting');
%     if ~isempty(ind_hitsyll)
%         dbase.fdbksyll = name_dbase(ind_hitsyll+7);
%         dbase.catchsyll = lower(dbase.fdbksyll);
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
    
        if bBOS
            % BOS playback catch/fdbk syll names
            TF5 = strcmp(dbase.BirdID, dbaseIDfdbksyllBOS);
            ind_fdbk = find(TF5(:,1));
            dbase.BOSfdbksyll = dbaseIDfdbksyllBOS{ind_fdbk,2};
    
            TF6 = strcmp(dbase.BirdID, dbaseIDcatchsyllBOS);
            ind_fdbk = find(TF6(:,1));
            dbase.BOScatchsyll = dbaseIDcatchsyllBOS{ind_fdbk,2};
    
            TF7 = strcmp(dbase.BirdID, BirdIDMotifBOS);
            ind_fdbk = find(TF7(:,1));
            dbase.BOSmotif = BirdIDMotifBOS{ind_fdbk,2};
            
            TF8 = strcmp(dbase.BirdID, BirdIDfdbkMotifBOS);
            ind_fdbk = find(TF8(:,1));
            dbase.BOSfdbkmotif = BirdIDfdbkMotifBOS{ind_fdbk,2};
    
            % get timing of target by efference copy
    
        end

    % remove all sylls not named. for bird 3308. RC 1/18/18
    %dbase = rc_dbaseRemoveEmptySylls(dbase);
    
    dbase=rcm_dbaseGetIndices(dbase);
    dbase=rc_dbaseGetUnusables(dbase); %checks for bUnusable and bBOS
    
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
    %dbase = rc_dbasespikewidth(dbase,1);
    dbase = rcm_ISIdist(dbase,0); %change to 1 for plots of ISI distributions
    
            % BOS related fields
        if bBOS
            dbase = rc_dbaseMakeBOSSylls(dbase);
        end

        lag=0.25;%Lag, in seconds, of how far out you want to plot
        bplot1=0; %if you want to plot the autocorr; 0 if you don't want to
        for binsize = [0.005 0.01 0.025 0.05]
            [dbase] = rcm_dbaseSpikeTrainAutocorrelation(dbase, lag, bplot1, binsize);
        end

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
    cent = 0.01;
    for j=1:length(dbase.hitsyllstarts) %;  numel(dbase.allfdbks)
        ind_fdbk = find((dbase.allfdbks+cent)-dbase.hitsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.hitsyllends(j) < 0);
        if length(ind_fdbk) ~= 1 && ~bBOS
            error(['check fdbktimes in ' dbase.title])
        end
        delay = dbase.allfdbks(ind_fdbk) - dbase.hitsyllstarts(j);
%           delay = dbase.allfdbks(j) - dbase.hitsyllstarts(j);
        d = [d delay];
    end
    dbase.fdbkdelays=d; %all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses
    
    fields specific to BOS
        if bBOS
            if strcmp(dbase.num,'091')
                dbase.BOShitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOSfdbksyll|dbase.allsyllnames=='W'));
                dbase.BOShitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.BOSfdbksyll|dbase.allsyllnames=='W'));
                dbase.BOScatchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOScatchsyll));
                dbase.BOScatchsyllends=dbase.allsyllends(find(dbase.allsyllnames==dbase.BOScatchsyll));
            else
                dbase.BOShitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOSfdbksyll));
                dbase.BOShitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.BOSfdbksyll));
                dbase.BOScatchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.BOScatchsyll));
                dbase.BOScatchsyllends=dbase.allsyllends(find(dbase.allsyllnames==dbase.BOScatchsyll));
            end
            dbase.fdbkdelays = zeros(length(dbase.hitsyllends),1);
            dbasedir = 'C:\Users\GLab\Box Sync\VP_dbases\sortedRCandPavel\';
            dbase2name = dir([dbasedir dbase.num '*']);
            dbase2 = load([dbasedir dbase2name.name]);
            dbase.fdbkdelays = median(dbase2.dbase.fdbkdelays) * ones(1,length(dbase.hitsyllends));
            if strcmp(dbase.num,'118')
                dbase.fdbkdelays = 0.275* ones(1,length(dbase.hitsyllends));
            end
            dbase.catchdelays = dbase.fdbkdelays;
        end
    
    % forced fdbk
%     dbase.Zsyllstarts = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
%     dbase.Zsyllends = dbase.allsyllends(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
%     dZ=[];
%     cent = 0.025;
%     for j=1:length(dbase.Zsyllstarts);
%         ind_Z = find((dbase.allfdbks+cent)-dbase.Zsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.Zsyllends(j) < 0);
%         if length(ind_Z) ~= 1 && ~bBOS
%             error(['check Z times in ' dbase.title ' Z number ' num2str(j)])
%         end
%         delayZ = dbase.allfdbks(ind_Z) - dbase.Zsyllstarts(j);
%         dZ = [dZ delayZ];
%     end
%     dbase.Zfdbkdelays=dZ;%all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses

         if ~bBOS
    dbase = vgm_dbaseMakeMidBoutEnd(dbase);
         end
    dbase = vgm_getwinrates(dbase, 0.075);
    %code from jesse
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

    %     if ~isempty(dbase.stimtimes)
    %         exclude_default=sort([filestarttimes_exclude fileendtimes_exclude concatenate(dbase.stimtimes)]);
    %     else
    %         exclude_default=[];
    %     end
    exclude_default = [];
    Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
    Istarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'I' | dbase.allsyllnames == 'i');
    Lstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'L' | dbase.allsyllnames == 'l');
    Qstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Q' | dbase.allsyllnames == 'q');
    
        %% now make all the trigInfos!
    %     % all syll onset, including syll names and syll duration.
    dbase = rcm_dbaseMakeTrigInfosyll(dbase);
    
            % motif aligned triginfo
    [dbase]=rcm_dbaseMakeTrigInfomotif(dbase,dbase.motif,dbase.fdbkmotif);
    [dbase]=rcm_dbaseMakeTrigInfomotif_caseInsensitive(dbase,dbase.motif);
    tf = dbase.trigInfomotifCaseI.notwarped{1};
    fdbktimes = concatenate(tf.fdbkOnsets{1});
     motifdur = median(tf.motifdurs);
    targetT = median(fdbktimes(fdbktimes>0 & fdbktimes<motifdur));
    dbase.targetT = targetT;
    dbase.motifdur = motifdur;
    
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

    % movement analysis
    if bMovement == 1
        dbase = rc_intan_dbaseSortMoves(dbase,foldname);  %computes threshold and detects movement onsets and offsets based on combined 3 axes
        dbase = ad_ephys_analysis_movement(dbase); % creats trigInfo for 1.all movement onsets offsets, 2.within bouts and 3.outside bouts
    end
    
    %some stats
     %dbase.IMCC = mean(dbase.trigInfomotifCaseI.notwarped{1}.spikecc20);
     dbase.IMCC_nmotifs = length(dbase.trigInfomotifCaseI.notwarped{1}.allmotifdurs);
     %dbase.IMCC_pval_kstest = dbase.trigInfomotifCaseI.notwarped{1}.pval.warped.spikecc20;
    dbase.FRbout = dbase.rates.bout;
    dbase.FRsilent = dbase.rates.silent;
    dbase.peakFRbout = (1/prctile(dbase.ISI.bout,5));
    dbase.peakFRsilent = (1/prctile(dbase.ISI.nonsong,5));
    
    % set directory for analysed dbase & SAVE IT!
    save_pathname = 'Z:\FieldL_16ch_ephys\Analyzeddbase';
    save_filename = name_dbase;
    save_fullfilename = fullfile(save_pathname,save_filename);
    save(save_fullfilename,'dbase');