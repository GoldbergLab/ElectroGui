function dbase=vg_dbaseGetallmoves(dbase);

%this function assumes you've already run vg_dbaseCorrectMoves and
%vg_dbaseGetMoveRaster. In other words, you've already created
%dbase.moveonsets where all move durs <40 ms were rejected.
%This rejection is instantiated in the
%dbase.EventIsSelected{dbase.moveindx} 0s and 1s. 

%Here, you are creating the fields dbase.allmoveons, dbase.allmoveoffs, and
%dbase.allmovedurs which accept all detectd movements, irrespective of
%duration. 

indx=dbase.moveindx;fs=dbase.Fs;
allmovedurs=[];
for i=1:length(dbase.EventTimes{indx})
    if ~isempty(dbase.EventTimes{indx}{1,i}) %if there are any spikes in the file

        tempspiketimes=dbase.EventTimes{indx}{1,i};
        tempspiketimes = tempspiketimes(find(tempspiketimes<dbase.FileLength(i))); %only get spikes before the start of next file
        tempspiketimes=tempspiketimes+3600*24*fs*dbase.Times2(i);%yoyo changed to dbase.Times2
        dbase.allmoveons{i}=tempspiketimes./fs;
        dbase.allmoveons{i}=dbase.allmoveons{i}';
        
        tempspiketimes=dbase.EventTimes{indx}{2,i};
        tempspiketimes = tempspiketimes(find(tempspiketimes<dbase.FileLength(i))); %only get spikes before the start of next file
        tempspiketimes=tempspiketimes+3600*24*fs*dbase.Times2(i);%yoyo changed to dbase.Times2
        dbase.allmoveoffs{i}=tempspiketimes./fs;
        dbase.allmoveoffs{i}=dbase.allmoveoffs{i}';
        
        allmovedurs=[allmovedurs dbase.allmoveoffs{i}-dbase.allmoveons{i}];
        
    end
end
dbase.allmovedurs=allmovedurs;