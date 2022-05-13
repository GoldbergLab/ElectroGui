function [spiketimes,ifr,indx, dbase]=vgm_dbaseGetRaster(dbase, varargin)

%Changed in 2010 to account for weird sampling in matlab time
%line 52 changed to dbase.Times2 which is the min(dbase.Times) not matlab
%time

%This function returns spiketimes and ifrs for selected
%channel/function/detector in dbase.  Spiketimes are in seconds in matlab
%time. dbase.Times is in matlab days, so *24*3600 to get to seconds.
bgetifr=0;
fs=dbase.Fs; indx=0; spiketimes=[];filestarttimes=[];ifr=[];ffiles=[];tempifr=[];
%Below function ensures that dbase.Times(n)<dbase.Times(n+1);
[dbase]=dbaseTimesCorrect(dbase);

dbase.Times2(find(dbase.Times==0))=NaN;
dbase.Times2=dbase.Times-min(dbase.Times(find(dbase.Times>0)));

if isempty(varargin)
    [source,ok] = listdlg('ListString',dbase.EventSources,'InitialValue',1,'Name','Choice','PromptString',dbase.title,'SelectionMode','single');
    [fnctn,ok]=listdlg('ListString',dbase.EventFunctions,'InitialValue',1,'Name','Choice','PromptString','Select choice','SelectionMode','single');
    [detector,ok]=listdlg('ListString',dbase.EventDetectors,'InitialValue',1,'Name','Choice','PromptString','Select choice','SelectionMode','single');
    
    % dbase.EventSources=['Channel ' num2str(chan)];% dbase.EventDetectors='SpikesAA';% dbase.EventFunctions='HanningHighPass';
    
    for i=1:length(dbase.EventSources)
        if strcmp(dbase.EventSources{i},dbase.EventSources(source)) & strcmp(dbase.EventDetectors{i},dbase.EventDetectors(detector)) & strcmp(dbase.EventFunctions{i},dbase.EventFunctions(fnctn))
            indx=i;
        end
    end
    if indx==0
        error('Event not found')
    end
else
    indx=varargin{1};
end

filestarttimes=dbase.Times2*(3600*24);
%For loop below fixes file overlap problem
% for f=2:length(dbase.Times)
%     if filestarttimes(f) < filestarttimes(f-1)+dbase.FileLength(f-1)/fs
%         overlap = filestarttimes(f-1)+dbase.FileLength(f-1)/fs-filestarttimes(f);
%         dbase.FileLength(f)=ceil(fs*(dbase.FileLength(f)-overlap)); %dbase.FileLength is in samples
%         newstart = filestarttimes(f)+overlap;
%     end
% end
for f=1:length(dbase.Times)-1
    if (filestarttimes(f)+dbase.FileLength(f)/fs) > filestarttimes(f+1)
        dbase.FileLength(f)=ceil(fs*(filestarttimes(f+1)-filestarttimes(f))); %dbase.FileLength is in samples
    end
end

%i is the filenum
for i=1:size(dbase.EventTimes{indx},2)
    if ~isempty(dbase.EventTimes{indx}{1,i}) %if there are any spikes in the file
        a=size(dbase.EventIsSelected{indx}{1,i});b=size(dbase.EventIsSelected{indx}{end,i});
        %below if statement for 0520fix
        if a(1)~=b(1);dbase.EventIsSelected{indx}{end,i}=dbase.EventIsSelected{indx}{end,i}';end
        % if detect nadir should look at eventtimes{indx}(2,i).  BEGIN rc edit 122118
        row = 1;
        if dbase.EventThresholds(indx,i)<0
            row = 2;
        end
        tempspiketimes=dbase.EventTimes{indx}{row,i}(find(dbase.EventIsSelected{indx}{1,i}.*dbase.EventIsSelected{indx}{end,i}));
        % if detect nadir should look at eventtimes{indx}(2,i).  END rc edit 122118
        tempspiketimes = tempspiketimes(find(tempspiketimes<dbase.FileLength(i))); %only get spikes before the start of next file
        tempspiketimes=tempspiketimes+3600*24*fs*dbase.Times2(i);%yoyo changed to dbase.Times2
        tempspiketimes=tempspiketimes';
        if bgetifr
            tempIFR=zeros(1,dbase.FileLength(i));
            for c=1:length(tempspiketimes)-1
%                 tempIFR((tempspiketimes(c):tempspiketimes(c+1))-3600*24*fs*dbase.Times(i))=fs/(tempspiketimes(c+1)-tempspiketimes(c));
                  tempIFR((tempspiketimes(c):tempspiketimes(c+1)))=fs/(tempspiketimes(c+1)-tempspiketimes(c));
            end
            ifr{i}=tempIFR;
        else
            ifr{i}=[];
        end
        tempspiketimes=tempspiketimes./fs;
        spiketimes{i}=tempspiketimes;
    else
        ifr{i}=[];
        spiketimes{i}=[];
    end
end
% dbase.spiketimes=spiketimes;
