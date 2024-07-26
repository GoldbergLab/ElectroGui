% script to identify silent files, segment movements within them, and make
% onset aligned histograms and rasters 
clear
close all

dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};
specylim = [0 8000];
clim = [12.0000, 24.5000];
bplot = 1;
afs = 5000;

for i = 22:length(names)
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
    smoothwin = 100e-3; % ms
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
    move_thresh = dbase.accmeans.threshold;

    %pick files to look thru for silent files and movements 
    firstsort = min(sortf);
    lastsort = max(sortf);
    range = lastsort-firstsort;
    if range>500
        ifile = firstsort:lastsort;
    else
        ifile = max([1 firstsort-100]):min([lastsort+100 length(soundfiles)]);
    end
    if length(ifile)>1000
        ifile = datasample(ifile,1000,'Replace',false);
    end
    ifile = sort(ifile);
    %identify silent files
    silentfiles = [];
    for k = 1:length(ifile)
        disp(['File ' num2str(k) ' of ' num2str(length(ifile))])
        S = egl_HC_ad([path '\' soundfiles{ifile(k)}],1);
        S = filtfilt(b,1,S);
        S = wdenoise(S,'ThresholdRule','Soft');
        tsound = linspace(0,length(S)/fs,length(S));
        amp = smooth(10*log10(S.^2+eps),smoothwin);
        amp = amp-min(amp(smoothwin:length(amp)-smoothwin));
        amp(find(amp<0))=0;
        amp(floor(19.99*fs):end) = mean(amp);
        amp(1:floor(0.01*fs)) = mean(amp);
        if max(amp)<20
            silentfiles = [silentfiles ifile(k)];
            display(silentfiles)
            % get threshed movements as RC
            movex = egl_HC_ad([path '\' xfiles{ifile(k)}],1);
            movey = egl_HC_ad([path '\' yfiles{ifile(k)}],1);
            movez = egl_HC_ad([path '\' zfiles{ifile(k)}],1);
            movecom = [movex-xmean,movey-ymean,movez-zmean];
            yeetus = [1:1000:(length(movecom)-1000) length(movecom)];
            movecom = detrend(movecom,'linear',yeetus);
            movecom = sqrt(sum(movecom.^2,2));
            movecom = smooth(movecom.^2,smoothwin_move);
            movecom = sqrt(movecom);

            
           
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
    
                H2 = subplot(312);
                plot(tsound,amp);
                xlim([0 20])
                box off
                H2.Color = 'none';

                H3 = subplot(313);
                tmov = linspace(0,length(movecom)/afs,length(movecom));
                plot(tmov,movecom)
                xlim([0 20])
                box off
                H3.Color= 'none';
    
                H.Position= [154         197        1609         779];
                linkaxes(H.Children,'x')
                set(H, 'WindowScrollWheelFcn', @scrollonlyx);
    
            end
        end
    end
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