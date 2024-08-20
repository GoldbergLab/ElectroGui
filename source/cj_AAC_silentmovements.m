% script to identify silent files, segment movements within them, and make
% onset aligned histograms and rasters 
clear
close all

dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};
specylim = [0 8000];
clim = [12.0000, 24.5000];
bplot = false;
afs = 5000;
pad = 0.5; %seconds before and after movement
amp_thresh = 20;%for sound

for i = 32:length(names)
    dbase = load([dbase_dir '\' names{i}]);
    dbase = dbase.dbase;
    path = dbase.PathName;
    chan = names{i}(strfind(names{1},'chan')+4:strfind(names{1},'chan')+5);
    chan = strrep(chan,'_','');
    birdID = names{i}(6:9); %hard coded, trusts stereotyped name format
    lc = strfind(names{i},'_');
    date = names{i}(lc(1)+1:lc(2)-1);

    fs = dbase.Fs;
    %smoothwin for amp
    smoothwin = 2.5e-3; % ms
    smoothwin = round(smoothwin*fs);
    %smoothwin for move
    smoothwin_move = 60;
    smoothwin_move = round(smoothwin_move/1000*afs);
    
    % Define the high pass filter cutoff frequency for SOUND
    Fcutoff = [400  8000]; 
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (fs/2);
    % Design the filter using fir1
    N = 50; % Order of the filter
    b = fir1(N, Wcutoff);

    %get file names
    soundfiles = {dbase.SoundFiles.name};
    soundfiles = natsort(soundfiles);
    zfiles = dir([path '\*chan18.*']);
    xfiles = dir([path '\*chan19.*']);
    yfiles = dir([path '\*chan20.*']);
    zfiles = {zfiles.name};
    zfiles = natsort(zfiles);
    xfiles = {xfiles.name};
    xfiles = natsort(xfiles);
    yfiles = {yfiles.name};
    yfiles = natsort(yfiles);
    %get dnums for files 
    for k = 1:length(soundfiles)
        uind = strfind(soundfiles{k},'_');
        dnum{k} = soundfiles{k}(uind(1)+2:uind(2)-1);
    end
    %get ind of ephys
    e_ind = [];
    for k = 1:length(dbase.EventSources)
        if strrep(dbase.EventSources{k}(end-1:end),' ','') == num2str(chan) & size(dbase.EventTimes{k},1) ~=1 & strcmp(dbase.EventDetectors{k},'Spikes_AA')
            e_ind = k;  
        end
    end
    %find sorted files
    sortedfiles = [];
    spks = dbase.EventTimes{e_ind};
    sels = dbase.EventIsSelected{e_ind};
    j = 0;
    for k = 1:length(spks)
        ispks = spks{1,k};
        isels = sels{1,k};
        usels = sels{2,k};
        isels = ~or(~isels,~usels);
        if ~isempty(ispks)
            selspks = ispks(find(isels));
            if ~isempty(selspks)
                j = j+1;
                sortedfiles{1,j} = dnum{k};
                sortedfiles{2,j} = k;
                sortedspks{j} = spks{2,k};
            end
        end
    end
    sortf = [sortedfiles{2,:}];

    % if dbase has been run thru cj_dbaseAAC_addmovementmeans, get means
    % and kmeans threshold here
    xmean = dbase.accmeans.xmov;
    ymean = dbase.accmeans.ymov;
    zmean = dbase.accmeans.zmov;
    move_thresh = dbase.accmeans.threshold*2;
    %segment constraints
    min_duration = 0.1*afs;
    min_int = 0.25*afs;
    prev_below_samples = 0.5*afs;

    %pick files to look thru for silent files and movements 
    firstsort = min(sortf);
    lastsort = max(sortf);
    numsort = length(sortf);
    range = lastsort-firstsort;
    if range<1000
        ifile = firstsort:lastsort;
    elseif range<300
        ifile = max([1 firstsort-100]):min([lastsort+100 length(soundfiles)]);
    else
        ifile = [sortf(1):sortf(1)+499 sortf(end)-499:sortf(end)];
    end
    ifile = sort(ifile);
    %identify silent files
    silentfiles = [];
    needsort = [];
    count = 0;
    for k = 1:length(ifile)
        disp(['File ' num2str(k) ' of ' num2str(length(ifile))])

        S = cj_txtread_datonly([path '\' soundfiles{ifile(k)}]);
        %electro gui filter
        %[S,~] = egf_BandPass860to8600(S,fs);
        S = filtfilt(b,1,S);
        %S = wdenoise(S,'ThresholdRule','Soft');
        tsound = linspace(0,length(S)/fs,length(S));
        amp = 10*log10(S.^2+eps);
        %amp = smooth(amp,smoothwin);
        amp = medfilt1(amp,500,'truncate');
        amp = amp-min(amp(smoothwin:length(amp)-smoothwin));
        amp(find(amp<0))=0;
        %find amplitude threshold crossings
        [amponsets,~] = cj_find_threshold_crossings(amp,amp_thresh,0.05/fs,0);
        if length(amponsets)<3
            silentfiles = [silentfiles ifile(k)];
            %display(silentfiles)
            % get threshed movements as RC
            movex = cj_txtread_datonly([path '\' xfiles{ifile(k)}]);
            movey = cj_txtread_datonly([path '\' yfiles{ifile(k)}]);
            movez = cj_txtread_datonly([path '\' zfiles{ifile(k)}]);
            movecom = [movex-xmean,movey-ymean,movez-zmean];
            yeetus = [1:1000:(length(movecom)-1000) length(movecom)];
            movecom = detrend(movecom,'linear',yeetus);
            movecom = sqrt(sum(movecom.^2,2));
            movecom = smooth(movecom.^2,smoothwin_move);
            movecom = sqrt(movecom);

            %identify movement onsets
            [onsets,offsets] = cj_find_threshold_crossings(movecom,move_thresh,min_duration,prev_below_samples);
            sorted_moves = [];
            % get spikes if sorted, otherwise make list of files needed to
            % be sorted
            if isempty(find(sortf==ifile(k)))
                needsort = [needsort ifile(k)];
            else
                filespks = sortedspks{find(sortf == ifile(k))};
                sorted_moves = [sorted_moves ifile(k)];
                for u = 1:length(onsets)
                    xlims = [onsets(u)-pad*afs onsets(u)+pad*afs];
                    %exclude movements for which the analysis window is
                    %cutoff by file beginning or end
                    if xlims(1)<0 || xlims(2) > length(movecom)
                        continue
                    else
                        count = count+1;
                        durs(count) = (offsets(u)-onsets(u))/fs;
                        moverast{1,count} = (filespks-onsets(u))/fs;%onset aligned
                        moverast{2,count} = (filespks-offsets(u))/fs;%offset aligned
                    end
                end
            end
           
            if bplot
                [SS,F,t] = specgram(S, 512, fs, 256,floor(0.75*256));
                ndx = find((F>=specylim(1)) & (F<=specylim(2)));
                p= 2*log(abs(SS(ndx,:))+eps)+20;
                f = linspace(specylim(1),specylim(2),size(p,1));

                H = figure;
                H1 = subplot(311);
                imagesc(linspace(tsound(1),tsound(end),size(p,2)),f,p);
                set(H1,'YDir','normal');
                c = colormap(H1,'parula');
                c(1,:) = [0,0,0];
                colormap(H1,c);
                set(H1,'CLim',clim)
                loc1 = H1.Position;
                xlim([0 20])
                title(soundfiles{ifile(k)})
                ylabel('Frequency (Hz)')
    
                H2 = subplot(312);
                plot(tsound,amp);
                ylim([0 80])
                xlim([0 20])
                ylabel('Sound Amplitude (dB)')
                box off
                H2.Color = 'none';

                H3 = subplot(313);
                tmov = linspace(0,length(movecom)/afs,length(movecom));
                plot(tmov,movecom)
                ylim([0 move_thresh+move_thresh*8])
                line([0 20],[move_thresh move_thresh],'Color','k','LineStyle','--')
                yl = ylim;
                ylabel('Movement')
                for z = 1:length(onsets)
                    line([onsets(z)/afs onsets(z)/afs],[move_thresh yl(2)],'Color','r')
                end

                xlim([0 20])
                box off
                H3.Color= 'none';

                %resize, link x, and scroll only fx
                H.Position= [154         197        1609         779];
                linkaxes(H.Children,'x')
                set(H, 'WindowScrollWheelFcn', @scrollonlyx);

                %play video button
                hButton = uicontrol('Style', 'pushbutton', 'String', 'Play Video', ...
                    'Position', [H.Position(3)-100, H.Position(4)-40, 80, 30], ...
                    'Callback', @(~,~) playVid(soundfiles{ifile(k)},H1.XLim,[onsets;offsets]'/afs));
    
            end
        end
    end
    dbase.needsort_formove = needsort;
    if count>10
        %store raster
        dbase.movementraster = moverast;        
        %make raster for this dbase
        binsz = 10;
        edges = -pad:binsz/1000:pad;
        ras = figure;
        H1 = subplot(211);
        title('Silent movement onset aligned')
        set(H1,'LineWidth',2)
        set(H1,'Box','On')
        set(H1,'Color','none')
        for k = 1:count
            s = moverast{1,k};
            s = s(s>-pad&s<pad);
            for j = 1:length(s)
                line([s(j)',s(j)'],[k-1,k],'color','k','LineWidth',2)
            end
            [dist(k,:),~] = histcounts(s,edges);
        end
        line([0,0],[0,count],'color','b','LineWidth',2)
        ylim([0 count])
        xticks([]);
        xlim([-pad pad])
        yticks([0 count])
        ylabel('Movements')
        set(gca,'FontSize',12)
        %ifr
        H2 = subplot(212);
        ifr = (smooth(sum(dist)/(binsz/1000),5))/size(dist,1);
        stairs(edges(1:end-1),zscore(ifr),'LineWidth',2,'Color','k');
        line([0,0],[ras.Children(1).YLim(1),ras.Children(1).YLim(2)],'color','b','LineWidth',2)
        box off
        set(gca,'LineWidth',2)
        set(gca,'FontSize',12)
        set(gca,'Color','none')
        ylabel('z-scored FR')
        xlabel('Time (s)')
    end
    save([dbase_dir '\' names{i}],'dbase')
    clear moverast dbase 
end
function playVid(n,xl,markerTimes)
    birdID = n(1:4);
    tt = strfind(n,'_');
    date = n(tt(2)+1:strfind(n,'T')-1);
    year = date(1:4);
    month = date(5:6);
    day = date(7:8);
    basepath = 'Y:\ht452\AAc_analysis';
    birdpath = [basepath '\' birdID '\videos\' month day year];
    if birdID == '0010'
         birdpath = [basepath '\' birdID '\videos\' month day year '\Alligned_videos_new'];
         if ~isfolder(birdpath)
            birdpath = [basepath '\' birdID '\videos\' month day year '\Alligned_videos'];
         end 
    end
    fnum = n(tt(1)+2:tt(2)-1);
    hnum = fnum(end-3:end);

    vid = dir([birdpath '\*' hnum '*.mp4']);
    if ~isempty(vid)
        vidName = vid.name;
        fullPath = [birdpath '\' vidName];
    else
        error('Video not found')
    end
    smarkTimes = cell(size(markerTimes));
    for i = 1:numel(markerTimes)
        seconds = mod(markerTimes(i),60);
        milliseconds = mod(markerTimes(i),1)*1000;
        smarkTimes{i} = sprintf('00:00:%02d,%03d',floor(seconds),round(milliseconds));
    end
    if size(markerTimes,1)>0
        for i = 1:size(markerTimes,1)
            subtitles{i} = struct('startTime',smarkTimes{i,1},'endTime',smarkTimes{i,2},'text','Move');
        end
    else
        % create a blank subtitle file if no segments exist
        smarkTimes{1,1} = '00:00:00,000';
        smarkTimes{1,2} = '00:00:00,001';
        subtitles{1} = struct('startTime',smarkTimes{1,1},'endTime',smarkTimes{1,2},'text',' ');
    end
    % specify directory to save temporary subtitle files
    srtPath = 'C:\Users\GLab\Documents\SRTbudgiefiles\subtitle.srt';
    fid = fopen(srtPath,'w');
    for i = 1:numel(subtitles)
        fprintf(fid, '%d\n', i);
        fprintf(fid, '%s --> %s\n', subtitles{i}.startTime, subtitles{i}.endTime);
        fprintf(fid, '%s\n', subtitles{i}.text);
        fprintf(fid, '\n'); % Add an empty line to separate entries
    end
    fclose(fid);
    % prepare for video playback
    % runtime = java.lang.Runtime.getRuntime();
    vPath = '"C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"';
    vlcCommand = [vPath, ' "', fullPath, '" --start-time=', num2str(xl(1)), ' --stop-time=', num2str(xl(2)), ' --play-and-exit --loop --sub-file=',srtPath,' &'];
    % process = runtime.exec(vlcCommand);
    system(vlcCommand);
end
function scrollonlyx(fig, event)
    % Get the current axis limits
    currentLimits = axis;
    
    % Get the cursor position in data coordinates
    cursorPoint = get(gca, 'CurrentPoint');
    cursorX = cursorPoint(1, 1);
    
    % Calculate the width of the current x-axis range
    xWidth = currentLimits(2) - currentLimits(1);
    
    % Define the zoom factor
    zoomFactor = 0.1; % Adjust as needed
    
    % Check if scrolling up or down
    if event.VerticalScrollCount > 0
        % Zoom out by expanding the x-axis range
        newXlim = currentLimits(1) - (cursorX - currentLimits(1)) * zoomFactor;
        newYlim = currentLimits(2) + (currentLimits(2) - cursorX) * zoomFactor;
    else
        % Zoom in by shrinking the x-axis range
        newXlim = currentLimits(1) + (cursorX - currentLimits(1)) * zoomFactor;
        newYlim = currentLimits(2) - (currentLimits(2) - cursorX) * zoomFactor;
    end
    
    % Update the x-axis limits and keep y-axis limits fixed
    axis([newXlim, newYlim, currentLimits(3:4)]);
end