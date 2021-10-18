function handles = egm_Batch_label(handles)
% ElectroGui macro
% Batch label syllables for faster analysis
% Use labels in current file to estimate syllable parameters, then
%   applies those parameters to attempt to label syllables in other files.

fileRangeString = ['1:' num2str(handles.TotalFileNumber)];

answer = inputdlg( ...
    {'File range to search for manual syllable labels', ...
     'File range to apply automatic labelling to unlabelled syllables', ...
     'List of syllable labels to include in autolabelling', ...
     'Min confidence for autolabelling (0-1)', ...
     'Min differential confidence for autolabelling (0-1)'}, ...
     'AutoLabelling Macro', 1, ...
     {fileRangeString, ...
      fileRangeString, ...
      'abcdDefgi', ...
      '0.0', ...
      '0.0'});
if isempty(answer)
    return
end

trainingFileNums = eval(answer{1});
labellingFileNums = eval(answer{2});
syllableTitleIncludeList = answer{3};
minConfidence = str2double(answer{4});
minDiffConfidence = str2double(answer{5});

for fileNum = 1:length(handles.menu_Segmenter)
    if strcmp(get(handles.menu_Segmenter(fileNum),'checked'),'on')
        alg = get(handles.menu_Segmenter(fileNum),'label');
    end
end

fftLength = 1000;

ax = handles.axes_Sonogram;
txt = text(ax, mean(xlim),mean(ylim),'Labelling... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w');
set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');

maxISI = Inf; %3000;  % Disregard ISIs larger than this.

timingNeighborhoodRadius = 5;  % Number of syllables before and after current syllable to record timing info for.

printCount = 0;

manualLabelCount = 0;

% Loop over files and automatically label unlablled syllables
for fileIdx = 1:length(labellingFileNums)
    count = fileIdx;
    fileNum = labellingFileNums(fileIdx);
    if sum(get(txt,'color')==[0 1 0])==3
        count = count-1;
        break
    end

    % Get all segment titles and times
    syllableTimes = handles.SegmentTimes{fileNum};
    syllableTitles = handles.SegmentTitles{fileNum};
    numSegments = size(syllableTitles, 2);

    % Load audio
    [snd, fs, dt, label, props] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, fullfile(handles.path_name, handles.sound_files(fileNum).name), true);
    if size(snd,2)>size(snd,1)
        snd = snd';
    end
    
    for syllableNum = 1:size(syllableTimes, 1)
        % Loop over manually lableed syllables and extract syllable prints
        syllableStart = syllableTimes(syllableNum, 1);
        syllableEnd = syllableTimes(syllableNum, 2);
        
        % Get normalized FFt of syllable
        syllableAudio = snd(syllableStart:syllableEnd);
        syllableTitle = syllableTitles{syllableNum};
        
%         unlabelledSyllableCount = unlabelledSyllableCount + 1;

        % Get entire timing neighborhood of the syllable
        neighborhoodIdx = (syllableNum - timingNeighborhoodRadius:syllableNum + timingNeighborhoodRadius)';
        prePad = sum(neighborhoodIdx < 1);
        postPad = sum(neighborhoodIdx > size(syllableTimes, 1));
        neighborhoodIdx = neighborhoodIdx(neighborhoodIdx <= size(syllableTimes, 1) & neighborhoodIdx >= 1);
        timingNeighborhood = (cat(1, nan([prePad, 2]), syllableTimes(neighborhoodIdx, :), nan([postPad, 2])) - syllableStart)';
        titleNeighborhood = cat(2, repmat({''}, [1, prePad]), syllableTitles(neighborhoodIdx), repmat({''}, [1, postPad]));

        if isempty(syllableTitle)
            syllableTitle = 'unknown';
        else
            manualLabelCount = manualLabelCount + 1;
        end
        newSyllablePrint = createSyllablePrint(timingNeighborhood, titleNeighborhood, syllableTitle, syllableAudio, fileNum, syllableNum, fftLength, maxISI);
        printCount = printCount + 1;
        collectedSyllablePrints(printCount) = newSyllablePrint;

    end
    
    set(txt,'string',['Labelled file ' num2str(trainingFileNums(fileIdx)) ' (' num2str(fileIdx) '/' num2str(length(trainingFileNums)) '). Click to quit.']);
    drawnow;
end

[clusterIdx, clusterTitles] = syllableClustering(collectedSyllablePrints);

totalAcceptedSyllableCount = 0;
totalRejectedSyllableCount = 0;
acceptedClusterTitles = {};
rejectedClusterTitles = {};
for s = 1:length(clusterIdx)
    fileNum = collectedSyllablePrints(s).fileNum;
    syllableNum = collectedSyllablePrints(s).syllableNum;
    if isempty(handles.SegmentTitles{fileNum}{syllableNum})
        if ~isnan(clusterIdx(s))
            acceptedClusterTitles(end+1) = clusterTitles(s);
            disp('labelling!');
            handles.SegmentTitles{fileNum}(syllableNum) = clusterTitles(s);
        else
            rejectedClusterTitles(end+1) = clusterTitles(s);
        end
    end
end

delete(txt);

uniqueAcceptedTitles = unique(acceptedClusterTitles)';
uniqueRejectedTitles = unique(rejectedClusterTitles)';

fprintf('AutoLabelling report:\n');
fprintf('Trained on %d labelled syllables\n', manualLabelCount);
fprintf('Found %d unlabelled syllables\n', printCount - manualLabelCount);
fprintf('   Identified and labelled %d syllables\n', length(acceptedClusterTitles))
for k = 1:length(uniqueAcceptedTitles)
    fprintf('      %s - %d\n', uniqueAcceptedTitles{k}, sum(strcmp(clusterTitles, uniqueAcceptedTitles{k})));
end
fprintf('   Rejected %d low-confidence syllabel IDs\n', length(rejectedClusterTitles))
for k = 1:length(uniqueRejectedTitles)
    fprintf('      %s - %d\n', uniqueRejectedTitles{k}, sum(strcmp(clusterTitles, uniqueRejectedTitles{k})));
end
fprintf('AutoLabelling complete.\n');


msgbox('Autolabelling complete!', 'Autolabelling complete!');
%msgbox(['Segmented ' num2str(count) ' files.'],'Segmentation complete')

function syllablePrint = createSyllablePrint(timingNeighborhood, titleNeighborhood, syllableTitle, syllableAudio, fileNum, syllableNum, fftLength, maxISI)
midPoint = floor(length(syllableAudio)/2);
audioStart = syllableAudio(1:midPoint);
audioEnd = syllableAudio(midPoint+1:end);

X = getFFT(syllableAudio, fftLength);
Xstart = getFFT(audioStart, fftLength);
Xend = getFFT(audioEnd, fftLength);

% Create new syllablePrint entry:
syllablePrint.title = syllableTitle;
syllablePrint.timingNeighborhood = timingNeighborhood;
syllablePrint.titleNeighborhood = titleNeighborhood;

a = interp1(1:length(syllableAudio), syllableAudio', (1:fftLength)*length(syllableAudio)/fftLength, 'spline');

syllablePrint.ffts = cat(2, X); %Xstart, Xend, a);
syllablePrint.fileNum = fileNum;
syllablePrint.syllableNum = syllableNum;

function discrepancy = getFFTDiscrepancy(fft, syllablePrint)
discrepancy = 0; return;
discrepancy = mean(abs(fft - syllablePrint.meanFFT)/syllablePrint.stdFFT);
%discrepancy = 1 - pdist([fft; syllablePrint.meanFFT], 'cosine');

function probabilities = getFFTMatchProbabilities(fft, syllablePrints)
discrepancies = [];
for k = 1:length(syllablePrints)
    discrepancies(k) = getFFTDiscrepancy(fft, syllablePrints(k));
end
meanDiscrepancy = mean(discrepancies);
stdDiscrepancy = std(discrepancies);
zScoreDiscrepancies = (discrepancies - meanDiscrepancy)/stdDiscrepancy;
probabilities = 1 - normcdf(zScoreDiscrepancies);

function X = getFFT(audio, fftLength)
% Get normalized FFt of syllable
X = abs(fft(audio));
% Make fft one-sided
X = X(1:floor(length(X)/2));
% Z-score normalize fft
stdX = std(X);
meanX = mean(X);
X = (X - meanX)/stdX;
% Interpolate to force fft to be a standard size for ease of comparison
X = interp1(1:length(X), X, (1:fftLength)*length(X)/fftLength, 'spline');
% Reduce size of fft vector to reduce impact of small variations
% downFactor = fftLength / fftBins;
% X = mean(reshape(X, downFactor, []));


function weightedProbabilities = getTimingMatchProbabilities(preISI, preIOI, preDuration, duration, postISI, postIOI, postDuration, syllablePrints)
% Construct a list of measurements, ensuring that [] ==> nan
measuresCell = {preISI, preIOI, preDuration, duration, postISI, postIOI, postDuration};
measures = [];
for k = 1:length(measuresCell)
    if isempty(measuresCell{k})
        measures = [measures, nan];
    else
        measures = [measures, measuresCell{k}];
    end
end

% Get number of measures and syllable types
numMeasures = length(measures);
numTitles = length(syllablePrints);

% Get a vector of the means and stdevs of each trained syllable type across all
% measures
allMeans = {[syllablePrints.meanPreISI], [syllablePrints.meanPreIOI], [syllablePrints.meanPreDuration], [syllablePrints.meanDuration], [syllablePrints.meanPostISI], [syllablePrints.meanPostIOI], [syllablePrints.meanPostDuration]};
allStds = {[syllablePrints.stdPreISI], [syllablePrints.stdPreIOI], [syllablePrints.stdPreDuration], [syllablePrints.stdDuration], [syllablePrints.stdPostISI], [syllablePrints.stdPostIOI], [syllablePrints.stdPreDuration]};

% Define a weight vector for how much to value each measure in terms of
% determining overall syllable type probability
weights = [1, 1, 1, 1, 1, 1, 1];

% figure;
probabilities = zeros([numMeasures, numTitles]);
for k = 1:numMeasures
    measure = measures(k);
    if isnan(measure)
        zscores = Inf([1, numTitles]);
    else
        means = allMeans{k};
        stds = allStds{k};
        zscores = (measure - means)./stds;
    end
%     subplot(numMeasures, 1, k);
%     hold on;
%     bar(1:numTitles, zscores);
%     probabilities(k, :) = 1 - (normcdf(zscores) - normcdf(-zscores));
%     text(1:numTitles, zscores, arrayfun(@(p)sprintf('%.03f', p), probabilities(k, :), 'UniformOutput', false))
end

weightedProbabilities = weights * probabilities;
% title(sprintf('%.03f ', weightedProbabilities));


% showPlots = false;
% duration
% disp('');
% if showPlots
%     figure;
%     subplot(4, 1, 1)
%     errorbar(0:5, [duration, syllablePrints.meanDuration], [0, syllablePrints.stdDuration], 'o');
%     xlim([-0.5, 5.5]);
%     subplot(4, 1, 2)
%     errorbar(0:5, [preISI, syllablePrints.meanPreISI], [0, syllablePrints.stdPreISI], 'o');
%     xlim([-0.5, 5.5]);
%     subplot(4, 1, 3)
%     errorbar(0:5, [postISI, syllablePrints.meanPostISI], [0, syllablePrints.stdPostISI], 'o');
%     xlim([-0.5, 5.5]);
%     subplot(4, 1, 4)
%     plot(1:5, probabilities, 'o');
%     xlim([-0.5, 5.5]);
% end

function [ID, confidence, diffConfidence, ID2] = IDSyllable(newSyllablePrint, syllablePrints)

% newSyllablePrint should just be a single syllable observation.
preISI = newSyllablePrint.preSyllableISIs;
preIOI = newSyllablePrint.preSyllableIOIs;
preDuration = newSyllablePrint.preSyllableDurations;
duration = newSyllablePrint.durations;
postISI = newSyllablePrint.postSyllableISIs;
postIOI = newSyllablePrint.postSyllableIOIs;
postDuration = newSyllablePrint.postSyllableDurations;
syllableFFT = newSyllablePrint.ffts;

timingProbabilities = getTimingMatchProbabilities(preISI, preIOI, preDuration, duration, postISI, postIOI, postDuration, syllablePrints);
fftProbabilities = getFFTMatchProbabilities(syllableFFT, syllablePrints);
% figure;
% text(timingProbabilities, fftProbabilities, {syllablePrints.title});
wTiming = 0.5;
wFFT = 0.5;
probabilities = (wTiming * timingProbabilities + wFFT * fftProbabilities) / (wTiming + wFFT);
[confidence, ID] = max(probabilities);
probabilities(ID) = -Inf;
[confidence2, ID2] = max(probabilities);
diffConfidence = confidence - confidence2;