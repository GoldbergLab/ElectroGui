function [dbase boutISI nonsongISI interboutISI boutspiketimes nonsongspiketimes interboutspiketimes edges boutdist nonsongdist bouttime silenttime interbouttime]=vgm_dbaseBoutNonsongISI(dbase,varargin)

%This function gets ISIs from bouts and silence during bUnusable files.
%It also gets the mean rates (numspikes/total time) for bout, interbout,
%and nonsong

%IMPORTANT, the varargin is the indx you want to analyze (e.g. indx for
%spikes or moveindx for movements

bPlot=0;bPlot2=0;
if isempty(varargin)
    [dbase.boutstarts dbase.boutends dbase.boutspiketimes interboutspiketimes catboutspikes catquietspikes boutISI interboutISI catdiffboutisis catdiffquietisis quiettime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs]=vgm_dbaseSingingISI(dbase);
    %[callstart callend callspiketimes silentspiketimes catcallspikes catsilentspikes catcallisis nonsongISI catdiffcallisis catdiffsilentisis silenttime calltime silentifrs callifrs catcallifrs catsilentifrs catdiffsilentifrs catdiffcallifrs]=dbaseCallingISI(dbase);
    [nonsongISI catcallisis nonsongspiketimes callspiketimes silenttime]=vgm_dbaseSilentCallsISI(dbase);

else
    [dbase.boutstarts dbase.boutends dbase.boutspiketimes interboutspiketimes catboutspikes catquietspikes boutISI interboutISI catdiffboutisis catdiffquietisis interbouttime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs]=vgm_dbaseSingingISI(dbase, varargin{1});
    %[callstart callend callspiketimes silentspiketimes catcallspikes catsilentspikes catcallisis nonsongISI catdiffcallisis catdiffsilentisis silenttime calltime silentifrs callifrs catcallifrs catsilentifrs catdiffsilentifrs catdiffcallifrs]=dbaseCallingISI(dbase);
    [nonsongISI catcallisis nonsongspiketimes callspiketimes silenttime]=vgm_dbaseSilentCallsISI(dbase, varargin{1});
end

if isempty(dbase.unusables)
    nonsongISI=[nonsongISI interboutISI];
    silenttime=[silenttime interbouttime];
    nonsongspiketimes=[nonsongspiketimes interboutspiketimes];
end

%This line below combines all the spikes silence and calls;
%nonsongISI=[nonsongISI catcallisis];
%%%%%%%%%%%%%%%%%%%%%

if bPlot

    %PLOTTING BELOW
    edges=[min([boutISI nonsongISI]):binISI:max([boutISI nonsongISI])];
    %edges=linspace(min([boutISI nonsongISI]),max([boutISI nonsongISI]),50);
    varboutisis=var(boutISI);varnonsongisis=var(nonsongISI);
    boutdist=histc(boutISI,edges);boutdist=boutdist/sum(boutdist);
    nonsongdist=histc(nonsongISI,edges);nonsongdist=nonsongdist/sum(nonsongdist);

    figure; plot(edges,smooth(boutdist,s)); hold on; plot(edges, smooth(nonsongdist,s), 'k');
    xlabel('Interspike interval (s)');ylabel('Probability Density'); xlim([-.001,xmax]);title('Distribution of Interspike intervals')

    %For ISI distribution
    edges=[min([boutISI nonsongISI]):binISI:max([boutISI nonsongISI])];
    %edges=linspace(min([boutISI nonsongISI]),max([boutISI nonsongISI]),50);
    varboutisis=var(boutISI);varnonsongisis=var(nonsongISI);
    boutdist=histc(boutISI,edges);boutdist=boutdist/sum(boutdist);
    nonsongdist=histc(nonsongISI,edges);nonsongdist=nonsongdist/sum(nonsongdist);

    figure; plot(edges,smooth(boutdist)); hold on; plot(edges, smooth(nonsongdist), 'k');
    xlabel('Interspike interval (s)');ylabel('Probability Density'); xlim([-.001,xmax]);title('Distribution of Interspike intervals')

    %For log-ISI distribution
    %logisiedges=[min([boutISI nonsongISI]):binlogISI:max([boutISI nonsongISI])];
    logisiedges=linspace(min([log10(boutISI) log10(nonsongISI)]),max([log10(boutISI) log10(nonsongISI)]));
    logboutdist=histc(log10(boutISI),logisiedges);logboutdist=logboutdist/sum(logboutdist);
    lognonsongdist=histc(log10(nonsongISI),logisiedges);lognonsongdist=lognonsongdist/sum(lognonsongdist);

    figure;plot(logisiedges, smooth(logboutdist,s)); hold on; plot(logisiedges,smooth(lognonsongdist,s), 'k');
    xlabel('Log Interspike interval (s)');ylabel('Probability Density'); xlim(loglim);title([dbase.title ': Distribution of Log Interspike intervals'])

    %%Plot log log ISI distributions
    figure;plot(logisiedges,log10(logboutdist));hold on; plot(logisiedges,log10(lognonsongdist),'k');
    xlabel('log Interspike interval (s)');ylabel('log Probability Density');
    title('Log-log ISI distributions');xlim([-3,-1]);

    %Plot log-linear
    figure;plot(edges,log10(boutdist));hold on; plot(edges,log10(nonsongdist),'k');
    xlabel('Interspike interval (s)');ylabel('log Probability Density');
    title('Log-linear ISI distributions');xlim([0,xmax]);
end
%For log-ISI distribution
%logisiedges=[min([boutISI nonsongISI]):binlogISI:max([boutISI nonsongISI])];
logisiedges=linspace(min([log10(boutISI) log10(nonsongISI)]),max([log10(boutISI) log10(nonsongISI)]));
logboutdist=histc(log10(boutISI),logisiedges);logboutdist=logboutdist/sum(logboutdist);
lognonsongdist=histc(log10(nonsongISI),logisiedges);lognonsongdist=lognonsongdist/sum(lognonsongdist);
loginterboutdist=histc(log10(interboutISI),logisiedges);loginterboutdist=loginterboutdist/sum(loginterboutdist);
if bPlot2
    figure;plot(logisiedges, smooth(logboutdist,s)); hold on; plot(logisiedges,smooth(lognonsongdist,s), 'k');

    hold on; plot(logisiedges, smooth(loginterboutdist,s),'r');
    xlabel('Log Interspike interval (s)');ylabel('Probability Density'); xlim(loglim);title([dbase.title ': Distribution of Log Interspike intervals'])
end


dbase.ISI.bout=boutISI;
dbase.ISI.nonsong=nonsongISI;
dbase.ISI.interbout=interboutISI;
dbase.boutISI=boutISI;
dbase.nonsongISI=nonsongISI;
dbase.interboutISI=interboutISI;

boutspiketimes=dbase.boutspiketimes;
% dbase.boutspiketimes = boutspiketimes;
dbase.nonsongspiketimes=nonsongspiketimes;
dbase.interboutspiketimes=interboutspiketimes;

%rates below
dbase.rates.silent=length(concatenate(nonsongspiketimes))/sum(concatenate(silenttime));
dbase.rates.interbout=length(concatenate(interboutspiketimes))/sum(concatenate(interbouttime));
dbase.rates.bout=length(concatenate(boutspiketimes))/sum(concatenate(bouttime));

dbase.rates.all=[length(concatenate(nonsongspiketimes))+length(concatenate(interboutspiketimes))+length(concatenate(boutspiketimes))]/[sum(concatenate(silenttime))+sum(concatenate(interbouttime))+sum(concatenate(bouttime))];


dbase=vg_dbaseGetUnusables(dbase);