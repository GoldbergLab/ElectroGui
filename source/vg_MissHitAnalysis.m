close all
clear
s = 3;
file = 'dbase092114_1chan5_ForAnalysis.mat';
% file = 'dbase102714_1chan6_ForAnalysis.mat';
% file = 'dbase050214_3Chan2_ForAnalysis.mat';

load(file)
DataStart = 0.5;
DataStop = 0.5;
BinSize = 0.025;
delay = 0.05;
allsyllnames = dbase.allsyllnames;
syllstarttimes = concatenate(dbase.syllstarttimes);
syllendtimes = concatenate(dbase.syllendtimes);
fdbktimes = concatenate(dbase.fdbktimes);
spiketimes = concatenate(dbase.spiketimes);
countMH = 0;
countME = 0;
for i = 1:length(allsyllnames)
    
    if allsyllnames(i) == 'L'
        countMH = countMH+1;
        MissHitStartTime(countMH) = fdbktimes(fdbktimes > syllstarttimes(i) & fdbktimes < syllendtimes(i));
        latency(countMH) = syllstarttimes(i)-MissHitStartTime(countMH);
        for j = i+1:length(allsyllnames)
            if allsyllnames(j) == 'l'
                countME = countME+1 ;
                MissEscapeStartTime(countME) = syllstarttimes(j)+latency(countMH);
                break
            end
        end
    end
end

edges = -DataStart:BinSize:DataStop;
edges = edges(1:end-1);
rdmat = [];
for i = 1:length(MissHitStartTime)
    tempspiketimes = spiketimes(spiketimes > MissHitStartTime(i)-DataStart & spiketimes < MissHitStartTime(i)+DataStop);
    tempspiketimes = tempspiketimes-MissHitStartTime(i);
    eventOnsetsMissHits{i} = tempspiketimes;
    temprd=histc(eventOnsetsMissHits{i},edges);
    rdmat=[rdmat;temprd];
end
rd=mean(rdmat)/BinSize;%gives rate histogram
rd=rd(1:end-1);
rdMissHit = rd;
rdmatMissHit = rdmat;
rdMissHitSmooth = smooth(rd, s);

rdmat = [];
for i = 1:length(MissEscapeStartTime)
    tempspiketimes = spiketimes(spiketimes > MissEscapeStartTime(i)-DataStart & spiketimes < MissEscapeStartTime(i)+DataStop);
    tempspiketimes = tempspiketimes-MissEscapeStartTime(i);
    eventOnsetsMissEscapes{i} = tempspiketimes;
    temprd=histc(eventOnsetsMissEscapes{i},edges);
    rdmat=[rdmat;temprd];
end
rd=mean(rdmat)/BinSize;%gives rate histogram
rd=rd(1:end-1);
rdMissEscape = rd;
rdMissEscapeSmooth = smooth(rd, s);
rdmatMissEscape = rdmat;

eventOnsetsAll = [eventOnsetsMissHits eventOnsetsMissEscapes];



fsz = 12;

figure(1)
subplot(2,1,1)
hold on
lineheight=1;
for i=1:length(eventOnsetsMissHits)
    spks=eventOnsetsMissHits{1,i};
    if ~isempty(spks);
        hr = rectangle('Position', [0 i-1 delay 1], 'FaceColor', 'r', 'EdgeColor', 'r');
        for j=1:length(spks)
            line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k')
        end
        
    end
end
yline = length(eventOnsetsMissHits);
line([-DataStart DataStop], [yline, yline], 'color', 'k')

lineheight=1;
for i=1:length(eventOnsetsMissEscapes)
    spks=eventOnsetsMissEscapes{1,i};
    if ~isempty(spks);
%         hr = rectangle('Position', [0 i-1 delay 1], 'FaceColor', 'r', 'EdgeColor', 'r');
        for j=1:length(spks)
%             line([spks(j)',spks(j)'],[i-1,i-1+lineheight],'color','k')
            line([spks(j)',spks(j)'],[yline+i-1,yline+i-1+lineheight],'color','k');
        end
        
    end
end
hold off
title('Calls')
xlim([-DataStart DataStop])
ylim([0 length(eventOnsetsAll)])
set(gca, 'FontSize', fsz)
set(gca, 'XTickLabel', [])
set(gca, 'YTickLabel', [])
ylabel('Mishits  Next Escapes')



winsz = 0.1;
stepsz = 0.005;

winstart = -DataStart:stepsz:DataStop-winsz;
X = winstart+winsz/2;
for i=1:length(winstart)
    for j=1:length(eventOnsetsMissHits)
        MissHitMat(j,i) = sum(eventOnsetsMissHits{j} >= winstart(i) & eventOnsetsMissHits{j} < winstart(i)+winsz);
    end
end

for i=1:length(winstart)
    for j=1:length(eventOnsetsMissEscapes)
        MissEscapeMat(j,i) = sum(eventOnsetsMissEscapes{j} >= winstart(i) & eventOnsetsMissEscapes{j} < winstart(i)+winsz);
    end
end

for i= 1:length(winstart)
    [p(i), H(i)] = ranksum(MissHitMat(:,i), MissEscapeMat(:,i));
end
Hshift = [H(2:end) 0];
Hsig = and(H, Hshift);
Xsig = X(Hsig);



subplot(2,1,2)
hold on
stairs(edges(1:end-1), rdMissHitSmooth, 'r', 'LineWidth', 2.0)






stairs(edges(1:end-1), rdMissEscapeSmooth, 'b', 'LineWidth', 2.0)

YLim = get(gca, 'YLim');

YLimU = 10*ceil(1.2*max([rdMissHitSmooth; rdMissEscapeSmooth])/10);
for i=1:length(Xsig)
    rectangle('Position', [Xsig(i)-stepsz/2 0.9*YLimU 2*stepsz 0.01*(YLimU-YLim(1))], 'FaceColor', 'k', 'EdgeColor', 'k')
end

hold off
xlim([-DataStart DataStop])
ylim([YLim(1) YLimU])
set(gca, 'FontSize', fsz)
xlabel('Time relative to feedback onset (s)', 'FontSize', fsz)
ylabel('Firing Rate (Hz)', 'FontSize', fsz)


trigInfoMissHit.edges = edges;
trigInfoMissHit.rd = rdMissHit;
trigInfoMissHit.eventOnsets{1} = eventOnsetsMissHits;
trigInfoMissHit=vgm_MonteCarlo_t(trigInfoMissHit);

trigInfoMissEscape.edges = edges;
trigInfoMissEscape.rd = rdMissEscape;
trigInfoMissEscape.eventOnsets{1} = eventOnsetsMissEscapes;
trigInfoMissEscape=vgm_MonteCarlo_t(trigInfoMissEscape);

pHitMin = trigInfoMissHit.pval.minrate;
pHitMax = trigInfoMissHit.pval.maxrate;
pEscapeMin = trigInfoMissEscape.pval.minrate;
pEscapeMax = trigInfoMissEscape.pval.maxrate;

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

hg = gtext(file, 'Rotation', [90], 'Interpreter', 'None');


