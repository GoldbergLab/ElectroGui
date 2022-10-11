function handles = egm_Batch_label2(handles)
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

% for fileNum = 1:length(handles.menu_Segmenter)
%     if strcmp(get(handles.menu_Segmenter(fileNum),'checked'),'on')
%         alg = get(handles.menu_Segmenter(fileNum),'label');
%     end
% end
% ax = handles.axes_Sonogram;
% txt = text(ax, mean(xlim),mean(ylim),'Labelling... Click to quit.','horizontalalignment','center','fontsize',14,'color','r','backgroundcolor','w');
% set(txt,'ButtonDownFcn','set(gco,''color'',''g''); drawnow;');
% 
%     if sum(get(txt,'color')==[0 1 0])==3
%         count = count-1;
%         break
%     end
%     set(txt,'string',['Labelled file ' num2str(trainingFileNums(fileIdx)) ' (' num2str(fileIdx) '/' num2str(length(trainingFileNums)) '). Click to quit.']);
%     drawnow;
% figure;
% for k = 1:length(syllableModel)
%     subplot(1, 9, k);
%     imshow(syllableModel(k).meanFFTs');
% end
% figure;
% for k = 1:length(syllableModel)
%     subplot(1, 9, k);
%     imshow(syllableModel(k).stdFFTs');
% end

maxISI = Inf; %3000;  % Disregard ISIs larger than this.

% Collect basic syllable info
[fileNums, syllableNums, syllableCount] = getFileInfo(handles.SegmentTimes, labellingFileNums);
[syllableStarts, syllableEnds] = getTimingInfo(handles.SegmentTimes, labellingFileNums);
[syllableTitles, manualTitle] = getTitleInfo(handles.SegmentTitles, labellingFileNums);
syllableFFTs = getFFTs(handles.plugins.loaders, handles.sound_loader, handles.path_name, handles.sound_files, handles.SegmentTimes, syllableStarts, syllableEnds, labellingFileNums);

% Calculate metrics about syllables and their neighborhoods.
preSyllableCount = 5;
postSyllableCount = 5;

syllableNeighborTitles = getSyllableNeighborTitles(syllableTitles, preSyllableCount, postSyllableCount);
syllableDurations = getNeighboringSyllableDurations(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount);
syllableISIs = getNeighboringSyllableISIs(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount);
syllableIOIs = getNeighboringSyllableIOIs(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount);

% Construct list of syllable classes
syllableClasses = createSyllableClasses(syllableTitles);
% Create syllable model
syllableModel = createSyllableModel(syllableClasses, syllableTitles, syllableNeighborTitles, syllableDurations, syllableISIs, syllableIOIs, syllableFFTs);

% %%% Compare syllables to the model and select a class for each one
% Score syllables based on model.
overallScores = scoreSyllables(syllableModel, syllableNeighborTitles, syllableDurations, syllableISIs, syllableIOIs, syllableFFTs);
% Get the indices of the best matching syllable class for each syllable
[maxProb, classIdx] = nanmax(overallScores, [], 2);
% Get a list of selected syllable titles
selectedSyllableTitles = syllableClasses(classIdx);
% Set syllable titles where confidence is too low back to empty
selectedSyllableTitles(~manualTitle & (maxProb < minConfidence)') = {''};

changes = [];
for iter = 1:4    
    % %%% Re-run syllable class selection with now completed syllable title list, to refine.
    % Recalculate neighboring titles with newly inferred title list
    syllableNeighborTitles = getSyllableNeighborTitles(selectedSyllableTitles, preSyllableCount, postSyllableCount);
    % Re-score syllables based on model again, this time with title list full
    overallScores = scoreSyllables(syllableModel, syllableNeighborTitles, syllableDurations, syllableISIs, syllableIOIs, syllableFFTs);
    % Get the indices of the best matching syllable class for each syllable
    [maxProb, classIdx] = nanmax(overallScores, [], 2);
    % Get a list of selected syllable titles
    newSelectedSyllableTitles = syllableClasses(classIdx);
    % Set syllable titles where confidence is too low back to empty
    newSelectedSyllableTitles(~manualTitle & (maxProb < minConfidence)') = {''};

    % Record how many syllable titles changed on this iteration
    changes(iter) = sum(~strcmp(selectedSyllableTitles, newSelectedSyllableTitles));

    selectedSyllableTitles = newSelectedSyllableTitles;
end

totalAcceptedSyllableCount = 0;
totalRejectedSyllableCount = 0;
acceptedTitles = {};
rejectedTitles = {};
selfValidationHits = 0;
selfValidationMisses = 0;
for syllableIdx = 1:syllableCount
    % Get file num syllable is part of
    fileNum = fileNums(syllableIdx);
    % Get syllable number within file
    syllableNum = syllableNums(syllableIdx);
    selectedSyllableClass = classIdx(syllableIdx);
    selectedSyllableTitle = syllableClasses{selectedSyllableClass};
    selectedSyllableConfidence = maxProb(syllableIdx);
    if ~manualTitle(syllableIdx)
        % This syllable was not manually lableled. Let's label it.
        if selectedSyllableConfidence > minConfidence
            syllableTitles{syllableIdx} = selectedSyllableTitle;
            acceptedTitles{end+1} = selectedSyllableTitle;
            totalAcceptedSyllableCount = totalAcceptedSyllableCount + 1;
        else
            totalRejectedSyllableCount = totalRejectedSyllableCount + 1;
            rejectedTitles{end+1} = selectedSyllableTitle;
        end
    else
        % This syllable was manually labeled. Let's check if we got it
        % right.
        if strcmp(selectedSyllableTitle, handles.SegmentTitles{fileNum}{syllableNum})
            selfValidationHits = selfValidationHits + 1;
        else
            selfValidationMisses = selfValidationMisses + 1;
        end
    end
end

% Assign final titles
for syllableIdx = 1:syllableCount
    % Get file num syllable is part of
    fileNum = fileNums(syllableIdx);
    % Get syllable number within file
    syllableNum = syllableNums(syllableIdx);
    handles.SegmentTitles{fileNum}{syllableNum} = syllableTitles{syllableIdx};
end


uniqueAcceptedTitles = unique(acceptedTitles);
uniqueRejectedTitles = unique(rejectedTitles);

% delete(txt);

fprintf('AutoLabelling report:\n');
fprintf('Trained on %d labelled syllables\n', sum(manualTitle));
fprintf('Found %d unlabelled syllables\n', sum(~manualTitle));
fprintf('   Identified and labelled %d syllables\n', length(acceptedTitles))
for k = 1:length(uniqueAcceptedTitles)
    fprintf('      %s - %d\n', uniqueAcceptedTitles{k}, sum(strcmp(acceptedTitles, uniqueAcceptedTitles{k})));
end
fprintf('   Rejected %d low-confidence syllable IDs\n', length(rejectedTitles))
for k = 1:length(uniqueRejectedTitles)
    fprintf('      %s - %d\n', uniqueRejectedTitles{k}, sum(strcmp(rejectedTitles, uniqueRejectedTitles{k})));
end
fprintf('Confidence: %f +/- %f\n', mean(maxProb), std(maxProb));
for iter = 1:length(changes)
    fprintf('# of changes after run #%d: %d\n', iter, changes(iter));
end
fprintf('Self-validation hit rate = %f\n', selfValidationHits / (selfValidationHits + selfValidationMisses));
fprintf('AutoLabelling complete.\n');

msgbox('Autolabelling complete!', 'Autolabelling complete!');
%msgbox(['Segmented ' num2str(count) ' files.'],'Segmentation complete')

function [fileNums, syllableNums, syllableCount] = getFileInfo(SegmentTimes, labellingFileNums)
% Loop over files and collect syllable info
syllableCount = 0;
for fileNum = labellingFileNums;
    for syllableNum = 1:size(SegmentTimes{fileNum}, 1)
        syllableCount = syllableCount + 1;
        
        fileNums(syllableCount) = fileNum;
        syllableNums(syllableCount) = syllableNum;
    end
end
function [syllableStarts, syllableEnds] = getTimingInfo(SegmentTimes, labellingFileNums)
% Loop over files and collect syllable starts/ends
syllableCount = 0;
for fileNum = labellingFileNums;
    for syllableNum = 1:size(SegmentTimes{fileNum}, 1)
        syllableCount = syllableCount + 1;
        syllableStarts(syllableCount) = SegmentTimes{fileNum}(syllableNum, 1);
        syllableEnds(syllableCount) = SegmentTimes{fileNum}(syllableNum, 2);
    end
end
function [syllableTitles, manualTitle] = getTitleInfo(SegmentTitles, labellingFileNums)
% Loop over files and collect syllable titles
syllableCount = 0;
manualTitle = [];
for fileNum = labellingFileNums;
    for syllableNum = 1:length(SegmentTitles{fileNum})
        syllableCount = syllableCount + 1;
        syllableTitles{syllableCount} = num2str(SegmentTitles{fileNum}{syllableNum});
        
        if ~isempty(syllableTitles{syllableCount})
            manualTitle(syllableCount) = true;
        else
            manualTitle(syllableCount) = false;
        end
    end
end
function syllableFFTs = getFFTs(loaders, sound_loader, path_name, sound_files, SegmentTimes, syllableStarts, syllableEnds, labellingFileNums)
fftLength = 1000;
% Loop over files and collect binned syllable FFTs
syllableCount = 0;
for fileNum = labellingFileNums;
    % Load audio
    [snd, ~, ~, ~, ~] = eg_runPlugin(loaders, sound_loader, fullfile(path_name, sound_files(fileNum).name), true);
    if size(snd,2)>size(snd,1)
        snd = snd';
    end
    for syllableNum = 1:size(SegmentTimes{fileNum}, 1)
        syllableCount = syllableCount + 1;
        % Get binned FFt of syllable
        syllableAudio = snd(syllableStarts(syllableCount):syllableEnds(syllableCount));
        binnedFFT = createBinnedFFT(syllableAudio, 3, 20);
        syllableFFTs(syllableCount, :, :) = binnedFFT;
    end    
end
function syllableNeighborTitles = getSyllableNeighborTitles(syllableTitles, preSyllableCount, postSyllableCount)
% Loop over syllables and extract neighboring titles
syllableCount = length(syllableTitles);
for syllableIdx = 1:syllableCount
    neighborCount = 0;
    for neighborIdx = (syllableIdx-preSyllableCount):(syllableIdx+postSyllableCount)
        neighborCount = neighborCount + 1;
        if neighborIdx >= 1 && neighborIdx <= syllableCount
            % Record neighboring syllable syllable titles, for neighboring syllables.
            syllableNeighborTitles{syllableIdx, neighborCount} = syllableTitles{neighborIdx};
        end
    end
end

function syllableDurations = getNeighboringSyllableDurations(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount)
% Loop over syllables and extract neighboring syllable durations
numNeighbors = preSyllableCount + postSyllableCount + 1;
syllableCount = length(syllableStarts);
syllableDurations = nan(syllableCount, numNeighbors);
for syllableIdx = 1:syllableCount
    neighborCount = 0;
    for neighborIdx = (syllableIdx-preSyllableCount):(syllableIdx+postSyllableCount)
        neighborCount = neighborCount + 1;
        if neighborIdx >= 1 && neighborIdx <= syllableCount
            % Record neighboring syllable duration
            syllableDurations(syllableIdx, neighborCount) = syllableEnds(neighborIdx) - syllableStarts(neighborIdx);
        end
    end
end

function syllableIOIs = getNeighboringSyllableIOIs(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount)
% Loop over syllables and extract neighboring IOIs
numNeighbors = preSyllableCount + postSyllableCount + 1;
syllableCount = length(syllableStarts);
syllableIOIs = nan(syllableCount, numNeighbors);
for syllableIdx = 1:syllableCount
    neighborCount = 0;
    for neighborIdx = (syllableIdx-preSyllableCount):(syllableIdx+postSyllableCount)
        neighborCount = neighborCount + 1;
        if neighborIdx >= 1 && neighborIdx <= syllableCount
            % Record neighboring syllable IOIs (inter-onset interval)
            if neighborIdx < syllableCount
                syllableIOIs(syllableIdx, neighborCount) = syllableStarts(neighborIdx+1) - syllableStarts(neighborIdx);
            end
        end
    end
end

function syllableISIs = getNeighboringSyllableISIs(syllableStarts, syllableEnds, preSyllableCount, postSyllableCount)
% Loop over syllables and extract neighborin ISIs
numNeighbors = preSyllableCount + postSyllableCount + 1;
syllableCount = length(syllableStarts);
syllableISIs = nan(syllableCount, numNeighbors);
for syllableIdx = 1:syllableCount
    neighborCount = 0;
    for neighborIdx = (syllableIdx-preSyllableCount):(syllableIdx+postSyllableCount)
        neighborCount = neighborCount + 1;
        if neighborIdx >= 1 && neighborIdx <= syllableCount
            % Record neighboring syllable ISI (inter-syllable interval)
            if neighborIdx < syllableCount
                syllableISIs(syllableIdx, neighborCount) = syllableStarts(neighborIdx+1) - syllableEnds(neighborIdx);
            end
        end
    end
end

function syllableClasses = createSyllableClasses(syllableTitles)
% Syllable classes are identified by their title
syllableClasses = unique(syllableTitles);
% Remove empty title from class list
syllableClasses(strcmp(syllableClasses, '')) = [];

function syllableModel = createSyllableModel(syllableClasses, syllableTitles, syllableNeighborTitles, syllableDurations, syllableISIs, syllableIOIs, syllableFFTs)
numClasses = length(syllableClasses);
numNeighbors = size(syllableNeighborTitles, 2);
% Loop over identified syllable classes and build a syllable model from the collected syllable data.
for c = 1:numClasses
    syllableTitle = syllableClasses{c};
    classIdx = strcmp(syllableTitles, syllableTitle);
    syllableModel(c).title = syllableTitle;
    syllableModel(c).neighborTitles = syllableNeighborTitles(classIdx, :);
    for n = 1:numNeighbors
        % Get list of titles that are for this class and this neighbor #
        neighborTitles = syllableNeighborTitles(classIdx, n);
        % Initialize an empty list to hold all the 
        syllableModel(c).neighborClasses{n} = [];
        for nt = 1:length(neighborTitles)
            if isempty(neighborTitles{nt})
                % This neighbor did not have a class assigned. Skip it.
                continue;
            end
            neighborTitle = neighborTitles{nt};
            neighborClass = find(strcmp(syllableClasses, neighborTitle));
            syllableModel(c).neighborClasses{n}(end+1) = neighborClass;
        end
    end
    syllableModel(c).meanFFTs = squeeze(mean(syllableFFTs(classIdx, :, :), 1));
    syllableModel(c).stdFFTs = squeeze(std(syllableFFTs(classIdx, :, :), 1));
    syllableModel(c).meanDuration = mean(syllableDurations(classIdx, :), 1);
    syllableModel(c).stdDuration = std(syllableDurations(classIdx, :), 1);
    syllableModel(c).meanIOI = mean(syllableIOIs(classIdx, :), 1);
    syllableModel(c).stdIOI = std(syllableIOIs(classIdx, :), 1);
    syllableModel(c).meanISI = mean(syllableISIs(classIdx, :), 1);
    syllableModel(c).stdISI = std(syllableISIs(classIdx, :), 1);
    syllableModel(c).neighborClassProbabilities = zeros(numNeighbors, numClasses);
    for n = 1:numNeighbors
        for c2 = 1:numClasses
            syllableModel(c).neighborClassProbabilities(n, c2) = sum(syllableModel(c).neighborClasses{n} == c2);
        end
        syllableModel(c).neighborClassProbabilities(n, :) = syllableModel(c).neighborClassProbabilities(n, :) / sum(syllableModel(c).neighborClassProbabilities(n, :));
    end
end

function overallScores = scoreSyllables(syllableModel, syllableNeighborTitles, syllableDurations, syllableISIs, syllableIOIs, syllableFFTs)
neighborTitleScores = [];
neighborISIScores = [];
neighborIOIScores = [];
syllableCount = length(syllableDurations);
for syllableIdx = 1:syllableCount    
    neighborTitleScores(syllableIdx, :) = getNeighborTitleScores(syllableModel, syllableNeighborTitles(syllableIdx, :));
    neighborISIScores(syllableIdx, :) = getContinuousAttributeScores(syllableModel, 'meanISI', 'stdISI', syllableISIs(syllableIdx, :));
    neighborIOIScores(syllableIdx, :) = getContinuousAttributeScores(syllableModel, 'meanIOI', 'stdIOI', syllableIOIs(syllableIdx, :));
    durationScores(syllableIdx, :) = getContinuousAttributeScores(syllableModel, 'meanDuration', 'stdDuration', syllableDurations(syllableIdx, :));
    fftScores(syllableIdx, :) = getContinuousAttributeScores(syllableModel, 'meanFFTs', 'stdFFTs', syllableFFTs(syllableIdx, :));
end
neighborTitleWeight = 1;
ISIWeight = 1;
IOIWeight = 1;
durationWeight = 1;
fftWeight = 2;
weights = [neighborTitleWeight, ISIWeight, IOIWeight, durationWeight, fftWeight];
weights = weights / sum(weights);
allScores = {neighborTitleScores, neighborISIScores, neighborIOIScores, durationScores, fftScores};
allScores = cellfun(@(scores, weight)scores * weight, allScores, num2cell(weights), 'UniformOutput', false);

overallScores = cat(3, allScores{:});
overallScores = nanmean(overallScores, 3);

function scores = getContinuousAttributeScores(syllableModel, meanField, stdField, values)
meanMatrix = vertcat(syllableModel.(meanField));  % A c x n matrix, where c is the number of classes, and n is the number of attributes
stdMatrix = vertcat(syllableModel.(stdField));    % Same as above
% Loop over each class and find the probability that the value could have
% been drawn from that class for each measurement.
for c = 1:length(syllableModel)
    % Calculate probability that, for each neighbor syllable, a randomly 
    %   drawn ISI would be at least this far from the mean ISI.
    probs(c, :) = probabilityOutside(values, meanMatrix(c, :), stdMatrix(c, :));
    % Weight is measured by how far from the mean probability the leading probability
    % is.
%    weight = abs(probs
end
scores = nanmean(probs, 2);

function prob = probabilityOutside(v, m, s)
% Find the probability that a sample randomly drawn from a normally
% distributed population with mean m and standard deviation s would produce
% a value as far or farther from the mean as v is.
prob = 1 - abs(normcdf(v, m, s) - normcdf(m + (m - v), m, s));

function [scores, weight] = getNeighborTitleScores(syllableModel, neighborTitles)
scores = zeros([1, length(syllableModel)]);
numNeighbors = length(neighborTitles);
% Weight keeps track of what percent of the maximum number of titles this
% score is based on.
weight = 0;
preNeighborWeight = 1;
postNeighborWeight = 1;
neighborWeights = [preNeighborWeight*ones([1, floor(numNeighbors / 2)]), postNeighborWeight*ones([1, 1+floor(numNeighbors / 2)])];
maxWeight = length(syllableModel) * length(neighborTitles);
for c = 1:length(syllableModel)
    neighborScores = [];
    for n = 1:numNeighbors
        neighborTitle = neighborTitles{n};
        neighborClass = find(strcmp({syllableModel.title}, neighborTitle));
        if isempty(neighborClass)
            % This neighborTitle is not in the list of syllable classes,
            % probably because it hasn't been identified yet. Skip it.
            continue;
        end
        neighborScores(end+1) = syllableModel(c).neighborClassProbabilities(n, neighborClass) * neighborWeights(n);
        weight = weight + 1;
    end
    scores(c) = mean(neighborScores);
end
weight = weight / maxWeight;

function binnedFFT = createBinnedFFT(audio, numTimeBins, numFreqBins)
fftTotalLength = length(audio);
% Define parts of FFT to keep (a lot of the spectrum has little variation)
fftLowCutoff = round(0.15 * fftTotalLength);
fftHighCutoff = round(0.75 * fftTotalLength);
fftLength = fftHighCutoff - fftLowCutoff + 1;
audioEndPoints = round((length(audio)-1)*(0:numTimeBins)/numTimeBins) + 1;
fftBinEdges = round((fftLength-1) * (0:numFreqBins) / numFreqBins) + 1;
binnedFFT = zeros(numTimeBins, numFreqBins);
for chunkNum = 1:numTimeBins
    % Get audio chunk
    audioChunk = audio(audioEndPoints(chunkNum):audioEndPoints(chunkNum+1));
    % Fourier transform
    X = getFFT(audioChunk, fftTotalLength);
    X = X(fftLowCutoff:fftHighCutoff);
    for binNum = 1:numFreqBins
        % Get mean value within audio chunk and within frequency bin
        fftStart = fftBinEdges(binNum);
        fftEnd = fftBinEdges(binNum+1);
        fftChunk = X(fftStart:fftEnd);
        binnedFFT(chunkNum, binNum) = mean(fftChunk);
    end
end
% Z-score and flatten fft
binnedFFT = zscore(binnedFFT(:));

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