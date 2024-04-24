function cj_makeaacNeuronexampleppt(dbase,ephyschan)
    %% makes a ppt of many warble examples, headbob, and kisses
    close all
    path = dbase.PathName;

    smoothwin = 5;
    binsz = 10;% 10ms bin for spks 
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

    savedir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs\batch_dbase_ppts\';
    savename = (['Bird ' birdID ' date ' date ' chan ' num2str(ephyschan)]);

    %add title page
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = savename;

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
    if ~isempty(C_ind)
        cfiles = [C_ind{1,:}];
        csfiles = intersect(sortf,cfiles);
        count = 0;
        pad = fs/2;
   
    for i = 1:length(csfiles)
        num = csfiles(i);
        icalls = C_ind{2,find([C_ind{1,:}]==num)};
        calltimes = dbase.SegmentTimes{num}(icalls,:);
        filespks = sortedspks{find(sortf==num)};
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
            %get event times
            xlims = [calltimes(j,1)-pad calltimes(j,2)+pad];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            durs(count) = diff(calltimes)/fs;
            %spk times in seconds
            thesespks = (filespks(filespks>xlims(1) & filespks<xlims(2)+pad))/fs;
            callrast{1,count} = (filespks-calltimes(j,1))/fs;% onset aligned
            callrast{2,count} = (filespks-calltimes(j,2))/fs;% offset aligned
            callrast{3,count} = (filespks-mean([calltimes(j,1) calltimes(j,2)]))/fs; %center aligned
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
            % detected spks
            for q = 1:length(thesespks)
                line([thesespks(q) thesespks(q)],[-0.8 -0.2],'color','m','LineWidth',2)
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
        if count>1
            meylim = median(eylims,1);
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
                    fig.Position=[107 108 1640 933];
                    rc_exportfigpptx(Presentation,fig,[1,1]);
                else 
                    if ~isempty(plots(i+1:end))
                        fig = tileFigures(plots(i+1:end),[6 2],0,[0,0]);
                        fig.Position=[107 108 1640 933];
                        rc_exportfigpptx(Presentation,fig,[1,1]);
                    end
                end
        
                %Presentation = pptAddFigure(Presentation,fig);
            end
        end
    else
        count = 0;
    end
    close all
    clear plots

    % make raster (onset aligned)
    if count >4
        smoothwin = 5;
        edges = -pad/fs:binsz/1000:pad/fs;
        ras = figure;
        subplot(211)
        title('Call onset aligned')
        set(gca,'LineWidth',2)
        set(gca,'Box','On')
        for i = 1:count
            s = callrast{1,i};
            for j = 1:length(s)
                line([s(j)',s(j)'],[i-1,i],'color','k','LineWidth',2)
            end
            hr = patch([0 durs(i) durs(i) 0],[i-1 i-1 i i],[0.4488 0.4488 1],'EdgeColor','none');
            set(hr,'FaceAlpha',0.4)
            [dist(i,:),~] = histcounts(s,edges); 
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([]);
        xlim([-pad/fs pad/fs])
        yticks([0 count])
        ylabel('Calls')
        set(gca,'FontSize',12)
        %ifr
        subplot(212)
        ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
        stairs(edges(1:end-1),ifr,'LineWidth',2,'Color','k');
        line([0,0],[0,ras.Children(1).YLim(2)],'color','b','LineWidth',2)
        box off
        set(gca,'LineWidth',2)
        set(gca,'FontSize',12)
        ylabel('FR (Hz)')
        xlabel('Time (s)')
        ras.Children(1).Position = [0.1300    0.19    0.775    0.3412];
    
        rc_exportfigpptx(Presentation,ras,[1,1]);
    end
    
    %%  get ind of warb bool and make warble plots
    warblim = 24; %limit number of warble plots
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
    for i = 1:length(dbase.Properties.Names)
        if dbase.Properties.Values{i}{ind} == 1
            warb(i) = 1;
        else
            warb(i) = 0;
        end
    end
    newwarb = intersect(find(warb),sortf);
    if length(newwarb)>warblim
        newwarb = datasample(newwarb,warblim,'Replace',false);
    end   
    for i = 1:length(newwarb)
        plt = figure;
        num = newwarb(i);
        filespks = sortedspks{find(sortf==num)};
        sound = egl_HC_ad([path '\' soundfiles{newwarb(i)}],1);
        ephys = egl_HC_ad([path '\' files{newwarb(i)}],1);

        movex = egl_HC_ad([path '\' xfiles{newwarb(i)}],1);
        movey = egl_HC_ad([path '\' yfiles{newwarb(i)}],1);
        movez = egl_HC_ad([path '\' zfiles{newwarb(i)}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);
        %movecom = sqrt((movex-mean(movex)).^2+(movey-mean(movey)).^2+(movez-mean(movez)).^2);
        %spectrogram
        H = subplot(411);
        showAudioSpectrogram(sound,fs);
        ylim([250 7500])
        yticks('')
        ylabel('')
        xticks([])
        xlabel('')
        loc1 = H.Position;
        xl1 = H.XLim;

        % plot detected spks
        H = subplot(412);
        ylim([-1 1])
        for q = 1:length(filespks)
            line([filespks(q)/fs filespks(q)/fs],[-1 1],'color','m','LineWidth',1)
        end
        axis off
        xlim(xl1)
        loc2 = H.Position;
        H.Position = [loc1(1) loc1(2)-0.03 loc2(3) loc2(4)/8];

        %ephys
        H = subplot(413);
        time = (0:length(sound)-1)*(1/fs);
        plot(time,ephys,'k')
        axis off
        eylims(i,:) = ylim;
        H.Position = [loc1(1) loc1(2)-0.19 loc1(3) loc1(4)];
        xlim(xl1);

        %accel
        H = subplot(414);
        time = (0:length(movecom)-1)*(1/afs);
        plot(time,smooth(movecom,smoothwin),'LineWidth',2)
        xlim(xl1);
        axis off
        aylims(i,:) = ylim;
        H.Position = [loc1(1) loc1(2)-0.3 loc1(3) loc1(4)];
        plt = shrinkFigureToContent(plt);
        pos = plt.Position;
        plt.Position =[0  0  pos(3)*2  pos(4)*1.5];
        warbplots(i) = plt;
        minlist(i) = min(movecom);
        maxlist(i) = max(movecom);
        
    end
    
    if length(newwarb)>1
        %adjust all plots to have median y limits
        meylim = median(eylims);
        maylim = [min(minlist) max(maxlist)];
        %maylim = median(aylims);
        for i = 1:length(warbplots)
            warbplots(i).Children(2).YLim = meylim;
            warbplots(i).Children(1).YLim = maylim;
        end
        
        % make tiled plots and put them in ppt
        totplots = 3;
        layout = 0:totplots:length(warbplots);
        for i = layout
            if i ~= layout(end)
                fig = tileFigures(warbplots(i+1:i+totplots),[1 3],0,[0,0]);
                fig.Position=[107 108 1640 933];
                rc_exportfigpptx(Presentation,fig,[1,1]);
            else 
                if ~isempty(warbplots(i+1:end))
                    fig = tileFigures(warbplots(i+1:end),[1 3],0,[0,0]);
                    fig.Position=[107 108 1640 933];
                    rc_exportfigpptx(Presentation,fig,[1,1]);
                end
            end
            %Presentation = pptAddFigure(Presentation,fig);
        end
    end
%     fig = tileFigures(warbplots(1:4),[1 4],0,[0,0],true);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%     fig = tileFigures(warbplots(5:8),[1 4],0,[0,0],true);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%     fig = tileFigures(warbplots(9:12),[1 4],0,[0,0],true);
%     rc_exportfigpptx(Presentation,fig,[1,1]);

    %% get indices of gestures
    h_ind = cj_findCellIndices(dbase.MarkerTitles,'h');
    if ~isempty(h_ind)
        hfiles = [h_ind{1,:}];
    else
        hfiles = [];
    end
    k_ind = cj_findCellIndices(dbase.MarkerTitles,'k');
    if ~isempty(k_ind)
        kfiles = [k_ind{1,:}];
    else
        kfiles = [];
    end
    t_ind = cj_findCellIndices(dbase.MarkerTitles,'t');
    if ~isempty(t_ind)
        tfiles = [t_ind{1,:}];
    else
        tfiles = [];
    end
    g_ind = cj_findCellIndices(dbase.MarkerTitles,'g');
    if ~isempty(g_ind)
        gfiles = [g_ind{1,:}];
    else 
        gfiles = [];
    end
    %get overlapped with sorted files
    hsfiles = intersect(sortf,hfiles);
    ksfiles = intersect(sortf,kfiles);
    tsfiles = intersect(sortf,tfiles);
    gsfiles = intersect(sortf,gfiles);

    %% making headbob plots
    %add title page
    titleslideText = (['headbobs']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    rearpad = 2*fs; %2 seconds before hbob
    pad = fs*2;
    binsz = 25;
    eylims = [];
    aylims = [];
    for i = 1:length(hsfiles)
        num = hsfiles(i);
        filespks = sortedspks{find(sortf==num)};
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
            xlims = [hbtimes(j,1)-pad hbtimes(j,2)+pad/2];
            if xlims(1) <0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            durs(count) = diff(hbtimes)/fs;
            %spk times in seconds
            thesespks = (filespks(filespks>xlims(1)&filespks<xlims(2)+pad))/fs;
            hbrast{1,count} = (filespks-hbtimes(j,1))/fs;%onset align
            hbrast{2,count} = (filespks-hbtimes(j,2))/fs;%offset align
            hbrast{3,count} = (filespks-mean([hbtimes(j,1) hbtimes(j,2)]))/fs;%center
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
            % detected spks
            for q = 1:length(thesespks)
                line([thesespks(q) thesespks(q)],[-0.8 -0.2],'color','m','LineWidth',2)
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
    if count >1
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
                fig.Position=[107 108 1640 933];
                rc_exportfigpptx(Presentation,fig,[1,1]);
            else 
                if ~isempty(plots(i+1:end))
                    fig = tileFigures(plots(i+1:end),[3 3],0,[0,0]);
                    fig.Position=[107 108 1640 933];
                    rc_exportfigpptx(Presentation,fig,[1,1]);
                end
            end
            %Presentation = pptAddFigure(Presentation,fig);
        end
    end
    close all
    clear plots

    % make hb raster
    if count>2
        dist = [];
        edges = -pad/fs:binsz/1000:pad/fs;
        ras = figure;
        subplot(211)
        title('Headbob onset aligned')
        set(gca,'LineWidth',2)
        box on
        for i = 1:count
            s = hbrast{1,i};
            for j = 1:length(s)
                line([s(j)',s(j)'],[i-1,i],'color','k','LineWidth',2)
            end
            %line([durs(i),durs(i)],[i-1,i],'color','r')
            hr = patch([0 durs(i) durs(i) 0],[i-1 i-1 i i],[0.4488 0.4488 1],'EdgeColor','none');
            set(hr,'FaceAlpha',0.4)
            [dist(i,:),~] = histcounts(s,edges);
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([])
        xlim([-pad/fs pad/fs])
        yticks([0 count])
        ylabel('Headbobs')
        set(gca,'FontSize',12)
        %ifr
        subplot(212)
        ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
        stairs(edges(1:end-1),ifr,'LineWidth',2,'Color','k');
        line([0,0],[0,ras.Children(1).YLim(2)],'color','b','LineWidth',2)
        box off
        set(gca,'LineWidth',2)
        set(gca,'FontSize',12)
        ylabel('FR (Hz)')
        xlabel('Time (s)')
        ras.Children(1).Position = [0.1300    0.19    0.775    0.3412];
        rc_exportfigpptx(Presentation,ras,[1,1]);
    end

    %% make tap raster
    pad = fs/2;
    dist = [];
    edges = -pad/fs:binsz/1000:pad/fs;
    count = 0;
    ras = figure;
    subplot(211)
    title('Tap onset aligned')
    set(gca,'LineWidth',2)
    box on
    for i = 1:length(tsfiles)

        num = tsfiles(i);
        filespks = sortedspks{find(sortf==num)};
        ts = t_ind{2,find([t_ind{1,:}]==num)};
        tstimes = dbase.MarkerTimes{num}(ts,:);
        for j = 1:size(tstimes,1)
            count= count+1;
            durs(count) = diff(tstimes)/fs;
            %spk times in seconds
            tsrast{1,count} = (filespks-tstimes(j,1))/fs;%onset align
            tsrast{2,count} = (filespks-tstimes(j,2))/fs;%offset align
            tsrast{3,count} = (filespks-mean([tstimes(j,1) tstimes(j,2)]))/fs;%center
            s = tsrast{1,count};
            for k = 1:length(s)
                line([s(k)',s(k)'],[count-1,count],'color','k','LineWidth',2)
            end
            hr = patch([0 durs(count) durs(count) 0],[count-1 count-1 count count],[0.4488 0.4488 1],'EdgeColor','none');
            set(hr,'FaceAlpha',0.4)
            [dist(count,:),~] = histcounts(s,edges);
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([])
        xlim([-pad/fs pad/fs])
        yticks([0 count])
        ylabel('Taps')
        set(gca,'FontSize',12)
    end
    %ifr
    subplot(212)
    ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
    stairs(edges(1:end-1),ifr,'LineWidth',2,'color','k');
    line([0,0],[0,ras.Children(1).YLim(2)],'color','b','LineWidth',2)
    box off
    set(gca,'LineWidth',2)
    set(gca,'FontSize',12)
    ylabel('FR (Hz)')
    xlabel('Time (s)')
    ras.Children(1).Position = [0.1300    0.19    0.775    0.3412];
    rc_exportfigpptx(Presentation,ras,[1,1]);

    %% making kissing plots
    %add title page
    titleslideText = (['Kissing']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    pad = fs*3;
    binsz = 50;
    maxlist = [];
    minlist = [];
    for i = 1:length(ksfiles)
        num = ksfiles(i);
        filespks = sortedspks{find(sortf==num)};
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
            durs(count) = diff(kstimes)/fs;
            % spk times in s
            thesespks = (filespks(filespks>xlims(1)&filespks<xlims(2)+pad))/fs;
            ksrast{1,count} = (filespks-kstimes(j,1))/fs;%onset align
            ksrast{2,count} = (filespks-kstimes(j,2))/fs;%offset align
            ksrast{3,count} = (filespks-mean([kstimes(j,1) kstimes(j,2)]))/fs;%center
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

            % plot segments
            H = subplot(312);
            xlim(xlims/fs)
            ylim([-2 2])
            for q = 1:size(markerTimes,1)
                if markerTimes(q,1) > xlims(1) && markerTimes(q,2) < xlims(2)
                    line([markerTimes(q,1)/fs markerTimes(q,2)/fs],[-0.08 -0.08],'color','b','LineWidth',5)
                    text((markerTimes(q,1)/fs+markerTimes(q,2)/fs)/2,0.55,markerTitles(q),'Color','blue','FontSize',14) 
                end
            end
            % detected spks
            for q = 1:length(thesespks)
                line([thesespks(q) thesespks(q)],[-0.8 -0.2],'color','m','LineWidth',2)
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
    if count >1
        for i = 1:length(plots)
            plots(i).Children(1).YLim = [min(minlist) max(maxlist)];
            plots(i).Children(2).YLim = meylim;
        end
        % make tiled plots and put them in ppt
        layout = 0:totplots:length(plots);
        for i = layout
            if i ~= layout(end)
                fig = tileFigures(plots(i+1:i+totplots),[3 3],0,[0,0]);
                fig.Position = [107 108 1640 933];
                rc_exportfigpptx(Presentation,fig,[1,1]);
            else
                if ~isempty(plots(i+1:end))
                    fig = tileFigures(plots(i+1:end),[3 3],0,[0,0]);
                    fig.Position = [107 108 1640 933];
                    rc_exportfigpptx(Presentation,fig,[1,1]);
                end
            end
        end
    end
    close all
    clear plots
    %make kiss raster
    if count > 4
        dist = [];
        edges = -pad/fs:binsz/1000:pad/fs;
        ras = figure;
        subplot(211)
        title('Kissing onset aligned')
        set(gca,'LineWidth',2)
        box on
        for i = 1:count
            s = ksrast{1,i};
            for j = 1:length(s)
                line([s(j)',s(j)'],[i-1,i],'color','k','LineWidth',2)
            end
            hr = patch([0 durs(i) durs(i) 0],[i-1 i-1 i i],[0.4488 0.4488 1],'EdgeColor','none');
            set(hr,'FaceAlpha',0.4)
            [dist(i,:),~] = histcounts(s,edges);
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([])
        xlim([-pad/fs pad/fs])
        yticks([0 count])
        ylabel('Kisses')
        set(gca,'FontSize',12)
        %ifr
        subplot(212)
        ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
        stairs(edges(1:end-1),ifr,'LineWidth',2,'Color','k');
        line([0,0],[0,ras.Children(1).YLim(2)],'color','b','LineWidth',2)
        box off
        set(gca,'LineWidth',2)
        set(gca,'FontSize',12)
        ylabel('FR (Hz)')
        xlabel('Time (s)')
        ras.Children(1).Position = [0.1300    0.19    0.775    0.3412];
        rc_exportfigpptx(Presentation,ras,[1,1]);
    end
    close all
    clear plots

    %% make general movement plots
    titleslideText = (['General Movement']);
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6);%title
    
    slideCount = Presentation.Slides.count;
    Slide1 = Presentation.Slides.AddSlide(slideCount+1,blankSlide);
    Slide1.Shapes.Title.TextFrame.TextRange.Text = titleslideText;
    count = 0;
    pad = fs*4;
    binsz = 25;
    maxlist = [];
    minlist = [];
    for i = 1:length(gsfiles)
        num = gsfiles(i);
        filespks = sortedspks{find(sortf==num)};
        gs = g_ind{2,find([g_ind{1,:}]==num)};
        gstimes = dbase.MarkerTimes{num}(gs,:);
        markerTimes = dbase.MarkerTimes{num};
        markerTitles = dbase.MarkerTitles{num};
        sound = egl_HC_ad([path '\' soundfiles{num}],1);
        ephys = egl_HC_ad([path '\' files{num}],1);
        movex = egl_HC_ad([path '\' xfiles{num}],1);
        movey = egl_HC_ad([path '\' yfiles{num}],1);
        movez = egl_HC_ad([path '\' zfiles{num}],1);
        movecom = sqrt(movex.^2+movey.^2+movez.^2);

        for j = 1:size(gstimes,1)
            count = count+1;
            plt = figure;
            H = subplot(311);

            % determine xlims
            cent = floor((gstimes(j,1)+gstimes(j,2))/2);
            xlims = [gstimes(j,1)-pad gstimes(j,2)+pad];
            if xlims(1) <0 || xlims(1) == 0
                xlims(1) = 1;
            end
            if xlims(2)>length(sound)
                xlims(2) = length(sound);
            end
            durs(count) = diff(gstimes)/fs;
            % spk times in s
            thesespks = (filespks(filespks>xlims(1)&filespks<xlims(2)+pad))/fs;
            gsrast{1,count} = (filespks-gstimes(j,1))/fs;%onset align
            gsrast{2,count} = (filespks-gstimes(j,2))/fs;%offset align
            gsrast{3,count} = (filespks-mean([gstimes(j,1) gstimes(j,2)]))/fs;%center
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

            % plot segments
            H = subplot(312);
            xlim(xlims/fs)
            ylim([-2 2])
            for q = 1:size(markerTimes,1)
                if markerTimes(q,1) > xlims(1) && markerTimes(q,2) < xlims(2)
                    line([markerTimes(q,1)/fs markerTimes(q,2)/fs],[-0.08 -0.08],'color','b','LineWidth',5)
                    text((markerTimes(q,1)/fs+markerTimes(q,2)/fs)/2,0.55,markerTitles(q),'Color','blue','FontSize',14) 
                end
            end
            % detected spks
            for q = 1:length(thesespks)
                line([thesespks(q) thesespks(q)],[-0.8 -0.2],'color','m','LineWidth',2)
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
    if count >1
        for i = 1:length(plots)
            plots(i).Children(1).YLim = [min(minlist) max(maxlist)];
            plots(i).Children(2).YLim = meylim;
        end
        % make tiled plots and put them in ppt
        layout = 0:totplots:length(plots);
        for i = layout
            if i ~= layout(end)
                fig = tileFigures(plots(i+1:i+totplots),[3 3],0,[0,0]);
                fig.Position = [107 108 1640 933];
                rc_exportfigpptx(Presentation,fig,[1,1]);
            else
                if ~isempty(plots(i+1:end))
                    fig = tileFigures(plots(i+1:end),[3 3],0,[0,0]);
                    fig.Position = [107 108 1640 933];
                    rc_exportfigpptx(Presentation,fig,[1,1]);
                end
            end
        end
    end

    close all
    clear plots
    %make gm raster
    if count > 4
        dist = [];
        edges = -pad/fs:binsz/1000:pad/fs;
        ras = figure;
        subplot(211)
        title('Movement onset aligned')
        set(gca,'LineWidth',2)
        box on
        for i = 1:count
            s = gsrast{1,i};
            for j = 1:length(s)
                line([s(j)',s(j)'],[i-1,i],'color','k','LineWidth',2)
            end
            hr = patch([0 durs(i) durs(i) 0],[i-1 i-1 i i],[0.4488 0.4488 1],'EdgeColor','none');
            set(hr,'FaceAlpha',0.4)
            [dist(i,:),~] = histcounts(s,edges);
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([])
        xlim([-pad/fs pad/fs])
        yticks([0 count])
        ylabel('Movements')
        set(gca,'FontSize',12)
        %ifr
        subplot(212)
        ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
        stairs(edges(1:end-1),ifr,'LineWidth',2,'Color','k');
        line([0,0],[0,ras.Children(1).YLim(2)],'color','b','LineWidth',2)
        box off
        set(gca,'LineWidth',2)
        set(gca,'FontSize',12)
        ylabel('FR (Hz)')
        xlabel('Time (s)')
        ras.Children(1).Position = [0.1300    0.19    0.775    0.3412];
        rc_exportfigpptx(Presentation,ras,[1,1]);
    end
    close all
    
    %% save ppt
    Presentation.SaveAs([savedir savename]);
    ppt.Quit;
    ppt.delete;
end
