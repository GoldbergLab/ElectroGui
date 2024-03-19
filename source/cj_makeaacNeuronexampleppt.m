function cj_makeaacNeuronexampleppt(dbase,ephyschan)
    %% makes a ppt of many warble examples, headbob, and kisses
    close all
    path = dbase.PathName;
    fs = dbase.Fs;
    files = dir([path '\*chan' num2str(ephyschan) '.*']);
    files = {files.name};
    soundfiles = {dbase.SoundFiles.name};
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
        if strrep(dbase.EventSources{i}(end-1:end),' ','') == num2str(ephyschan) & size(dbase.EventTimes{i},1) ~=1
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

    %get ind of warb bool
    for i = 1:length(dbase.Properties.Names{1})
        if strcmp(dbase.Properties.Names{1}{i}, 'containsWarb')
            ind = i;
        end
    end

    %get indices of gestures
    h_ind = cj_findCellIndices(dbase.MarkerTitles,'h');
    hfiles = [h_ind{1,:}];
    k_ind = cj_findCellIndices(dbase.MarkerTitles,'k');
    kfiles = [k_ind{1,:}];
    t_ind = cj_findCellIndices(dbase.MarkerTitles,'t');
    tfiles = [t_ind{1,:}];
    %get overlapped with sorted files
    sortf = [sortedfiles{2,:}];
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
    for i = 1:length(hsfiles)
        num = hsfiles(i);
        hbs = h_ind{2,find([h_ind{1,:}]==num)};

        hbtimes = dbase.MarkerTimes{num}(hbs,:);
        markerTimes = dbase.MarkerTimes{num};
        markerTitles = dbase.MarkerTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);

        for j = 1:size(hbtimes,1)
            plt = figure;
            H = subplot(311);
            cent = floor((hbtimes(j,1)+hbtimes(j,2))/2);
            xlims = [hbtimes(j,1)-fs/2 hbtimes(j,2)+fs/2];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            % chop up the audio and ephys so we don't plot unnecessary data
            sou = sound(xlims(1):xlims(2));
            eph = ephys(xlims(1):xlims(2));
            showAudioSpectrogram(sou,fs);
            ylim([250 7500])
            yticks('')
            ylabel('')
            xticks([0 round(length(sou)/fs,2)])
            xlabel('')
            loc1 = H.Position;
            H.FontSize = 12;

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
            plot(eph,'k','LineWidth',2);
            axis off
            H.Position = [loc1(1) loc1(2)-0.275 loc2(3) loc2(4)];
            count = count +1;
            plots(count) = plt;
        end
    end
    % make tiled plots and put them in ppt
    layout = 0:6:length(plots);
    for i = layout
        if i ~= layout(end)
            fig = tileFigures(plots(i+1:i+6),[3 2],0);
        else
            fig = tileFigures(plots(i+1:end),[3 2],0);
        end
        fig.Position=[1 31 1920 1093];
        loc = fig.Children(1).Position;
        locb = fig.Children(end).Position;
        rc_exportfigpptx(Presentation,fig,[1,1]);
    end
    close all
    %% making kissing plots
    %add title page
    titleslideText = (['Kissing']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    plots = [];
    for i = 1:length(ksfiles)
        num = ksfiles(i);
        ks = k_ind{2,find([k_ind{1,:}]==num)};
        kstimes = dbase.MarkerTimes{num}(ks,:);
        markerTimes = dbase.MarkerTimes{num};
        markerTitles = dbase.MarkerTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);

        for j = 1:size(kstimes,1)
            plt = figure;
            H = subplot(311);
            cent = floor((kstimes(j,1)+kstimes(j,2))/2);
            xlims = [kstimes(j,1)-fs/2 kstimes(j,2)+fs/2];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            % chop up the audio and ephys so we don't plot unnecessary data
            sou = sound(xlims(1):xlims(2));
            eph = ephys(xlims(1):xlims(2));
            showAudioSpectrogram(sou,fs);
            ylim([250 7500])
            yticks('')
            ylabel('')
            xticks([0 round(length(sou)/fs,2)])
            xlabel('')
            loc1 = H.Position;
            H.FontSize = 12;

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
            plot(eph,'k','LineWidth',2);
            axis off
            H.Position = [loc1(1) loc1(2)-0.275 loc2(3) loc2(4)];
            count = count +1;
            plots(count) = plt;
        end
    end
    % make tiled plots and put them in ppt
    layout = 0:6:length(plots);
    for i = layout
        if i ~= layout(end)
            fig = tileFigures(plots(i+1:i+6),[3 2],0);
        else
            fig = tileFigures(plots(i+1:end),[3 2],0);
        end
        fig.Position=[1 31 1920 1093];
        loc = fig.Children(1).Position;
        locb = fig.Children(end).Position;
        rc_exportfigpptx(Presentation,fig,[1,1]);
    end

    





end
