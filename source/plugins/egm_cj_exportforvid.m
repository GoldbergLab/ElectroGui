function handles = egm_cj_exportforvid(handles)
    %define functions to retrieve filenum and name
    function currentFileNum = getCurrentFileNum(handles)
    currentFileNum = str2double(get(handles.edit_FileNumber, 'string'));
    end
    function currentFileName = getCurrentFileName(handles)
    currentFileNum = getCurrentFileNum(handles);
    currentFileName = handles.sound_files(currentFileNum).name;
    end
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
        end
    end
    
    %% 
    dbase = handles.dbase;
    fs = handles.fs;
    fileNum = getCurrentFileNum(handles);
    n = getCurrentFileName(handles);

    % get marker and segment times
    markerTimes = handles.MarkerTimes{fileNum}/fs;
    markerTitles = handles.MarkerTitles{fileNum};

    segmentTimes = handles.SegmentTimes{fileNum}/fs;
    segmentTitles = handles.SegmentTitles{fileNum};
    
    % get birdID & date from file name
    birdID = n(1:4);
    tt = strfind(n,'_');
    date = n(tt(2)+1:strfind(n,'T')-1);
    year = date(1:4);
    month = date(5:6);
    day = date(7:8);
    %% code a bunch of hard coded shit for one example for jesse's talk
    curfig = gcf;
    set(curfig,'Position',[184         108        1413         955]);
    sh = get(curfig,'Children');
    %set(sh(1),'Colormap',colormap);
    set(sh(3),'xTick',[]);
    set(sh(2),'xTick',[]);
    set(sh(3),'YTick',[2000 4000 6000]);
    
    set(sh(3),'FontSize',14);
    set(sh(2),'Visible','off');
    set(sh(1),'Visible','off');
    sh(1).YLim = [-0.0009 0.003];
    sh(3).Title.String = '';
    sh(3).YLabel.String = 'Freq. (KHz)';
    sh(3).YTickLabel{1} = '2';
    sh(3).YTickLabel{2} = '4';
    sh(3).YTickLabel{3} = '6';
    sh(3).YLabel.FontSize = 14;
    lo1 = get(sh(1),'Position');
    lo2 = get(sh(2),'Position');
    lo3 = get(sh(3),'Position');
    %adjust height of spectrogram
    set(sh(3),'Position',[lo3(1) lo3(2) lo3(3) lo3(4)*0.75])
    %adjust position of ephys
    xdat = 1:length(sh(2).Children.XData);
    set(sh(2),'Position',[lo2(1) lo1(3)-0.32 lo2(3) lo2(4)]);
    set(sh(1),'Position',[lo1(1) lo1(3)-0.44 lo1(3) lo1(4)]);
    sh(2).XLim = sh(3).XLim;
    sh(1).XLim = sh(3).XLim;
    
    % add axes for behavioral segments
    ax4 = axes('Position',[lo3(1) lo1(3)-0.15 lo3(3) lo3(4)*0.5]);
    ax4.XLim = sh(3).XLim;
    ax4.YLim = [-1 1];
    axis off
    % plot markers
    for q = 1:size(markerTimes,1)
        line([markerTimes(q,1) markerTimes(q,2)],[-0.5 -0.5],'color','b','LineWidth',5)
    end
    % plot segs
    for q = 1:size(segmentTimes,1)
        line([segmentTimes(q,1) segmentTimes(q,2)],[0 0],'color','r','LineWidth',5)
    end


    % label the units
    sh(2).YLabel.Visible = 'on';
    sh(2).YLabel.String = 'Unit 1';
    sh(2).YLabel.Color = 'k';
    sh(2).YLabel.FontSize = 16;
    sh(2).YLabel.Rotation = 0;
    pos = sh(2).YLabel.Position;
    sh(2).YLabel.Position = [pos(1)-0.3 pos(2)*0.5 pos(3)];
    sh(1).YLabel.Visible = 'on';
    sh(1).YLabel.String = 'Unit 2';
    sh(1).YLabel.Color = 'k';
    sh(1).YLabel.FontSize = 16;
    sh(1).YLabel.Rotation = 0;
    pos2 = sh(1).YLabel.Position;
    sh(1).YLabel.Position = [pos(1)-0.3 pos2(2)*0.5 pos2(3)];
    % Link the x-axes of the subplots
    linkaxes([sh(1), sh(2), sh(3), ax4], 'x');
    
    % Set the total duration of the animation
    totalDuration = 20; % seconds
    
    % Set the frame rate and calculate the delay per frame
    frameRate = 30; % frames per second
    delayPerFrame = 1 / frameRate;
    
    % Calculate the number of frames and points per frame
    numFrames = totalDuration * frameRate;
    pointsPerFrame = numel(xdat) / numFrames;
    
    % Create a VideoWriter object
    videoFile = ['X:\Budgie\Caleb_saved_videos\' birdID '_' num2str(fileNum) '_' date '.avi'];
    writerObj = VideoWriter(videoFile, 'Motion JPEG AVI');
    writerObj.FrameRate = frameRate; % Set the frame rate of the video
    
    % Open the video file for writing
    open(writerObj);
    
    % Create the sliding bar using line
    fs = 20000;
    initialPosition = 1;
    slider1 = line(sh(1), [initialPosition, initialPosition], [sh(1).YLim(1), sh(1).YLim(2)], 'Color', 'r', 'LineWidth', 2);
    slider2 = line(sh(2), [initialPosition, initialPosition], [sh(2).YLim(1), sh(2).YLim(2)], 'Color', 'r', 'LineWidth', 2);
    slider3 = line(sh(3), [initialPosition, initialPosition], [sh(3).YLim(1), sh(3).YLim(2)], 'Color', 'r', 'LineWidth', 2);
    slider4 = line(ax4, [initialPosition,initialPosition],[ax4.YLim(1),ax4.YLim(2)],'Color','r','LineWidth',2);

    % Create an animation loop
    for frame = 1:numFrames
        disp(['Frame number: ' num2str(frame)])
        xSlider = (initialPosition+(frame/numFrames)*(max(xdat)-min(xdat)))/fs;
        set(slider1, 'XData', [xSlider, xSlider]);
        set(slider2, 'XData', [xSlider, xSlider]);
        set(slider3, 'XData', [xSlider, xSlider]);
        set(slider4, 'XData', [xSlider, xSlider]);
        %drawnow;
        % Capture the current frame
        thisframe = getframe(gcf);
        
        % Write the frame to the video file
        writeVideo(writerObj, thisframe);
    end
    
    close(writerObj)
end

