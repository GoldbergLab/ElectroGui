close all
clear

fold{1}='H:\Vikram\Rig Data\VTA\MetaAnalysis\N10ms\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});
for i=3:length(contents);
    clearvars -except fold i y contents
    i-2
    file = [fold{y} contents(i).name];
    load(file);
    
    
    % select the dbase file to load
    % file = 'dbase050214_3Chan2_ForAnalysis.mat';
    % file = 'dbase092114_1chan5_ForAnalysis.mat';
    % file = 'dbase100714_3chan7_ForAnalysis.mat';
    % file = 'dbase102014_1chan2_ForAnalysis.mat';
    % file = 'dbase102614_1chan2_ForAnalysis.mat';
    % file = 'dbase102714_1chan6_ForAnalysis.mat';
    % file = 'dbase102814_1chan2_ForAnalysis.mat';
    % file = 'edbase020515_1chan4_ForAnalysis.mat';
    % load(file)
    
    if i-2 == 7
    yesz = 0;
    else yesz = 1;
    end
    
    fdbkdur = 0.05;
    edges = dbase.trigInfomotif{1}.warped.edges;
    edgesfdbk = dbase.trigInfofdbkmotif{1}.warped.edges;
    if yesz
        edgesZ = dbase.trigInfofdbkmotif{2}.warped.edges;
    end
    rd = dbase.trigInfomotif{1}.warped.rd;
    rdfdbk = dbase.trigInfofdbkmotif{1}.warped.rd;
    if yesz
        rdZ = dbase.trigInfofdbkmotif{2}.warped.rd;
    end
    warp = dbase.trigInfofdbkmotif{1}.warped.warp;
    
    rdsmooth = smooth(rd, 3);
    rdfdbksmooth = smooth(rdfdbk, 3);
    if yesz
        rdZsmooth = smooth(rdZ, 3);
    end
    
    % rddiff = rdsmooth-rdfdbksmooth;
    
    dataStart = dbase.trigInfomotif{1}.warped.dataStart{1};
    dataStop = dbase.trigInfomotif{1}.warped.dataStop{1};
    if yesz
        dataStartZ = dbase.trigInfofdbkmotif{2}.warped.dataStart{1};
        dataStopZ = dbase.trigInfofdbkmotif{2}.warped.dataStop{1};
    end
    
    
    
    eventOnsetsEscape = dbase.trigInfomotif{1}.warped.eventOnsets{1};
    eventOnsetsHit = dbase.trigInfofdbkmotif{1}.warped.eventOnsets{1};
    eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
    if yesz
        eventOnsetsZ = dbase.trigInfofdbkmotif{2}.warped.eventOnsets{1};
    end
    
    fdbktimes = concatenate(dbase.fdbktimes);
    
    motifstarts = dbase.trigInfomotif{1}.warped.motifstarts;
    motifends = dbase.trigInfomotif{1}.warped.motifends;
    fdbkmotifstarts = dbase.trigInfofdbkmotif{1}.warped.motifstarts;
    fdbkmotifends = dbase.trigInfofdbkmotif{1}.warped.motifends;
    if yesz
        Zmotifstarts = dbase.trigInfofdbkmotif{2}.warped.motifstarts;
        Zmotifends = dbase.trigInfofdbkmotif{2}.warped.motifends;
    end
    
    for i = 1:length(fdbkmotifstarts)
        tempfdbktimes(i) = fdbktimes(fdbktimes>fdbkmotifstarts(i) & fdbktimes<fdbkmotifends(i));
        tempfdbkstarttimes(i) = tempfdbktimes(i)-fdbkmotifstarts(i);
        tempfdbkendtimes(i) = tempfdbkstarttimes(i)+fdbkdur;
        tempfdbkstarttimes(i) = tempfdbkstarttimes(i)*warp(i);
        tempfdbkendtimes(i) = tempfdbkendtimes(i)*warp(i);
    end
    searchWin = 0.015;
    if yesz
        for i = 1:length(Zmotifstarts)
            tempZtimes(i) = fdbktimes(fdbktimes>Zmotifstarts(i)-searchWin & fdbktimes<Zmotifends(i)+searchWin);
            tempZtimes(i) = tempZtimes(i)-Zmotifstarts(i);
        end
    end
    
    fdbkstartimemedian = median(tempfdbkstarttimes);
    
    fdbkmedianedge = sum(edges<fdbkstartimemedian);
    
    
    
    % FIGURE 7
    fsz = 10;
    hf = figure;
    set(hf, 'position', [680 678 1000 420])
    
    
    
    % SUBPLOT(2,2,1)
    hs1 = subplot(2,2,1);
    s1p = get(hs1, 'Position');
    s1p(2) = 0.8*s1p(2);
    set(hs1, 'Position', s1p)
    
    set(gca, 'Box', 'On')
    % title(file, 'Interpreter', 'None')
    hold on
    lineheight=1;
    for i=1:length(eventOnsetsHit)
        spks=eventOnsetsHit{1,i};
        if ~isempty(spks);
            hr = rectangle('Position', [tempfdbkstarttimes(i) i-1 tempfdbkendtimes(i)-tempfdbkstarttimes(i) 1], 'FaceColor', 'r', 'EdgeColor', 'r');
            for j=1:length(spks)
                line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k')
            end
            
        end
    end
    yline = length(eventOnsetsHit);
    line([dataStart dataStop], [yline, yline], 'color', 'k')
    for i=1:length(eventOnsetsEscape)
        spks=eventOnsetsEscape{1,i};
        if ~isempty(spks);
            for j=1:length(spks)
                line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k');
            end
        end
    end
    hold off
    xlim([dataStart dataStop])
    ylim([0 length(eventOnsetsAll)])
    set(gca, 'FontSize', fsz)
    set(gca, 'XTickLabel', [])
    set(gca, 'YTickLabel', [])
    ylabel('Hits      Escapes')
    
    if yesz
        % SUBPLOT(2,2,2)
        hs2 = subplot(2,2,2);
        Data1w = dataStop-dataStart;
        Data2w = dataStopZ-dataStartZ;
        s1p = get(hs1, 'Position');
        sp1w = s1p(3);
        sp2w = sp1w*(Data2w/Data1w);
        s2p = get(hs2, 'Position');
        s2p(3) = sp2w;
        s2p(2)=0.8*s2p(2);
        set(hs2, 'Position', s2p)
        set(gca, 'Box', 'On')
        hold on
        lineheight=1;
        for i=1:length(eventOnsetsZ)
            spks=eventOnsetsZ{1,i};
            %     if ~isempty(spks);
            hr = rectangle('Position', [tempZtimes(i) i-1 fdbkdur 1], 'FaceColor', 'r', 'EdgeColor', 'r');
            for j=1:length(spks)
                line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k')
            end
            
            %     end
        end
        hold off
        xlim([dataStartZ dataStopZ])
        ylim([0 length(eventOnsetsZ)])
        set(gca, 'FontSize', fsz)
        set(gca, 'XTickLabel', [])
        set(gca, 'YTickLabel', [])
        ylabel('Feedback outside song')
        
    end
    
    
    
    % SUBPLOT(2,2,3)
    subplot(2,2,3)
    
    pHitMin = dbase.trigInfofdbkmotif{1}.warped.pval.minrate;
    pHitMax = dbase.trigInfofdbkmotif{1}.warped.pval.maxrate;
    pEscapeMin = dbase.trigInfomotif{1}.warped.pval.minrate;
    pEscapeMax = dbase.trigInfomotif{1}.warped.pval.maxrate;
    
    % winsz = 0.1;
    % stepsz = 0.005;
    %modified
    winsz = 0.01;
    stepsz = 0.005;
    
    winstart = dataStart:stepsz:dataStop-winsz;
    X = winstart+winsz/2;
    for i=1:length(winstart)
        for j=1:length(fdbkmotifstarts)
            HitMat(j,i) = sum(eventOnsetsHit{j} >= winstart(i) & eventOnsetsHit{j} < winstart(i)+winsz);
        end
    end
    
    for i=1:length(winstart)
        for j=1:length(motifstarts)
            EscapeMat(j,i) = sum(eventOnsetsEscape{j} >= winstart(i) & eventOnsetsEscape{j} < winstart(i)+winsz);
        end
    end
    
    for i= 1:length(winstart)
        [p(i), H(i)] = ranksum(HitMat(:,i), EscapeMat(:,i), 'alpha', 0.05);
    end
    Hshift1 = [H(2:end) 0];
    Hshift2 = [H(3:end) 0 0];
    Hsig = (H+Hshift1+Hshift2) == 3;
    Xsig = X(Hsig);
    
    binsize = edges(2)-edges(1);
    
    latency = Xsig(1)-fdbkstartimemedian;
    
    
    hp1 = stairs(edgesfdbk, rdfdbksmooth, 'r', 'LineWidth', 2.0);
    hold on
    hp2 = stairs(edges, rdsmooth, 'b', 'LineWidth', 2.0);
    
    YLim = get(gca, 'YLim');
    
    YLimU = 10*ceil(1.2*max([rdfdbksmooth; rdsmooth])/10);
    for i=1:length(Xsig)
        rectangle('Position', [Xsig(i)-stepsz/2 0.9*YLimU 2*stepsz 0.01*(YLimU-YLim(1))], 'FaceColor', 'k', 'EdgeColor', 'k')
    end
    
    hold off
    xlim([dataStart dataStop])
    ylim([YLim(1) YLimU])
    set(gca, 'FontSize', fsz)
    xlabel('Time relative to motif onset (s)', 'FontSize', fsz)
    ylabel('Firing Rate (Hz)', 'FontSize', fsz)
    
    gtext(['Latency = ' num2str(round(1000*latency)) ' ms'], 'Interpreter', 'None');
    
    
    if pHitMin<0.001
        LpHitMin = '< 0.001';
    else
        LpHitMin = ['= ' num2str(pHitMin)];
    end
    if pHitMax<0.001
        LpHitMax = '< 0.001';
    else
        LpHitMax = ['= ' num2str(pHitMax)];
    end
    if pEscapeMin<0.001
        LpEscapeMin = '< 0.001';
    else
        LpEscapeMin = ['= ' num2str(pEscapeMin)];
    end
    if pEscapeMax<0.001
        LpEscapeMax = '< 0.001';
    else
        LpEscapeMax = ['= ' num2str(pEscapeMax)];
    end
    % LegendHit = ['Hit ' 'p_{min} ' LpHitMin ', p_{max} ' LpHitMax];
    % LegendEscape = ['Escape ' 'p_{min} ' LpEscapeMin ', p_{max} ' LpEscapeMax];
    % hl = legend(LegendHit, LegendEscape, 'Location', 'NW');
    %
    % set(hl, 'FontSize', 6)
    
    
    
    if yesz
        
        % SUBPLOT(2,2,4)
        
        pZMin = dbase.trigInfofdbkmotif{2}.warped.pval.minrate;
        pZMax = dbase.trigInfofdbkmotif{2}.warped.pval.maxrate;
        
        
        hs4 = subplot(2,2,4);
        s4p = get(hs4, 'Position');
        s4p(3) = s2p(3);
        set(hs4, 'Position', s4p)
        % set(hs4, 'Position', [0.6 0.11 0.25 0.341163])
        
        hp1 = stairs(edgesZ, rdZsmooth, 'r', 'LineWidth', 2.0);
        
        
        
        
        
        
        
        xlim([dataStartZ dataStopZ])
        set(hs4, 'XTick', [-0.4:0.2:0.4])
        set(hs4, 'XTickLabel', {'-0.4', '-0.2', '0', '0.2', '0.4'})
        ylim([YLim(1) YLimU])
        set(gca, 'FontSize', fsz)
        xlabel('Time relative to feedback onset (s)', 'FontSize', fsz)
        ylabel('Firing Rate (Hz)', 'FontSize', fsz)
        
        if pZMin<0.001
            LpZMin = '< 0.001';
        else
            LpZMin = ['= ' num2str(pZMin)];
        end
        if pZMax<0.001
            LpZMax = '< 0.001';
        else
            LpZMax = ['= ' num2str(pZMax)];
        end
        
        
        LegendZ = ['Fdbk-NoSong ' 'p_{min} ' LpZMin ', p_{max} ' LpZMax];
        h2 = legend(LegendZ, 'Location', 'NW');
        set(h2, 'FontSize', 6)
        
    end
    
    hg = gtext(file, 'Rotation', [90], 'Interpreter', 'None');
end