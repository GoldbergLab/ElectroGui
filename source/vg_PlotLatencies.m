% close all
clear
% select the dbase file to load
file = 'dbase050214_3Chan2_ForAnalysis.mat';
% file = 'dbase092114_1chan5_ForAnalysis.mat';
% file = 'dbase100714_3chan7_ForAnalysis.mat';
% file = 'dbase102014_1chan2_ForAnalysis.mat';
% file = 'dbase102614_1chan2_ForAnalysis.mat';
% file = 'dbase102714_1chan6_ForAnalysis.mat';
% file = 'dbase102814_1chan2_ForAnalysis.mat';
% file = 'edbase020515_1chan4_ForAnalysis.mat';
load(file)

fdbkdur = 0.05;
edges = dbase.trigInfomotif{1}.warped.edges;
edgesfdbk = dbase.trigInfofdbkmotif{1}.warped.edges;
% edgesZ = dbase.trigInfofdbkmotif{2}.warped.edges;
rd = dbase.trigInfomotif{1}.warped.rd;
rdfdbk = dbase.trigInfofdbkmotif{1}.warped.rd;
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
% 


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
% for i = 1:length(Zmotifstarts)
%     tempZtimes(i) = fdbktimes(fdbktimes>Zmotifstarts(i)-searchWin & fdbktimes<Zmotifends(i)+searchWin);
%     tempZtimes(i) = tempZtimes(i)-Zmotifstarts(i);
% end

fdbkstartimemedian = median(tempfdbkstarttimes);

fdbkmedianedge = sum(edges<fdbkstartimemedian); 

rd = rdsmooth;

prior = rd(edges<fdbkstartimemedian);
priorfdbk = rdfdbk(edgesfdbk<fdbkstartimemedian);

Mprior = mean(prior);
sigmaprior = std(prior);

Mpriorfdbk = mean(priorfdbk);
sigmapriorfdbk = std(priorfdbk);

for i = 1:length(rd)
    [H(i), p(i)] = ztest(rd(i), Mprior, sigmaprior, 'alpha', 0.005);
    if rd(i) < Mprior
        H(i) = 0;
    end
end
Htemp = H;
H(1:fdbkmedianedge-1)=0;
FirstSigEdge = find(H==1, 1);


for i = 1:length(rdfdbk)
    [Hfdbk(i), pfdbk(i)] = ztest(rdfdbk(i), Mpriorfdbk, sigmapriorfdbk, 'alpha', 0.05);
    if rdfdbk(i) > Mpriorfdbk
        Hfdbk(i) = 0;
    end
end
Hfdbktemp = Hfdbk;
Hfdbk(1:fdbkmedianedge-1)=0;
FirstSigEdgefdbk = find(Hfdbk==1, 1);





binsize = 0.010;

% latency = 0.025*(FirstSigEdge-fdbkmedianedge);
latency = binsize*(FirstSigEdge-fdbkmedianedge);
latencyfdbk = binsize*(FirstSigEdgefdbk-fdbkmedianedge);

figure



r = rectangle('Position', [edges(fdbkmedianedge) 0 0.050 1]);
set(r, 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0])
hold on
p1 = plot(edges,Htemp, '.-');
set(p1, 'MarkerSize', 3)

hold off
title(['Latency = ' num2str(latency*1000) ' ms'])



figure

r = rectangle('Position', [edges(fdbkmedianedge) 0 0.050 1]);
set(r, 'FaceColor', [1 0 0], 'EdgeColor', [1 0 0])
hold on
p1 = plot(edgesfdbk,Hfdbktemp, '.-');
set(p1, 'MarkerSize', 3)

hold off
title(['Latency_fdbk = ' num2str(latencyfdbk*1000) ' ms'])











