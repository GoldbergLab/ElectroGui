clear
%function [dbase]=vg_VTABatchAnalysis2();


% fold{1}='G:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
fold{1}='H:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases round 2\';
% fold{1} = 'H:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{2}='C:\Users\jesseg\Desktop\N\';
bmotif=0;bplot=0;
for y=1;
    contents=dir(fold{y});
    for i=4%:length(contents);
        %         try
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            dbase.dbasePathName=[fold{y} contents(i).name];
            dbase.title=contents(i).name;
            disp(['Working on ' dbase.title]);
            
            dbase.PathName(1) = 'H';
            
            %             %initial analyses to extract eventTimes
            %             dbase=vg_dbaseGetIndices(dbase);
            %             dbase=vg_dbaseBoutNonsongISI(dbase,dbase.indx);
            %             dbase=vg_dbaseGetMoveRasterNoPresort(dbase);
            
            %spike train autocorrs
            lag=1.5;
            [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
            [dbase]=vg_dbaseSpikeTrainAutocorrelation(dbase,lag, bplot);
            
            %             if ~isfield(dbase,'allsylls');
            %                 [dbase]=vg_dbaseMakeTrigInfoAllsylls(dbase,0);
            %             end
            %                         dbase.fdbksyll = 'c';
            %                         dbase=vgm_hithistory(dbase);
            
            save(dbase.dbasePathName,'dbase');
            %             if bmotif
            %                 %Motif aligned hists
            %                 motif{1}='abcde';motif{2}='abcdef';motif{3}='abcdey';
            %                 fdbkmotif{1}='abcDe';fdbkmotif{2}='abcDef';fdbkmotif{3}='abcDey';
            %                 [dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
            %
            %             end
            
            
        end
        %         catch
        %         continue
        
        %         end
    end
end
%% This script uses vg_MakeTrigInfoFlex to make trigInfo fields
clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

binsize=.025;
xl=0.3;
bplot = 0;
for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
%         if strcmp(contents(i).name,'dbase051315_14chan6_M_sl_nsr.mat');    
            load([fold{y} contents(i).name]);
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            exclude_default=sort([dbase.filestarttimes dbase.fileendtimes concatenate(dbase.stimtimes)]);
             
            Zstarttimes = dbase.allsyllstarts(dbase.allsyllnames == 'Z');
%             % Trigger: syllable start times, Events: spikes, Exclude: []
%             trigger = concatenate(dbase.syllstarttimes);
%             events = concatenate(dbase.spiketimes);
%             exclude = [];
%             %             exclude = sort([concatenate(dbase.boutstarts) concatenate(dbase.boutends)]);
%             bplot = 0;
%             trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot, xl, binsize);
%             dbase.trigInfoSyllOnsetsSpikes = trigInfo;
%             %             clear trigger events exclude bplot trigInfo;
            
            % Trigger: movement onsets, Events: spikes, Exclude: only
            % default
            clear trigger events exclude;
            trigger=concatenate(dbase.moveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=exclude_default;
            dbase.trigInfomoveonsbin25=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);            
            

            % Trigger: movement onsets, Events: spikes, Exclude: syllable
            % onsets and syllable offsets
            clear trigger events exclude;
            trigger=concatenate(dbase.moveonsets);
            events = concatenate(dbase.spiketimes);
            exclude=sort([exclude_default concatenate(dbase.syllstarttimes) concatenate(dbase.syllendtimes)]);
            dbase.trigInfomoveonsbin25no_song=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);

            % Trigger: syllable onsets, Events: spikes, Exclude: Z start
            % times
            clear trigger events exclude;
            trigger=concatenate(dbase.syllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=[exclude_default Zstarttimes];
            dbase.trigInfoSyllOnsetsSpikes=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                        
            % Trigger: syllable onsets, Events: spikes, Exclude: movement
            % onsets and offsets and Z start times
            clear trigger events exclude;
            trigger=concatenate(dbase.syllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets)]);
            dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsets=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            
            % Trigger: syllable onsets, Events: spikes, Exclude: Z start
            % times, bout start times, bout end times
            clear trigger events exclude;
            trigger=concatenate(dbase.syllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=[exclude_default Zstarttimes concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
            dbase.trigInfoSyllOnsetsSpikesNoBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
                        
            % Trigger: syllable onsets, Events: spikes, Exclude: movement
            % onsets and offsets and Z start times, bout start times, bout
            % end times
            clear trigger events exclude;
            trigger=concatenate(dbase.syllstarttimes);
            events = concatenate(dbase.spiketimes);
            exclude=([exclude_default Zstarttimes concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) concatenate(dbase.boutstarts) concatenate(dbase.boutends)]);
            dbase.trigInfoSyllOnsetsSpikesNoMoveOnsetsMoveOffsetsBoutStartsBoutEnds=vgm_MakeTrigInfoFlex(trigger, events, exclude,dbase, bplot,xl,binsize);
            
            
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
        
    end
end
%% This script makes the field trigInfomotifmoveons and
% trigInfofdbkmotifmoveons for 2995 dbases
clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

% binsize=.025;xl=1.05;
for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            if strcmp(dbase.BirdID, '2995')
                motifmoveons = {'abcde'};
                fdbkmotifmoveons = {'abcDe'};
                [dbase]=vgm_dbaseMakeTrigInfomotifmoveons(dbase,motifmoveons,fdbkmotifmoveons);
            end
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
        
    end
end

%% This script runs dbasespikewidth on all dbases to make the field 'thespike'
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
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
%             pold = dbase.PathName;
%             ind_VTA = strfind(pold, 'VTA');
%             pfirst = 'H:\Vikram\Rig Data\';
%             pnew = [pfirst pold(ind_VTA:end)];
%             dbase.PathName = pnew;
            
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
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
        
    end
end

%% This script runs vgm_spiketrainautocorrelation on all files
clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';

lag = 1.2;
bplot1 = 0;
for y=1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];

            
            if isfield(dbase, 'spiketrainautocorr')
                dbase = rmfield(dbase, 'spiketrainautocorr');
            end
            for binsize = [0.01 0.025 0.050]
                [dbase] = vgm_dbaseSpikeTrainAutocorrelation(dbase, lag, bplot1, binsize);
            end
            
            save(dbase.dbasePathNameVikram,'dbase');
        end
        
    end
end

%% This script plots thespike
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
            dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            
            figure;
            plot(dbase.thespike.edges, dbase.thespike.thespike)
            title(dbase.title)
            
            
        end
        
    end
end


%%
clear
fold{1}='H:\Vikram\Rig Data\VTA\MetaAnalysis\N10ms\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});
for i=3:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        motif = dbase.motif;
        fdbkmotif = dbase.fdbkmotif;
        dbase = rmfield(dbase, 'trigInfomotif');
        dbase = rmfield(dbase, 'trigInfofdbkmotif');
        [dbase]=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
        
        trigInfo = dbase.trigInfomotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfomotif{1}.warped = trigInfo;
        clear trigInfo
        
        trigInfo = dbase.trigInfofdbkmotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfofdbkmotif{1}.warped = trigInfo;
        clear trigInfo
        
        if i~=9
            trigInfo = dbase.trigInfofdbkmotif{2}.warped;
            trigInfo=vgm_MonteCarlo_t(trigInfo);
            dbase.trigInfofdbkmotif{2}.warped = trigInfo;
        end
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end
%% for making a 2 ms raster to calculate latencies
clear
fold{1}='H:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});
for i=3%6:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        motif = dbase.motif;
        fdbkmotif = dbase.fdbkmotif;
        dbase = rmfield(dbase, 'trigInfomotif');
        dbase = rmfield(dbase, 'trigInfofdbkmotif');
        [dbase]=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
        
        trigInfo = dbase.trigInfomotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfomotif{1}.warped = trigInfo;
        clear trigInfo
        
        trigInfo = dbase.trigInfofdbkmotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfofdbkmotif{1}.warped = trigInfo;
        clear trigInfo
        
        %         if i~=16
        %             trigInfo = dbase.trigInfofdbkmotif{2}.warped;
        %             trigInfo=vgm_MonteCarlo_t(trigInfo);
        %             dbase.trigInfofdbkmotif{2}.warped = trigInfo;
        %         end
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end



%% makes the field dbase.fdbklatencies, autocorr

clear
fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
y=1;
contents=dir(fold{y});
for i=9%3:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        %         dbase=vgm_fdbklatencies(dbase);
        
        %spike train autocorrs
        lag=1.5;
        bplot = 0;
        %                         if isfield(dbase, 'ifrautocorr')
        %                         dbase = rmfield(dbase, 'ifrautocorr');
        %                         end
        if isfield(dbase, 'spiketrainautocorr')
            dbase = rmfield(dbase, 'spiketrainautocorr');
        end
        
        %                         [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
        [dbase]=vg_dbaseSpikeTrainAutocorrelation(dbase,lag, bplot);
        
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end


%% Make the fields dbase.fdbksyll, dbase.motif, dbase.fdbkmotif for all the dbasesdb

clear
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});

BirdIDs = [2940 2995 2998 2951 2975 2116 2968 2965 2961];
fdbksylls = 'EDACDDBEB';

for i=3:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        
        fdbksyll = fdbksylls(BirdIDs == str2num(dbase.PathName(24:27)));
        dbase.fdbksyll = fdbksyll;
        motif = lower(fdbksyll);
        fdbkmotif = upper(fdbksyll);
        dbase.motif = {motif};
        dbase.fdbkmotif = {fdbkmotif};
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end

%%
clear
fold{1} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
y=1;
contents=dir(fold{y});
for i=4:length(contents);
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        disp(['Working on ' dbase.title]);
        %         motif = dbase.motif;
        %         fdbkmotif = dbase.fdbkmotif;
        
        %         [dbase]=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
        
        
        %             trigger = concatenate(dbase.syllstarttimes);
        %             events = concatenate(dbase.spiketimes);
        % %             exclude = [];
        %             exclude = sort([concatenate(dbase.moveoffsets) concatenate(dbase.moveonsets)]);
        %             bplot = 1;
        %         trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        %                 clear f a z count fnew;
        %                 f = concatenate(dbase.fdbktimes(not(dbase.unusables)));
        %                 a = concatenate(dbase.syllstarttimes);
        %                 z = a(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
        %                 count = 0;
        %                 for j = 1:length(f)
        %                     if ~any(z >= f(j)-0.005 & z <= f(j)+0.005)
        %                         count = count+1;
        %                         fnew(count) = f(j);
        %                     end
        %                 end
        %
        %
        %                 trigger = fnew+0.05;
        %
        %                 events = concatenate(dbase.spiketimes);
        %                 exclude = [];
        %                 %             exclude = sort([concatenate(dbase.moveoffsets) concatenate(dbase.moveonsets)]);
        %                 bplot = 1;
        %                 trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        %                 trigInfo=vgm_MonteCarloFlex(trigInfo);
        %                 dbase.trigInfofdbkoffsets = trigInfo;
        %                 clear trigInfo
        trigger = concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        %         exclude = [];
        exclude = sort([concatenate(dbase.syllstarttimes) concatenate(dbase.syllendtimes)...
            concatenate(dbase.stimtimes)...
            concatenate(dbase.fdbktimes) concatenate(dbase.fdbktimes)+0.05]);
        bplot = 1;
        trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        trigInfo=vgm_MonteCarloFlex(trigInfo);
        dbase.trigInfoMoveonsetsNoSonSoffStfdonfdoff = trigInfo;
        clear trigInfo
        
        
        %         trigInfo = dbase.trigInfomotif{1}.warped;
        %         trigInfo=vgm_MonteCarlo_t(trigInfo);
        %         dbase.trigInfomotif{1}.warped = trigInfo;
        %         clear trigInfo
        %
        %         trigInfo = dbase.trigInfofdbkmotif{1}.warped;
        %         trigInfo=vgm_MonteCarlo_t(trigInfo);
        %         dbase.trigInfofdbkmotif{1}.warped = trigInfo;
        %         clear trigInfo
        %
        %         if i~=16
        %             trigInfo = dbase.trigInfofdbkmotif{2}.warped;
        %             trigInfo=vgm_MonteCarlo_t(trigInfo);
        %             dbase.trigInfofdbkmotif{2}.warped = trigInfo;
        %         end
        %
        save(dbase.dbasePathName,'dbase');
        
    end
    
end

%%
clear
fold{1} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
y=1;
contents=dir(fold{y});
for i=3:length(contents)
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        for j = 1:length(dbase.moveonsets)
            dbase.moveonsets{j} = dbase.moveonsets{j}';
        end
        for j = 1:length(dbase.moveoffsets)
            dbase.moveoffsets{j} = dbase.moveoffsets{j}';
        end
        save(dbase.dbasePathName,'dbase');
        
    end
    
end




%%
%fold is the name of the folder with all the dbases from a cell type
%fold is the name of the folder with all the dbases from a cell type
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
tic
bplot=0;btriginfo=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            
            if ~isfield(dbase,'trigInfoNoBout');
                
                % [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBout(dbase);
                % [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBout(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBoutSmooth(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBoutSmooth(dbase);
                
                if isfield(dbase,'moveindx');
                    [dbase]=vg_dbaseBoutNonsongIMI(dbase,dbase.moveindx);%Get intermove interval (IMI) = move onsets are analyzed
                    dbase=dbaseMakeTrigInfoSubsongOnsetsNoMoveSmooth(dbase);
                    dbase=dbaseMakeTrigInfoSubsongOffsetsNoMoveSmooth(dbase);
                    dbase=dbaseMakeTrigInfoMoveOnSpikes(dbase);
                    dbase=dbaseMakeTrigInfoMoveOffSpikes(dbase);
                    dbase=dbaseMakeTrigInfoMoveOnSpikesNoSylls(dbase);
                    dbase=dbaseMakeTrigInfoMoveOffSpikesNoSylls(dbase);
                    dbase=dbaseMakeTrigInfoSyllOnMoveOns(dbase);
                    dbase=dbaseMakeTrigInfoSyllOffMoveOns(dbase);
                end
                save(dbase.dbasePathNameJesse, 'dbase');
                dbase.title
            end
        end
    end
end
toc
%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
tic
bplot=0;btriginfo=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            
            
            if isfield(dbase,'moveindx');
                if isfield(dbase.trigInfoNoMove.Onsets3,'edges');
                    figure;plot(dbase.trigInfoNoBout.Onsets3.edges,dbase.trigInfoNoBout.Onsets3.rd)
                    
                    hold on;plot(dbase.trigInfoNoMove.Onsets3.edges,dbase.trigInfoNoMove.Onsets3.rd,'r');
                    xlim([-.3,.3]);title(dbase.title);
                end
                
                
            end
        end
    end
end
toc

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if strfind(dbase.allsylls, 'abcdef')>=6
                %
                %                 [dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
                %                 save(dbase.dbasePathNameJesse, 'dbase');
                
                
                trigInfo1=dbase.trigInfomotif{3}.warped;
                trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
                if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);
                    
                    figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));
                    
                    hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                    xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                    title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf']);
                    count=count+1
                end
                
            end
        end
    end
end

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if strfind(dbase.allsylls, 'abcdef')>=6
                %
                %                 [dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
                %                 save(dbase.dbasePathNameJesse, 'dbase');
                
                
                trigInfo1=dbase.trigInfomotif{3}.warped;
                trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
                if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);
                    
                    figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));
                    
                    hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                    xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                    title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf' ' y=' num2str(y) ' i=' num2str(i)]);
                    count=count+1
                end
                
            end
        end
    end
end

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;

allcellmovedurs=[];
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if isfield(dbase,'moveindx');
                dbase=vg_dbaseGetallmoves(dbase);
                save(dbase.dbasePathNameJesse, 'dbase');
                allcellmovedurs=[allcellmovedurs dbase.allmovedurs];
            end
            
        end
    end
end

%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';

bplot=0;

allcellmovedurs=[];
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            
            if isfield(dbase,'moveindx');
                figure;
                trigger=concatenate(dbase.syllstarttimes);
                events=concatenate(dbase.moveonsets);
                exclude=[concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,1);hold on; plot(t.edges,t.rd);title(['moveons vs ' num2str(length(t.events)) ' syllons']);
                
                trigger=concatenate(dbase.moveoffsets);
                events=concatenate(dbase.spiketimes);
                exclude=[concatenate(dbase.syllstarttimes) concatenate(dbase.syllendtimes) concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,2);hold on; plot(t.edges,t.rd);title(['spikes vs' num2str(length(t.events)) ' moveons']);
                xlabel([dbase.title]);
                
                trigger=concatenate(dbase.syllendtimes);
                events=concatenate(dbase.spiketimes);
                exclude=[concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,3);hold on; plot(t.edges,t.rd);title(['spikes vs ' num2str(length(t.events)) ' syllons']);
                
                
            end
        end
    end
end

%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';


for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            
            
            
            
            
            
            if isfield(dbase,'motif') && isfield(dbase,'fdbkmotif');
                for m=1:length(dbase.motif);
                    motif=dbase.motif{m};
                    
                    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif);
                    dbase.motifstarts{m}=motifstarts;
                    dbase.motifends{m}=motifends;
                    dbase.motifdurs{m}=motifdurs;
                    
                    
                end
                
                for m=1:length(dbase.fdbkmotif);
                    motif=dbase.fdbkmotif{m};
                    
                    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif);
                    dbase.fdbkmotifstarts{m}=motifstarts;
                    dbase.fdbkmotifends{m}=motifends;
                    dbase.fdbkmotifdurs{m}=motifdurs;
                    
                end
                save(dbase.dbasePathNameJesse, 'dbase');
            end
        end
    end
end
%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';

bplot=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            
            
            
            trigger=concatenate(dbase.syllstarttimes);
            events=concatenate(dbase.spiketimes);
            exclude=[];
            exclude=sort(exclude);
            t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
            figure;hold on; plot(t.edges,t.rd);title([dbase.title 'numsylls=' num2str(length(t.events))]);
            
            
            
            if isfield(dbase,'motif') && isfield(dbase,'fdbkmotif');
                figure;
                trigger=concatenate(dbase.motifstarts{2});
                events=concatenate(dbase.spiketimes);
                exclude=[];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                hold on; plot(t.edges,t.rd);
                num=length(t.events);
                
                
                trigger=concatenate(dbase.fdbkmotifstarts{2});
                events=concatenate(dbase.spiketimes);
                exclude=[];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                hold on; plot(t.edges,t.rd,'r');
                title([dbase.title 'ctrl=' num2str(num) 'fdbk=' num2str(length(t.events))]);
            end
        end
    end
end

%%

%explore ifr autocorr

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
lag=1;

for y=[3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            %             [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
            figure;plot(dbase.ifrautocorr.bout.lags/4000,dbase.ifrautocorr.bout.ifr);
            hold on;plot(dbase.ifrautocorr.nonsong.lags/4000,dbase.ifrautocorr.nonsong.ifr,'r');
            title([dbase.title ' y=' num2str(y) ' i=' num2str(i)]);
            vg_plotisidist(dbase,s);
            
            %             save(dbase.dbasePathNameJesse, 'dbase');
        end
    end
end

%%
%keeps below are dbases that had peaks in the ifrautocorr during singing
%but not during nonsong (y,i);
keep=     [2    23
    2     9
    1    24
    1    23
    1    14
    1    11
    1     5
    1     4];

iis=keep(:,2);

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
lag=1;

for y=[1 2];
    contents=dir(fold{y});
    for newi=1:length(unique(keep(:,2)));
        i=iis(newi);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            trigger=concatenate(dbase.syllstarttimes);
            events=concatenate(dbase.spiketimes);
            exclude=[concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
            exclude=sort(exclude);
            t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, 0);
            figure; plot(t.edges,t.rd);title(['spikes vs ' num2str(length(t.events)) ' syllons']);
            trigInfo1=dbase.trigInfomotif{3}.warped;
            trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
            if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);
                figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));
                hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf' '-y=' num2str(y) '-i=' num2str(i)]);
            end
        end
    end
end
%%
dbase.stimclips.anticlips{1}

%%
clear
fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\N2ms\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});
for i=3:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        
        1/(length(dbase.trigInfomotif{1}.warped.allmotifdurs)*dbase.rates.bout)
        
        
        
    end
    
end

%% Bird ID field

clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';
y=3;
contents=dir(fold{y});
for i=3:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathNameVikram=[fold{y} contents(i).name];
        ind_VTA = strfind(dbase.PathName, 'VTA');
        dbase.BirdID = dbase.PathName(ind_VTA+4:ind_VTA+7);
        
        
        
        save(dbase.dbasePathNameVikram,'dbase');
        
    end
    
end

%% List of bird IDs
clear
fold{1}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA adromic\';
fold{2}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA error\';
fold{3}='C:\Users\GoldbergLab\Dropbox\Vikram\MetaAnalysis\manuscript\dbases\VTA other dbases\';
count = 0;
count1 = 0;
AllBirdIDs = {};
for y = 1:3
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            %         dbase.dbasePathNameVikram=[fold{y} contents(i).name];
            %         ind_VTA = strfind(dbase.PathName, 'VTA');
            %         dbase.BirdID = dbase.PathName(ind_VTA+4:ind_VTA+7);
            count1 = count1+1;
            BirdIDList{count1, 1} = dbase.BirdID;
            if ~any(strcmp(AllBirdIDs, dbase.BirdID))
                count = count+1;
                AllBirdIDs{count,1} = dbase.BirdID;
            end
            
            
            
            %         save(dbase.dbasePathNameVikram,'dbase');
            
        end
        
    end
end


