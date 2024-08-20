clear
close all
dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};
specylim = [0 8000];
clim = [10.0000, 24.5000];
afs = 5000;

binsz = 10;
edges = 0:binsz/1000:20;
for i = 1:length(names)
    dbase = load([dbase_dir '\' names{i}]);
    dbase = dbase.dbase;
    path = dbase.PathName;
    chan = names{i}(strfind(names{1},'chan')+4:strfind(names{1},'chan')+5);
    chan = strrep(chan,'_','');
    birdID = names{i}(6:9); %hard coded, trusts stereotyped name format
    lc = strfind(names{i},'_');
    date = names{i}(lc(1)+1:lc(2)-1);

    fs = dbase.Fs;
    % Define the high pass filter cutoff frequency for SOUND
    Fcutoff = [400  8000]; 
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (fs/2);
    % Design the filter using fir1
    N = 50; % Order of the filter
    b = fir1(N, Wcutoff);

    %define filter for ephys
    Fcutoff = [400 9000];
    eb = fir1(80,Fcutoff/(fs/2));

    %define filter for mov data
    Fcutoff = 100;
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (afs/2);
    % Design the filter using fir1
    N = 80; % Order of the filter
    ab = fir1(N, Wcutoff,'high');
    
    xmean = dbase.accmeans.xmov;
    ymean = dbase.accmeans.ymov;
    zmean = dbase.accmeans.zmov;
%     %define filter for amp data
%     Fcutoff = 100;
%     % Normalize the cutoff frequency
%     Wcutoff = Fcutoff / (fs/2);
%     % Design the filter using fir1
%     N = 80; % Order of the filter
%     sb = fir1(N, Wcutoff,'high');

    smoothwin = 10e-3; % ms
    smoothwin = round(smoothwin*fs);
    smoothwin_move = 60;% ms
    smoothwin_move = round(smoothwin_move/1000*afs);
    kt = 0:0.01:20-0.01;
    sigma = 0.01;
    %kernel for ifr
    gaussian_kernel = @(kt, kt_i, sigma) (1 / (sigma * sqrt(2 * pi))) * exp(-(kt - kt_i).^2 / (2 * sigma^2));

    soundfiles = {dbase.SoundFiles.name};
    zfiles = dir([path '\*chan18.*']);
    xfiles = dir([path '\*chan19.*']);
    yfiles = dir([path '\*chan20.*']);
    zfiles = {zfiles.name};
    xfiles = {xfiles.name};
    yfiles = {yfiles.name};
    efiles = dir([path '\*chan' num2str(chan) '.*']);
    efiles = {efiles.name};

    % determine which files to look at (SORTED FILES). need to identify silent files,
    % warble files (make sure it is correct identity, need to use
    % cj_identity voc 

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
    all_mi_sou_spks = [];
    all_mi_mov_spks = [];
    allamp = [];
    allmov = [];
    allifr = [];
    for k = 1:length(sortf)
        disp(['File ' num2str(k) ' of ' num2str(length(sortf))])
        % get movement
        movex = cj_txtread_datonly([path '\' xfiles{sortf(k)}]);
        movey = cj_txtread_datonly([path '\' yfiles{sortf(k)}]);
        movez = cj_txtread_datonly([path '\' zfiles{sortf(k)}]);
        movecom = [movex-xmean,movey-ymean,movez-zmean];
        yeetus = [1:1000:(length(movecom)-1000) length(movecom)];
        movecom = detrend(movecom,'linear',yeetus);
        movecom = sqrt(sum(movecom.^2,2));
        movecom = smooth(movecom.^2,smoothwin_move);
        movecom = sqrt(movecom);
        if length(movecom)>20*afs
            movecom = movecom(1:20*afs);
        end
        tmov = linspace(0,length(movecom)/afs,length(movecom));
        ss = 0.01;
        kernel_size = round(6 * ss / (tmov(2) - tmov(1))); % 6 sigma rule for kernel size
        x = linspace(-3*ss, 3*ss, kernel_size);
        agaussian_kernel = (1 / (ss * sqrt(2 * pi))) * exp(-x.^2 / (2 * ss^2));
        agaussian_kernel = agaussian_kernel/sum(agaussian_kernel);
        movecom = conv(movecom,agaussian_kernel,'same');
        movecom = interp1(tmov, movecom, linspace(0,20,2000), 'linear');

        % get ephys
        filespks = sortedspks{find(sortf==sortf(k))};
        ephys = egl_HC_ad([path '\' efiles{sortf(k)}],1);
        if length(ephys)>20*fs
            ephys = ephys(1:20*fs);
        end
        ephys = filtfilt(eb,1,ephys);
        filespks = filespks/fs;
%         % calculate ISI as egf_ISI does
%         ifr = zeros(size(ephys));
%         f = floor(filespks*fs);
%         for c=1:length(f)-1
%             ifr(f(c):f(c+1))= fs/(f(c+1)-f(c));
%         end
        
        % kernel density estimation
        ifr = zeros(size(kt));
        for q = 1:length(filespks)
            ifr = ifr+gaussian_kernel(kt,filespks(q),sigma);
        end

        % get sound and calculate amp as calculated in egui
        S = egl_HC_ad([path '\' soundfiles{sortf(k)}],1);
        if length(S)>fs*20
            S = S(1:fs*20);
        end
        S = filtfilt(b, 1, S);
        S = wdenoise(S,'ThresholdRule','Soft');
        tsound=linspace(0,length(S)/fs,length(S)); 
        amp = smooth(10*log10(S.^2+eps),smoothwin);
        amp = amp-min(amp(smoothwin:length(amp)-smoothwin));
        amp(find(amp<0))=0;
        %amp = filtfilt(sb,1,amp);
        amp = conv(amp,agaussian_kernel,'same');  %smooth & downsamp with gauss kern
        downsamplefac = round(length(amp)/length(kt));
        amp = interp1(tsound, amp, linspace(0,20,2000), 'linear');

        %normalize all traces
        movecom = normalize(movecom,'zscore');
        amp = normalize(amp,'zscore');
        ifr = normalize(ifr,'zscore');

%         %measure mutual info & cov
%         knn = 25;
%         mi_amp_spks = mi_cont_cont(amp,ifr,knn);
%         mi_mov_spks = mi_cont_cont(movecom,ifr,knn);
%         all_mi_sou_spks(k) = mi_amp_spks;
%         all_mi_mov_spks(k) = mi_mov_spks;
% 
%         cov_amp_spks = cov(amp,ifr);
%         cov_mov_spks = cov(movecom,ifr);
%         allcovsou{k} = cov_amp_spks;
%         allcovmov{k} = cov_mov_spks;

%         % rolling window MI calculation
%         dfs = 100;
%         winsize = 20;%10 10ms bins for a 100ms window size
%         percent_overlap = 50;
%         [souMIvec,souti]= cj_rolling_window_mi(amp,ifr,winsize,percent_overlap,dfs);
%         [movMIvec,movti]= cj_rolling_window_mi(movecom,ifr,winsize,percent_overlap,dfs);

%         % get data glm ready 
%         allamp = [allamp amp];
%         allmov = [allmov movecom];
%         allifr = [allifr ifr];

%         % measure cross-correlations on normalized data
%         N = length(movecom);
%         %maxlag = 0.05*fs;
%         [movcorr,movlags] = xcorr(movecom,ifr,'normalized');
%         [soucorr, soulags] = xcorr(amp,ifr,'normalized');

        % plot everything
        H = figure;
        numsubs = 6;
        %spectrogram
        H1 = subplot(numsubs,1,1);
        [SS,F,t] = specgram(S, 512, fs, 256,floor(0.75*256));
        ndx = find((F>=specylim(1)) & (F<=specylim(2)));
        p= 2*log(abs(SS(ndx,:))+eps)+20;
        f = linspace(specylim(1),specylim(2),size(p,1));
        imagesc(linspace(tsound(1),tsound(end),size(p,2)),f,p);
        set(H1,'YDir','normal');
        c = colormap(H1,'parula');
        c(1,:) = [0,0,0];
        colormap(H1,c);
        set(H1,'CLim',clim)
        loc1 = H1.Position;
        xlim([0 20])
        yticks('')
        xticks('')
        %amp
        H2 = subplot(numsubs,1,2);
        %plot(kt,amp);
        stairs(kt,amp,'LineWidth',2,'Color','m');
        H2.Color = 'none';
        box off
        H2.Position = [loc1(1) loc1(2) loc1(3) loc1(4)];
        xticks('')
        H2.YAxis.Color = 'w';
        H2.YAxis.TickLabelColor = 'k';
        ylabel('Sound Amplitude')
        H2.YLabel.Color = 'k';

        %detectedspks
        H3 = subplot(numsubs,1,3);
        for q = 1:length(filespks)
             line([filespks(q) filespks(q)],[-1 1],'color','g','LineWidth',2)
        end
        xlim([0 20])
        axis off
        H3.Position = [loc1(1) loc1(2)-loc1(4)/8 loc1(3) loc1(4)/6];
        xticks('')


        %ephys ifr
        H4 = subplot(numsubs,1,4);
        %plot(kt,ifr,'k');
        stairs(kt,ifr,'LineWidth',2,'Color','g')
        % if using egui IFR
        %stairs(linspace(0,length(ifr)/fs,length(ifr)),ifr,'LineWidth',2,'Color','g')
        xlim([0 20])
        box off
        H4.Position = [loc1(1) loc1(2)-loc1(4)-0.02 loc1(3) loc1(4)];
        ylabel('IFR (Hz)')

        H4.Color = 'none';
        xticks('')

        %mov
        H5 = subplot(numsubs,1,5);
        %plot(kt,movecom);
        stairs(kt,movecom,'LineWidth',2,'Color','k')
        box off
        H5.Position = [loc1(1) loc1(2)-loc1(4)*2-0.05 loc1(3) loc1(4)];
        ylabel('Combined Movement (V)')
        H5.Color = 'none';
       
        set(H, 'WindowScrollWheelFcn', @cj_scrollonlyx);


%         % plot mutual information
%         H6 = subplot(numsubs,1,6);
%         scatter([1 2],[mi_amp_spks mi_mov_spks],'filled','MarkerFaceColor','k','SizeData',100);
%         xlim([0 3])
%         H6.Position = [loc1(1) loc1(2)-loc1(4)*6-0.1 loc1(3)/8 loc1(4)*4];
%         ylim([0 0.2])
%         ylabel('Mutual Information with IFR')
%         xticks([1 2]);
%         H6.XTickLabel = {'sound' 'move'};
%         H6.Color = 'none';
        linkaxes(H.Children,'x')

%         % plot corr
%         H6 = subplot(numsubs,1,6);
%         plot(movlags,movcorr)
%         hold on
%         plot(soulags,soucorr)
%         legend movcorr soucorr
%         H6.Color = 'none';
%         box off

%         H6 = subplot(numsubs,1,6);
%         stairs(souti,souMIvec,'LineWidth',2,'Color','m')
%         hold on
%         stairs(movti,movMIvec,'LineWidth',2,'Color','k')
%         box off
%         H6.Color = 'none';
%         H6.Position = [loc1(1) loc1(2)-loc1(4)*3-0.1 loc1(3) loc1(4)];
%         ylabel('Mutual Information')
%         legend sound movement

        %linkaxes(H.Children,'x')
        H.Position= [154         197        1609         779];
    end

    %% fit glm with both mov and 
    %dat = [allamp' allmov' allifr'];
    %cv = cvpartition(length(dat),'HoldOut',0.2); % 80% training 20 test
    %traindat = dat(training(cv),:);
    %testdat = dat(test(cv),:);
    %model = fitglm([traindat(:,1) traindat(:,2)],traindat(:,3));
    %disp(model);
    % 

%     % fit glm for each mov  and sou 
%     dat = [allamp' allifr'];
%     cv = cvpartition(length(dat),'HoldOut',0.2);
%     traindat = dat(training(cv),:);
%     testdat = dat(test(cv),:);
% 
% 
%     model = fitglm(traindat(:,size(dat,2)-1),traindat(:,end));
%     y_test = testdat(:,end);
%     y_pred = predict(model,testdat(:,1:size(dat,2)-1));
%     scatter(y_test,y_pred);
%     xlabel('Actual');
%     ylabel('Predicted');
%     refline(1,0);
%     mse= mean((y_test-y_pred).^2);
%%
    %mutual info stuff
%     alldbasemi{i,1} = all_mi_sou_spks;
%     alldbasemi{i,2} = all_mi_mov_spks;
%     alldbasecov{i,1} = allcovsou;
%     alldbasecov{i,2} = allcovmov;
    %save('X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs\dbase_mutual_info\alldbase_mutual_info.mat','alldbasemi')
    %save('X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs\dbase_mutual_info\alldbase_cov.mat','alldbasecov')

%     D = figure;
%     edges = 0:0.01:0.5;
%     nsou = histc(alldbasemi{i,1},edges);
%     nmov = histc(alldbasemi{i,2},edges);
%     stairs(edges,nsou,'LineWidth',2,'Color','k')
%     hold on
%     stairs(edges,nmov,'LineWidth',2,'Color','b')
%     legend sound movement
%     title(names{i})
%     xlabel('Mutual Information')
%     ylabel('Files')
%     disp('yeet')

%    allscoredists_figs{i} = D;
    %save('X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs\dbase_mutual_info\mutual_info_dists.mat','allscoredists_figs')
end





%%
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