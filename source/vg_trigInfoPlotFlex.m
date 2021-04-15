function trigInfo=vg_trigInfoPlotFlex(trigInfo,bplotraster,bdmn,bsmooth, varargin)

if bsmooth, s=3;else s=1;end%smooth
if mean(trigInfo.rd)<10;lw=5;else;lw=1;end%linewidth in raster


if isempty(varargin);
xl=[-.2, .2];
else
    xl=[-varargin{1},varargin{1}];
end


cy='k';%color of plot and raster
figure;
edges=trigInfo.edges;
if bplotraster;subplot(2,1,1);end
if bdmn;xplot=trigInfo.rdmn;else;xplot=trigInfo.rd;end

plot(trigInfo.edges,smooth(xplot,s),cy,'LineWidth',lw);xlim([xl(1),xl(2)]);

if bplotraster
     lineheight=length(trigInfo.events)/100;
%      lineheight=1;
    for i=1:length(trigInfo.events)
        spks=trigInfo.events{i};
        if ~isempty(spks);
            for j=1:length(spks)
                subplot(2,1,2);hold on; line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color',cy,'LineWidth',lw);
            end
        end
    end
    hold on; subplot(2,1,2);line([0,0],[0,i],'color','k');
    %sylldur=median(trigInfo.currTrigOffset);

    hold on;subplot(2,1,2);ylim([0,i]);xlim([xl(1),xl(2)]);

    hold on;subplot(2,1,1);set(gca, 'xtick',[xl(1):.1:xl(2)]);
    hold on;subplot(2,1,2);set(gca, 'xtick',[xl(1):.1:xl(2)]);
end