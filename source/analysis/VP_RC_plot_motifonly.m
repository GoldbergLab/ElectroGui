function fig = VP_RC_plot_motifonly(dbase, varargin)

if isempty(varargin);
bDisplay=1;
else
bDisplay=varargin{1};
end

count = 0;
Ncon = 4;
Ncoff = 8;
winsz = 0.03;
stepsz = 0.002;
xlimit = [-.5,.5];
fsz = 20;
lw = 2;

bdirection = 0;
bplot = 0;
bsave = 0;

loaddata = 1;

ord = 80;

count = count+1;

eventOnsetsHit = dbase.trigInfoFhitbin25.events;
eventOnsetsEscape = dbase.trigInfocatchbin25.events;
% eventOnsetsHitpreCC = dbase.trigInfoFhitbin25preCC.events;
% eventOnsetsEscapepreCC = dbase.trigInfocatchbin25preCC.events;
% eventOnsetsHitpostCC = dbase.trigInfoFhitbin25postCC.events;
% eventOnsetsEscapepostCC = dbase.trigInfocatchbin25postCC.events;
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
% eventOnsetsAllpreCC = [eventOnsetsHitpreCC eventOnsetsEscapepreCC];
% eventOnsetsAllpostCC = [eventOnsetsHitpostCC eventOnsetsEscapepostCC];
% eventOnsetsMove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
% eventOnsetsMoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.events;
% eventOnsetsMoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
edges = dbase.trigInfoFhitbin25.edges;
rdhit = dbase.trigInfoFhitbin25.rd;
% rdhitpreCC = dbase.trigInfoFhitbin25preCC.rd;
% rdhitpostCC = dbase.trigInfoFhitbin25postCC.rd;
rdescape = dbase.trigInfocatchbin25.rd;
% rdescapepreCC = dbase.trigInfocatchbin25preCC.rd;
% rdescapepostCC = dbase.trigInfocatchbin25postCC.rd;
% rdmove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rd;
% rdmoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoSylls.rd;
% rdmoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.rd;
rdhitsmooth = dbase.trigInfoFhitbin25.rds;
rdescapesmooth = dbase.trigInfocatchbin25.rds;
% rdmovesmooth = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rds;
% rdmoveNoSyllsmooth = dbase.trigInfoMoveOnsetsSpikesNoSylls.rds;
% rdmoveBoutsmooth = dbase.trigInfoBoutMoveOnsetsSpikes.rds;
dataStart = dbase.trigInfoFhitbin25.edges(1);
dataStop = dbase.trigInfoFhitbin25.edges(end);
pmin = dbase.trigInfoFhitbin25.pval.minrates;
pmin_stats(count) = pmin;
mintime = dbase.trigInfoFhitbin25.corrtime.mins;
pmax = dbase.trigInfocatchbin25.pval.maxrates;
pmax_stats(count) = pmax;
maxtime = dbase.trigInfocatchbin25.corrtime.maxs;
hitmin = min(rdhitsmooth);
escapemax = max(rdescapesmooth);
yrange = escapemax-hitmin;
trigStarts = dbase.trigInfoFhitbin25.trigStarts;
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
        [Xsigon, Xsigoff] = pp_error_diffAnalysis(dbase,errorzscore);
        
        hf = figure('units','normalized','outerposition',[0 0 1 1]);
        if ~bDisplay
        set(hf,'Visible','off')
        end
        
        opengl software

        %subplot.
        s2 = subplot('Position', [0.13 0.35 0.7750 0.55]);
        %                 set(gca, 'Visible', 'Off')

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


        % subplot for histogram
        subplot('Position', [0.13 0.2 0.7750 0.09])
        hold on
        line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
        hp1 = stairs(edges, rdhitsmooth, 'r', 'LineWidth', 2);

        hp2 = stairs(edges, rdescapesmooth, 'b', 'LineWidth', 2);
        xlim([-0.5 0.5])
%         ylim([80 200])%mean(1./dbase.boutISI) + std(1./dbase.boutISI)])

        subplot('Position', [0.13 0.1 0.7750 0.09])
        hold on
        line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
        stairs(edges, errorzscore, 'k', 'LineWidth', 2)
        
        for i=1:length(Xsigon)
        line([Xsigon(i)-stepsz/2 Xsigoff(i)-stepsz/2], [5.5 5.5], 'Color', 'k', 'LineWidth', 2)
        end
        
        case 2 %hit-escape
        errorzscore = zscore(rdhitsmooth-rdescapesmooth);
        [Xsigon, Xsigoff] = pp_error_diffAnalysis(dbase,errorzscore);
        
        for i=1:length(Xsigon)
        line([Xsigon(i)-stepsz/2 Xsigoff(i)-stepsz/2], [5.5 5.5], 'Color', 'k', 'LineWidth', 2)
        end
    end
end


hold off
xlim([-.5 .5])
ylim([-6 6])
ylm = get(gca, 'YLim');
line([0 0], [ylm(1) ylm(2)], 'Color', 'k', 'Linewidth', lw)
set(gca, 'YTick', [-3 0 3 6])
set(gca, 'YTickLabel', {'' '0' '' '6'})
xlabel('Time relative to song target time (s)', 'FontSize', fsz)
ylabel('z-score', 'FontSize', fsz)
box off

set(gca, 'LineWidth', 2)
set(gca, 'FontSize', fsz)

fig = gca;



% 
% 
% 
% 
% 
% 
% HitMat = [];
% for i=1:length(winstart)
%     for k=1:length(eventOnsetsHit)
%         HitMat(k,i) = sum(eventOnsetsHit{k} >= winstart(i) & eventOnsetsHit{k} < winstart(i)+winsz);
%     end
% end
% 
% EscapeMat = [];
% for i=1:length(winstart)
%     for k=1:length(eventOnsetsEscape)
%         EscapeMat(k,i) = sum(eventOnsetsEscape{k} >= winstart(i) & eventOnsetsEscape{k} < winstart(i)+winsz);
%     end
% end
% 
% HitVec = mean(HitMat);
% EscapeVec = mean(EscapeMat);
% DiffVec = EscapeVec-HitVec;
% 
% %             p = [];
% %             H = [];
% %             for i= 1:length(winstart)
% %                 [p(i), H(i)] = ranksum(HitMat(:,i), EscapeMat(:,i));
% %             end
% 
% prior_diff = DiffVec(winstart<-winsz);            
% 
% Mprior_diff = mean(prior_diff);
% sigmaprior_diff = std(prior_diff);
% 
% 
% for i = 1:length(winstart)
%     [H(i), p(i)] = ztest(DiffVec(i), Mprior_diff, sigmaprior_diff, 'alpha', 0.05);
% 
% end 
% 
% 
% 
% %             %directionality requirement
% if bdirection == 1
%     H(HitVec>EscapeVec) = 0;
% end
% 
% Xsig = X(logical(H));
% 
% Hsigon = H;
% for i = 1:Ncon-1
%     Hsigon = Hsigon & [H(i+1:end) zeros(1,i)];
% end
% Hsigon = [0 diff(Hsigon)] > 0;
% Xsigon = X(Hsigon);
% 
% notH = not(H);
% Hsigoff = notH;
% for i = 1:Ncoff-1
%     Hsigoff = Hsigoff & [notH(i+1:end) zeros(1,i)];
% end
% Hsigoff = [0 diff(Hsigoff)] > 0;
% Hsigoff(end) = true;
% Xsigoff = X(Hsigoff);
% 
% Xsigofftemp = [];
% for i = 1:length(Xsigon)
%     Xsigofftemp(i) = Xsigoff(find(Xsigoff - Xsigon(i) > 0, 1, 'first'));
% end
% Xsigoff = Xsigofftemp;
% [Xsigoff, ind] = unique(Xsigoff);
% Xsigon = Xsigon(ind);
% 
% [~, ind_max_errorzscore] = max(errorzscore);
% max_X_diff = edges(ind_max_errorzscore) + 0.0125;
% 
% ind_Xsig_diff = Xsigon < max_X_diff & Xsigoff > max_X_diff;
% Xsigon = Xsigon(ind_Xsig_diff);
% Xsigoff = Xsigoff(ind_Xsig_diff);
% 
% if ~isempty(Xsigon)
%     latency_diff(count) = Xsigon;
%     duration_diff(count) = Xsigoff-Xsigon;
% else
%     latency_diff(count) = NaN;
%     duration_diff(count) = NaN;
% end
% 
% for i = 1:length(trigStarts)
%     [Ymin,ind_min] = min(abs(fdbktimes-trigStarts(i)));
%     tempfdbktimes(i) = fdbktimes(ind_min);
%     tempfdbkstarttimes(i) = tempfdbktimes(i)-trigStarts(i);
%     tempfdbkendtimes(i) = tempfdbkstarttimes(i)+fdbkdur;
% end
% 
% % hit analysis
% prior_hit = HitVec(winstart<-winsz);
% prior_escape = EscapeVec(winstart<-winsz);
% 
% 
% Mprior_hit = mean(prior_hit);
% sigmaprior_hit = std(prior_hit);
% 
% Mprior_escape = mean(prior_escape);
% sigmaprior_escape = std(prior_escape);
% 
% for i = 1:length(winstart)
%     [H_hit(i), p_hit(i)] = ztest(HitVec(i), Mprior_hit, sigmaprior_hit, 'alpha', 0.05);
% 
% end
% 
% %directionality requirement
% if bdirection == 1
%     H_hit(HitVec>Mprior_hit) = 0;
% end
% 
% Xsig_hit = X(logical(H_hit));
% 
% Hsigon_hit = H_hit;
% for i = 1:Ncon-1
%     Hsigon_hit = Hsigon_hit & [H_hit(i+1:end) zeros(1,i)];
% end
% Hsigon_hit = [0 diff(Hsigon_hit)] > 0;
% Xsigon_hit = X(Hsigon_hit);
% 
% notH_hit = not(H_hit);
% Hsigoff_hit = notH_hit;
% for i = 1:Ncoff-1
%     Hsigoff_hit = Hsigoff_hit & [notH_hit(i+1:end) zeros(1,i)];
% end
% Hsigoff_hit = [0 diff(Hsigoff_hit)] > 0;
% Hsigoff_hit(end) = true;
% 
% Xsigoff_hit = X(Hsigoff_hit);
% 
% Xsigofftemp_hit = [];
% for i = 1:length(Xsigon_hit)
%     Xsigofftemp_hit(i) = Xsigoff_hit(find(Xsigoff_hit - Xsigon_hit(i) > 0, 1, 'first'));
% end
% Xsigoff_hit = Xsigofftemp_hit;
% [Xsigoff_hit, ind_hit] = unique(Xsigoff_hit);
% Xsigon_hit = Xsigon_hit(ind_hit);
% 
% if ~isempty(Xsigon_hit)
%     min_X_hit = mintime + 0.0125;
% 
%     ind_Xsig_hit = Xsigon_hit < min_X_hit & Xsigoff_hit > min_X_hit;
%     Xsigon_hit = Xsigon_hit(ind_Xsig_hit);
%     Xsigoff_hit = Xsigoff_hit(ind_Xsig_hit);
% end
% 
% 
% if ~isempty(Xsigon_hit)
%     latency_hit(count) = Xsigon_hit;
%     duration_hit(count) = Xsigoff_hit-Xsigon_hit;
% else
%     latency_hit(count) = NaN;
%     duration_hit(count) = NaN;
% end
% 
% % escape analysis
% for i = 1:length(winstart)
%     [H_escape(i), p_escape(i)] = ztest(EscapeVec(i), Mprior_escape, sigmaprior_escape, 'alpha', 0.05);
% 
% end
% 
% %directionality requirement
% if bdirection == 1
%     H_escape(EscapeVec<Mprior_escape) = 0;
% end
% 
% Xsig_escape = X(logical(H_escape));
% 
% 
% Hsigon_escape = H_escape;
% for i = 1:Ncon-1
%     Hsigon_escape = Hsigon_escape & [H_escape(i+1:end) zeros(1,i)];
% end
% Hsigon_escape = [0 diff(Hsigon_escape)] > 0;
% Xsigon_escape = X(Hsigon_escape);
% 
% notH_escape = not(H_escape);
% Hsigoff_escape = notH_escape;
% for i = 1:Ncoff-1
%     Hsigoff_escape = Hsigoff_escape & [notH_escape(i+1:end) zeros(1,i)];
% end
% Hsigoff_escape = [0 diff(Hsigoff_escape)] > 0;
% Hsigoff_escape(end) = true;
% 
% Xsigoff_escape = X(Hsigoff_escape);
% 
% Xsigofftemp_escape = [];
% for i = 1:length(Xsigon_escape)
%     Xsigofftemp_escape(i) = Xsigoff_escape(find(Xsigoff_escape - Xsigon_escape(i) > 0, 1, 'first'));
% end
% Xsigoff_escape = Xsigofftemp_escape;
% [Xsigoff_escape, ind_escape] = unique(Xsigoff_escape);
% Xsigon_escape = Xsigon_escape(ind_escape);
% 
% if ~isempty(Xsigon_escape)
%     max_X_escape = maxtime + 0.0125;
% 
%     ind_Xsig_escape = Xsigon_escape < max_X_escape & Xsigoff_escape > max_X_escape;
%     Xsigon_escape = Xsigon_escape(ind_Xsig_escape);
%     Xsigoff_escape = Xsigoff_escape(ind_Xsig_escape);
% end
% 
% 
% if ~isempty(Xsigon_escape)
%     latency_escape(count) = Xsigon_escape;
%     duration_escape(count) = Xsigoff_escape-Xsigon_escape;
% else
%     latency_escape(count) = NaN;
%     duration_escape(count) = NaN;
% end
% 
% prior_zscore = errorzscore(edges<0);
% Mprior_zscore = mean(prior_zscore);
% sigmaprior_zscore = std(prior_zscore);
% 
% hf = figure('units','normalized','outerposition',[0 0 1 1]);
% if ~bDisplay
%     set(hf,'Visible','off')
% end
% 
% opengl software
% 
% %subplot.
% s2 = subplot('Position', [0.13 0.35 0.7750 0.55]);
% %                 set(gca, 'Visible', 'Off')
% 
% set(gca, 'LineWidth', 2)
% set(gca, 'Box', 'On')
% lineheight=1;
% for i=1:length(eventOnsetsHit)
%     spks=eventOnsetsHit{1,i};
%     if ~isempty(spks);
% 
%         for j=1:length(spks)
%             line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 2)
%         end
% 
%     end
% %                                         hr = patch([tempfdbkstarttimes(i) tempfdbkendtimes(i) tempfdbkendtimes(i) tempfdbkstarttimes(i)],...
% %                                             [i-1 i-1 i i], 'r', 'EdgeColor', 'none');
% %                                         set(hr, 'FaceAlpha', 0.5)
% end
% hr = patch([0 fdbkdur fdbkdur 0],...
%      [0 0 length(eventOnsetsHit) length(eventOnsetsHit)], [1 0.4488 0.4488], 'EdgeColor', 'none');
%      set(hr, 'FaceAlpha', 0.5)
% 
% 
% yline = length(eventOnsetsHit);
% line([dataStart dataStop], [yline, yline], 'color', 'k', 'LineWidth', 2)
% for i=1:length(eventOnsetsEscape)
%     spks=eventOnsetsEscape{1,i};
%     if ~isempty(spks);
%         for j=1:length(spks)
%             line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k', 'LineWidth', 2);
%         end
%     end
% end
% line([0 0],[length(eventOnsetsHit) length(eventOnsetsAll)], 'Color', 'b', 'LineWidth', 2)
% 
% xlim(xlimit)
% set(gca, 'YTick', length(eventOnsetsAll))
% set(gca, 'XTickLabel', [])
% ylim([0 length(eventOnsetsAll)])
% set(gca, 'FontSize', fsz)
% ylabel('Hits Escapes', 'FontSize', fsz)
% 
% 
% % subplot for histogram
% subplot('Position', [0.13 0.2 0.7750 0.09])
% hold on
% line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
% hp1 = stairs(edges, rdhitsmooth, 'r', 'LineWidth', 2);
% 
% hp2 = stairs(edges, rdescapesmooth, 'b', 'LineWidth', 2);
% xlim(xlimit)
% 
% subplot('Position', [0.13 0.1 0.7750 0.09])
% hold on
% line([-1 1], [0 0], 'Color', 'k', 'Linewidth', lw, 'LineStyle', ':')
% stairs(edges, errorzscore, 'k', 'LineWidth', 2)
% 
% for i=1:length(Xsigon)
%     line([Xsigon(i)-stepsz/2 Xsigoff(i)-stepsz/2], [5.5 5.5], 'Color', 'k', 'LineWidth', 2)
% end
% %                 plot(X,H_hit, 'r')
% %                 plot(X,H_escape, 'b')
% hold off
% xlim(xlimit)
% ylim([-6 6])
% ylm = get(gca, 'YLim');
% line([0 0], [ylm(1) ylm(2)], 'Color', 'k', 'Linewidth', lw)
% set(gca, 'YTick', [-3 0 3 6])
% set(gca, 'YTickLabel', {'' '0' '' '6'})
% xlabel('Time relative to song target time (s)', 'FontSize', fsz)
% ylabel('z-score', 'FontSize', fsz)
% box off
% 
% set(gca, 'LineWidth', 2)
% set(gca, 'FontSize', fsz)
% 
% fig = gca;


