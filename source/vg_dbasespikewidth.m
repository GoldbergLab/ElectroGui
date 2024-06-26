function [dbase] = vg_dbasespikewidth(dbase, varargin)

if isempty(varargin);
bEliminateOutliers=1;
else
bEliminateOutliers=varargin{1};
end



bplot1=0;

interpVal=8;
%load the exper file
cd(dbase.PathName);
if isempty(dir('exper2.mat'))
    load([dbase.PathName '\exper.mat'])
else
    load([dbase.PathName '\exper2.mat'])
end
%note this used to be called dbasegetspikewaveform

%This function returns numspks number of sample spikes, as well as the
%amplitude ratio (unitless) and spikeduration (ms) of that many averaged spikes.
%at present data is interpolated 4-fold.  if change interpVal then you
%should change window size (win) as well as double check on spikeduration
%calculation.  It goes through many files and finds the biggest spike.  To
%make it run faster, change the filestep size.
fs=40000;
filestep=1;

win=[-500:500];
count=0;
numspks=50; %number of spikes to keep on the file.

[spiketimes, ifr, spkndx]=dbaseGetRasterOld(dbase,dbase.indx);clear ifr;

chan=dbase.EventSources{spkndx}(end);

exper.dir=[dbase.PathName '\'];

for i=1:filestep:length(spiketimes)%i is dbase filenum; not the filenum for exper
    if ~isempty(spiketimes{i}) && ~dbase.stims(i);
        %Get filenum in exper terms (not nec = i)
        yo=max(find(dbase.ChannelFiles{str2num(chan)}(i).name=='_'));
        filenum=str2num(dbase.ChannelFiles{str2num(chan)}(i).name(yo-5:yo-1));
        if strcmp(dbase.BirdID,'2898')
            signal=loadData(exper,filenum,10);
        else
            signal=loadData(exper,filenum,chan);
        end
        spks=dbase.Fs*spiketimes{i}-3600*24*dbase.Fs*dbase.Times(i);
        spks=spks(find(spks>length(win)));%this is to ensure that you can get a window around the spike
        spks=spks(find(spks<(length(signal)-length(win))));

        %Get spike Ndx from preselected spikes (in this dbase);
        leading=spks;leading=leading';
        %Below use hanning high pass on signal
        params.Names={'Cutoff frequency (Hz)','Order'};params.Values={'750','80'};
        %[signal lab] = egf_HanningHighPass(signal,dbase.Fs,params);
        data=signal;
        %Interpolate signal 4fold, 'spline'
        %         t=1/40000:1/40000:length(signal)/40000;
        %         t4=1/40000:1/160000:length(signal)/40000;
        %         data=interp1(t,signal,t4,'spline');
        %         leading=4*leading;

        %Orient data properly
        if(size(data,2) > size(data,1))
            data = data';
        end

        offsets = repmat(win, length(leading),1);
        indices = repmat(leading, 1, length(win));
        indices = offsets + indices;
        indices(indices<1) = 1;
        indices(indices>length(data)) = length(data);
        [nadir, nadirNdx] = min(data(indices),[],2);
        [zenith, zenithNdx] = max(data(indices),[],2);
        nadirNdx = indices(:,1) + nadirNdx - 1;
        zenithNdx = indices(:,1) + zenithNdx - 1;

        window=win;
        if dbase.EventThresholds(spkndx,i)>0
            y=repmat(zenithNdx',length(window), 1);
        else
            y=repmat(nadirNdx',length(window),1);
        end
        y=y+repmat(window',1,length(zenithNdx));
        spikes=data(y);spikes=spikes';
        if length(leading)>numspks
            spikes=spikes(1:numspks,:);
        else
            spikes=spikes(1:length(leading),:);
        end
%         figure;plot(mean(spikes),'r');title(num2str(filenum));
        spikesize(i)=max(mean(spikes))-min(mean(spikes));
    else
        spikesize(i)=NaN;
    end
end

[bigspike bestfile]=max(spikesize);

%Now run on just the best spikefile
for i=bestfile%i is dbase filenum; not the filenum for exper
    %Get filenum in exper terms (not nec = i)
    yo=max(find(dbase.ChannelFiles{str2num(chan)}(i).name=='_'));
    filenum=str2num(dbase.ChannelFiles{str2num(chan)}(i).name(yo-5:yo-1));
    if strcmp(dbase.BirdID,'2898')
        signal=loadData(exper,filenum,10);
    else
        signal=loadData(exper,filenum,chan);
    end
    spks=dbase.Fs*spiketimes{i}-3600*24*dbase.Fs*dbase.Times(i);
    spks=spks(find(spks>length(win)));%this is to ensure that you can get a window around the spike

    spks=spks(find(spks>length(win)));%this is to ensure that you can get a window around the spike
    spks=spks(find(spks<(length(signal)-length(win))));

    %Get spike Ndx from preselected spikes (in this dbase);
    leading=spks;leading=leading';
    %Below use hanning high pass on signal
    %params.Names={'Cutoff frequency (Hz)','Order'};params.Values={'750','80'};
    %[signal lab] = egf_HanningHighPass(signal,dbase.Fs,params);
    data=signal;
    %Interpolate signal 4fold, 'spline'
    t=1/fs:1/fs:length(signal)/fs;
    t4=1/fs:1/(interpVal*fs):length(signal)/fs;
    data=interp1(t,signal,t4,'spline');
    leading=interpVal*leading;

    %Orient data properly
    if(size(data,2) > size(data,1))
        data = data';
    end

    offsets = repmat(win, length(leading),1);
    indices = repmat(leading, 1, length(win));
    indices = offsets + indices;
    indices(indices<1) = 1;
    indices(indices>length(data)) = length(data);
    [nadir, nadirNdx] = min(data(indices),[],2);
    [zenith, zenithNdx] = max(data(indices),[],2);
    nadirNdx = indices(:,1) + nadirNdx - 1;
    zenithNdx = indices(:,1) + zenithNdx - 1;

    window=win;
    if dbase.EventThresholds(spkndx,i)>0
        y=repmat(zenithNdx',length(window), 1);
    else
        y=repmat(nadirNdx',length(window),1);
    end
    y=y+repmat(window',1,length(zenithNdx));
    spikes=data(y);spikes=spikes';
    if length(leading)>numspks
        spikes=spikes(1:numspks,:);
    else
        spikes=spikes(1:length(leading),:);
    end

end

%eliminate outlier spikes
if bEliminateOutliers
    for j=[80 100 120];
        a=prctile(spikes(:,j),[5,95]);
        acceptNdx=find(spikes(:,j)>a(1) & spikes(:,j)<a(2));
        spikes=spikes(acceptNdx,:);
    end
end


thespike=mean(spikes);

%amplitude ratio is measure of biphasicness--more biphasic is lower
%amplitdue ratio, monophasic
amplitude_ratio=(abs(min(thespike))-max(thespike))/(abs(min(thespike))+max(thespike));

%now get spike duration based on when spike enters and std of signal<.1(w/o spike)
c=1.5;% c is how many stds from baseline you want cutoff;

%width based on std rel to noise for onset and offset of spike
% cutoff=c*std(signal(find(signal<.1)));
% cutoff=c*std(signal(1:60));
% begin=find(abs(thespike)>cutoff);begin=begin(1);
% theend=find(fliplr(abs(thespike))>cutoff);theend=theend(1);
% theend=length(win)-theend;
% spikeduration=1000*(theend-begin)/(4*40000);

mean_rate=[];
% [boutISI nonsongISI]=dbaseBoutNonsongISI(dbase, 0, 0, 1);
% mean_rate=1/mean(nonsongISI);
% mean_rate=length(nonsongISI)/sum(nonsongISI);

% spikestats.dur=spikeduration;spikestats.ratio=amplitude_ratio;spikestats.rate=mean_rate;
% figure;plot(-cumsum(mean(spikes)-mean(mean(spikes))));
% title('CumsumSpike');

%2nd deriviative of spike
% deriv2spike=abs(diff(diff(thespike)));
% derivbaseline=[deriv2spike(1:60) deriv2spike(end-60:end)];
% sw=find(deriv2spike>5*std(derivbaseline));
% sw=(max(sw)-min(sw))/(4*fs);

fs4=interpVal*fs;

% hold on; plot(begin,thespike(begin),'.k');hold on; plot(theend,thespike(theend),'.k');
% hold;plot(deriv2spike);hold on; plot([1:241],(max(derivbaseline)+std(derivbaseline))*ones(1,241),'r')

data=thespike;
data=data-mean(data(1:win(end)-10));

if abs(min(data))>=max(data)
    thres=min(data)/2;
    onsetndx = find(data(1:end-1)>thres & data(2:end)<=thres);
    offsetndx = find(data(1:end-1)<thres & data(2:end)>=thres);
else
    thres=max(data)/2;
    onsetndx = find(data(1:end-1)<thres & data(2:end)>=thres);
    offsetndx = find(data(1:end-1)>thres & data(2:end)<=thres);
end
    
    %figure;plot(thespike);

halfwidth=(offsetndx-onsetndx)/fs4;
clear thespike
edges=[1/fs4:1/fs4:length(win)/fs4];
dbase.thespike.thespike=data;
dbase.thespike.edges=edges;
dbase.thespike.halfwidth=halfwidth*1000;
dbase.thespike.bestfile=bestfile;
dbase.thespike.spikeheight=max(dbase.thespike.thespike)-min(dbase.thespike.thespike);

s=3;
if bplot1
    figure;plot([1/fs4:1/fs4:length(win)/fs4],median(spikes));
    hold on; plot(onsetndx/fs4,data(onsetndx),'.r');hold on; plot(offsetndx/fs4, data(offsetndx),'.r');
    hold on; plot([1/fs4:1/fs4:length(win)/fs4],prctile(spikes,25),'k');
    hold on; plot([1/fs4:1/fs4:length(win)/fs4],prctile(spikes,75),'k');
    title([dbase.title ' ' num2str(1000*dbase.thespike.halfwidth)]);
end

d=data(1:300);
[mm ndxmin]=min(data);[mx ndxmax]=max(data);
thres=[mean(d)+4*std(d), mean(d)-4*std(d)];

if ndxmin<ndxmax
        onset = find(data(1:end-1)>thres(2) & data(2:end)<=thres(2));onset=onset(1);
offset = find(data(1:end-1)>thres(1) & data(2:end)<=thres(1));offset=offset(end);

else
    onset = find(data(1:end-1)<thres(1) & data(2:end)>=thres(1));onset=onset(1);
offset = find(data(1:end-1)<thres(2) & data(2:end)>=thres(2));offset=offset(end);
end
dbase.thespike.totalwidth=1000*(offset-onset)/fs4;
[test ndxmax]=max(dbase.thespike.thespike);[test ndxmin]=min(dbase.thespike.thespike);
dbase.thespike.widthMinToMax=abs(ndxmax-ndxmin)/fs4;


