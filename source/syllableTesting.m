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
    };

colors = cellfun(@(x)x/255, colors, 'UniformOutput', false);

load('syllablePrints.mat', 'collectedSyllablePrints', 'syllablePrintsWithStats');

otherObservations = [];
otherFields = {'preSyllableISIs', 'preSyllableIOIs', 'preSyllableDurations', 'durations', 'postSyllableISIs', 'postSyllableIOIs', 'postSyllableDurations'};

numSyllables = length(collectedSyllablePrints);
numOtherFields = length(otherFields);

for k = 1:numOtherFields
    obs = {collectedSyllablePrints.(otherFields{k})};
    for j = 1:numSyllables
        if isempty(obs{j})
            obs{j} = nan;
        end
    end
    otherObservations(:, k) = cell2mat(obs);
end

unknownTitle = '+';

titles = {collectedSyllablePrints.title};
titles(strcmp(titles, 'unknown')) = {unknownTitle};

trainingSet = ~strcmp(titles, unknownTitle);
validationSet = strcmp(titles, unknownTitle);

categories = unique(titles(trainingSet));

% Replace nan with mean
for j = 1:numSyllables
    for k = 1:numOtherFields
        if isnan(otherObservations(j, k));
            otherObservations(j, k) = nanmean(otherObservations(:, k));
        end
    end
end

ffts = cat(1, collectedSyllablePrints.ffts);
observations = cat(2, otherObservations, ffts);

weights = 1./var(observations);
% if ~exist('extraWeightFactor', 'var')
%     extraWeightFactor = 10;
%     fprintf('Using default extra weight factor: %d\n', extraWeightFactor);
% end

weightFactors = 10*[10, 10, 10, 10, 10, 10, 10];
weights(1:7) = weights(1:7) .* weightFactors; %* extraWeightFactor;

[wcoeff, transformedObservations] = pca(observations, 'VariableWeights', weights);

numKDims = 20;

startingCentroids = [];
for k = 1:length(categories)
    thisTitle = categories{k};
    startingCentroids(k, :) = mean(transformedObservations(strcmp(titles, thisTitle), :), 1);
end

centroidScale = max(startingCentroids(:));

startingCentroids = cat(1, startingCentroids, (rand([10, size(startingCentroids, 2)])-0.5)*centroidScale);

clusterIdx = kmeans(transformedObservations(:, 1:numKDims), [], 'Start', cat(1, startingCentroids(:, 1:numKDims)), 'EmptyAction', 'drop');

accuracy = zeros(size(categories));
unknownClusterAssigments = clusterIdx(strcmp(titles, unknownTitle));
uncategorizedCount = 0;
for c = unique(clusterIdx)'
    if ~any(~strcmp(titles(clusterIdx==c), unknownTitle));
        uncategorizedCount = uncategorizedCount + sum(clusterIdx==c); 
    end
end
uncategorizedFrac = uncategorizedCount / sum(strcmp(titles, unknownTitle));
for k = 1:length(categories)
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

plotColors = colors(clusterIdx);

means = [];
for k = 1:length(categories)
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
for k = 1:length(categories)
    plot3(x(clusterIdx==k), y(clusterIdx==k), z(clusterIdx==k), '+', 'Color', colors{k});
end
figure; ax = axes();
for k = 1:length(categories)
    text(x(clusterIdx==k), y(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
    xlim(ax, xlimAll);
    ylim(ax, ylimAll);
end
figure; ax = axes();
for k = 1:length(categories)
    text(y(clusterIdx==k), z(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
    xlim(ax, ylimAll);
    ylim(ax, zlimAll);
end
figure; ax = axes();
for k = 1:length(categories)
    text(z(clusterIdx==k), x(clusterIdx==k), titles(clusterIdx==k), 'Parent', ax, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', colors{k});
    xlim(ax, zlimAll);
    ylim(ax, xlimAll);
end

return;



rx = rand(size(collectedSyllablePrints))*10;
figure; hold on;
for j = 1:length(syllablePrintsWithStats)
    m = syllablePrintsWithStats(j).meanDuration;
    s = 3*syllablePrintsWithStats(j).stdDuration;
    fill([j/2, 10, 10, j/2], [m-s, m-s, m+s, m+s], colors{j});
end
plot(rx, [collectedSyllablePrints.durations], 'ko');

figure; hold on;
for j = 1:length(syllablePrintsWithStats)
    m = syllablePrintsWithStats(j).meanPreISI;
    s = 3*syllablePrintsWithStats(j).stdPreISI;
    fill([j/2, 10, 10, j/2], [m-s, m-s, m+s, m+s], colors{j});
end
plot(rx, [collectedSyllablePrints.preSyllableISIs], 'ko');

figure; hold on;
for j = 1:length(syllablePrintsWithStats)
    m = syllablePrintsWithStats(j).meanPreISI;
    s = 3*syllablePrintsWithStats(j).stdPreISI;
    fill([j/2, 10, 10, j/2], [m-s, m-s, m+s, m+s], colors{j});
end
plot(rx, [collectedSyllablePrints.preSyllableISIs], 'ko');

collectedSyllablePrints = randsample(collectedSyllablePrints, 100);

IDs = [];

for k = 1:length(collectedSyllablePrints)
    fftDiscrepancies = [];
    for j = 1:length(syllablePrintsWithStats)
%    discrepancies(k) = mean(abs(xs(k).ffts - xs(baseIdx).ffts));
%    discrepancies(k) = sqrt(mean((xs(k).ffts - xs(baseIdx).ffts).^2));
        fftDiscrepancies(j) = 1 - max(xcorr(collectedSyllablePrints(k).ffts, syllablePrintsWithStats(j).meanFFT, 20, 'coeff'));
    end
    durationDiscrepancies = [];
    for j = 1:length(syllablePrintsWithStats)
        disp('Duration discrepancy:');
        d = collectedSyllablePrints(k).durations
        md = syllablePrintsWithStats(j).meanDuration
        sd = syllablePrintsWithStats(j).stdDuration
        zd = (d - md)/(3*sd)
        durationDiscrepancies(j) = 1 - (normcdf(zd) - normcdf(-zd))
    end
    discrepancies = fftDiscrepancies .* durationDiscrepancies;
    [~, idx] = min(discrepancies);
    IDs(end+1) = idx;
end


[IDso, idx] = sort(IDs);
xso = collectedSyllablePrints(idx);
figure; hold on;
for k = 1:length(xso)
    plot(10*(k-1)*ones(size(xso(k).ffts)), 'Color', 'black');
    plot(xso(k).ffts + 10*(k-1), 'Color', colors{IDso(k)});
end
ylim([0, 10*length(xso)]);