function dbase=vg_plotisidist(dbase,smoothfactor);

%this funciton just plots ISI dists really quickly and easily

edges=[0:.0001:.5];
s=smoothfactor;

dist=histc(dbase.boutISI,edges);
figure;plot(edges,smooth(dist/sum(dist),s));
dist=histc(dbase.nonsongISI,edges);
hold on;plot(edges,smooth(dist/sum(dist),s),'r');
title(dbase.title);
xlim([0, prctile([dbase.boutISI dbase.nonsongISI],99)]);