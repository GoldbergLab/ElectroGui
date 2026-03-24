function egm_Compute_event_feature_stats(obj)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% egm_Compute_event_feature_stats: Compute statistics for event features
%   across a dataset for use in automated spike sorting/cleanup.
%
% For each selected event source, this macro:
%   1. Samples events across files (all or a random subset)
%   2. Runs selected ega_* feature extractors on those events
%   3. Computes robust statistics (median, MAD) for each feature
%   4. Optionally rejects outliers and recomputes
%   5. Computes a PCA transform on the standardized feature matrix
%   6. Stores everything in dbase.EventFeatureStats{eventSourceIdx}
%
% The stored stats can then be used to:
%   - Visualize the "typical" spike distribution as an ellipse overlay
%   - Automatically filter spikes that deviate from the distribution
%   - View events in PCA-transformed feature space
%
% Prerequisites:
%   - Event detection must have already been run (threshold set, events
%     detected) for the event sources you want to analyze.
%
% See also: ega_AP_amplitude, ega_Half_width, ega_Waveform_energy
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arguments
    obj electro_gui
end

%% Validate that data is loaded
if ~electro_gui.isDataLoaded(obj.dbase)
    warndlg('Please load or create a dbase first.');
    return;
end

numFiles = electro_gui.getNumFiles(obj.dbase);
numEventSources = length(obj.dbase.EventSources);

if numEventSources == 0
    warndlg('No event sources found. Please detect events first.');
    return;
end

%% Build the configuration GUI
featurePlugins = obj.plugins.eventFeatures;
featureNames = {featurePlugins.name};
numFeatures = length(featureNames);

% Build event source display names
eventSourceNames = cell(1, numEventSources);
for sourceIdx = 1:numEventSources
    channelName = obj.dbase.EventSources{sourceIdx};
    filterName = obj.dbase.EventFunctions{sourceIdx};
    detectorName = obj.dbase.EventDetectors{sourceIdx};
    eventSourceNames{sourceIdx} = sprintf('%s - %s - %s', channelName, filterName, detectorName);
end

[selections, ok] = configDialog(eventSourceNames, featureNames, numFiles);
if ~ok
    return;
end

selectedSourceIndices = selections.eventSources;
selectedFeatureIndices = selections.features;
numFilesToSample = selections.numFiles;
outlierMADs = selections.outlierMADs;
computeFeatureStats = selections.computeFeatureStats;
computeWaveformPCA = selections.computeWaveformPCA;
minPeakToTrough = selections.minPeakToTrough;
waveformSmoothWidth = selections.waveformSmoothWidth;

selectedFeatureNames = featureNames(selectedFeatureIndices);
numSelectedFeatures = length(selectedFeatureIndices);

%% Process each selected event source
progressBar = waitbar(0, 'Computing event feature statistics...');

for sourceNum = 1:length(selectedSourceIndices)
    eventSourceIdx = selectedSourceIndices(sourceNum);

    if ~isvalid(progressBar)
        return;
    end
    waitbar((sourceNum - 1) / length(selectedSourceIndices), progressBar, ...
        sprintf('Processing event source %d of %d...', sourceNum, length(selectedSourceIndices)));

    % Get event source info
    [channelNum, filterName, ~, ~, filterParams, eventXLims, ~, ~, isPseudoChannel] = ...
        obj.GetEventSourceInfo(eventSourceIdx);
    windowSamples = round(eventXLims * obj.dbase.Fs);

    % Determine which event part to use (default to first)
    eventPartIdx = 1;

    % Select which files to sample
    filesWithEvents = findFilesWithEvents(obj.dbase, eventSourceIdx, eventPartIdx);
    if isempty(filesWithEvents)
        electro_gui.issueWarning( ...
            sprintf('No events found for event source %d, skipping.', eventSourceIdx), ...
            'noEventsForStats');
        continue;
    end

    if numFilesToSample < length(filesWithEvents)
        sampledFiles = sort(randsample(filesWithEvents, numFilesToSample));
    else
        sampledFiles = filesWithEvents;
    end

    % Collect feature values and waveforms across all sampled files
    allFeatureValues = [];  % Will become NxF matrix (N events, F features)
    allWaveforms = [];      % Will become NxW matrix (N events, W snippet samples)

    for fileIdx = 1:length(sampledFiles)
        filenum = sampledFiles(fileIdx);

        if ~isvalid(progressBar)
            return;
        end
        totalEvents = size(allFeatureValues, 1) + size(allWaveforms, 1);
        overallProgress = ((sourceNum - 1) + fileIdx / length(sampledFiles)) / length(selectedSourceIndices);
        waitbar(overallProgress, progressBar, ...
            sprintf('Source %d/%d, file %d/%d (%d events so far)', ...
            sourceNum, length(selectedSourceIndices), ...
            fileIdx, length(sampledFiles), totalEvents));

        % Load channel data for this file
        try
            [channelData, fs] = obj.loadChannelData(channelNum, ...
                'FilterName', filterName, ...
                'FilterParams', filterParams, ...
                'FileNum', filenum, ...
                'IsPseudoChannel', isPseudoChannel);
        catch ME
            electro_gui.issueWarning( ...
                sprintf('Failed to load file %d: %s', filenum, ME.message), ...
                'fileLoadFail');
            continue;
        end

        % Get event times for this file
        allEventTimes = obj.dbase.EventTimes{eventSourceIdx}(:, filenum);
        eventSamples = allEventTimes{eventPartIdx};
        if isempty(eventSamples)
            continue;
        end
        numEventsThisFile = length(eventSamples);

        % Run each selected feature extractor
        if computeFeatureStats && numSelectedFeatures > 0
            fileFeatures = NaN(numEventsThisFile, numSelectedFeatures);
            for featureIdx = 1:numSelectedFeatures
                pluginIdx = selectedFeatureIndices(featureIdx);
                try
                    [featureValues, ~] = electro_gui.eg_runPlugin( ...
                        featurePlugins, featureNames{pluginIdx}, ...
                        channelData, fs, allEventTimes, eventPartIdx, windowSamples);
                    fileFeatures(:, featureIdx) = featureValues(:);
                catch ME
                    electro_gui.issueWarning( ...
                        sprintf('Feature %s failed on file %d: %s', ...
                        featureNames{pluginIdx}, filenum, ME.message), ...
                        'featureExtractFail');
                end
            end
            allFeatureValues = [allFeatureValues; fileFeatures]; %#ok<AGROW>
        end

        % Extract amplitude-normalized waveform snippets
        if computeWaveformPCA
            [normalizedWaveforms, ~] = electro_gui.conditionSpikeWaveforms( ...
                channelData, eventSamples, windowSamples(1), windowSamples(2), ...
                'MinPeakToTrough', minPeakToTrough, ...
                'SmoothWidth', waveformSmoothWidth);
            allWaveforms = [allWaveforms; normalizedWaveforms]; %#ok<AGROW>
        end
    end

    %% Compute feature statistics and feature PCA
    featureMedians = [];
    featureMADs = [];
    pcaCoeffs = [];
    pcaMedians = [];
    pcaMADs = [];
    featureNs = [];

    if computeFeatureStats && ~isempty(allFeatureValues) && size(allFeatureValues, 1) >= 2
        % Remove rows with any NaN or Inf (from failed feature extractions
        % or features like Preceding_ISI that return Inf for edge events)
        validRows = all(isfinite(allFeatureValues), 2);
        allFeatureValues = allFeatureValues(validRows, :);

        if size(allFeatureValues, 1) >= 2
            % Compute robust statistics (first pass)
            featureMedians = median(allFeatureValues, 1);
            featureMADs = mad(allFeatureValues, 1, 1);

            % Optional outlier rejection pass
            if outlierMADs > 0 && ~isinf(outlierMADs)
                safeMADs = featureMADs;
                safeMADs(safeMADs == 0) = Inf;
                zScores = abs(allFeatureValues - featureMedians) ./ safeMADs;
                inlierMask = all(zScores <= outlierMADs, 2);
                allFeatureValues = allFeatureValues(inlierMask, :);

                if size(allFeatureValues, 1) >= 2
                    featureMedians = median(allFeatureValues, 1);
                    featureMADs = mad(allFeatureValues, 1, 1);
                end
            end

            featureNs = repmat(size(allFeatureValues, 1), 1, numSelectedFeatures);

            if size(allFeatureValues, 1) >= 2 && numSelectedFeatures >= 2
                % Compute PCA on standardized features
                safeMADs = featureMADs;
                safeMADs(safeMADs == 0) = 1;
                standardized = (allFeatureValues - featureMedians) ./ safeMADs;
                [pcaCoeffs, pcaScores, ~] = pca(standardized);
                pcaMedians = median(pcaScores, 1);
                pcaMADs = mad(pcaScores, 1, 1);
            end
        end
    elseif computeFeatureStats
        electro_gui.issueWarning( ...
            sprintf('Not enough events for event source %d to compute feature statistics.', eventSourceIdx), ...
            'tooFewEvents');
    end

    %% Compute waveform PCA
    waveformPCACoeffs = [];
    waveformMean = [];
    waveformPcaMedians = [];
    waveformPcaMADs = [];

    if computeWaveformPCA && ~isempty(allWaveforms) && size(allWaveforms, 1) >= 2
        % Compute the mean normalized waveform and subtract it
        waveformMean = mean(allWaveforms, 1);
        centeredWaveforms = allWaveforms - waveformMean;

        % Compute PCA on the centered, amplitude-normalized waveforms
        snippetLength = size(centeredWaveforms, 2);
        numComponents = min(size(centeredWaveforms, 1) - 1, snippetLength);
        [waveformPCACoeffs, waveformPcaScores, ~] = pca(centeredWaveforms, 'NumComponents', numComponents);
        waveformPcaMedians = median(waveformPcaScores, 1);
        waveformPcaMADs = mad(waveformPcaScores, 1, 1);
    elseif computeWaveformPCA
        electro_gui.issueWarning( ...
            sprintf('Not enough valid waveforms for event source %d to compute waveform PCA.', eventSourceIdx), ...
            'tooFewWaveforms');
    end

    %% Store results via the validated setter
    obj.setEventFeatureStats(eventSourceIdx, selectedFeatureNames, ...
        'medians', featureMedians, ...
        'MADs', featureMADs, ...
        'Ns', featureNs, ...
        'PCA', pcaCoeffs, ...
        'pcaMedians', pcaMedians, ...
        'pcaMADs', pcaMADs, ...
        'waveformPCA', waveformPCACoeffs, ...
        'waveformMean', waveformMean, ...
        'waveformWindow', windowSamples, ...
        'waveformSmoothWidth', waveformSmoothWidth, ...
        'waveformPcaMedians', waveformPcaMedians, ...
        'waveformPcaMADs', waveformPcaMADs, ...
        'outlierMADs', outlierMADs, ...
        'numFilesSampled', length(sampledFiles));
end

if isvalid(progressBar)
    delete(progressBar);
end

msgbox(sprintf('Event feature statistics computed for %d event source(s).', length(selectedSourceIndices)));
end

%% Helper functions

function filesWithEvents = findFilesWithEvents(dbase, eventSourceIdx, eventPartIdx)
    % Return a list of file numbers that have at least one event for the
    % given event source and part.
    numFiles = electro_gui.getNumFiles(dbase);
    filesWithEvents = [];
    for filenum = 1:numFiles
        if eventPartIdx <= size(dbase.EventTimes{eventSourceIdx}, 1) && ...
                filenum <= size(dbase.EventTimes{eventSourceIdx}, 2)
            eventSamples = dbase.EventTimes{eventSourceIdx}{eventPartIdx, filenum};
            if ~isempty(eventSamples)
                filesWithEvents(end + 1) = filenum; %#ok<AGROW>
            end
        end
    end
end

function [selections, ok] = configDialog(eventSourceNames, featureNames, numFiles)
    % Display a configuration dialog for the macro and return user selections.
    ok = false;
    selections = struct();

    numSources = length(eventSourceNames);
    numFeatures = length(featureNames);

    % Compute figure dimensions
    rowHeight = 22;
    margin = 10;
    sectionGap = 15;

    % Sections: event sources, features, settings, buttons
    sourceSectionHeight = numSources * rowHeight + 30;
    featureSectionHeight = numFeatures * rowHeight + 30;
    settingsSectionHeight = 6 * rowHeight + 20;
    buttonHeight = 35;

    figHeight = margin + sourceSectionHeight + sectionGap + featureSectionHeight + ...
        sectionGap + settingsSectionHeight + sectionGap + buttonHeight + margin;
    figWidth = 420;

    fig = figure('Name', 'Compute Event Feature Statistics', ...
        'NumberTitle', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
        'Resize', 'off', 'WindowStyle', 'modal', ...
        'Position', [300, 200, figWidth, figHeight]);

    yPos = figHeight - margin;

    % Event source selection
    yPos = yPos - 20;
    uicontrol(fig, 'Style', 'text', 'String', 'Event sources:', ...
        'Position', [margin, yPos, figWidth - 2*margin, 18], ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    yPos = yPos - 2;

    sourceCheckboxes = gobjects(1, numSources);
    for k = 1:numSources
        yPos = yPos - rowHeight;
        sourceCheckboxes(k) = uicontrol(fig, 'Style', 'checkbox', ...
            'String', eventSourceNames{k}, 'Value', 1, ...
            'Position', [margin + 10, yPos, figWidth - 2*margin - 10, rowHeight]);
    end

    % Feature selection
    yPos = yPos - sectionGap - 20;
    uicontrol(fig, 'Style', 'text', 'String', 'Features:', ...
        'Position', [margin, yPos, figWidth - 2*margin, 18], ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold');
    yPos = yPos - 2;

    featureCheckboxes = gobjects(1, numFeatures);
    for k = 1:numFeatures
        yPos = yPos - rowHeight;
        % Default to checked, except for features that are unlikely to be
        % useful for spike sorting (event number, time)
        defaultOn = ismember(featureNames{k}, { ...
            'Peak_amplitude', 'Trough_depth', 'Half_width', ...
            'Waveform_energy', 'Repolarization_slope', ...
            'Following_ISI', 'Spike_symmetry'});
        featureCheckboxes(k) = uicontrol(fig, 'Style', 'checkbox', ...
            'String', featureNames{k}, 'Value', defaultOn, ...
            'Position', [margin + 10, yPos, figWidth - 2*margin - 10, rowHeight]);
    end

    % Settings
    yPos = yPos - sectionGap - 20;
    uicontrol(fig, 'Style', 'text', 'String', 'Settings:', ...
        'Position', [margin, yPos, figWidth - 2*margin, 18], ...
        'HorizontalAlignment', 'left', 'FontWeight', 'bold');

    yPos = yPos - rowHeight;
    computeFeatureStatsCheckbox = uicontrol(fig, 'Style', 'checkbox', ...
        'String', 'Compute feature statistics and feature PCA', 'Value', 1, ...
        'Position', [margin + 10, yPos, figWidth - 2*margin - 10, rowHeight]);

    yPos = yPos - rowHeight;
    computeWaveformPCACheckbox = uicontrol(fig, 'Style', 'checkbox', ...
        'String', 'Compute waveform PCA', 'Value', 1, ...
        'Position', [margin + 10, yPos, figWidth - 2*margin - 10, rowHeight]);

    yPos = yPos - rowHeight;
    uicontrol(fig, 'Style', 'text', 'String', 'Files to sample (0 = all):', ...
        'Position', [margin + 10, yPos, 180, rowHeight], ...
        'HorizontalAlignment', 'left');
    numFilesEdit = uicontrol(fig, 'Style', 'edit', ...
        'String', num2str(min(200, numFiles)), ...
        'Position', [200, yPos + 2, 80, rowHeight - 4]);

    yPos = yPos - rowHeight;
    uicontrol(fig, 'Style', 'text', 'String', 'Outlier rejection (MADs, 0 = off):', ...
        'Position', [margin + 10, yPos, 180, rowHeight], ...
        'HorizontalAlignment', 'left');
    outlierEdit = uicontrol(fig, 'Style', 'edit', ...
        'String', '3', ...
        'Position', [200, yPos + 2, 80, rowHeight - 4]);

    yPos = yPos - rowHeight;
    uicontrol(fig, 'Style', 'text', 'String', 'Min peak-to-trough for waveform PCA:', ...
        'Position', [margin + 10, yPos, 230, rowHeight], ...
        'HorizontalAlignment', 'left');
    minPTTEdit = uicontrol(fig, 'Style', 'edit', ...
        'String', '0', ...
        'Position', [250, yPos + 2, 80, rowHeight - 4]);

    yPos = yPos - rowHeight;
    uicontrol(fig, 'Style', 'text', 'String', 'Waveform smooth width (samples, 0 = off):', ...
        'Position', [margin + 10, yPos, 230, rowHeight], ...
        'HorizontalAlignment', 'left');
    smoothWidthEdit = uicontrol(fig, 'Style', 'edit', ...
        'String', '3', ...
        'Position', [250, yPos + 2, 80, rowHeight - 4]);

    % Buttons
    yPos = yPos - sectionGap - buttonHeight;
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Run', ...
        'Position', [figWidth/2 - 110, yPos, 100, 30], ...
        'Callback', @(~,~) onOK());
    uicontrol(fig, 'Style', 'pushbutton', 'String', 'Cancel', ...
        'Position', [figWidth/2 + 10, yPos, 100, 30], ...
        'Callback', @(~,~) onCancel());

    uiwait(fig);

    function onOK()
        selections.eventSources = find(arrayfun(@(cb) cb.Value, sourceCheckboxes));
        selections.features = find(arrayfun(@(cb) cb.Value, featureCheckboxes));
        selections.computeFeatureStats = logical(computeFeatureStatsCheckbox.Value);
        selections.computeWaveformPCA = logical(computeWaveformPCACheckbox.Value);

        numFilesVal = str2double(numFilesEdit.String);
        if isnan(numFilesVal) || numFilesVal <= 0
            numFilesVal = numFiles;
        end
        selections.numFiles = round(numFilesVal);

        outlierVal = str2double(outlierEdit.String);
        if isnan(outlierVal) || outlierVal < 0
            outlierVal = 0;
        end
        selections.outlierMADs = outlierVal;

        minPTTVal = str2double(minPTTEdit.String);
        if isnan(minPTTVal) || minPTTVal < 0
            minPTTVal = 0;
        end
        selections.minPeakToTrough = minPTTVal;

        smoothWidthVal = str2double(smoothWidthEdit.String);
        if isnan(smoothWidthVal) || smoothWidthVal < 0
            smoothWidthVal = 0;
        end
        selections.waveformSmoothWidth = round(smoothWidthVal);

        if isempty(selections.eventSources)
            warndlg('Please select at least one event source.');
            return;
        end
        if ~selections.computeFeatureStats && ~selections.computeWaveformPCA
            warndlg('Please select at least one computation (feature stats or waveform PCA).');
            return;
        end

        ok = true;
        delete(fig);
    end

    function onCancel()
        ok = false;
        delete(fig);
    end
end
