function stimClips = vgm_clipStimFromSignal(signal,preMs,postMs,yl,bplot)


stimThreshold=5;
preStimMs=preMs;
postStimMs=postMs;
maxPeakWidthMs=3; 
minPeakSpacingSecs=.25;
samplingRate=40000;

preStimNdx = -round((preStimMs/1000) * samplingRate);
postStimNdx = round((postStimMs/1000) * samplingRate);

[leadingEdgeNdx, fallingEdgeNdx] = detectThresholdCrossings(signal, stimThreshold, true);

%remove stim artifacts that are wider than allowed.
leadingEdgeNdx = leadingEdgeNdx(find(((fallingEdgeNdx - leadingEdgeNdx)/samplingRate)*1000 < maxPeakWidthMs));

%remove stim artifacts that are too close together.
if(length(leadingEdgeNdx) > 0)
    bGoodSpace = logical((diff(leadingEdgeNdx)/samplingRate) > minPeakSpacingSecs);
    bGoodSpace = [true;bGoodSpace]; % & [bGoodSpace;true];
    leadingEdgeNdx = leadingEdgeNdx(bGoodSpace);
end

%bp filter
bfilt=1;
if bfilt
    fs=40000;freq1 = 400;freq2 = 9000;ord = 80;
    b = fir1(ord,[freq1 freq2]/(fs/2));
    snd = filtfilt(b, 1, signal);
    signal=snd;
end

if(length(leadingEdgeNdx) == 0)
    stimClips = [];
    %         return;
    %     end
else

    stimClipNdx = repmat(leadingEdgeNdx,1,postStimNdx-preStimNdx+1) + repmat([preStimNdx:postStimNdx],length(leadingEdgeNdx),1);

    %Becareful because last stim in file can get cut off.
    if max(max(stimClipNdx))+postMs/1000*samplingRate > length(signal)
        stimClipNdx = stimClipNdx(1:end-1,:);
    end
    if max(max(stimClipNdx))+postMs/1000*samplingRate > length(signal)
        stimClipNdx = stimClipNdx(1:end-1,:);
    end
    if max(max(stimClipNdx))+postMs/1000*samplingRate > length(signal)
        stimClipNdx = stimClipNdx(1:end-1,:);
    end

    if(min(min(stimClipNdx))-preMs/1000*samplingRate < 1)
        stimClipNdx = stimClipNdx(2:end,:);
    end
    if(min(min(stimClipNdx))-preMs/1000*samplingRate < 1)
        stimClipNdx = stimClipNdx(2:end,:);
    end
    if(min(min(stimClipNdx))-preMs/1000*samplingRate < 1)
        stimClipNdx = stimClipNdx(2:end,:);
    end
    stimClips = signal(stimClipNdx);
    z=size(stimClips);
    %         for i=1:z(1);
    %             figure;plot(linspace(-1*preStimMs, postStimMs, length(stimClips)),stimClips(i,:),'k'); %ylim([-7,2]);
    %             xlim([-1*preStimMs, postStimMs]);ylim([-.2,.4]);
    %             %xlim([-200,200])
    %         end
end
if ~isempty(stimClips);
    if length(linspace(-1*preStimMs, postStimMs, length(stimClips))) == size(stimClips(1:min([5 size(stimClips,1)]),:),2)
        if bplot
            figure;plot(linspace(-1*preStimMs, postStimMs, length(stimClips)), stimClips(1:min([5 size(stimClips,1)]),:));
        end
        ylim(yl);xlim([-preMs postMs]);
        if bplot
            if z>0
                yy=[1:5:50];

                for i=1:z(1);
                    if ismember(i,yy);figure;count=0;end
                    count=count+1;
                    hold on;subplot(5,1,count);plot(linspace(-1*preStimMs, postStimMs, length(stimClips)),stimClips(i,:),'k'); %ylim([-7,2]);
                    set(gca,'xtick',[]);%set(gca,'ytick',[]);
                    xlim([-1*preStimMs, postStimMs]);
                    ylim([yl]);
                end
            end
        end
    end
else
    stimClips=[];
end
