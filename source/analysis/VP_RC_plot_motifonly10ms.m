function fig = VP_RC_plot_motifonly10ms(dbase, varargin)

if isempty(varargin);
    bDisplay=1;
else
    bDisplay=varargin{1};
end

count = 0;
Ncon = 4;
Ncoff = 4;
winsz = 0.03;
stepsz = 0.005;
xlimit = [-.5,.5];
fsz = 16;
lw = 2;
smoothwin=3;

bdirection = 0;
bplot = 0;
bsave = 0;

loaddata = 1;

ord = 80;

count = count+1;

eventOnsetsHit = dbase.trigInfoFhitbin10.events;
eventOnsetsEscape = dbase.trigInfocatchbin10.events;
% eventOnsetsHitpreCC = dbase.trigInfoFhitbin10preCC.events;
% eventOnsetsEscapepreCC = dbase.trigInfocatchbin10preCC.events;
% eventOnsetsHitpostCC = dbase.trigInfoFhitbin10postCC.events;
% eventOnsetsEscapepostCC = dbase.trigInfocatchbin10postCC.events;
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
% eventOnsetsAllpreCC = [eventOnsetsHitpreCC eventOnsetsEscapepreCC];
% eventOnsetsAllpostCC = [eventOnsetsHitpostCC eventOnsetsEscapepostCC];
% eventOnsetsMove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
% eventOnsetsMoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.events;
% eventOnsetsMoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
edges = dbase.trigInfoFhitbin10.edges;
rdhit = dbase.trigInfoFhitbin10.rd;
% rdhitpreCC = dbase.trigInfoFhitbin10preCC.rd;
% rdhitpostCC = dbase.trigInfoFhitbin10postCC.rd;
rdescape = dbase.trigInfocatchbin10.rd;
% rdescapepreCC = dbase.trigInfocatchbin10preCC.rd;
% rdescapepostCC = dbase.trigInfocatchbin10postCC.rd;
% rdmove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rd;
% rdmoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoSylls.rd;
% rdmoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.rd;
rdhitsmooth = smooth(dbase.trigInfoFhitbin10.rd,smoothwin);
rdescapesmooth = smooth(dbase.trigInfocatchbin10.rd,smoothwin);
% rdmovesmooth = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rds;
% rdmoveNoSyllsmooth = dbase.trigInfoMoveOnsetsSpikesNoSylls.rds;
% rdmoveBoutsmooth = dbase.trigInfoBoutMoveOnsetsSpikes.rds;
dataStart = dbase.trigInfoFhitbin10.edges(1);
dataStop = dbase.trigInfoFhitbin10.edges(end);
pmin = dbase.trigInfoFhitbin10.pval.minrates;
pmin_stats(count) = pmin;
mintime = dbase.trigInfoFhitbin10.corrtime.mins;
pmax = dbase.trigInfocatchbin10.pval.maxrates;
pmax_stats(count) = pmax;
maxtime = dbase.trigInfocatchbin10.corrtime.maxs;
hitmin = min(rdhitsmooth);
escapemax = max(rdescapesmooth);
yrange = escapemax-hitmin;
trigStarts = dbase.trigInfoFhitbin10.trigStarts;
errorzscore = zscore(rdescapesmooth-rdhitsmooth);


fdbktimes = concatenate(dbase.fdbktimes);
fdbkdur = 0.050;

%difference analysis
winstart = dataStart:stepsz:dataStop-winsz;
X = winstart+winsz/2;

for n = 1:2
    switch n
        case 1 %escape- hit
            errorzscore = zscore(rdescapesmooth-rdhitsmooth);
            %         [Xsigon, Xsigoff] = pp_error_diffAnalysis(dbase,errorzscore,10);
             [pvals,edges_bar,Xsigon,Xsigoff] = rc_trigInfoRasterRanksum(dbase.trigInfoFhitbin10,dbase.trigInfocatchbin10,winsz,stepsz);
            
            fig = figure('units','normalized','outerposition',[0 0 1 1]);
            fig.Renderer='Painters';
            set( fig, 'Color', 'White', 'Unit', 'Normalized', ...
                'Position', [0.1,0.1,0.6,0.6] ) ;
            if ~bDisplay
                set(fig,'Visible','off')
            end
            
            nPlots = 2;
            nCol = 1;
            
            % set up coords for subplots
            nRow = ceil( nPlots / nCol ) ;
            rowH = 0.58 / nRow ;  colW = 0.7 / nCol ;
            colX = 0.06 + linspace( 0, 0.96, nCol+1 ) ;  colX = colX(1:end-1) ;
            rowY = 0.1 + linspace( 0.9, 0, nRow+1 ) ;  rowY = rowY(2:end) ;
            
            % Build title axes and title.
            axes( 'Position', [0, 0.95, 1, 0.05] ) ;
            set( gca, 'Color', 'None', 'XColor', 'White', 'YColor', 'White' ) ;
            text( 0.5, 0, dbase.title, 'FontSize', 14', 'FontWeight', 'Bold', ...
                'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom',...
                'interpreter','none') ;
            
            
            % compute position for this subplot
            dId = 1;
            rowId = ceil( dId / nCol ) ;
            colId = dId - (rowId - 1) * nCol ;
            axes( 'Position', [0.13 0.35 0.7750 0.6] ) ;
            
            %         hf = figure('units','normalized','outerposition',[0 0 1 1]);
            %         if ~bDisplay
            %         set(hf,'Visible','off')
            %         end
            %
            %         opengl software
            %
            %         %subplot.
            %         s2 = subplot('Position', [0.13 0.35 0.7750 0.55]);
            %         %                 set(gca, 'Visible', 'Off')
            
            set(gca, 'LineWidth', 2)
            set(gca, 'Box', 'On')
            lineheight=1;
            for i=1:length(eventOnsetsHit)
                spks=eventOnsetsHit{1,i};
                if ~isempty(spks);
                    
                    for j=1:length(spks)
                        line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 2)
                    end
                    
                end
                
            end
            hr = patch([0 fdbkdur fdbkdur 0],...
                [0 0 length(eventOnsetsHit) length(eventOnsetsHit)], [1 1 0], 'EdgeColor', 'none');
            set(hr, 'FaceAlpha', 0.5)
            
            
            yline = length(eventOnsetsHit);
            line([dataStart dataStop], [yline, yline], 'color', 'k', 'LineWidth', 2)
            for i=1:length(eventOnsetsEscape)
                spks=eventOnsetsEscape{1,i};
                if ~isempty(spks);
                    for j=1:length(spks)
                        line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k', 'LineWidth', 2);
                    end
                end
            end
            %         % mark target onset at undistorted
            %         line([0 0],[length(eventOnsetsHit) length(eventOnsetsAll)], 'Color', 'b', 'LineWidth', 2)
            
            xlim([-.5 .5])
            set(gca, 'YTick', length(eventOnsetsAll))
            set(gca, 'XTickLabel', [])
            ylim([0 length(eventOnsetsAll)])
            set(gca, 'FontSize', fsz)
            ylabel('Hits Escapes', 'FontSize', fsz)
            
            % compute position for this subplot
            dId = 2;
            rowId = ceil( dId / nCol ) ;
            colId = dId - (rowId - 1) * nCol ;
            axes( 'Position', [0.13 0.225 0.7750 0.09] ) ;
            
            %         % subplot for histogram
            %         subplot('Position', [0.13 0.2 0.7750 0.09])
            hold on
            %         line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
            hp1 = stairs(edges, rdhitsmooth, 'r', 'LineWidth', 2);
            hp2 = stairs(edges, rdescapesmooth, 'b', 'LineWidth', 2);
            ylm = get(gca, 'YLim');
            line([0 0], [ylm(1) ylm(2)], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
            xlim([-0.5 0.5])
            ylabel('Rate', 'FontSize', fsz)
            set(gca, 'LineWidth', 2)
            set(gca,'xtick',[])
            set(gca,'xticklabel',[])
            %         ylim([80 200])%mean(1./dbase.boutISI) + std(1./dbase.boutISI)])
            
            subplot('Position', [0.13 0.1 0.7750 0.09])
            hold on
            line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
            stairs(edges, errorzscore, 'k', 'LineWidth', 2)
            
            for i=1:length(Xsigon)
                line([Xsigon(i) Xsigoff(i)], [5.5 5.5], 'Color', 'k', 'LineWidth', 2)
                %         text(Xsigoff(i),5.5,[num2str(Xsigon(i)) ' ' num2str(Xsigoff(i)-Xsigon(i)+winsz)]);
            end
            
        case 2 %hit-escape
            %         errorzscore = zscore(rdhitsmooth-rdescapesmooth);
            %         [Xsigon, Xsigoff] = pp_error_diffAnalysis(dbase,errorzscore,10);
            %
            %         for i=1:length(Xsigon)
            %         line([Xsigon(i)-stepsz/2 Xsigoff(i)-stepsz/2], [5.5 5.5], 'Color', 'k', 'LineWidth', 2)
            %         end
    end
end


hold off
xlim([-.5 .5])
ylim([-6 6])
ylm = get(gca, 'YLim');
line([0 0], [ylm(1) ylm(2)], 'Color', 'k', 'Linewidth',lw, 'LineStyle', ':')
set(gca, 'YTick', [-6 0 6])
% set(gca, 'YTickLabel', {'' '0' '6'})
xlabel('Time relative to song target time (s)', 'FontSize', fsz)
ylabel('z-score', 'FontSize', fsz)
box off

set(gca, 'LineWidth', 2)
% set(gca, 'FontSize', fsz)

fig = gca;


