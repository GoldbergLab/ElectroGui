%% This script takes a dbase made by electro_gui gets it ready for plotting VTA manuscript figures

clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

% fold{1}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
% fold{2}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
% fold{3}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

for y=1:3
    contents=dir(fold{y});
    for i=1:length(contents);
        disp(['dbase no. ' num2str(i-2)])
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
%             %remove old fields
%             allfields = fieldnames(dbase);
%             fieldstoremove = allfields(21:end);
%             dbase = rmfield(dbase,fieldstoremove);
            
            %set path for where the dbase file is located and make the
            %title field
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            dbase.title=contents(i).name;
            
            
            %Make the BirdID field
            ind_VTA = strfind(dbase.PathName, 'VTA');
            dbase.BirdID = dbase.PathName(ind_VTA+4:ind_VTA+7);
            
            %make the fdbksyll field
            BirdIDfdbksyll = {'2940' 'E';...
                '2995' 'D';...
                '2998' 'A';...
                '2951' 'C';...
                '2975' 'D';...
                '2116' 'D';...
                '2968' 'B';...
                '2965' 'E';...
                '2961' 'B';...
                '2810' 'B';...
                '2808' 'C';...
                '2894' 'E';...
                '2827' 'C';...
                '2854' 'C';...
                '2840' 'D';...
                '2866' 'A'};
            
            TF = strcmp(dbase.BirdID, BirdIDfdbksyll);
            ind_fdbk = find(TF(:,1));
            fdbksyll = BirdIDfdbksyll{ind_fdbk,2};
            dbase.fdbksyll = fdbksyll;
          
            %make the BirdIDMoveThresh field
            BirdIDMoveThresh =...
               {'2808'    0.0045;...
                '2840'    0.0043;...
                '2995'    0.0027;...
                '2968'    0.0054;...
                '2965'    0.0045;...
                '2961'    0.0047;...
                '2810'    0.0049;...
                '2940'    0.0048;...
                '2894'    0.0036;...
                '2827'    0.0044;...
                '2854'    0.0035;...
                '2866'    0.0051;...
                '2998'    0.0037;...
                '2951'    0.0051;...
                '2975'    0.0047;...
                '2116'    0.0078};
            
            TF = strcmp(dbase.BirdID, BirdIDMoveThresh);
            ind = find(TF(:,1));
            movethresh = BirdIDMoveThresh{ind,2};
            dbase.BirdIDMoveThresh = movethresh;
            
            % make microdirve position fields
            MicrodrivePosition =...
               {'2940' [0.6 2.2 5.5];...
                '2995' [0.6 2.7 5.3];...
                '2998' [0.65 3.0 5.3];...
                '2951' [0.6 2.8 5.5];...
                '2975' [0.6 3.0 5.5];...
                '2116' [0.6 2.8 5.4];...
                '2968' [0.6 2.4 5.5];...
                '2965' [0.6 2.4 5.15];...
                '2961' [0.63 2.4 5.13];...
                '2810' [0.6 2.4 5.35];...
                '2808' [0.6 2.8 5.55];...
                '2894' [0.85 2.0 5.73];...
                '2827' [0.85 2.2 5.5];...
                '2854' [0.85 3.0 5.65];...
                '2840' [0.6 2.6 5.58];...
                '2866' [0.6 2.6 5.65]};
            
            TF = strcmp(dbase.BirdID, MicrodrivePosition);
            ind_pos = find(TF(:,1));
            position = MicrodrivePosition{ind_pos,2};
            dbase.BirdIDMicrodriveImplantPostition = position;
            
            % make fields for electrode postion for each dbase
%             path_elecpos = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\';
            path_elecpos = 'C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\';
            
            file_elecpos = 'ElectrodeDepth.mat';
            load([path_elecpos file_elecpos])
            
            TF = strcmp(dbase.title, ElectrodeDepth);
            ind_depth = find(TF(:,1));
            depth = ElectrodeDepth{ind_depth,2};
            dbase.Electrode.Depth = depth(1:2);
            dbase.Electrode.Penetration = depth(3);
            
            %initial analyses to extract eventTimes
            dbase=vgm_dbaseGetIndices(dbase);
            
            dbase=vgm_dbaseBoutNonsongISI(dbase,dbase.indx);
            
            [filestarttimes, fileendtimes, dbase.syllstarttimes, dbase.syllendtimes,...
                dbase.sylldurs, preintrvl, postintrvl, allintrvls, dbase.syllnames]...
                = vgm_dbaseGetSylls(dbase);
            dbase.filestarttimes=filestarttimes;
            dbase.fileendtimes=fileendtimes;
            dbase.allsyllnames=cell2mat(concatenate(dbase.syllnames));
            
            dbase = vgm_dbaseMakeBoutSylls(dbase);
 
            % get the spike waveform with dbase.thespike
            if isfield(dbase, 'thespike')
                dbase = rmfield(dbase, 'thespike');
            end
            bEliminateOutliers = 1;
            %the outliers code takes out all spikes for neuron 1
            %confirmed that it's OK to not eliminate outliers for file 18
            % the second case there is a small spike the preceds it
            if strcmp(dbase.title, 'dbase051315_7chan6_M_sl_nsr.mat') ||...
                    strcmp(dbase.title, 'dbase100814_2chan2_M_sl_nsr.mat')
                bEliminateOutliers = 0;
            end
            [dbase] = vg_dbasespikewidth(dbase, bEliminateOutliers);
            
            %Extract movement times
            dbase=vgm_dbaseGetMoveRasterNoPresort(dbase);
            
            %Fix extremely low movement offset to onset times
            dbase = vgm_fusedoublemoves(dbase);
            
            dbase = vgm_dbaseMakeBoutMoves(dbase);
            
            %spike train analyses
            lag=1.2;%Lag, in seconds, of how far out you want to plot
            bplot1=0; %if you want to plot the autocorr; 0 if you don't want to
            for binsize = [0.01 0.025 0.050]
                [dbase] = vgm_dbaseSpikeTrainAutocorrelation(dbase, lag, bplot1, binsize);
            end
            
            %infrastructure for error-related analyses -- below we define
            %medianfdbk time as zero
            dbase.allsyllstarts=concatenate(dbase.syllstarttimes);
            dbase.allsyllends=concatenate(dbase.syllendtimes);
            dbase.allsyllnames=concatenate(concatenate(dbase.syllnames));
            dbase.allfdbks=concatenate(dbase.fdbktimes);
            dbase.hitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==dbase.fdbksyll));%
            dbase.hitsyllends = dbase.allsyllends(find(dbase.allsyllnames==dbase.fdbksyll));
            dbase.catchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==lower(dbase.fdbksyll)));
            
            dbase.catchsyllends=dbase.allsyllends(find(dbase.allsyllnames==lower(dbase.fdbksyll)));
            
            d=[];
            cent = 0.025;
            for j=1:length(dbase.hitsyllstarts);
                ind_fdbk = find((dbase.allfdbks+cent)-dbase.hitsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.hitsyllends(j) < 0);
                if length(ind_fdbk) ~= 1
                    error(['check fdbktimes in ' dbase.title])
                end
                delay = dbase.allfdbks(ind_fdbk) - dbase.hitsyllstarts(j);
                d = [d delay];
            end
            dbase.fdbkdelays=d;%all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses
            
            
            dbase.Zsyllstarts = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
            dbase.Zsyllends = dbase.allsyllends(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
            dZ=[];
            cent = 0.025;
            for j=1:length(dbase.Zsyllstarts);
                ind_Z = find((dbase.allfdbks+cent)-dbase.Zsyllstarts(j) > 0 & (dbase.allfdbks+cent)-dbase.Zsyllends(j) < 0);
                if length(ind_Z) ~= 1
                    error(['check Z times in ' dbase.title])
                end
                delayZ = dbase.allfdbks(ind_Z) - dbase.Zsyllstarts(j);
                dZ = [dZ delayZ];
            end
            dbase.Zfdbkdelays=dZ;%all of the fdbk delays relative to the hit syll onset (median of this value plus the syllonset time sets time '0' in the following analyses
            
                
                
             %only for error neurons
             if y == 1 || y == 2
            
                % to get bout isi excluding hit and esc times + 300 ms
                dbase = vgm_boutISInohitesc(dbase);
                
                % to get nonsong isi excluding Ztimes + 300 ms
                dbase = vgm_nonsongISInoZ(dbase);
                
                
                
                
                
                
                
                % get mishittimes
                dbase=vgm_dbasegetmishits(dbase);
                
                
                % stims and collisions analysis
                dbase = vgm_GetStimClips(dbase);
                
                
                
                % Burst Analysis
                if isfield(dbase, 'BurstAnalysis')
                    dbase = rmfield(dbase, 'BurstAnalysis');
                end
                
                dbase=vgm_BurstAnalysis(dbase, 5);
                
                
                
                
  
            end
           
            
            % Hits and escapes midbout and endbouts
            dbase = vgm_dbaseMakeMidBoutEnd(dbase);
            
            % Hits and escapes with and without moves
            dbase = vgm_dbaseMakeMoveNoMove(dbase);
                
            % get the rate estimates by spike counting in random
            % windows
            dbase = vgm_getwinrates(dbase, 0.075);
            
            % make field historyanalysis
            if isfield(dbase,'historyanalysis')
                dbase = rmfield(dbase,'historyanalysis');
            end
            dbase = vgm_hithistory(dbase);
            
            
            
            %below get triginfos (raster data) for various events and
            %triggers
            if ~isfield(dbase,'stimtimes')
                dbase.stimtimes = [];
            end
            
            %below exlude any event that has filestarts, fileends, or stims within the xlim
            
            %To NOT exclude filestarttimes and fileendtimes that overlap
           
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
            
            
            %only for error neurons
            if y == 1 || y == 2
                binsize=.025;
                xl=1.05;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
                bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping

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
                
            end
            
            binsize=.025;
            xl=1.05;%
            bplot=0;%

            %Hit syll spikes (time 0 is the time of the median fdbk)
            clear trigger events exclude;
            trigger = dbase.hitsyllstarts+median(dbase.fdbkdelays);
            events = concatenate(dbase.spiketimes);
            exclude = exclude_default;
            dbase.trigInfohitbin25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfohitbin25 = vgm_MonteCarloFlex(dbase.trigInfohitbin25);
            
            %Hit syll spikes (time 0 is the time of the actual fdbk)
            clear trigger events exclude;
            trigger = dbase.hitsyllstarts+dbase.fdbkdelays; % no median here
            events = concatenate(dbase.spiketimes);
            exclude = exclude_default;
            dbase.trigInfoFhitbin25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfoFhitbin25 = vgm_MonteCarloFlex(dbase.trigInfoFhitbin25);
            
            %Catch syll spikes
            clear trigger events exclude;
            trigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
            events = concatenate(dbase.spiketimes);
            exclude = exclude_default;
            dbase.trigInfocatchbin25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            dbase.trigInfocatchbin25 = vgm_MonteCarloFlex(dbase.trigInfocatchbin25);
            
            
            

            %Z spikes
            if ~isempty(dbase.Zsyllstarts)
                binsize=.025;
                xl=1.025;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
                bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping
                
                clear trigger events exclude;
                trigger = dbase.Zsyllstarts+dbase.Zfdbkdelays;
                events = concatenate(dbase.spiketimes);
                exclude = exclude_default;
                dbase.trigInfoZbin25 = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                dbase.trigInfoZbin25 = vgm_MonteCarloFlex(dbase.trigInfoZbin25);
            end
            
            
              
            dbase = vgm_dprime(dbase,1000);
            disp(['max: ' num2str(dbase.dprime.ptile_dprime_max)])
            disp(['min: ' num2str(dbase.dprime.ptile_dprime_min)])
            
            
                
            %only for error neurons
            if y == 1 || y == 2
                binsize=.025;
                xl=1.025;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
                bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping
                
                %Hit sylls move onsets
                clear trigger events exclude;
                trigger=dbase.hitsyllstarts+dbase.fdbkdelays;
                events=concatenate(dbase.moveonsets);
                exclude=sort([exclude_default Zstarttimes]);
                dbase.trigInfomovehitbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                
                %Catch sylls move onsets
                clear trigger events exclude;
                trigger=dbase.catchsyllstarts+median(dbase.fdbkdelays);
                events=concatenate(dbase.moveonsets);
                exclude=sort([exclude_default Zstarttimes]);
                dbase.trigInfomovecatchbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);
            
                %Hit sylls move offsets
                clear trigger events exclude;
                trigger=dbase.hitsyllstarts+dbase.fdbkdelays;
                events=concatenate(dbase.moveoffsets);
                exclude=sort([exclude_default Zstarttimes]);
                dbase.trigInfomoveoffsetshitbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                
                %Catch sylls move onsets
                clear trigger events exclude;
                trigger=dbase.catchsyllstarts+median(dbase.fdbkdelays);
                events=concatenate(dbase.moveoffsets);
                exclude=sort([exclude_default Zstarttimes]);
                dbase.trigInfomoveoffsetscatchbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);

            end
            
            
            
             
                
            
            %analysis for movement and syllable onset aligned spiking
            binsize=.025;
            xl = 1.05;
            bplot = 0;
            
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
            
            binsize=.025;
            xl = 0.325;
            bplot = 0;

            % 4. Movement onsets and offset within song no boutons and offs
            % Trigger: movement onsets and offsets
            % Events: spikes
            % Exclude: bout onsets and offsets
            % default + Z
            clear trigger events exclude;
            trigger=concatenate(dbase.boutmoveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default Zstarttimes boutstarts_exclude boutends_exclude]);
            dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds.edges)
                dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds);
                dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutMoveOnsetsSpikesNoBoutStartsBoutEnds,'bout');
            end
            trigger=concatenate(dbase.boutmoveoffsets);
            dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            if ~isempty(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds.edges)
                dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds = vgm_MonteCarloFlex(dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds);
                dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds = vgm_reliability(dbase,dbase.trigInfoBoutMoveOffsetsSpikesNoBoutStartsBoutEnds,'bout');
            end
            
            binsize=.025;
            xl = 1.05;
            bplot = 0;
            
            % 5. Song syll onsets and offsets
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
            
            % 6. Song syll onsets and offsets no bout ons and offs 
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
            
            binsize=.025;
            xl = 0.225;
            bplot = 0;
        
            % 7. Song syll onsets and offsets no movements
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
            
            
            binsize=.025;
            xl = 0.225;
            bplot = 0;
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

            if y == 1 || y == 2
                alf = 'abcdefgh';
                dbase.motif = {alf(1:strfind(alf,lower(dbase.fdbksyll)))};
                dbase.fdbkmotif = {[alf(1:strfind(alf,lower(dbase.fdbksyll))-1) dbase.fdbksyll]};
                dbase = vgm_dbaseMakeTrigInfomotif(dbase,dbase.motif,dbase.fdbkmotif);
                dbase.trigInfomotif{1}.warped = vgm_MonteCarlo_t(dbase.trigInfomotif{1}.warped);
                dbase.trigInfomotif{1}.notwarped = vgm_MonteCarlo_t(dbase.trigInfomotif{1}.notwarped);
            end

              
            
                
                %only for error neurons
                if y == 1 || y == 2
                    %Z spikes no moves
                    binsize=.025;
                    xl=0.225;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
                    bplot=0;%change this to 1 if you want to plot each raster as yoyu are looping
                    
                    if ~strcmp(dbase.title, 'dbase102814_1chan2_ForAnalysis.mat')
                        clear trigger events exclude;
                        trigger = dbase.Zsyllstarts+dbase.Zfdbkdelays;
                        events = concatenate(dbase.spiketimes);
                        exclude = [exclude_default concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)];
                        dbase.trigInfoZNoMoves = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%                         dbase.trigInfoZNoMoves = vgm_MonteCarloFlex(dbase.trigInfoZNoMoves);
                    end
                
                end
              %}  
                
            save(dbase.dbasePathNameVikram,'dbase');
        end
        
    end
end

%% only get movement onsets, offsets, durations, and fix small offset to onset times


clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            %set path for where the dbase file is located and make the
            %title field
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            %Extract movement times
            %             dbase=vgm_dbaseGetMoveRasterNoPresort(dbase);
            
            %Fix extremely low movement offset to onset times
            dbase = vgm_fusedoublemoves(dbase);
            
            %             %Monte Carlo for p values for fig S4
            %             dbase.trigInfomoveonsbin25 = vgm_MonteCarloFlex(dbase.trigInfomoveonsbin25);
            %             dbase.trigInfomoveonsbin25no_song = vgm_MonteCarloFlex(dbase.trigInfomoveonsbin25no_song);
            %             dbase.trigInfoSyllOnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoSyllOnsetsSpikes);
            %             dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets = vgm_MonteCarloFlex(dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets);
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
    end
end

%% To objectively determine the threshold to use for the movement analysis
% Read accelerometer data from acquisition gui files
% Accelerometer data

close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

loaddata = 1;

for y=2:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            path_accl = [dbase.PathName '\'];
            
            data_accl = {};
            for j = 1:size(dbase.ChannelFiles{3},1)
                file_accl = dbase.ChannelFiles{3}(j).name;
                [data, fs, dateandtime, label, props] = egl_AA_daq([path_accl file_accl], loaddata);
                data_accl{j} = data;
            end
            
            data_mov = {};
            for i = 1:size(data_accl,2)
                N = length(data_accl{i});
                BP = [1:10000:(N-10000) N];
                ssignal = smooth(data_accl{i},40);
                y_dt = detrend(ssignal, 'linear', BP);
                ysmooth = smooth(y_dt.^2, 2400);
                data_mov{i} = sqrt(ysmooth)';
            end
            
            mov = concatenate(data_mov);
            
            mov = log10(mov);
            edges = linspace(-4,-1,400);
            dist = histc(mov,edges);
            
            [IDX, C] = kmeans(mov',2);
            threshold = 10^mean(C);
            
            dbase.dbaseMoveThreshold = threshold;
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
    end
end


%% to get average movement threshold for each bird

close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

count = 0;
count1 = 0;
allthresh = {};
BirdIDMoveThresh = {};

for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            count = count+1;
            allthresh{count,1} = dbase.BirdID;
            allthresh{count,2} = dbase.dbaseMoveThreshold;
            if ~any(strcmp(BirdIDMoveThresh, dbase.BirdID))
                count1 = count1+1;
                BirdIDMoveThresh{count1,1} = dbase.BirdID;
                BirdIDMoveThresh{count1,2} = dbase.dbaseMoveThreshold;
                BirdIDMoveThresh{count1,3} = 1;
            else
                ind = find(strcmp(BirdIDMoveThresh, dbase.BirdID));
                BirdIDMoveThresh{ind,2} = BirdIDMoveThresh{ind,2}+...
                    dbase.dbaseMoveThreshold;
                BirdIDMoveThresh{ind,3} = BirdIDMoveThresh{ind,3}+1;
            end
        end
    end
end



for i = 1:size(BirdIDMoveThresh,1)
    BirdIDMoveThresh{i,2} = BirdIDMoveThresh{i,2}/BirdIDMoveThresh{i,3};
end
%% to make the movement threshold for the bird a part of the dbase.

close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

BirdIDMoveThresh =...
    {'2808'    0.0045;...
    '2840'    0.0043;...
    '2995'    0.0027;...
    '2968'    0.0054;...
    '2965'    0.0045;...
    '2961'    0.0047;...
    '2810'    0.0049;...
    '2940'    0.0048;...
    '2894'    0.0036;...
    '2827'    0.0044;...
    '2854'    0.0035;...
    '2866'    0.0051;...
    '2998'    0.0037;...
    '2951'    0.0051;...
    '2975'    0.0047;...
    '2116'    0.0078};



for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            TF = strcmp(dbase.BirdID, BirdIDMoveThresh);
            ind = find(TF(:,1));
            movethresh = BirdIDMoveThresh{ind,2};
            dbase.BirdIDMoveThresh = movethresh;
            
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
    end
end

%% to make sure all Z's are labeled
close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';


delay = 0.025;
C = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'L' 'Z'};

for y=3%:3
    contents=dir(fold{y});
    for i=84%:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            for j = 1:size(dbase.SoundFiles,1)
                dispsyll{j,1} = j;
                s = dbase.syllstarttimes{j};
                f = dbase.fdbktimes{j};
                syllnames = dbase.syllnames{j};
                if ~isempty(f)
                    for k = 1:length(f)
                        d = s-(f(k)+delay);
                        ind = find(d<0,1,'last');
                        
                        
                        syll(j,k) = syllnames{ind};
                        
                        
                    end
                else
                    syll(j,1) = ' ';
                end
                
                
                dispsyll{j,2} = syll(j,:);
                
            end
            disp(dbase.title)
            disp(dispsyll)
            
        end
    end
end



%% making dbase fields with depth information

close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

path_elecpos = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\';
file_elecpos = 'ElectrodeDepth.mat';
load([path_elecpos file_elecpos])


for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            % make fields for electrode postion for each dbase
            
            
            TF = strcmp(dbase.title, ElectrodeDepth);
            ind_depth = find(TF(:,1));
            depth = ElectrodeDepth{ind_depth,2};
            dbase.Electrode.Depth = depth(1:2);
            dbase.Electrode.Penetration = depth(3);
            
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
    end
end


%% running loop for various things

close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';



for y=1:2
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            
            
            disp(length(dbase.interboutISI))
            
            
            
        end
    end
end

%% motif analysis for neuron 10
close all
clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';



for y=1%:2
    contents=dir(fold{y});
    for i=7%3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            motif =     {'a', 'ab', 'abc', 'abcd', 'ia', 'iab', 'iabc', 'iabcd', 'da', 'dab', 'dabc', 'dabcd', 'ad', 'dad', 'ada', 'ada'};
            fdbkmotif = {'A', 'Ab', 'Abc', 'Abcd', 'iA', 'iAb', 'iAbc', 'iAbcd', 'dA', 'dAb', 'dAbc', 'dAbcd', 'Ad', 'dAd', 'Ada', 'adA'};
            dbase=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
            
            binsize=.025;
            xl=1.05;%set xlimits binsize of PSTH (1.05 xlim will get replotted as [-1 1] later
            bplot=0;
            
            exclude_default=sort([dbase.filestarttimes dbase.fileendtimes concatenate(dbase.stimtimes)]);
            Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
            
            events = concatenate(dbase.spiketimes);
            exclude = exclude_default;
            
            %Hit syll spikes (time 0 is the time of the actual fdbk)
            alltrigger = dbase.hitsyllstarts+dbase.fdbkdelays;
            for j = 1:length(dbase.fdbkmotif)
                fdbkmotif = dbase.fdbkmotif{j};
                motifstarts = dbase.trigInfofdbkmotif{j}.notwarped.motifstarts;
                motifends = dbase.trigInfofdbkmotif{j}.notwarped.motifends;
                trigger = [];
                for k = 1:length(motifstarts)
                    trigger(k) = alltrigger(alltrigger > motifstarts(k) & alltrigger < motifends(k));
                end
                dbase.(['trigInfoFhitbin25_' fdbkmotif]) = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            end
            
            %Catch syll spikes
            alltrigger = dbase.catchsyllstarts+median(dbase.fdbkdelays);
            for j = 1:length(dbase.motif)
                motif = dbase.motif{j};
                motifstarts = dbase.trigInfomotif{j}.notwarped.motifstarts;
                motifends = dbase.trigInfomotif{j}.notwarped.motifends;
                
                if strcmp(motif,'ada')
                    trigger = [];
                    for k = 1:length(motifstarts)
                        trigger(k) = alltrigger(find(alltrigger > motifstarts(k) & alltrigger < motifends(k), 1, 'first'));
                    end
                    dbase.(['trigInfocatchbin25_' motif '1']) = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                    
                    trigger = [];
                    for k = 1:length(motifstarts)
                        trigger(k) = alltrigger(find(alltrigger > motifstarts(k) & alltrigger < motifends(k), 1, 'last'));
                    end
                    dbase.(['trigInfocatchbin25_' motif '2']) = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                else
                    trigger = [];
                    for k = 1:length(motifstarts)
                        trigger(k) = alltrigger(alltrigger > motifstarts(k) & alltrigger < motifends(k));
                    end
                    dbase.(['trigInfocatchbin25_' motif]) = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                end
            end
            
            
            
            
            
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
    end
end

%% for birdbases Jesse's birdbases
clear
% fold = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases\';
fold = 'C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases\';

contents=dir(fold);
for i=13:length(contents);
    if strcmp(contents(i).name(end),'t');
        load([fold contents(i).name]);
        dbase.title=contents(i).name;
        %         dbase.dbasePathNameJesse=[fold contents(i).name];
        dbase.dbasePathNameVikram=[fold contents(i).name];
        disp(['dbase no.' num2str(i-2)])
        
        dbase = vgm_dprime_move(dbase,1000);
        disp(['max: ' num2str(dbase.dprime.ptile_dprime_max)])
        disp(['min: ' num2str(dbase.dprime.ptile_dprime_min)])
        
        save(dbase.dbasePathNameVikram,'dbase');
        
    end
end

%% for birdbases VG's birdbase
clear
% fold = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases_VG\';
fold = 'C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases_VG\';
file = 'Birdbase_VG.mat';
load([fold file])
BirdIDs = fieldnames(Birdbase);
s = 3;

for i=1:length(BirdIDs);
    disp(['BirdID no.' num2str(i)])
    
%     eventOnsetsHit = Birdbase.(BirdIDs{i}).trigInfomovehitbin25.events;
%     eventOnsetsEscape = Birdbase.(BirdIDs{i}).trigInfomovecatchbin25.events;
%     eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
% 
%     xl = 1.05;
%     binsize = 0.025;
%     edges=-xl:binsize:xl+binsize;
%     alleventsHit=concatenate(eventOnsetsHit);
%     distHit=histc(alleventsHit,edges);
%     distHit=distHit/length(eventOnsetsHit);
%     distHit=distHit/binsize;
%     distHit=distHit(1:end-1);
%     edges=edges(1:end-1);
%     rdhit=distHit;
%     rdhitsmooth = smooth(rdhit,s)';
%     
%     edges=-xl:binsize:xl+binsize;
%     alleventsEscape=concatenate(eventOnsetsEscape);
%     distEscape=histc(alleventsEscape,edges);
%     distEscape=distEscape/length(eventOnsetsEscape);
%     distEscape=distEscape/binsize;
%     distEscape=distEscape(1:end-1);
%     edges=edges(1:end-1);
%     rdescape = distEscape;
%     rdescapesmooth = smooth(rdescape,s)';
%     
%     errorzscore = zscore(rdescapesmooth-rdhitsmooth);
%     
%     Birdbase.(BirdIDs{i}).trigInfomovehitbin25.rd = rdhit;
%     Birdbase.(BirdIDs{i}).trigInfomovehitbin25.rds = rdhitsmooth;
%     Birdbase.(BirdIDs{i}).trigInfomovehitbin25.s = s;
%     Birdbase.(BirdIDs{i}).trigInfomovecatchbin25.rd = rdescape;
%     Birdbase.(BirdIDs{i}).trigInfomovecatchbin25.rds = rdescapesmooth;
%     Birdbase.(BirdIDs{i}).trigInfomovecatchbin25.s = s;
%     Birdbase.(BirdIDs{i}).errorzscore = errorzscore;
    
    
    Birdbase.(BirdIDs{i}) = vgm_dprime_move(Birdbase.(BirdIDs{i}),1000);
    disp(['max: ' num2str(Birdbase.(BirdIDs{i}).dprime.ptile_dprime_max)])
    disp(['min: ' num2str(Birdbase.(BirdIDs{i}).dprime.ptile_dprime_min)])
    
    save([fold file],'Birdbase');
    
    
end


%% for spectral analysis of post hit or esc syllable


clear

bplot=0;
% fold = 'C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases_nextsyll\';
fold = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases_nextsyll_local\';

contents=dir(fold);
for i=3:length(contents);
    if strcmp(contents(i).name(end),'t');
        load([fold contents(i).name]);
        dbase.title=contents(i).name;
        dbase.dbasePathNameVikram=[fold contents(i).name];
        
        if ~isfield(dbase,'moveindx');dbase.fdbkindx=1;dbase.moveindx=2;dbase.stimindx=3; end
        
        
        
        
        
        [dbase.filestarttimes dbase.fileendtimes dbase.syllstarttimes dbase.syllendtimes dbase.sylldurs preintrvl postintrvl allintrvls dbase.syllnames] = dbaseGetSylls(dbase);
        
        
        fdbkindx=dbase.fdbkindx;
        
        for i=1:length(dbase.EventTimes{fdbkindx})
            if ~isempty(dbase.EventTimes{fdbkindx}{1,i})
                a=size(dbase.EventIsSelected{fdbkindx}{1,i});b=size(dbase.EventIsSelected{fdbkindx}{end,i});
                if a(1)~=b(1);dbase.EventIsSelected{fdbkindx}{end,i}=dbase.EventIsSelected{fdbkindx}{end,i}';end
                if a(2)~=b(2);%then inequal number of onsets and offsets (file cutoff)
                    ons=dbase.EventTimes{fdbkindx}{1,i};offs=dbase.EventTimes{fdbkindx}{2,i};
                    if length(ons)>length(offs); dbase.EventIsSelected{fdbkindx}{1,i}(end)=[];dbase.EventTimes{fdbkindx}{1,i}(end)=[];end
                    if length(offs)>length(ons);dbase.EventIsSelected{fdbkindx}{2,i}(1)=[];dbase.EventTimes{fdbkindx}{2,i}(1)=[];end
                end
            end
        end
        dbase.fdbktimes=dbaseGetRaster(dbase,dbase.fdbkindx);
        
        dbase.allsyllstarts=concatenate(dbase.syllstarttimes);
        dbase.allsyllends=concatenate(dbase.syllendtimes);
        dbase.allsyllnames=concatenate(concatenate(dbase.syllnames));
        dbase.allfdbks=concatenate(dbase.fdbktimes);
        
        [dbase.allsyllstarts sortndx]=sort(dbase.allsyllstarts);
        dbase.allsyllends=dbase.allsyllends(sortndx);
        dbase.allsyllnames=dbase.allsyllnames(sortndx);
        
        
        allfdbks=sort([dbase.allfdbks dbase.allfdbks+.055]);
        catches=[];hits=[];
        for i=1:length(dbase.allsyllnames)
            st=dbase.allsyllstarts(i);en=dbase.allsyllends(i);
            ifhit=find(allfdbks>st & allfdbks<en);
            if ~isempty(ifhit);
                dbase.allsyllnames(i)=upper(dbase.allsyllnames(i));
            end
        end
        
        %Get fdbksyll below
        possylls='abcde';
        clear count;
        for i=1:length(possylls);
            if isempty(find(dbase.allsyllnames==upper(possylls(i))))
                count(i)=0;
            else
                count(i)=length(find(dbase.allsyllnames==upper(possylls(i))));
            end
        end
        [mx ndx]=max(count);
        dbase.fdbksyll=possylls(ndx);
        
        
        dbase.allsylls=unique(dbase.allsyllnames);
        dbase.hitsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==upper(dbase.fdbksyll)));
        dbase.catchsyllstarts=dbase.allsyllstarts(find(dbase.allsyllnames==lower(dbase.fdbksyll)));
        d=[];
        for j=1:length(dbase.hitsyllstarts);
            delay=dbase.allfdbks-dbase.hitsyllstarts(j);
            [tmpdelay ndx]=min(abs(delay));%(find(delay>0));
            d=[d delay(ndx)];
        end
        dbase.fdbkdelays=d;
        
        
      
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        save(dbase.dbasePathNameVikram,'dbase');
    end
end

%% Testing

clear

fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

% fold{1}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
% fold{2}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
% fold{3}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

count = 0;
for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        disp(i-2)
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            disp(dbase.BirdID)
            
        end
    end
end

%% old code

            
            
            

%             % Trigger: syllable onsets, Events: spikes, Exclude: Z start
%             % times
%             clear trigger events exclude;
%             trigger=concatenate(dbase.syllstarttimes);
%             events = concatenate(dbase.spiketimes);
%             exclude=[exclude_default Zstarttimes];
%             dbase.trigInfoSyllOnsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             dbase.trigInfoSyllOnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoSyllOnsetsSpikes);
%             trigger=concatenate(dbase.syllendtimes);
%             dbase.trigInfoSyllOffsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             dbase.trigInfoSyllOffsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoSyllOffsetsSpikes);
%             
%             
% 
%             % Trigger: syllable onsets, Events: spikes, Exclude: movement
%             % onsets and offsets and Z start times
%             clear trigger events exclude;
%             trigger=concatenate(dbase.syllstarttimes);
%             events = concatenate(dbase.spiketimes);
%             exclude=([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
%             dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             if ~isempty(dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets.edges)
%                 dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets = vgm_MonteCarloFlex(dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets);
%             end
%             trigger=concatenate(dbase.syllendtimes);
%             dbase.trigInfoSyllOffsetsSpikesNoMoveOnsetsMoveOffsets=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             if ~isempty(dbase.trigInfoSyllOffsetsSpikesNoMoveOnsetsMoveOffsets.edges)
%                 dbase.trigInfoSyllOffsetsSpikesNoMoveOnsetsMoveOffsets = vgm_MonteCarloFlex(dbase.trigInfoSyllOffsetsSpikesNoMoveOnsetsMoveOffsets);
%             end
            
            
            
            
%             % infrastructure for not triggering on hit or catch sylls and
%             % the next ones within bout if sooner than 0.3s
%
%             ind_next = [];
%             count = 0;
%             ind_hit = find(dbase.allboutsyllnames==upper(dbase.fdbksyll));
%             ind_catch = find(dbase.allboutsyllnames==lower(dbase.fdbksyll));
%             ind_hitcatch = sort([ind_hit ind_catch]);
%             for k = 1:length(ind_hitcatch)
%                 if ind_hitcatch(k) < length(dbase.allboutsyllstarts)
%                     if dbase.allboutsyllstarts(ind_hitcatch(k)+1) - dbase.allboutsyllstarts(ind_hitcatch(k)) < 0.3
%                         count = count+1;
%                         ind_next(count) = ind_hitcatch(k)+1;
%                     end
%                 end
%             end
%             ind_bad = sort([ind_hitcatch ind_next]);
%
%
%             % Trigger: syllable onsets and offsets only within bouts
%             % and no hit or catch or the subsequent one if sooner than 0.3s,
%             % Events: spikes, Exclude: Z start times
%             clear trigger events exclude;
%             trigger=concatenate(dbase.boutsyllstarttimes);
%             trigger(ind_bad) = [];
%             events = concatenate(dbase.spiketimes);
%             exclude=[exclude_default Zstarttimes];
%             dbase.trigInfoBoutSyllNoHitCatchPlus1OnsetsSpikes = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             dbase.trigInfoBoutSyllNoHitCatchPlus1OnsetsSpikes = vgm_MonteCarloFlex(dbase.trigInfoBoutSyllNoHitCatchPlus1OnsetsSpikes);
        
                
            
            
            

            
                    
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
%             binsize=.025;
%             xl = 0.5;
%             bplot = 1;
            
            
            
            
%             %Hit syll spikes (time 0 is the time of the median fdbk)
%             clear trigger events exclude;
%             trigger = dbase.mishittimes;
%             events = concatenate(dbase.spiketimes);
%             exclude = exclude_default;
%             dbase.trigInfomishits = vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
%             bplotraster = 1;
%             trigInfo = dbase.trigInfomishits;
%             bdmn = 0;
%             bsmooth = 1;
%             trigInfo=vg_trigInfoPlotFlex(trigInfo,bplotraster,bdmn,bsmooth, 0.5, 0.5);
  

            %Hit sylls moves
            clear trigger events exclude;
            trigger=dbase.hitsyllstarts+median(dbase.fdbkdelays);
            events=concatenate(dbase.moveonsets);
            exclude = exclude_default;
            dbase.trigInfomovehitbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            
            %Catch sylls moves
            clear trigger events exclude;
            trigger=dbase.catchsyllstarts+median(dbase.fdbkdelays);
            events=concatenate(dbase.moveonsets);
            exclude = exclude_default;
            dbase.trigInfomovecatchbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);
            
            %Syllable onset aligned movement rasters
            %Trigger: Syllable onsets, Events: Movement onsets, Exclude:
            %default and Z starttimes
            clear trigger events exclude;
            trigger=concatenate(dbase.syllstarttimes);
            events=concatenate(dbase.moveonsets);
            exclude=sort([exclude_default Zstarttimes]);
            dbase.trigInfoSyllOnsetsMoveOnsets=vgm_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot,xl,binsize);
            dbase.trigInfoSyllOnsetsMoveOnsets = vgm_MonteCarloFlex(dbase.trigInfoSyllOnsetsMoveOnsets);

            
            
            
%% for birdbases
clear
fold = 'C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\birdbases\';
contents=dir(fold);
for i=4:length(contents);
    disp(i-2)
    if strcmp(contents(i).name(end),'t');
        load([fold contents(i).name]);
        dbase.title=contents(i).name;
        %         dbase.dbasePathNameJesse=[fold contents(i).name];
        dbase.dbasePathNameVikram=[fold contents(i).name];
        
        % for bootstrap stats on syll onset aligned movement histogram
        dbase.trigInfomoveonsyllon = vgm_MonteCarloFlex(dbase.trigInfomoveonsyllon);
        
        save(dbase.dbasePathNameVikram,'dbase');
        
    end
end
%% date of birth
% date of birth % date of surgery % date of first day of recording % date
% of last day of recording % age in days at surgery
BirdID_DOB = {
'2940' [2013 11 11] [2014 02 21] [2014 02 25] [2014 03 08] [102];...
                
'2995' [2013 12 12] [2014 04 24] [2014 04 30] [2014 05 06] [133];...
                
'2998' [2013 12 15] [2014 05 02] [2014 05 07] [2014 05 16] [138];...
                
'2951' [2014 02 16] [2014 06 13] [2014 06 19] [2014 06 26] [117];...
                
'2975' [2014 05 01] [2014 07 17] [2014 07 25] [2014 07 30] [78];...
                
'2116' [] [2014 09 08] [2014 09 12] [2014 09 21] [];...
                
'2968' [2014 05 21] [2014 09 11] [2014 09 16] [2014 09 24] [114];...
                
'2965' [2014 07 21] [2014 10 02] [2014 10 05] [2014 10 12] [74];...
                
'2961' [2014 07 22] [2014 10 09] [2014 10 20] [2014 10 28] [80];...
                
'2810' [2014 09 23] [2014 12 25] [2014 12 29] [2015 01 03] [94];...
                
'2808' [2014 09 23] [2015 01 30] [2015 02 03] [2015 02 10] [130];...
                
'2894' [2014 09 18] [2015 03 19] [2015 03 25] [2015 03 27] [183];...
                
'2827' [2015 01 14] [2015 03 31] [2015 04 06] [2015 04 09] [76];...
                
'2854' [2014 12 20] [2015 04 08] [2015 04 12] [2015 04 17] [109];...
                
'2840' [2015 01 14] [2015 04 16] [2015 04 19] [2015 04 24] [76];...
                
'2866' [2015 01 11] [2015 04 23] [2015 05 14] [2015 05 18] [102]};




%% To find movement related neurons that are not bursty


clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

% fold{1}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
% fold{2}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
% fold{3}='C:\Users\Admin\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

count = 0;
CVisi = [];
rate_all = [];
pSTA = [];

s = 5;

count_AD = 0;
count_ERNA = 0;
count_OT = 0;
for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            
            count = count+1;
            if y == 1
                count_AD = count_AD+1;
            elseif y == 2
                count_ERNA = count_ERNA+1;
            elseif y == 3
                count_OT = count_OT+1;
            end
            isi = [dbase.ISI.bout dbase.ISI.interbout dbase.ISI.nonsong];
            CVisi(count) = std(isi)/mean(isi);
            rate_all(count) = dbase.rates.all;
            pSTA(count)=max(smooth(dbase.spiketrainautocorr.nlnallsong25ms, s));
        end
    end
end


N_AD = count_AD;
N_ERNA = count_ERNA;
N_ER = N_AD+N_ERNA;
N_OT = count_OT;
N_all = N_AD+N_ERNA+N_OT;


ind = rate_all < 50 & CVisi < 1.5 & pSTA < 1.5;
find(ind);















