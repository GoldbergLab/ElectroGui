classdef RasterGUI < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RasterGUI: Sorted raster plot viewer for electro_gui
%
% Generates peri-stimulus raster plots and PSTHs by aligning neural
% events to behavioral triggers (syllable onsets, markers, motifs, etc.)
% with support for sorting, filtering, and time warping.
%
% Usage:
%   raster = RasterGUI(eg)  % eg is an electro_gui instance
%   raster.show()           % Show the raster GUI window
%
% See also: electro_gui
%
% Based on egm_Sorted_rasters by Aaron Andalman, Jesse Goldberg, et al.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Properties - electro_gui reference
    properties% (SetAccess = private)  % TODO: restore access control
        eg electro_gui  % Reference to parent electro_gui instance
    end

    %% Properties - GUI widgets
    properties% (Access = private)  % TODO: restore access control
        % Figure
        figure_Main matlab.ui.Figure

        % Axes
        axes_Raster matlab.graphics.axis.Axes
        axes_PSTH matlab.graphics.axis.Axes
        axes_Hist matlab.graphics.axis.Axes

        % Tab group
        tab_group

        % Trigger panel
        popup_TriggerSource
        popup_TriggerType
        popup_TriggerAlignment
        check_ExcludeIncomplete
        check_PlotOtherTrialTriggers
        % Trigger label coloring controls
        list_TriggerLabels
        panel_SelectedTrigLabel   % Colored indicator for selected trigger label
        text_SelectedTrigLabel    % Text inside the indicator
        push_TrigLabelColor
        check_TrigAutoColor
        popup_TrigColormap
        check_TrigAutoUpdate
        push_TrigUpdate

        % Event series panel
        list_EventSeries
        push_EventSeriesAdd
        push_EventSeriesRemove
        panel_EventSeriesDetail  % Bordered panel for per-series controls
        % Event series detail controls (populated from selected series)
        edit_EventSeriesName
        popup_EventSeriesSource
        popup_EventSeriesType
        popup_EventSeriesFilterMode
        edit_EventSeriesFilterList
        % Burst-specific controls (visible only when type is Bursts/Burst events/Single events)
        text_EventSeriesBurstFreq
        edit_EventSeriesBurstFreq
        text_EventSeriesBurstMinSpikes
        edit_EventSeriesBurstMinSpikes
        popup_EventSeriesSelection
        push_EventSeriesColor
        check_EventSeriesPSTH
        popup_EventSeriesPSTHStyle

        % Window panel
        popup_StartReference
        popup_StopReference
        check_ExcludePartialEvents
        check_WindowAutoUpdate
        push_WindowUpdate

        % Sort panel
        popup_PrimarySort
        popup_SecondarySort
        radio_Ascending
        radio_Descending
        check_GroupLabels

        % Warp panel
        list_WarpPoints
        push_AddWarp
        push_RemoveWarp
        push_WarpOptions
        popup_WarpType

        % File panel
        popup_Files
        push_Open

        % Control buttons
        push_GenerateRaster

        % PSTH panel
        popup_PSTHUnits
        popup_PSTHCount

        % Window inline edits
        edit_PreStart
        edit_PostStop

        % Files inline edit
        edit_FileRange
        popup_PropertyFilterMode   % (None), Single, Expression
        popup_PropertyName         % Property name dropdown (for Single mode)
        edit_PropertyExpression    % Expression edit (for Expression mode)
        check_FilesAutoUpdate
        push_FilesUpdate

        % Plot inline edits
        check_AutoXLim
        check_PlotAutoUpdate
        push_PlotUpdate
        edit_XMin
        edit_XMax
        edit_TickHeight
        edit_BinSize
        edit_TickLineWidth
        edit_Overlap
        % Legend controls
        panel_Legend
        check_ShowLegend
        check_LegendTriggers
        check_LegendEvents

        % Trigger options (inline in tab)
        popup_TrigFilterMode    % 'All', 'Include', 'Exclude'
        edit_TrigFilterList


        % Presets tab
        popup_Presets
        push_LoadPreset
        push_SavePreset
        push_DeletePreset
        push_RefreshPresets

        % Export tab
        push_ExportFigure
        push_ExportPNG
        push_ExportPDF
        push_ExportJPG
        push_ExportSVG

        % Axes panel
        panel_Axes

        % Status bar
        statusBar StatusBar

        % Static text widgets
        text__TriggerType
        text_TriggerAlignment
        text_StartReference
        text_StopReference
        text_PreMinus
        text_PreUnit
        text_PostPlus
        text_PostUnit
        text_PrimarySort
        text_SecondarySort
        text_FileRange
        text_PSTHUnits
        text_PSTHCount
        text_XMin
        text_XMax
        text_TickHeight
        text_BinSize
        text_TickLineWidth
        text_Overlap
        text_ExportToFile
    end

    %% Properties - state
    properties% (Access = private)  % TODO: restore access control

        %
        % Trial data is immutable after generation. Sorting and filtering
        % are done by recomputing TrialOrder, an index vector into these
        % arrays, without touching the data itself.

        % 1xN struct array, one element per trial. Each element has:
        %   fileNum, isComplete, absTime, label, corrShift,
        %   onset, offset (current trigger boundaries, in seconds
        %       relative to the alignment point),
        %   prevOnset, prevOffset, nextOnset, nextOffset (neighboring
        %       trigger boundaries, in seconds relative to alignment),
        %   dataStart, dataStop (visible window bounds in seconds)
        TriggerData struct = struct( ...
            'fileNum', {}, ...
            'isComplete', {}, ...
            'absTime', {}, ...
            'label', {}, ...
            'corrShift', {}, ...
            'onset', {}, ...
            'offset', {}, ...
            'prevOnset', {}, ...
            'prevOffset', {}, ...
            'nextOnset', {}, ...
            'nextOffset', {}, ...
            'dataStart', {}, ...
            'dataStop', {} ...
        )

        % 1xNumEventSeries cell array. EventData{k} is a 1xN struct
        % array (same N as TriggerData) with fields:
        %   onsets  - double vector of event onset times (seconds,
        %             relative to alignment point)
        %   offsets - double vector of event offset times
        % Variable length per trial.
        EventData cell = {}

        % Index vector into TriggerData/EventData that defines the
        % current display order and filtering. Recomputed by
        % recomputeTrialOrder() when sort/filter settings change.
        % Plotting indexes as TriggerData(TrialOrder) and
        % EventData{k}(TrialOrder).
        TrialOrder double = []

        % Trigger label coloring: parallel arrays mapping label values
        % to RGB colors. Persists across generates so manual color
        % choices are preserved. New labels get auto-assigned or gray.
        TriggerLabelValues double = []      % Numeric label values (double of char)
        TriggerLabelColors double = []      % N x 3 RGB colors

        % File range
        FileRange double = []
        FileNames cell = {}

        % Histogram configuration (not yet exposed in GUI)
        HistBinSize double = [1, 1]
        HistSmoothingWindow double = 1

        % Full axis limits after last plot — used for double-click reset
        % and to clamp scroll-zoom/pan
        RasterFullYLim double = [0.5, 1.5]
        BackupXLim double = []        % Raster/PSTH X limits after last plot
        BackupPSTHYLim double = []    % PSTH Y limits after last plot
        BackupHistXLim double = []    % Hist X limits after last plot

        % Background color
        BackgroundColor double = [1, 1, 1]

        % Single source of truth for all GUI settings
        ControlParams struct = struct()

        % Warp points
        WarpPoints cell = {}

        % Preset system
        preset_prefix char = 'egsr_preset_'

        % Axis positions (for show/hide PSTH/hist)
        AxisPosRaster double = []
        AxisPosPSTH double = []

        % linkprop handles for axis linking. Stored as properties so
        % they don't get garbage collected (which would break the link).
        LinkXLim = []
        LinkYLim = []
        AxisPosHist double = []

        % Crosshair guide graphics handles (shift+mouseover)
        GuideVertRaster = gobjects(0)    % Vertical line on raster
        GuideVertPSTH = gobjects(0)      % Vertical line on PSTH
        GuideHorizRaster = gobjects(0)   % Horizontal line on raster
        GuideHorizHist = gobjects(0)     % Horizontal line on histogram
        GuideTrialLabel = gobjects(0)    % "Trial N" text on raster
        GuideTimeLabel = gobjects(0)     % "0.123 s" text on PSTH
        GuidesVisible logical = false    % Whether guides are currently shown
    end

    %% Constructor
    methods
        function obj = RasterGUI(eg)
            % Create a RasterGUI instance attached to an electro_gui instance.
            % The window starts hidden; call show() to display it.
            arguments
                eg electro_gui
            end
            obj.eg = eg;
            obj.initializeParameters();
        end
    end

    %% Public methods
    methods
        function show(obj)
            % Show the raster GUI window. Creates it if it doesn't exist.
            arguments
                obj RasterGUI
            end
            if isempty(obj.figure_Main) || ~isvalid(obj.figure_Main)
                obj.buildGUI();
                obj.layoutGUI();
                obj.refreshFromDbase();
                obj.refreshPresetList();  % Also calls updateControlStates
            else
                obj.refreshFromDbase();
            end
            obj.figure_Main.Visible = 'on';
            figure(obj.figure_Main);  % Bring to front
        end

        function refreshFromDbase(obj)
            % Rescan the electro_gui dbase and update all derived UI state.
            % Call this when electro_gui data may have changed (segments,
            % markers, events, event sources, file count, properties, etc.).
            arguments
                obj RasterGUI
            end

            % --- Update source popups ---
            % Rebuild the source list and try to preserve current selections
            oldTrigSource = obj.popup_TriggerSource.Value;
            oldEventSource = obj.popup_EventSeriesSource.Value;
            obj.populateSourceMenus();
            obj.popup_TriggerSource.Value = min(oldTrigSource, length(obj.popup_TriggerSource.String));
            obj.popup_EventSeriesSource.Value = min(oldEventSource, length(obj.popup_EventSeriesSource.String));

            % --- Update file count ---
            numFiles = electro_gui.getNumFiles(obj.eg.dbase);
            obj.FileRange = 1:numFiles;
            obj.edit_FileRange.String = ['1:', num2str(numFiles)];

            % --- Update property names ---
            if ~isempty(obj.eg.dbase.PropertyNames)
                obj.popup_PropertyName.String = obj.eg.dbase.PropertyNames;
            else
                obj.popup_PropertyName.String = {'(No properties)'};
            end

            % --- Clear cached data (segments/events may have changed) ---
            obj.clearCache();
            obj.updateControlStates();
        end

        function hide(obj)
            % Hide the raster GUI window without destroying it.
            arguments
                obj RasterGUI
            end
            if ~isempty(obj.figure_Main) && isvalid(obj.figure_Main)
                obj.figure_Main.Visible = 'off';
            end
        end

        function generate(obj)
            % Generate the raster plot with current settings.
            % Pipeline: snapshot GUI params -> extract trial data ->
            % compute sort order -> update colors -> plot.
            arguments
                obj RasterGUI
            end

            if ~electro_gui.isDataLoaded(obj.eg.dbase)
                warndlg('No data loaded in electro_gui.');
                return;
            end

            obj.setAllControlsEnabled(false);
            obj.push_GenerateRaster.ForegroundColor = 'r';
            obj.statusBar.Status = 'Generating raster...';
            obj.statusBar.Progress = 0;
            drawnow;

            % Snapshot all GUI control values
            obj.syncOptionsFromGUI();

            try
                if isempty(obj.ControlParams.eventSeries)
                    obj.statusBar.Status = 'No event series defined';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('Please add at least one event series.', 'No event series');
                    return;
                end

                % --- Extract triggers and events into immutable data ---
                obj.extractTrialData();

                if isempty(obj.TriggerData)
                    obj.statusBar.Status = 'No triggers found';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('No triggers found!', 'Error');
                    return;
                end

                % --- Sort ---
                numTrials = length(obj.TriggerData);
                obj.statusBar.Status = sprintf('Sorting %d triggers...', numTrials);
                obj.statusBar.Progress = 0.55;
                drawnow;
                obj.computeTrialOrder();

                % Update trigger label color mapping
                obj.updateTriggerLabelColors();

                % --- Plot ---
                obj.statusBar.Status = sprintf('Plotting %d trials...', numTrials);
                obj.statusBar.Progress = 0.75;
                drawnow;
                obj.plotRaster();
                obj.statusBar.Progress = 0.85;
                drawnow;
                obj.plotPSTH();
                obj.statusBar.Progress = 0.95;
                drawnow;
                obj.plotHist();
                obj.updateLegend();

            catch ME
                obj.statusBar.Status = sprintf('Error: %s', ME.message);
                obj.statusBar.Progress = [];
                obj.updateControlStates();
                obj.push_GenerateRaster.ForegroundColor = 'k';
                warndlg(sprintf('Error generating raster: %s', ME.message), 'Error');
                rethrow(ME);
            end

            % Store backup limits for double-click zoom reset
            obj.BackupXLim = obj.axes_Raster.XLim;
            obj.BackupPSTHYLim = obj.axes_PSTH.YLim;
            obj.BackupHistXLim = obj.axes_Hist.XLim;
            % RasterFullYLim is already set inside plotRaster

            obj.statusBar.Status = sprintf( ...
                'Done — %d trials', length(obj.TriggerData));
            obj.statusBar.Progress = 1;
            obj.updateControlStates();
            obj.push_GenerateRaster.ForegroundColor = 'k';
        end

        function extractTrialData(obj)
            % Extract triggers and events from the dbase and populate
            % TriggerData and EventData. This is the new data extraction
            % pipeline that replaces the combined extract+align+sort flow
            % in the old generate() method.
            %
            % After this method returns:
            %   obj.TriggerData  — 1xN struct array of trigger metadata
            %   obj.EventData    — 1xM cell array, each containing a 1xN
            %                      struct array with onsets/offsets
            %   obj.TrialOrder   — initialized to 1:N (unsorted)
            arguments
                obj RasterGUI
            end

            dbase = obj.eg.dbase;
            fs = dbase.Fs;
            params = obj.ControlParams;

            % --- Read alignment and window parameters ---
            alignmentType = params.alignmentType;
            startRefType = params.startRefType;
            stopRefType = params.stopRefType;
            excludeIncomplete = params.excludeIncomplete;
            excludePartial = params.excludePartialEvents;
            preStartPad = params.preStartRef * fs;
            postStopPad = params.postStopRef * fs;

            % --- Step 1: Extract raw trigger times ---
            obj.statusBar.Status = 'Extracting triggers...';
            obj.statusBar.Progress = 0.1;
            drawnow;
            [trig.on, trig.off, trig.info, ~] = obj.getEventStructure( ...
                params.triggerSourceIdx, params.triggerType, params.trigger);

            % --- Step 2: Extract raw event times for each series ---
            numSeries = length(obj.ControlParams.eventSeries);
            rawEvents = cell(1, numSeries);
            for seriesIdx = 1:numSeries
                series = obj.ControlParams.eventSeries(seriesIdx);
                obj.statusBar.Status = sprintf( ...
                    'Extracting events for "%s" (%d/%d)...', ...
                    series.name, seriesIdx, numSeries);
                obj.statusBar.Progress = 0.1 + 0.25 * seriesIdx / numSeries;
                drawnow;

                % Build a params struct from this series' own settings.
                % Fields not stored per-series use defaults.
                seriesParams = struct( ...
                    'filterMode',       series.filterMode, ...
                    'filterList',       series.filterList, ...
                    'burstFrequency',   series.burstFrequency, ...
                    'burstMinSpikes',   series.burstMinSpikes, ...
                    'selectionMode',    series.selectionMode, ...
                    'motifSequences',   {{}}, ...
                    'motifInterval',    0.2, ...
                    'boutInterval',     0.5, ...
                    'boutMinDuration',  0.2, ...
                    'boutMinSyllables', 2, ...
                    'pauseMinDuration', 0.05, ...
                    'contSmooth',       1, ...
                    'contSubsample',    0.001);

                eventSourceIdx = series.sourceIdx - 1;
                [rawEvents{seriesIdx}.on, rawEvents{seriesIdx}.off, ...
                    rawEvents{seriesIdx}.info, ~] = obj.getEventStructure( ...
                    eventSourceIdx, series.type, seriesParams);
            end

            % --- Step 3: Build TriggerData and EventData by iterating
            %     over triggers and aligning events to each trial ---
            obj.statusBar.Status = 'Aligning events to triggers...';
            obj.statusBar.Progress = 0.4;
            drawnow;

            % Pre-allocate with an empty struct array so we can index
            % directly into it during the loop
            trialCount = 0;
            triggerData = struct( ...
                'fileNum', {}, 'isComplete', {}, 'absTime', {}, ...
                'label', {}, 'corrShift', {}, ...
                'onset', {}, 'offset', {}, ...
                'prevOnset', {}, 'prevOffset', {}, ...
                'nextOnset', {}, 'nextOffset', {}, ...
                'dataStart', {}, 'dataStop', {});

            % Pre-allocate event data: one cell per series, each will
            % become a struct array with onsets/offsets
            eventData = cell(1, numSeries);

            for fileIdx = 1:length(trig.on)
                numTrigsInFile = length(trig.on{fileIdx});
                filenum = trig.info.filenum(fileIdx);
                fileDatetime = electro_gui.getFileDatetime(dbase, filenum);
                fileLength = obj.eg.getFileLength(filenum);

                for trigIdx = 1:numTrigsInFile
                    trigOnSample = trig.on{fileIdx}(trigIdx);
                    trigOffSample = trig.off{fileIdx}(trigIdx);

                    % Determine alignment point (in samples)
                    switch alignmentType
                        case 'Onset'
                            alignSample = trigOnSample;
                        case 'Midpoint'
                            alignSample = round( ...
                                (trigOnSample + trigOffSample) / 2);
                        case 'Offset'
                            alignSample = trigOffSample;
                    end

                    % Determine window start (in samples)
                    switch startRefType
                        case 'Trigger onset'
                            windowStart = trigOnSample;
                        case 'Trigger offset'
                            windowStart = trigOffSample;
                        case 'Prev trigger onset'
                            if trigIdx == 1
                                windowStart = -inf;
                            else
                                windowStart = trig.on{fileIdx}(trigIdx - 1);
                            end
                        case 'Prev trigger offset'
                            if trigIdx == 1
                                windowStart = -inf;
                            else
                                windowStart = trig.off{fileIdx}(trigIdx - 1);
                            end
                    end

                    % Determine window end (in samples)
                    switch stopRefType
                        case 'Trigger onset'
                            windowEnd = trigOnSample;
                        case 'Trigger offset'
                            windowEnd = trigOffSample;
                        case 'Next trigger onset'
                            if trigIdx == numTrigsInFile
                                windowEnd = inf;
                            else
                                windowEnd = trig.on{fileIdx}(trigIdx + 1);
                            end
                        case 'Next trigger offset'
                            if trigIdx == numTrigsInFile
                                windowEnd = inf;
                            else
                                windowEnd = trig.off{fileIdx}(trigIdx + 1);
                            end
                    end

                    % Apply pre/post padding
                    windowStart = round(windowStart - preStartPad);
                    windowEnd = round(windowEnd + postStopPad);

                    % Check completeness
                    if windowStart < 1 || windowEnd > fileLength
                        if excludeIncomplete
                            continue;
                        end
                        isComplete = false;
                    else
                        isComplete = true;
                    end
                    windowStart = max(windowStart, 1);
                    windowEnd = min(windowEnd, fileLength);

                    % --- Store this trial ---
                    trialCount = trialCount + 1;

                    % Trigger metadata
                    triggerData(trialCount).fileNum = filenum;
                    triggerData(trialCount).isComplete = isComplete;
                    triggerData(trialCount).absTime = ...
                        posixtime(fileDatetime) + alignSample / fs;
                    triggerData(trialCount).label = ...
                        trig.info.label{fileIdx}(trigIdx);
                    triggerData(trialCount).corrShift = 0;

                    % Current trigger boundaries (seconds from alignment)
                    triggerData(trialCount).onset = ...
                        (trigOnSample - alignSample) / fs;
                    triggerData(trialCount).offset = ...
                        (trigOffSample - alignSample) / fs;

                    % Neighboring triggers (seconds from alignment)
                    if trigIdx == 1
                        triggerData(trialCount).prevOnset = -inf;
                        triggerData(trialCount).prevOffset = -inf;
                    else
                        triggerData(trialCount).prevOnset = ...
                            (trig.on{fileIdx}(trigIdx-1) - alignSample) / fs;
                        triggerData(trialCount).prevOffset = ...
                            (trig.off{fileIdx}(trigIdx-1) - alignSample) / fs;
                    end
                    if trigIdx == numTrigsInFile
                        triggerData(trialCount).nextOnset = inf;
                        triggerData(trialCount).nextOffset = inf;
                    else
                        triggerData(trialCount).nextOnset = ...
                            (trig.on{fileIdx}(trigIdx+1) - alignSample) / fs;
                        triggerData(trialCount).nextOffset = ...
                            (trig.off{fileIdx}(trigIdx+1) - alignSample) / fs;
                    end

                    % Window bounds (seconds from alignment)
                    triggerData(trialCount).dataStart = ...
                        (windowStart - alignSample) / fs + eps;
                    triggerData(trialCount).dataStop = ...
                        (windowEnd - alignSample) / fs - eps;

                    % Align events from each series to this trial
                    for seriesIdx = 1:numSeries
                        evOn = rawEvents{seriesIdx}.on{fileIdx};
                        evOff = rawEvents{seriesIdx}.off{fileIdx};

                        % Find events within the window
                        if excludePartial
                            eventIdx = find( ...
                                evOn > windowStart & evOff < windowEnd);
                        else
                            onInWindow = find( ...
                                evOn > windowStart & evOn < windowEnd);
                            offInWindow = find( ...
                                evOff > windowStart & evOff < windowEnd);
                            spanning = find( ...
                                evOn < windowStart & evOff > windowEnd);
                            eventIdx = union( ...
                                union(onInWindow, offInWindow), spanning);
                        end

                        eventData{seriesIdx}(trialCount).onsets = ...
                            (evOn(eventIdx) - alignSample) / fs;
                        eventData{seriesIdx}(trialCount).offsets = ...
                            (evOff(eventIdx) - alignSample) / fs;
                    end
                end
            end

            % Warn if timestamps are not strictly increasing
            if trialCount > 1
                absTimes = [triggerData.absTime];
                if any(diff(absTimes) <= 0)
                    warning('RasterGUI:nonMonotonicTime', ...
                        ['Trigger absolute times are not strictly ' ...
                         'increasing. This may cause incorrect ' ...
                         'cross-trial trigger plotting. Consider ' ...
                         'running the "Fix chunked timestamps" macro.']);
                end
            end

            % Store results
            obj.TriggerData = triggerData;
            obj.EventData = eventData;
            obj.TrialOrder = 1:trialCount;
        end

        function computeTrialOrder(obj)
            % Compute TrialOrder from the current sort settings and the
            % immutable TriggerData/EventData. No data is mutated — only
            % the index vector changes.
            arguments
                obj RasterGUI
            end

            params = obj.ControlParams;
            numTrials = length(obj.TriggerData);
            if numTrials == 0
                obj.TrialOrder = [];
                return;
            end

            % Event data from the first series (used for event-based
            % sort criteria). Empty struct if no series exist.
            if ~isempty(obj.EventData)
                primaryEvents = obj.EventData{1};
            else
                primaryEvents = struct('onsets', {}, 'offsets', {});
            end

            % Start with all trials in original order
            order = 1:numTrials;

            % Apply secondary sort first so that primary sort is dominant
            if ~strcmp(params.secondarySort, '(None)')
                secondaryValues = RasterGUI.getSortValues( ...
                    params.secondarySort, obj.TriggerData, primaryEvents);
                order = RasterGUI.applySingleSort(order, secondaryValues, ...
                    params.sortDescending, false, obj.TriggerData);
            end

            % Apply primary sort
            if ~strcmp(params.primarySort, '(None)')
                primaryValues = RasterGUI.getSortValues( ...
                    params.primarySort, obj.TriggerData, primaryEvents);
                order = RasterGUI.applySingleSort(order, primaryValues, ...
                    params.sortDescending, params.groupLabels, ...
                    obj.TriggerData);
            end

            obj.TrialOrder = order;
        end
    end

    methods (Access = private, Static)
        function sortValues = getSortValues(sortType, triggerData, eventData)
            % Compute a numeric sort value for each trial based on the
            % given sort criterion. Works on the immutable TriggerData
            % and EventData struct arrays without mutating them.
            arguments
                sortType (1, :) char
                triggerData (1, :) struct
                eventData (1, :) struct
            end

            numTrials = length(triggerData);

            switch sortType
                case 'Absolute time'
                    sortValues = [triggerData.absTime];
                case 'Trigger duration'
                    sortValues = [triggerData.offset] - [triggerData.onset];
                case 'Prev trig onset'
                    sortValues = -[triggerData.prevOnset];
                case 'Prev trig offset'
                    sortValues = -[triggerData.prevOffset];
                case 'Prev trig interval'
                    sortValues = -([triggerData.prevOffset] - [triggerData.prevOnset]);
                case 'Next trig onset'
                    sortValues = [triggerData.nextOnset];
                case 'Next trig offset'
                    sortValues = [triggerData.nextOffset];
                case 'Next trig interval'
                    sortValues = [triggerData.nextOffset] - [triggerData.nextOnset];
                case 'Trigger label'
                    sortValues = [triggerData.label];
                case 'Preceding event onset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        preceding = find(eventData(trialIdx).onsets < 0);
                        if ~isempty(preceding)
                            sortValues(trialIdx) = ...
                                -eventData(trialIdx).onsets(preceding(end));
                        end
                    end
                case 'Preceding event offset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        preceding = find(eventData(trialIdx).offsets < 0);
                        if ~isempty(preceding)
                            sortValues(trialIdx) = ...
                                -eventData(trialIdx).offsets(preceding(end));
                        end
                    end
                case 'Following event onset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        following = find(eventData(trialIdx).onsets > 0);
                        if ~isempty(following)
                            sortValues(trialIdx) = ...
                                eventData(trialIdx).onsets(following(1));
                        end
                    end
                case 'Following event offset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        following = find(eventData(trialIdx).offsets > 0);
                        if ~isempty(following)
                            sortValues(trialIdx) = ...
                                eventData(trialIdx).offsets(following(1));
                        end
                    end
                case 'First event onset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        if ~isempty(eventData(trialIdx).onsets)
                            sortValues(trialIdx) = ...
                                min(eventData(trialIdx).onsets);
                        end
                    end
                case 'First event offset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        if ~isempty(eventData(trialIdx).offsets)
                            sortValues(trialIdx) = ...
                                min(eventData(trialIdx).offsets);
                        end
                    end
                case 'Last event onset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        if ~isempty(eventData(trialIdx).onsets)
                            sortValues(trialIdx) = ...
                                max(eventData(trialIdx).onsets);
                        end
                    end
                case 'Last event offset'
                    sortValues = inf(1, numTrials);
                    for trialIdx = 1:numTrials
                        if ~isempty(eventData(trialIdx).offsets)
                            sortValues(trialIdx) = ...
                                max(eventData(trialIdx).offsets);
                        end
                    end
                case 'Number of events'
                    sortValues = zeros(1, numTrials);
                    for trialIdx = 1:numTrials
                        sortValues(trialIdx) = ...
                            length(eventData(trialIdx).onsets);
                    end
                case 'Is in event'
                    sortValues = zeros(1, numTrials);
                    for trialIdx = 1:numTrials
                        % A trial "is in event" if there's an event whose
                        % onset is <= 0 and offset > 0 (spans the trigger)
                        sortValues(trialIdx) = ...
                            any(eventData(trialIdx).onsets <= 0 & ...
                                eventData(trialIdx).offsets > 0);
                    end
                otherwise
                    sortValues = 1:numTrials;
            end
        end
    end

    methods (Access = private, Static)
        function order = applySingleSort(order, sortValues, descending, groupLabels, triggerData)
            % Sort the given index vector by sortValues. If groupLabels
            % is true, group trials by label first.
            arguments
                order (1, :) double
                sortValues (1, :) double
                descending (1, 1) logical
                groupLabels (1, 1) logical
                triggerData (1, :) struct
            end

            % Sort the values in the current order
            [~, subOrd] = sort(sortValues(order));
            if descending
                subOrd = subOrd(end:-1:1);
            end
            order = order(subOrd);

            % Group by label if requested: within each label group,
            % the sort order is preserved, but groups are arranged so
            % that each label's mean position determines group order.
            if groupLabels
                labels = [triggerData.label];
                orderedLabels = labels(order);
                uniqueLabels = unique(orderedLabels, 'stable');
                groupSort = zeros(size(order));
                for labelIdx = 1:length(uniqueLabels)
                    mask = orderedLabels == uniqueLabels(labelIdx);
                    groupSort(mask) = mean(find(mask));
                end
                [~, groupOrd] = sort(groupSort);
                order = order(groupOrd);
            end
        end
    end

    %% GUI construction
    methods (Access = private)
        function initializeParameters(obj)
            % Initialize the default parameter structure
            arguments
                obj RasterGUI
            end
            obj.ControlParams.trigger.filterMode = 'All';   % 'All', 'Include', or 'Exclude'
            obj.ControlParams.trigger.filterList = '';
            obj.ControlParams.trigger.motifSequences = {};
            obj.ControlParams.trigger.motifInterval = 0.2;
            obj.ControlParams.trigger.boutInterval = 0.5;
            obj.ControlParams.trigger.boutMinDuration = 0.2;
            obj.ControlParams.trigger.boutMinSyllables = 2;
            obj.ControlParams.trigger.burstFrequency = 100;
            obj.ControlParams.trigger.burstMinSpikes = 2;
            obj.ControlParams.trigger.selectionMode = 'Selected only';
            obj.ControlParams.trigger.pauseMinDuration = 0.05;
            obj.ControlParams.trigger.contSmooth = 1;
            obj.ControlParams.trigger.contSubsample = 0.001;
            obj.ControlParams.preStartRef = 0.4;
            obj.ControlParams.postStopRef = 0.4;
            obj.ControlParams.filter = repmat([-inf, inf], 15, 1);

            % Trigger source and type (portable string names)
            obj.ControlParams.triggerSource = '';
            obj.ControlParams.triggerSourceIdx = 0;
            obj.ControlParams.triggerType = 'Events';
            obj.ControlParams.alignmentType = 'Onset';

            % Window references
            obj.ControlParams.startRefType = 'Trigger onset';
            obj.ControlParams.stopRefType = 'Trigger offset';

            % Exclude flags
            obj.ControlParams.excludeIncomplete = false;
            obj.ControlParams.excludePartialEvents = false;
            obj.ControlParams.plotOtherTrialTriggers = false;

            % Sort settings
            obj.ControlParams.primarySort = 'None';
            obj.ControlParams.secondarySort = 'None';
            obj.ControlParams.sortDescending = false;
            obj.ControlParams.groupLabels = false;

            % File filter settings (raw GUI state, not computed FileRange)
            obj.ControlParams.fileFilter = 'All files';
            obj.ControlParams.fileRangeExpression = '';
            obj.ControlParams.propertyFilterMode = 'None';
            obj.ControlParams.propertyName = '';
            obj.ControlParams.propertyExpression = '';

            % Plot settings
            obj.ControlParams.autoXLim = true;
            obj.ControlParams.plotXLim = [-0.15, 0.15];
            obj.ControlParams.plotTickSize.tickHeight = 1;
            obj.ControlParams.plotTickSize.lineWidth = 1;
            obj.ControlParams.plotOverlap = 50;
            obj.ControlParams.psthBinSize = 0.001;
            obj.ControlParams.psthSmoothingWindow = 1;
            obj.ControlParams.psthUnits = 'Rate (Hz)';
            obj.ControlParams.psthCount = 'Onsets';

            % Legend settings
            obj.ControlParams.showLegend = false;
            obj.ControlParams.legendTriggers = true;
            obj.ControlParams.legendEvents = true;

            % Auto-update settings
            obj.ControlParams.autoUpdateTrigger = true;
            obj.ControlParams.autoUpdateWindow = true;
            obj.ControlParams.autoUpdateFiles = true;
            obj.ControlParams.autoUpdatePlot = true;

            % Event series configs (empty initially)
            obj.ControlParams.eventSeries = struct( ...
                'name', {}, 'sourceIdx', {}, 'type', {}, ...
                'filterMode', {}, 'filterList', {}, ...
                'burstFrequency', {}, 'burstMinSpikes', {}, ...
                'selectionMode', {}, ...
                'color', {}, 'showPSTH', {}, 'psthStyle', {});

            obj.FileRange = 1:electro_gui.getNumFiles(obj.eg.dbase);
        end

        function layoutGUI(obj)
            % --- Layout constants ---
            arguments
                obj RasterGUI
            end
            % Status bar at the very bottom
            statusBarH = 0.025;
            statusBarY = 0.002;

            % Left control panel
            leftX = 0.005;                          % Left edge of control panel
            leftW = 0.250;                          % Width of control panel
            bottomY = statusBarY + statusBarH + 0.005; % Content starts above status bar
            buttonY = bottomY;                      % Y position of Generate button
            buttonH = 0.08;                         % Height of Generate button
            tabGroupY = buttonY + buttonH + 0.01;   % Tab group starts above buttons
            tabGroupH = 0.97 - tabGroupY;           % Tab group fills to top

            % Axes panel (contains raster, PSTH, and histogram axes)
            axesPanelX = leftX + leftW + 0.005;
            axesPanelW = 1 - axesPanelX - 0.005;
            axesPanelY = bottomY;
            axesPanelH = 0.99;

            % Axes positions relative to the panel
            rightMargin = 0.02;
            rasterX = 0.08;                       % Left edge within panel
            rasterY = 0.30;                       % Raster bottom within panel
            rasterH = 0.63;                       % Raster height
            psthY = 0.10;                         % PSTH bottom within panel
            psthH = rasterY - psthY;              % PSTH butts up to raster bottom
            histW = 0.12;                         % Histogram width
            histX = 1 - rightMargin - histW;      % Histogram flush to right
            axesW = histX - rasterX;              % Raster/PSTH butt up to histogram

            % Tab content layout in pixels (controls stay compact regardless
            % of window size; tab group itself uses normalized units)
            textHeight = 28;
            m = 5;                         % Margin (px)
            rowH = 22;                     % Row height (px)
            rowSpacing = 28;               % Vertical spacing between row tops (px)
            numRows = 20;
            % rowY positions computed after tab group creation (see below)
            % Placeholder — will be set once we know the tab interior height

            tabMargin = m;
            fullW = 270;                   % Approximate usable width inside tab (px)
            tabFullW = fullW;
            halfW = fullW * 0.48;          % Half-width button (px)
            halfGap = fullW * 0.04;        % Gap between half-width buttons (px)
            % thirdW = 80;                   % Third-width button (px)
            % thirdGap = 5;                  % Gap between third-width buttons (px)
            % editW = 70;                    % Short numeric edit box (px)
            exportBtnW = 60;               % Export button width (px)
            exportBtnGap = 5;              % Gap between export buttons (px)
            labelW = 65;                   % Width of text labels (px)
            labelPopupGap = 4;
            popupAfterLabelX = tabMargin + labelW + labelPopupGap;
            popupAfterLabelW = 120;        % Popup width after standard label (px)

            % Sort tab label column (wider labels)
            sortLabelW = 80;
            sortPopupX = tabMargin + sortLabelW + labelPopupGap;
            sortPopupW = fullW - sortPopupX;

            % Window tab label column (narrower labels)
            % winLabelW = 50;
            % winPopupX = tabMargin + winLabelW + labelPopupGap;
            % winPopupW = fullW - winPopupX;

            % Plot tab two-column layout
            plotLabelW = 58;
            plotEditW = 55;
            col2X = fullW / 2 + 5;

            % --- Figure ---
            obj.figure_Main.Units = 'normalized';
            obj.figure_Main.Position = [0.025, 0.05, 0.95, 0.9];
            % --- Status bar ---
            obj.statusBar.Units = 'normalized';
            obj.statusBar.Position = [0, statusBarY, 1, statusBarH];
            % --- Axes panel ---
            obj.panel_Axes.Units = 'normalized';
            obj.panel_Axes.Position = [axesPanelX, axesPanelY, axesPanelW, axesPanelH];
            obj.axes_Raster.Units = 'normalized';
            obj.axes_Raster.Position = [rasterX, rasterY, axesW, rasterH];
            obj.axes_PSTH.Units = 'normalized';
            obj.axes_PSTH.Position = [rasterX, psthY, axesW, psthH];
            obj.axes_Hist.Units = 'normalized';
            obj.axes_Hist.Position = [histX, rasterY, histW, rasterH];

            obj.AxisPosRaster = obj.axes_Raster.Position;
            obj.AxisPosPSTH = obj.axes_PSTH.Position;
            obj.AxisPosHist = obj.axes_Hist.Position;

            % --- Left side: tab group + generate buttons ---
            obj.tab_group.Units = 'normalized';
            obj.tab_group.Position = [leftX, tabGroupY, leftW, tabGroupH];

            % Compute row Y positions based on actual tab content area height.
            tabGroupSize = getpixelposition(obj.tab_group);
            tabContentH = tabGroupSize(4);

            topRowY = tabContentH - rowH - m - textHeight;
            rowY = topRowY - (0:numRows-1) * rowSpacing;

            % --- Trigger tab ---
            obj.popup_TriggerSource.Units = 'pixels';
            obj.popup_TriggerSource.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.text__TriggerType.Units = 'pixels';
            obj.text__TriggerType.Position = [tabMargin, rowY(2), labelW, rowH];
            obj.popup_TriggerType.Units = 'pixels';
            obj.popup_TriggerType.Position = [popupAfterLabelX, rowY(2), popupAfterLabelW, rowH];
            obj.text_TriggerAlignment.Units = 'pixels';
            obj.text_TriggerAlignment.Position = [tabMargin, rowY(3), labelW, rowH];
            obj.popup_TriggerAlignment.Units = 'pixels';
            obj.popup_TriggerAlignment.Position = [popupAfterLabelX, rowY(3), popupAfterLabelW, rowH];
            % Inline trigger filter (visible depending on type)
            filterModeW = 70;
            filterListX = tabMargin + filterModeW + 4;
            filterListW = fullW - filterListX;
            obj.popup_TrigFilterMode.Units = 'pixels';
            obj.popup_TrigFilterMode.Position = [tabMargin, rowY(5), filterModeW, rowH];
            obj.edit_TrigFilterList.Units = 'pixels';
            obj.edit_TrigFilterList.Position = [filterListX, rowY(5), filterListW, rowH];
            obj.check_ExcludeIncomplete.Units = 'pixels';
            obj.check_ExcludeIncomplete.Position = [tabMargin, rowY(6), tabFullW, rowH];
            obj.check_PlotOtherTrialTriggers.Units = 'pixels';
            obj.check_PlotOtherTrialTriggers.Position = [tabMargin, rowY(7), tabFullW, rowH];
            % Trigger label coloring controls
            trigLabelListH = 7 * rowSpacing;  % 7 rows tall
            trigColorBtnW = 50;
            obj.list_TriggerLabels.Units = 'pixels';
            obj.list_TriggerLabels.Position = [tabMargin, rowY(8) - trigLabelListH + rowH + rowSpacing, fullW, trigLabelListH];
            obj.list_TriggerLabels.ColumnWidth = {fullW - 4};
            % Selected label indicator sits between table and buttons
            obj.panel_SelectedTrigLabel.Units = 'pixels';
            obj.panel_SelectedTrigLabel.Position = [tabMargin, rowY(16) + rowSpacing, fullW, rowH];
            obj.push_TrigLabelColor.Units = 'pixels';
            obj.push_TrigLabelColor.Position = [tabMargin, rowY(16), trigColorBtnW, rowH];
            obj.check_TrigAutoColor.Units = 'pixels';
            obj.check_TrigAutoColor.Position = [tabMargin + trigColorBtnW + 8, rowY(16), 80, rowH];
            obj.popup_TrigColormap.Units = 'pixels';
            obj.popup_TrigColormap.Position = [tabMargin + trigColorBtnW + 8 + 80 + 4, rowY(16), 80, rowH];
            obj.check_TrigAutoUpdate.Units = 'pixels';
            obj.check_TrigAutoUpdate.Position = [tabMargin, rowY(17), halfW, rowH];
            obj.push_TrigUpdate.Units = 'pixels';
            obj.push_TrigUpdate.Position = [tabMargin + halfW + halfGap, rowY(17), halfW, rowH];
            % --- Events tab ---
            % Series list with +/- buttons to the right
            listH = 3 * rowSpacing;  % 3 rows tall
            btnW = 22;
            btnGap = 2;
            obj.list_EventSeries.Units = 'pixels';
            obj.list_EventSeries.Position = [tabMargin, rowY(1) - listH + rowH, fullW - btnW - btnGap, listH];
            obj.push_EventSeriesAdd.Units = 'pixels';
            obj.push_EventSeriesAdd.Position = [tabMargin + fullW - btnW, rowY(1), btnW, rowH];
            obj.push_EventSeriesRemove.Units = 'pixels';
            obj.push_EventSeriesRemove.Position = [tabMargin + fullW - btnW, rowY(1) - rowSpacing, btnW, rowH];
            % Detail panel: positioned below the list, spans 5 rows.
            % The panel top aligns with row 4 (first row below the 3-row
            % listbox), and extends downward for detailNumRows rows plus
            % internal padding.
            detailStartRow = 4;  % After 3-row list
            detailNumRows = 5;
            panelPad = 3;  % Internal padding within the panel
            panelH = detailNumRows * rowSpacing + 2 * panelPad;
            panelTopY = rowY(detailStartRow) + rowH;  % Top of row 4's control
            panelY = panelTopY - panelH;
            obj.panel_EventSeriesDetail.Units = 'pixels';
            obj.panel_EventSeriesDetail.Position = [tabMargin - 1, panelY, fullW + 2, panelH];
            % Detail controls positioned relative to the panel interior
            % Row positions within the panel (top-down)
            pW = fullW - 2 * panelPad;   % Usable width inside panel
            pHalfW = pW * 0.48;
            pHalfGap = pW * 0.04;
            pRowY = panelH - panelPad - rowH - (0:detailNumRows-1) * rowSpacing;
            obj.edit_EventSeriesName.Units = 'pixels';
            obj.edit_EventSeriesName.Position = [panelPad, pRowY(1), pW, rowH];
            obj.popup_EventSeriesSource.Units = 'pixels';
            obj.popup_EventSeriesSource.Position = [panelPad, pRowY(2), pHalfW, rowH];
            obj.popup_EventSeriesType.Units = 'pixels';
            obj.popup_EventSeriesType.Position = [panelPad + pHalfW + pHalfGap, pRowY(2), pHalfW, rowH];
            % Filter controls (row 3, visible for Sound sources)
            pFilterModeW = 70;
            pFilterListX = panelPad + pFilterModeW + 4;
            pFilterListW = pW - pFilterModeW - 4;
            obj.popup_EventSeriesFilterMode.Units = 'pixels';
            obj.popup_EventSeriesFilterMode.Position = [panelPad, pRowY(3), pFilterModeW, rowH];
            obj.edit_EventSeriesFilterList.Units = 'pixels';
            obj.edit_EventSeriesFilterList.Position = [pFilterListX, pRowY(3), pFilterListW, rowH];
            % Burst controls (row 3, visible for burst types)
            burstLabelW = 30;
            burstEditW = 40;
            burstGap = 4;
            obj.text_EventSeriesBurstFreq.Units = 'pixels';
            obj.text_EventSeriesBurstFreq.Position = [panelPad, pRowY(3), burstLabelW, rowH];
            obj.edit_EventSeriesBurstFreq.Units = 'pixels';
            obj.edit_EventSeriesBurstFreq.Position = [panelPad + burstLabelW + burstGap, pRowY(3), burstEditW, rowH];
            burstMinX = panelPad + burstLabelW + burstGap + burstEditW + burstGap;
            obj.text_EventSeriesBurstMinSpikes.Units = 'pixels';
            obj.text_EventSeriesBurstMinSpikes.Position = [burstMinX, pRowY(3), burstLabelW, rowH];
            obj.edit_EventSeriesBurstMinSpikes.Units = 'pixels';
            obj.edit_EventSeriesBurstMinSpikes.Position = [burstMinX + burstLabelW + burstGap, pRowY(3), burstEditW, rowH];
            % Selection mode (row 4)
            obj.popup_EventSeriesSelection.Units = 'pixels';
            obj.popup_EventSeriesSelection.Position = [panelPad, pRowY(4), pW, rowH];
            % Color, PSTH, style (row 5)
            colorBtnW = rowH;  % Square button
            obj.push_EventSeriesColor.Units = 'pixels';
            obj.push_EventSeriesColor.Position = [panelPad, pRowY(5), colorBtnW, rowH];
            obj.check_EventSeriesPSTH.Units = 'pixels';
            obj.check_EventSeriesPSTH.Position = [panelPad + colorBtnW + 8, pRowY(5), 80, rowH];
            psthStyleX = panelPad + colorBtnW + 8 + 80 + 4;
            obj.popup_EventSeriesPSTHStyle.Units = 'pixels';
            obj.popup_EventSeriesPSTHStyle.Position = [psthStyleX, pRowY(5), 80, rowH];
            % Window controls (continued in Events tab).
            % Start below the detail panel with one row of gap.
            winRefLabelW = 30;
            winRefPopupX = tabMargin + winRefLabelW + 2;
            winRefPopupW = 110;
            winOpX = winRefPopupX + winRefPopupW + 2;
            winOpW = 16;
            winEditX = winOpX + winOpW + 2;
            winEditW = 40;
            winUnitX = winEditX + winEditW + 2;
            winUnitW = 12;
            sharedControlsStartRow = detailStartRow + detailNumRows + 1;

            obj.text_StartReference.Units = 'pixels';
            obj.text_StartReference.Position = [tabMargin, rowY(sharedControlsStartRow), winRefLabelW, rowH];
            obj.popup_StartReference.Units = 'pixels';
            obj.popup_StartReference.Position = [winRefPopupX, rowY(sharedControlsStartRow), winRefPopupW, rowH];
            obj.text_PreMinus.Units = 'pixels';
            obj.text_PreMinus.Position = [winOpX, rowY(sharedControlsStartRow), winOpW, rowH];
            obj.edit_PreStart.Units = 'pixels';
            obj.edit_PreStart.Position = [winEditX, rowY(sharedControlsStartRow), winEditW, rowH];
            obj.text_PreUnit.Units = 'pixels';
            obj.text_PreUnit.Position = [winUnitX, rowY(sharedControlsStartRow), winUnitW, rowH];

            obj.text_StopReference.Units = 'pixels';
            obj.text_StopReference.Position = [tabMargin, rowY(sharedControlsStartRow+1), winRefLabelW, rowH];
            obj.popup_StopReference.Units = 'pixels';
            obj.popup_StopReference.Position = [winRefPopupX, rowY(sharedControlsStartRow+1), winRefPopupW, rowH];
            obj.text_PostPlus.Units = 'pixels';
            obj.text_PostPlus.Position = [winOpX, rowY(sharedControlsStartRow+1), winOpW, rowH];
            obj.edit_PostStop.Units = 'pixels';
            obj.edit_PostStop.Position = [winEditX, rowY(sharedControlsStartRow+1), winEditW, rowH];
            obj.text_PostUnit.Units = 'pixels';
            obj.text_PostUnit.Position = [winUnitX, rowY(sharedControlsStartRow+1), winUnitW, rowH];

            obj.check_ExcludePartialEvents.Units = 'pixels';
            obj.check_ExcludePartialEvents.Position = [tabMargin, rowY(sharedControlsStartRow+2), tabFullW, rowH];
            obj.check_WindowAutoUpdate.Units = 'pixels';
            obj.check_WindowAutoUpdate.Position = [tabMargin, rowY(sharedControlsStartRow+3), halfW, rowH];
            obj.push_WindowUpdate.Units = 'pixels';
            obj.push_WindowUpdate.Position = [tabMargin + halfW + halfGap, rowY(sharedControlsStartRow+3), halfW, rowH];
            % --- Sort tab ---
            obj.text_PrimarySort.Units = 'pixels';
            obj.text_PrimarySort.Position = [tabMargin, rowY(1), sortLabelW, rowH];
            obj.popup_PrimarySort.Units = 'pixels';
            obj.popup_PrimarySort.Position = [sortPopupX, rowY(1), sortPopupW, rowH];
            obj.text_SecondarySort.Units = 'pixels';
            obj.text_SecondarySort.Position = [tabMargin, rowY(2), sortLabelW, rowH];
            obj.popup_SecondarySort.Units = 'pixels';
            obj.popup_SecondarySort.Position = [sortPopupX, rowY(2), sortPopupW, rowH];
            obj.radio_Ascending.Units = 'pixels';
            obj.radio_Ascending.Position = [tabMargin, rowY(3), halfW, rowH];
            obj.radio_Descending.Units = 'pixels';
            obj.radio_Descending.Position = [tabMargin + halfW + halfGap, rowY(3), halfW, rowH];
            obj.check_GroupLabels.Units = 'pixels';
            obj.check_GroupLabels.Position = [tabMargin, rowY(4), tabFullW, rowH];
            % --- Files tab ---
            obj.popup_Files.Units = 'pixels';
            obj.popup_Files.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.text_FileRange.Units = 'pixels';
            obj.text_FileRange.Position = [tabMargin, rowY(2), labelW, rowH];
            obj.edit_FileRange.Units = 'pixels';
            obj.edit_FileRange.Position = [popupAfterLabelX, rowY(2), fullW - popupAfterLabelX, rowH];
            obj.push_Open.Units = 'pixels';
            obj.push_Open.Position = [tabMargin, rowY(3), halfW, rowH];
            obj.popup_PropertyFilterMode.Units = 'pixels';
            obj.popup_PropertyFilterMode.Position = [tabMargin, rowY(4), tabFullW, rowH];
            obj.popup_PropertyName.Units = 'pixels';
            obj.popup_PropertyName.Position = [tabMargin, rowY(5), tabFullW, rowH];
            obj.edit_PropertyExpression.Units = 'pixels';
            obj.edit_PropertyExpression.Position = [tabMargin, rowY(5), tabFullW, rowH];
            obj.check_FilesAutoUpdate.Units = 'pixels';
            obj.check_FilesAutoUpdate.Position = [tabMargin, rowY(6), halfW, rowH];
            obj.push_FilesUpdate.Units = 'pixels';
            obj.push_FilesUpdate.Position = [tabMargin + halfW + halfGap, rowY(6), halfW, rowH];
            % --- PSTH tab ---
            obj.text_PSTHUnits.Units = 'pixels';
            obj.text_PSTHUnits.Position = [tabMargin, rowY(1), labelW, rowH];
            obj.popup_PSTHUnits.Units = 'pixels';
            obj.popup_PSTHUnits.Position = [popupAfterLabelX, rowY(1), popupAfterLabelW, rowH];
            obj.text_PSTHCount.Units = 'pixels';
            obj.text_PSTHCount.Position = [tabMargin, rowY(2), labelW, rowH];
            obj.popup_PSTHCount.Units = 'pixels';
            obj.popup_PSTHCount.Position = [popupAfterLabelX, rowY(2), popupAfterLabelW, rowH];
            % --- Plot tab ---
            obj.check_AutoXLim.Units = 'pixels';
            obj.check_AutoXLim.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.text_XMin.Units = 'pixels';
            obj.text_XMin.Position = [tabMargin, rowY(2), plotLabelW, rowH];
            obj.edit_XMin.Units = 'pixels';
            obj.edit_XMin.Position = [tabMargin + plotLabelW + 2, rowY(2), plotEditW, rowH];
            obj.text_XMax.Units = 'pixels';
            obj.text_XMax.Position = [col2X, rowY(2), plotLabelW, rowH];
            obj.edit_XMax.Units = 'pixels';
            obj.edit_XMax.Position = [col2X + plotLabelW + 2, rowY(2), plotEditW, rowH];
            obj.text_TickHeight.Units = 'pixels';
            obj.text_TickHeight.Position = [tabMargin, rowY(3), plotLabelW, rowH];
            obj.edit_TickHeight.Units = 'pixels';
            obj.edit_TickHeight.Position = [tabMargin + plotLabelW + 2, rowY(3), plotEditW, rowH];
            obj.text_BinSize.Units = 'pixels';
            obj.text_BinSize.Position = [col2X, rowY(3), plotLabelW, rowH];
            obj.edit_BinSize.Units = 'pixels';
            obj.edit_BinSize.Position = [col2X + plotLabelW + 2, rowY(3), plotEditW, rowH];
            obj.text_TickLineWidth.Units = 'pixels';
            obj.text_TickLineWidth.Position = [tabMargin, rowY(4), plotLabelW, rowH];
            obj.edit_TickLineWidth.Units = 'pixels';
            obj.edit_TickLineWidth.Position = [tabMargin + plotLabelW + 2, rowY(4), plotEditW, rowH];
            obj.text_Overlap.Units = 'pixels';
            obj.text_Overlap.Position = [col2X, rowY(4), plotLabelW, rowH];
            obj.edit_Overlap.Units = 'pixels';
            obj.edit_Overlap.Position = [col2X + plotLabelW + 2, rowY(4), plotEditW, rowH];
            % Legend panel: spans rows 5-7 (2 internal rows + title)
            legendPanelPad = 8;
            legendPanelH = 2 * rowSpacing + 1.5 * legendPanelPad;
            legendPanelTopY = rowY(5) + rowH;
            obj.panel_Legend.Units = 'pixels';
            obj.panel_Legend.Position = [tabMargin - 1, legendPanelTopY - legendPanelH, fullW + 2, legendPanelH];
            % Controls inside the legend panel
            legendRowY1 = legendPanelH - legendPanelPad - textHeight;
            legendRowY2 = legendRowY1 - rowSpacing;
            obj.check_ShowLegend.Units = 'pixels';
            obj.check_ShowLegend.Position = [legendPanelPad, legendRowY1, 120, rowH];
            obj.check_LegendTriggers.Units = 'pixels';
            obj.check_LegendTriggers.Position = [legendPanelPad, legendRowY2, 80, rowH];
            obj.check_LegendEvents.Units = 'pixels';
            obj.check_LegendEvents.Position = [legendPanelPad + 80 + 4, legendRowY2, 80, rowH];

            obj.check_PlotAutoUpdate.Units = 'pixels';
            obj.check_PlotAutoUpdate.Position = [tabMargin, rowY(8), halfW, rowH];
            obj.push_PlotUpdate.Units = 'pixels';
            obj.push_PlotUpdate.Position = [tabMargin + halfW + halfGap, rowY(8), halfW, rowH];
            % --- Presets tab ---
            obj.popup_Presets.Units = 'pixels';
            obj.popup_Presets.Position = [tabMargin, rowY(1), tabFullW, rowH];
            quarterW = 60;
            quarterGap = 4;
            obj.push_LoadPreset.Units = 'pixels';
            obj.push_LoadPreset.Position = [tabMargin, rowY(2), quarterW, rowH];
            obj.push_SavePreset.Units = 'pixels';
            obj.push_SavePreset.Position = [tabMargin + (quarterW + quarterGap), rowY(2), quarterW, rowH];
            obj.push_DeletePreset.Units = 'pixels';
            obj.push_DeletePreset.Position = [tabMargin + 2*(quarterW + quarterGap), rowY(2), quarterW, rowH];
            obj.push_RefreshPresets.Units = 'pixels';
            obj.push_RefreshPresets.Position = [tabMargin + 3*(quarterW + quarterGap), rowY(2), quarterW, rowH];
            % --- Export tab ---
            obj.push_ExportFigure.Units = 'pixels';
            obj.push_ExportFigure.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.text_ExportToFile.Units = 'pixels';
            obj.text_ExportToFile.Position = [tabMargin, rowY(2), tabFullW, rowH * 0.7];
            obj.push_ExportPNG.Units = 'pixels';
            obj.push_ExportPNG.Position = [tabMargin, rowY(3), exportBtnW, rowH];
            obj.push_ExportPDF.Units = 'pixels';
            obj.push_ExportPDF.Position = [tabMargin + exportBtnW + exportBtnGap, rowY(3), exportBtnW, rowH];
            obj.push_ExportJPG.Units = 'pixels';
            obj.push_ExportJPG.Position = [tabMargin + 2*(exportBtnW + exportBtnGap), rowY(3), exportBtnW, rowH];
            obj.push_ExportSVG.Units = 'pixels';
            obj.push_ExportSVG.Position = [tabMargin + 3*(exportBtnW + exportBtnGap), rowY(3), exportBtnW, rowH];
            % --- Generate button below the tab group ---
            obj.push_GenerateRaster.Units = 'normalized';
            obj.push_GenerateRaster.Position = [leftX, buttonY, leftW, buttonH];
            obj.popup_PSTHUnits.Position = [popupAfterLabelX, rowY(1), popupAfterLabelW, rowH];

        end

        function buildGUI(obj)
            % Programmatically create the raster GUI figure and all widgets.
            arguments
                obj RasterGUI
            end

            % --- Figure ---
            obj.figure_Main = figure( ...
                'Name', 'Sorted Raster Plots', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Visible', 'off', ...
                'CloseRequestFcn', @(~,~) obj.hide(), ...
                'WindowScrollWheelFcn', @(~, evt) obj.onScrollWheel(evt), ...
                'WindowButtonMotionFcn', @(~,~) obj.onMouseMotion());

            % --- Status bar ---
            obj.statusBar = StatusBar(obj.figure_Main);
            obj.statusBar.AutoClear = true;
            obj.statusBar.Status = 'Ready';

            % --- Axes panel ---
            obj.panel_Axes = uipanel(obj.figure_Main, ...
                'BorderType', 'none');

            obj.axes_Raster = axes(obj.panel_Axes, ...
                'Box', 'on', ...
                'Tag', 'axes_Raster', ...
                'ButtonDownFcn', @(~,~) obj.onRasterClick());
            obj.axes_PSTH = axes(obj.panel_Axes, ...
                'Box', 'on', ...
                'Tag', 'axes_PSTH', ...
                'ButtonDownFcn', @(~,~) obj.onPSTHClick());
            obj.axes_Hist = axes(obj.panel_Axes, ...
                'Box', 'on', ...
                'Tag', 'axes_Hist', ...
                'ButtonDownFcn', @(~,~) obj.onHistClick());

            % Link axes: raster+PSTH share X, raster+histogram share Y.
            % Use linkprop instead of linkaxes because calling linkaxes
            % twice on the same axis (once for X, once for Y) replaces
            % the first link in R2025b.
            obj.LinkXLim = linkprop([obj.axes_Raster, obj.axes_PSTH], 'XLim');
            obj.LinkYLim = linkprop([obj.axes_Raster, obj.axes_Hist], 'YLim');

            % --- Left side: tab group + generate buttons ---
            obj.tab_group = uitabgroup(obj.figure_Main);

            % --- Trigger tab ---
            trigTab = uitab(obj.tab_group, 'Title', 'Trigger');
            obj.popup_TriggerSource = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Sound'}, ...
                'Callback', @(~,~) obj.triggerSettingChanged());
            obj.text__TriggerType = uicontrol(trigTab, 'Style', 'text', ...
                'String', 'Type:', ...
                'Tag', 'text__TriggerType', ...
                'HorizontalAlignment', 'right');
            obj.popup_TriggerType = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Syllables', 'Markers', 'Motifs', 'Bouts'}, ...
                'Callback', @(~,~) obj.triggerTypeChanged());
            obj.text_TriggerAlignment = uicontrol(trigTab, 'Style', 'text', ...
                'String', 'Align:', ...
                'Tag', 'text_TriggerAlignment', ...
                'HorizontalAlignment', 'right');
            obj.popup_TriggerAlignment = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Onset', 'Offset', 'Midpoint'}, ...
                'Callback', @(~,~) obj.triggerSettingChanged());
            % Inline trigger filter (visible depending on type)
            obj.popup_TrigFilterMode = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'All', 'Include', 'Exclude'}, ...
                'Callback', @(~,~) obj.triggerSettingChanged());
            obj.edit_TrigFilterList = uicontrol(trigTab, 'Style', 'edit', ...
                'String', '', 'HorizontalAlignment', 'left', ...
                'Callback', @(~,~) obj.triggerSettingChanged());
            obj.check_ExcludeIncomplete = uicontrol(trigTab, 'Style', 'checkbox', ...
                'String', 'Exclude incomplete', 'Value', 1, ...
                'Callback', @(~,~) obj.triggerSettingChanged());
            obj.check_PlotOtherTrialTriggers = uicontrol(trigTab, 'Style', 'checkbox', ...
                'String', 'Plot triggers from other trials', ...
                'Callback', @(~,~) obj.replotFromCache());
            % Trigger label coloring
            obj.list_TriggerLabels = uitable2(trigTab, ...
                'Data', {'(No triggers yet)'}, ...
                'ColumnName', {}, ...
                'RowName', {}, ...
                'ColumnEditable', false, ...
                'RowStriping', 'off', ...
                'CellSelectionCallback', @(~,~) obj.selectTriggerLabel(), ...
                'ColumnSelectable', true, ...
                'RowSelectionColor', [], ...
                'ClearNativeSelection', true);
            % Selected trigger label indicator — colored panel with text
            obj.panel_SelectedTrigLabel = uipanel(trigTab, ...
                'BorderType', 'line', ...
                'HighlightColor', [0.5, 0.5, 0.5], ...
                'BackgroundColor', [0.94, 0.94, 0.94]);
            obj.text_SelectedTrigLabel = uicontrol(obj.panel_SelectedTrigLabel, ...
                'Style', 'text', ...
                'String', 'Selected: (none)', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 1, 1], ...
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', [0.94, 0.94, 0.94]);
            obj.push_TrigLabelColor = uicontrol(trigTab, 'Style', 'pushbutton', ...
                'String', 'Color', ...
                'Callback', @(~,~) obj.trigLabelColorPicked());
            obj.check_TrigAutoColor = uicontrol(trigTab, 'Style', 'checkbox', ...
                'String', 'Auto-color', 'Value', 1, ...
                'Callback', @(~,~) obj.trigAutoColorChanged());
            obj.popup_TrigColormap = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'hsv', 'parula', 'jet', 'turbo', 'lines', 'colorcube', 'prism'}, ...
                'Callback', @(~,~) obj.trigAutoColorChanged());

            obj.check_TrigAutoUpdate = uicontrol(trigTab, 'Style', 'checkbox', ...
                'String', 'Auto-update', 'Value', 1);
            obj.push_TrigUpdate = uicontrol(trigTab, 'Style', 'pushbutton', ...
                'String', 'Update', ...
                'Callback', @(~,~) obj.generate());

            % --- Events tab ---
            eventTab = uitab(obj.tab_group, 'Title', 'Events');
            % Series list and management buttons
            obj.list_EventSeries = uicontrol(eventTab, 'Style', 'listbox', ...
                'String', {'(No event series)'}, ...
                'Callback', @(~,~) obj.selectEventSeries());
            obj.push_EventSeriesAdd = uicontrol(eventTab, 'Style', 'pushbutton', ...
                'String', '+', ...
                'FontWeight', 'bold', ...
                'Callback', @(~,~) obj.addEventSeries());
            obj.push_EventSeriesRemove = uicontrol(eventTab, 'Style', 'pushbutton', ...
                'String', char(215), 'FontWeight', 'bold', 'Enable', 'off', ... % × symbol
                'Callback', @(~,~) obj.removeEventSeries());
            % Detail panel (bordered, hidden until a series is selected)
            obj.panel_EventSeriesDetail = uipanel(eventTab, ...
                'Title', '', ...
                'BorderType', 'line', ...
                'HighlightColor', [0.7, 0.7, 0.7], ...
                'Visible', 'off');
            dp = obj.panel_EventSeriesDetail;  % Short alias for parenting
            % Detail controls (inside the panel)
            obj.edit_EventSeriesName = uicontrol(dp, 'Style', 'edit', ...
                'String', '', ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(~,~) obj.eventSeriesNameChanged());
            obj.popup_EventSeriesSource = uicontrol(dp, 'Style', 'popupmenu', ...
                'String', {'Sound'}, ...
                'Callback', @(~,~) obj.eventSeriesSourceChanged());
            obj.popup_EventSeriesType = uicontrol(dp, 'Style', 'popupmenu', ...
                'String', {'Syllables'}, ...
                'Callback', @(~,~) obj.eventSeriesTypeChanged());
            obj.popup_EventSeriesFilterMode = uicontrol(dp, 'Style', 'popupmenu', ...
                'String', {'All', 'Include', 'Exclude'}, 'Visible', 'off', ...
                'Callback', @(~,~) obj.eventSeriesFilterModeChanged());
            obj.edit_EventSeriesFilterList = uicontrol(dp, 'Style', 'edit', ...
                'String', '', 'HorizontalAlignment', 'left', 'Visible', 'off', ...
                'Callback', @(~,~) obj.eventSeriesDetailChanged());
            % Burst-specific controls (same row as filter, shown for burst types)
            obj.text_EventSeriesBurstFreq = uicontrol(dp, 'Style', 'text', ...
                'String', 'Freq:', ...
                'HorizontalAlignment', 'right', ...
                'Visible', 'off');
            obj.edit_EventSeriesBurstFreq = uicontrol(dp, 'Style', 'edit', ...
                'String', '100', ...
                'Visible', 'off', ...
                'Callback', @(~,~) obj.eventSeriesDetailChanged());
            obj.text_EventSeriesBurstMinSpikes = uicontrol(dp, 'Style', 'text', ...
                'String', 'Min:', ...
                'HorizontalAlignment', 'right', ...
                'Visible', 'off');
            obj.edit_EventSeriesBurstMinSpikes = uicontrol(dp, 'Style', 'edit', ...
                'String', '2', ...
                'Visible', 'off', ...
                'Callback', @(~,~) obj.eventSeriesDetailChanged());
            obj.popup_EventSeriesSelection = uicontrol(dp, 'Style', 'popupmenu', ...
                'String', {'All', 'Selected only', 'Unselected only'}, ...
                'Value', 2, ...  % Default to 'Selected only'
                'Callback', @(~,~) obj.eventSeriesDetailChanged());
            obj.push_EventSeriesColor = uicontrol(dp, 'Style', 'pushbutton', ...
                'String', '', ...
                'BackgroundColor', [0 0 0], ...
                'Callback', @(~,~) obj.eventSeriesColorPicked());
            obj.check_EventSeriesPSTH = uicontrol(dp, 'Style', 'checkbox', ...
                'String', 'PSTH source', ...
                'Callback', @(~,~) obj.eventSeriesPSTHChanged());
            obj.popup_EventSeriesPSTHStyle = uicontrol(dp, 'Style', 'popupmenu', ...
                'String', {'Line', 'Histogram', 'Both'}, ...
                'Callback', @(~,~) obj.eventSeriesPSTHChanged());

            % Window controls (in Events tab)
            % Row: Start: [Trigger onset ▾] — [0.4] s
            obj.text_StartReference = uicontrol(eventTab, 'Style', 'text', ...
                'String', 'Start:', ...
                'HorizontalAlignment', 'right');
            obj.popup_StartReference = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'String', {'Trigger onset', 'Trigger offset', 'Prev trigger onset', 'Prev trigger offset'}, ...
                'Callback', @(~,~) obj.windowSettingChanged());
            obj.text_PreMinus = uicontrol(eventTab, 'Style', 'text', ...
                'String', char(8212), ...
                'FontSize', 14, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            obj.edit_PreStart = uicontrol(eventTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.preStartRef), ...
                'Callback', @(~,~) obj.windowSettingChanged());
            obj.text_PreUnit = uicontrol(eventTab, 'Style', 'text', ...
                'String', 's', ...
                'HorizontalAlignment', 'left');
            % Row: Stop: [Trigger offset ▾] + [0.4] s
            obj.text_StopReference = uicontrol(eventTab, 'Style', 'text', ...
                'String', 'Stop:', ...
                'HorizontalAlignment', 'right');
            obj.popup_StopReference = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'String', {'Trigger onset', 'Trigger offset', 'Next trigger onset', 'Next trigger offset'}, ...
                'Callback', @(~,~) obj.windowSettingChanged());
            obj.text_PostPlus = uicontrol(eventTab, 'Style', 'text', ...
                'String', '+', ...
                'FontSize', 14, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
            obj.edit_PostStop = uicontrol(eventTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.postStopRef), ...
                'Callback', @(~,~) obj.windowSettingChanged());
            obj.text_PostUnit = uicontrol(eventTab, 'Style', 'text', ...
                'String', 's', ...
                'HorizontalAlignment', 'left');
            obj.check_ExcludePartialEvents = uicontrol(eventTab, 'Style', 'checkbox', ...
                'String', 'Exclude partial events', ...
                'Callback', @(~,~) obj.windowSettingChanged());
            obj.check_WindowAutoUpdate = uicontrol(eventTab, 'Style', 'checkbox', ...
                'String', 'Auto-update', 'Value', 1);
            obj.push_WindowUpdate = uicontrol(eventTab, 'Style', 'pushbutton', ...
                'String', 'Update', ...
                'Callback', @(~,~) obj.generate());

            % --- Sort tab ---
            sortTab = uitab(obj.tab_group, 'Title', 'Sort');
            obj.text_PrimarySort = uicontrol(sortTab, 'Style', 'text', ...
                'String', 'Primary:', ...
                'Tag', 'text_PrimarySort', ...
                'HorizontalAlignment', 'right');
            obj.popup_PrimarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'String', obj.getSortOptions(), ...
                'Callback', @(~,~) obj.sortSettingChanged());
            obj.text_SecondarySort = uicontrol(sortTab, 'Style', 'text', ...
                'String', 'Secondary:', ...
                'Tag', 'text_SecondarySort', ...
                'HorizontalAlignment', 'right');
            obj.popup_SecondarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'String', obj.getSortOptions(), ...
                'Callback', @(~,~) obj.sortSettingChanged());
            obj.radio_Ascending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'String', 'Ascending', 'Value', 1, ...
                'Callback', @(~,~) obj.ascendingClicked());
            obj.radio_Descending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'String', 'Descending', 'Value', 0, ...
                'Callback', @(~,~) obj.descendingClicked());
            obj.check_GroupLabels = uicontrol(sortTab, 'Style', 'checkbox', ...
                'String', 'Group by label', ...
                'Callback', @(~,~) obj.sortSettingChanged());

            % --- Files tab ---
            filesTab = uitab(obj.tab_group, 'Title', 'Files');
            obj.popup_Files = uicontrol(filesTab, 'Style', 'popupmenu', ...
                'String', {'All files in range', 'Only read files', 'Only unread files'}, ...
                'Callback', @(~,~) obj.filesSettingChanged());
            obj.text_FileRange = uicontrol(filesTab, 'Style', 'text', ...
                'String', 'Range:', ...
                'Tag', 'text_FileRange', ...
                'HorizontalAlignment', 'right');
            numFiles = electro_gui.getNumFiles(obj.eg.dbase);
            obj.edit_FileRange = uicontrol(filesTab, 'Style', 'edit', ...
                'String', ['1:', num2str(numFiles)], ...
                'HorizontalAlignment', 'left', ...
                'Callback', @(~,~) obj.filesSettingChanged());
            obj.push_Open = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'String', 'Open dbase', 'Callback', @(~,~) obj.openCallback());
            obj.popup_PropertyFilterMode = uicontrol(filesTab, 'Style', 'popupmenu', ...
                'String', {'(No property filter)', 'Single', 'Expression'}, ...
                'Callback', @(~,~) obj.filesSettingChanged());
            obj.popup_PropertyName = uicontrol(filesTab, 'Style', 'popupmenu', ...
                'String', {'(None)'}, 'Visible', 'off', ...
                'Callback', @(~,~) obj.filesSettingChanged());
            obj.edit_PropertyExpression = uicontrol(filesTab, 'Style', 'edit', ...
                'String', '', 'HorizontalAlignment', 'left', ...
                'Visible', 'off', ...
                'Callback', @(~,~) obj.filesSettingChanged());
            obj.check_FilesAutoUpdate = uicontrol(filesTab, 'Style', 'checkbox', ...
                'String', 'Auto-update', 'Value', 1);
            obj.push_FilesUpdate = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'String', 'Update', ...
                'Callback', @(~,~) obj.generate());

            % --- PSTH tab ---
            psthTab = uitab(obj.tab_group, 'Title', 'PSTH');
            obj.text_PSTHUnits = uicontrol(psthTab, 'Style', 'text', ...
                'String', 'Units:', ...
                'Tag', 'text_PSTHUnits', ...
                'HorizontalAlignment', 'right');
            obj.popup_PSTHUnits = uicontrol(psthTab, 'Style', 'popupmenu', ...
                'String', {'Rate (Hz)', 'Count/trial', 'Total count'}, ...
                'Callback', @(~,~) obj.replotFromCache());
            obj.text_PSTHCount = uicontrol(psthTab, 'Style', 'text', ...
                'String', 'Count:', ...
                'Tag', 'text_PSTHCount', ...
                'HorizontalAlignment', 'right');
            obj.popup_PSTHCount = uicontrol(psthTab, 'Style', 'popupmenu', ...
                'String', {'Onsets', 'Offsets', 'Full duration'}, ...
                'Callback', @(~,~) obj.replotFromCache());

            % --- Plot tab ---
            plotTab = uitab(obj.tab_group, 'Title', 'Plot');

            obj.check_AutoXLim = uicontrol(plotTab, 'Style', 'checkbox', ...
                'String', 'Auto X limits', 'Value', 1, ...
                'Callback', @(~,~) obj.autoXLimChanged());
            obj.text_XMin = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'X min (s):', ...
                'Tag', 'text_XMin', ...
                'HorizontalAlignment', 'right');
            obj.edit_XMin = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.plotXLim(1)), ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.xLimChanged());
            obj.text_XMax = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'X max (s):', ...
                'Tag', 'text_XMax', ...
                'HorizontalAlignment', 'right');
            obj.edit_XMax = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.plotXLim(2)), ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.xLimChanged());

            obj.text_TickHeight = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Tick height:', ...
                'Tag', 'text_TickHeight', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickHeight = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.plotTickSize.tickHeight), ...
                'Callback', @(~,~) obj.plotSettingChanged());
            obj.text_BinSize = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Bin size (s):', ...
                'Tag', 'text_BinSize', ...
                'HorizontalAlignment', 'right');
            obj.edit_BinSize = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.psthBinSize), ...
                'Callback', @(~,~) obj.plotSettingChanged());

            obj.text_TickLineWidth = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Line width:', ...
                'Tag', 'text_TickLineWidth', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickLineWidth = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.plotTickSize.lineWidth), ...
                'Callback', @(~,~) obj.plotSettingChanged());
            obj.text_Overlap = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Overlap %:', ...
                'Tag', 'text_Overlap', ...
                'HorizontalAlignment', 'right');
            obj.edit_Overlap = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.ControlParams.plotOverlap), ...
                'Callback', @(~,~) obj.plotSettingChanged());
            % Legend controls (grouped in a labeled panel)
            obj.panel_Legend = uipanel(plotTab, ...
                'Title', 'Legend', ...
                'BorderType', 'line', ...
                'HighlightColor', [0.7, 0.7, 0.7]);
            obj.check_ShowLegend = uicontrol(obj.panel_Legend, 'Style', 'checkbox', ...
                'String', 'Show', 'Value', 0, ...
                'Callback', @(~,~) obj.updateLegend());
            obj.check_LegendTriggers = uicontrol(obj.panel_Legend, 'Style', 'checkbox', ...
                'String', 'Triggers', 'Value', 1, ...
                'Callback', @(~,~) obj.updateLegend());
            obj.check_LegendEvents = uicontrol(obj.panel_Legend, 'Style', 'checkbox', ...
                'String', 'Events', 'Value', 1, ...
                'Callback', @(~,~) obj.updateLegend());

            obj.check_PlotAutoUpdate = uicontrol(plotTab, 'Style', 'checkbox', ...
                'String', 'Auto-update', 'Value', 1);
            obj.push_PlotUpdate = uicontrol(plotTab, 'Style', 'pushbutton', ...
                'String', 'Update', ...
                'Callback', @(~,~) obj.replotFromCache());

            % --- Presets tab ---
            presetsTab = uitab(obj.tab_group, 'Title', 'Presets');
            obj.popup_Presets = uicontrol(presetsTab, 'Style', 'popupmenu', ...
                'String', {'(No presets found)'}, 'Enable', 'off');
            obj.push_LoadPreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Load', ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.loadPresetCallback());
            obj.push_SavePreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Save', ...
                'Callback', @(~,~) obj.savePresetCallback());
            obj.push_DeletePreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Delete', ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.deletePresetCallback());
            obj.push_RefreshPresets = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Refresh', ...
                'Callback', @(~,~) obj.refreshPresetList());

            % --- Export tab ---
            exportTab = uitab(obj.tab_group, 'Title', 'Export');
            obj.push_ExportFigure = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'Export to new figure', ...
                'Callback', @(~,~) obj.exportToFigure());
            obj.text_ExportToFile = uicontrol(exportTab, 'Style', 'text', ...
                'String', 'Export to file:', ...
                'Tag', 'text_ExportToFile', ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold');
            % exportBtnW, exportBtnGap defined in layout constants above
            obj.push_ExportPNG = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'PNG', ...
                'Callback', @(~,~) obj.exportToFile('png'));
            obj.push_ExportPDF = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'PDF', ...
                'Callback', @(~,~) obj.exportToFile('pdf'));
            obj.push_ExportJPG = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'JPG', ...
                'Callback', @(~,~) obj.exportToFile('jpg'));
            obj.push_ExportSVG = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'SVG', ...
                'Callback', @(~,~) obj.exportToFile('svg'));

            % --- Generate button below the tab group ---
            obj.push_GenerateRaster = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'String', 'Generate', ...
                'FontWeight', 'bold', ...
                'Callback', @(~,~) obj.generate());

            % Set tooltips on all controls
            obj.setTooltips();
        end

        function setTooltips(obj)
            % Set tooltips on all interactive controls.
            arguments
                obj RasterGUI
            end
            % Trigger tab
            obj.popup_TriggerSource.Tooltip = 'Data source for triggers (Sound = syllables/markers)';
            obj.popup_TriggerType.Tooltip = 'Type of trigger events to extract';
            obj.popup_TriggerAlignment.Tooltip = 'Which part of the trigger to align to (time zero)';
            obj.popup_TrigFilterMode.Tooltip = 'All: use all labels; Include: only listed; Exclude: all except listed';
            obj.check_ExcludeIncomplete.Tooltip = 'Exclude triggers whose window extends beyond file boundaries';
            obj.check_PlotOtherTrialTriggers.Tooltip = 'Show triggers from other trials that fall within each trial''s time window';
            obj.list_TriggerLabels.Tooltip = 'Trigger labels and their colors; select to change color';
            obj.push_TrigLabelColor.Tooltip = 'Pick a color for the selected trigger label';
            obj.check_TrigAutoColor.Tooltip = 'Automatically assign colors from the selected colormap';
            obj.popup_TrigColormap.Tooltip = 'Colormap for automatic label coloring';
            obj.check_TrigAutoUpdate.Tooltip = 'Automatically regenerate when trigger settings change';
            obj.push_TrigUpdate.Tooltip = 'Regenerate raster with current trigger settings';

            % Events tab - series controls
            obj.list_EventSeries.Tooltip = 'Event series to plot on the raster';
            obj.push_EventSeriesAdd.Tooltip = 'Add a new event series';
            obj.push_EventSeriesRemove.Tooltip = 'Remove the selected event series';
            obj.edit_EventSeriesName.Tooltip = 'Display name for this series';
            obj.popup_EventSeriesSource.Tooltip = 'Data source for this event series';
            obj.popup_EventSeriesType.Tooltip = 'Type of events to extract for this series';
            obj.popup_EventSeriesFilterMode.Tooltip = 'All: use all labels; Include: only listed; Exclude: all except listed';
            obj.edit_EventSeriesFilterList.Tooltip = 'Label characters to include or exclude';
            obj.edit_EventSeriesBurstFreq.Tooltip = 'Minimum burst frequency (Hz): events closer than 1/freq are grouped into bursts';
            obj.edit_EventSeriesBurstMinSpikes.Tooltip = 'Minimum number of events in a burst';
            obj.popup_EventSeriesSelection.Tooltip = 'All: use all events; Selected only: use events marked as selected; Unselected only: use unselected events';
            obj.push_EventSeriesColor.Tooltip = 'Click to pick a color for this series';
            obj.check_EventSeriesPSTH.Tooltip = 'Include this series in the PSTH display (multiple allowed)';
            obj.popup_EventSeriesPSTHStyle.Tooltip = 'PSTH plot style: Line, Histogram (bar), or Both';
            obj.popup_StartReference.Tooltip = 'Reference point for the start of the event window';
            obj.popup_StopReference.Tooltip = 'Reference point for the end of the event window';
            obj.check_ExcludePartialEvents.Tooltip = 'Exclude events not fully contained within the window';
            obj.check_WindowAutoUpdate.Tooltip = 'Automatically regenerate when window settings change';
            obj.push_WindowUpdate.Tooltip = 'Regenerate raster with current settings';

            % Sort tab
            obj.popup_PrimarySort.Tooltip = 'Primary criterion for ordering trials';
            obj.popup_SecondarySort.Tooltip = 'Secondary criterion (applied within primary groups)';
            obj.radio_Ascending.Tooltip = 'Sort in ascending order';
            obj.radio_Descending.Tooltip = 'Sort in descending order';
            obj.check_GroupLabels.Tooltip = 'Group trials with the same label together';

            % Files tab
            obj.popup_Files.Tooltip = 'Which files to include from the file range';
            obj.push_Open.Tooltip = 'Open a different dbase file';
            obj.popup_PropertyFilterMode.Tooltip = 'Filter files by property: None, Single property, or Boolean expression';
            obj.popup_PropertyName.Tooltip = 'Include only files where this property is true';
            obj.edit_PropertyExpression.Tooltip = 'Boolean expression using property names (e.g., "bSorted & ~bUnusable")';
            obj.check_FilesAutoUpdate.Tooltip = 'Automatically regenerate when file settings change';
            obj.push_FilesUpdate.Tooltip = 'Regenerate raster with current file settings';

            % PSTH tab
            obj.popup_PSTHUnits.Tooltip = 'Units for the PSTH Y axis';
            obj.popup_PSTHCount.Tooltip = 'Onsets: count event starts; Offsets: count event ends; Full duration: count active events per bin';

            % Plot tab
            obj.check_AutoXLim.Tooltip = 'Automatically fit X limits to the data';
            obj.edit_XMin.Tooltip = 'Minimum X axis value (seconds)';
            obj.edit_XMax.Tooltip = 'Maximum X axis value (seconds)';
            obj.edit_TickHeight.Tooltip = 'Height of event ticks and trigger boxes (1 = full row)';
            obj.edit_BinSize.Tooltip = 'PSTH histogram bin width (seconds)';
            obj.edit_TickLineWidth.Tooltip = 'Line width for event ticks';
            obj.edit_Overlap.Tooltip = 'Vertical overlap between adjacent trials (percent)';
            obj.check_ShowLegend.Tooltip = 'Show or hide the legend on the raster axes';
            obj.check_LegendTriggers.Tooltip = 'Include trigger label colors in the legend';
            obj.check_LegendEvents.Tooltip = 'Include event series in the legend';
            obj.check_PlotAutoUpdate.Tooltip = 'Automatically replot when plot settings change';
            obj.push_PlotUpdate.Tooltip = 'Replot with current settings';

            % Presets tab
            obj.popup_Presets.Tooltip = 'Select a saved preset';
            obj.push_LoadPreset.Tooltip = 'Load the selected preset';
            obj.push_SavePreset.Tooltip = 'Save current settings as a new preset';
            obj.push_DeletePreset.Tooltip = 'Delete the selected preset';
            obj.push_RefreshPresets.Tooltip = 'Rescan the presets folder';

            % Export tab
            obj.push_ExportFigure.Tooltip = 'Copy the plots to a new standalone figure';
            obj.push_ExportPNG.Tooltip = 'Save as PNG image (300 DPI)';
            obj.push_ExportPDF.Tooltip = 'Save as PDF (vector)';
            obj.push_ExportJPG.Tooltip = 'Save as JPEG image (300 DPI)';
            obj.push_ExportSVG.Tooltip = 'Save as SVG vector image';

            % Main buttons
            obj.push_GenerateRaster.Tooltip = 'Extract triggers and events, sort, and plot';
        end

        function populateSourceMenus(obj)
            % Populate the trigger and event source dropdown menus from
            arguments
                obj RasterGUI
            end
            % the current electro_gui dbase.
            sourceStrings = {'Sound'};
            for sourceIdx = 1:length(obj.eg.dbase.EventSources)
                sourceStrings{end+1} = sprintf('%s - %s - %s', ...
                    obj.eg.dbase.EventDetectors{sourceIdx}, ...
                    obj.eg.dbase.EventSources{sourceIdx}, ...
                    obj.eg.dbase.EventFunctions{sourceIdx}); %#ok<AGROW>
            end
            obj.popup_TriggerSource.String = sourceStrings;
            obj.popup_EventSeriesSource.String = sourceStrings;

            obj.FileRange = 1:electro_gui.getNumFiles(obj.eg.dbase);
        end
    end

    %% Plotting
    methods (Access = private)
        function plotRaster(obj)
            % Render the raster plot from TriggerData, EventData, and
            % TrialOrder. The trial data is not modified; TrialOrder
            % controls which trials appear and in what order.
            arguments
                obj RasterGUI
            end

            numTrials = length(obj.TrialOrder);
            if numTrials == 0
                return;
            end

            % Get sorted views of the data
            triggerData = obj.TriggerData(obj.TrialOrder);
            numSeries = length(obj.EventData);

            ax = obj.axes_Raster;
            delete(ax.Children);
            hold(ax, 'on');

            % Trial y-positions (trial 1 at top)
            trialY = 1:numTrials;

            % Tick height: each trial spans 1 unit, ticks fill most of it
            tickHalfHeight = obj.ControlParams.plotTickSize.tickHeight / 2;

            % --- Plot trigger boxes colored by label ---
            % Single patch call with per-face colors via FaceVertexCData.
            obj.statusBar.Status = 'Plotting trigger boxes...';
            drawnow;
            trigOn = [triggerData.onset]';
            trigOff = [triggerData.offset]';
            trigLabels = [triggerData.label]';
            validTrig = isfinite(trigOn) & isfinite(trigOff);
            if any(validTrig)
                tOn = trigOn(validTrig);
                tOff = trigOff(validTrig);
                tY = trialY(validTrig)';
                numValid = length(tOn);
                % Build vertices: [all BL; all BR; all TR; all TL]
                vertices = [tOn, tY - tickHalfHeight; ...
                            tOff, tY - tickHalfHeight; ...
                            tOff, tY + tickHalfHeight; ...
                            tOn, tY + tickHalfHeight];
                faces = [(1:numValid)', (numValid+1:2*numValid)', ...
                         (2*numValid+1:3*numValid)', (3*numValid+1:4*numValid)'];
                % Build per-face colors from label mapping, lightened for boxes.
                tLabels = trigLabels(validTrig);
                faceColors = zeros(numValid, 3);
                uniqueValid = unique(tLabels);
                for labelNum = 1:length(uniqueValid)
                    mask = tLabels == uniqueValid(labelNum);
                    baseColor = obj.getTriggerLabelColor(uniqueValid(labelNum));
                    faceColors(mask, :) = repmat(1 - (1 - baseColor) * 0.25, sum(mask), 1);
                end
                patch(ax, 'Faces', faces, 'Vertices', vertices, ...
                    'FaceVertexCData', faceColors, 'FaceColor', 'flat', ...
                    'EdgeColor', 'none', ...
                    'PickableParts', 'none', ...
                    'HitTest', 'off');
            end

            % --- Plot triggers from other trials (optional) ---
            % For each trial, find all other triggers whose onset/offset
            % falls within this trial's visible time window. Uses absolute
            % time to handle triggers across file boundaries.
            if obj.ControlParams.plotOtherTrialTriggers && numTrials > 1
                absT = [triggerData.absTime]';
                ownOn = trigOn;
                ownOff = trigOff;
                xLim = ax.XLim;

                % Compute where every other trial's trigger appears in
                % each trial's coordinate system (NxN matrices).
                dtSec = absT - absT';
                otherOn = dtSec + ownOn;
                otherOff = dtSec + ownOff;

                % Zero out the diagonal (own trigger already plotted)
                otherOn(1:numTrials+1:end) = NaN;
                otherOff(1:numTrials+1:end) = NaN;

                % Find boxes that overlap the visible X range
                visible = isfinite(otherOn) & isfinite(otherOff) & ...
                          otherOff > xLim(1) & otherOn < xLim(2);
                [srcTrial, destTrial] = find(visible);
                if ~isempty(srcTrial)
                    idx = sub2ind([numTrials, numTrials], srcTrial, destTrial);
                    boxOn = otherOn(idx);
                    boxOff = otherOff(idx);
                    boxY = trialY(destTrial)';
                    srcLabels = trigLabels(srcTrial);
                    nOther = length(boxOn);

                    vertices = [boxOn, boxY - tickHalfHeight; ...
                                boxOff, boxY - tickHalfHeight; ...
                                boxOff, boxY + tickHalfHeight; ...
                                boxOn, boxY + tickHalfHeight];
                    otherFaces = [(1:nOther)', (nOther+1:2*nOther)', ...
                                  (2*nOther+1:3*nOther)', (3*nOther+1:4*nOther)'];
                    % Extra-lightened colors for other-trial triggers
                    otherFaceColors = zeros(nOther, 3);
                    uniqueSrc = unique(srcLabels);
                    for labelNum = 1:length(uniqueSrc)
                        mask = srcLabels == uniqueSrc(labelNum);
                        baseColor = obj.getTriggerLabelColor(uniqueSrc(labelNum));
                        otherFaceColors(mask, :) = repmat(1 - (1 - baseColor) * 0.12, sum(mask), 1);
                    end
                    patch(ax, 'Faces', otherFaces, 'Vertices', vertices, ...
                        'FaceVertexCData', otherFaceColors, 'FaceColor', 'flat', ...
                        'EdgeColor', 'none', ...
                        'PickableParts', 'none', ...
                        'HitTest', 'off');
                end
            end

            % --- Plot event ticks for each series ---
            % Each event series is rendered as vertical tick marks in its
            % own color. All ticks for a series are concatenated into a
            % single NaN-separated vector for fast vectorized rendering.
            for seriesIdx = 1:numSeries
                seriesEvents = obj.EventData{seriesIdx}(obj.TrialOrder);
                seriesColor = obj.ControlParams.eventSeries(seriesIdx).color;
                seriesName = obj.ControlParams.eventSeries(seriesIdx).name;

                obj.statusBar.Status = sprintf('Plotting "%s" (%d/%d)...', ...
                    seriesName, seriesIdx, numSeries);
                obj.statusBar.Progress = 0.8 + 0.15 * seriesIdx / numSeries;
                drawnow;

                % Count total events across all trials for pre-allocation
                totalEvents = 0;
                for trialIdx = 1:numTrials
                    totalEvents = totalEvents + length(seriesEvents(trialIdx).onsets);
                end
                if totalEvents == 0
                    continue;
                end

                % Build NaN-separated X/Y arrays for all event ticks.
                % Each tick is 3 entries: [x; x; NaN] and [yBottom; yTop; NaN]
                allX = NaN(3 * totalEvents, 1);
                allY = NaN(3 * totalEvents, 1);
                writeIdx = 0;
                for trialIdx = 1:numTrials
                    eventTimes = seriesEvents(trialIdx).onsets;
                    nEvents = length(eventTimes);
                    if nEvents > 0
                        yBottom = trialY(trialIdx) - tickHalfHeight;
                        yTop = trialY(trialIdx) + tickHalfHeight;
                        range = writeIdx + (1:3*nEvents);
                        allX(range) = reshape([eventTimes(:)'; eventTimes(:)'; NaN(1, nEvents)], [], 1);
                        allY(range) = reshape([repmat(yBottom, 1, nEvents); ...
                                               repmat(yTop, 1, nEvents); ...
                                               NaN(1, nEvents)], [], 1);
                        writeIdx = writeIdx + 3 * nEvents;
                    end
                end

                % Render all ticks for this series in one call
                plot(ax, allX, allY, 'Color', seriesColor, ...
                    'LineWidth', obj.ControlParams.plotTickSize.lineWidth, ...
                    'HitTest', 'off', 'PickableParts', 'none');
            end

            % --- Plot zero line (trigger alignment point) ---
            plot(ax, [0, 0], [0.5, numTrials + 0.5], '--', ...
                'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.5, ...
                'PickableParts', 'none', ...
                'HitTest', 'off');

            % --- Axes formatting ---
            ax.YDir = 'reverse';
            newFullYLim = [0.5, numTrials + 0.5];
            if isequal(obj.RasterFullYLim, newFullYLim)
                % Trial count unchanged — preserve the user's zoom/pan
                % but clamp in case the view extends past the data
                ax.YLim = [max(ax.YLim(1), newFullYLim(1)), ...
                           min(ax.YLim(2), newFullYLim(2))];
            else
                % Trial count changed — reset to show all trials
                ax.YLim = newFullYLim;
            end
            obj.RasterFullYLim = newFullYLim;
            if obj.ControlParams.autoXLim
                % Compute tight X limits from all plotted data
                allXData = [];
                for childIdx = 1:length(ax.Children)
                    child = ax.Children(childIdx);
                    if isprop(child, 'XData') && ~isempty(child.XData)
                        finiteX = child.XData(isfinite(child.XData));
                        allXData = [allXData; finiteX(:)]; %#ok<AGROW>
                    end
                end
                if ~isempty(allXData)
                    ax.XLim = [min(allXData), max(allXData)];
                end
            else
                ax.XLim = obj.ControlParams.plotXLim;
            end
            ax.YLabel.String = 'Trial';
            ax.XLabel.String = '';
            ax.XTickLabel = {};
            ax.Box = 'on';
            title(ax, sprintf('%d trials', numTrials));
            hold(ax, 'off');

            % If auto, update ControlParams.plotXLim and edit boxes from
            % the auto-computed result
            if obj.ControlParams.autoXLim
                drawnow;
                obj.ControlParams.plotXLim = ax.XLim;
                obj.edit_XMin.String = num2str(obj.ControlParams.plotXLim(1), '%.3f');
                obj.edit_XMax.String = num2str(obj.ControlParams.plotXLim(2), '%.3f');
            end
        end

        function plotPSTH(obj)
            % Render peri-stimulus time histograms for all event series
            % that have showPSTH=true. Each series is plotted in its own
            % color as an overlaid line. If no series has showPSTH checked,
            % the axes stays blank.
            arguments
                obj RasterGUI
            end

            numTrials = length(obj.TrialOrder);
            if numTrials == 0
                return;
            end

            ax = obj.axes_PSTH;
            delete(ax.Children);
            hold(ax, 'on');

            % Find all series with showPSTH=true
            psthSeriesIndices = find([obj.ControlParams.eventSeries.showPSTH]);
            if isempty(psthSeriesIndices)
                ax.YLabel.String = '';
                ax.XLabel.String = 'Time (s)';
                hold(ax, 'off');
                return;
            end

            % Shared bin edges for all series
            binSize = obj.ControlParams.psthBinSize;
            binEdges = obj.ControlParams.plotXLim(1):binSize:obj.ControlParams.plotXLim(2);
            if isempty(binEdges) || length(binEdges) < 2
                hold(ax, 'off');
                return;
            end
            binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

            % Determine Y axis label from selected units
            psthUnit = obj.ControlParams.psthUnits;
            switch psthUnit
                case 'Rate (Hz)',    yLabel = 'Firing rate (Hz)';
                case 'Count/trial',  yLabel = 'Count/trial';
                case 'Total count',  yLabel = 'Total count';
                otherwise,           yLabel = 'Rate (Hz)';
            end

            % Determine count mode (Onsets, Offsets, or Full duration)
            psthCountMode = obj.ControlParams.psthCount;

            % Plot each PSTH series as a line in its color
            for psthIdx = 1:length(psthSeriesIndices)
                seriesIdx = psthSeriesIndices(psthIdx);
                seriesEvents = obj.EventData{seriesIdx}(obj.TrialOrder);
                seriesColor = obj.ControlParams.eventSeries(seriesIdx).color;
                seriesStyle = obj.ControlParams.eventSeries(seriesIdx).psthStyle;

                % Compute histogram counts based on count mode
                switch psthCountMode
                    case 'Onsets'
                        allTimes = cat(1, seriesEvents.onsets);
                        if isempty(allTimes), continue; end
                        counts = histcounts(allTimes, binEdges);
                    case 'Offsets'
                        allTimes = cat(1, seriesEvents.offsets);
                        if isempty(allTimes), continue; end
                        counts = histcounts(allTimes, binEdges);
                    case 'Full duration'
                        % Count how many events are active in each bin
                        % (onset before bin end AND offset after bin start)
                        allOnsets = cat(1, seriesEvents.onsets);
                        allOffsets = cat(1, seriesEvents.offsets);
                        if isempty(allOnsets), continue; end
                        counts = zeros(1, length(binEdges) - 1);
                        for binIdx = 1:length(counts)
                            counts(binIdx) = sum( ...
                                allOnsets < binEdges(binIdx+1) & ...
                                allOffsets > binEdges(binIdx));
                        end
                end

                % Convert to the selected units
                switch psthUnit
                    case 'Rate (Hz)'
                        psthValues = counts / (numTrials * binSize);
                    case 'Count/trial'
                        psthValues = counts / numTrials;
                    case 'Total count'
                        psthValues = counts;
                    otherwise
                        psthValues = counts / (numTrials * binSize);
                end

                % Smooth if requested
                if obj.ControlParams.psthSmoothingWindow > 1
                    psthValues = movmean(psthValues, obj.ControlParams.psthSmoothingWindow);
                end

                % Plot using the series' psthStyle setting
                if any(strcmp(seriesStyle, {'Histogram', 'Both'}))
                    bar(ax, binCenters, psthValues, 1, ...
                        'FaceColor', seriesColor, 'FaceAlpha', 0.25, ...
                        'EdgeColor', 'none', ...
                        'HitTest', 'off', 'PickableParts', 'none');
                end
                if any(strcmp(seriesStyle, {'Line', 'Both'}))
                    plot(ax, binCenters, psthValues, ...
                        'Color', seriesColor, 'LineWidth', 1, ...
                        'HitTest', 'off', 'PickableParts', 'none');
                end
            end

            % Zero line
            plot(ax, [0, 0], ax.YLim, '--', ...
                'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.5, ...
                'PickableParts', 'none', ...
                'HitTest', 'off');

            % Formatting (X limits linked to raster via linkprop)
            ax.YLabel.String = yLabel;
            ax.XLabel.String = 'Time (s)';
            ax.Box = 'on';
            hold(ax, 'off');
        end

        function updateLegend(obj)
            % Show or hide a legend on the raster axes based on the
            % legend checkboxes. Creates invisible dummy plot objects
            % for each legend entry so the legend shows the correct
            % icons and colors.
            arguments
                obj RasterGUI
            end

            % Sync legend settings from GUI so this works when called
            % directly from checkbox callbacks (without full syncOptionsFromGUI)
            obj.ControlParams.showLegend = logical(obj.check_ShowLegend.Value);
            obj.ControlParams.legendTriggers = logical(obj.check_LegendTriggers.Value);
            obj.ControlParams.legendEvents = logical(obj.check_LegendEvents.Value);

            ax = obj.axes_Raster;

            % Remove any existing legend and dummy handles
            legend(ax, 'off');
            delete(findobj(ax, 'Tag', 'LegendDummy'));

            if ~obj.ControlParams.showLegend
                return;
            end

            hold(ax, 'on');
            dummyHandles = gobjects(0);

            % Add trigger label entries (colored patches)
            if obj.ControlParams.legendTriggers && ~isempty(obj.TriggerLabelValues)
                for labelNum = 1:length(obj.TriggerLabelValues)
                    labelVal = obj.TriggerLabelValues(labelNum);
                    color = obj.TriggerLabelColors(labelNum, :);
                    boxColor = 1 - (1 - color) * 0.25;  % Match lightened box color
                    % Label display text
                    if labelVal == 0
                        labelStr = '(unlabeled)';
                    elseif labelVal > 1000
                        labelStr = num2str(labelVal - 1000);
                    else
                        labelStr = char(labelVal);
                    end
                    h = patch(ax, NaN, NaN, boxColor, ...
                        'EdgeColor', color, 'LineWidth', 0.5, ...
                        'DisplayName', labelStr, ...
                        'Tag', 'LegendDummy');
                    dummyHandles(end+1) = h; %#ok<AGROW>
                end
            end

            % Add event series entries (colored lines)
            if obj.ControlParams.legendEvents && ~isempty(obj.ControlParams.eventSeries)
                for seriesNum = 1:length(obj.ControlParams.eventSeries)
                    s = obj.ControlParams.eventSeries(seriesNum);
                    h = plot(ax, NaN, NaN, '|', ...
                        'Color', s.color, ...
                        'MarkerSize', 10, ...
                        'LineWidth', max(obj.ControlParams.plotTickSize.lineWidth, 1.5), ...
                        'DisplayName', s.name, ...
                        'Tag', 'LegendDummy');
                    dummyHandles(end+1) = h; %#ok<AGROW>
                end
            end

            if isempty(dummyHandles)
                return;
            end

            lg = legend(ax, dummyHandles, ...
                'Location', 'northeast', ...
                'FontSize', 8, ...
                'Box', 'on');
            % Make the legend non-interactive so it doesn't interfere
            % with scroll zoom or double-click
            lg.HitTest = 'off';
            lg.PickableParts = 'none';
        end

        function plotHist(obj)
            % Render the vertical histogram showing event counts per trial,
            % displayed as horizontal bars aligned with the raster Y axis.
            % Mirrors plotPSTH: plots all showPSTH-enabled series in their
            % own colors and styles, using the same count mode.
            arguments
                obj RasterGUI
            end

            numTrials = length(obj.TrialOrder);
            if numTrials == 0
                return;
            end

            ax = obj.axes_Hist;
            delete(ax.Children);
            hold(ax, 'on');

            % Find all PSTH-enabled series
            psthSeriesIndices = find([obj.ControlParams.eventSeries.showPSTH]);
            if isempty(psthSeriesIndices)
                ax.YDir = 'reverse';
                ax.YTickLabel = {};
                ax.XLabel.String = '';
                hold(ax, 'off');
                return;
            end

            % Count mode (same as PSTH)
            psthCountMode = obj.ControlParams.psthCount;

            % Binning parameters — counts reflect all events in each
            % trial's full window, not just the visible X range.
            trialBinSize = max(1, round(obj.HistBinSize(1)));
            numBins = ceil(numTrials / trialBinSize);
            binCenters = zeros(numBins, 1);
            for binIdx = 1:numBins
                trialStart = (binIdx - 1) * trialBinSize + 1;
                trialEnd = min(binIdx * trialBinSize, numTrials);
                binCenters(binIdx) = (trialStart + trialEnd) / 2;
            end

            maxCount = 0;

            % Plot each PSTH-enabled series
            for psthIdx = 1:length(psthSeriesIndices)
                seriesIdx = psthSeriesIndices(psthIdx);
                seriesEvents = obj.EventData{seriesIdx}(obj.TrialOrder);
                seriesColor = obj.ControlParams.eventSeries(seriesIdx).color;
                seriesStyle = obj.ControlParams.eventSeries(seriesIdx).psthStyle;

                % Count events per trial using the selected count mode.
                % Counts all events in the trial window, not just the
                % visible X range, so the histogram reflects the data
                % selection and matches event-based sort criteria.
                countsPerTrial = zeros(numTrials, 1);
                for trialIdx = 1:numTrials
                    switch psthCountMode
                        case 'Onsets'
                            countsPerTrial(trialIdx) = ...
                                length(seriesEvents(trialIdx).onsets);
                        case 'Offsets'
                            countsPerTrial(trialIdx) = ...
                                length(seriesEvents(trialIdx).offsets);
                        case 'Full duration'
                            countsPerTrial(trialIdx) = ...
                                length(seriesEvents(trialIdx).onsets);
                    end
                end

                % Bin counts by groups of trials
                binnedCounts = zeros(numBins, 1);
                for binIdx = 1:numBins
                    trialStart = (binIdx - 1) * trialBinSize + 1;
                    trialEnd = min(binIdx * trialBinSize, numTrials);
                    binnedCounts(binIdx) = mean(countsPerTrial(trialStart:trialEnd));
                end

                % Smooth if requested
                if obj.HistSmoothingWindow > 1 && length(binnedCounts) > 1
                    binnedCounts = movmean(binnedCounts, obj.HistSmoothingWindow);
                end

                maxCount = max(maxCount, max(binnedCounts));

                % Plot using the series' psthStyle
                if any(strcmp(seriesStyle, {'Histogram', 'Both'}))
                    barh(ax, binCenters, binnedCounts, 1, ...
                        'FaceColor', seriesColor, 'FaceAlpha', 0.25, ...
                        'EdgeColor', 'none', ...
                        'HitTest', 'off', 'PickableParts', 'none');
                end
                if any(strcmp(seriesStyle, {'Line', 'Both'}))
                    plot(ax, binnedCounts, binCenters, ...
                        'Color', seriesColor, 'LineWidth', 1, ...
                        'HitTest', 'off', 'PickableParts', 'none');
                end
            end

            % Formatting (Y axis linked to raster via linkprop)
            ax.YDir = 'reverse';
            ax.YTickLabel = {};
            ax.XLabel.String = 'Events/trial';
            ax.Box = 'on';

            % Auto-scale X
            if maxCount > 0
                ax.XLim = [0, maxCount * 1.1];
            end

            hold(ax, 'off');
        end
    end

    %% Presets
    methods (Access = private)
        function presetDir = getPresetDir(obj)
            % Return the path to the presets directory, creating it if needed.
            arguments
                obj RasterGUI
            end
            presetDir = fullfile(obj.eg.SourceDir, 'raster_presets');
            if ~isfolder(presetDir)
                mkdir(presetDir);
            end
        end

        function refreshPresetList(obj)
            % Refresh the presets popup with available preset files.
            arguments
                obj RasterGUI
            end
            presetDir = obj.getPresetDir();
            files = dir(fullfile(presetDir, '*.mat'));
            if isempty(files)
                obj.popup_Presets.Value = 1;
                obj.popup_Presets.String = {'(No presets found)'};
            else
                names = cell(1, length(files));
                for k = 1:length(files)
                    [~, names{k}, ~] = fileparts(files(k).name);
                end
                if obj.popup_Presets.Value > length(names)
                    obj.popup_Presets.Value = length(names);
                end
                obj.popup_Presets.String = names;
            end
            obj.updateControlStates();
        end

        function preset = getPreset(obj)
            % Capture the current GUI state as a preset struct.
            arguments
                obj RasterGUI
            end
            % ControlParams is the single source of truth. Ensure it's
            % current, then return it directly.
            obj.syncOptionsFromGUI();
            preset = obj.ControlParams;
        end

        function applyPreset(obj, preset)
            % Apply a ControlParams preset struct to the GUI — the inverse
            % of syncOptionsFromGUI. Writes preset values back to all GUI
            % controls, then stores the struct as the active ControlParams.
            arguments
                obj RasterGUI
                preset (1, 1) struct
            end

            % --- Trigger settings ---
            obj.setPopupByName(obj.popup_TriggerSource, preset, 'triggerSource');
            obj.setPopupByName(obj.popup_TriggerType, preset, 'triggerType');
            obj.setPopupByName(obj.popup_TriggerAlignment, preset, 'alignmentType');

            % --- Trigger filter ---
            if isfield(preset, 'trigger')
                obj.setPopupByName(obj.popup_TrigFilterMode, preset.trigger, 'filterMode');
                if isfield(preset.trigger, 'filterList')
                    obj.edit_TrigFilterList.String = preset.trigger.filterList;
                end
            end

            % --- Window references ---
            obj.setPopupByName(obj.popup_StartReference, preset, 'startRefType');
            obj.setPopupByName(obj.popup_StopReference, preset, 'stopRefType');
            if isfield(preset, 'preStartRef')
                obj.edit_PreStart.String = num2str(preset.preStartRef);
            end
            if isfield(preset, 'postStopRef')
                obj.edit_PostStop.String = num2str(preset.postStopRef);
            end

            % --- Exclude flags ---
            obj.setCheckbox(obj.check_ExcludeIncomplete, preset, 'excludeIncomplete');
            obj.setCheckbox(obj.check_PlotOtherTrialTriggers, preset, 'plotOtherTrialTriggers');
            obj.setCheckbox(obj.check_ExcludePartialEvents, preset, 'excludePartialEvents');

            % --- Sort settings ---
            obj.setPopupByName(obj.popup_PrimarySort, preset, 'primarySort');
            obj.setPopupByName(obj.popup_SecondarySort, preset, 'secondarySort');
            if isfield(preset, 'sortDescending')
                obj.radio_Descending.Value = preset.sortDescending;
                obj.radio_Ascending.Value = ~preset.sortDescending;
            end
            obj.setCheckbox(obj.check_GroupLabels, preset, 'groupLabels');

            % --- Event series ---
            if isfield(preset, 'eventSeries')
                obj.ControlParams.eventSeries = preset.eventSeries;
                obj.refreshEventSeriesList();
                if ~isempty(obj.ControlParams.eventSeries)
                    obj.list_EventSeries.Value = 1;
                    obj.selectEventSeries();
                end
            end

            % --- File filter settings ---
            obj.setPopupByName(obj.popup_Files, preset, 'fileFilter');
            if isfield(preset, 'fileRangeExpression')
                obj.edit_FileRange.String = preset.fileRangeExpression;
            end
            obj.setPopupByName(obj.popup_PropertyFilterMode, preset, 'propertyFilterMode');
            obj.setPopupByName(obj.popup_PropertyName, preset, 'propertyName');
            if isfield(preset, 'propertyExpression')
                obj.edit_PropertyExpression.String = preset.propertyExpression;
            end

            % --- Plot settings ---
            obj.setCheckbox(obj.check_AutoXLim, preset, 'autoXLim');
            if isfield(preset, 'plotXLim')
                obj.edit_XMin.String = num2str(preset.plotXLim(1));
                obj.edit_XMax.String = num2str(preset.plotXLim(2));
            end
            if isfield(preset, 'plotTickSize')
                obj.edit_TickHeight.String = num2str(preset.plotTickSize.tickHeight);
                obj.edit_TickLineWidth.String = num2str(preset.plotTickSize.lineWidth);
            end
            if isfield(preset, 'psthBinSize')
                obj.edit_BinSize.String = num2str(preset.psthBinSize);
            end
            if isfield(preset, 'plotOverlap')
                obj.edit_Overlap.String = num2str(preset.plotOverlap);
            end

            % --- PSTH settings ---
            obj.setPopupByName(obj.popup_PSTHUnits, preset, 'psthUnits');
            obj.setPopupByName(obj.popup_PSTHCount, preset, 'psthCount');

            % --- Legend settings ---
            obj.setCheckbox(obj.check_ShowLegend, preset, 'showLegend');
            obj.setCheckbox(obj.check_LegendTriggers, preset, 'legendTriggers');
            obj.setCheckbox(obj.check_LegendEvents, preset, 'legendEvents');

            % --- Auto-update settings ---
            obj.setCheckbox(obj.check_TrigAutoUpdate, preset, 'autoUpdateTrigger');
            obj.setCheckbox(obj.check_WindowAutoUpdate, preset, 'autoUpdateWindow');
            obj.setCheckbox(obj.check_FilesAutoUpdate, preset, 'autoUpdateFiles');
            obj.setCheckbox(obj.check_PlotAutoUpdate, preset, 'autoUpdatePlot');

            % --- Apply the full ControlParams struct ---
            obj.ControlParams = preset;
        end

        function loadPresetCallback(obj)
            arguments
                obj RasterGUI
            end
            presetNames = obj.popup_Presets.String;
            selectedName = presetNames{obj.popup_Presets.Value};
            presetPath = fullfile(obj.getPresetDir(), [selectedName, '.mat']);
            if ~isfile(presetPath)
                warndlg(sprintf('Preset file not found: %s', presetPath), 'Preset not found');
                obj.refreshPresetList();
                return;
            end
            loaded = load(presetPath, 'preset');
            if ~isfield(loaded, 'preset')
                warndlg('Invalid preset file.', 'Error');
                return;
            end
            obj.applyPreset(loaded.preset);
            obj.updateControlStates();
            obj.clearCache();
            obj.generate();
            fprintf('Loaded preset: %s\n', selectedName);
        end

        function savePresetCallback(obj)
            arguments
                obj RasterGUI
            end
            answer = inputdlg({'Preset name:'}, 'Save Preset', 1, {'untitled'});
            if isempty(answer) || isempty(answer{1})
                return;
            end
            presetName = answer{1};
            % Validate name
            allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
            if any(~ismember(presetName, allowedChars))
                warndlg(sprintf('Preset name can only contain: %s', allowedChars), 'Invalid name');
                return;
            end
            preset = obj.getPreset();
            presetPath = fullfile(obj.getPresetDir(), [presetName, '.mat']);
            save(presetPath, 'preset');
            fprintf('Saved preset: %s\n', presetName);
            obj.refreshPresetList();
            % Select the newly saved preset
            names = obj.popup_Presets.String;
            idx = find(strcmp(names, presetName), 1);
            if ~isempty(idx)
                obj.popup_Presets.Value = idx;
            end
        end

        function deletePresetCallback(obj)
            arguments
                obj RasterGUI
            end
            presetNames = obj.popup_Presets.String;
            selectedName = presetNames{obj.popup_Presets.Value};
            answer = questdlg(sprintf('Delete preset "%s"?', selectedName), ...
                'Delete Preset', 'Delete', ...
                'Cancel', 'Cancel');
            if ~strcmp(answer, 'Delete')
                return;
            end
            presetPath = fullfile(obj.getPresetDir(), [selectedName, '.mat']);
            if isfile(presetPath)
                delete(presetPath);
                fprintf('Deleted preset: %s\n', selectedName);
            end
            obj.refreshPresetList();
        end
    end

    methods (Access = private, Static)
        function setPopupByName(popup, preset, fieldName)
            % Set a popup's value by matching a name string from the preset
            % to the popup's current String list. Warns if not found.
            arguments
                popup (1, 1) matlab.ui.control.UIControl
                preset (1, 1) struct
                fieldName (1, :) char
            end
            if ~isfield(preset, fieldName)
                return;
            end
            targetName = preset.(fieldName);
            strs = popup.String;
            idx = find(strcmp(strs, targetName), 1);
            if ~isempty(idx)
                popup.Value = idx;
            else
                warning('RasterGUI:presetMismatch', ...
                    'Preset value "%s" for %s not found in current options. Keeping current selection.', ...
                    targetName, fieldName);
            end
        end

        function setCheckbox(checkbox, preset, fieldName)
            % Set a checkbox value from a preset field if it exists.
            arguments
                checkbox (1, 1) matlab.ui.control.UIControl
                preset (1, 1) struct
                fieldName (1, :) char
            end
            if isfield(preset, fieldName)
                checkbox.Value = preset.(fieldName);
            end
        end

        function value = parseDouble(editBox, fallback)
            % Parse a numeric value from an edit box, returning the
            % fallback if the string is not a valid finite number.
            arguments
                editBox (1, 1) matlab.ui.control.UIControl
                fallback (1, 1) double
            end
            value = str2double(editBox.String);
            if ~isfinite(value)
                value = fallback;
                editBox.String = num2str(fallback);
            end
        end
    end

    %% Export
    methods (Access = private)
        function exportToFigure(obj)
            % Copy the axes panel contents to a new standalone figure.
            arguments
                obj RasterGUI
            end
            newFig = figure('Name', 'Raster Export', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'figure', ...
                'Units', 'normalized', ...
                'Position', [0.1, 0.1, 0.7, 0.8]);

            % Copy each axes into the new figure, preserving positions
            axesToCopy = [obj.axes_Raster, obj.axes_PSTH, obj.axes_Hist];
            for k = 1:length(axesToCopy)
                srcAx = axesToCopy(k);
                if ~isempty(srcAx.Children)
                    newAx = copyobj(srcAx, newFig);
                    newAx.Position = srcAx.Position;
                end
            end
        end

        function exportToFile(obj, format)
            % Export the axes panel to an image file.
            %
            % Arguments:
            %   format - one of 'png', 'pdf', 'jpg', 'svg'
            arguments
                obj RasterGUI
                format (1, :) char {mustBeMember(format, {'png', 'pdf', 'jpg', 'svg'})}
            end

            % Build file filter for the dialog
            switch format
                case 'png'
                    filter = {'*.png', 'PNG Image (*.png)'};
                case 'pdf'
                    filter = {'*.pdf', 'PDF Document (*.pdf)'};
                case 'jpg'
                    filter = {'*.jpg', 'JPEG Image (*.jpg)'};
                case 'svg'
                    filter = {'*.svg', 'SVG Vector Image (*.svg)'};
                otherwise
                    filter = {'*.*', 'All Files (*.*)'};
            end

            [fileName, filePath] = uiputfile(filter, 'Export raster plot');
            if isequal(fileName, 0)
                return;  % User cancelled
            end
            fullPath = fullfile(filePath, fileName);

            % Create a temporary invisible figure with the axes
            tempFig = figure('Visible', 'off', ...
                'Units', 'normalized', ...
                'Position', [0, 0, 0.7, 0.8], ...
                'Color', 'w');

            axesToCopy = [obj.axes_Raster, obj.axes_PSTH, obj.axes_Hist];
            for k = 1:length(axesToCopy)
                srcAx = axesToCopy(k);
                if ~isempty(srcAx.Children)
                    newAx = copyobj(srcAx, tempFig);
                    newAx.Position = srcAx.Position;
                end
            end

            % Export based on format
            switch format
                case 'png'
                    exportgraphics(tempFig, fullPath, 'Resolution', 300);
                case 'pdf'
                    exportgraphics(tempFig, fullPath, 'ContentType', 'vector');
                case 'jpg'
                    exportgraphics(tempFig, fullPath, 'Resolution', 300);
                case 'svg'
                    saveas(tempFig, fullPath, 'svg');
            end

            close(tempFig);
            fprintf('Exported to: %s\n', fullPath);
        end
    end

    %% Event series management
    methods (Access = private)
        function DefaultSeriesColors = getDefaultSeriesColors(~)
            % Default color palette for event series
            DefaultSeriesColors = [
                0.0, 0.0, 0.0;   % Black
                1.0, 0.0, 0.0;   % Red
                0.0, 0.0, 1.0;   % Blue
                0.0, 0.6, 0.0;   % Green
                0.8, 0.4, 0.0;   % Orange
                0.5, 0.0, 0.8;   % Purple
            ];
        end

        function series = createDefaultEventSeries(obj, seriesNumber)
            % Create a new event series struct with default values.
            arguments
                obj RasterGUI
                seriesNumber (1, 1) double {mustBePositive, mustBeInteger}
            end
            colors = obj.getDefaultSeriesColors();
            colorIdx = mod(seriesNumber - 1, size(colors, 1)) + 1;
            series.name = sprintf('Event series %d', seriesNumber);
            series.sourceIdx = 1;           % Default to first source (Sound)
            series.type = 'Syllables';
            series.filterMode = 'All';
            series.filterList = '';
            series.burstFrequency = 100;    % Hz threshold for burst detection
            series.burstMinSpikes = 2;      % Min events to form a valid burst
            series.selectionMode = 'Selected only';  % 'All', 'Selected only', 'Unselected only'
            series.color = colors(colorIdx, :);
            series.showPSTH = (seriesNumber == 1);  % First series shows PSTH by default
            series.psthStyle = 'Line';
        end

        function addEventSeries(obj)
            % Add a new event series with default values.
            arguments
                obj RasterGUI
            end
            seriesNum = length(obj.ControlParams.eventSeries) + 1;
            obj.ControlParams.eventSeries(seriesNum) = obj.createDefaultEventSeries(seriesNum);
            obj.refreshEventSeriesList();
            obj.list_EventSeries.Value = seriesNum;
            obj.selectEventSeries();
            obj.clearCache();
        end

        function removeEventSeries(obj)
            % Remove the currently selected event series.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            obj.ControlParams.eventSeries(idx) = [];
            obj.refreshEventSeriesList();
            if ~isempty(obj.ControlParams.eventSeries)
                obj.list_EventSeries.Value = min(idx, length(obj.ControlParams.eventSeries));
                obj.selectEventSeries();
            else
                obj.hideEventSeriesDetail();
            end
            obj.clearCache();
        end

        function refreshEventSeriesList(obj)
            % Update the listbox display from the eventSeries array.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                obj.list_EventSeries.String = {'(No event series)'};
                obj.list_EventSeries.Value = 1;
                obj.push_EventSeriesRemove.Enable = 'off';
            else
                names = cell(1, length(obj.ControlParams.eventSeries));
                for k = 1:length(obj.ControlParams.eventSeries)
                    names{k} = obj.ControlParams.eventSeries(k).name;
                end
                obj.list_EventSeries.String = names;
                obj.push_EventSeriesRemove.Enable = 'on';
            end
        end

        function selectEventSeries(obj)
            % Populate the detail controls from the selected event series.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                obj.hideEventSeriesDetail();
                return;
            end
            idx = obj.list_EventSeries.Value;
            if idx < 1 || idx > length(obj.ControlParams.eventSeries)
                obj.hideEventSeriesDetail();
                return;
            end
            series = obj.ControlParams.eventSeries(idx);

            % Show detail controls
            obj.showEventSeriesDetail();

            % Populate values
            obj.edit_EventSeriesName.String = series.name;

            % Set source popup
            obj.popup_EventSeriesSource.Value = series.sourceIdx;

            % Update type options based on source, then set type
            obj.updateEventSeriesTypeOptions();
            typeStrs = obj.popup_EventSeriesType.String;
            typeIdx = find(strcmp(typeStrs, series.type), 1);
            if ~isempty(typeIdx)
                obj.popup_EventSeriesType.Value = typeIdx;
            else
                obj.popup_EventSeriesType.Value = 1;
            end

            % Filter
            filterModes = obj.popup_EventSeriesFilterMode.String;
            filterIdx = find(strcmp(filterModes, series.filterMode), 1);
            if ~isempty(filterIdx)
                obj.popup_EventSeriesFilterMode.Value = filterIdx;
            end
            obj.edit_EventSeriesFilterList.String = series.filterList;

            % Burst parameters
            obj.edit_EventSeriesBurstFreq.String = num2str(series.burstFrequency);
            obj.edit_EventSeriesBurstMinSpikes.String = num2str(series.burstMinSpikes);

            % Selection mode — controls whether to use all events/segments,
            % only those marked as selected in the dbase, or only
            % unselected ones. Applies to both Sound sources
            % (SegmentIsSelected/MarkerIsSelected) and spike sources
            % (EventIsSelected).
            selStrs = obj.popup_EventSeriesSelection.String;
            selIdx = find(strcmp(selStrs, series.selectionMode), 1);
            if ~isempty(selIdx)
                obj.popup_EventSeriesSelection.Value = selIdx;
            else
                obj.popup_EventSeriesSelection.Value = 1;  % Default to 'All'
            end

            % Color button
            obj.push_EventSeriesColor.BackgroundColor = series.color;

            % PSTH checkbox and style
            obj.check_EventSeriesPSTH.Value = series.showPSTH;
            styleStrs = obj.popup_EventSeriesPSTHStyle.String;
            styleIdx = find(strcmp(styleStrs, series.psthStyle), 1);
            if ~isempty(styleIdx)
                obj.popup_EventSeriesPSTHStyle.Value = styleIdx;
            else
                obj.popup_EventSeriesPSTHStyle.Value = 3;  % Default to 'Both'
            end

            % Show/hide context-dependent controls based on source and type
            obj.updateEventSeriesDetailVisibility();
        end

        function saveSelectedEventSeries(obj)
            % Save the detail control values back to the selected series.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            if idx < 1 || idx > length(obj.ControlParams.eventSeries)
                return;
            end

            obj.ControlParams.eventSeries(idx).name = obj.edit_EventSeriesName.String;
            obj.ControlParams.eventSeries(idx).sourceIdx = obj.popup_EventSeriesSource.Value;
            typeStrs = obj.popup_EventSeriesType.String;
            obj.ControlParams.eventSeries(idx).type = typeStrs{obj.popup_EventSeriesType.Value};
            filterModes = obj.popup_EventSeriesFilterMode.String;
            obj.ControlParams.eventSeries(idx).filterMode = filterModes{obj.popup_EventSeriesFilterMode.Value};
            obj.ControlParams.eventSeries(idx).filterList = obj.edit_EventSeriesFilterList.String;
            obj.ControlParams.eventSeries(idx).burstFrequency = str2double(obj.edit_EventSeriesBurstFreq.String);
            obj.ControlParams.eventSeries(idx).burstMinSpikes = str2double(obj.edit_EventSeriesBurstMinSpikes.String);
            selStrs = obj.popup_EventSeriesSelection.String;
            obj.ControlParams.eventSeries(idx).selectionMode = selStrs{obj.popup_EventSeriesSelection.Value};
            obj.ControlParams.eventSeries(idx).color = obj.push_EventSeriesColor.BackgroundColor;
            obj.ControlParams.eventSeries(idx).showPSTH = logical(obj.check_EventSeriesPSTH.Value);
            styleStrs = obj.popup_EventSeriesPSTHStyle.String;
            obj.ControlParams.eventSeries(idx).psthStyle = styleStrs{obj.popup_EventSeriesPSTHStyle.Value};

            % Update list display in case name changed
            obj.refreshEventSeriesList();
            obj.list_EventSeries.Value = idx;
        end

        function showEventSeriesDetail(obj)
            % Show the detail panel and update context-dependent controls
            % (filter vs burst) based on the current source and type.
            arguments
                obj RasterGUI
            end
            obj.panel_EventSeriesDetail.Visible = 'on';
            obj.updateEventSeriesDetailVisibility();
        end

        function hideEventSeriesDetail(obj)
            % Hide the entire detail panel.
            arguments
                obj RasterGUI
            end
            obj.panel_EventSeriesDetail.Visible = 'off';
        end

        function updateEventSeriesTypeOptions(obj)
            % Update the type dropdown options based on the selected source.
            arguments
                obj RasterGUI
            end
            numEventSources = length(obj.eg.dbase.EventSources);
            sourceIdx = obj.popup_EventSeriesSource.Value - 1;
            if sourceIdx == 0
                types = {'Syllables', 'Markers', 'Motifs', 'Bouts'};
            elseif sourceIdx <= numEventSources
                types = {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses'};
            else
                types = {'Continuous function'};
            end
            if ~isequal(obj.popup_EventSeriesType.String, types)
                obj.popup_EventSeriesType.String = types;
                obj.popup_EventSeriesType.Value = 1;
            end
        end

        function updateEventSeriesDetailVisibility(obj)
            % Show/hide the filter and burst controls based on the
            % selected source and type. Sound sources show include/
            % exclude filter controls; spike sources with burst types
            % show burst frequency/min spikes controls; other spike
            % types (Events, Pauses) show neither.
            arguments
                obj RasterGUI
            end
            sourceIdx = obj.popup_EventSeriesSource.Value - 1;  % 0 = Sound
            typeStrs = obj.popup_EventSeriesType.String;
            typeStr = typeStrs{obj.popup_EventSeriesType.Value};
            isSoundSource = (sourceIdx == 0);
            isBurstType = ismember(typeStr, {'Bursts', 'Burst events', 'Single events'});

            % Filter controls: visible only for Sound sources
            filterWidgets = [obj.popup_EventSeriesFilterMode, ...
                obj.edit_EventSeriesFilterList];
            if isSoundSource
                set(filterWidgets, 'Visible', 'on');
                % Enable/disable filter list based on filter mode
                modes = obj.popup_EventSeriesFilterMode.String;
                isAll = strcmp(modes{obj.popup_EventSeriesFilterMode.Value}, 'All');
                if isAll
                    obj.edit_EventSeriesFilterList.Enable = 'off';
                else
                    obj.edit_EventSeriesFilterList.Enable = 'on';
                end
            else
                set(filterWidgets, 'Visible', 'off');
            end

            % Burst controls: visible only for spike sources with burst types
            burstWidgets = [obj.text_EventSeriesBurstFreq, ...
                obj.edit_EventSeriesBurstFreq, ...
                obj.text_EventSeriesBurstMinSpikes, ...
                obj.edit_EventSeriesBurstMinSpikes];
            if ~isSoundSource && isBurstType
                set(burstWidgets, 'Visible', 'on');
            else
                set(burstWidgets, 'Visible', 'off');
            end
        end

        function eventSeriesDetailChanged(obj)
            % Called when any detail control changes. Saves back to the
            % series array and clears cache.
            arguments
                obj RasterGUI
            end
            obj.saveSelectedEventSeries();
            obj.clearCache();
        end

        function eventSeriesSourceChanged(obj)
            % Called when the series source popup changes. Updates type
            % options, updates detail visibility, saves, and clears cache.
            arguments
                obj RasterGUI
            end
            obj.updateEventSeriesTypeOptions();
            obj.updateEventSeriesDetailVisibility();
            obj.saveSelectedEventSeries();
            obj.clearCache();
        end

        function eventSeriesTypeChanged(obj)
            % Called when the series type popup changes. Updates detail
            % visibility (filter vs burst controls), saves, and clears cache.
            arguments
                obj RasterGUI
            end
            obj.updateEventSeriesDetailVisibility();
            obj.saveSelectedEventSeries();
            obj.clearCache();
        end

        function eventSeriesFilterModeChanged(obj)
            % Called when the filter mode changes. Updates filter list
            % enable state, saves, and clears cache.
            arguments
                obj RasterGUI
            end
            obj.updateEventSeriesDetailVisibility();
            obj.saveSelectedEventSeries();
            obj.clearCache();
        end

        function eventSeriesNameChanged(obj)
            % Called when the series name is edited. Saves and refreshes list.
            arguments
                obj RasterGUI
            end
            obj.saveSelectedEventSeries();
        end

        function eventSeriesColorPicked(obj)
            % Open a color picker for the selected series. Color is a
            % display-only property, so replot from cache rather than
            % clearing cache and regenerating.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            newColor = uisetcolor(obj.ControlParams.eventSeries(idx).color, 'Pick series color');
            if length(newColor) == 3
                obj.ControlParams.eventSeries(idx).color = newColor;
                obj.push_EventSeriesColor.BackgroundColor = newColor;
                obj.replotFromCache();
            end
        end

        function eventSeriesPSTHChanged(obj)
            % Update the selected series' showPSTH and psthStyle, then
            % replot. Multiple series can have showPSTH=true simultaneously.
            arguments
                obj RasterGUI
            end
            if isempty(obj.ControlParams.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            obj.ControlParams.eventSeries(idx).showPSTH = logical(obj.check_EventSeriesPSTH.Value);
            styleStrs = obj.popup_EventSeriesPSTHStyle.String;
            obj.ControlParams.eventSeries(idx).psthStyle = styleStrs{obj.popup_EventSeriesPSTHStyle.Value};
            % Replot PSTH and histogram to reflect the change
            obj.plotPSTH();
            obj.plotHist();
        end
    end

    %% Cache management
    methods (Access = private)
        function clearCache(obj)
            % Clear extracted trial data. Called when any upstream setting
            % changes (trigger/event source/type, window, file range,
            % include/ignore lists) to force a full re-extraction on next
            % generate.
            arguments
                obj RasterGUI
            end
            obj.TriggerData = struct( ...
                'fileNum', {}, 'isComplete', {}, 'absTime', {}, ...
                'label', {}, 'corrShift', {}, ...
                'onset', {}, 'offset', {}, ...
                'prevOnset', {}, 'prevOffset', {}, ...
                'nextOnset', {}, 'nextOffset', {}, ...
                'dataStart', {}, 'dataStop', {});
            obj.EventData = {};
            obj.TrialOrder = [];
        end

        function hasCache = hasCachedData(obj)
            % Check if extracted trial data exists.
            arguments
                obj RasterGUI
            end
            hasCache = ~isempty(obj.TriggerData);
        end

        function resortAndPlot(obj)
            % Recompute TrialOrder from current sort settings and replot.
            % No data is re-extracted or mutated — only the index vector
            % changes. No-op if no trial data exists.
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerData)
                return;
            end

            obj.statusBar.Status = 'Re-sorting...';
            obj.statusBar.Progress = 0.3;
            drawnow;

            obj.syncOptionsFromGUI();
            obj.computeTrialOrder();

            obj.statusBar.Status = 'Plotting...';
            obj.statusBar.Progress = 0.7;
            drawnow;
            obj.plotRaster();
            obj.plotPSTH();
            obj.plotHist();
            obj.updateLegend();

            % Update backup limits for double-click zoom reset
            obj.BackupXLim = obj.axes_Raster.XLim;
            obj.BackupPSTHYLim = obj.axes_PSTH.YLim;
            obj.BackupHistXLim = obj.axes_Hist.XLim;

            obj.statusBar.Status = sprintf( ...
                'Re-sorted — %d trials', length(obj.TrialOrder));
            obj.statusBar.Progress = 1;
        end
    end

    %% Widget enable/disable management
    methods (Access = private)
        function setAllControlsEnabled(obj, enabled)
            % Enable or disable all interactive controls. Called with
            % false to lock the UI during generation, and with true
            % (via updateControlStates) when generation completes.
            % Uses a cell array rather than concatenation so that
            % controls of different types (uicontrol, uitable2, etc.)
            % can coexist without type-conversion errors.
            arguments
                obj RasterGUI
                enabled (1, 1) logical
            end
            if enabled
                enableState = 'on';
            else
                enableState = 'off';
            end
            controls = { ...
                obj.popup_TriggerSource, ...
                obj.popup_TriggerType, ...
                obj.popup_TriggerAlignment, ...
                obj.popup_TrigFilterMode, ...
                obj.edit_TrigFilterList, ...
                obj.check_ExcludeIncomplete, ...
                obj.check_PlotOtherTrialTriggers, ...
                obj.list_TriggerLabels, ...
                obj.push_TrigLabelColor, ...
                obj.check_TrigAutoColor, ...
                obj.popup_TrigColormap, ...
                obj.check_TrigAutoUpdate, ...
                obj.push_TrigUpdate, ...
                obj.list_EventSeries, ...
                obj.push_EventSeriesAdd, ...
                obj.push_EventSeriesRemove, ...
                obj.edit_EventSeriesName, ...
                obj.popup_EventSeriesSource, ...
                obj.popup_EventSeriesType, ...
                obj.popup_EventSeriesFilterMode, ...
                obj.edit_EventSeriesFilterList, ...
                obj.edit_EventSeriesBurstFreq, ...
                obj.edit_EventSeriesBurstMinSpikes, ...
                obj.popup_EventSeriesSelection, ...
                obj.push_EventSeriesColor, ...
                obj.check_EventSeriesPSTH, ...
                obj.popup_EventSeriesPSTHStyle, ...
                obj.popup_StartReference, ...
                obj.popup_StopReference, ...
                obj.edit_PreStart, ...
                obj.edit_PostStop, ...
                obj.check_ExcludePartialEvents, ...
                obj.check_WindowAutoUpdate, ...
                obj.push_WindowUpdate, ...
                obj.popup_PrimarySort, ...
                obj.popup_SecondarySort, ...
                obj.radio_Ascending, ...
                obj.radio_Descending, ...
                obj.check_GroupLabels, ...
                obj.popup_Files, ...
                obj.edit_FileRange, ...
                obj.push_Open, ...
                obj.popup_PropertyFilterMode, ...
                obj.popup_PropertyName, ...
                obj.edit_PropertyExpression, ...
                obj.check_FilesAutoUpdate, ...
                obj.push_FilesUpdate, ...
                obj.popup_PSTHUnits, ...
                obj.popup_PSTHCount, ...
                obj.check_AutoXLim, ...
                obj.check_ShowLegend, ...
                obj.check_LegendTriggers, ...
                obj.check_LegendEvents, ...
                obj.check_PlotAutoUpdate, ...
                obj.push_PlotUpdate, ...
                obj.edit_XMin, ...
                obj.edit_XMax, ...
                obj.edit_TickHeight, ...
                obj.edit_BinSize, ...
                obj.edit_TickLineWidth, ...
                obj.edit_Overlap, ...
                obj.popup_Presets, ...
                obj.push_LoadPreset, ...
                obj.push_SavePreset, ...
                obj.push_DeletePreset, ...
                obj.push_RefreshPresets, ...
                obj.push_ExportFigure, ...
                obj.push_ExportPNG, ...
                obj.push_ExportPDF, ...
                obj.push_ExportJPG, ...
                obj.push_ExportSVG, ...
                obj.push_GenerateRaster};
            for controlIdx = 1:length(controls)
                controls{controlIdx}.Enable = enableState;
            end
        end

        function updateControlStates(obj)
            % Set each control to its correct enabled/disabled state based
            % on current context. Call this after an operation completes.
            arguments
                obj RasterGUI
            end

            % Default: enable everything
            obj.setAllControlsEnabled(true);

            % Update trigger type options based on trigger source.
            % Source index 0 means "Sound", which provides behavioral
            % triggers (syllables, markers, etc.). Any other source is
            % an event detector, which provides neural event types.
            % numEventSources = length(obj.eg.dbase.EventSources);
            trigSourceIdx = obj.popup_TriggerSource.Value - 1;
            if trigSourceIdx == 0
                % Sound source: behavioral trigger types
                trigTypes = {'Syllables', 'Markers', 'Motifs', 'Bouts'};
            else
                % Event detector source: neural trigger types
                trigTypes = {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses'};
            end
            % Only update if the options actually changed, to avoid
            % resetting the user's selection unnecessarily
            if ~isequal(obj.popup_TriggerType.String, trigTypes)
                obj.popup_TriggerType.String = trigTypes;
                obj.popup_TriggerType.Value = 1;
            end

            % Trigger include/ignore: only when type needs them
            obj.updateTriggerOptionsVisibility();


            % Preset Load/Delete: only when presets exist
            presetNames = obj.popup_Presets.String;
            hasPresets = ~isempty(presetNames) && ~strcmp(presetNames{1}, '(No presets found)');
            if ~hasPresets
                obj.popup_Presets.Enable = 'off';
                obj.push_LoadPreset.Enable = 'off';
                obj.push_DeletePreset.Enable = 'off';
            end

            % X limit edits: disabled when auto is on
            if obj.check_AutoXLim.Value
                obj.edit_XMin.Enable = 'off';
                obj.edit_XMax.Enable = 'off';
            end

            % Trigger label color controls
            obj.updateTrigLabelControlStates();
        end
    end

    %% Callback stubs
    methods (Access = private)
        function updateTriggerOptionsVisibility(obj)
            % Show/hide trigger filter controls based on the selected type.
            arguments
                obj RasterGUI
            end
            trigTypeStrs = obj.popup_TriggerType.String;
            trigType = trigTypeStrs{obj.popup_TriggerType.Value};
            showFilter = ismember(trigType, {'Syllables', 'Markers', 'Bouts'});
            onOff = {'off', 'on'};
            vis = onOff{showFilter + 1};
            obj.popup_TrigFilterMode.Visible = vis;
            obj.edit_TrigFilterList.Visible = vis;
            % Disable text field when mode is "All"
            trigModes = obj.popup_TrigFilterMode.String;
            isAll = strcmp(trigModes{obj.popup_TrigFilterMode.Value}, 'All');
            obj.edit_TrigFilterList.Enable = onOff{~isAll + 1};
        end
        function syncOptionsFromGUI(obj)
            % Read all GUI controls into ControlParams — the single source
            % of truth for the entire GUI state. Also computes the derived
            % FileRange property from the raw filter settings.
            arguments
                obj RasterGUI
            end

            % --- Trigger filter ---
            trigModes = obj.popup_TrigFilterMode.String;
            obj.ControlParams.trigger.filterMode = trigModes{obj.popup_TrigFilterMode.Value};
            obj.ControlParams.trigger.filterList = obj.edit_TrigFilterList.String;

            % --- Trigger source and type ---
            trigSourceStrs = obj.popup_TriggerSource.String;
            obj.ControlParams.triggerSource = trigSourceStrs{obj.popup_TriggerSource.Value};
            obj.ControlParams.triggerSourceIdx = obj.popup_TriggerSource.Value - 1;
            trigTypeStrs = obj.popup_TriggerType.String;
            obj.ControlParams.triggerType = trigTypeStrs{obj.popup_TriggerType.Value};

            % --- Alignment ---
            alignStrs = obj.popup_TriggerAlignment.String;
            obj.ControlParams.alignmentType = alignStrs{obj.popup_TriggerAlignment.Value};

            % --- Window references ---
            startRefStrs = obj.popup_StartReference.String;
            obj.ControlParams.startRefType = startRefStrs{obj.popup_StartReference.Value};
            stopRefStrs = obj.popup_StopReference.String;
            obj.ControlParams.stopRefType = stopRefStrs{obj.popup_StopReference.Value};
            obj.ControlParams.preStartRef = RasterGUI.parseDouble(obj.edit_PreStart, obj.ControlParams.preStartRef);
            obj.ControlParams.postStopRef = RasterGUI.parseDouble(obj.edit_PostStop, obj.ControlParams.postStopRef);

            % --- Exclude flags ---
            obj.ControlParams.excludeIncomplete = logical(obj.check_ExcludeIncomplete.Value);
            obj.ControlParams.excludePartialEvents = logical(obj.check_ExcludePartialEvents.Value);
            obj.ControlParams.plotOtherTrialTriggers = logical(obj.check_PlotOtherTrialTriggers.Value);

            % --- Sort settings ---
            primarySortStrs = obj.popup_PrimarySort.String;
            obj.ControlParams.primarySort = primarySortStrs{obj.popup_PrimarySort.Value};
            secondarySortStrs = obj.popup_SecondarySort.String;
            obj.ControlParams.secondarySort = secondarySortStrs{obj.popup_SecondarySort.Value};
            obj.ControlParams.sortDescending = logical(obj.radio_Descending.Value);
            obj.ControlParams.groupLabels = logical(obj.check_GroupLabels.Value);

            % --- Event series ---
            % Save the currently selected series' detail controls back to
            % the ControlParams.eventSeries array
            if ~isempty(obj.ControlParams.eventSeries)
                obj.saveSelectedEventSeries();
            end

            % --- File filter settings (raw GUI values) ---
            fileFilterStrs = obj.popup_Files.String;
            obj.ControlParams.fileFilter = fileFilterStrs{obj.popup_Files.Value};
            obj.ControlParams.fileRangeExpression = obj.edit_FileRange.String;
            propModes = obj.popup_PropertyFilterMode.String;
            obj.ControlParams.propertyFilterMode = propModes{obj.popup_PropertyFilterMode.Value};
            propNames = obj.popup_PropertyName.String;
            obj.ControlParams.propertyName = propNames{obj.popup_PropertyName.Value};
            obj.ControlParams.propertyExpression = obj.edit_PropertyExpression.String;

            % --- Compute derived FileRange from raw filter settings ---
            try
                obj.FileRange = eval(obj.ControlParams.fileRangeExpression);
            catch
                electro_gui.issueWarning('Invalid file range expression, using all files.', 'badFileRange');
                numFiles = electro_gui.getNumFiles(obj.eg.dbase);
                obj.FileRange = 1:numFiles;
            end
            switch obj.ControlParams.fileFilter
                case 'Only read files'
                    readMask = obj.eg.dbase.FileReadState(obj.FileRange);
                    obj.FileRange = obj.FileRange(readMask);
                case 'Only unread files'
                    readMask = obj.eg.dbase.FileReadState(obj.FileRange);
                    obj.FileRange = obj.FileRange(~readMask);
            end
            switch obj.ControlParams.propertyFilterMode
                case 'Single'
                    if ~strcmp(obj.ControlParams.propertyName, '(No properties)')
                        propValues = obj.eg.getPropertyValue(obj.ControlParams.propertyName, obj.FileRange);
                        obj.FileRange = obj.FileRange(logical(propValues));
                    end
                case 'Expression'
                    if ~isempty(strtrim(obj.ControlParams.propertyExpression))
                        try
                            obj.FileRange = obj.evaluatePropertyExpression( ...
                                obj.ControlParams.propertyExpression, obj.FileRange);
                        catch ME
                            warndlg(sprintf('Property expression error: %s', ME.message), 'Expression error');
                        end
                    end
            end

            % --- Plot settings ---
            obj.ControlParams.autoXLim = logical(obj.check_AutoXLim.Value);
            obj.ControlParams.plotXLim = [ ...
                RasterGUI.parseDouble(obj.edit_XMin, obj.ControlParams.plotXLim(1)), ...
                RasterGUI.parseDouble(obj.edit_XMax, obj.ControlParams.plotXLim(2))];
            obj.ControlParams.plotTickSize.tickHeight = RasterGUI.parseDouble(obj.edit_TickHeight, obj.ControlParams.plotTickSize.tickHeight);
            obj.ControlParams.plotTickSize.lineWidth = RasterGUI.parseDouble(obj.edit_TickLineWidth, obj.ControlParams.plotTickSize.lineWidth);
            obj.ControlParams.psthBinSize = RasterGUI.parseDouble(obj.edit_BinSize, obj.ControlParams.psthBinSize);
            obj.ControlParams.plotOverlap = RasterGUI.parseDouble(obj.edit_Overlap, obj.ControlParams.plotOverlap);

            % --- PSTH settings ---
            psthUnitStrs = obj.popup_PSTHUnits.String;
            obj.ControlParams.psthUnits = psthUnitStrs{obj.popup_PSTHUnits.Value};
            psthCountStrs = obj.popup_PSTHCount.String;
            obj.ControlParams.psthCount = psthCountStrs{obj.popup_PSTHCount.Value};

            % --- Legend settings ---
            obj.ControlParams.showLegend = logical(obj.check_ShowLegend.Value);
            obj.ControlParams.legendTriggers = logical(obj.check_LegendTriggers.Value);
            obj.ControlParams.legendEvents = logical(obj.check_LegendEvents.Value);

            % --- Auto-update settings ---
            obj.ControlParams.autoUpdateTrigger = logical(obj.check_TrigAutoUpdate.Value);
            obj.ControlParams.autoUpdateWindow = logical(obj.check_WindowAutoUpdate.Value);
            obj.ControlParams.autoUpdateFiles = logical(obj.check_FilesAutoUpdate.Value);
            obj.ControlParams.autoUpdatePlot = logical(obj.check_PlotAutoUpdate.Value);
        end
        function autoXLimChanged(obj)
            % Called when the Auto X limits checkbox changes.
            arguments
                obj RasterGUI
            end
            obj.updateControlStates();
            obj.syncOptionsFromGUI();
            obj.applyXLim();
        end
        function xLimChanged(obj)
            % Called when the X min or X max edit box changes.
            arguments
                obj RasterGUI
            end
            obj.syncOptionsFromGUI();
            obj.applyXLim();
        end
        function applyXLim(obj)
            % Apply X limits to all axes based on auto/manual mode.
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerData)
                return;
            end
            if obj.ControlParams.autoXLim
                % Recompute tight limits from raster data
                obj.plotRaster();  % Will compute and set tight X limits
            else
                obj.axes_Raster.XLim = obj.ControlParams.plotXLim;  % PSTH follows via linkprop
            end
            % Replot PSTH and histogram since their bin range depends on X limits
            obj.plotPSTH();
            obj.plotHist();
        end
        function plotSettingChanged(obj)
            % Called when a plot display setting changes (tick height,
            % bin size, line width, overlap). Replots if auto-update is on.
            arguments
                obj RasterGUI
            end
            obj.syncOptionsFromGUI();
            if obj.check_PlotAutoUpdate.Value
                obj.replotFromCache();
            end
        end
        function replotFromCache(obj)
            % Replot from existing trial data without re-extracting or
            % re-sorting. Used when only display settings change (tick
            % height, colors, bin size, etc.).
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerData)
                return;
            end
            obj.syncOptionsFromGUI();
            obj.plotRaster();
            obj.plotPSTH();
            obj.plotHist();
            obj.updateLegend();
            % Update backup limits for double-click zoom reset
            obj.BackupXLim = obj.axes_Raster.XLim;
            obj.BackupPSTHYLim = obj.axes_PSTH.YLim;
            obj.BackupHistXLim = obj.axes_Hist.XLim;
        end
        function windowSettingChanged(obj)
            % Called when a Window tab setting changes. Clears cache
            % and regenerates if auto-update is on.
            arguments
                obj RasterGUI
            end
            obj.clearCache();
            obj.updateControlStates();
            if obj.check_WindowAutoUpdate.Value
                obj.generate();
            end
        end
        function triggerSettingChanged(obj)
            % Called when a Trigger tab setting changes. Clears cache
            % and regenerates if auto-update is on.
            %
            % Optimization: if only the filter changed and the effective
            % filter settings are identical (after normalizing empty
            % Include/Exclude as All), skip the expensive regeneration.
            arguments
                obj RasterGUI
            end

            % Check if the effective filter settings actually changed
            trigModes = obj.popup_TrigFilterMode.String;
            newMode = trigModes{obj.popup_TrigFilterMode.Value};
            newList = obj.edit_TrigFilterList.String;
            % Normalize: empty Include or Exclude is equivalent to All
            if ismember(newMode, {'Include', 'Exclude'}) && isempty(newList)
                effectiveNewMode = 'All';
            else
                effectiveNewMode = newMode;
            end
            oldList = obj.ControlParams.trigger.filterList;
            if ismember(obj.ControlParams.trigger.filterMode, {'Include', 'Exclude'}) && isempty(oldList)
                effectiveOldMode = 'All';
            else
                effectiveOldMode = obj.ControlParams.trigger.filterMode;
            end
            filterUnchanged = strcmp(effectiveNewMode, effectiveOldMode) && ...
                (strcmp(effectiveNewMode, 'All') || strcmp(newList, oldList));

            if filterUnchanged
                % Effective filter unchanged — update stored settings
                % but skip regeneration
                obj.ControlParams.trigger.filterMode = newMode;
                obj.ControlParams.trigger.filterList = newList;
                obj.updateControlStates();
                return;
            end

            obj.clearCache();
            obj.updateControlStates();
            if obj.check_TrigAutoUpdate.Value
                obj.generate();
            end
        end
        function triggerTypeChanged(obj)
            % Called when the trigger Type dropdown changes. Updates
            % filter visibility and clears cache, but does NOT call
            % updateControlStates (which would re-set the Type dropdown
            % options and interfere with the in-progress value change).
            % Regenerates if auto-update is on.
            arguments
                obj RasterGUI
            end
            obj.updateTriggerOptionsVisibility();
            obj.clearCache();
            if obj.check_TrigAutoUpdate.Value
                obj.generate();
            end
        end

        function updateTriggerLabelColors(obj)
            % Update the trigger label color mapping after generate().
            % Discovers all unique labels in the current triggerInfo,
            % preserves existing manual color assignments, and assigns
            % colors to new labels (auto from colormap, or gray for manual).
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerData)
                return;
            end

            % Get unique labels sorted by first appearance
            allLabels = [obj.TriggerData.label]';
            [~, firstIdx] = unique(allLabels, 'first');
            uniqueLabels = allLabels(sort(firstIdx));

            if obj.check_TrigAutoColor.Value
                % Auto-color mode: assign from colormap
                cmapName = obj.popup_TrigColormap.String{obj.popup_TrigColormap.Value};
                cmapFunc = str2func(cmapName);
                nLabels = length(uniqueLabels);
                colors = cmapFunc(max(nLabels, 1));
                obj.TriggerLabelValues = uniqueLabels;
                obj.TriggerLabelColors = colors(1:nLabels, :);
            else
                % Manual mode: preserve existing colors, assign gray to new labels
                oldValues = obj.TriggerLabelValues;
                oldColors = obj.TriggerLabelColors;
                newColors = zeros(length(uniqueLabels), 3);
                for k = 1:length(uniqueLabels)
                    existingIdx = find(oldValues == uniqueLabels(k), 1);
                    if ~isempty(existingIdx)
                        newColors(k, :) = oldColors(existingIdx, :);
                    else
                        newColors(k, :) = [0.5, 0.5, 0.5];  % Gray for new labels
                    end
                end
                obj.TriggerLabelValues = uniqueLabels;
                obj.TriggerLabelColors = newColors;
            end

            obj.refreshTriggerLabelList();
            obj.updateTrigLabelControlStates();
        end

        function refreshTriggerLabelList(obj)
            % Update the trigger label table display with per-row
            % background colors and label text.
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerLabelValues)
                obj.list_TriggerLabels.Data = {'(No triggers yet)'};
                obj.list_TriggerLabels.ResetBackgroundColor();
                obj.text_SelectedTrigLabel.String = 'Selected: (none)';
                obj.panel_SelectedTrigLabel.BackgroundColor = [0.94, 0.94, 0.94];
                obj.text_SelectedTrigLabel.BackgroundColor = [0.94, 0.94, 0.94];
                return;
            end

            numLabels = length(obj.TriggerLabelValues);
            triggerStrings = cell(numLabels, 1);
            for k = 1:numLabels
                labelVal = obj.TriggerLabelValues(k);

                % Determine label display text
                if labelVal == 0
                    triggerStrings{k} = '(unlabeled)';
                elseif labelVal > 1000
                    % Numeric labels (burst counts, motif indices, etc.)
                    triggerStrings{k} = num2str(labelVal - 1000);
                else
                    triggerStrings{k} = char(labelVal);
                end
            end
            obj.list_TriggerLabels.Data = triggerStrings;

            % Set per-row background colors to match trigger label colors.
            % Use lightened colors so the text remains readable.
            bgColors = 1 - (1 - obj.TriggerLabelColors(1:numLabels, :)) * 0.35;
            obj.list_TriggerLabels.BackgroundColor = bgColors;
        end

        function updateTrigLabelControlStates(obj)
            % Enable/disable the color picker and colormap based on
            % auto-color mode.
            arguments
                obj RasterGUI
            end
            if obj.check_TrigAutoColor.Value
                obj.push_TrigLabelColor.Enable = 'off';
                obj.popup_TrigColormap.Enable = 'on';
            else
                obj.push_TrigLabelColor.Enable = 'on';
                obj.popup_TrigColormap.Enable = 'off';
            end
        end

        function selectTriggerLabel(obj)
            % Callback for trigger label table selection. Updates the
            % selected-label indicator panel with the label's color and text.
            arguments
                obj RasterGUI
            end
            idx = obj.list_TriggerLabels.SelectedRow;
            if isempty(idx) || idx < 1 || idx > length(obj.TriggerLabelValues)
                obj.text_SelectedTrigLabel.String = 'Selected: (none)';
                obj.panel_SelectedTrigLabel.BackgroundColor = [0.94, 0.94, 0.94];
                obj.text_SelectedTrigLabel.BackgroundColor = [0.94, 0.94, 0.94];
                obj.text_SelectedTrigLabel.ForegroundColor = [0, 0, 0];
                return;
            end
            % Get the label's color (lightened, same as the table row)
            labelColor = obj.TriggerLabelColors(idx, :);
            bgColor = 1 - (1 - labelColor) * 0.35;
            % Choose readable text color (dark on light, light on dark)
            if mean(bgColor) > 0.5
                textColor = [0, 0, 0];
            else
                textColor = [1, 1, 1];
            end
            % Get label display text
            labelVal = obj.TriggerLabelValues(idx);
            if labelVal == 0
                labelStr = '(unlabeled)';
            elseif labelVal > 1000
                labelStr = num2str(labelVal - 1000);
            else
                labelStr = char(labelVal);
            end
            obj.text_SelectedTrigLabel.String = ['Selected: ', labelStr];
            obj.panel_SelectedTrigLabel.BackgroundColor = bgColor;
            obj.text_SelectedTrigLabel.BackgroundColor = bgColor;
            obj.text_SelectedTrigLabel.ForegroundColor = textColor;
        end

        function trigLabelColorPicked(obj)
            % Open a color picker for the selected trigger label.
            arguments
                obj RasterGUI
            end
            if isempty(obj.TriggerLabelValues)
                return;
            end
            idx = obj.list_TriggerLabels.SelectedRow;
            if isempty(idx) || idx < 1 || idx > length(obj.TriggerLabelValues)
                return;
            end
            newColor = uisetcolor(obj.TriggerLabelColors(idx, :), 'Pick label color');
            if length(newColor) == 3
                obj.TriggerLabelColors(idx, :) = newColor;
                obj.refreshTriggerLabelList();
                obj.selectTriggerLabel();  % Update indicator color
                obj.replotFromCache();
            end
        end

        function trigAutoColorChanged(obj)
            % Called when auto-color checkbox or colormap selection changes.
            % Reassigns colors and replots.
            arguments
                obj RasterGUI
            end
            obj.updateTrigLabelControlStates();
            if obj.check_TrigAutoColor.Value
                % Recompute colors from the selected colormap
                obj.updateTriggerLabelColors();
                obj.selectTriggerLabel();  % Update indicator color
                obj.replotFromCache();
            end
        end

        function rgb = getTriggerLabelColor(obj, labelValue)
            % Look up the color for a given trigger label value.
            % Returns the mapped color, or light red as a fallback.
            arguments
                obj RasterGUI
                labelValue (1, 1) double
            end
            idx = find(obj.TriggerLabelValues == labelValue, 1);
            if ~isempty(idx)
                rgb = obj.TriggerLabelColors(idx, :);
            else
                rgb = [1.0, 0.85, 0.85];  % Default light red
            end
        end

        function ascendingClicked(obj)
            arguments
                obj RasterGUI
            end
            obj.radio_Descending.Value = 0;
            obj.radio_Ascending.Value = 1;
            obj.sortSettingChanged();
        end
        function descendingClicked(obj)
            arguments
                obj RasterGUI
            end
            obj.radio_Ascending.Value = 0;
            obj.radio_Descending.Value = 1;
            obj.sortSettingChanged();
        end
        function sortSettingChanged(obj)
            % Called when a sort-only setting changes (primary/secondary
            % sort, ascending/descending, group labels). Re-sorts from
            % cache if available.
            arguments
                obj RasterGUI
            end
            obj.resortAndPlot();
        end
        function filteredRange = evaluatePropertyExpression(obj, expr, fileRange)
            % Evaluate a boolean property expression to filter files.
            % Creates a temporary workspace with each property name as a
            % logical vector, then evaluates the expression.
            arguments
                obj RasterGUI
                expr (1, :) char
                fileRange (1, :) double
            end
            % Build a struct with property values for the given file range
            propVars = struct();
            for k = 1:length(obj.eg.dbase.PropertyNames)
                propName = obj.eg.dbase.PropertyNames{k};
                % Make sure name is a valid variable name
                safeName = matlab.lang.makeValidName(propName);
                propVars.(safeName) = logical(obj.eg.getPropertyValue(propName, fileRange));
            end
            % Evaluate the expression in the context of these variables
            mask = evalInStruct(propVars, expr);
            if ~islogical(mask) || length(mask) ~= length(fileRange)
                error('Expression must produce a logical vector with one element per file.');
            end
            filteredRange = fileRange(mask);
        end
        function filesSettingChanged(obj)
            % Called when any Files tab setting changes. Clears cache
            % and regenerates if auto-update is on.
            arguments
                obj RasterGUI
            end
            % Update property filter visibility first
            obj.propertyFilterModeChanged();
            obj.clearCache();
            if obj.check_FilesAutoUpdate.Value
                obj.generate();
            end
        end
        function propertyFilterModeChanged(obj)
            arguments
                obj RasterGUI
            end
            modes = obj.popup_PropertyFilterMode.String;
            mode = modes{obj.popup_PropertyFilterMode.Value};
            switch mode
                case '(No property filter)'
                    obj.popup_PropertyName.Visible = 'off';
                    obj.edit_PropertyExpression.Visible = 'off';
                case 'Single'
                    % Populate property names from dbase
                    if ~isempty(obj.eg.dbase.PropertyNames)
                        obj.popup_PropertyName.String = obj.eg.dbase.PropertyNames;
                    else
                        obj.popup_PropertyName.String = {'(No properties)'};
                    end
                    obj.popup_PropertyName.Visible = 'on';
                    obj.edit_PropertyExpression.Visible = 'off';
                case 'Expression'
                    obj.popup_PropertyName.Visible = 'off';
                    obj.edit_PropertyExpression.Visible = 'on';
            end
        end
        function openCallback(obj) %#ok<MANU>
            % TODO: Port open dbase functionality
            arguments
                obj RasterGUI
            end

        end
        function dataRect = rbboxToDataRect(obj, ax)
            % Use rbbox to let the user drag a selection rectangle, then
            % convert to data coordinates. Handles YDir='reverse'.
            % Returns [x, y, width, height] in data units.
            arguments
                obj RasterGUI
                ax (1, 1) matlab.graphics.axis.Axes
            end
            % Temporarily set figure to pixel units so rbbox returns
            % pixels, matching getpixelposition's coordinate system
            oldFigUnits = obj.figure_Main.Units;
            obj.figure_Main.Units = 'pixels';
            pixelRect = rbbox;
            obj.figure_Main.Units = oldFigUnits;

            % getpixelposition(ax, true) returns figure-relative pixels
            axPos = getpixelposition(ax, true);
            xl = ax.XLim;
            yl = ax.YLim;

            % X mapping (XDir is always 'normal')
            fracX = (pixelRect(1) - axPos(1)) / axPos(3);
            fracW = pixelRect(3) / axPos(3);
            dataX = xl(1) + fracX * diff(xl);
            dataW = fracW * diff(xl);

            % Y mapping — account for YDir='reverse' where bottom
            % pixel corresponds to YLim(2) instead of YLim(1)
            fracY = (pixelRect(2) - axPos(2)) / axPos(4);
            fracH = pixelRect(4) / axPos(4);
            if strcmp(ax.YDir, 'reverse')
                dataY = yl(2) - (fracY + fracH) * diff(yl);
            else
                dataY = yl(1) + fracY * diff(yl);
            end
            dataH = fracH * diff(yl);

            dataRect = [dataX, dataY, dataW, dataH];
        end

        function onRasterClick(obj)
            % Handle clicks on the raster axes:
            %   Normal click + drag: rubber-band zoom on X and Y
            %   Normal point click: show trial info in the status bar
            %   Double-click: reset all axes to full limits
            arguments
                obj RasterGUI
            end
            selType = obj.figure_Main.SelectionType;
            ax = obj.axes_Raster;

            if strcmp(selType, 'normal')
                dataRect = obj.rbboxToDataRect(ax);
                if dataRect(3) == 0 || dataRect(4) == 0
                    % Point click — show trial info
                    obj.showTrialInfo(dataRect(1), dataRect(2));
                    return;
                end
                % Rubber-band zoom: set raster limits, PSTH X and Hist Y
                % follow via linkprop
                ax.XLim = [dataRect(1), dataRect(1) + dataRect(3)];
                ax.YLim = [dataRect(2), dataRect(2) + dataRect(4)];

            elseif strcmp(selType, 'open')
                % Double-click: reset all axes to backup limits
                obj.resetZoom();
            end
        end

        function onPSTHClick(obj)
            % Handle clicks on the PSTH axes:
            %   Normal click + drag: zoom X (shared with raster) and PSTH Y
            %   Double-click: reset all axes to backup limits
            arguments
                obj RasterGUI
            end
            selType = obj.figure_Main.SelectionType;
            ax = obj.axes_PSTH;

            if strcmp(selType, 'normal')
                dataRect = obj.rbboxToDataRect(ax);
                if dataRect(3) == 0 || dataRect(4) == 0
                    return;
                end
                % Zoom X on raster (PSTH follows via linkprop) and PSTH Y
                obj.axes_Raster.XLim = [dataRect(1), dataRect(1) + dataRect(3)];
                ax.YLim = [dataRect(2), dataRect(2) + dataRect(4)];

            elseif strcmp(selType, 'open')
                obj.resetZoom();
            end
        end

        function onHistClick(obj)
            % Handle clicks on the histogram axes:
            %   Normal click + drag: zoom Y (shared with raster) and Hist X
            %   Double-click: reset all axes to backup limits
            arguments
                obj RasterGUI
            end
            selType = obj.figure_Main.SelectionType;
            ax = obj.axes_Hist;

            if strcmp(selType, 'normal')
                dataRect = obj.rbboxToDataRect(ax);
                if dataRect(3) == 0 || dataRect(4) == 0
                    return;
                end
                % Zoom Y on raster (Hist follows via linkprop) and Hist X
                obj.axes_Raster.YLim = [dataRect(2), dataRect(2) + dataRect(4)];
                ax.XLim = [dataRect(1), dataRect(1) + dataRect(3)];

            elseif strcmp(selType, 'open')
                obj.resetZoom();
            end
        end

        function resetZoom(obj)
            % Reset all axes to their post-plot backup limits.
            arguments
                obj RasterGUI
            end
            if ~isempty(obj.BackupXLim)
                obj.axes_Raster.XLim = obj.BackupXLim;
            end
            obj.axes_Raster.YLim = obj.RasterFullYLim;
            if ~isempty(obj.BackupPSTHYLim)
                obj.axes_PSTH.YLim = obj.BackupPSTHYLim;
            end
            if ~isempty(obj.BackupHistXLim)
                obj.axes_Hist.XLim = obj.BackupHistXLim;
            end
        end

        function [infoStr, displayIdx] = getTrialInfoString(obj, dataX, dataY)
            % Build a formatted info string for the trial nearest to the
            % given data coordinates. Returns the string and the display
            % index (1-based position in the sorted trial order).
            arguments
                obj RasterGUI
                dataX (1, 1) double
                dataY (1, 1) double
            end
            numTrials = length(obj.TrialOrder);
            infoStr = '';
            displayIdx = [];
            if numTrials == 0
                return;
            end

            % Find the nearest trial by Y position (trials are at integer
            % Y values 1..numTrials)
            [~, displayIdx] = min(abs(dataY - (1:numTrials)));
            trialIdx = obj.TrialOrder(displayIdx);
            trial = obj.TriggerData(trialIdx);

            % Build label string
            if trial.label == 0
                labelStr = '(unlabeled)';
            elseif trial.label > 1000
                labelStr = num2str(trial.label - 1000);
            else
                labelStr = char(trial.label);
            end

            % Build info string
            spc = '  |  ';
            infoStr = [ ...
                'Trial: ', num2str(displayIdx), ...
                spc, 'File: ', num2str(trial.fileNum), ...
                spc, 'Label: ', labelStr, ...
                spc, 'Time: ', num2str(dataX, '%.4f'), ' s'];
        end

        function showTrialInfo(obj, clickX, clickY)
            % Display information about the clicked trial in the status bar.
            arguments
                obj RasterGUI
                clickX (1, 1) double
                clickY (1, 1) double
            end
            infoStr = obj.getTrialInfoString(clickX, clickY);
            if ~isempty(infoStr)
                obj.statusBar.Status = infoStr;
            end
        end

        %% Crosshair guides (shift+mouseover)

        function createGuides(obj)
            % Create the crosshair guide lines and text labels. Called
            % lazily on first shift-hover. All objects start invisible.
            arguments
                obj RasterGUI
            end
            guideColor = [0.4, 0.4, 0.4];
            guideStyle = '--';
            guideWidth = 0.5;
            commonProps = {'HitTest', 'off', 'PickableParts', 'none', ...
                'HandleVisibility', 'off', 'Visible', 'off'};

            % Vertical guide lines (raster + PSTH)
            hold(obj.axes_Raster, 'on');
            obj.GuideVertRaster = plot(obj.axes_Raster, [NaN, NaN], [NaN, NaN], ...
                guideStyle, 'Color', guideColor, 'LineWidth', guideWidth, ...
                commonProps{:});
            hold(obj.axes_Raster, 'off');

            hold(obj.axes_PSTH, 'on');
            obj.GuideVertPSTH = plot(obj.axes_PSTH, [NaN, NaN], [NaN, NaN], ...
                guideStyle, 'Color', guideColor, 'LineWidth', guideWidth, ...
                commonProps{:});
            hold(obj.axes_PSTH, 'off');

            % Horizontal guide lines (raster + histogram)
            hold(obj.axes_Raster, 'on');
            obj.GuideHorizRaster = plot(obj.axes_Raster, [NaN, NaN], [NaN, NaN], ...
                guideStyle, 'Color', guideColor, 'LineWidth', guideWidth, ...
                commonProps{:});
            hold(obj.axes_Raster, 'off');

            hold(obj.axes_Hist, 'on');
            obj.GuideHorizHist = plot(obj.axes_Hist, [NaN, NaN], [NaN, NaN], ...
                guideStyle, 'Color', guideColor, 'LineWidth', guideWidth, ...
                commonProps{:});
            hold(obj.axes_Hist, 'off');

            % Trial label on right edge of raster
            hold(obj.axes_Raster, 'on');
            obj.GuideTrialLabel = text(obj.axes_Raster, NaN, NaN, '', ...
                'HorizontalAlignment', 'right', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'Color', guideColor, ...
                'BackgroundColor', [1, 1, 1, 0.7], ...
                'Margin', 1, ...
                commonProps{:});
            hold(obj.axes_Raster, 'off');

            % Time label at top of PSTH
            hold(obj.axes_PSTH, 'on');
            obj.GuideTimeLabel = text(obj.axes_PSTH, NaN, NaN, '', ...
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'top', ...
                'FontSize', 8, 'Color', guideColor, ...
                'BackgroundColor', [1, 1, 1, 0.7], ...
                'Margin', 1, ...
                commonProps{:});
            hold(obj.axes_PSTH, 'off');
        end

        function updateGuidePositions(obj, dataX, dataY)
            % Move all guide lines and labels to the given data position.
            % dataY should already be snapped to the nearest trial index.
            arguments
                obj RasterGUI
                dataX (1, 1) double
                dataY (1, 1) double
            end
            % Vertical lines span full Y extent of each axis
            rasterYLim = obj.axes_Raster.YLim;
            psthYLim = obj.axes_PSTH.YLim;
            obj.GuideVertRaster.XData = [dataX, dataX];
            obj.GuideVertRaster.YData = rasterYLim;
            obj.GuideVertPSTH.XData = [dataX, dataX];
            obj.GuideVertPSTH.YData = psthYLim;

            % Horizontal lines span full X extent of each axis
            rasterXLim = obj.axes_Raster.XLim;
            histXLim = obj.axes_Hist.XLim;
            obj.GuideHorizRaster.XData = rasterXLim;
            obj.GuideHorizRaster.YData = [dataY, dataY];
            obj.GuideHorizHist.XData = histXLim;
            obj.GuideHorizHist.YData = [dataY, dataY];

            % Trial label near right edge of raster (inset slightly)
            numTrials = length(obj.TrialOrder);
            trialNum = max(1, min(numTrials, round(dataY)));
            xInset = diff(rasterXLim) * 0.01;
            obj.GuideTrialLabel.Position = [rasterXLim(2) - xInset, dataY, 0];
            obj.GuideTrialLabel.String = ['Trial ', num2str(trialNum)];

            % Time label near top of PSTH (inset slightly)
            yInset = diff(psthYLim) * 0.03;
            obj.GuideTimeLabel.Position = [dataX, psthYLim(2) - yInset, 0];
            obj.GuideTimeLabel.String = [num2str(dataX, '%.4f'), ' s'];
        end

        function showGuides(obj)
            % Make all crosshair guide objects visible.
            arguments
                obj RasterGUI
            end
            obj.GuideVertRaster.Visible = 'on';
            obj.GuideVertPSTH.Visible = 'on';
            obj.GuideHorizRaster.Visible = 'on';
            obj.GuideHorizHist.Visible = 'on';
            obj.GuideTrialLabel.Visible = 'on';
            obj.GuideTimeLabel.Visible = 'on';
            obj.GuidesVisible = true;
        end

        function hideGuides(obj)
            % Hide all crosshair guide objects.
            arguments
                obj RasterGUI
            end
            if ~isempty(obj.GuideVertRaster) && isvalid(obj.GuideVertRaster)
                obj.GuideVertRaster.Visible = 'off';
                obj.GuideVertPSTH.Visible = 'off';
                obj.GuideHorizRaster.Visible = 'off';
                obj.GuideHorizHist.Visible = 'off';
                obj.GuideTrialLabel.Visible = 'off';
                obj.GuideTimeLabel.Visible = 'off';
            end
            obj.GuidesVisible = false;
        end

        function onMouseMotion(obj)
            % Handle mouse motion over the figure. When shift is held and
            % the mouse is over the raster axes, show crosshair guides
            % spanning all axes and update the status bar with trial info.
            arguments
                obj RasterGUI
            end
            % Check if shift is held
            modifier = get(obj.figure_Main, 'CurrentModifier');
            isShift = any(strcmp(modifier, 'shift'));

            if ~isShift
                % Shift not held — hide guides if they're showing
                if obj.GuidesVisible
                    obj.hideGuides();
                end
                return;
            end

            % Shift is held — check if mouse is over the raster axes
            if isempty(obj.TriggerData)
                return;
            end
            ax = obj.axes_Raster;
            cp = ax.CurrentPoint;
            dataX = cp(1, 1);
            dataY = cp(1, 2);
            xl = ax.XLim;
            yl = ax.YLim;

            if dataX < xl(1) || dataX > xl(2) || ...
               dataY < yl(1) || dataY > yl(2)
                % Mouse is outside raster axes
                if obj.GuidesVisible
                    obj.hideGuides();
                end
                return;
            end

            % Snap Y to nearest trial
            numTrials = length(obj.TrialOrder);
            snappedY = max(1, min(numTrials, round(dataY)));

            % Create guides lazily on first use
            if isempty(obj.GuideVertRaster) || ~isvalid(obj.GuideVertRaster)
                obj.createGuides();
            end

            % Update positions and show
            obj.updateGuidePositions(dataX, snappedY);
            if ~obj.GuidesVisible
                obj.showGuides();
            end

            % Update status bar with trial info
            infoStr = obj.getTrialInfoString(dataX, snappedY);
            if ~isempty(infoStr)
                obj.statusBar.Status = infoStr;
            end
        end

        function onScrollWheel(obj, evt)
            % Handle mouse scroll over the raster axes. Plain scroll
            % zooms Y centered on the mouse; shift+scroll pans Y.
            % X limits are never changed. Zoom/pan is clamped so the
            % view cannot exceed the full data range.
            arguments
                obj RasterGUI
                evt matlab.ui.eventdata.ScrollWheelData
            end

            % Only act when the mouse is over the raster axes
            ax = obj.axes_Raster;
            cp = ax.CurrentPoint;
            yMouse = cp(1, 2);
            xMouse = cp(1, 1);
            xlim = ax.XLim;
            ylim = ax.YLim;
            % Check if the mouse is within the raster axes data range
            if xMouse < xlim(1) || xMouse > xlim(2) || ...
               yMouse < ylim(1) || yMouse > ylim(2)
                return;
            end

            fullYLim = obj.RasterFullYLim;
            fullSpan = fullYLim(2) - fullYLim(1);
            scrollDir = evt.VerticalScrollCount;  % +1 = scroll down, -1 = scroll up

            modifier = get(obj.figure_Main, 'CurrentModifier');
            isShift = any(strcmp(modifier, 'shift'));

            if isShift
                % --- Shift+scroll: pan in Y ---
                % Pan by 10% of the current view span per scroll click
                panAmount = 0.1 * diff(ylim) * scrollDir;
                newYLim = ylim + panAmount;
                % Clamp to full data range
                if newYLim(1) < fullYLim(1)
                    newYLim = newYLim - (newYLim(1) - fullYLim(1));
                end
                if newYLim(2) > fullYLim(2)
                    newYLim = newYLim - (newYLim(2) - fullYLim(2));
                end
            else
                % --- Plain scroll: zoom in Y centered on mouse ---
                % Scroll down = zoom out, scroll up = zoom in
                zoomFactor = 1.15 ^ scrollDir;
                newSpan = diff(ylim) * zoomFactor;
                % Clamp: don't zoom out past the full data range
                newSpan = min(newSpan, fullSpan);
                % Clamp: don't zoom in past 1 trial height
                newSpan = max(newSpan, 1);
                % Fraction of the view below the mouse stays constant
                frac = (yMouse - ylim(1)) / diff(ylim);
                newYLim = [yMouse - frac * newSpan, yMouse - frac * newSpan + newSpan];
                % Clamp to full data range (shift if needed)
                if newYLim(1) < fullYLim(1)
                    newYLim = [fullYLim(1), fullYLim(1) + newSpan];
                end
                if newYLim(2) > fullYLim(2)
                    newYLim = [fullYLim(2) - newSpan, fullYLim(2)];
                end
            end

            ax.YLim = newYLim;
            % Histogram follows via linkaxes
        end
    end

    %% Core algorithms (ported from egm_Sorted_rasters)
    methods (Access = private)
        function [ons, offs, eventInfo, fileList] = getEventStructure(obj, eventSourceIdx, eventTypeStr, params)
            % Extract triggers or events from the dbase across files.
            arguments
                obj RasterGUI
                eventSourceIdx (1, 1) double {mustBeInteger, mustBeNonnegative}
                eventTypeStr (1, :) char {mustBeMember(eventTypeStr, {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses', 'Syllables', 'Markers', 'Motifs', 'Bouts', 'Continuous function'})}
                params (1, 1) struct
            end
            %
            % Arguments:
            %   eventSourceIdx - index into EventTimes (0 = sound/segments)
            %   eventTypeStr - one of: 'Events', 'Bursts', 'Burst events',
            %       'Single events', 'Pauses', 'Syllables', 'Markers',
            %       'Motifs', 'Bouts', 'Continuous function'
            %   params - parameter struct with fields like burstFrequency,
            %       motifSequences, boutInterval, etc.
            %
            % Returns:
            %   ons - cell array of onset times (in samples) per file
            %   offs - cell array of offset times (in samples) per file
            %   eventInfo - struct with .label (cell of label arrays) and
            %       .filenum (file numbers)
            %   fileList - list of file indices processed

            dbase = obj.eg.dbase;
            fs = dbase.Fs;
            fileList = obj.FileRange;

            % Filter file list based on file selection popup
            % (For now, use all files in range — file search filtering
            % can be added later when the file list widget is ported)

            numFiles = length(fileList);
            ons = cell(1, numFiles);
            offs = cell(1, numFiles);
            eventInfo.label = cell(1, numFiles);
            eventInfo.filenum = zeros(1, numFiles);

            for fileListIdx = 1:numFiles
                filenum = fileList(fileListIdx);

                % For spike event types, build the selection mask and
                % extract part times once before the type-specific logic.
                % params.selectionMode controls which events are included:
                % 'All', 'Selected only', or 'Unselected only'.
                if ismember(eventTypeStr, {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses'})
                    selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                    for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                        selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                    end
                    switch params.selectionMode
                        case 'All'
                            selectedIndices = (1:length(selectedMask))';
                        case 'Selected only'
                            selectedIndices = find(selectedMask);
                        case 'Unselected only'
                            selectedIndices = find(~selectedMask);
                    end
                    allPartTimes = dbase.EventTimes{eventSourceIdx}{1, filenum}(selectedIndices);
                    for partIdx = 2:size(dbase.EventTimes{eventSourceIdx}, 1)
                        allPartTimes = [allPartTimes, dbase.EventTimes{eventSourceIdx}{partIdx, filenum}(selectedIndices)]; %#ok<AGROW>
                    end
                end

                switch eventTypeStr
                    case 'Events'
                        % Simple events: onset = min across parts, offset = max
                        ons{fileListIdx} = min(allPartTimes, [], 2);
                        offs{fileListIdx} = max(allPartTimes, [], 2);
                        eventInfo.label{fileListIdx} = zeros(size(allPartTimes, 1), 1);

                    case 'Bursts'
                        % Find bursts based on inter-event frequency
                        eventSamples = min(allPartTimes, [], 2);
                        burstOnsets = find(fs ./ (eventSamples(1:end-1) - [-inf; eventSamples(1:end-2)]) <= params.burstFrequency & ...
                            fs ./ (eventSamples(2:end) - eventSamples(1:end-1)) > (params.burstFrequency + eps));
                        burstOffsets = find(fs ./ (eventSamples(2:end) - eventSamples(1:end-1)) > params.burstFrequency & ...
                            fs ./ ([eventSamples(3:end); inf] - eventSamples(2:end)) <= params.burstFrequency) + 1;
                        validBursts = find(burstOffsets - burstOnsets >= params.burstMinSpikes - 1);
                        ons{fileListIdx} = eventSamples(burstOnsets(validBursts));
                        offs{fileListIdx} = eventSamples(burstOffsets(validBursts));
                        eventInfo.label{fileListIdx} = 1000 + burstOffsets(validBursts) - burstOnsets(validBursts) + 1;

                    case {'Burst events', 'Single events'}
                        % Categorize individual spikes by burst membership
                        evOn = min(allPartTimes, [], 2);
                        evOff = max(allPartTimes, [], 2);
                        burstOnsets = find(fs ./ (evOn(1:end-1) - [-inf; evOn(1:end-2)]) <= params.burstFrequency & ...
                            fs ./ (evOn(2:end) - evOn(1:end-1)) > (params.burstFrequency + eps));
                        burstOffsets = find(fs ./ (evOn(2:end) - evOn(1:end-1)) > params.burstFrequency & ...
                            fs ./ ([evOn(3:end); inf] - evOn(2:end)) <= params.burstFrequency) + 1;
                        validBursts = find(burstOffsets - burstOnsets >= params.burstMinSpikes - 1);
                        burstSpikeIndices = [];
                        for burstNum = 1:length(validBursts)
                            burstSpikeIndices = [burstSpikeIndices, burstOnsets(validBursts(burstNum)):burstOffsets(validBursts(burstNum))]; %#ok<AGROW>
                        end
                        if strcmp(eventTypeStr, 'Burst events')
                            ons{fileListIdx} = evOn(burstSpikeIndices);
                            offs{fileListIdx} = evOff(burstSpikeIndices);
                        else % 'Single events'
                            nonBurstIndices = setdiff(1:length(evOn), burstSpikeIndices);
                            ons{fileListIdx} = evOn(nonBurstIndices);
                            offs{fileListIdx} = evOff(nonBurstIndices);
                        end
                        eventInfo.label{fileListIdx} = zeros(length(ons{fileListIdx}), 1);

                    case 'Pauses'
                        % Find gaps between events
                        gapOnsets = [min(allPartTimes, [], 2); obj.eg.getFileLength(filenum) + fs * params.pauseMinDuration];
                        gapOffsets = [-fs * params.pauseMinDuration; max(allPartTimes, [], 2)];
                        pauseIndices = find(gapOnsets - gapOffsets > fs * params.pauseMinDuration);
                        ons{fileListIdx} = gapOffsets(pauseIndices);
                        offs{fileListIdx} = gapOnsets(pauseIndices);
                        eventInfo.label{fileListIdx} = zeros(length(pauseIndices), 1);

                    case {'Syllables', 'Markers'}
                        switch eventTypeStr
                            case 'Syllables'
                                times = dbase.SegmentTimes{filenum};
                                selection = dbase.SegmentIsSelected{filenum};
                                titles = dbase.SegmentTitles{filenum};
                            case 'Markers'
                                times = dbase.MarkerTimes{filenum};
                                selection = dbase.MarkerIsSelected{filenum};
                                titles = dbase.MarkerTitles{filenum};
                        end
                        if ~isempty(times)
                            % Apply selection mode filter
                            switch params.selectionMode
                                case 'All'
                                    selectedIndices = (1:size(times, 1))';
                                case 'Selected only'
                                    selectedIndices = find(selection == 1);
                                case 'Unselected only'
                                    selectedIndices = find(selection ~= 1);
                            end
                            ons{fileListIdx} = times(selectedIndices, 1);
                            offs{fileListIdx} = times(selectedIndices, 2);
                            labels = zeros(size(ons{fileListIdx}));
                            for labelIdx = 1:length(labels)
                                if ~isempty(titles{selectedIndices(labelIdx)})
                                    labels(labelIdx) = double(titles{selectedIndices(labelIdx)});
                                end
                            end
                            eventInfo.label{fileListIdx} = labels;

                            % Apply filter based on mode
                            keepMask = RasterGUI.getLabelFilterMask(labels, params.filterMode, params.filterList);
                            ons{fileListIdx} = ons{fileListIdx}(keepMask);
                            offs{fileListIdx} = offs{fileListIdx}(keepMask);
                            eventInfo.label{fileListIdx} = eventInfo.label{fileListIdx}(keepMask);
                        end

                    case 'Motifs'
                        if ~isempty(dbase.SegmentTimes{filenum})
                            % Apply selection mode filter
                            switch params.selectionMode
                                case 'All'
                                    selectedIndices = (1:size(dbase.SegmentTimes{filenum}, 1))';
                                case 'Selected only'
                                    selectedIndices = find(dbase.SegmentIsSelected{filenum} == 1);
                                case 'Unselected only'
                                    selectedIndices = find(dbase.SegmentIsSelected{filenum} ~= 1);
                            end
                            syllOnsets = dbase.SegmentTimes{filenum}(selectedIndices, 1);
                            syllOffsets = dbase.SegmentTimes{filenum}(selectedIndices, 2);
                            syllTitles = dbase.SegmentTitles{filenum}(selectedIndices);
                            titleStr = '';
                            for syllIdx = 1:length(syllTitles)
                                if isempty(syllTitles{syllIdx}) || strcmp(syllTitles{syllIdx}, '')
                                    titleStr = [titleStr, char(1)]; %#ok<AGROW>
                                else
                                    titleStr = [titleStr, syllTitles{syllIdx}]; %#ok<AGROW>
                                end
                            end
                            ons{fileListIdx} = [];
                            offs{fileListIdx} = [];
                            eventInfo.label{fileListIdx} = [];
                            for motifIdx = 1:length(params.motifSequences)
                                [matchStarts, matchEnds] = regexp(titleStr, params.motifSequences{motifIdx}, 'start', 'end');
                                % Validate motif continuity
                                for matchIdx = length(matchStarts):-1:1
                                    if max(syllOnsets(matchStarts(matchIdx)+1:matchEnds(matchIdx)) - syllOffsets(matchStarts(matchIdx):matchEnds(matchIdx)-1)) > fs * params.motifInterval
                                        matchStarts(matchIdx) = [];
                                        matchEnds(matchIdx) = [];
                                    end
                                end
                                ons{fileListIdx} = [ons{fileListIdx}; syllOnsets(matchStarts)];
                                offs{fileListIdx} = [offs{fileListIdx}; syllOffsets(matchEnds)];
                                eventInfo.label{fileListIdx} = [eventInfo.label{fileListIdx}; motifIdx * ones(length(matchStarts), 1)];
                            end
                            eventInfo.label{fileListIdx} = 1000 + eventInfo.label{fileListIdx};
                        end

                    case 'Bouts'
                        if ~isempty(dbase.SegmentTimes{filenum})
                            % Apply selection mode filter
                            switch params.selectionMode
                                case 'All'
                                    selectedIndices = (1:size(dbase.SegmentTimes{filenum}, 1))';
                                case 'Selected only'
                                    selectedIndices = find(dbase.SegmentIsSelected{filenum} == 1);
                                case 'Unselected only'
                                    selectedIndices = find(dbase.SegmentIsSelected{filenum} ~= 1);
                            end

                            % Apply filter to select which syllables form bouts
                            labels = zeros(1, length(selectedIndices));
                            for labelIdx = 1:length(labels)
                                if ~isempty(dbase.SegmentTitles{filenum}{selectedIndices(labelIdx)})
                                    labels(labelIdx) = double(dbase.SegmentTitles{filenum}{selectedIndices(labelIdx)});
                                end
                            end
                            keepMask = RasterGUI.getLabelFilterMask(labels, params.filterMode, params.filterList);
                            selectedIndices = selectedIndices(keepMask);

                            % Find bouts: groups of syllables separated by gaps
                            syllOnsets = [dbase.SegmentTimes{filenum}(selectedIndices, 1); inf];
                            syllOffsets = [-inf; dbase.SegmentTimes{filenum}(selectedIndices, 2)];
                            gapIndices = find(syllOnsets - syllOffsets > fs * params.boutInterval);
                            boutStarts = gapIndices(1:end-1);
                            boutEnds = gapIndices(2:end) - 1;
                            durationOK = find(syllOffsets(boutEnds + 1) - syllOnsets(boutStarts) > fs * params.boutMinDuration);
                            syllCountOK = find(boutEnds - boutStarts >= params.boutMinSyllables - 1);
                            validBouts = intersect(durationOK, syllCountOK);
                            ons{fileListIdx} = syllOnsets(boutStarts(validBouts));
                            offs{fileListIdx} = syllOffsets(boutEnds(validBouts) + 1);
                            eventInfo.label{fileListIdx} = 1000 + boutEnds(validBouts) - boutStarts(validBouts) + 1;
                        end

                    case 'Continuous function'
                        ons{fileListIdx} = [];
                        offs{fileListIdx} = [];
                        eventInfo.label{fileListIdx} = [];
                end

                eventInfo.filenum(fileListIdx) = filenum;
                if size(ons{fileListIdx}, 2) == 0
                    ons{fileListIdx} = [];
                    offs{fileListIdx} = [];
                    eventInfo.label{fileListIdx} = [];
                end
            end
        end

    end

    %% Sort options and filtering
    methods (Access = private, Static)
        function keepMask = getLabelFilterMask(labels, filterMode, filterList)
            % Return a logical mask indicating which labels to keep based
            % on the filter mode and list.
            %
            % Arguments:
            %   labels - numeric array of label values (double of char)
            %   filterMode - 'All', 'Include', or 'Exclude'
            %   filterList - char array of label characters
            arguments
                labels double
                filterMode (1, :) char {mustBeMember(filterMode, {'All', 'Include', 'Exclude'})}
                filterList (1, :) char = ''
            end

            switch filterMode
                case 'All'
                    keepMask = true(size(labels));
                case 'Include'
                    if isempty(filterList)
                        % Empty include list = include all (same as 'All')
                        keepMask = true(size(labels));
                    else
                        filterCodes = double(filterList);
                        keepMask = ismember(labels, filterCodes);
                    end
                case 'Exclude'
                    filterCodes = double(filterList);
                    keepMask = ~ismember(labels, filterCodes);
            end
        end

        function options = getSortOptions()
            options = { ...
                '(None)', ...
                'Absolute time', ...
                'Trigger duration', ...
                'Prev trig onset', ...
                'Prev trig offset', ...
                'Prev trig interval', ...
                'Next trig onset', ...
                'Next trig offset', ...
                'Next trig interval', ...
                'Trigger label', ...
                'Preceding event onset', ...
                'Preceding event offset', ...
                'Following event onset', ...
                'Following event offset', ...
                'First event onset', ...
                'First event offset', ...
                'Last event onset', ...
                'Last event offset', ...
                'Number of events', ...
                'Is in event'};
        end
    end

    %% Destructor
    methods
        function delete(obj)
            arguments
                obj RasterGUI
            end
            if ~isempty(obj.figure_Main) && isvalid(obj.figure_Main)
                delete(obj.figure_Main);
            end
        end
    end
end
