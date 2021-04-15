% testing for movement figure
% close all
clear
fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';

count = 0;
for y = 2%1:length(fold)
    contents=dir(fold{y});
    for k=36%3:length(contents);
        k-2
        if strcmp(contents(k).name(end),'t');
            load([fold{y} contents(k).name]);
            
           
            
            fdbkdur = 0.05;
            edges = dbase.trigInfomotif{1}.warped.edges;
            edgesfdbk = dbase.trigInfofdbkmotif{1}.warped.edges;
            n = min(length(edges), length(edgesfdbk));
            edges = edges(1:n);
            edgesfdbk = edgesfdbk(1:n);
            % edgesZ = dbase.trigInfofdbkmotif{2}.warped.edges;
            rd = dbase.trigInfomotif{1}.warped.rd;
            rdfdbk = dbase.trigInfofdbkmotif{1}.warped.rd;
            rd = rd(1:n);
            rdfdbk = rdfdbk(1:n);
            
            % rdZ = dbase.trigInfofdbkmotif{2}.warped.rd;
            warp = dbase.trigInfofdbkmotif{1}.warped.warp;
            
            rdsmooth = smooth(rd, 3);
            rdfdbksmooth = smooth(rdfdbk, 3);
            % rdZsmooth = smooth(rdZ, 3);
            
            % rddiff = rdsmooth-rdfdbksmooth;
            
            dataStart = dbase.trigInfomotif{1}.warped.dataStart{1};
            dataStop = dbase.trigInfomotif{1}.warped.dataStop{1};
            % dataStartZ = dbase.trigInfofdbkmotif{2}.warped.dataStart{1};
            % dataStopZ = dbase.trigInfofdbkmotif{2}.warped.dataStop{1};
            
            
            
            eventOnsetsEscape = dbase.trigInfomotif{1}.warped.eventOnsets{1};
            eventOnsetsHit = dbase.trigInfofdbkmotif{1}.warped.eventOnsets{1};
            eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
            % eventOnsetsZ = dbase.trigInfofdbkmotif{2}.warped.eventOnsets{1};
            
            fdbktimes = concatenate(dbase.fdbktimes);
            
            motifstarts = dbase.trigInfomotif{1}.warped.motifstarts;
            motifends = dbase.trigInfomotif{1}.warped.motifends;
            fdbkmotifstarts = dbase.trigInfofdbkmotif{1}.warped.motifstarts;
            fdbkmotifends = dbase.trigInfofdbkmotif{1}.warped.motifends;
            % Zmotifstarts = dbase.trigInfofdbkmotif{2}.warped.motifstarts;
            % Zmotifends = dbase.trigInfofdbkmotif{2}.warped.motifends;
            
            for i = 1:length(fdbkmotifstarts)
                tempfdbktimes(i) = fdbktimes(fdbktimes>fdbkmotifstarts(i) & fdbktimes<fdbkmotifends(i));
                tempfdbkstarttimes(i) = tempfdbktimes(i)-fdbkmotifstarts(i);
                tempfdbkendtimes(i) = tempfdbkstarttimes(i)+fdbkdur;
                tempfdbkstarttimes(i) = tempfdbkstarttimes(i)*warp(i);
                tempfdbkendtimes(i) = tempfdbkendtimes(i)*warp(i);
            end
            searchWin = 0.015;
            
            
            
            
            fsz = 10;
            hf = figure();
            
            
            
            
            hs1 = subplot(2,1,1);
            
            
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
            
            
            
            
            
            % SUBPLOT(2,2,3)
            subplot(2,1,2)
            
            pHitMin = dbase.trigInfofdbkmotif{1}.warped.pval.minrate;
            pHitMax = dbase.trigInfofdbkmotif{1}.warped.pval.maxrate;
            pEscapeMin = dbase.trigInfomotif{1}.warped.pval.minrate;
            pEscapeMax = dbase.trigInfomotif{1}.warped.pval.maxrate;
            
            winsz = 0.1;
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
                [p(i), H(i)] = ranksum(HitMat(:,i), EscapeMat(:,i));
            end
            Hshift = [H(2:end) 0];
            Hsig = and(H, Hshift);
            Xsig = X(Hsig);
            
            
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
            LegendHit = ['Hit ' 'p_{min} ' LpHitMin ', p_{max} ' LpHitMax];
            LegendEscape = ['Escape ' 'p_{min} ' LpEscapeMin ', p_{max} ' LpEscapeMax];
            % hl = legend(LegendHit, LegendEscape, 'Location', 'NW');
            
            % set(hl, 'FontSize', 6)
            
            
            clearvars -except y k fold contents
            
        end
    end
end

