%% script to analyze Julie's pupil/eyelid data
clear; close all
ceredir = 'Y:\jc2824\For Caleb\Pupil Project\Webcam - 2 cere\';
pupdir = 'Y:\jc2824\For Caleb\Pupil Project\NanEye\';

specylim = [100 8000];
% load in cere tracking data and do HB detect
cerefiles = dir([ceredir '*.csv']);


% whisperseg
params = egg_WhisperSeg('params');
params.Values{3} = 0;
params.Values{4} = 0.0025;
params.Values{5} = 0.01;
params.Values{6} = 0.01;
params.Values{7} = 0.02;
params.Values{8} = 0.001;
params.Values{9} = 3;
params.Values{10} = '20240907_ZhileiEphysWarble20kFinetune3'; % which model
%params.Values{10} = 'cj_0572_run1'; % which model
params.Values{11} = 'true'; % whether or not to get labels

scount.v = 0; scount.vin = 0; scount.vout = 0; % this may be a little insane but whatevs
scount.e = 0; scount.ein = 0; scount.eout = 0;
scount.b = 0; scount.bin = 0; scount.bout = 0;
scount.x = 0; scount.xin = 0; scount.xout = 0;
scount.h = 0; scount.hin = 0; scount.hout = 0;
scount.g = 0; scount.gin = 0; scount.gout = 0;

%pdfFile = fullfile(ceredir)
count = 0;count2 = 0;
for i = 1:numel(cerefiles)

    M = readtable([ceredir cerefiles(i).name]);
    pulsenum = cerefiles(i).name(6:9);
    disp(pulsenum)
    if pulsenum=='0435'; continue; end
    %% load in cere position and track y-axis movement for potential
    % headbobs (to be curated later)
    Bird1Y = M.DLC_resnet50_CereForNaneyeNov14shuffle1_250000_1;
    Bird2Y = M.DLC_resnet50_CereForNaneyeNov14shuffle1_250000_4;
    % calculate exact frame rate, should be ~30, ASSUMES ALL FILES 20s
    framerate(i) = length(Bird1Y)/20;

    % look for potential HB
    OUT1= detect_headbobs_keypoints(Bird1Y,framerate(i));
    OUT2= detect_headbobs_keypoints(Bird2Y,framerate(i));


    %% load in audio
    audfile = dir([ceredir '*' pulsenum '*.wav']);
    [aud,fs] = audioread([ceredir audfile.name]);
    aud_bone = aud(:,3);
    % Define filter cutoff frequency for SOUND
    Fcutoff = [100  8000];
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (fs/2);
    % Design the filter using fir1
    N = 280; % Order of the filter
    b = fir1(N, Wcutoff);
    S = filtfilt(b,1,aud_bone); % audio has three channels, not sure why
    % make spectrogram
    [SS,F,t] = specgram(S, 512*2, fs, 256*2,floor(0.85*256)*2);% channel 3 is the bone mic
    ndx = find((F>=specylim(1)) & (F<=specylim(2)));
    p= 2*log(abs(SS(ndx,:))+eps)+20;
    f = linspace(specylim(1),specylim(2),size(p,1));

    %% load in pupil  ASSUMES ALL FILES 20s
    eyefile = dir([pupdir 'pulse' pulsenum '*naneye*.csv']);
    M1 = readmatrix([pupdir eyefile.name]);
    M1(:,1) = [];
    % calculate pupil area and eyelid distance using Julie's code
    % with a tweak to Julie's code, which is just replace low confidence
    % times with NaN because they likely represent an occlusion of the
    % pupil from the eyelids 
    target_value = 0.8;
    [I,J] = find(M1<target_value);
    for j = 1:numel(I)
        M1(I(j),J(j)-2:J(j)-1) = nan; % Now just make ALL low confidence keypoints NaN
    end
    

%     for clipstart = 1:length(M1(1,:))
%         if M1(1,clipstart) == 0
%             M1(1,clipstart-2) = M1(2,clipstart-2);
%             M1(1,clipstart-1) = M1(2,clipstart-1);
%             M1(1,clipstart) = 1;
%         end
%     end
% 
%     for j = 1:length(M1)
%         for k = 1:length(M1(1,:))
%             if M1(j,k) == 0
%                 M1(j,(k-2)) = M1((j-1),(k-2));
%                 M1(j,(k-1)) = M1((j-1),(k-1));
%             end
%         end
%     end
    EyelidDistance = sqrt((M1(:,25)-M1(:,28)).^2 + ((M1(:,26)-M1(:,29)).^2));
    Ellipse.Distance.N_S = sqrt((M1(:,1)-M1(:,7)).^2 + ((M1(:,2)-M1(:,8)).^2));
    Ellipse.Distance.E_W = sqrt((M1(:,4)-M1(:,10)).^2 + ((M1(:,5)-M1(:,11)).^2));
    Ellipse.Area = pi.*(Ellipse.Distance.E_W/2).^2;
    %Ellipse.Area = filloutliers(Ellipse.Area,'previous');
    % calculate frame rate of this naneye video
    naneyeFS = size(M1,1)/20;
    %% run whisperseg on each file
    [segs{i}, filesylls{i}] = egg_WhisperSeg(S,[],fs,[],params);

    %     %% plot entire file
    H = figure; H.Position = [1          49        1920        1075/2];
    sub1 = subplot(411);
    imagesc(t,f,p);
    set(sub1,'YDir','normal'); xticks([]); box off;
    c = colormap(sub1,'jet'); yticks(specylim); yticklabels({specylim/1000})
    c(1,:) = [0,0,0]; sub1.FontSize= 14;
    colormap(sub1,c); sub1.CLim = [12 24]; sub1.XAxis.Color = 'none';
    ylabel('Freq. (kHz)')
    hold on
    for j = 1:size(segs{i})
        line([segs{i}(j,1)/fs segs{i}(j,2)/fs],[specylim(1) specylim(1)],'LineWidth',3,'Color','r')
    end

    sub2 = subplot(412); sub2.Position(2) = sub1.Position(2)-sub1.Position(4)-0.02;
    plot(linspace(0,t(end),size(M1,1)),Ellipse.Area,'Color',rgb('tomato'),'LineWidth',2);
    sub2.Color = 'none'; sub2.XAxis.Color = 'none';
    ylabel('Pupil Area')

    sub3 = subplot(413); sub3.Position(2) = sub2.Position(2)-sub2.Position(4)-0.02;
    plot(linspace(0,t(end),size(M1,1)),EyelidDistance,'Color',rgb('DarkOrange'),'LineWidth',2);
    sub3.Color = 'none'; sub3.XAxis.Color = 'none';
    ylabel('Eyelid Dist.')

    sub4 = subplot(414); sub4.Position(2) = sub3.Position(2)-sub3.Position(4)-0.02;
    plot(linspace(0,t(end),size(Bird1Y,1)),OUT1.hb_sig,'Color',rgb('SeaGreen'),'LineWidth',2);
    hold on
    plot(linspace(0,t(end),size(Bird2Y,1)),OUT2.hb_sig,'Color',rgb('blue'),'LineWidth',2);
    sub4.Color = 'none'; box off; ylabel('HB signal')
    yl = ylim;
    % now plot lines for each potential HB
    subfac = range(yl)*.05;
    liney = yl(2)-subfac;
    for j = 1:size(OUT1.onsets,1)
        line([OUT1.onsets(j)/framerate(i) OUT1.offsets(j)/framerate(i)],[yl(2) yl(2)],'LineWidth',3,'Color',rgb('SeaGreen'))
    end
    for j = 1:size(OUT2.onsets,1)
        line([OUT2.onsets(j)/framerate(i) OUT2.offsets(j)/framerate(i)],[liney liney],'LineWidth',3,'Color',rgb('blue'))
    end

    linkaxes(H.Children,'x'); zoom xon; ylim manual;
    [H.Children.FontSize] = deal(14);
    %close


    %% label all segs as in or out of HB
    inoutpbird = zeros(1,size(segs{i},1));
    inoutobird = zeros(1,size(segs{i},1));
    for bird= {OUT1,OUT2}
        for j = 1:numel(bird{1}.onsets)
            ons = bird{1}.onsets(j)/framerate(i);
            offs = bird{1}.offsets(j)/framerate(i);
            for k = 1:size(segs{i},1)
                segspan = (segs{i}(k,1):segs{i}(k,2))/fs;
                inhb = segspan>ons & segspan<offs;
                if any(inhb) && isequal(bird{1},OUT1)
                    inoutpbird(k) = 1;
                elseif any(inhb) && isequal(bird{1},OUT2)
                    inoutobird(k) = 1;                            
                end
            end
            
        end
    end

    %% analysis
    teye = linspace(0,t(end),size(M1,1));
    thb = linspace(0,t(end),size(Bird1Y,1));
    tsound = linspace(0,t(end),numel(t));
    pad = 3;
    binsz = 0.05;
    edges = -pad:binsz:pad;
    for bird = {OUT1, OUT2}
        for j = 1:numel(bird{1}.onsets)
            ons = bird{1}.onsets(j);
            offs = bird{1}.offsets(j);
            if isequal(bird{1},OUT1)
                count = count+1;
                relpupA.onset_aligned(count,:) = meaninterp2(Ellipse.Area,teye-ons/framerate(i),edges);
                relpupA.offset_aligned(count,:) = meaninterp(Ellipse.Area,teye-offs/framerate(i),edges);
                releye.onset_aligned(count,:) = meaninterp(EyelidDistance,teye-ons/framerate(i),edges);
                releye.offset_aligned(count,:) = meaninterp(EyelidDistance,teye-offs/framerate(i),edges);
                relsound.onset_aligned{count}= S(tsound-ons>edges(1)&tsound-ons<edges(end));
                relsound.offset_aligned{count}= S(tsound-offs>edges(1)&tsound-offs<edges(end));

                hb_sig1.onset_aligned{count} = bird{1}.hb_sig(thb-ons>edges(1)&thb-ons<edges(end));
                hb_sig1.offset_aligned{count} = bird{1}.hb_sig(thb-offs>edges(1)&thb-offs<edges(end));
            else
                count2 = count2+1;
                OBrelpupA.onset_aligned(count2,:) = meaninterp(Ellipse.Area,teye-ons/framerate(i),edges);
                OBrelpupA.offset_aligned(count2,:) = meaninterp(Ellipse.Area,teye-offs/framerate(i),edges);
                OBreleye.onset_aligned(count2,:) = meaninterp(EyelidDistance,teye-ons/framerate(i),edges);
                OBreleye.offset_aligned(count2,:) = meaninterp(EyelidDistance,teye-offs/framerate(i),edges);
                OBrelsound.onset_aligned{count2}= S(tsound-ons>edges(1)&tsound-ons<edges(end));
                OBrelsound.offset_aligned{count2}= S(tsound-offs>edges(1)&tsound-offs<edges(end));

                OBhb_sig1.onset_aligned{count2} = bird{1}.hb_sig(thb-ons>edges(1)&thb-ons<edges(end));
                OBhb_sig1.offset_aligned{count2} = bird{1}.hb_sig(thb-offs>edges(1)&thb-offs<edges(end));
            end
        end
    end
    

    
    % now make whisperseg aligned PA and ELD traces, also do inside/outisde
    % HB for the pupil bird's vocalizations
    pad = 1;
    edges = -pad:binsz:pad;
    for syll = {'v','e','b','h','x'}
        numsyll = sum([filesylls{i}{:}] == syll{1});
        inds = find([filesylls{i}{:}] == syll{1});
        sylltimes = segs{i}(inds,:);
        iop = inoutpbird(inds);
        ioo = inoutobird(inds);
        for j = 1:numsyll
            scount.(syll{1})= scount.(syll{1})+1;
            onset = sylltimes(j,1);
            srelpupA.(syll{1}).onset(scount.(syll{1}),:) = meaninterp(Ellipse.Area,teye-onset/fs,edges);
            srelEL.(syll{1}).onset(scount.(syll{1}),:) = meaninterp(EyelidDistance,teye-onset/fs,edges);
            if iop(j)==1
                scount.([syll{1} 'in']) = scount.([syll{1} 'in'])+1;
                srelpupA.(syll{1}).in_onset(scount.([syll{1} 'in']),:) = srelpupA.(syll{1}).onset(scount.(syll{1}),:);
                srelEL.(syll{1}).in_onset(scount.([syll{1} 'in']),:) = srelEL.(syll{1}).onset(scount.(syll{1}),:);
            else
                scount.([syll{1} 'out']) = scount.([syll{1} 'out'])+1;
                srelpupA.(syll{1}).out_onset(scount.([syll{1} 'out']),:) = srelpupA.(syll{1}).onset(scount.(syll{1}),:);
                srelEL.(syll{1}).out_onset(scount.([syll{1} 'out']),:) = srelEL.(syll{1}).onset(scount.(syll{1}),:);
            end
        end
    end
    
    % now split by in or out of HB
    

    %% save data
    %print(H,['X:\Budgie\AAC_figures\Fig2\' namedbase 'phase_examples.pdf'],'-dpdf','-painters')

    % save data for analysis 
    datmat.filename = cerefiles(i).name;
    datmat.othbird.hb_sig = OUT2.hb_sig;
    datmat.pupbird.PA = Ellipse.Area;
    datmat.pupbird.eyelid = EyelidDistance;
    datmat.pupbird.hb_sig = OUT1.hb_sig;
    datmat.audio = S; datmat.Fs = fs;
    datmat.othbird.hbtimes.onsets = OUT2.onsets;
    datmat.othbird.hbtimes.offsets = OUT2.offsets;
    datmat.othbird.hbtimes.inds = OUT2.headbob_inds;
    datmat.pupbird.hbtimes.onsets = OUT1.onsets;
    datmat.pupbird.hbtimes.offsets = OUT1.offsets;
    datmat.pupbird.hbtimes.inds = OUT1.headbob_inds;
    datmat.segs = segs{i}; datmat.labs = filesylls{i};
    %save(['X:\Julie\pupilbird\' cerefiles(i).name(1:end-4) '.mat'],"datmat")

end

%% avg pupil area
yeet = OBreleye.offset_aligned;
hbedges = -3:binsz:3;
x = hbedges(1:end-1);

m  = mean(yeet, 1, 'omitnan');
sd = std(yeet,1,'omitnan');
n = sum(~isnan(yeet),1);
sem = sd ./ sqrt(n);
alpha = 0.05;
tval = tinv(1-alpha/2,n-1);
ci=tval.*sem;

figure; hold on

% shaded std
fill([x fliplr(x)], ...
    [m+ci fliplr(m-ci)], ...
    [0.6 0.6 0.6], ...
    'FaceAlpha',0.3, ...
    'EdgeColor','none');

% mean line
plot(x, m, 'k', 'LineWidth', 2);

box off
hold on; yl = ylim;
line([0 0],ylim,'Color','b','LineStyle','--'); set(gca,'YLim',yl);
xlabel('Time rel. to partner HB offset')
ylabel('Eyelid Dist. (pixels)')
set(gca,'FontSize',16); set(gca,'LineWidth',2)
title('Mean Eyelid Dist., shading 95% CI')

%% avg pupil area aligned to whispersegs
H = tiledlayout(1,5);
yeetus = 0;
for syll = {'v','e','h','b','x'}
yeetus = yeetus+1;
yeet = srelEL.(syll{1}).onset;
num = size(yeet,1);
edges = -1:binsz:1;
x = edges(1:end-1);

m  = mean(yeet, 1, 'omitnan');
sd = std(yeet,1,'omitnan');
n = sum(~isnan(yeet),1);
sem = sd ./ sqrt(n);
alpha = 0.05;
tval = tinv(1-alpha/2,n-1);
ci=tval.*sem;

nexttile; hold on

% shaded CI
fill([x fliplr(x)], ...
    [m+ci fliplr(m-ci)], ...
    [0.6 0.6 0.6], ...
    'FaceAlpha',0.3, ...
    'EdgeColor','none');

% mean line
plot(x, m, 'k', 'LineWidth', 2);

box off
ylim([45 60])
hold on; yl = ylim;
line([0 0],ylim,'Color','b','LineStyle','--'); set(gca,'YLim',yl);

if yeetus==1
ylabel('Eyelid Dist. (pixels)')
xlabel('Time rel. to syllable onset')
else
    yticks([])
end

set(gca,'FontSize',16); set(gca,'LineWidth',2)
title([num2str(syll{1}) ' ,n = ' num2str(num)])
end


%% helper functions
function [isig] = meaninterp(sig,t,edges)
for i = 1:length(edges)-1
    isig(i) = mean(sig(t>=edges(i)&t<=edges(i+1)));
end

end
function isig = meaninterp2(sig, t, edges)
sig = sig(:); t = t(:);
nb = numel(edges) - 1;
isig = nan(nb,1);

for i = 1:nb
    if i < nb
        m = (t >= edges(i)) & (t < edges(i+1));
    else
        m = (t >= edges(i)) & (t <= edges(i+1)); % include last edge
    end
    isig(i) = mean(sig(m), 'omitnan');
end
end



