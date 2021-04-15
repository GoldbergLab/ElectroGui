function dbase=vg_plotimidist(dbase,smoothfactor);

%this funciton just plots ISI dists really quickly and easily
s=smoothfactor;
edges=[0:.001:.3];


dist=histc(dbase.IMI.bout,edges);
figure;plot(edges,smooth(dist/sum(dist),s));
dist=histc(dbase.IMI.nonsong,edges);
hold on;plot(edges,smooth(dist/sum(dist),s),'r');
title(dbase.title);
xlim([0, prctile([dbase.boutISI dbase.nonsongISI],99)]);