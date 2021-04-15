function [dbase boutISI nonsongISI interboutISI boutspiketimes nonsongspiketimes interboutspiketimes edges boutdist nonsongdist bouttime silenttime interbouttime]=vg_dbaseBoutNonsongIMI(dbase,moveindx);

%This function gets ISIs from bouts and silence during bUnusable files.
%It also gets the mean rates (numspikes/total time) for bout, interbout,
%and nonsong

%IMPORTANT, the varargin is the indx you want to analyze (e.g. indx for
%spikes or moveindx for movements


[boutstart boutend boutspiketimes interboutspiketimes catboutspikes catquietspikes boutISI interboutISI catdiffboutisis catdiffquietisis interbouttime bouttime quietifrs boutifrs catboutifrs catquietifrs catdiffquietifrs catdiffboutifrs]=dbaseSingingIMI(dbase, moveindx);
[nonsongISI catcallisis nonsongspiketimes callspiketimes silenttime]=dbaseSilentCallsIMI(dbase, moveindx);



if isempty(dbase.unusables);
    nonsongISI=[nonsongISI interboutISI];
    silenttime=[silenttime interbouttime];
    nonsongspiketimes=[nonsongspiketimes interboutspiketimes];
end


dbase.IMI.bout=boutISI;
dbase.IMI.nonsong=nonsongISI;
dbase.IMI.interbout=interboutISI;
dbase.boutmovetimes = boutspiketimes;
dbase.nonsongmovetimes=nonsongspiketimes;
dbase.interboutmovetimes=interboutspiketimes;

%rates below
dbase.moverates.silent=length(concatenate(nonsongspiketimes))/sum(concatenate(silenttime));
dbase.moverates.interbout=length(concatenate(interboutspiketimes))/sum(concatenate(interbouttime));
dbase.moverates.bout=length(concatenate(boutspiketimes))/sum(concatenate(bouttime));
