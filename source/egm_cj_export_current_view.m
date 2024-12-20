function obj = egm_cj_export_current_view(obj)
    % Press control-e to produce a export of the sonogram and any channel
    % views.
    f_export = figure();

    % Determine how many channels are visible
    numChannels = 0;
    for c = 1:length(obj.axes_Channel)
        if strcmp(get(obj.axes_Channel(c), 'Visible'), 'on')
            numChannels = numChannels + 1;
        end
    end

    % Copy sonogram
    sonogram_export = subplot(numChannels+1, 1, 1, 'Parent', f_export);
    sonogram_children = get(obj.axes_Sonogram, 'Children');
    for k = 1:length(sonogram_children)
        copyobj(sonogram_children(k), sonogram_export);
    end
    % Match axes limits
    xlim(sonogram_export, xlim(obj.axes_Sonogram));
    ylim(sonogram_export, ylim(obj.axes_Sonogram));
    set(sonogram_export, 'CLim', get(obj.axes_Sonogram, 'CLim'));
    colormap(sonogram_export, obj.Colormap);

    % Set figure size to match contents
    set(sonogram_export, 'Units', get(obj.axes_Sonogram, 'Units'));
    curr_pos = get(sonogram_export, 'Position');
    son_pos = get(obj.axes_Sonogram, 'Position');
    aspect_ratio = 1.2*(1+numChannels)*son_pos(4) / son_pos(3);
    f_pos = get(f_export, 'Position');
    f_pos(4) = f_pos(3) * aspect_ratio;
    set(f_export, 'Position', f_pos);

    % Add title to sonogram (file name)
    currentFileName = electro_gui.getCurrentFileName(obj.dbase, obj.settings);
    title(sonogram_export, currentFileName, 'Interpreter', 'none');

    % Loop over any channels that are currently visible, and copy them
    chan = 0;
    for c = 1:length(obj.axes_Channel)
        if strcmp(get(obj.axes_Channel(c), 'Visible'), 'on')
            chan = chan + 1;
            channel_export = subplot(numChannels+1, 1, 1+chan, 'Parent', f_export);
            channel_children = get(obj.axes_Channel(c), 'Children');
            for k = 1:length(channel_children)
                copyobj(channel_children(k), channel_export);
            end

%            [~, selectedChannelName, ~] = getSelectedChannel(handles, c);
%             title(channel_export, selectedChannelName, 'Interpreter', 'none');
        end
    end

    %get filenum and mark/seg info
    fileNum  = electro_gui.getCurrentFileNum(obj.settings);
    fs = obj.dbase.Fs;
    markerTimes = obj.dbase.MarkerTimes{fileNum}/fs;
    markerTitles = obj.dbase.MarkerTitles{fileNum};

    segmentTimes = obj.dbase.SegmentTimes{fileNum}/fs;
    segmentTitles = obj.dbase.SegmentTitles{fileNum};

    % modify the plot
    % get current axes
    cur = get(gcf);
    numplots = length(cur.Children);
    if numplots ==2
        h1 = cur.Children(2);
        h2 = cur.Children(1);
        loc1 = get(h1,'Position');
        loc2 = get(h2,'Position');
        hs = axes('Position',[loc1(1) loc1(2)-loc1(4)/3 loc1(3) loc1(4)*0.5]);
    else
        if numplots ==3
            h1 = cur.Children(3);
            h2 = cur.Children(2);
            h3 = cur.Children(1);
            loc1 = get(h1,'Position');
            loc2 = get(h2,'Position');
            loc3 = get(h3,'Position');
            hs = axes('Position',[loc1(1) loc1(2)-loc1(4)*2 loc1(3) loc1(4)*0.5]);
        end
    end

    set(h1,'Ylim',[250 7000]);
    xlims = get(h1,'Xlim');
    set(h2,'Xlim',xlims);
    % add axes for behav segs

    set(hs,'XLim',get(h1,'XLim'));
    set(hs,'YLim',[-1 1]);
    axis off
    % plot markers
    for q = 1:size(markerTimes,1)
        line([markerTimes(q,1) markerTimes(q,2)],[-0.5 -0.5],'color','b','LineWidth',5)
        text((markerTimes(q,1)+markerTimes(q,2))/2,-0.15,markerTitles(q),'Color','blue','FontSize',14)
    end
    % plot segs
    for q = 1:size(segmentTimes,1)
        line([segmentTimes(q,1) segmentTimes(q,2)],[0 0],'color','r','LineWidth',5)
    end
    
    set(h1,'Ylim',[250 7000]);
    xlabel('');
    set(h1,'Ytick',[2000 4000 6000]);
    set(h1,'Xtick',[]);
    set(h1,'YTickLabel',['2'; '4'; '6'])
    set(h1,'FontSize',16)
    ylabel('Freq (Hz)');
    xlims = get(h1,'Xlim');
    set(h2,'Xlim',xlims);
    set(h2,'Visible','off');
    ylabel('Voltage')
    set(h2,'Position',[loc2(1) loc1(2)-loc1(4)*1.5 loc2(3) loc1(4)*1.4])

    %change color and thickness
    xd = get(h2,'Children');
    set(xd,'LineWidth',2)
    set(xd,'Color','k')
    xl = get(h2,'Xlim');
    line([xl(1),xl(1)],[-100, 0],'LineWidth',8)



    %modify third plot if it is there
    if numplots ==3
        loc3 = get(h3,'Position');
        set(h3,'Position',[loc3(1) loc1(2)-0.5 loc3(3) loc1(4)*1.3])
        set(h3,'Visible','off')
        set(h3,'Xlim',xlims);
    end
    set(gcf,'Position',[306 353 981 486]);


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
