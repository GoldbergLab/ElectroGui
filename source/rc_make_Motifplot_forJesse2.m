function fig = rc_make_Motifplot_forJesse(dbase,varargin)

if isempty(varargin);
bDisplay=1;
else
bDisplay=varargin{1};
end

%% create figure

fig = figure('units','normalized','outerposition',[0 0 1 1]);
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


%% Motif aligned rasters

% get motif
trigInfo = dbase.trigInfomotif.notwarped{1};
trigInfoFdbk = dbase.trigInfofdbkmotif.notwarped{1};
motifname = trigInfo.motif;
% motifDur = trigInfo.warpedDur;
totalDur = 0.9; % this is total xlength of the plot
eventOnsets = trigInfo.eventOnsets{1,1};
fdbkOnsets = trigInfo.fdbkOnsets{1,1};

% trigOffsets = trigInfo.currTrigOffset;
% [sortedOffsets, indexByDur] = sort(trigOffsets);
nMotifs = length(eventOnsets);

% if nMotifs>1000
%     randomKeep = sort(randsample(nMotifs,100));
%     nMotifs = 100;
% %     indexByDur = indexByDur(randomKeep);
%     eventOnsets = eventOnsets(randomKeep);
% %     fdbkOnsets = fdbkOnsets(randomKeep);
%     trigOffsets = trigOffsets(randomKeep);
% %     sortedOffsets = sortedOffsets(randomKeep);
% end

% compute position for this subplot
dId = 1;
rowId = ceil( dId / nCol ) ;
colId = dId - (rowId - 1) * nCol ;
axes( 'Position', [0.13 0.41 0.7750 0.49] ) ;

% make subplot with ticks
fdbkdur = 0.05;
lineheight = 1;
for iMotif=1:nMotifs
%     iSyllSorted = indexByDur(iMotif);
    spks = eventOnsets{1,iMotif};
    fdbks = fdbkOnsets{1,iMotif};
    if ~isempty(spks)
        for j=1:length(spks)
            line([spks(j)',spks(j)'],[iMotif-1,iMotif-1+lineheight],'color','k', 'LineWidth', 2)
        end
    end
    % fdbks
%     if ~isempty(fdbks)
%         for iFdbk = 1:length(fdbks)
%             hr = patch([fdbks(iFdbk) fdbks(iFdbk)+fdbkdur fdbks(iFdbk)+fdbkdur fdbks(iFdbk)],...
%                 [iMotif-1 iMotif-1 iMotif-1+lineheight iMotif-1+lineheight], [1 1 0], 'EdgeColor', 'none');
%             set(hr, 'FaceAlpha', 0.5)
%         end
%     end
    % onset and offset lines
%     line([trigOffsets(iMotif),trigOffsets(iMotif)],[iMotif-1,iMotif-1+lineheight],'color','r', 'LineWidth', 1)
%     line([0,0],[iMotif-1,iMotif-1+lineheight],'color','g', 'LineWidth', 1)    
end
xmin = -0.038;
xmax = totalDur-0.038;
xlim([xmin,xmax]);
ylim([0,nMotifs]);
set(gca,'TickLength',[ 0 0 ])
% set(gca, 'YTickLabel', [])

xlabel('time (s)');
ylabel('motif number'); 
title(['motif ' motifname ' onset aligned rasters']);

% Histogram 
smoothWin = 3;
rdsmooth = smooth(trigInfo.rd, smoothWin);
edges = trigInfo.edges;
edgesfdbk = trigInfoFdbk.edges;
rdsmoothFdbk = smooth(trigInfoFdbk.rd,smoothWin);

% compute position for this subplot
dId = 2;
rowId = ceil( dId / nCol ) ;
colId = dId - (rowId - 1) * nCol ;
axes( 'Position', [0.13 0.1 0.7750 0.2] ) ;

% plot histogram with stairs
if ~isempty(rdsmooth)
    hp1 = stairs(edges, rdsmooth, 'b', 'LineWidth', 2); hold on;
    hp2 = stairs(edgesfdbk, rdsmoothFdbk, 'r',  'LineWidth', 2);
    xlim([xmin,xmax]);
    ylim([0,150]);
end
set(gca,'TickLength',[ 0 0 ])
% line([0,0],[0,60],'color','k');line([motifDur,motifDur],[0,60],'color','k');
xlabel('time (s)');
ylabel('rate (Hz)'); 
title(['motif ' motifname ' onset aligned rate histogram']);