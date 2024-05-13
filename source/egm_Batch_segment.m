function handles = egm_Batch_segment(handles)
% ElectroGui macro
% Batch syllable segmentation for faster analysis
% Uses current segmentation algorithm and parameters
% Only works for segmentation based on sound amplitude

answer = inputdlg({'File range'},'File range',1,{['1:' num2str(handles.TotalFileNumber)]});
if isempty(answer)
    return
end

filenums = eval(answer{1});
for filenum = 1:length(handles.menu_Segmenter)
    if handles.menu_Segmenter(filenum).Checked
        segmenterAlgorithmName = handles.menu_Segmenter(filenum).Label;
    end
end
x = mean(xlim(handles.axes_Sonogram));
y = mean(ylim(handles.axes_Sonogram));

for fileIdx = 1:length(filenums)
    displayProgress('Segmenting file %d of %d, fileIdx', length(filenums), round(length(filenums)/10), true);
    filenum = filenums(fileIdx);

    [handles, sound] = electro_gui('getSound', handles, [], filenum);
    [handles, amp, fs] = electro_gui('calculateAmplitude', handles, filenum);

    if handles.menu_AutoThreshold.Checked
        handles.SoundThresholds(filenum) = eg_AutoThreshold(amp);
    else
        handles.SoundThresholds(filenum) = handles.CurrentThreshold;
    end
    curr = handles.SoundThresholds(filenum);
    
    handles.SegmentTimes{filenum} = eg_runPlugin(handles.plugins.segmenters, segmenterAlgorithmName, sound, amp, fs, curr, handles.SegmenterParams);
    handles.SegmentTitles{filenum} = cell(1,size(handles.SegmentTimes{filenum},1));
    handles.SegmentSelection{filenum} = ones(1,size(handles.SegmentTimes{filenum},1));

end

msgbox(sprintf('Segmented %d files. Segmentation complete', fileIdx));

function amp = eg_CalculateAmplitude(handles)

for c = 1:length(handles.menu_Filter)
    if strcmp(get(handles.menu_Filter(c),'checked'),'on')
        h = handles.menu_Filter(c);
        set(h,'userdata',handles.FilterParams);
        alg = get(handles.menu_Filter(c),'label');
    end
end

handles.filtered_sound = eg_runPlugin(handles.plugins.filters, alg, handles.sound, handles.fs, handles.FilterParams);

wind = round(handles.SmoothWindow*handles.fs);
amp = smooth(10*log10(handles.filtered_sound.^2+eps),wind);
amp = amp-min(amp(wind:length(amp)-wind));
amp(amp<0)=0;

function threshold = eg_AutoThreshold(amp)

if mean(amp)<0
    amp = -amp;
    isneg=1;
else
    isneg=0;
end

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
    threshold = max(amp)*1.1;
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