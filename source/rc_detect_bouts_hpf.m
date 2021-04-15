function dbase = rc_detect_bouts_hpf(fold,graphic)
if isempty(dir([fold filesep 'bouts\analysis.mat']))
    if length(dir(fold))<3
        return
    end
    if isempty(dir([fold filesep 'bouts']))
        mkdir([fold filesep 'bouts']);
    end
    
    dbase = [];
    dbase.PathName = fold;
    
    % CHANGE HERE FOR WAVE FILES
    %                         files = dir([dbase.PathName filesep '*.dat']);
    %                         dbase.SoundLoader = 'AA_daq';
    files = dir([dbase.PathName filesep '*.wav']);
    if isempty(files)
        return
    end
    dbase.SoundLoader = 'WaveRead';
    
    dbase.EventSources = {};
    dbase.EventFunctions = {};
    dbase.EventDetectors = {};
    dbase.EventThresholds = zeros(0,length(files));
    dbase.EventTimes = {};
    dbase.EventIsSelected = {};
    
    for fl = 1:length(files)
        dbase.Properties.Names{fl} = {};
        dbase.Properties.Values{fl} = {};
        dbase.Properties.Types{fl} = {};
    end
    
    dbase.SoundFiles = files;
    dbase.ChannelFiles = {};
    dbase.ChannelLoader = {};
    dbase.Fs = 44100;
    dbase.AnalysisState.SourceList = {'(None)','Sound'}';
    dbase.AnalysisState.EventList = {'(None)',};
    dbase.AnalysisState.CurrentFile = 0;
    dbase.AnalysisState.EventWhichPlot = [0];
    dbase.AnalysisState.EventLims = repmat([1.000000000000000e-003 0.00300000000000],1,1);
    dbase.FileLength = zeros(1,length(files));
    dbase.Times = zeros(1,length(files));
    
    if graphic==1
        fig = figure;
        subplot('position',[.05 0.35 0.9 0.6]);
        text(0,3,[fold],'fontsize',14,'interpreter','none','horizontalalignment','center');
        hold on
        filesanalyzed = text(0,2,['Files analyzed: 0 of ' num2str(length(files))],'fontsize',14,'interpreter','none','horizontalalignment','center');
        progbar = imagesc([-1 1],[.4 .6],zeros(1,length(files)));
        timeelapsed = text(0,-1,'Time elapsed: 0 sec','fontsize',14,'interpreter','none','horizontalalignment','center');
        boutssaved = text(0,-2,'Bouts saved: 0','fontsize',14,'interpreter','none','horizontalalignment','center');
        xlim([-1 1])
        ylim([-3 3]);
        axis off
        drawnow
    else
        disp([fold]);
    end
    starttime = now;
    
    temp.files = [];
    temp.bouts = zeros(0,2);
    temp.syll = {};
    temp.titl = {};
    temp.sel = {};
    temp.time = [];
    temp.len = [];
    temp.ev = {};
    
    if ~isempty(dir([fold filesep 'analysis_incomplete.mat']))
        load([fold filesep 'analysis_incomplete.mat']);
    end
    for fl = dbase.AnalysisState.CurrentFile+1:length(files)
        dbase.AnalysisState.CurrentFile = fl;
        mt = dir([dbase.PathName '\bouts\extr' num2str(fl,'%05.f') '_*']);
        for i = 1:length(mt)
            delete([dbase.PathName '\bouts\' mt(i).name]);
        end
        
        % CHANGE HERE FOR WAVE FILES
        try
            [a fs] = audioread([fold filesep files(fl).name]);
            % 010617 RC fix for don's gui.
            if size(a,2)>1
                a = a(:,1);
            end
            % 010617 end fix
        catch
            disp('fail');
            a = [];
        end
        
        if ~isempty(a)
            if strcmp(files(fl).name(1:2),'rc')
                nums = sscanf(files(fl).name,'rc_%f_%f.wav');
                dt = nums(2);
                dbase.Times(fl) = datenum(dt);
            else
                nums = sscanf(files(fl).name,'%f_%f_%f_%f_%f_%f_%f.wav');
                % 121815 RC: quick fix for filenames containning 'lesion' e.g. '2900lesion_...''
                if length(nums)<2
                   nums = sscanf(files(fl).name,'%f%*[a-z]_%f_%f_%f_%f_%f_%f.wav');
                end   
                % 121815 end
                % 010617 RC: fix for don's gui.
                if length(nums)<2
                   nums = sscanf(files(fl).name,'%fa%f_%f_%f_%f_%f_%f.wav');
                   if length(nums)>1
                    num_milliseconds = nums(5)*3600000+nums(6)*60000+fix(nums(7)*1000);
                    nums(2) = num_milliseconds;
                   end
                end             
                % 010617 end
                if length(nums)<2
                   nums = sscanf(files(fl).name,'Song %f_%f_%f_%f_%f_%f_%f.wav');
                end
                if length(nums)<2
                   nums = sscanf(files(fl).name,'song %f_%f_%f_%f_%f_%f_%f.wav');
                end   
                if length(nums)<2
                   nums = sscanf(files(fl).name,'%2s%f_%f_%f_%f_%f_%f_%f.wav');
                end 
                yr = datevec(files(fl).date);
                yr = yr(1);
                dv = datevec(nums(2)-fix(nums(2)));
                dt = [yr(1) nums(3:4)' dv(4:6)];
                dbase.Times(fl) = datenum(dt);
            end
            
            dbase.FileLength(fl) = (files(fl).bytes-44)/2;
            dateandtime = dbase.Times(fl);
            
            % Remove clicks
            f = find(a==0);
            a(f) = randn(size(f))*std(a);
            f = 1;
            while ~isempty(f)
                df = [0; diff(diff(a)); 0];
                f = find(abs(df)>0.01);
                a(f) = (a(f-1)+a(f+1))/2;
            end
            
            %High Pass Filter (added by jg on 062613) 
            %filteredsound = hanninghighpass(sound, cutoff, order, fs);
            %(edited by rc on 121417 to save orignial sound)
            a_original = a;
            a = hanninghighpass(a, 2000, 80, 44100);
            
            % Segment
            b = fir1(200,[1000 4000]/(fs/2));
            snd = filtfilt(b, 1, a);
            smooth_window = 0.0025;
            wind = round(smooth_window*fs);
            amp = smooth(10*log10(snd.^2+eps),wind);
            amp = amp-prctile(amp(wind:length(amp)-wind),5);
            amp(find(amp<0))=0;
            th = eg_AutoThreshold(amp);
            params.Values = {'7', '7','7','0'};
            params.IsSplit = 0;
            segs = DA_segmenter(amp,fs,th,params);
            sel = select_bouts(a,fs,amp,th,segs);
            dbase.SegmentThresholds(fl) = th;
            dbase.SegmentTimes{fl} = segs;
            dbase.SegmentTitles{fl} = cell(1,size(segs,1));
            dbase.SegmentIsSelected{fl} = sel;
            
            syll = segs(find(sel==1),:);
            if ~isempty(syll)
                intr = find(syll(2:end,1)-syll(1:end-1,2)>.5*fs);
                ons = [1; intr+1];
                offs = [intr; size(syll,1)];
                for c = 1:length(ons)
                    temp.files(end+1) = fl;
                    temp.bouts(end+1,:) = [max(1,round(syll(ons(c),1)-0.5*fs)) min(length(a),round(syll(offs(c),2)+0.5*fs))];
                    f = find(segs(:,1)>temp.bouts(end,1) & segs(:,2)<temp.bouts(end,2));
                    temp.syll{end+1} = segs(f,:)-temp.bouts(end,1);
                    temp.titl{end+1} = cell(1,size(segs,1));
                    temp.sel{end+1} = sel(f);
                    
                    rec.Fs = fs;
                    rec.Data = a_original(temp.bouts(end,1):temp.bouts(end,2)); %rc edit
                    rec.Time = dateandtime + temp.bouts(end,1)/fs/(24*60*60);
                    temp.time(end+1) = rec.Time;
                    temp.len(end+1) = length(rec.Data);
                    
                    param.Values = {'7','7','0'};
                    %aa = egf_Extract_inspirations(rec.Data,rec.Fs,[]);
                    %temp.ev{end+1} = egg_DA_segmenter_old(aa,rec.Fs,10,param);
                    temp.ev{end+1} = zeros(0,2);
                    
                    rec.Properties.Names = {};
                    rec.Properties.Types = [];
                    rec.Properties.Values = {};
                    iss = 0;
                    while iss==0
                        try
                            save([dbase.PathName '\bouts\extr' num2str(fl,'%05.f') '_' num2str(c,'%03.f') '.mat'],'rec');
                            iss = 1;
                        catch
                            disp('fail');
                            pause(1);
                        end
                    end
                    
                    if graphic==1
                        figure(fig);
                        subplot('position',[.05 0.05 0.9 0.3]);
                        ylim([1000 7000]);
                        [p f t] = quick_spectrogram(gca,rec.Data,rec.Fs);
                        imagesc(t,f,p);
                        set(gca,'ydir','normal');
                        axis tight
                        axis off
                        set(gca,'clim',[prctile(p(1:prod(size(p))),50) prctile(p(1:prod(size(p))),95)*1.2]);
                        drawnow
                    end
                end
            end
            
            iss = 0;
            while iss==0
                try
                    save([fold filesep 'analysis_incomplete.mat'],'dbase','temp');
                    iss = 1;
                catch
                    disp('fail');
                    pause(1);
                end
            end
            
            if graphic==1
                set(filesanalyzed,'string',['Files analyzed: ' num2str(fl) ' of ' num2str(length(files))]);
                set(progbar,'cdata',[ones(1,fl) zeros(1,length(files)-fl)]);
                set(timeelapsed,'string',['Time elapsed: ' num2str((now-starttime)*(24*60*60)) ' sec']);
                set(boutssaved,'string',['Bouts saved: ' num2str(length(temp.files))]);
                drawnow
            else
                disp(['Files analyzed: ' num2str(fl) ' of ' num2str(length(files))]);
                disp(['Bouts saved: ' num2str(length(temp.files))]);
            end
        end
    end
    
    dbase.AnalysisState.CurrentFile = 1;
    iss = 0;
    while iss==0
        try
            save([fold filesep 'analysis.mat'],'dbase');
            delete([fold filesep 'analysis_incomplete.mat']);
            iss = 1;
        catch
            disp('fail');
            pause(1);
        end
    end
    
    
    % Bouts dbase
    thres = dbase.SegmentThresholds;
    
    dbase = [];
    dbase.PathName = [fold filesep 'bouts'];
    dbase.Times = temp.time;
    dbase.FileLength = temp.len;
    dbase.SoundFiles = dir([dbase.PathName filesep 'extr*.mat']);
    dbase.ChannelFiles = {};
    dbase.SoundLoader = 'Surgery_Rig_daq';
    dbase.ChannelLoader = {};
    dbase.Fs = fs;
    dbase.SegmentThresholds = thres(temp.files);
    dbase.SegmentTimes = temp.syll;
    dbase.SegmentTitles = temp.titl;
    
    for jj = 1:length(temp.sel)
        temp.sel{jj}(1:end) = 1;
    end
    dbase.SegmentIsSelected = temp.sel;
    
    dbase.EventSources = {'Sound'};
    dbase.EventFunctions = {'Extract_inspirations'};
    dbase.EventDetectors = {'ThresholdCrossings'};
    dbase.EventThresholds = 0.1*ones(1,length(dbase.Times));
    
    param.Values = {'7','7','0'};
    for fl = 1:length(temp.files)
        ev = temp.ev{fl};
        dbase.EventTimes{1}{1,fl} = ev(:,1)';
        dbase.EventIsSelected{1}{1,fl} = ones(size(ev(:,1)));
        dbase.EventTimes{1}{2,fl} = ev(:,2)';
        dbase.EventIsSelected{1}{2,fl} = ones(size(ev(:,2)));
    end
    
    for fl = 1:length(temp.files)
        dbase.Properties.Names{fl} = {};
        dbase.Properties.Values{fl} = {};
        dbase.Properties.Types{fl} = {};
    end
    
    dbase.AnalysisState.SourceList = {'(None)','Sound','Sound - Extract_inspirations - Zenith','Sound - Extract_inspirations - Nadir'}';
    dbase.AnalysisState.EventList = {'(None)','Sound - Extract_inspirations - Zenith','Sound - Extract_inspirations - Nadir'};
    dbase.AnalysisState.CurrentFile = 1;
    dbase.AnalysisState.EventWhichPlot = [0 0 0];
    dbase.AnalysisState.EventLims = repmat([1.000000000000000e-003 0.00300000000000],3,1);
    
    dbase = rc_parse_segments_sc(dbase);
    
    iss = 0;
    while iss==0
        try
            save([fold filesep 'bouts' filesep 'analysis.mat'],'dbase');
            iss = 1;
        catch
            disp('fail');
            pause(1);
        end
    end
else
    load([fold filesep 'bouts\analysis.mat']);
    dbase = dbase;
end







function sel = select_bouts(a,fs,ampl,thres,segs)

seg = segs/fs*1000;
sel = zeros(1,size(seg,1));
if size(seg,1)<2
    return
end

dur = seg(:,2)-seg(:,1);

wind = round(0.001*fs);
b = fir1(200,[1000 10000]/(fs/2));
snd = filtfilt(b, 1, a);
snd = 10*log10(smooth(snd.^2,wind));
mn = median(abs(diff(snd(1:wind:end))));
gd = sel;
loud = sel;
for c = 1:size(seg,1)
    amp = snd(segs(c,1):segs(c,2));
    loud(c) = median(amp);
    df = diff(amp(1:wind:end));
    df = abs(df)/mn;
    if mean(df)/dur(c)<.075
        gd(c) = 1;
    end
end
f = find(diff(diff(loud))<-40) + 1;
gd(f) = 0;

pause = zeros(size(seg,1),1);
f = find(gd==1);
ps = seg(f(2:end),1)-seg(f(1:end-1),2);
if ~isempty(ps)
    ps = min([[ps(1); ps] [ps; ps(end)]],[],2);
    pause(f) = ps;
    
    f = find(dur./(pause+eps)>.20 & gd'==1);
    
    if ~isempty(f)
        intr = find(seg(f(2:end),1)-seg(f(1:end-1),2)>500);
        ons = [1; intr+1];
        offs = [intr; length(f)];
    else
        ons = [];
        offs = [];
    end
    
    for c = 1:length(ons)
        numsyll = offs(c)-ons(c)+1;
        boutlength = seg(f(offs(c)),2)-seg(f(ons(c)),1);
        sylldur = sum(seg(f(ons(c):offs(c)),2)-seg(f(ons(c):offs(c)),1));
        % RC edit 05/20/18 old param: 2,300,.3,90,15
        indx_end = round(segs(f(offs(c)),2));
        indx_half = round(0.5*(indx_end+segs(f(ons(c)),1)));
        if numsyll>3 && boutlength>500 && sylldur/boutlength>.3 ... 
                && prctile(ampl(indx_half:indx_end),90) - prctile(ampl(indx_half:indx_end),10) > 30  % range:[15,30] PP
            sel(f(ons(c)):f(offs(c))) = 1;
        end
    end
    
    sel(find(gd==0)) = 0;
end



function threshold = eg_AutoThreshold(amp)

if mean(amp)<0
    amp = -amp;
    isneg=1;
else
    isneg=0;
end
if range(amp)==0
    threshold = inf;
    return;
end

try
    % Code from Aaron Andalman
    [noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp);
    if(noiseEst>soundEst)
        disc = max(amp)+eps;
    else
        %Compute the optimal classifier between the two gaussians...
        p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
        p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
        p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
        disc = roots(p);
        disc = disc(find(disc>noiseEst & disc<soundEst));
        if(length(disc)==0)
            disc = max(amp)+eps;
        else
            disc = disc(1);
            disc = soundEst - 0.5 * (soundEst - disc);
        end
    end
    threshold = disc;
    
    if ~isreal(threshold)
        threshold = max(amp)*0.8; % RC edit 121417 was 1.1
    else
        threshold = threshold * 1.1;
    end
catch
    threshold = max(amp)*0.8; % RC edit 121417
end

if isneg
    threshold = -threshold;
end



% by Aaron Andalman
function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow)

%Run EM algorithm on mixture of two gaussian model:

%set initial conditions
l = length(audioLogPow);
len = 1/l;
m = sort(audioLogPow);
uNoise = median(m(fix(1:length(m)/2)));
uSound = median(m(fix(length(m)/2:length(m))));
sdNoise = 5;
sdSound = 20;

%compute estimated log likelihood given these initial conditions...
prob = zeros(2,l);
prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
[estProb, class] = max(prob);
warning off
logEstLike = sum(log(estProb)) * len;
warning on
logOldEstLike = -Inf;

%maximize using Estimation Maximization
while(abs(logEstLike-logOldEstLike) > .005)
    logOldEstLike = logEstLike;
    
    %Which samples are noise and which are sound.
    nndx = find(class==1);
    sndx = find(class==2);
    
    %Maximize based on this classification.
    uNoise = mean(audioLogPow(nndx));
    sdNoise = std(audioLogPow(nndx));
    if ~isempty(sndx)
        uSound = mean(audioLogPow(sndx));
        sdSound = std(audioLogPow(sndx));
    else
        uSound = max(audioLogPow);
        sdSound = 0;
    end
    
    %Given new parameters, recompute log likelihood.
    prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
    prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
    [estProb, class] = max(prob);
    logEstLike = sum(log(estProb+eps)) * len;
end


function segs = DA_segmenter(a,fs,th,params)
% ElectroGui segmenter

if isstr(a) & strcmp(a,'params')
    segs.Names = {'Minimum duration (ms)','Minimum interval (ms)','Mininum duration for splitting (ms)','Minimum interval for splitting (ms)'};
    segs.Values = {'7', '7','7','0'};
    return
end

min_dur = str2num(params.Values{1})/1000;
min_stop = str2num(params.Values{2})/1000;

if params.IsSplit == 1
    min_dur = str2num(params.Values{3})/1000;
    min_stop = str2num(params.Values{4})/1000;
end

if th < 0
    a = -a;
    th = -th;
end
th = th-min(a);
a = a-min(a);

% Find threshold crossing points
f = [];
a = [0; a; 0];
f(:,1) = find(a(1:end-1)<th & a(2:end)>=th)-1;
f(:,2) = find(a(1:end-1)>=th & a(2:end)<th)-1;
a = a(2:end-1);

% Eliminate VERY short syllables
i = find(f(:,2)-f(:,1)>min_dur/2*fs);
f = f(i,:);

% Extend syllables to a lower threshold
if params.IsSplit == 0
    warning off
    mn = mean(a(find(a<th)));
    st = std(a(find(a<th)));
    warning on
    thnew = min([th mn+2*st]);
    indx_compare_1 = find(a<thnew);
    indx_compare_2 = find(a<th/2);

    % for c=1:size(f,1)
    %     f(c,1)=max([1; find(indx_compare_1<f(c,1))]);
    %     f(c,2)=min([length(a); f(c,2)+find(indx_compare_2>f(c,2))]);
    % end
    % f2 = f;
    for c=1:size(f,1)
        
        % f(c,1)=max([1; find(a(1:f(c,1)-1)<thnew)]);
        % a1 = f(c,1);
        % f(c,2)=min([length(a); f(c,2)+find(a(f(c,2)+1:end)<th/2)]);
        % b1 = f(c,2);
        
        
        % indxf1 = vertcat(1,find(indx_compare_1<f2(c,1)));
        % f2(c,1)= max([1; indx_compare_1(indxf1(end))]);
        % a2 = f2(c,1);
        % indxf2 = vertcat(find(indx_compare_2>f2(c,2)),length(indx_compare_2));
        
        % f2(c,2)= min([length(a); indx_compare_2(indxf2(1))]);
        % b2 = f2(c,2);

        % if a1~=a2 | b1~=b2
        %     a1
        % end

        indxf1 = vertcat(1,find(indx_compare_1<f(c,1)));
        f(c,1)= max([1; indx_compare_1(indxf1(end))]);
        indxf2 = vertcat(find(indx_compare_2>f(c,2)),length(indx_compare_2));
        f(c,2)= min([length(a); indx_compare_2(indxf2(1))]);



    end
end

% Eliminate short syllables
i = find(f(:,2)-f(:,1)>min_dur*fs);
f = f(i,:);

if isempty(f)
    segs = zeros(0,2);
    return
end

% Eliminate short intervals
if size(f,1)>1
    i = [find(f(2:end,1)-f(1:end-1,2) > min_stop*fs); length(f)];
    f = [f([1; i(1:end-1)+1],1) f(i,2)];
end

segs = f;