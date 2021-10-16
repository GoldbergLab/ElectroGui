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

labelledSyllableCount = 0;
unlabelledSyllableCount = 0;
acceptedSyllableCount = struct();
rejectedSyllableCount = struct();

maxISI = Inf; %3000;  % Disregard ISIs larger than this.

% Create a blank struct array...why is this so hard in MATLAB
initSyllablePrint = createSyllablePrint([2, 3], 'unknown', [0, 1], 'unknown', [4, 5], 'unknown', 1:10, fftLength, maxISI);
syllablePrints = initSyllablePrint([]);

% Loop over all files and collect syllablePrints for manually labelled
% syllables
for fileIdx = 1:length(trainingFileNums)
    count = fileIdx;
    fileNum = trainingFileNums(fileIdx);
    if sum(get(txt,'color')==[0 1 0])==3
        count = count-1;
        break
    end

    % Get all labelled segment titles and times that are in include list
    includeIdx = cellfun(@(title)~isempty(title) && any(syllableTitleIncludeList == title), handles.SegmentTitles{fileNum});
    syllableTimes = handles.SegmentTimes{fileNum}(includeIdx, :);
    syllableTitles = handles.SegmentTitles{fileNum}(includeIdx);
    numSegments = size(syllableTitles, 2);
    labelledSyllableCount = labelledSyllableCount + 1;

    if isempty(syllableTitles)
        % If no labelled syllables found, don't bother laoding audio.
        continue;
    end
    
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

        if syllableNum > 1
            preSyllableTimes = syllableTimes(syllableNum-1, :);
            preSyllableTitle = syllableTitles{syllableNum-1};
        else
            preSyllableTimes = [nan, nan];
            preSyllableTitle = '';
        end
        if syllableNum > numSegments - 1
            postSyllableTimes = [nan, nan];
            postSyllableTitle = '';
        else
            postSyllableTimes = syllableTimes(syllableNum+1, :);
            postSyllableTitle = syllableTitles{syllableNum+1};
        end
        
        % Find the index corresponding to this syllable label, if it exists
        % yet.
        printIdx = find(strcmp({syllablePrints.title}, syllableTitle));
        
        if isempty(printIdx)
            % Create new syllablePrint entry:
            printIdx = length(syllablePrints)+1;
            syllablePrints(printIdx) = createSyllablePrint(syllableTimes(syllableNum, :), syllableTitle, preSyllableTimes, preSyllableTitle, postSyllableTimes, postSyllableTitle, syllableAudio, fftLength, maxISI);
        else
            % Update syllablePrint with new info
            newSyllable = createSyllablePrint(syllableTimes(syllableNum, :), syllableTitle, preSyllableTimes, preSyllableTitle, postSyllableTimes, postSyllableTitle, syllableAudio, fftLength, maxISI);
            syllablePrints(printIdx) = combineSyllablePrints(syllablePrints(printIdx), newSyllable);
        end
        
    end

end

% Calculate syllablePrint stats
for k = 1:length(syllablePrints)
    syllablePrintsWithStats(k) = addStatisticsToSyllablePrint(syllablePrints(k));
end

printCount = 0;

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
        
        unlabelledSyllableCount = unlabelledSyllableCount + 1;

        if syllableNum > 1
            preSyllableTimes = syllableTimes(syllableNum-1, :);
            preSyllableTitle = syllableTitles{syllableNum-1};
        else
            preSyllableTimes = [nan, nan];
            preSyllableTitle = '';
        end
        if syllableNum > numSegments - 1
            postSyllableTimes = [nan, nan];
            postSyllableTitle = '';
        else
            postSyllableTimes = syllableTimes(syllableNum+1, :);
            postSyllableTitle = syllableTitles{syllableNum+1};
        end

        if isempty(syllableTitle)
            syllableTitle = 'unknown';
        end
        newSyllablePrint = createSyllablePrint(syllableTimes(syllableNum, :), syllableTitle, preSyllableTimes, preSyllableTitle, postSyllableTimes, postSyllableTitle, syllableAudio, fftLength, maxISI);
        printCount = printCount + 1;
        collectedSyllablePrints(printCount) = newSyllablePrint;

        [ID, conf, diffConf, ID2] = IDSyllable(newSyllablePrint, syllablePrintsWithStats);
        IDTitle = syllablePrints(ID).title;
        IDTitle2 = syllablePrints(ID2).title;
        if conf >= minConfidence && diffConf >= minDiffConfidence
            % We got a valid ID!
            if isempty(syllableTitle)
                handles.SegmentTitles{fileNum}{syllableNum} = IDTitle;
            else
                if strcmp(IDTitle, syllableTitle)
                    fprintf('RIGHT ID= %s ==> ', syllableTitle);
                else
                    fprintf('WRONG ID= %s ==> ', syllableTitle);
                end
            end
            fprintf('File #%d syllable #%d ACCEPTED ID = %s, c=%.03f, dc=%.03f, secondID=%s\n', fileNum, syllableNum, IDTitle, conf, diffConf, IDTitle2); 
            if isfield(acceptedSyllableCount, IDTitle)
                acceptedSyllableCount.(IDTitle) = acceptedSyllableCount.(IDTitle) + 1;
            else
                acceptedSyllableCount.(IDTitle) = 1;
            end
        else
            if ~isempty(syllableTitle)
                if strcmp(IDTitle, syllableTitle)
                    fprintf('RIGHT ID= %s ==> ', syllableTitle);
                else
                    fprintf('WRONG ID= %s ==> ', syllableTitle);
                end
            end
            fprintf('File #%d syllable #%d REJECTED ID = %s, c=%.03f, dc=%.03f, secondID=%s\n', fileNum, syllableNum, IDTitle, conf, diffConf, IDTitle2); 
            if isfield(rejectedSyllableCount, IDTitle)
                rejectedSyllableCount.(IDTitle) = rejectedSyllableCount.(IDTitle) + 1;
            else
                rejectedSyllableCount.(IDTitle) = 1;
            end
        end
    end
    
    set(txt,'string',['Labelled file ' num2str(trainingFileNums(fileIdx)) ' (' num2str(fileIdx) '/' num2str(length(trainingFileNums)) '). Click to quit.']);
    drawnow;
end

delete(txt);

% Compute and report summary report
totalAcceptedSyllableCount = 0;
totalRejectedSyllableCount = 0;
acceptedTitles = fields(acceptedSyllableCount);
for k = 1:length(acceptedTitles)
    totalAcceptedSyllableCount = totalAcceptedSyllableCount + acceptedSyllableCount.(acceptedTitles{k});
end
rejectedTitles = fields(rejectedSyllableCount);
for k = 1:length(rejectedTitles)
    totalRejectedSyllableCount = totalRejectedSyllableCount + rejectedSyllableCount.(rejectedTitles{k});
end

fprintf('AutoLabelling report:\n');
fprintf('Trained on %d labelled syllables\n', labelledSyllableCount)
fprintf('Found %d unlabelled syllables\n', unlabelledSyllableCount)
fprintf('   Identified and labelled %d syllables\n', totalAcceptedSyllableCount)
for k = 1:length(acceptedTitles)
fprintf('      %s - %d\n', acceptedTitles{k}, acceptedSyllableCount.(acceptedTitles{k}))
end
fprintf('   Rejected %d low-confidence syllabel IDs\n', totalRejectedSyllableCount)
for k = 1:length(rejectedTitles)
fprintf('      %s - %d\n', rejectedTitles{k}, rejectedSyllableCount.(rejectedTitles{k}))
end
fprintf('AutoLabelling complete.\n');


msgbox('Autolabelling complete!', 'Autolabelling complete!');
%msgbox(['Segmented ' num2str(count) ' files.'],'Segmentation complete')

function syllablePrint = addStatisticsToSyllablePrint(syllablePrint)
syllablePrint.meanDuration = mean(syllablePrint.durations);
syllablePrint.stdDuration = std(syllablePrint.durations);
if syllablePrint.stdDuration == 0
    syllablePrint.stdDuration = syllablePrint.meanDuration/2;
end
syllablePrint.meanPreDuration = mean(syllablePrint.preSyllableDurations);
syllablePrint.meanPreISI = mean(syllablePrint.preSyllableISIs);
syllablePrint.meanPostISI = mean(syllablePrint.postSyllableISIs);
syllablePrint.meanPreIOI = mean(syllablePrint.preSyllableIOIs);
syllablePrint.meanPostIOI = mean(syllablePrint.postSyllableIOIs);
syllablePrint.meanPostDuration = mean(syllablePrint.postSyllableDurations);
syllablePrint.stdPreDuration = std(syllablePrint.preSyllableDurations);
syllablePrint.stdPreISI = std(syllablePrint.preSyllableISIs);
syllablePrint.stdPostISI = std(syllablePrint.postSyllableISIs);
syllablePrint.stdPreIOI = std(syllablePrint.preSyllableIOIs);
syllablePrint.stdPostIOI = std(syllablePrint.postSyllableIOIs);
syllablePrint.stdPostDuration = std(syllablePrint.postSyllableDurations);

syllablePrint.meanFFT = mean(syllablePrint.ffts, 1);
syllablePrint.stdFFT = std(syllablePrint.ffts, 0, 1);

function syllablePrint = combineSyllablePrints(syllablePrintA, syllablePrintB)
% Aggregate data from two syllable prints for the same syllable
if ~strcmp(syllablePrintA.title, syllablePrintB.title)
    error('Cannot combine syllable prints for different syllables.');
end

% Titles should be the same - get it from syllablePrintA
syllablePrint.title = syllablePrintA.title;
% Append syllable duration lists
syllablePrint.durations = [syllablePrintA.durations, syllablePrintB.durations];
% Combine pre/postSyllable data
syllablePrint.preSyllableTitles = [syllablePrintA.preSyllableTitles, syllablePrintB.preSyllableTitles];
syllablePrint.preSyllableISIs = [syllablePrintA.preSyllableISIs, syllablePrintB.preSyllableISIs];
syllablePrint.preSyllableIOIs = [syllablePrintA.preSyllableIOIs, syllablePrintB.preSyllableIOIs];
syllablePrint.preSyllableDurations = [syllablePrintA.preSyllableDurations, syllablePrintB.preSyllableDurations];
syllablePrint.postSyllableTitles = [syllablePrintA.postSyllableTitles, syllablePrintB.postSyllableTitles];
syllablePrint.postSyllableISIs = [syllablePrintA.postSyllableISIs, syllablePrintB.postSyllableISIs];
syllablePrint.postSyllableIOIs = [syllablePrintA.postSyllableIOIs, syllablePrintB.postSyllableIOIs];
syllablePrint.postSyllableDurations = [syllablePrintA.postSyllableDurations, syllablePrintB.postSyllableDurations];
% Stack ffts
syllablePrint.ffts = cat(1, syllablePrintA.ffts, syllablePrintB.ffts);

function syllablePrint = createSyllablePrint(syllableTimes, syllableTitle, preSyllableTimes, preSyllableTitle, postSyllableTimes, postSyllableTitle, syllableAudio, fftLength, maxISI)
syllableStart = syllableTimes(1);
syllableEnd = syllableTimes(2);
preSyllableStart = preSyllableTimes(1);
preSyllableEnd = preSyllableTimes(2);
postSyllableStart = postSyllableTimes(1);
postSyllableEnd = postSyllableTimes(2);

midPoint = floor(length(syllableAudio)/2);
audioStart = syllableAudio(1:midPoint);
audioEnd = syllableAudio(midPoint+1:end);

%actualFFTLength = fftLength;
% fftBins = 100;
% % fftLength must be made a multiple of fftBins
% actualFFTLength = fftBins * round(fftLength / fftBins);
% if actualFFTLength == 0
%     error('fftLength must be at least %d.', fftBins);
% end

Xstart = getFFT(audioStart, fftLength);
Xend = getFFT(audioEnd, fftLength);
% % Get normalized FFt of syllable
% X = abs(fft(syllableAudio));
% % Make fft one-sided
% X = X(1:floor(length(X)/2));
% % Z-score normalize fft
% stdX = std(X);
% meanX = mean(X);
% X = (X - meanX)/stdX;
% % Interpolate to force fft to be a standard size for ease of comparison
% X = interp1(1:length(X), X, (1:actualFFTLength)*length(X)/actualFFTLength, 'spline');
% % Reduce size of fft vector to reduce impact of small variations
% % downFactor = fftLength / fftBins;
% % X = mean(reshape(X, downFactor, []));

duration = syllableEnd - syllableStart + 1;

preSyllableIOI = syllableStart - preSyllableStart;
preSyllableISI = syllableStart - preSyllableEnd;
preSyllableDuration = preSyllableEnd - preSyllableStart;
postSyllableISI = postSyllableStart - syllableEnd;
postSyllableIOI = postSyllableStart - syllableStart;
postSyllableDuration = postSyllableEnd - postSyllableStart;

% Create new syllablePrint entry:
syllablePrint.title = syllableTitle;
syllablePrint.durations = duration;
if isempty(preSyllableTitle)
    preSyllableTitle = 'unknown';
end
if isempty(postSyllableTitle)
    postSyllableTitle = 'unknown';
end
if (preSyllableISI <= maxISI) && (~isnan(preSyllableISI) || ~isempty(preSyllableISI))
    % There is a preceding syllable
    syllablePrint.preSyllableTitles = {preSyllableTitle};
    syllablePrint.preSyllableISIs = preSyllableISI;
    syllablePrint.preSyllableIOIs = preSyllableIOI;
    syllablePrint.preSyllableDurations = preSyllableDuration;
elseif ~isfield(syllablePrint, 'preSyllables')
    % Initialize empty preISI field
    syllablePrint.preSyllableTitles = {};
    syllablePrint.preSyllableISIs = [];
    syllablePrint.preSyllableIOIs = [];
    syllablePrint.preSyllableDurations = [];
end
if (postSyllableISI <= maxISI) && (~isnan(postSyllableISI) || ~isempty(postSyllableISI))
    syllablePrint.postSyllableTitles = {postSyllableTitle};
    syllablePrint.postSyllableISIs = postSyllableISI;
    syllablePrint.postSyllableIOIs = postSyllableIOI;
    syllablePrint.postSyllableDurations = postSyllableDuration;
elseif ~isfield(syllablePrint, 'postSyllables')
    % Initialize empty postISI field
    syllablePrint.postSyllableTitles = {};
    syllablePrint.postSyllableISIs = [];
    syllablePrint.postSyllableIOIs = [];
    syllablePrint.postSyllableDurations = [];
end
syllablePrint.ffts = cat(2, Xstart, Xend);

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