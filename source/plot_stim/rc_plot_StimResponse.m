function [fig,latency,duration,normchange] = rc_plot_StimResponse(dbase,binsize,bDisplay,varargin)
    
    dbase = rc_dbaseMakeStimRasters(dbase,binsize);
    spikelinewidth=1;
    tf = dbase.trigInfoStimBurstSpikes;
    if ~isfield(tf,'events') % no burst detected. use single stims instead
        tf = dbase.trigInfoStimSpikes;
    end
    eventOnsets = tf.events;
    nrows = length(eventOnsets);
    fsz = 14;
    fig = figure;
    if ~bDisplay
        set(fig,'Visible','off')
    end
    %subplot
    s1 = subplot('Position', [0.13 0.4 0.7750 0.5]);
    set(s1, 'LineWidth', 1)
    set(s1, 'Box', 'On')
    set(s1,'XTick',[]);
    set(s1,'YTick',[1,nrows]);
    lineheight=1;
    for i=1:length(eventOnsets)
        spks=eventOnsets{1,i};
        if ~isempty(spks)
            for j=1:length(spks)
                line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', spikelinewidth)
            end

        end
    end
    yline = nrows;
%                 line([dataStart dataStop], [yline, yline], 'color', 'k', 'LineWidth', 1)
    line([0,0],[1,yline]);
    ylim([1,nrows])
    xlim([-1 1])
%     set(gca, 'YTick', length(eventOnsets))
%     set(gca, 'XTickLabel', [])
%     ylim([0 length(eventOnsets)])
    set(gca, 'FontSize', fsz)
    
    %subplot
    stepsz = 0.005;
    s1 = subplot('Position', [0.13 0.1 0.7750 0.2]);
    rd = tf.rd;
    edges = tf.edges;
    baseline = mean(rd(edges<0));
    [Xsigon,Xsigoff] = rc_phasic_ztest(tf,rd,edges);
%     [Xsigon,Xsigoff] = rc_phasic_wrstest(tf,rd,edges);
    %Xsigon=[];
    if ~isempty(Xsigon)
        Xsigon(Xsigon<0) = 0.015;
        latency = Xsigon(1);
        newrates = getNewRate(tf, Xsigon(1),Xsigoff(1));
        newrate = mean(newrates);
        normchange = newrate/baseline-1;
        duration = Xsigoff(1)-Xsigon(1);
    else
        latency = nan;
        duration = nan;
        normchange = nan;
    end
    binsize = 0.01;
    dbase = rc_dbaseMakeStimRasters(dbase,binsize);
    spikelinewidth=1;
    tf = dbase.trigInfoStimBurstSpikes;    
    rd = tf.rd;
    edges = tf.edges;
    rds = smooth(rd,3);
    hp1 = stairs(edges, rds, 'k', 'LineWidth', 1);
    set(gca, 'LineWidth', 1)
    if ~isempty(varargin)
        ymax = varargin{1};
    elseif max(rds)<2
        ymax = 3;
    else
        ymax = ceil(max(rds)*1.3/10)*10;
    end
    ylim([0,ymax]);
    yline = ymax*0.9;
    for i=1:length(Xsigon)
        line([Xsigon(i)-stepsz/2 Xsigoff(i)-stepsz/2], [yline yline], 'Color', 'k', 'LineWidth', 1)
    end
    xlim([-1 1]);
    set(gca, 'YTick', [0 ymax]);
    set(gca, 'LineWidth', 1)
    set(gca, 'FontSize', fsz)
    set(gca,'Box','Off');
end

function rates = getNewRate(tf,s,e)
    events = tf.events;
    n = length(events);
    count = zeros(n,1);
    for i = 1:n
        count(i) = sum(events{i}>s & events{i}<e);
    end
    rates = count/(e-s);
end