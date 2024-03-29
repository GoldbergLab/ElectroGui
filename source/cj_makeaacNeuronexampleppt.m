function cj_makeaacNeuronexampleppt(dbase,ephyschan)
    %% makes a ppt of many warble examples, headbob, and kisses
    close all
    path = dbase.PathName;

    smoothwin = 5;

    fs = dbase.Fs;
    afs = 5000; %HARD CODED ACC FS
    files = dir([path '\*chan' num2str(ephyschan) '.*']);
    files = {files.name};
    soundfiles = {dbase.SoundFiles.name};
    zfiles = dir([path '\*chan18.*']);
    xfiles = dir([path '\*chan19.*']);
    yfiles = dir([path '\*chan20.*']);
    zfiles = {zfiles.name};
    xfiles = {xfiles.name};
    yfiles = {yfiles.name};
    n = soundfiles{1000}; % 1000th sound file best guess for bird id and date THIS COULD BE WRONG
    birdID = n(1:4);
    tt = strfind(n,'_');
    date = n(tt(2)+1:strfind(n,'T')-1);

    %get dnums for files 
    for i = 1:length(soundfiles)
        uind = strfind(soundfiles{i},'_');
        dnum{i} = soundfiles{i}(uind(1)+2:uind(2)-1);
    end

    %initialize a ppt
    ppt = actxserver('PowerPoint.Application');
    disp('Creating a new Presentation');
    Presentation = ppt.Presentation.Add;

    %add title page
    titleslideText = (['Bird ' birdID ' date ' date ' chan ' num2str(ephyschan)]);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;

    %get ind of ephys
    e_ind = [];
    for i = 1:length(dbase.EventSources)
        if strrep(dbase.EventSources{i}(end-1:end),' ','') == num2str(ephyschan) & size(dbase.EventTimes{i},1) ~=1 & strcmp(dbase.EventDetectors{i},'Spikes_AA')
            e_ind = i;  
        end
    end

    %find sorted files
    sortedfiles = [];
    spks = dbase.EventTimes{e_ind};
    sels = dbase.EventIsSelected{e_ind};
    j = 0;
    for i = 1:length(spks)
        ispks = spks{1,i};
        isels = sels{1,i};
        usels = sels{2,i};
        isels = ~or(~isels,~usels);
        if ~isempty(ispks)
            selspks = ispks(find(isels));
            if ~isempty(selspks)
                j = j+1;
                sortedfiles{1,j} = dnum{i};
                sortedfiles{2,j} = i;
                sortedspks{j} = spks{2,i};
            end
        end
    end
    sortf = [sortedfiles{2,:}];

    %% get ind of calls and make call plots
    titleslideText = ('Calls');
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    
    C_ind = cj_findCellIndices(dbase.SegmentTitles,'C');
    cfiles = [C_ind{1,:}];
    csfiles = intersect(sortf,cfiles);
    count = 0;
    pad = fs/2;
    for i = 1:length(csfiles)
        num = csfiles(i);
        icalls = C_ind{2,find([C_ind{1,:}]==num)};
        calltimes = dbase.SegmentTimes{num}(icalls,:);

        segmentTimes = dbase.SegmentTimes{num};
        segmentTitles = dbase.SegmentTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);
        movex = egl_HC_ad([path '\' xfiles{num}],1);
        movey = egl_HC_ad([path '\' yfiles{num}],1);
        movez = egl_HC_ad([path '\' zfiles{num}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);
        
        for j = 1:size(calltimes,1)
            count=count+1;
            plt = figure;
            
            xlims = [calltimes(j,1)-pad calltimes(j,2)+pad];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end

            % chop up the audio and ephys and acc so we don't plot unnecessary data
            sou = sound(xlims(1):xlims(2));
            eph = ephys(xlims(1):xlims(2));
            mov = smooth(movecom(ceil(xlims(1)/4):round(xlims(2)/4)),smoothwin);
            % spectrogram
            H = subplot(411);
            showAudioSpectrogram(sou,fs);
            ylim([250 7500])
            yticks('')
            ylabel('')
            xticks([0 round(length(sou)/fs,2)])
            xlabel('')
            loc1 = H.Position;
            H.FontSize = 12;
            firstlims = H.XLim;

            % plot segments
            H = subplot(412);
            xlim(xlims/fs)
            ylim([-2 2])
            for q = 1:size(segmentTimes,1)
                if segmentTimes(q,1) > xlims(1) && segmentTimes(q,2) < xlims(2)
                    line([segmentTimes(q,1)/fs segmentTimes(q,2)/fs],[-0.08 -0.08],'color','r','LineWidth',5)
                    text((segmentTimes(q,1)/fs+segmentTimes(q,2)/fs)/2,0.55,segmentTitles(q),'Color','red','FontSize',14) 
                end
            end
            axis off
            loc2 = H.Position;
            H.Position = [loc1(1) loc1(2)-0.12 loc2(3) loc2(4)];

            % plot ephys
            H = subplot(413);
            time = (0:length(sou)-1)*(1/fs);
            plot(time,eph,'k','LineWidth',2);
            xlim(plt.Children(3).XLim)
            axis off
            H.Position = [loc1(1) loc1(2)-0.23 loc2(3) loc2(4)];
            eylims(count,:) = ylim;

            % plot movement
            H = subplot(414);
            time = (0:length(mov)-1)*(1/afs);
            plot(time,mov,'LineWidth',2);
            axis off
            H.Position = [loc1(1) loc1(2)-0.37 loc2(3) loc2(4)];
            xlim(firstlims)
            aylims(count,:) = ylim;
            maxlist(count) = max(mov);
            minlist(count) = min(mov);

            %add plot to arr
            plt = shrinkFigureToContent(plt);
            plt.Position = [680.0000  601.0000  205.0000  320.3959];
            plots(count) = plt;
            clear plt   
        end
    end
    %adjust ylims
    meylim = median(eylims);
    maylim = [min(minlist) max(maxlist)];
    for i = 1:length(plots)
        plots(i).Children(2).YLim = meylim;
        plots(i).Children(1).YLim = maylim;
    end
    % make tiled plots and put them in ppt
    totplots = 12;
    layout = 0:totplots:length(plots);
    for i = layout
        if i ~= layout(end)
            fig = tileFigures(plots(i+1:i+totplots),[6 2],0,[0,0]);
        else 
            if ~isempty(plots(i+1:end))
                fig = tileFigures(plots(i+1:end),[6 2],0,[0,0]);
            end
        end
        fig.Position=[107 108 1640 933];
        rc_exportfigpptx(Presentation,fig,[1,1]);
        %Presentation = pptAddFigure(Presentation,fig);
    end
    close all
    clear plots

    %%  get ind of warb bool and make warble plots
    titleslideText = ('warble');
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title

    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    for i = 1:length(dbase.Properties.Names{1})
        if strcmp(dbase.Properties.Names{1}{i}, 'containsWarb')
            ind = i;
        end
    end
    warb = [];
    for i = 1:length(dbase.Properties.Values)
        if dbase.Properties.Values{i}{ind} == 1
            warb(i) = 1;
        else
            warb(i) = 0;
        end
    end
    if length(find(warb))>12
        newwarb = datasample(find(warb),12);
    else
        newwarb = find(warb);
    end
    eylims = zeros(length(newwarb),2);
    aylims = zeros(length(newwarb),2);
    for i = 1:length(newwarb)
        plt = figure;
        sound = egl_HC_ad([path '\' soundfiles{newwarb(i)}],1);
        ephys = egl_HC_ad([path '\' files{newwarb(i)}],1);

        movex = egl_HC_ad([path '\' xfiles{newwarb(i)}],1);
        movey = egl_HC_ad([path '\' yfiles{newwarb(i)}],1);
        movez = egl_HC_ad([path '\' zfiles{newwarb(i)}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);
        %spectrogram
        H = subplot(311);
        showAudioSpectrogram(sound,fs);
        ylim([250 7500])
        yticks('')
        ylabel('')
        xticks([0 round(length(sound)/fs,2)])
        xlabel('')
        loc1 = H.Position;
        xl1 = H.XLim;
        %ephys
        H = subplot(312);
        time = (0:length(sound)-1)*(1/fs);
        plot(time,ephys,'k')
        axis off
        eylims(i,:) = ylim;
        H.Position = [loc1(1) loc1(2)-0.23 loc1(3) loc1(4)];
        plt.Position = [78 364 1531 716];
        xlim(xl1);
        %accel
        H = subplot(313);
        time = (0:length(movecom)-1)*(1/afs);
        plot(time,smooth(movecom,smoothwin))
        xlim(xl1);
        axis off
        aylims(i,:) = ylim;
        H.Position = [loc1(1) loc1(2)-0.4 loc1(3) loc1(4)];
        plt = shrinkFigureToContent(plt);
        warbplots(i) = plt;
    end
    
    %adjust all plots to have median y limits
    meylim = median(eylims);
    maylim = median(aylims);
    for i = 1:length(warbplots)
        warbplots(i).Children(2).YLim = meylim;
        warbplots(i).Children(1).YLim = maylim;
    end


    fig = tileFigures(warbplots(1:4),[1 4],0,[0,0],true);
    rc_exportfigpptx(Presentation,fig,[1,1]);
    fig = tileFigures(warbplots(5:8),[1 4],0,[0,0],true);
    rc_exportfigpptx(Presentation,fig,[1,1]);
    fig = tileFigures(warbplots(9:12),[1 4],0,[0,0],true);
    rc_exportfigpptx(Presentation,fig,[1,1]);

    %% get indices of gestures
    h_ind = cj_findCellIndices(dbase.MarkerTitles,'h');
    hfiles = [h_ind{1,:}];
    k_ind = cj_findCellIndices(dbase.MarkerTitles,'k');
    kfiles = [k_ind{1,:}];
    t_ind = cj_findCellIndices(dbase.MarkerTitles,'t');
    tfiles = [t_ind{1,:}];
    %get overlapped with sorted files
    hsfiles = intersect(sortf,hfiles);
    ksfiles = intersect(sortf,kfiles);
    tsfiles = intersect(sortf,tfiles);

    %% making headbob plots
    %add title page
    titleslideText = (['headbobs']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    rearpad = 2*fs; %2 seconds before hbob
    pad = fs;
    eylims = [];
    aylims = [];
    for i = 1:length(hsfiles)
        num = hsfiles(i);
        hbs = h_ind{2,find([h_ind{1,:}]==num)};

        hbtimes = dbase.MarkerTimes{num}(hbs,:);
        markerTimes = dbase.MarkerTimes{num};
        markerTitles = dbase.MarkerTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);
        movex = egl_HC_ad([path '\' xfiles{num}],1);
        movey = egl_HC_ad([path '\' yfiles{num}],1);
        movez = egl_HC_ad([path '\' zfiles{num}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);

        for j = 1:size(hbtimes,1)
            count = count +1;
            plt = figure;
            H = subplot(411);
            % determine xlims
            cent = floor((hbtimes(j,1)+hbtimes(j,2))/2);
            xlims = [hbtimes(j,1)-rearpad hbtimes(j,2)+pad];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            % chop up the audio and ephys and acc so we don't plot unnecessary data
            sou = sound(xlims(1):xlims(2));
            eph = ephys(xlims(1):xlims(2));
            mov = smooth(movecom(ceil(xlims(1)/4):round(xlims(2)/4)),smoothwin);
            % spectrogram
            showAudioSpectrogram(sou,fs);
            ylim([250 7500])
            yticks('')
            ylabel('')
            xticks([0 round(length(sou)/fs,2)])
            xlabel('')
            loc1 = H.Position;
            H.FontSize = 12;
            firstlims = H.XLim;

            % plot segments
            H = subplot(412);
            xlim(xlims/fs)
            ylim([-2 2])
            for q = 1:size(markerTimes,1)
                if markerTimes(q,1) > xlims(1) && markerTimes(q,2) < xlims(2)
                    line([markerTimes(q,1)/fs markerTimes(q,2)/fs],[-0.08 -0.08],'color','b','LineWidth',5)
                    text((markerTimes(q,1)/fs+markerTimes(q,2)/fs)/2,0.55,markerTitles(q),'Color','blue','FontSize',14) 
                end
            end
            axis off
            loc2 = H.Position;
            H.Position = [loc1(1) loc1(2)-0.12 loc2(3) loc2(4)];

            % plot ephys
            H = subplot(413);
            time = (0:length(sou)-1)*(1/fs);
            plot(time,eph,'k','LineWidth',2);
            xlim(plt.Children(3).XLim)
            axis off
            H.Position = [loc1(1) loc1(2)-0.23 loc2(3) loc2(4)];
            eylims(count,:) = ylim;

            % plot movement
            H = subplot(414);
            time = (0:length(mov)-1)*(1/afs);
            plot(time,mov,'LineWidth',2);
            axis off
            H.Position = [loc1(1) loc1(2)-0.37 loc2(3) loc2(4)];
            xlim(firstlims)
            aylims(count,:) = ylim;

            %add plot to arr
            plt = shrinkFigureToContent(plt);
            plots(count) = plt;
            clear plt
        end
    end
    %adjust ylims
    meylim = median(eylims);
    maylim = median(aylims);
    for i = 1:length(plots)
        plots(i).Children(1).YLim = maylim;
        plots(i).Children(2).YLim = meylim;
    end
    % make tiled plots and put them in ppt
    totplots = 9;
    layout = 0:totplots:length(plots);
    for i = layout
        if i ~= layout(end)
            fig = tileFigures(plots(i+1:i+totplots),[3 3],0,[0,0]);
        else 
            if ~isempty(plots(i+1:end))
                fig = tileFigures(plots(i+1:end),[3 3],0,[0,0]);
            end
        end
        fig.Position=[107 108 1640 933];
        loc = fig.Children(1).Position;
        locb = fig.Children(end).Position;
        rc_exportfigpptx(Presentation,fig,[1,1]);
        %Presentation = pptAddFigure(Presentation,fig);
    end
    close all
    clear plots

    %% making kissing plots
    %add title page
    titleslideText = (['Kissing']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    pad = fs*1.5;
    maxlist = [];
    minlist = [];
    for i = 1:length(ksfiles)
        num = ksfiles(i);
        ks = k_ind{2,find([k_ind{1,:}]==num)};
        kstimes = dbase.MarkerTimes{num}(ks,:);
        markerTimes = dbase.MarkerTimes{num};
        markerTitles = dbase.MarkerTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);
        movex = egl_HC_ad([path '\' xfiles{num}],1);
        movey = egl_HC_ad([path '\' yfiles{num}],1);
        movez = egl_HC_ad([path '\' zfiles{num}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);

        for j = 1:size(kstimes,1)
            count = count+1;
            plt = figure;
            H = subplot(311);

            % determine xlims
            cent = floor((kstimes(j,1)+kstimes(j,2))/2);
            xlims = [kstimes(j,1)-pad kstimes(j,2)+pad];
            if xlims(1) <0 || xlims(1) == 0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            % chop up the audio and ephys so we don't plot unnecessary data
            sou = sound(xlims(1):xlims(2));
            eph = ephys(xlims(1):xlims(2));
            mov = smooth(movecom(ceil(xlims(1)/4):round(xlims(2)/4)),smoothwin);

            showAudioSpectrogram(sou,fs);
            ylim([250 7500])
            yticks('')
            ylabel('')
            xticks([0 round(length(sou)/fs,2)])
            xlabel('')
            loc1 = H.Position;
            H.FontSize = 12;
            firstlims = H.XLim;

            %plot segments
            H = subplot(312);
            xlim(xlims/fs)
            ylim([-2 2])
            for q = 1:size(markerTimes,1)
                if markerTimes(q,1) > xlims(1) && markerTimes(q,2) < xlims(2)
                    line([markerTimes(q,1)/fs markerTimes(q,2)/fs],[-0.08 -0.08],'color','b','LineWidth',5)
                    text((markerTimes(q,1)/fs+markerTimes(q,2)/fs)/2,0.55,markerTitles(q),'Color','blue','FontSize',14) 
                end
            end
            axis off
            loc2 = H.Position;
            H.Position = [loc1(1) loc1(2)-0.149 loc2(3) loc2(4)];

            %plot ephys
            H = subplot(313);
            time = (0:length(sou)-1)*(1/fs);
            plot(time,eph,'k','LineWidth',2);
            xlim(plt.Children(3).XLim)
            axis off
            H.Position = [loc1(1) loc1(2)-0.275 loc2(3) loc2(4)];

            % plot movement
            H = subplot(414);
            time = (0:length(mov)-1)*(1/afs);
            plot(time,mov,'LineWidth',2);
            axis off
            H.Position = [loc1(1) loc1(2)-0.45 loc2(3) loc2(4)];
            xlim(firstlims);
            maxlist(count) = max(mov);
            minlist(count) = min(mov);

            plt = shrinkFigureToContent(plt);
            plots(count) = plt;
        end
    end
    %adjust ylims, just use the ones from headbobs
    for i = 1:length(plots)
        plots(i).Children(1).YLim = [min(minlist) max(maxlist)];
        plots(i).Children(2).YLim = meylim;
    end
    % make tiled plots and put them in ppt
    layout = 0:totplots:length(plots);
    for i = layout
        if i ~= layout(end)
            fig = tileFigures(plots(i+1:i+totplots),[3 3],0,[0,0]);
        else
            fig = tileFigures(plots(i+1:end),[3 3],0,[0,0]);
        end
        fig.Position = [107 108 1640 933];
        loc = fig.Children(1).Position;
        locb = fig.Children(end).Position;
        rc_exportfigpptx(Presentation,fig,[1,1]);
    end
%%
    
close all
end
