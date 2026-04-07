function [meanWaveform, stdWaveform, tMs, numUsed] = computeAverageEventWaveform(dbaseInput, eventSourceIdx, options)
    % Compute the mean and standard deviation waveform for an event source
    % by randomly sampling events across files.
    %
    % Usage:
    %   % From a dbase .mat file path:
    %   [mu, sd, t] = computeAverageEventWaveform('path/to/dbase.mat', 1);
    %
    %   % From pre-loaded dbase and settings structs:
    %   [mu, sd, t] = computeAverageEventWaveform(dbase, 1, 'Settings', settings);
    %
    %   % With explicit EventXLims in ms (no settings needed):
    %   [mu, sd, t] = computeAverageEventWaveform(dbase, 1, 'EventXLims', [-1, 3]);
    %
    %   % Limit to 500 randomly sampled events:
    %   [mu, sd, t] = computeAverageEventWaveform(dbase, 1, 'NumEvents', 500, ...
    %       'Settings', settings);
    %
    % Arguments:
    %   dbaseInput     - either a path to a dbase .mat file (char/string),
    %                    or a pre-loaded dbase struct
    %   eventSourceIdx - index into dbase.EventTimes
    %
    % Optional name-value arguments:
    %   Settings     - electro_gui settings struct. Required when
    %                  dbaseInput is a struct and EventXLims is not given.
    %                  Automatically loaded from file when dbaseInput is a
    %                  path.
    %   EventXLims   - [startOffset, stopOffset] in ms. Overrides the 
    %                  value in Settings.EventXLims.
    %   NumEvents    - number of events to randomly sample. When 0 or
    %                  greater than the total event count, all events are
    %                  used. Default: 0 (all).
    %   EventPartIdx - which event part to use (default 1)
    %   Loader       - function handle or loader plugin name, passed
    %                  through to getEventWaveforms. Only needed when
    %                  ChannelData is not pre-loaded (i.e., the function
    %                  must load from disk). Defaults to the loader
    %                  registered in dbase.
    %   Seed         - random seed for reproducibility (default: no seed)
    %   ShowProgress - if true, display progress updates via
    %                  displayProgress (default: false)
    %
    % Returns:
    %   meanWaveform - 1xW mean waveform vector
    %   stdWaveform  - 1xW standard deviation vector
    %   tMs          - 1xW time vector in milliseconds relative to event
    %   numUsed      - number of waveforms that contributed to the average
    %                  (may be less than NumEvents if some files had issues)
    arguments
        dbaseInput
        eventSourceIdx (1, 1) double {mustBePositive, mustBeInteger}
        options.Settings = []
        options.EventXLims = []
        options.NumEvents (1, 1) double {mustBeNonnegative, mustBeInteger} = 0
        options.EventPartIdx (1, 1) double {mustBePositive, mustBeInteger} = 1
        options.Loader = []
        options.Seed = []
        options.ShowProgress (1, 1) logical = false
    end

    % --- Load dbase (and settings) from file if needed ---
    if istext(dbaseInput)
        S = load(dbaseInput, 'dbase', 'settings');
        if ~isfield(S, 'dbase')
            error('computeAverageEventWaveform:badFile', ...
                'File does not contain a dbase variable: %s', dbaseInput);
        end
        dbase = S.dbase;
        % Use file settings as fallback if caller didn't provide any
        if isempty(options.Settings) && isfield(S, 'settings')
            options.Settings = S.settings;
        end
    elseif isstruct(dbaseInput)
        dbase = dbaseInput;
    else
        error('computeAverageEventWaveform:badInput', ...
            'dbaseInput must be a file path or a dbase struct.');
    end

    % --- Resolve EventXLims ---
    if ~isempty(options.EventXLims)
        eventXLims = options.EventXLims * 0.001;
    elseif ~isempty(options.Settings)
        eventXLims = options.Settings.EventXLims(eventSourceIdx, :);
    else
        error('computeAverageEventWaveform:noEventXLims', ...
            'Either EventXLims or Settings must be provided.');
    end

    % --- Count events per file and build a global event index ---
    % Each event is identified by (filenum, eventNum) where eventNum is the
    % index within that file's event list for the given part.
    eventPartIdx = options.EventPartIdx;
    numFiles = size(dbase.EventTimes{eventSourceIdx}, 2);

    % Count events in each file
    eventsPerFile = zeros(1, numFiles);
    for filenum = 1:numFiles
        eventTimesForFile = dbase.EventTimes{eventSourceIdx}{eventPartIdx, filenum};
        eventsPerFile(filenum) = length(eventTimesForFile);
    end
    totalEvents = sum(eventsPerFile);

    if totalEvents == 0
        meanWaveform = [];
        stdWaveform = [];
        tMs = [];
        numUsed = 0;
        return;
    end

    % --- Select events ---
    if ~isempty(options.Seed)
        rng(options.Seed);
    end

    if options.NumEvents == 0
        % Use all events
        selectedGlobalIdx = 1:totalEvents;
    elseif options.NumEvents > totalEvents
        error('computeAverageEventWaveform:tooFewEvents', ...
            'Requested %d events but only %d are available. Use NumEvents=0 to select all.', ...
            options.NumEvents, totalEvents);
    else
        selectedGlobalIdx = sort(randperm(totalEvents, options.NumEvents));
    end

    % Map global indices to (filenum, eventNum) pairs.
    % Build cumulative event counts to map global index -> file.
    cumEvents = [0, cumsum(eventsPerFile)];
    selectedFilenums = zeros(1, length(selectedGlobalIdx));
    selectedEventNums = zeros(1, length(selectedGlobalIdx));
    for selIdx = 1:length(selectedGlobalIdx)
        globalIdx = selectedGlobalIdx(selIdx);
        % Find which file this global index falls in
        filenum = find(cumEvents >= globalIdx, 1) - 1;
        localEventNum = globalIdx - cumEvents(filenum);
        selectedFilenums(selIdx) = filenum;
        selectedEventNums(selIdx) = localEventNum;
    end

    % --- Build the canonical time vector for the full window ---
    channelNum = dbase.EventChannels(eventSourceIdx);
    canonicalFs = dbase.ChannelFs(channelNum);
    leftSamples = round(eventXLims(1) * canonicalFs);
    rightSamples = round(eventXLims(2) * canonicalFs);
    canonicalT = (leftSamples:rightSamples) / canonicalFs;
    canonicalLength = length(canonicalT);

    % --- Group selected events by file for efficient loading ---
    uniqueFiles = unique(selectedFilenums);

    % Pre-allocate: collect all waveforms into a matrix after we know the
    % canonical length. Until then, accumulate in a cell array.
    allWaveforms = {};

    % Build common arguments for getEventWaveforms
    extraArgs = {};
    if ~isempty(options.EventXLims)
        extraArgs = [extraArgs, {'EventXLims', options.EventXLims}];
    end
    if ~isempty(options.Settings)
        extraArgs = [extraArgs, {'Settings', options.Settings}];
    end
    if ~isempty(options.Loader)
        extraArgs = [extraArgs, {'Loader', options.Loader}];
    end

    numUniqueFiles = length(uniqueFiles);
    for fileIdx = 1:numUniqueFiles
        filenum = uniqueFiles(fileIdx);

        if options.ShowProgress
            displayProgress('Loading waveforms from file %d of %d...\n', ...
                fileIdx, numUniqueFiles);
        end

        % Get all waveforms for this file (we extract all, then pick the
        % selected ones — simpler than trying to extract a subset, and
        % getEventWaveforms is fast once the channel data is loaded)
        try
            [fileWaveforms, fileTMs] = electro_gui.getEventWaveforms( ...
                dbase, filenum, eventSourceIdx, ...
                'EventPartIdx', eventPartIdx, extraArgs{:});
        catch ME
            warning('computeAverageEventWaveform:loadError', ...
                'Failed to load waveforms for file %d: %s', filenum, ME.message);
            continue;
        end

        % Pick selected events from this file and align to canonical grid
        fileMask = selectedFilenums == filenum;
        fileEventNums = selectedEventNums(fileMask);

        for eventNum = fileEventNums
            if eventNum > length(fileWaveforms) || isempty(fileWaveforms{eventNum})
                continue;
            end

            waveform = fileWaveforms{eventNum};
            tVec = fileTMs{eventNum};

            if length(waveform) == canonicalLength
                % Full-width waveform — no padding needed
                allWaveforms{end+1} = waveform(:)'; %#ok<AGROW>
            else
                % Edge-truncated waveform — place into canonical grid
                % Find where this waveform's time range starts in the
                % canonical vector by matching the first time point
                paddedWaveform = NaN(1, canonicalLength);
                % Round to avoid floating point mismatches
                startOffset = round((tVec(1) - canonicalT(1)) * canonicalFs);
                insertIdx = 1 + startOffset;
                insertEnd = insertIdx + length(waveform) - 1;
                % Clamp to valid range
                insertIdx = max(1, insertIdx);
                insertEnd = min(canonicalLength, insertEnd);
                srcStart = insertIdx - startOffset;
                srcEnd = srcStart + (insertEnd - insertIdx);
                paddedWaveform(insertIdx:insertEnd) = waveform(srcStart:srcEnd);
                allWaveforms{end+1} = paddedWaveform; %#ok<AGROW>
            end
        end
    end

    % --- Compute mean and std ---
    numUsed = length(allWaveforms);
    if numUsed == 0
        meanWaveform = [];
        stdWaveform = [];
        tMs = [];
        return;
    end

    % Stack into a matrix (numUsed x canonicalLength)
    waveformMatrix = vertcat(allWaveforms{:});

    % nanmean/nanstd to handle any NaN-padded edges
    meanWaveform = mean(waveformMatrix, 1, 'omitnan');
    stdWaveform = std(waveformMatrix, 0, 1, 'omitnan');
    tMs = canonicalT;
end
