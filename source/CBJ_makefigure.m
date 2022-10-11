%undirected
load('Z:\FieldL_16ch_ephys\Analyzeddbase\dbase0680_chan8_FIR_11_2_2021_cbj_NOBOS_undir.mat');
[fig, UD_undistortedspikes, UD_distortedspikes, UD_histo_undist, UD_histo_dist, UD_histo_edges, fdbkdur, dataStart, dataStop] = cj_rc_plot_target_raster_histogram(dbase, 1);

%directed
load('Z:\FieldL_16ch_ephys\Analyzeddbase\dbase0680_chan8_FIR_11_2_2021_cbj_NOBOS_directed.mat');
[fig, D_undistortedspikes, D_distortedspikes, D_histo_undist, D_histo_dist, D_histo_edges, fdbkdur, dataStart, dataStop] = cj_rc_plot_target_raster_histogram(dbase, 1);



xlimit = [-.3,.3];
fsz = 20;
lw = 2;

opengl software

%%%%%%%%%%%%%% plotting both distorted cases ( Undir and Dir) on top of each other
figure;
%subplot.
s2 = subplot('Position', [0.13 0.35 0.7750 0.55]);
set(gca, 'LineWidth', 2)
set(gca, 'Box', 'On')
lineheight=1;
for i=1:length(UD_distortedspikes)
    spks=UD_distortedspikes{1,i};
    if ~isempty(spks);

        for j=1:length(spks)
            line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 2)
        end

    end
end

hr = patch([0 fdbkdur fdbkdur 0],[0 0 length(UD_distortedspikes) length(UD_distortedspikes)], [1 1 0], 'EdgeColor', 'none');
set(hr, 'FaceAlpha', 0.5)
yline = length(UD_distortedspikes);

line([dataStart dataStop], [yline, yline], 'color', 'k', 'LineWidth', 2)
for i=1:length(D_distortedspikes)
    spks=D_distortedspikes{1,i};
    if ~isempty(spks);
        for j=1:length(spks)
            line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k', 'LineWidth', 2);
        end
    end
end
% line([0 0],[length(D_distortedspikes) length(D_distortedspikes)], 'Color', 'b', 'LineWidth', 2)

hr = patch([0 fdbkdur fdbkdur 0],[0 0 (length(D_distortedspikes)+length(UD_distortedspikes)) (length(D_distortedspikes)+length(UD_distortedspikes))], [1 1 0], 'EdgeColor', 'none');
set(hr, 'FaceAlpha', 0.5)
hold on
line([0 0],[0 (length(D_distortedspikes)+length(UD_distortedspikes))], 'Color', 'b', 'LineWidth', 2)

xlim(xlimit)
set(gca, 'YTick', (length(D_distortedspikes)+length(UD_distortedspikes)))
set(gca, 'XTickLabel', [])
ylim([0 (length(D_distortedspikes)+length(UD_distortedspikes))])
set(gca, 'FontSize', 24)
ylabel('Motif Renditions', 'FontSize', 32)
set(gca,'TickLength',[ 0 0 ])



% subplot for histogram
subplot('Position', [0.13 0.1 0.7750 0.18])
hold on
line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
hp1 = stairs(UD_histo_edges, UD_histo_dist, 'k', 'LineWidth', 2);
hp2 = stairs(UD_histo_edges, D_histo_dist, 'g', 'LineWidth', 2);
line([0 0],[0 200], 'Color', 'k', 'LineWidth', 2)
xlim(xlimit)
xlabel('Time rel. to target syllable (s)','FontSize',28);
set(gca,'FontSize',24,'TickLength',[0 3])
set(gca, 'XTick', [-.2 0 .2])
set(gca, 'XTickLabel',[-.2 0 .2])
ylim([0,150]);
ylabel('Rate(Hz)','FontSize', 28)
ax.FontSize = 0;

%%%%%%%%%%%%%%%%%%%%%%%%% plotting both undistorted on top of each other

figure;
%subplot.
s2 = subplot('Position', [0.13 0.35 0.7750 0.55]);
set(gca, 'LineWidth', 2)
set(gca, 'Box', 'On')
lineheight=1;
for i=1:length(UD_undistortedspikes)
    spks=UD_undistortedspikes{1,i};
    if ~isempty(spks);

        for j=1:length(spks)
            line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 2)
        end

    end
end

yline = length(UD_undistortedspikes);

line([dataStart dataStop], [yline, yline], 'color', 'k', 'LineWidth', 2)
for i=1:length(D_undistortedspikes)
    spks=D_undistortedspikes{1,i};
    if ~isempty(spks);
        for j=1:length(spks)
            line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k', 'LineWidth', 2);
        end
    end
end
line([0 0],[0 (length(D_undistortedspikes)+length(UD_undistortedspikes))], 'Color', 'b', 'LineWidth', 2)


xlim(xlimit)
set(gca, 'YTick', (length(D_undistortedspikes)+length(UD_undistortedspikes)))
set(gca, 'XTickLabel', [])
ylim([0 (length(D_undistortedspikes)+length(UD_undistortedspikes))])
set(gca, 'FontSize', 24)
ylabel('Motif Renditions', 'FontSize', 32)
set(gca,'TickLength',[ 0 0 ])

% subplot for histogram
subplot('Position', [0.13 0.1 0.7750 0.18])
hold on
line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
hp1 = stairs(UD_histo_edges, UD_histo_undist, 'k', 'LineWidth', 2);
hp2 = stairs(UD_histo_edges, D_histo_undist, 'g', 'LineWidth', 2);
line([0 0],[0 200], 'Color', 'k', 'LineWidth', 2)
xlim(xlimit)
xlabel('Time rel. to target syllable (s)','FontSize',28);
set(gca,'FontSize',24,'TickLength',[0 3])
set(gca, 'XTick', [-.2 0 .2])
set(gca, 'XTickLabel',[-.2 0 .2])
ylim([0,150]);
ylabel('Rate(Hz)','FontSize', 28)
ax.FontSize = 0;
