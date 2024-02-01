function handles = egm_cj_export_current_view(handles)
    % Press control-e to produce a export of the sonogram and any channel
    % views.
    f_export = figure();

    % Determine how many channels are visible
    numChannels = 0;
    for c = 1:length(handles.axes_Channel)
        if strcmp(get(handles.axes_Channel(c), 'Visible'), 'on')
            numChannels = numChannels + 1;
        end
    end

    % Copy sonogram
    sonogram_export = subplot(numChannels+1, 1, 1, 'Parent', f_export);
    sonogram_children = get(handles.axes_Sonogram, 'Children');
    for k = 1:length(sonogram_children)
        copyobj(sonogram_children(k), sonogram_export);
    end
    % Match axes limits
    xlim(sonogram_export, xlim(handles.axes_Sonogram));
    ylim(sonogram_export, ylim(handles.axes_Sonogram));
    set(sonogram_export, 'CLim', get(handles.axes_Sonogram, 'CLim'));
    colormap(sonogram_export, handles.Colormap);

    % Set figure size to match contents
    set(sonogram_export, 'Units', get(handles.axes_Sonogram, 'Units'));
    curr_pos = get(sonogram_export, 'Position');
    son_pos = get(handles.axes_Sonogram, 'Position');
    aspect_ratio = 1.2*(1+numChannels)*son_pos(4) / son_pos(3);
    f_pos = get(f_export, 'Position');
    f_pos(4) = f_pos(3) * aspect_ratio;
    set(f_export, 'Position', f_pos);

    % Add title to sonogram (file name)
    currentFileName = getCurrentFileName(handles);
    title(sonogram_export, currentFileName, 'Interpreter', 'none');

    % Loop over any channels that are currently visible, and copy them
    chan = 0;
    for c = 1:length(handles.axes_Channel)
        if strcmp(get(handles.axes_Channel(c), 'Visible'), 'on')
            chan = chan + 1;
            channel_export = subplot(numChannels+1, 1, 1+chan, 'Parent', f_export);
            channel_children = get(handles.axes_Channel(c), 'Children');
            for k = 1:length(channel_children)
                copyobj(channel_children(k), channel_export);
            end

%            [~, selectedChannelName, ~] = getSelectedChannel(handles, c);
%             title(channel_export, selectedChannelName, 'Interpreter', 'none');
        end
    end
    
    %get filenum and mark/seg info
    fileNum  = getCurrentFileNum(handles);
    fs = handles.fs;
    markerTimes = handles.MarkerTimes{fileNum}/fs;
    markerTitles = handles.MarkerTitles{fileNum};

    segmentTimes = handles.SegmentTimes{fileNum}/fs;
    segmentTitles = handles.SegmentTitles{fileNum};
    
    % modify the plot

    h1 = subplot(211);
    %set(h1,'Visible','off');
    set(h1,'Ylim',[250 7000]);
    xlims = get(h1,'Xlim');
    h2 = subplot(212);
    set(h2,'Xlim',xlims);
    loc1 = get(h1,'Position');
    set(h1,'Position',[loc1(1) loc1(2)+0.03 loc1(3) loc1(4)])
    
    % add axes for behav segs
    hs = axes('Position',[loc1(1) loc1(2)-0.125 loc1(3) loc1(4)*0.5]);
    set(hs,'XLim',get(h1,'XLim'));
    set(hs,'YLim',[-1 1]);
    axis off
    % plot markers
    for q = 1:size(markerTimes,1)
        line([markerTimes(q,1) markerTimes(q,2)],[-0.5 -0.5],'color','b','LineWidth',5)
        text((markerTimes(q,1)+markerTimes(q,2))/2,-0.25,markerTitles(q),'Color','blue','FontSize',14)
    end
    % plot segs
    for q = 1:size(segmentTimes,1)
        line([segmentTimes(q,1) segmentTimes(q,2)],[0 0],'color','r','LineWidth',5)
    end
    
    set(gcf,'Position',[306 353 981 486]);
    set(h1,'Ylim',[250 7000]);
    xlabel('');
    set(h1,'Ytick',[2000 4000 6000]);
    set(h1,'YTickLabel',['2k'; '4k'; '6k'])
    set(h1,'FontSize',16)
    ylabel('Freq (Hz)');
    xlims = get(h1,'Xlim');
    h2 = subplot(212);
    loc2 = get(h2,'Position');
    set(h2,'Xlim',xlims);
    set(h2,'Visible','off');
    set(h2,'Position',[loc2(1) loc2(2)+0.05 loc2(3) loc2(4)])
    
    return
    
end
%define functions to retrieve filenum and name
function currentFileNum = getCurrentFileNum(handles)
currentFileNum = str2double(get(handles.edit_FileNumber, 'string'));
end
function currentFileName = getCurrentFileName(handles)
currentFileNum = getCurrentFileNum(handles);
currentFileName = handles.sound_files(currentFileNum).name;
end