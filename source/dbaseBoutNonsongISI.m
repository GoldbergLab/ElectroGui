function [boutISI nonsongISI boutspiketimes nonsongspiketimes interboutspiketimes interboutISI edges boutdist nonsongdist bouttime silenttime interbouttime]=dbaseBoutNonsongISI(dbase, bPlot, bTerm, bIncludeInterBoutISI, varargin);

%This function gets ISIs from bouts and silence during Unusable files.
%If bPlot=1, it will plot ISI dists for each.
%If bTerm=1; it will assume edges and xlims for terms; else for dlm nrns.
%If bIncludeInterBoutISI=1, then the 'nonsong' stats will also have
%interbout silence

s=9;%smooth factor for ISI plot
edges=[];boutdist=[];nonsongdist=[];
if ~bTerm
    xmax=.05; binISI=.0001; binlogISI=.25;loglim=[-3,0];
else
    xmax=.025; binISI=.00005; binlogISI=.05;loglim=[-3,0];%binlogISI was .1
end
if isempty(varargin)
    [boutstart boutend boutspiketimes interboutspiketimes catboutspikes catquietspikes boutISI interboutISI catdiffboutisis catdiffquietisis quiettime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs]=dbaseSingingISI(dbase);
    %[callstart callend callspiketimes silentspiketimes catcallspikes catsilentspikes catcallisis nonsongISI catdiffcallisis catdiffsilentisis silenttime calltime silentifrs callifrs catcallifrs catsilentifrs catdiffsilentifrs catdiffcallifrs]=dbaseCallingISI(dbase);
    [nonsongISI catcallisis nonsongspiketimes callspiketimes silenttime]=dbaseSilentCallsISI(dbase);

else
    [boutstart boutend boutspiketimes interboutspiketimes catboutspikes catquietspikes boutISI interboutISI catdiffboutisis catdiffquietisis interbouttime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs]=dbaseSingingISI(dbase, varargin{1});
    %[callstart callend callspiketimes silentspiketimes catcallspikes catsilentspikes catcallisis nonsongISI catdiffcallisis catdiffsilentisis silenttime calltime silentifrs callifrs catcallifrs catsilentifrs catdiffsilentifrs catdiffcallifrs]=dbaseCallingISI(dbase);
    [nonsongISI catcallisis nonsongspiketimes callspiketimes silenttime]=dbaseSilentCallsISI(dbase, varargin{1});
end
if bIncludeInterBoutISI
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
if bPlot
    figure;plot(logisiedges, smooth(logboutdist,s)); hold on; plot(logisiedges,smooth(lognonsongdist,s), 'k');

    hold on; plot(logisiedges, smooth(loginterboutdist,s),'r');
    xlabel('Log Interspike interval (s)');ylabel('Probability Density'); xlim(loglim);title([dbase.title ': Distribution of Log Interspike intervals'])
end
