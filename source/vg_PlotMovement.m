clear
fold{1} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
y=1;
contents=dir(fold{y});
for i=9%[3:38 40:length(contents)];
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        i-2
        disp(['Working on ' dbase.title]);
        
        % spikes vs. syllable onsets
        trigger = concatenate(dbase.syllstarttimes);
        events = concatenate(dbase.spiketimes);
        %         exclude = [];
        exclude = sort([concatenate(dbase.boutstarts) concatenate(dbase.boutends)]);
        bplot = 0;
        trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        dbase.trigInfoSyllOnsetsNoBouts = trigInfo;
        clear trigger events exclude bplot trigInfo;
        
        % spikes vs. movement onsets
        trigger = concatenate(dbase.moveonsets);
        events = concatenate(dbase.spiketimes);
        exclude = [];
        bplot = 0;
        trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        dbase.trigInfoMoveOnsets = trigInfo;
        clear trigger events exclude bplot trigInfo;
        
        % movement onsets vs. syllable onsets
        trigger = concatenate(dbase.syllstarttimes);
        events = concatenate(dbase.moveonsets);
        %         exclude = [];
        exclude = sort([concatenate(dbase.boutstarts) concatenate(dbase.boutends)]);
        bplot = 0;
        trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        dbase.trigInfoSyllOnsetsMoveOnsetsNoBouts = trigInfo;
        clear trigger events exclude bplot trigInfo;
        
        % spikes vs. syllable onsets no movement onsets or offsets
        trigger = concatenate(dbase.syllstarttimes);
        events = concatenate(dbase.spiketimes);
        exclude = sort([concatenate(dbase.moveoffsets) concatenate(dbase.moveonsets) ...
            concatenate(dbase.boutstarts) concatenate(dbase.boutends)]);
        bplot = 0;
        trigInfo=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
        dbase.trigInfoSyllOnsetsNoBoutsNoMoves = trigInfo;
        clear trigger events exclude bplot trigInfo;
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end

%% With bouts
clear
fold{1} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
y=1;
contents=dir(fold{y});
for i=3:8%[3:38 40:length(contents)];
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        i-2
        disp(['Working on ' dbase.title]);
        s = 3;
        h = figure(i-2);
        
        
        subplot(2,2,1)
        
        edges = dbase.trigInfoSyllOnsets.edges;
        rd = dbase.trigInfoSyllOnsets.rd;
        numtrig = length(dbase.trigInfoSyllOnsets.events);
        plot(edges, smooth(rd,s), 'k')
        xlim([-0.3 0.3])
        xlabel('Time relative to syllable onset (s)')
        ylabel('Spike Rate (Hz)')
        title([dbase.title ' ' num2str(numtrig) ' triggers'], 'Interpreter', 'None')
        
        subplot(2,2,2)
        edges = dbase.trigInfoMoveOnsets.edges;
        rd = dbase.trigInfoMoveOnsets.rd;
        numtrig = length(dbase.trigInfoMoveOnsets.events);
        plot(edges, smooth(rd,3), 'k')
        xlim([-0.3 0.3])
        xlabel('Time relative to movement onset (s)')
        ylabel('Spike Rate (Hz)')
        title([num2str(numtrig) ' triggers'])
        
        subplot(2,2,3)
        edges = dbase.trigInfoSyllOnsetsMoveOnsets.edges;
        rd = dbase.trigInfoSyllOnsetsMoveOnsets.rd;
        numtrig = length(dbase.trigInfoSyllOnsetsMoveOnsets.events);
        plot(edges, smooth(rd,3), 'k')
        xlim([-0.3 0.3])
        xlabel('Time relative to syllable onset (s)')
        ylabel('Movement onset Rate (Hz)')
        title([num2str(numtrig) ' triggers'])
        
        subplot(2,2,4)
        edges = dbase.trigInfoSyllOnsetsNoMoves.edges;
        rd = dbase.trigInfoSyllOnsetsNoMoves.rd;
        numtrig = length(dbase.trigInfoSyllOnsetsNoMoves.events);
        plot(edges, smooth(rd,3), 'k')
        xlim([-0.3 0.3])
        xlabel('Time relative to syllable onset (s) no movement')
        ylabel('Spike Rate (Hz)')
        title([num2str(numtrig) ' triggers'])
        
        print(h, '-djpeg', num2str(i-2))
        
    end
end

%% No bouts
clear
fsz = 8;
fold{1} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2} = 'F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
for y=1;
    contents=dir(fold{y});
    for i=3:9%[3:38 41:length(contents)];
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
            dbase.dbasePathName=[fold{y} contents(i).name];
            i-2
            disp(['Working on ' dbase.title]);
            s = 3;
            h = figure(i-2);
            
            
            subplot(2,3,1)
            
            edges = dbase.trigInfoSyllOnsetsNoBouts.edges;
            rd = dbase.trigInfoSyllOnsetsNoBouts.rd;
            numtrig = length(dbase.trigInfoSyllOnsetsNoBouts.events);
            plot(edges, smooth(rd,s), 'k')
            xlim([-0.3 0.3])
            xlabel('Time relative to syllable onset (s)', 'Fontsize', fsz)
            ylabel('Spike Rate (Hz)', 'Fontsize', fsz)
            title([dbase.title ' ' num2str(numtrig) ' triggers'], 'Interpreter', 'None', 'Fontsize', fsz)
            set(gca, 'Fontsize', fsz)
            
            subplot(2,3,2)
            edges = dbase.trigInfoMoveOnsets.edges;
            rd = dbase.trigInfoMoveOnsets.rd;
            numtrig = length(dbase.trigInfoMoveOnsets.events);
            plot(edges, smooth(rd,3), 'k')
            xlim([-0.3 0.3])
            xlabel('Time relative to movement onset (s)', 'Fontsize', fsz)
            ylabel('Spike Rate (Hz)', 'Fontsize', fsz)
            title([num2str(numtrig) ' triggers'], 'Fontsize', fsz)
            set(gca, 'Fontsize', fsz)
            
            subplot(2,3,3)
            edges = dbase.trigInfoSyllOnsetsMoveOnsetsNoBouts.edges;
            rd = dbase.trigInfoSyllOnsetsMoveOnsetsNoBouts.rd;
            numtrig = length(dbase.trigInfoSyllOnsetsMoveOnsetsNoBouts.events);
            plot(edges, smooth(rd,3), 'k')
            xlim([-0.3 0.3])
            xlabel('Time relative to syllable onset (s)', 'Fontsize', fsz)
            ylabel('Movement onset Rate (Hz)', 'Fontsize', fsz)
            title([num2str(numtrig) ' triggers'], 'Fontsize', fsz)
            set(gca, 'Fontsize', fsz)
            
            subplot(2,3,4)
            edges = dbase.trigInfoSyllOnsetsNoBoutsNoMoves.edges;
            rd = dbase.trigInfoSyllOnsetsNoBoutsNoMoves.rd;
            numtrig = length(dbase.trigInfoSyllOnsetsNoBoutsNoMoves.events);
            plot(edges, smooth(rd,3), 'k')
            xlim([-0.3 0.3])
            xlabel('Time relative to syllable onset (s) no movement', 'Fontsize', fsz)
            ylabel('Spike Rate (Hz)', 'Fontsize', fsz)
            title([num2str(numtrig) ' triggers'], 'Fontsize', fsz)
            set(gca, 'Fontsize', fsz)
            
            subplot(2,3,5)
            edges = dbase.spiketrainautocorr.edges;
            stacbout = dbase.spiketrainautocorr.nlbout30ms;
            stacnonsong = dbase.spiketrainautocorr.nlnonsong30;
            plot(edges, stacbout, 'r')
            hold on
            plot(edges, stacnonsong, 'b')
            hold off
            xlim([0 1.5])
            xlabel('Lag (s)', 'Fontsize', fsz)
            ylabel('Normalized Spike Train Autocorrelation', 'Fontsize', fsz)
            legend('bout', 'nonsong', 'Location', 'NorthEast')
            set(gca, 'Fontsize', fsz)
            
            subplot(2,3,6)
            edges = 0:0.005:2;
            Nbout = histc(dbase.boutISI, edges);
            Pbout = Nbout/length(dbase.boutISI);
            Nnonsong = hist(dbase.nonsongISI, edges);
            Pnonsong = Nnonsong/length(dbase.nonsongISI);
            plot(edges, Pbout, 'r')
            hold on
            plot(edges, Pnonsong, 'b')
            hold off
            xlim([0 0.1])
            xlabel('ISI (s)', 'Fontsize', fsz)
            ylabel('Probability', 'Fontsize', fsz)
            legend('bout', 'nonsong', 'Location', 'NorthEast')
            set(gca, 'Fontsize', fsz)
            
%             print(h, '-djpeg', ['N' num2str(i-2)])
            
        end
    end
end



