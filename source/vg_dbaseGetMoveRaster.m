% function [dbase]=vg_dbaseGetMoveRaster(dbase);

%this runs detrend to get movetimes

%This function returns spiketimes and ifrs for selected
%channel/function/detector in dbase.  Spiketimes are in seconds in matlab
%time. dbase.Times is in matlab days, so *24*3600 to get to seconds.
fs=dbase.Fs; spiketimes=[];filestarttimes=[];ifr=[];ffiles=[];tempifr=[];
%Below function ensures that dbase.Times(n)<dbase.Times(n+1);
[dbase]=dbaseTimesCorrect(dbase);
dbase.Times2(find(dbase.Times==0))=NaN;
dbase.Times2=dbase.Times-min(dbase.Times(find(dbase.Times>0)));
dbase.moveindx = 4;
indx=dbase.moveindx;


filestarttimes=dbase.Times2*(3600*24);
%For loop below fixes file overlap problem
for f=1:length(dbase.Times)-1
    if (filestarttimes(f)+dbase.FileLength(f)/fs) > filestarttimes(f+1) %& filestarttimes(f+1)>0 & filestarttimes(f)>0 mod VG
        dbase.FileLength(f)=ceil(fs*(filestarttimes(f+1)-filestarttimes(f))); %dbase.FileLength is in samples
    end
end

%in the loop below, dbase.EventTimes{indx}{1 or 2,i} --> indx is the indx
%pointing to the movement events; 1 or 2 refers to movements onsets and
%offsets, respectively, and the i refers to the filenum

thres=1.5e-5;
smoothms=60;
s=(smoothms/1000)*dbase.Fs;

cd(dbase.PathName);
if isempty(dir('exper2.mat'))
    load([dbase.PathName '\exper.mat'])
else
    load([dbase.PathName '\exper2.mat'])
end

% chan=dbase.EventSources{dbase.moveindx}(end);
chan = '3';
exper.dir=[dbase.PathName '\'];
dbase.exper=exper;
  thres=1.5e-5;
for i=1:length(dbase.Times)%loop through all the files

    %Get filenum in exper terms (not nec = i)
    yo=max(find(dbase.ChannelFiles{str2num(chan)}(i).name=='_'));
    filenum=str2num(dbase.ChannelFiles{str2num(chan)}(i).name(yo-5:yo-1));
    signal=loadData(exper,filenum,chan);
    ssignal=smooth(signal,.001*dbase.Fs);
    N = length(signal);
    BP = [1:10000:(N-10000) N];
    y_dt = detrend(ssignal, 'linear', BP);
    y = smooth(y_dt.^2, s);

    temponsets=find(y(1:end-1)<thres & y(2:end)>=thres);
    tempoffsets=find(y(1:end-1)>thres & y(2:end)<=thres);

    temponsets = temponsets(find(temponsets<dbase.FileLength(i))); %only get spikes before the start of next file
    temponsets=temponsets+3600*24*dbase.Fs*dbase.Times2(i);%
    temponsets=temponsets./dbase.Fs;

    tempoffsets = tempoffsets(find(tempoffsets<dbase.FileLength(i))); %only get spikes before the start of next file
    tempoffsets=tempoffsets+3600*24*dbase.Fs*dbase.Times2(i);%yoyo changed to dbase.Times2
    tempoffsets=tempoffsets./dbase.Fs;

    moveonsets{i}=temponsets;
    moveoffsets{i}=tempoffsets;

end

%below get rid of moveoffsets that were first in file and moveonsets that
%were last in file and deals with the potential staggering of
%moveonsets/offsets in EventIsSelected field
movedurs=[];
for i=1:length(moveonsets)%loop through files
    if ~isempty(moveoffsets{i}) && ~isempty(moveonsets{i});
        if moveoffsets{i}(1)<moveonsets{i}(1);
            moveoffsets{i}=moveoffsets{i}(2:end);
            moveselected{2,i}=moveselected{2,i}(2:end);
        end
        if moveonsets{i}(end)>moveoffsets{i}(end);
            moveonsets{i}=moveonsets{i}(1:end-1);
            moveselected{1,i}=moveselected{1,i}(1:end-1);
        end
        select=moveselected{1,i}.*moveselected{2,i};
        moveonsets{i}=moveonsets{i}(find(select));
        moveoffsets{i}=moveoffsets{i}(find(select));

        tempmovedurs=[(moveoffsets{i}-moveonsets{i})];
        movedurs=[movedurs tempmovedurs];

    end
end
dbase.moveonsets=moveonsets;
dbase.moveoffsets=moveoffsets;
dbase.movedurs=movedurs;