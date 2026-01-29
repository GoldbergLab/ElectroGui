%% script to analyze Julie's pupil/eyelid data
clear; close all
ceredir = 'Y:\jc2824\For Caleb\Pupil Project\Webcam - 2 cere\';
pupdir = 'Y:\jc2824\For Caleb\Pupil Project\NanEye\';

specylim = [100 8000];
% load in cere tracking data and do HB detect
cerefiles = dir([ceredir '*.csv']);

for i = 43:numel(cerefiles)
    M = readtable([ceredir cerefiles(i).name]);
    pulsenum = cerefiles(i).name(6:9);
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
    % Define filter cutoff frequency for SOUND
    Fcutoff = [100  8000];
    % Normalize the cutoff frequency
    Wcutoff = Fcutoff / (fs/2);
    % Design the filter using fir1
    N = 280; % Order of the filter
    b = fir1(N, Wcutoff);
    S = filtfilt(b,1,aud); % audio has three channels, not sure why
    % make spectrogram
    [SS,F,t] = specgram(S(:,2), 512*2, fs, 256*2,floor(0.85*256)*2);
    ndx = find((F>=specylim(1)) & (F<=specylim(2)));
    p= 2*log(abs(SS(ndx,:))+eps)+20;
    f = linspace(specylim(1),specylim(2),size(p,1));

    %% load in pupil  ASSUMES ALL FILES 20s
    eyefile = dir([pupdir 'pulse' pulsenum '*naneye*.csv']);
    M1 = readmatrix([pupdir eyefile.name]);
    M1(:,1) = [];
    % calculate pupil area and eyelid distance using Julie's code
    target_value = 0.8;
    M1(M1 < target_value) = 0;

    for clipstart = 1:length(M1(1,:))
        if M1(1,clipstart) == 0
            M1(1,clipstart-2) = M1(2,clipstart-2);
            M1(1,clipstart-1) = M1(2,clipstart-1);
            M1(1,clipstart) = 1;
        end
    end

    for j = 1:length(M1)
        for k = 1:length(M1(1,:))
            if M1(j,k) == 0
                M1(j,(k-2)) = M1((j-1),(k-2));
                M1(j,(k-1)) = M1((j-1),(k-1));
            end
        end
    end
    EyelidDistance = sqrt((M1(:,25)-M1(:,28)).^2 + ((M1(:,26)-M1(:,29)).^2));
    Ellipse.Distance.N_S = sqrt((M1(:,1)-M1(:,7)).^2 + ((M1(:,2)-M1(:,8)).^2));
    Ellipse.Distance.E_W = sqrt((M1(:,4)-M1(:,10)).^2 + ((M1(:,5)-M1(:,11)).^2));
    Ellipse.Area = pi.*(Ellipse.Distance.E_W/2).^2;
    Ellipse.Area = filloutliers(Ellipse.Area,'previous');
    % calculate frame rate of this naneye video
    naneyeFS = size(M1,1)/20;

    %% plot entire file
    H = figure; H.Position = [1          49        1920        1075];
    sub1 = subplot(411);
    imagesc(t,f,p);
    set(sub1,'YDir','normal'); xticks([]); box off;
    c = colormap(sub1,'jet'); yticks(specylim); yticklabels({specylim/1000})
    c(1,:) = [0,0,0]; sub1.FontSize= 14; 
    colormap(sub1,c); sub1.CLim = [12 24]; sub1.XAxis.Color = 'none';
    ylabel('Freq. (kHz)')

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

end