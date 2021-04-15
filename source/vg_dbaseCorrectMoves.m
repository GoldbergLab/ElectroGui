function dbase=vg_dbaseCorrectMoves(dbase,thres);

%This function takes the updated movement onset/offset times and re-saves
%them in the EventTimes field. It also assigns a 0 value in the
%EventIsSelected field to any movement duration <thres.

%Finally, it reassigns dbase.moveonsets and dbase.moveoffsets based on this
%rejection of <thres movement durs

%IMPORTANT - It assumes that you've already fixed the problem files where
%num moveonets ~= num moveoffsets;

thres=.04;%reject any movement duration less than this value
indx=dbase.moveindx;
fs=dbase.Fs;
for i=1:length(dbase.Times);

    tmpmoveons=dbase.moveonsets{i}-dbase.filestarttimes(i);
    tmpmoveons=round(fs*tmpmoveons);
    tmpmoveoffs=dbase.moveoffsets{i}-dbase.filestarttimes(i);
    tmpmoveoffs=round(fs*tmpmoveoffs);
    tmpdurs=tmpmoveoffs-tmpmoveons;
    rejectindx=find(tmpdurs<(thres*fs));

    dbase.EventTimes{indx}{1,i}=tmpmoveons;
    dbase.EventTimes{indx}{2,i}=tmpmoveoffs;
    tmpSelected=ones(size(dbase.EventTimes{indx}{1,i}));
    tmpSelected(rejectindx)=0;
    dbase.EventIsSelected{indx}{1,i}=tmpSelected;
    dbase.EventIsSelected{indx}{2,i}=tmpSelected;

end

[dbase]=dbaseGetMoveRaster(dbase, dbase.moveindx);