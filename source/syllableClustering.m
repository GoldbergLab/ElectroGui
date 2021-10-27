function [clusterIdx, clusterTitles] = syllableClustering(collectedSyllablePrints)
numRandomExtraCentroids = 5;
corrWeight = 65;
timingWeight = 3;
xcorrLength = 20;
reducedFFTWeight = 1;
fftReductionFactor = 20;  % Must be a factor of fftLength
%numKDims = 115; % With just two half ffts
%numKDims = 155; % With two half ffts and raw audio
numKDims = 175; % With single fft and 2x time radius
maxMeanClusterDistance = 1.5;
%numKDims = 4;

colors = {...
    [255, 0, 0], ...
    [255, 255, 0], ...
    [0, 255, 0], ...
    [0, 255, 255], ...
    [0, 0, 255], ...
    [255, 0, 255], ...
    [128, 128, 0], ...
    [0, 128, 128], ...
    [128, 0, 128], ...
    [255, 128, 128], ...
    [128, 255, 128], ...
    [128, 128, 255], ...
    [255, 255, 128], ...
    [255, 128, 255], ...
    [128, 255, 255], ...
    [255, 128, 64], ...
    [128, 255, 64], ...
    [128, 64, 255], ...
    [64, 128, 255], ...
    [64, 255, 128], ...
    [0, 0, 0], ...
    [255, 0, 0], ...
    [255, 255, 0], ...
    [0, 255, 0], ...
    [0, 255, 255], ...
    [0, 0, 255], ...
    [255, 0, 255], ...
    [128, 128, 0], ...
    [0, 128, 128], ...
    [128, 0, 128], ...
    };

colors = cellfun(@(x)x/255, colors, 'UniformOutput', false);

%load('syllablePrints.mat', 'collectedSyllablePrints');

numSyllables = length(collectedSyllablePrints);

timingData = [];

discardRadius = 6;
%numOtherFields = numel((collectedSyllablePrints(1).timingNeighborhood))-2*discardRadius;

for k = 1:numSyllables
    timingData(k, :) = (collectedSyllablePrints(k).timingNeighborhood(:));
end
timingData = timingData(:, (1+discardRadius):end-discardRadius);

numTimingFields = size(timingData, 2);

unknownTitle = '+';

titles = {collectedSyllablePrints.title};
titles(strcmp(titles, 'unknown')) = {unknownTitle};

trainingSet = ~strcmp(titles, unknownTitle);
validationSet = strcmp(titles, unknownTitle);

categories = unique(titles(trainingSet));
numCategories = length(categories);

ffts = cat(1, collectedSyllablePrints.ffts);
fftLength = size(ffts, 2);

meanFFTs = zeros([numCategories, fftLength]);
for c = 1:numCategories
    meanFFTs(c, :) = mean(vertcat(collectedSyllablePrints(strcmp(titles, categories{c})).ffts), 1);
end
fftCorrs = zeros([numSyllables, numCategories]);
for c = 1:numCategories
    for s = 1:numSyllables
        fftCorrs(s, c) = max(xcorr(collectedSyllablePrints(s).ffts, meanFFTs(c, :), xcorrLength, 'coeff'));
    end
end
numCorrFields = size(fftCorrs, 2);

reducedFFTs = squeeze(mean(reshape(ffts, numSyllables, fftReductionFactor, fftLength / fftReductionFactor), 2));
numReducedFFTSamples = size(reducedFFTs, 2);

otherObservations = cat(2, fftCorrs, timingData, reducedFFTs);
numOtherFields = size(otherObservations, 2);

% Replace nan with mean
for j = 1:numSyllables
    for k = 1:numOtherFields
        if isnan(otherObservations(j, k)) || isinf(otherObservations(j, k));
            otherObservations(j, k) = nanmean(otherObservations(:, k));
        end
    end
end

observations = cat(2, otherObservations, ffts);

weights = 1./var(observations);
sum(weights == Inf)
weights(weights == Inf | weights == -Inf) = 1e-100;
% if ~exist('extraWeightFactor', 'var')
%     extraWeightFactor = 10;
%     fprintf('Using default extra weight factor: %d\n', extraWeightFactor);
% end
%halfNumTimingFields = round(numTimingFields/2);
%otherHalfNumTimingFields = numTimingFields - halfNumTimingFields;
%timingWeights = [timingWeight * (1:halfNumTimingFields), timingWeight * flip(1:otherHalfNumTimingFields)];
timingWeights = timingWeight * cumsum(-sign((1:numTimingFields)-ceil(numOtherFields/2)-1)).^4;
%timingWeights = timingWeight * ones([1, numTimingFields]);
weightFactors = [corrWeight*ones([1, numCorrFields]), timingWeights, reducedFFTWeight * ones([1, numReducedFFTSamples])];  % Triangle function that puts more weight on this syllable
%weightFactors = 0.0001 * ones([1, numOtherFields]);
weights(1:numOtherFields) = weights(1:numOtherFields) .* weightFactors; %* extraWeightFactor;

% 0.721 =  1.4000    7.8000    3.2000    6.9000    7.7000    6.0000    4.3000    0.6000    5.0000    1.2000
% 0.721 =  0.5000    2.6000    2.4000    7.3000    9.1000    0.1000    0.2000    0.9000    4.0000    7.4000

[wcoeff, transformedObservations] = pca(observations, 'VariableWeights', weights);

startingCentroids = [];
for k = 1:numCategories
    thisTitle = categories{k};
    startingCentroids(k, :) = mean(transformedObservations(strcmp(titles, thisTitle), :), 1);
end

centroidScale = max(startingCentroids(:));

% permutation = randperm(size(transformedObservations, 1));
% transformedObservations = transformedObservations(permutation, :);
% titles = titles(permutation);

clusteringAlgorithm = 'kmeans';

switch clusteringAlgorithm
    case 'kmeans'
        startingCentroids = cat(1, startingCentroids, 2*(rand([numRandomExtraCentroids, size(startingCentroids, 2)])-0.5)*centroidScale);
        [clusterIdx,~,~,D] = kmeans(transformedObservations(:, 1:numKDims), [], 'Start', cat(1, startingCentroids(:, 1:numKDims), rand([0, numKDims])), 'EmptyAction', 'drop', 'Distance', 'cityblock');
    case 'gmm'
        startingCentroids = cat(1, startingCentroids);
        init.mu = startingCentroids(:, 1:numKDims);
        init.Sigma = repmat(eye(numKDims, numKDims), 1, 1, numCategories);
        options = statset('MaxIter',1000);
        gmfit = gmdistribution.fit(transformedObservations(:, 1:numKDims),numCategories,'Options',options, 'Start', init, 'SharedCov', false, 'CovType', 'full');
        clusterIdx = cluster(gmfit,transformedObservations(:, 1:numKDims)); % Cluster index 
        D = mahal(gmfit,X0); % Distance from each grid point to each GMM component
end

% Map clusters to syllable categories
categoryClusterIdx = [];
categoryClusterTitles = {};
categoryIdx = 1:numCategories;
uniqueClusterIdx = 1:max(clusterIdx);
for clusterNum = uniqueClusterIdx
    thisClusterTitles = titles(clusterIdx==clusterNum);
    titleCounts = [];
    for k = 1:numCategories
        title = categories{k};
        titleCounts(k) = sum(strcmp(title, thisClusterTitles));
    end
    [~, idx] = max(titleCounts);
    categoryClusterIdx(clusterNum) = categoryIdx(idx);
    categoryClusterTitles{clusterNum} = categories{idx};
end

disp('Cluster IDs:');
categoryClusterTitles

% Calculate distance between each syllable and the centroid of its cluster.
centroidDistances = zeros([1, numSyllables]);
for s = 1:numSyllables
    centroidDistances(s) = D(s, clusterIdx(s));
end
meanClusterDistances = zeros([1, numCategories]);
for c = 1:numCategories
    meanClusterDistances(c) = mean(centroidDistances(clusterIdx==c));
end
normalizedCentroidDistances = zeros([1, numCategories]);
for s = 1:numSyllables
    normalizedCentroidDistances(s) = centroidDistances(s) / meanClusterDistances(clusterIdx(s));
end

% for s = 1:numSyllables
%     fprintf('%s dist %0.03f cluster #%d: %s\n', titles{s}, normalizedCentroidDistances(s), clusterIdx(s), sort([titles{clusterIdx==clusterIdx(s)}], 'descend'));
% end

fprintf('Rejecting %d syllables\n', length(clusterIdx(normalizedCentroidDistances>2)));
clusterIdx(normalizedCentroidDistances>maxMeanClusterDistance) = nan;

clusterTitles = {};
for s = 1:numSyllables
    if isnan(clusterIdx(s))
        clusterTitles{s} = '';
    else
        clusterTitles{s} = categoryClusterTitles{clusterIdx(s)};
    end
end


accuracy = zeros(size(categories));
unknownClusterAssigments = clusterIdx(strcmp(titles, unknownTitle));
uncategorizedCount = 0;
for c = unique(clusterIdx)'
    if ~any(~strcmp(titles(clusterIdx==c), unknownTitle));
        uncategorizedCount = uncategorizedCount + sum(clusterIdx==c); 
    end
end
uncategorizedCount = uncategorizedCount + sum(isnan(clusterIdx));
uncategorizedFrac = uncategorizedCount / sum(strcmp(titles, unknownTitle));
for k = 1:numCategories
    thisClusterAssigments = clusterIdx(strcmp(titles, categories{k}));
    otherClusterAssigments = clusterIdx(~strcmp(titles, categories{k}) & ~strcmp(titles, unknownTitle));
    
    clusters = unique(thisClusterAssigments);
    thisSyllableCounts = [];
    otherSyllableCounts = [];
    unknownSyllableCounts = [];
    for c = clusters'
        thisSyllableCounts = [thisSyllableCounts, sum(thisClusterAssigments==c)];
        otherSyllableCounts = [otherSyllableCounts, sum(otherClusterAssigments==c)];
        unknownSyllableCounts = [unknownSyllableCounts, sum(unknownClusterAssigments==c)];
    end
    [maxThisCount, maxIdx] = max(thisSyllableCounts);
    otherCount = otherSyllableCounts(maxIdx);
    unknownCount = unknownSyllableCounts(maxIdx);
    accuracy(k) = (maxThisCount - otherCount)/sum(thisSyllableCounts);
end
% disp('Accuracy:')
% disp(categories)
% disp(accuracy)
% fprintf('extra weight = %d\n', extraWeightFactor);
fprintf('Average accuracy: %0.03f\n', mean(accuracy));
fprintf('Uncategorized frac: %0.03f\n', uncategorizedFrac);

for k = uniqueClusterIdx
    fprintf('Cluster ID: %s Members: %s\n', categoryClusterTitles{k}, sort([titles{clusterIdx==k}], 'descend'))
end
fprintf('Rejected IDs:')
fprintf('%s\n', sort([titles{isnan(clusterIdx)}], 'descend'))

plot = false;
if plot
    plotColors = colors(clusterIdx);
    means = [];
    for k = 1:numCategories
        catIdx = strcmp(titles, categories{k});
        means(k, :) = mean(transformedObservations(catIdx, :), 1);
        stds(k, :)  =  std(transformedObservations(catIdx, :), 1);
    end

    x = transformedObservations(:, 1);
    y = transformedObservations(:, 2);
    z = transformedObservations(:, 3);
    %titles = titles(:);
    xlimAll = [min(x), max(x)];
    ylimAll = [min(y), max(y)];
    zlimAll = [min(z), max(z)];

    xTrain = transformedObservations(trainingSet, 1);
    yTrain = transformedObservations(trainingSet, 2);
    zTrain = transformedObservations(trainingSet, 3);
    titlesTrain = titles(trainingSet);
    xlimTrain = [min(xTrain), max(xTrain)];
    ylimTrain = [min(yTrain), max(yTrain)];
    zlimTrain = [min(zTrain), max(zTrain)];

    xValidate = transformedObservations(validationSet, 1);
    yValidate = transformedObservations(validationSet, 2);
    zValidate = transformedObservations(validationSet, 3);
    titlesValidate = titles(validationSet);
    xlimValidate = [min(xValidate), max(xValidate)];
    ylimValidate = [min(yValidate), max(yValidate)];
    zlimValidate = [min(zValidate), max(zValidate)];

    figure; 
    for k = 1:numCategories
        plot3(x(clusterIdx==k), y(clusterIdx==k), z(clusterIdx==k), '+', 'Color', colors{k});
    end
    figure; ax = axes();
    for k = 1:numCategories
        text(x(clusterIdx==k), y(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
        xlim(ax, xlimAll);
        ylim(ax, ylimAll);
    end
    figure; ax = axes();
    for k = 1:numCategories
        text(y(clusterIdx==k), z(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
        xlim(ax, ylimAll);
        ylim(ax, zlimAll);
    end
    figure; ax = axes();
    for k = 1:numCategories
        text(z(clusterIdx==k), x(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
        xlim(ax, zlimAll);
        ylim(ax, xlimAll);
    end
end