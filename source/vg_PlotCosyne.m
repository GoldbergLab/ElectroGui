clear

fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';

count = 0;
for y = 1%1:length(fold)
    contents=dir(fold{y});
    for i=3:8%[3:39 41:50]%:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            
            count = count+1;
            load([fold{y} contents(i).name]);
%             ratebout(count) = dbase.rates.bout;
%             ratesilent(count) = dbase.rates.silent;
%             CV_boutISI(count) = std(dbase.boutISI)/mean(dbase.boutISI);
%             CV_nonsongISI(count) = std(dbase.nonsongISI)/mean(dbase.nonsongISI);
%             peakFRbout(count) = 1/prctile(dbase.boutISI,1);
%             peakFRnonsong(count) = 1/prctile(dbase.nonsongISI,1);
%             IFRautocorrHWbout(count) = dbase.ifrautocorr.bout.halfwidth;
%             IFRautocorrHWnonsong(count) = dbase.ifrautocorr.nonsong.halfwidth;
            stacbout(count,:) = dbase.spiketrainautocorr.nlbout30ms;
            stacnonsong(count,:) = dbase.spiketrainautocorr.nlnonsong30;
            stacedges(count,:) = dbase.spiketrainautocorr.edges30ms;
            
            h(count) = figure(count);
            plot(stacedges(count,:), stacnonsong(count,:), 'b')
            hold on
            plot(stacedges(count,:), stacbout(count,:), 'r')
            hold off
            title(dbase.title, 'Interpreter', 'None')
            
        end
    end
end


% h(i-2) = figure(i-2);
% plot(stacedges(i,:), stacnonsong(i,:), 'b')
% hold on
% plot(stacedges(i,:), stacbout(i,:), 'r')
% hold off
% title(dbase.title, 'Interpreter', 'None')

%%
for i = [1:37 39:48]
    print(h(i), '-djpeg', ['N' num2str(i)])
end



















%%
% This makes a figure: rate song vs. rate non song

clear

fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';

count = 0;
for y = 1:length(fold)
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            
            count = count+1;
            load([fold{y} contents(i).name]);
            ratebout(count) = dbase.rates.bout;
            ratesilent(count) = dbase.rates.silent;
            CV_boutISI(count) = std(dbase.boutISI)/mean(dbase.boutISI);
            CV_nonsongISI(count) = std(dbase.nonsongISI)/mean(dbase.nonsongISI);
            peakFRbout(count) = 1/prctile(dbase.boutISI,1);
            peakFRnonsong(count) = 1/prctile(dbase.nonsongISI,1);
%             IFRautocorrHWbout(count) = dbase.ifrautocorr.bout.halfwidth;
%             IFRautocorrHWnonsong(count) = dbase.ifrautocorr.nonsong.halfwidth;
            
        end
    end
end
%%
for i = 1:48
    N{i} = num2str(i);
end
figure()
plot(ratesilent(1:7), ratebout(1:7), 'or', 'MarkerSize', 10)
text(ratesilent(1:7), ratebout(1:7), {'1' '2' '3' '4' '5' '6' '7'}, 'FontSize', 6, 'Color', 'r')
hold on
plot(ratesilent(8:end), ratebout(8:end), 'ob', 'MarkerSize', 10)
text(ratesilent(8:end), ratebout(8:end), N', 'FontSize', 6)
hold off
xlabel('Rate Silent (Hz)')
ylabel('Rate Bout (Hz)')
% xlim([0 150])
% ylim([0 150])
figure()
plot(CV_nonsongISI(1:7), CV_boutISI(1:7), 'or', 'MarkerSize', 10)
text(CV_nonsongISI(1:7), CV_boutISI(1:7), {'1' '2' '3' '4' '5' '6' '7'}, 'FontSize', 6, 'Color', 'r')
hold on
plot(CV_nonsongISI(8:end), CV_boutISI(8:end), 'ob', 'MarkerSize', 10)
text(CV_nonsongISI(8:end), CV_boutISI(8:end), N', 'FontSize', 6)
hold off
xlabel('CV nonsongISI (Hz)')
ylabel('CV boutISI (Hz)')

figure()
plot(peakFRnonsong(1:7), peakFRbout(1:7), 'or', 'MarkerSize', 10)
text(peakFRnonsong(1:7), peakFRbout(1:7), {'1' '2' '3' '4' '5' '6' '7'}, 'FontSize', 6, 'Color', 'r')
hold on
plot(peakFRnonsong(8:end), peakFRbout(8:end), 'ob', 'MarkerSize', 10)
text(peakFRnonsong(8:end), peakFRbout(8:end), N', 'FontSize', 6)
hold off
xlabel('peakFRnonsong (Hz)')
ylabel('peakFRbout (Hz)')

figure()
plot(IFRautocorrHWnonsong(1:7), IFRautocorrHWbout(1:7), 'or', 'MarkerSize', 10)
text(IFRautocorrHWnonsong(1:7), IFRautocorrHWbout(1:7), {'1' '2' '3' '4' '5' '6' '7'}, 'FontSize', 6, 'Color', 'r')
hold on
plot(IFRautocorrHWnonsong(8:end), IFRautocorrHWbout(8:end), 'ob', 'MarkerSize', 10)
text(IFRautocorrHWnonsong(8:end), IFRautocorrHWbout(8:end), N', 'FontSize', 6)
hold off
xlabel('IFRautocorrHWnonsong (Hz)')
ylabel('IFRautocorrHWbout (Hz)')
%%


% This makes a figure: movement response vs. feedback response

clear

fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';

count = 0;
for y = 1:length(fold)
    contents=dir(fold{y});
    for i=3:length(contents);
        i-2
        if strcmp(contents(i).name(end),'t');
            
            count = count+1;
            load([fold{y} contents(i).name]);
            baselineFRnonsong = dbase.rates.silent;
            trigInfoM = dbase.trigInfoMoveonsetsNoSonSoffStfdonfdoff;
            edgesM = trigInfoM.edges;
            rdM = trigInfoM.rds;
%             figure()
%             plot(edgesM, rdM)
            muM = mean(rdM(edgesM <= 0));
            sigmaM = std(rdM(edgesM <= -0.1));
            moddepthM = trigInfoM.moddepth;
%             zM(count) = moddepthM/sigmaM/baselineFRnonsong;
%             zM(count) = moddepthM/sigmaM;
            zM(count) = moddepthM;
            baselineFR = dbase.rates.bout;
            fdbklatency = median(dbase.fdbklatencies);
            trigInfoFe = dbase.trigInfomotif;
            trigInfoFh = dbase.trigInfofdbkmotif;
            edges = trigInfoFe{1}.warped.edges;
            rdFe = trigInfoFe{1}.warped.rds;
            rdFh = trigInfoFh{1}.warped.rds;
            n = min(length(rdFe), length(rdFh));
            
            rddiff = rdFe(1:n)-rdFh(1:n);
            
            mu = mean(rddiff(edges <= 0));
            sigma = std(rddiff(edges <= 0));
            x = max(rddiff(edges >= fdbklatency & edges < fdbklatency + 0.150));
%             zF(count) = (x-baselineFR)/sigma;
%             zF(count) = x/baselineFR;
%             zF(count) = x;
%             zF(count) = x/sigma;
            z = zscore(rddiff);
            zF(count) = max(z);
            intZ(count) = trapz(edges(1:n), z(1:n));
%             figure();
%             plot(edges(1:n), z(1:n))
%             title(dbase.title);ylim([-4 4]);
            %             trigInfo = dbase.trigInfomotif;
%             edges = trigInfo{1}.warped.edges;
%             rd = trigInfo{1}.warped.rds;
% %             figure()
% %             plot(edges, rd)
%             mu = mean(rd(edges <= 0));
%             sigma = std(rd(edges <= 0));
%             x = max(abs(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu));
%             if abs(max(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu)) <= ...
%                     abs(min(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu))
%                 x = -x;
%             end
%             zFe = x/sigma;
% 
%             trigInfo = dbase.trigInfofdbkmotif;
%             edges = trigInfo{1}.warped.edges;
%             rd = trigInfo{1}.warped.rds;
% %             figure()
% %             plot(edges, rd)
%             mu = mean(rd(edges <= 0));
%             sigma = std(rd(edges <= 0));
%             x = max(abs(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu));
%             if abs(max(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu)) <= ...
%                     abs(min(rd(edges >= fdbklatency & edges < fdbklatency + 0.150) - mu))
%                 x = -x;
%             end
%             zFh = x/sigma;
%             
%             zF(count) = zFe-zFh;
            
            
            
        end
    end
end
%%
for i = 1:48
    N{i} = num2str(i);
end
figure()
plot(zM(1:7), zF(1:7), 'or', 'MarkerSize', 10)
text(zM(1:7), zF(1:7), {'1' '2' '3' '4' '5' '6' '7'}, 'FontSize', 6, 'Color', 'r')
hold on
plot(zM(8:end), zF(8:end), 'ob', 'MarkerSize', 10)
text(zM(8:end), zF(8:end), N, 'FontSize', 6)
hold off
xlabel('Movement')
ylabel('Feedback')





















%%
% This makes a figure: movement response vs. feedback response

clear
fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
count = 0;
for y = 1:length(fold)
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            
            count = count+1;
            load([fold{y} contents(i).name]);
            trigInfoM = dbase.trigInfoMoveonsetsNoSonSoffStfdonfdoff;
            pmaxM(count) = trigInfoM.pval.maxrate;
            pminM(count) = trigInfoM.pval.minrate;
            moddepthM(count) = trigInfoM.moddepth;
            trigInfoF = dbase.trigInfofdbkoffsets;
            pmaxF(count) = trigInfoF.pval.maxrate;
            pminF(count) = trigInfoF.pval.minrate;
            moddepthF(count) = trigInfoF.moddepth;
            ctimemaxF(count) = trigInfoF.corrtime.max;
            ctimeminF(count) = trigInfoF.corrtime.min;
            c = concatenate(trigInfoF.events);
            DeltaHitRateNorm(count) = (sum(c >= 0 & c <= 0.1)/length(trigInfoF.events)/0.1-dbase.rates.bout)/dbase.rates.bout;
            rd(count, :) = trigInfoF.rd;
        end
    end
end
%%


for i = 1:length(moddepthM)
    
%     if (pmaxF(i) < 0.05 && ctimemaxF(i) >= 0 && ctimemaxF(i) <= 0.1)...
%             || (pminF(i) < 0.05 && ctimeminF(i) >= 0 && ctimeminF(i) <= 0.1)
%         F(i) = DeltaHitRateNorm(i);
%     else
%         F(i) = 0;
%     end
    
    mu = mean(rd(i,1:30));
    sigma = std(rd(i,1:30));
    F(i) = mean((rd(i,31:41)-mu)/sigma); 
%     z = (rd(i,:)-mean(rd(i,:)))/std(rd(i,:));
%     F(i) = mean(z(31:41));
    
    
    if pmaxM(i) < 0.05 || pminM(i) < 0.05
        M(i) = moddepthM(i);
        
    else
        M(i) = 0;
        
    end
end
%%
figure(1)
plot(F,M, 'ok')
% xlim([-1.2 1.2])
ylim([-1 6])
xlabel('Feedback Response (Normalized Change in Firing Rate)')
ylabel('Movement Response ()')



%%
clear
fold='L:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
% fold='G:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
contents=dir(fold);
count = 0;
% HitRateNormAll = [];
% EscapeRateNormAll = [];
for i=[4 6 7 10 12 14 16]%3:length(contents);
    if strcmp(contents(i).name(end),'t');
        
        count = count+1;
        load([fold contents(i).name]);
        %         HitRateNormAll = [HitRateNormAll (dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2))/dbase.rates.bout];
        %         EscapeRateNormAll = [EscapeRateNormAll (dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2))/dbase.rates.bout];
        HitRateNormMean(count) = (mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2))/dbase.rates.bout;
        HitRateNormSe(count) = std(dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        EscapeRateNormMean(count) = (mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2))/dbase.rates.bout;
        EscapeRateNormSe(count) = std(dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=16
            ZRateNormMean(count) = (mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2))/dbase.rates.silent;
            ZRateNormSe(count) = std(dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)/dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
        DeltaHitRateNormMean(count) = (mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout;
        DeltaHitRateNormSe(count) = std((dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        DeltaEscapeRateNormMean(count) = (mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout;
        DeltaEscapeRateNormSe(count) = std((dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=16
            DeltaZRateNormMean(count) = (mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2)-dbase.rates.silent)/dbase.rates.silent;
            DeltaZRateNormSe(count) = std((dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)-dbase.rates.silent)/dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
        DeltaHitRateMean(count) = mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2)-dbase.rates.bout;
        DeltaHitRateSe(count) = std(dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)-dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        DeltaEscapeRateMean(count) = mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2)-dbase.rates.bout;
        DeltaEscapeRateSe(count) = std(dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)-dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=16
            DeltaZRateMean(count) = mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2)-dbase.rates.silent;
            DeltaZRateSe(count) = std(dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)-dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
    end
end

xHit = [1.1 0.9 1.1 0.9 1.1 1 1];
xEscape = [2.9 2.9 3.1 3 3 3.1 3];
xZ = [5.1 5.0 4.9 5.1 5.0 4.9];
fsz = 16;
figure(1)
hp = errorbar(xHit,HitRateNormMean,HitRateNormSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, EscapeRateNormMean,EscapeRateNormSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, ZRateNormMean,ZRateNormSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [1 1]);

set(hl, 'LineStyle', '--', 'Color', 'k')

XLine1 = [xHit; xEscape];
YLine1 = [HitRateNormMean; EscapeRateNormMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape(1:end-1); xZ];
YLine2 = [EscapeRateNormMean(1:end-1); ZRateNormMean];
line(XLine2, YLine2, 'Color', 'k')


hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-0.2 3.5])
set(gca, 'YTick', 0:0.5:3.5)
set(gca, 'YTickLabel', {'0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0', '3.5'})
ylabel('Normalized Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

HitRateNormAllMean = mean(HitRateNormMean);
HitRateNormAllSe = std(HitRateNormMean)/sqrt(length(HitRateNormMean));
EscapeRateNormAllMean = mean(EscapeRateNormMean);
EscapeRateNormAllSe = std(EscapeRateNormMean)/sqrt(length(EscapeRateNormMean));
ZRateNormAllMean = mean(ZRateNormMean);
ZRateNormAllSe = std(ZRateNormMean)/sqrt(length(ZRateNormMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;
figure(2)
hp1 = errorbar(xHitAll, HitRateNormAllMean, HitRateNormAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, EscapeRateNormAllMean, EscapeRateNormAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, ZRateNormAllMean, ZRateNormAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [1 1]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-0.2 3])
set(gca, 'YTick', 0:0.5:3)
set(gca, 'YTickLabel', {'0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0'})
ylabel('Normalized Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

figure(3)
hp = errorbar(xHit,DeltaHitRateNormMean,DeltaHitRateNormSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, DeltaEscapeRateNormMean,DeltaEscapeRateNormSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, DeltaZRateNormMean,DeltaZRateNormSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
XLine1 = [xHit; xEscape];
YLine1 = [DeltaHitRateNormMean; DeltaEscapeRateNormMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape(1:end-1); xZ];
YLine2 = [DeltaEscapeRateNormMean(1:end-1); DeltaZRateNormMean];
line(XLine2, YLine2, 'Color', 'k')





hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-1.2 2.7])
set(gca, 'YTick', -1:0.5:2.5)
set(gca, 'YTickLabel', {'-1.0', '-0.5', '0', '0.5', '1.0', '1.5', '2.0', '2.5'})
ylabel('Normalized Change in Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)


DeltaHitRateNormAllMean = mean(DeltaHitRateNormMean);
DeltaHitRateNormAllSe = std(DeltaHitRateNormMean)/sqrt(length(DeltaHitRateNormMean));
DeltaEscapeRateNormAllMean = mean(DeltaEscapeRateNormMean);
DeltaEscapeRateNormAllSe = std(DeltaEscapeRateNormMean)/sqrt(length(DeltaEscapeRateNormMean));
DeltaZRateNormAllMean = mean(DeltaZRateNormMean);
DeltaZRateNormAllSe = std(DeltaZRateNormMean)/sqrt(length(DeltaZRateNormMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;

figure(4)
hp1 = errorbar(xHitAll, DeltaHitRateNormAllMean, DeltaHitRateNormAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, DeltaEscapeRateNormAllMean, DeltaEscapeRateNormAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, DeltaZRateNormAllMean, DeltaZRateNormAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-1.2 1.2])
set(gca, 'YTick', -1:0.5:2)
set(gca, 'YTickLabel', {'-1.0', '-0.5', '0', '0.5', '1.0'})
ylabel('Normalized Change in Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

figure(5)
hp = errorbar(xHit,DeltaHitRateMean,DeltaHitRateSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, DeltaEscapeRateMean,DeltaEscapeRateSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, DeltaZRateMean,DeltaZRateSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')

XLine1 = [xHit; xEscape];
YLine1 = [DeltaHitRateMean; DeltaEscapeRateMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape(1:end-1); xZ];
YLine2 = [DeltaEscapeRateMean(1:end-1); DeltaZRateMean];
line(XLine2, YLine2, 'Color', 'k')



hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-40 40])
set(gca, 'YTick', -40:20:40)
set(gca, 'YTickLabel', {'-40', '-20', '0', '20', '40'})
ylabel('Change in Firing Rate (Hz)', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

DeltaHitRateAllMean = mean(DeltaHitRateMean);
DeltaHitRateAllSe = std(DeltaHitRateMean)/sqrt(length(DeltaHitRateMean));
DeltaEscapeRateAllMean = mean(DeltaEscapeRateMean);
DeltaEscapeRateAllSe = std(DeltaEscapeRateMean)/sqrt(length(DeltaEscapeRateMean));
DeltaZRateAllMean = mean(DeltaZRateMean);
DeltaZRateAllSe = std(DeltaZRateMean)/sqrt(length(DeltaZRateMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;
figure(6)
hp1 = errorbar(xHitAll, DeltaHitRateAllMean, DeltaHitRateAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, DeltaEscapeRateAllMean, DeltaEscapeRateAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, DeltaZRateAllMean, DeltaZRateAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-25 25])
set(gca, 'YTick', -20:10:20)
set(gca, 'YTickLabel', {'-20', '-10', '0', '10', '20'})
ylabel('Change in Firing Rate (Hz)', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

%%
close all
clear
% select the dbase file to load
file = 'dbase050214_3Chan2_ForAnalysis.mat';
% file = 'dbase092114_1chan5_ForAnalysis.mat';
% file = 'dbase100714_3chan7_ForAnalysis.mat';
% file = 'dbase102014_1chan2_ForAnalysis.mat';
% file = 'dbase102614_1chan2_ForAnalysis.mat';
% file = 'dbase102714_1chan6_ForAnalysis.mat';
% file = 'dbase102814_1chan2_ForAnalysis.mat';
load(file)

fdbkdur = 0.05;
edges = dbase.trigInfomotif{1}.warped.edges;
edgesfdbk = dbase.trigInfofdbkmotif{1}.warped.edges;
edgesZ = dbase.trigInfofdbkmotif{2}.warped.edges;
rd = dbase.trigInfomotif{1}.warped.rd;
rdfdbk = dbase.trigInfofdbkmotif{1}.warped.rd;
rdZ = dbase.trigInfofdbkmotif{2}.warped.rd;
warp = dbase.trigInfofdbkmotif{1}.warped.warp;

rdsmooth = smooth(rd, 3);
rdfdbksmooth = smooth(rdfdbk, 3);
rdZsmooth = smooth(rdZ, 3);

% rddiff = rdsmooth-rdfdbksmooth;

dataStart = dbase.trigInfomotif{1}.warped.dataStart{1};
dataStop = dbase.trigInfomotif{1}.warped.dataStop{1};
dataStartZ = dbase.trigInfofdbkmotif{2}.warped.dataStart{1};
dataStopZ = dbase.trigInfofdbkmotif{2}.warped.dataStop{1};



eventOnsetsEscape = dbase.trigInfomotif{1}.warped.eventOnsets{1};
eventOnsetsHit = dbase.trigInfofdbkmotif{1}.warped.eventOnsets{1};
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
eventOnsetsZ = dbase.trigInfofdbkmotif{2}.warped.eventOnsets{1};

fdbktimes = concatenate(dbase.fdbktimes);

motifstarts = dbase.trigInfomotif{1}.warped.motifstarts;
motifends = dbase.trigInfomotif{1}.warped.motifends;
fdbkmotifstarts = dbase.trigInfofdbkmotif{1}.warped.motifstarts;
fdbkmotifends = dbase.trigInfofdbkmotif{1}.warped.motifends;
Zmotifstarts = dbase.trigInfofdbkmotif{2}.warped.motifstarts;
Zmotifends = dbase.trigInfofdbkmotif{2}.warped.motifends;

for i = 1:length(fdbkmotifstarts)
    tempfdbktimes(i) = fdbktimes(fdbktimes>fdbkmotifstarts(i) & fdbktimes<fdbkmotifends(i));
    tempfdbkstarttimes(i) = tempfdbktimes(i)-fdbkmotifstarts(i);
    tempfdbkendtimes(i) = tempfdbkstarttimes(i)+fdbkdur;
    tempfdbkstarttimes(i) = tempfdbkstarttimes(i)*warp(i);
    tempfdbkendtimes(i) = tempfdbkendtimes(i)*warp(i);
end
searchWin = 0.015;
for i = 1:length(Zmotifstarts)
    tempZtimes(i) = fdbktimes(fdbktimes>Zmotifstarts(i)-searchWin & fdbktimes<Zmotifends(i)+searchWin);
    tempZtimes(i) = tempZtimes(i)-Zmotifstarts(i);
end


% FIGURE 7
fsz = 10;
hf = figure(7);
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





% SUBPLOT(2,2,3)
subplot(2,2,3)

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
hl = legend(LegendHit, LegendEscape, 'Location', 'NW');

set(hl, 'FontSize', 6)





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
hg = gtext(file, 'Rotation', [90], 'Interpreter', 'None');


%% testing for movement figure
% close all
clear
fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
fold{2}='F:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';

count = 0;
for y = 1:length(fold)
    contents=dir(fold{y});
    for k=3:length(contents);
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
            
            
            
            
        end
    end
end
%% FOR COSYNE TALK
close all
clear
% select the dbase file to load
file = 'dbase050214_3Chan2_ForAnalysis.mat';
% file = 'dbase092114_1chan5_ForAnalysis.mat';
% file = 'dbase100714_3chan7_ForAnalysis.mat';
% file = 'dbase102014_1chan2_ForAnalysis.mat';
% file = 'dbase102614_1chan2_ForAnalysis.mat';
% file = 'dbase102714_1chan6_ForAnalysis.mat';
% file = 'dbase102814_1chan2_ForAnalysis.mat';
load(file)

fdbkdur = 0.05;
edges = dbase.trigInfomotif{1}.warped.edges;
edgesfdbk = dbase.trigInfofdbkmotif{1}.warped.edges;
edgesZ = dbase.trigInfofdbkmotif{2}.warped.edges;
rd = dbase.trigInfomotif{1}.warped.rd;
rdfdbk = dbase.trigInfofdbkmotif{1}.warped.rd;
rdZ = dbase.trigInfofdbkmotif{2}.warped.rd;
warp = dbase.trigInfofdbkmotif{1}.warped.warp;

rdsmooth = smooth(rd, 3);
rdfdbksmooth = smooth(rdfdbk, 3);
rdZsmooth = smooth(rdZ, 3);

% rddiff = rdsmooth-rdfdbksmooth;

dataStart = dbase.trigInfomotif{1}.warped.dataStart{1};
dataStop = dbase.trigInfomotif{1}.warped.dataStop{1};
dataStartZ = dbase.trigInfofdbkmotif{2}.warped.dataStart{1};
dataStopZ = dbase.trigInfofdbkmotif{2}.warped.dataStop{1};



eventOnsetsEscape = dbase.trigInfomotif{1}.warped.eventOnsets{1};
eventOnsetsHit = dbase.trigInfofdbkmotif{1}.warped.eventOnsets{1};
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
eventOnsetsZ = dbase.trigInfofdbkmotif{2}.warped.eventOnsets{1};

fdbktimes = concatenate(dbase.fdbktimes);

motifstarts = dbase.trigInfomotif{1}.warped.motifstarts;
motifends = dbase.trigInfomotif{1}.warped.motifends;
fdbkmotifstarts = dbase.trigInfofdbkmotif{1}.warped.motifstarts;
fdbkmotifends = dbase.trigInfofdbkmotif{1}.warped.motifends;
Zmotifstarts = dbase.trigInfofdbkmotif{2}.warped.motifstarts;
Zmotifends = dbase.trigInfofdbkmotif{2}.warped.motifends;

for i = 1:length(fdbkmotifstarts)
    tempfdbktimes(i) = fdbktimes(fdbktimes>fdbkmotifstarts(i) & fdbktimes<fdbkmotifends(i));
    tempfdbkstarttimes(i) = tempfdbktimes(i)-fdbkmotifstarts(i);
    tempfdbkendtimes(i) = tempfdbkstarttimes(i)+fdbkdur;
    tempfdbkstarttimes(i) = tempfdbkstarttimes(i)*warp(i);
    tempfdbkendtimes(i) = tempfdbkendtimes(i)*warp(i);
end
searchWin = 0.015;
for i = 1:length(Zmotifstarts)
    tempZtimes(i) = fdbktimes(fdbktimes>Zmotifstarts(i)-searchWin & fdbktimes<Zmotifends(i)+searchWin);
    tempZtimes(i) = tempZtimes(i)-Zmotifstarts(i);
end


% FIGURE 7
fsz = 10;
hf = figure(7);
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
            line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k', 'LineWidth', 2)
        end
        
    end
end
yline = length(eventOnsetsHit);
line([dataStart dataStop], [yline, yline], 'color', 'k')
for i=1:length(eventOnsetsEscape)
    spks=eventOnsetsEscape{1,i};
    if ~isempty(spks);
        for j=1:length(spks)
            line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k', 'LineWidth', 2);
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





% SUBPLOT(2,2,3)
subplot(2,2,3)

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
% LegendHit = ['Hit ' 'p_{min} ' LpHitMin ', p_{max} ' LpHitMax];
LegendHit = 'Hit ';
% LegendEscape = ['Escape ' 'p_{min} ' LpEscapeMin ', p_{max} ' LpEscapeMax];
LegendEscape = 'Escape ';
hl = legend(LegendHit, LegendEscape, 'Location', 'NW');

set(hl, 'FontSize', 6)





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
hg = gtext(file, 'Rotation', [90], 'Interpreter', 'None');

%% FOR COSYNE TALK
clear
fold='H:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
% fold='G:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
contents=dir(fold);
count = 0;
% HitRateNormAll = [];
% EscapeRateNormAll = [];
for i=3:length(contents);
    if strcmp(contents(i).name(end),'t');
        
        count = count+1;
        load([fold contents(i).name]);
        %         HitRateNormAll = [HitRateNormAll (dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2))/dbase.rates.bout];
        %         EscapeRateNormAll = [EscapeRateNormAll (dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2))/dbase.rates.bout];
        HitRateNormMean(count) = (mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2))/dbase.rates.bout;
        HitRateNormSe(count) = std(dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        EscapeRateNormMean(count) = (mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2))/dbase.rates.bout;
        EscapeRateNormSe(count) = std(dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=9
            if i>9
                countsp = count-1;
            else
                countsp = count;
            end
            ZRateNormMean(countsp) = (mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2))/dbase.rates.silent;
            ZRateNormSe(countsp) = std(dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)/dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
        DeltaHitRateNormMean(count) = (mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout;
        DeltaHitRateNormSe(count) = std((dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        DeltaEscapeRateNormMean(count) = (mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout;
        DeltaEscapeRateNormSe(count) = std((dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)-dbase.rates.bout)/dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=9
             if i>9
                countsp = count-1;
            else
                countsp = count;
            end
            DeltaZRateNormMean(countsp) = (mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2)-dbase.rates.silent)/dbase.rates.silent;
            DeltaZRateNormSe(countsp) = std((dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)-dbase.rates.silent)/dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
        DeltaHitRateMean(count) = mean(dbase.historyanalysis.hitnum)/dbase.historyanalysis.window(2)-dbase.rates.bout;
        DeltaHitRateSe(count) = std(dbase.historyanalysis.hitnum/dbase.historyanalysis.window(2)-dbase.rates.bout)/sqrt(length(dbase.historyanalysis.hitnum));
        DeltaEscapeRateMean(count) = mean(dbase.historyanalysis.escapenum)/dbase.historyanalysis.window(2)-dbase.rates.bout;
        DeltaEscapeRateSe(count) = std(dbase.historyanalysis.escapenum/dbase.historyanalysis.window(2)-dbase.rates.bout)/sqrt(length(dbase.historyanalysis.escapenum));
        if i~=9
             if i>9
                countsp = count-1;
            else
                countsp = count;
            end
            DeltaZRateMean(countsp) = mean(dbase.historyanalysis.Znum)/dbase.historyanalysis.window(2)-dbase.rates.silent;
            DeltaZRateSe(countsp) = std(dbase.historyanalysis.Znum/dbase.historyanalysis.window(2)-dbase.rates.silent)/sqrt(length(dbase.historyanalysis.Znum));
        end
    end
end
disp('hello')
xHit = [1.1 0.9 1.1 0.9 1.1 1 1 1];
xEscape = [2.9 2.9 3.1 3 3 3.1 3 3.1];
xZ = [5.1 5.0 4.9 5.1 5.0 4.9 5.1];
fsz = 16;
figure(1)
hp = errorbar(xHit,HitRateNormMean,HitRateNormSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, EscapeRateNormMean,EscapeRateNormSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, ZRateNormMean,ZRateNormSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [1 1]);

set(hl, 'LineStyle', '--', 'Color', 'k')

XLine1 = [xHit; xEscape];
YLine1 = [HitRateNormMean; EscapeRateNormMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape([1:end-2 end]); xZ];
YLine2 = [EscapeRateNormMean([1:end-2 end]); ZRateNormMean];
line(XLine2, YLine2, 'Color', 'k')


hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-0.2 3.5])
set(gca, 'YTick', 0:0.5:3.5)
set(gca, 'YTickLabel', {'0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0', '3.5'})
ylabel('Normalized Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)
%%
HitRateNormAllMean = mean(HitRateNormMean);
HitRateNormAllSe = std(HitRateNormMean)/sqrt(length(HitRateNormMean));
EscapeRateNormAllMean = mean(EscapeRateNormMean);
EscapeRateNormAllSe = std(EscapeRateNormMean)/sqrt(length(EscapeRateNormMean));
ZRateNormAllMean = mean(ZRateNormMean);
ZRateNormAllSe = std(ZRateNormMean)/sqrt(length(ZRateNormMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;
figure(2)
hp1 = errorbar(xHitAll, HitRateNormAllMean, HitRateNormAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, EscapeRateNormAllMean, EscapeRateNormAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, ZRateNormAllMean, ZRateNormAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [1 1]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-0.2 3])
set(gca, 'YTick', 0:0.5:3)
set(gca, 'YTickLabel', {'0', '0.5', '1.0', '1.5', '2.0', '2.5', '3.0'})
ylabel('Normalized Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

figure(3)
hp = errorbar(xHit,DeltaHitRateNormMean,DeltaHitRateNormSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, DeltaEscapeRateNormMean,DeltaEscapeRateNormSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, DeltaZRateNormMean,DeltaZRateNormSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
XLine1 = [xHit; xEscape];
YLine1 = [DeltaHitRateNormMean; DeltaEscapeRateNormMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape(1:end-1); xZ];
YLine2 = [DeltaEscapeRateNormMean(1:end-1); DeltaZRateNormMean];
line(XLine2, YLine2, 'Color', 'k')





hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-1.2 2.7])
set(gca, 'YTick', -1:0.5:2.5)
set(gca, 'YTickLabel', {'-1.0', '-0.5', '0', '0.5', '1.0', '1.5', '2.0', '2.5'})
ylabel('Normalized Change in Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)


DeltaHitRateNormAllMean = mean(DeltaHitRateNormMean);
DeltaHitRateNormAllSe = std(DeltaHitRateNormMean)/sqrt(length(DeltaHitRateNormMean));
DeltaEscapeRateNormAllMean = mean(DeltaEscapeRateNormMean);
DeltaEscapeRateNormAllSe = std(DeltaEscapeRateNormMean)/sqrt(length(DeltaEscapeRateNormMean));
DeltaZRateNormAllMean = mean(DeltaZRateNormMean);
DeltaZRateNormAllSe = std(DeltaZRateNormMean)/sqrt(length(DeltaZRateNormMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;

figure(4)
hp1 = errorbar(xHitAll, DeltaHitRateNormAllMean, DeltaHitRateNormAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, DeltaEscapeRateNormAllMean, DeltaEscapeRateNormAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, DeltaZRateNormAllMean, DeltaZRateNormAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-1.2 1.2])
set(gca, 'YTick', -1:0.5:2)
set(gca, 'YTickLabel', {'-1.0', '-0.5', '0', '0.5', '1.0'})
ylabel('Normalized Change in Firing Rate', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

figure(5)
hp = errorbar(xHit,DeltaHitRateMean,DeltaHitRateSe, 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 5);
hold on
errorbar(xEscape, DeltaEscapeRateMean,DeltaEscapeRateSe, 'ob', 'MarkerFaceColor', 'b', 'MarkerSize', 5)
errorbar(xZ, DeltaZRateMean,DeltaZRateSe, 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')

XLine1 = [xHit; xEscape];
YLine1 = [DeltaHitRateMean; DeltaEscapeRateMean];
line(XLine1, YLine1, 'Color', 'k')
XLine2 = [xEscape(1:end-1); xZ];
YLine2 = [DeltaEscapeRateMean(1:end-1); DeltaZRateMean];
line(XLine2, YLine2, 'Color', 'k')



hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-40 40])
set(gca, 'YTick', -40:20:40)
set(gca, 'YTickLabel', {'-40', '-20', '0', '20', '40'})
ylabel('Change in Firing Rate (Hz)', 'FontSize', fsz)
set(gca, 'FontSize', fsz)

DeltaHitRateAllMean = mean(DeltaHitRateMean);
DeltaHitRateAllSe = std(DeltaHitRateMean)/sqrt(length(DeltaHitRateMean));
DeltaEscapeRateAllMean = mean(DeltaEscapeRateMean);
DeltaEscapeRateAllSe = std(DeltaEscapeRateMean)/sqrt(length(DeltaEscapeRateMean));
DeltaZRateAllMean = mean(DeltaZRateMean);
DeltaZRateAllSe = std(DeltaZRateMean)/sqrt(length(DeltaZRateMean));
xHitAll = 1;
xEscapeAll = 3;
xZAll = 5;
figure(6)
hp1 = errorbar(xHitAll, DeltaHitRateAllMean, DeltaHitRateAllSe, 'or');
set(hp1, 'MarkerFaceColor', 'r', 'MarkerSize', 5)
hold on
hp2 = errorbar(xEscapeAll, DeltaEscapeRateAllMean, DeltaEscapeRateAllSe, 'ob');
set(hp2, 'MarkerFaceColor', 'b', 'MarkerSize', 5)
hp3 = errorbar(xZAll, DeltaZRateAllMean, DeltaZRateAllSe, 'ok');
set(hp3, 'MarkerFaceColor', 'k', 'MarkerSize', 5)
hl = line([0 6], [0 0]);
set(hl, 'LineStyle', '--', 'Color', 'k')
hold off
xlim([0 6])
set(gca, 'XTick', [1 3 5])
set(gca, 'XTickLabel', {'Hit', 'Escape', 'Z'})
% xlabel('Condition', 'FontSize', fsz)
ylim([-25 25])
set(gca, 'YTick', -20:10:20)
set(gca, 'YTickLabel', {'-20', '-10', '0', '10', '20'})
ylabel('Change in Firing Rate (Hz)', 'FontSize', fsz)
set(gca, 'FontSize', fsz)
