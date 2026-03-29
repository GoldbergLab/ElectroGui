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
    properties (SetAccess = private)
        eg electro_gui  % Reference to parent electro_gui instance
    end

    %% Properties - GUI widgets
    properties (Access = private)
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
    properties (Access = private)
        % Data
        triggerInfo struct = struct()       % Sorted trigger info (used for plotting)
        preSortTriggerInfo struct = struct() % Cached alignment output before sorting

        % Event series: array of structs, one per event series
        % Each has: name, sourceIdx, type, filterMode, filterList,
        %           burstFrequency, burstMinSpikes, selectionMode,
        %           color, showPSTH, psthStyle, triggerInfo
        eventSeries struct = struct( ...
            'name', {}, ...
            'sourceIdx', {}, ...    % Index into popup (1=Sound, 2+=event detectors)
            'type', {}, ...         % e.g., 'Events', 'Syllables'
            'filterMode', {}, ...   % 'All', 'Include', 'Exclude'
            'filterList', {}, ...   % Label filter string
            'burstFrequency', {}, ...  % Hz threshold for burst detection (per-series)
            'burstMinSpikes', {}, ...  % Min spikes to form a valid burst (per-series)
            'selectionMode', {}, ...   % 'All', 'Selected', 'Unselected'
            'color', {}, ...        % 1x3 RGB
            'showPSTH', {}, ...     % true/false
            'psthStyle', {}, ...    % 'Line', 'Histogram', or 'Both'
            'triggerInfo', {} ...   % Aligned event data for this series
        )

        % File range
        FileRange double = []
        FileNames cell = {}

        % Sort order
        Order double = []
        SkippingSort logical = false

        % Plot configuration
        PlotHandles cell = cell(1, 30)
        PlotInclude logical = logical([0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0])
        PlotContinuous double = [1 1 -1 1 1 -1 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 -1 -1 1 1 -1 1 1 -1 -1 -1 -1]
        PlotColor double = [ ...
            1 0 0; 1 0 0; 1 0.5 0.125; 1 0 0; 1 0 0; 1 0.5 0.125; ...
            1 0 0; 1 0 0; 1 0.5 0.125; ...
            0 0 0; 0 0 0; 230/255 230/255 128/255; ...
            0 0 0; 128/255 128/255 128/255; 1 0 0; ...
            0 0 0; 128/255 128/255 128/255; 1 1 1; ...
            0 1 0; 0 1 0; 1 1 1; ...
            0.75 0 0.75; 0.75 0 0.75; 1 0.85 0.85; ...
            0 0 1; 0 0 1; 0.8 0.8 1; 0 0 1; 0 0 1; 0.8 0.8 1]
        PlotLineWidth double = ones(1, 30)
        PlotAlpha double = ones(1, 30)
        PlotAutoColors double = []
        PlotXLim double = [-0.15, 0.15]
        PlotTickSize double = [1, 0.25, 1, 0.5]
        PlotOverlap double = 50
        PlotInPerSec double = 0.04

        % PSTH configuration
        PSTHBinSize double = 0.001
        PSTHSmoothingWindow double = 1
        PSTHYLim double = repmat([-inf, inf], 5, 1)

        % Histogram configuration
        HistBinSize double = [1, 1]
        HistSmoothingWindow double = 1
        HistYLim double = repmat([-inf, inf], 5, 1)
        HistShow double = [1, 1]

        % Full Y range of the raster (placeholder until plotRaster sets
        % it to [0.5, numTrials+0.5]; used to clamp scroll-zoom/pan)
        RasterFullYLim double = [0.5, 1.5]

        % Background color
        BackgroundColor double = [1, 1, 1]

        % Parameters
        P struct = struct()

        % Warp points
        WarpPoints cell = {}

        % Preset system
        preset_prefix char = 'egsr_preset_'

        % Axis positions (for show/hide PSTH/hist)
        AxisPosRaster double = []
        AxisPosPSTH double = []
        AxisPosHist double = []
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
            % This is the main entry point that runs the full pipeline:
            % extract triggers -> align events -> filter -> sort -> warp -> plot
            arguments
                obj RasterGUI
            end

            if ~electro_gui.isDataLoaded(obj.eg.dbase)
                warndlg('No data loaded in electro_gui.');
                return;
            end

            obj.disableAllControls();
            obj.push_GenerateRaster.ForegroundColor = 'r';
            obj.statusBar.Status = 'Generating raster...';
            obj.statusBar.Progress = 0;
            drawnow;

            % Read inline options into P struct
            obj.syncOptionsFromGUI();

            try
                if isempty(obj.eventSeries)
                    obj.statusBar.Status = 'No event series defined';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('Please add at least one event series.', 'No event series');
                    return;
                end

                % --- Step 1: Get trigger times ---
                obj.statusBar.Status = 'Extracting triggers...';
                obj.statusBar.Progress = 0.1;
                drawnow;
                trigSourceIdx = obj.popup_TriggerSource.Value - 1;  % 0 = Sound
                trigTypeStrs = obj.popup_TriggerType.String;
                trigTypeStr = trigTypeStrs{obj.popup_TriggerType.Value};
                [trig.on, trig.off, trig.info, ~] = obj.getEventStructure( ...
                    trigSourceIdx, trigTypeStr, obj.P.trig);

                % --- Step 2: Extract and align events for each series ---
                numSeries = length(obj.eventSeries);
                for seriesIdx = 1:numSeries
                    s = obj.eventSeries(seriesIdx);
                    obj.statusBar.Status = sprintf('Extracting events for "%s" (%d/%d)...', s.name, seriesIdx, numSeries);
                    obj.statusBar.Progress = 0.1 + 0.35 * (seriesIdx - 1) / numSeries;
                    drawnow;

                    % Build a P struct for this series, overriding per-series params
                    seriesP = obj.P.trig;
                    seriesP.filterMode = s.filterMode;
                    seriesP.filterList = s.filterList;
                    seriesP.burstFrequency = s.burstFrequency;
                    seriesP.burstMinSpikes = s.burstMinSpikes;
                    seriesP.selectionMode = s.selectionMode;

                    % Extract events
                    eventSourceIdx = s.sourceIdx - 1;  % 0 = Sound
                    [event.on, event.off, event.info, ~] = obj.getEventStructure( ...
                        eventSourceIdx, s.type, seriesP);

                    % Align events to triggers
                    seriesTI = obj.alignEventsToTriggers(trig, event);

                    % Store aligned data in the series
                    obj.eventSeries(seriesIdx).triggerInfo = seriesTI;
                end

                % Use the first series' triggerInfo as the primary
                % (for trigger metadata like absTime, labels, sort values)
                ti = obj.eventSeries(1).triggerInfo;

                if isempty(ti) || ~isfield(ti, 'absTime') || isempty(ti.absTime)
                    obj.statusBar.Status = 'No triggers found';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('No triggers found!', 'Error');
                    return;
                end

                % Cache the pre-sort alignment data
                obj.preSortTriggerInfo = ti;

                % --- Step 3: Sort triggers ---
                obj.statusBar.Status = sprintf('Sorting %d triggers...', length(ti.absTime));
                obj.statusBar.Progress = 0.55;
                drawnow;
                primarySortStrs = obj.popup_PrimarySort.String;
                primarySortType = primarySortStrs{obj.popup_PrimarySort.Value};
                descending = obj.radio_Descending.Value;
                groupLabels = obj.check_GroupLabels.Value;

                % Apply secondary sort first (so primary is dominant)
                secondarySortStrs = obj.popup_SecondarySort.String;
                secondarySortType = secondarySortStrs{obj.popup_SecondarySort.Value};
                if ~strcmp(secondarySortType, '(None)')
                    [ti, ord] = RasterGUI.sortTriggers(ti, secondarySortType, descending, ...
                        '', false);
                    % Apply same sort order to all series
                    for seriesIdx = 1:numSeries
                        obj.eventSeries(seriesIdx).triggerInfo = ...
                            RasterGUI.applyOrder(obj.eventSeries(seriesIdx).triggerInfo, ord);
                    end
                end
                if ~strcmp(primarySortType, '(None)')
                    [ti, ord] = RasterGUI.sortTriggers(ti, primarySortType, descending, ...
                        '', groupLabels);
                    % Apply same sort order to all series
                    for seriesIdx = 1:numSeries
                        obj.eventSeries(seriesIdx).triggerInfo = ...
                            RasterGUI.applyOrder(obj.eventSeries(seriesIdx).triggerInfo, ord);
                    end
                end

                obj.triggerInfo = ti;

                % --- Step 5: Plot ---
                obj.statusBar.Status = sprintf('Plotting %d trials...', length(ti.absTime));
                obj.statusBar.Progress = 0.75;
                drawnow;
                obj.plotRaster();
                obj.statusBar.Progress = 0.85;
                drawnow;
                obj.plotPSTH();
                obj.statusBar.Progress = 0.95;
                drawnow;
                obj.plotHist();

            catch ME
                obj.statusBar.Status = sprintf('Error: %s', ME.message);
                obj.statusBar.Progress = [];
                obj.updateControlStates();
                obj.push_GenerateRaster.ForegroundColor = 'k';
                warndlg(sprintf('Error generating raster: %s', ME.message), 'Error');
                rethrow(ME);
            end

            obj.statusBar.Status = sprintf('Done — %d trials', length(obj.triggerInfo.absTime));
            obj.statusBar.Progress = 1;
            obj.updateControlStates();
            obj.push_GenerateRaster.ForegroundColor = 'k';
        end
    end

    %% GUI construction
    methods (Access = private)
        function initializeParameters(obj)
            % Initialize the default parameter structure
            arguments
                obj RasterGUI
            end
            obj.P.trig.filterMode = 'All';   % 'All', 'Include', or 'Exclude'
            obj.P.trig.filterList = '';
            obj.P.trig.motifSequences = {};
            obj.P.trig.motifInterval = 0.2;
            obj.P.trig.boutInterval = 0.5;
            obj.P.trig.boutMinDuration = 0.2;
            obj.P.trig.boutMinSyllables = 2;
            obj.P.trig.burstFrequency = 100;
            obj.P.trig.burstMinSpikes = 2;
            obj.P.trig.selectionMode = 'Selected only';
            obj.P.trig.pauseMinDuration = 0.05;
            obj.P.trig.contSmooth = 1;
            obj.P.trig.contSubsample = 0.001;
            obj.P.preStartRef = 0.4;
            obj.P.postStopRef = 0.4;
            obj.P.filter = repmat([-inf, inf], 15, 1);

            obj.PlotAlpha(27) = 0.5;
            obj.PlotAlpha(30) = 0.5;

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
            numRows = 15;
            % rowY positions computed after tab group creation (see below)
            % Placeholder — will be set once we know the tab interior height

            tabMargin = m;
            fullW = 270;                   % Approximate usable width inside tab (px)
            tabFullW = fullW;
            halfW = fullW * 0.48;          % Half-width button (px)
            halfGap = fullW * 0.04;        % Gap between half-width buttons (px)
            thirdW = 80;                   % Third-width button (px)
            thirdGap = 5;                  % Gap between third-width buttons (px)
            editW = 70;                    % Short numeric edit box (px)
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
            winLabelW = 50;
            winPopupX = tabMargin + winLabelW + labelPopupGap;
            winPopupW = fullW - winPopupX;

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
            obj.check_TrigAutoUpdate.Units = 'pixels';
            obj.check_TrigAutoUpdate.Position = [tabMargin, rowY(8), halfW, rowH];
            obj.push_TrigUpdate.Units = 'pixels';
            obj.push_TrigUpdate.Position = [tabMargin + halfW + halfGap, rowY(8), halfW, rowH];
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
            % Detail panel: positioned below the list, spans 5 rows
            detailStartRow = 4;  % After 3-row list
            detailNumRows = 5;
            panelPad = 3;  % Internal padding within the panel
            panelH = detailNumRows * rowSpacing + 2 * panelPad;
            panelY = rowY(detailStartRow) - (detailNumRows - 1) * rowSpacing - panelPad;
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
            % Window controls (continued in Events tab)
            winRefLabelW = 30;
            winRefPopupX = tabMargin + winRefLabelW + 2;
            winRefPopupW = 110;
            winOpX = winRefPopupX + winRefPopupW + 2;
            winOpW = 16;
            winEditX = winOpX + winOpW + 2;
            winEditW = 40;
            winUnitX = winEditX + winEditW + 2;
            winUnitW = 12;
            sharedControlsStartRow = detailStartRow + 4;

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
            obj.check_PlotAutoUpdate.Units = 'pixels';
            obj.check_PlotAutoUpdate.Position = [tabMargin, rowY(5), halfW, rowH];
            obj.push_PlotUpdate.Units = 'pixels';
            obj.push_PlotUpdate.Position = [tabMargin + halfW + halfGap, rowY(5), halfW, rowH];
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
                'WindowScrollWheelFcn', @(~, evt) obj.onScrollWheel(evt));

            % --- Status bar ---
            obj.statusBar = StatusBar(obj.figure_Main);
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
                'Tag', 'axes_PSTH');
            obj.axes_Hist = axes(obj.panel_Axes, ...
                'Box', 'on', ...
                'Tag', 'axes_Hist');

            % Link axes: raster+PSTH share X, raster+histogram share Y
            linkaxes([obj.axes_Raster, obj.axes_PSTH], 'x');
            linkaxes([obj.axes_Raster, obj.axes_Hist], 'y');

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
                'String', num2str(obj.P.preStartRef), ...
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
                'String', num2str(obj.P.postStopRef), ...
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
                'String', num2str(obj.PlotXLim(1)), ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.xLimChanged());
            obj.text_XMax = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'X max (s):', ...
                'Tag', 'text_XMax', ...
                'HorizontalAlignment', 'right');
            obj.edit_XMax = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotXLim(2)), ...
                'Enable', 'off', ...
                'Callback', @(~,~) obj.xLimChanged());

            obj.text_TickHeight = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Tick height:', ...
                'Tag', 'text_TickHeight', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickHeight = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotTickSize(1)), ...
                'Callback', @(~,~) obj.plotSettingChanged());
            obj.text_BinSize = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Bin size (s):', ...
                'Tag', 'text_BinSize', ...
                'HorizontalAlignment', 'right');
            obj.edit_BinSize = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PSTHBinSize), ...
                'Callback', @(~,~) obj.plotSettingChanged());

            obj.text_TickLineWidth = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Line width:', ...
                'Tag', 'text_TickLineWidth', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickLineWidth = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotTickSize(3)), ...
                'Callback', @(~,~) obj.plotSettingChanged());
            obj.text_Overlap = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Overlap %:', ...
                'Tag', 'text_Overlap', ...
                'HorizontalAlignment', 'right');
            obj.edit_Overlap = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotOverlap), ...
                'Callback', @(~,~) obj.plotSettingChanged());
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
            % Render the raster plot from the current triggerInfo.
            arguments
                obj RasterGUI
            end

            numTrials = length(obj.triggerInfo.absTime);
            if numTrials == 0
                return;
            end

            ax = obj.axes_Raster;
            delete(ax.Children);
            hold(ax, 'on');

            % Trial y-positions (trial 1 at top)
            trialY = 1:numTrials;

            % Tick height: each trial spans 1 unit, ticks fill most of it
            tickHalfHeight = obj.PlotTickSize(1) / 2;
            ti = obj.triggerInfo;

            % --- Plot trigger boxes (vectorized as a single patch) ---
            obj.statusBar.Status = 'Plotting trigger boxes...';
            drawnow;
            trigColor = [1.0, 0.85, 0.85];  % Light red
            trigOn = ti.currTrigOnset(:);
            trigOff = ti.currTrigOffset(:);
            validTrig = isfinite(trigOn) & isfinite(trigOff);
            if any(validTrig)
                tOn = trigOn(validTrig);
                tOff = trigOff(validTrig);
                tY = trialY(validTrig)';
                % Build patch with matrix inputs: each column is one face
                % (4 vertices per face)
                patchX = [tOn, tOff, tOff, tOn]';   % 4 x nBoxes
                patchY = [tY - tickHalfHeight, tY - tickHalfHeight, ...
                          tY + tickHalfHeight, tY + tickHalfHeight]';  % 4 x nBoxes
                patch(ax, patchX, patchY, trigColor, ...
                    'EdgeColor', 'none', ...
                    'PickableParts', 'none', ...
                    'HitTest', 'off');
            end

            % --- Plot triggers from other trials (optional) ---
            % For each trial, find all other triggers whose onset/offset
            % falls within this trial's visible time window. Uses absolute
            % time to handle triggers across file boundaries.
            if obj.check_PlotOtherTrialTriggers.Value && numTrials > 1
                otherTrigColor = [0.85, 0.85, 1.0];  % Light blue
                % Absolute alignment time for each trial (in days)
                absT = ti.absTime(:);
                % Each trial's trigger onset/offset in seconds relative
                % to its own alignment point
                ownOn = ti.currTrigOnset(:);
                ownOff = ti.currTrigOffset(:);
                % Visible X range (seconds) — only plot what's on screen
                xLim = ax.XLim;

                % For each trial i, compute where every OTHER trial j's
                % trigger would appear: offset = (absT(j) - absT(i)) in
                % seconds, then add j's own trigger onset/offset.
                % Work in vectorized form: NxN matrices.
                dtSec = absT - absT';  % N x N, dtSec(j,i) = seconds from trial i to j
                otherOn = dtSec + ownOn;    % (j,i) = trial j's onset in trial i's coords
                otherOff = dtSec + ownOff;  % (j,i) = trial j's offset in trial i's coords

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
                    opX = [boxOn, boxOff, boxOff, boxOn]';
                    opY = [boxY - tickHalfHeight, boxY - tickHalfHeight, ...
                           boxY + tickHalfHeight, boxY + tickHalfHeight]';
                    patch(ax, opX, opY, otherTrigColor, ...
                        'EdgeColor', 'none', ...
                        'PickableParts', 'none', ...
                        'HitTest', 'off');
                end
            end

            % --- Plot event ticks for each series ---
            % Each event series is rendered as vertical tick marks in its
            % own color. All ticks for a series are concatenated into a
            % single NaN-separated vector for fast vectorized rendering.
            for seriesIdx = 1:length(obj.eventSeries)
                s = obj.eventSeries(seriesIdx);
                seriesTI = s.triggerInfo;

                % Skip series with no aligned data
                if isempty(seriesTI) || ~isfield(seriesTI, 'eventOnsets')
                    continue;
                end

                obj.statusBar.Status = sprintf('Plotting "%s" (%d/%d)...', ...
                    s.name, seriesIdx, length(obj.eventSeries));
                obj.statusBar.Progress = 0.8 + 0.15 * seriesIdx / length(obj.eventSeries);
                drawnow;

                % Count total events across all trials for pre-allocation
                totalEvents = sum(cellfun(@length, seriesTI.eventOnsets));
                if totalEvents == 0
                    continue;
                end

                % Build NaN-separated X/Y arrays for all event ticks.
                % Each tick is 3 entries: [x; x; NaN] and [yBottom; yTop; NaN]
                allX = NaN(3 * totalEvents, 1);
                allY = NaN(3 * totalEvents, 1);
                writeIdx = 0;
                for trialIdx = 1:numTrials
                    eventTimes = seriesTI.eventOnsets{trialIdx};
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
                plot(ax, allX, allY, 'Color', s.color, ...
                    'LineWidth', obj.PlotTickSize(3));
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
            if obj.check_AutoXLim.Value
                % Compute tight X limits from all plotted data
                allXData = [];
                for k = 1:length(ax.Children)
                    child = ax.Children(k);
                    if isprop(child, 'XData') && ~isempty(child.XData)
                        finiteX = child.XData(isfinite(child.XData));
                        allXData = [allXData; finiteX(:)]; %#ok<AGROW>
                    end
                end
                if ~isempty(allXData)
                    ax.XLim = [min(allXData), max(allXData)];
                end
            else
                ax.XLim = obj.PlotXLim;
            end
            ax.YLabel.String = 'Trial';
            ax.XLabel.String = '';
            ax.XTickLabel = {};
            ax.Box = 'on';
            title(ax, sprintf('%d trials', numTrials));
            hold(ax, 'off');

            % If auto, update PlotXLim and edit boxes from the auto result
            if obj.check_AutoXLim.Value
                drawnow;
                obj.PlotXLim = ax.XLim;
                obj.edit_XMin.String = num2str(obj.PlotXLim(1), '%.3f');
                obj.edit_XMax.String = num2str(obj.PlotXLim(2), '%.3f');
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
            ti = obj.triggerInfo;
            if isempty(ti) || ~isfield(ti, 'absTime')
                return;
            end
            numTrials = length(ti.absTime);
            if numTrials == 0
                return;
            end

            ax = obj.axes_PSTH;
            delete(ax.Children);
            hold(ax, 'on');

            % Find all series with showPSTH=true
            psthSeriesIndices = find([obj.eventSeries.showPSTH]);
            if isempty(psthSeriesIndices)
                % No series designated for PSTH — leave blank
                ax.YLabel.String = '';
                ax.XLabel.String = 'Time (s)';
                hold(ax, 'off');
                return;
            end

            % Shared bin edges for all series
            binSize = obj.PSTHBinSize;
            binEdges = obj.PlotXLim(1):binSize:obj.PlotXLim(2);
            if isempty(binEdges) || length(binEdges) < 2
                hold(ax, 'off');
                return;
            end
            binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

            % Determine Y axis label from selected units
            psthUnitStrs = obj.popup_PSTHUnits.String;
            psthUnit = psthUnitStrs{obj.popup_PSTHUnits.Value};
            switch psthUnit
                case 'Rate (Hz)',    yLabel = 'Firing rate (Hz)';
                case 'Count/trial',  yLabel = 'Count/trial';
                case 'Total count',  yLabel = 'Total count';
                otherwise,           yLabel = 'Rate (Hz)';
            end

            % Determine count mode (Onsets, Offsets, or Full duration)
            psthCountStrs = obj.popup_PSTHCount.String;
            psthCountMode = psthCountStrs{obj.popup_PSTHCount.Value};

            % Plot each PSTH series as a line in its color
            for k = 1:length(psthSeriesIndices)
                sIdx = psthSeriesIndices(k);
                s = obj.eventSeries(sIdx);
                seriesTI = s.triggerInfo;

                % Skip series with no aligned data
                if isempty(seriesTI) || ~isfield(seriesTI, 'eventOnsets')
                    continue;
                end

                % Compute histogram counts based on count mode
                switch psthCountMode
                    case 'Onsets'
                        allTimes = cat(1, seriesTI.eventOnsets{:});
                        if isempty(allTimes), continue; end
                        counts = histcounts(allTimes, binEdges);
                    case 'Offsets'
                        allTimes = cat(1, seriesTI.eventOffsets{:});
                        if isempty(allTimes), continue; end
                        counts = histcounts(allTimes, binEdges);
                    case 'Full duration'
                        % Count how many events are active in each bin
                        % (onset before bin end AND offset after bin start)
                        allOnsets = cat(1, seriesTI.eventOnsets{:});
                        allOffsets = cat(1, seriesTI.eventOffsets{:});
                        if isempty(allOnsets), continue; end
                        counts = zeros(1, length(binEdges) - 1);
                        for b = 1:length(counts)
                            counts(b) = sum(allOnsets < binEdges(b+1) & ...
                                            allOffsets > binEdges(b));
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
                if obj.PSTHSmoothingWindow > 1
                    psthValues = movmean(psthValues, obj.PSTHSmoothingWindow);
                end

                % Plot using the series' psthStyle setting
                style = s.psthStyle;
                if any(strcmp(style, {'Histogram', 'Both'}))
                    % Bar-style histogram using stairs for sharp bin edges
                    bar(ax, binCenters, psthValues, 1, ...
                        'FaceColor', s.color, 'FaceAlpha', 0.25, ...
                        'EdgeColor', 'none');
                end
                if any(strcmp(style, {'Line', 'Both'}))
                    plot(ax, binCenters, psthValues, ...
                        'Color', s.color, 'LineWidth', 1.5);
                end
            end

            % Zero line
            plot(ax, [0, 0], ax.YLim, '--', ...
                'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.5, ...
                'PickableParts', 'none', ...
                'HitTest', 'off');

            % Formatting (X limits linked to raster via linkaxes)
            ax.YLabel.String = yLabel;
            ax.XLabel.String = 'Time (s)';
            ax.Box = 'on';
            hold(ax, 'off');
        end

        function plotHist(obj)
            % Render the vertical histogram showing event counts per trial,
            % displayed as horizontal bars aligned with the raster Y axis.
            arguments
                obj RasterGUI
            end

            ti = obj.triggerInfo;
            if isempty(ti) || ~isfield(ti, 'absTime')
                return;
            end
            numTrials = length(ti.absTime);
            if numTrials == 0
                return;
            end

            ax = obj.axes_Hist;
            delete(ax.Children);
            hold(ax, 'on');

            % Use the first PSTH-enabled series for the histogram
            psthSeriesIdx = find([obj.eventSeries.showPSTH], 1);
            if isempty(psthSeriesIdx)
                % No series has showPSTH checked — leave blank
                hold(ax, 'off');
                return;
            end
            if isempty(psthSeriesIdx)
                hold(ax, 'off');
                return;
            end
            histTI = obj.eventSeries(psthSeriesIdx).triggerInfo;
            if isempty(histTI) || ~isfield(histTI, 'eventOnsets')
                hold(ax, 'off');
                return;
            end

            % Count events per trial within the visible X range
            xLim = obj.PlotXLim;
            countsPerTrial = zeros(numTrials, 1);
            for trialIdx = 1:numTrials
                eventTimes = histTI.eventOnsets{trialIdx};
                if ~isempty(eventTimes)
                    countsPerTrial(trialIdx) = sum(eventTimes >= xLim(1) & eventTimes <= xLim(2));
                end
            end

            % Bin counts by groups of trials for smoother display
            binSize = max(1, round(obj.HistBinSize(1)));
            numBins = ceil(numTrials / binSize);
            binnedCounts = zeros(numBins, 1);
            binCenters = zeros(numBins, 1);
            for binIdx = 1:numBins
                trialStart = (binIdx - 1) * binSize + 1;
                trialEnd = min(binIdx * binSize, numTrials);
                binnedCounts(binIdx) = mean(countsPerTrial(trialStart:trialEnd));
                binCenters(binIdx) = (trialStart + trialEnd) / 2;
            end

            % Smooth if requested
            if obj.HistSmoothingWindow > 1 && length(binnedCounts) > 1
                binnedCounts = movmean(binnedCounts, obj.HistSmoothingWindow);
            end

            % Plot as horizontal bars (Y = trial, X = count)
            barh(ax, binCenters, binnedCounts, 1, ...
                'FaceColor', [0.5, 0.5, 0.5], 'EdgeColor', 'none');

            % Match Y axis to raster (YLim follows via linkaxes)
            ax.YDir = 'reverse';
            ax.YTickLabel = {};  % Hide Y tick labels (shared with raster)
            ax.XLabel.String = 'Events';
            ax.Box = 'on';

            % Auto-scale X
            if max(binnedCounts) > 0
                ax.XLim = [0, max(binnedCounts) * 1.1];
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
            % Saves semantic names (not popup indices) so presets are
            % portable across different dbases.

            % Trigger settings
            trigSourceStrs = obj.popup_TriggerSource.String;
            preset.triggerSource = trigSourceStrs{obj.popup_TriggerSource.Value};
            trigTypeStrs = obj.popup_TriggerType.String;
            preset.triggerType = trigTypeStrs{obj.popup_TriggerType.Value};
            alignStrs = obj.popup_TriggerAlignment.String;
            preset.triggerAlignment = alignStrs{obj.popup_TriggerAlignment.Value};

            % Event series (save the config for each series, without triggerInfo)
            seriesConfigs = struct([]);
            for k = 1:length(obj.eventSeries)
                s = obj.eventSeries(k);
                seriesConfigs(k).name = s.name;
                seriesConfigs(k).sourceIdx = s.sourceIdx;
                seriesConfigs(k).type = s.type;
                seriesConfigs(k).filterMode = s.filterMode;
                seriesConfigs(k).filterList = s.filterList;
                seriesConfigs(k).burstFrequency = s.burstFrequency;
                seriesConfigs(k).burstMinSpikes = s.burstMinSpikes;
                seriesConfigs(k).selectionMode = s.selectionMode;
                seriesConfigs(k).color = s.color;
                seriesConfigs(k).showPSTH = s.showPSTH;
                seriesConfigs(k).psthStyle = s.psthStyle;
            end
            preset.eventSeries = seriesConfigs;

            % Window settings
            startRefStrs = obj.popup_StartReference.String;
            preset.startReference = startRefStrs{obj.popup_StartReference.Value};
            stopRefStrs = obj.popup_StopReference.String;
            preset.stopReference = stopRefStrs{obj.popup_StopReference.Value};
            preset.excludeIncomplete = logical(obj.check_ExcludeIncomplete.Value);
            preset.plotOtherTrialTriggers = logical(obj.check_PlotOtherTrialTriggers.Value);
            preset.excludePartialEvents = logical(obj.check_ExcludePartialEvents.Value);

            % Sort settings
            primarySortStrs = obj.popup_PrimarySort.String;
            preset.primarySort = primarySortStrs{obj.popup_PrimarySort.Value};
            secondarySortStrs = obj.popup_SecondarySort.String;
            preset.secondarySort = secondarySortStrs{obj.popup_SecondarySort.Value};
            preset.ascending = logical(obj.radio_Ascending.Value);
            preset.groupLabels = logical(obj.check_GroupLabels.Value);

            % File settings
            fileStrs = obj.popup_Files.String;
            preset.fileFilter = fileStrs{obj.popup_Files.Value};

            % PSTH settings
            psthUnitStrs = obj.popup_PSTHUnits.String;
            preset.psthUnits = psthUnitStrs{obj.popup_PSTHUnits.Value};
            psthCountStrs = obj.popup_PSTHCount.String;
            preset.psthCount = psthCountStrs{obj.popup_PSTHCount.Value};

            % Plot settings
            preset.plotXLim = obj.PlotXLim;
            preset.plotTickSize = obj.PlotTickSize;
            preset.plotOverlap = obj.PlotOverlap;
            preset.psthBinSize = obj.PSTHBinSize;
            preset.psthSmoothingWindow = obj.PSTHSmoothingWindow;

            % Parameters
            preset.P = obj.P;

            % File range
            preset.fileRange = obj.FileRange;
        end

        function applyPreset(obj, preset)
            % Apply a preset struct to the GUI, matching names to current
            % popup contents. Warns if a saved selection isn't available.
            arguments
                obj RasterGUI
                preset (1, 1) struct
            end

            obj.setPopupByName(obj.popup_TriggerSource, preset, 'triggerSource');
            obj.setPopupByName(obj.popup_TriggerType, preset, 'triggerType');
            obj.setPopupByName(obj.popup_TriggerAlignment, preset, 'triggerAlignment');

            % Restore event series from preset.
            % Each series config is rebuilt from the saved fields, with
            % an empty triggerInfo (data must be regenerated).
            if isfield(preset, 'eventSeries')
                % Clear existing series
                obj.eventSeries = struct( ...
                    'name', {}, 'sourceIdx', {}, 'type', {}, ...
                    'filterMode', {}, 'filterList', {}, ...
                    'burstFrequency', {}, 'burstMinSpikes', {}, ...
                    'selectionMode', {}, ...
                    'color', {}, 'showPSTH', {}, 'psthStyle', {}, ...
                    'triggerInfo', {});

                % Recreate each series from the saved config
                for k = 1:length(preset.eventSeries)
                    sc = preset.eventSeries(k);
                    obj.eventSeries(k).name = sc.name;
                    obj.eventSeries(k).sourceIdx = sc.sourceIdx;
                    obj.eventSeries(k).type = sc.type;
                    obj.eventSeries(k).filterMode = sc.filterMode;
                    obj.eventSeries(k).filterList = sc.filterList;
                    % Backward compatibility: use defaults if burst fields
                    % are missing from older presets
                    if isfield(sc, 'burstFrequency')
                        obj.eventSeries(k).burstFrequency = sc.burstFrequency;
                    else
                        obj.eventSeries(k).burstFrequency = 100;
                    end
                    if isfield(sc, 'burstMinSpikes')
                        obj.eventSeries(k).burstMinSpikes = sc.burstMinSpikes;
                    else
                        obj.eventSeries(k).burstMinSpikes = 2;
                    end
                    if isfield(sc, 'selectionMode')
                        obj.eventSeries(k).selectionMode = sc.selectionMode;
                    else
                        obj.eventSeries(k).selectionMode = 'Selected only';
                    end
                    obj.eventSeries(k).color = sc.color;
                    obj.eventSeries(k).showPSTH = logical(sc.showPSTH);
                    if isfield(sc, 'psthStyle')
                        obj.eventSeries(k).psthStyle = sc.psthStyle;
                    else
                        obj.eventSeries(k).psthStyle = 'Both';
                    end
                    obj.eventSeries(k).triggerInfo = struct();  % Must regenerate
                end

                % Update the list display and select the first series
                obj.refreshEventSeriesList();
                if ~isempty(obj.eventSeries)
                    obj.list_EventSeries.Value = 1;
                    obj.selectEventSeries();
                end
            end

            obj.setPopupByName(obj.popup_StartReference, preset, 'startReference');
            obj.setPopupByName(obj.popup_StopReference, preset, 'stopReference');
            obj.setCheckbox(obj.check_ExcludeIncomplete, preset, 'excludeIncomplete');
            obj.setCheckbox(obj.check_PlotOtherTrialTriggers, preset, 'plotOtherTrialTriggers');
            obj.setCheckbox(obj.check_ExcludePartialEvents, preset, 'excludePartialEvents');

            obj.setPopupByName(obj.popup_PrimarySort, preset, 'primarySort');
            obj.setPopupByName(obj.popup_SecondarySort, preset, 'secondarySort');
            if isfield(preset, 'ascending')
                obj.radio_Ascending.Value = preset.ascending;
                obj.radio_Descending.Value = ~preset.ascending;
            end
            obj.setCheckbox(obj.check_GroupLabels, preset, 'groupLabels');

            obj.setPopupByName(obj.popup_Files, preset, 'fileFilter');
            obj.setPopupByName(obj.popup_PSTHUnits, preset, 'psthUnits');
            obj.setPopupByName(obj.popup_PSTHCount, preset, 'psthCount');

            if isfield(preset, 'plotXLim'), obj.PlotXLim = preset.plotXLim; end
            if isfield(preset, 'plotTickSize'), obj.PlotTickSize = preset.plotTickSize; end
            if isfield(preset, 'plotOverlap'), obj.PlotOverlap = preset.plotOverlap; end
            if isfield(preset, 'psthBinSize'), obj.PSTHBinSize = preset.psthBinSize; end
            if isfield(preset, 'psthSmoothingWindow'), obj.PSTHSmoothingWindow = preset.psthSmoothingWindow; end
            if isfield(preset, 'P'), obj.P = preset.P; end
            if isfield(preset, 'fileRange'), obj.FileRange = preset.fileRange; end
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
            series.psthStyle = 'Both';
            series.triggerInfo = struct();
        end

        function addEventSeries(obj)
            % Add a new event series with default values.
            arguments
                obj RasterGUI
            end
            seriesNum = length(obj.eventSeries) + 1;
            obj.eventSeries(seriesNum) = obj.createDefaultEventSeries(seriesNum);
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
            if isempty(obj.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            obj.eventSeries(idx) = [];
            obj.refreshEventSeriesList();
            if ~isempty(obj.eventSeries)
                obj.list_EventSeries.Value = min(idx, length(obj.eventSeries));
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
            if isempty(obj.eventSeries)
                obj.list_EventSeries.String = {'(No event series)'};
                obj.list_EventSeries.Value = 1;
                obj.push_EventSeriesRemove.Enable = 'off';
            else
                names = cell(1, length(obj.eventSeries));
                for k = 1:length(obj.eventSeries)
                    names{k} = obj.eventSeries(k).name;
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
            if isempty(obj.eventSeries)
                obj.hideEventSeriesDetail();
                return;
            end
            idx = obj.list_EventSeries.Value;
            if idx < 1 || idx > length(obj.eventSeries)
                obj.hideEventSeriesDetail();
                return;
            end
            series = obj.eventSeries(idx);

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
            if isempty(obj.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            if idx < 1 || idx > length(obj.eventSeries)
                return;
            end

            obj.eventSeries(idx).name = obj.edit_EventSeriesName.String;
            obj.eventSeries(idx).sourceIdx = obj.popup_EventSeriesSource.Value;
            typeStrs = obj.popup_EventSeriesType.String;
            obj.eventSeries(idx).type = typeStrs{obj.popup_EventSeriesType.Value};
            filterModes = obj.popup_EventSeriesFilterMode.String;
            obj.eventSeries(idx).filterMode = filterModes{obj.popup_EventSeriesFilterMode.Value};
            obj.eventSeries(idx).filterList = obj.edit_EventSeriesFilterList.String;
            obj.eventSeries(idx).burstFrequency = str2double(obj.edit_EventSeriesBurstFreq.String);
            obj.eventSeries(idx).burstMinSpikes = str2double(obj.edit_EventSeriesBurstMinSpikes.String);
            selStrs = obj.popup_EventSeriesSelection.String;
            obj.eventSeries(idx).selectionMode = selStrs{obj.popup_EventSeriesSelection.Value};
            obj.eventSeries(idx).color = obj.push_EventSeriesColor.BackgroundColor;
            obj.eventSeries(idx).showPSTH = logical(obj.check_EventSeriesPSTH.Value);
            styleStrs = obj.popup_EventSeriesPSTHStyle.String;
            obj.eventSeries(idx).psthStyle = styleStrs{obj.popup_EventSeriesPSTHStyle.Value};

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
            if isempty(obj.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            newColor = uisetcolor(obj.eventSeries(idx).color, 'Pick series color');
            if length(newColor) == 3
                obj.eventSeries(idx).color = newColor;
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
            if isempty(obj.eventSeries)
                return;
            end
            idx = obj.list_EventSeries.Value;
            obj.eventSeries(idx).showPSTH = logical(obj.check_EventSeriesPSTH.Value);
            styleStrs = obj.popup_EventSeriesPSTHStyle.String;
            obj.eventSeries(idx).psthStyle = styleStrs{obj.popup_EventSeriesPSTHStyle.Value};
            % Replot PSTH and histogram to reflect the change
            obj.plotPSTH();
            obj.plotHist();
        end
    end

    %% Cache management
    methods (Access = private)
        function clearCache(obj)
            % Clear the pre-sort trigger info cache. Called when any
            % upstream setting changes (trigger/event source/type, window,
            % file range, include/ignore lists).
            arguments
                obj RasterGUI
            end
            obj.preSortTriggerInfo = struct();
        end

        function hasCache = hasCachedData(obj)
            % Check if a valid pre-sort cache exists.
            arguments
                obj RasterGUI
            end
            hasCache = ~isempty(fieldnames(obj.preSortTriggerInfo));
        end

        function resortAndPlot(obj)
            % Re-sort and re-plot from cached alignment data without
            % re-extracting triggers/events. No-op if cache is empty.
            arguments
                obj RasterGUI
            end
            if ~obj.hasCachedData()
                return;
            end

            obj.statusBar.Status = 'Re-sorting...';
            obj.statusBar.Progress = 0.3;
            drawnow;

            % Start from the cached pre-sort data
            ti = obj.preSortTriggerInfo;

            % Apply sort
            obj.syncOptionsFromGUI();
            primarySortStrs = obj.popup_PrimarySort.String;
            primarySortType = primarySortStrs{obj.popup_PrimarySort.Value};
            descending = obj.radio_Descending.Value;
            groupLabels = obj.check_GroupLabels.Value;

            secondarySortStrs = obj.popup_SecondarySort.String;
            secondarySortType = secondarySortStrs{obj.popup_SecondarySort.Value};

            % Secondary sort first (so primary is dominant)
            % Apply same order to all event series
            if ~strcmp(secondarySortType, '(None)')
                [ti, ord] = RasterGUI.sortTriggers(ti, secondarySortType, descending, '', false);
                for seriesIdx = 1:length(obj.eventSeries)
                    obj.eventSeries(seriesIdx).triggerInfo = ...
                        RasterGUI.applyOrder(obj.eventSeries(seriesIdx).triggerInfo, ord);
                end
            end
            if ~strcmp(primarySortType, '(None)')
                [ti, ord] = RasterGUI.sortTriggers(ti, primarySortType, descending, '', groupLabels);
                for seriesIdx = 1:length(obj.eventSeries)
                    obj.eventSeries(seriesIdx).triggerInfo = ...
                        RasterGUI.applyOrder(obj.eventSeries(seriesIdx).triggerInfo, ord);
                end
            end

            obj.triggerInfo = ti;

            obj.statusBar.Status = 'Plotting...';
            obj.statusBar.Progress = 0.7;
            drawnow;
            obj.plotRaster();
            obj.plotPSTH();
            obj.plotHist();

            obj.statusBar.Status = sprintf('Re-sorted — %d trials', length(ti.absTime));
            obj.statusBar.Progress = 1;
        end
    end

    %% Widget enable/disable management
    methods (Access = private)
        function controls = getAllInteractiveControls(obj)
            % Return a list of all interactive controls that should be
            % disabled during long operations.
            arguments
                obj RasterGUI
            end
            controls = [ ...
                obj.popup_TriggerSource, ...
                obj.popup_TriggerType, ...
                obj.popup_TriggerAlignment, ...
                obj.popup_TrigFilterMode, ...
                obj.edit_TrigFilterList, ...
                obj.check_ExcludeIncomplete, ...
                obj.check_PlotOtherTrialTriggers, ...
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
                obj.push_GenerateRaster];
        end

        function disableAllControls(obj)
            % Disable all interactive controls (e.g., during generation).
            arguments
                obj RasterGUI
            end
            controls = obj.getAllInteractiveControls();
            for k = 1:length(controls)
                controls(k).Enable = 'off';
            end
        end

        function updateControlStates(obj)
            % Set each control to its correct enabled/disabled state based
            % on current context. Call this after an operation completes.
            arguments
                obj RasterGUI
            end

            % Default: enable everything
            controls = obj.getAllInteractiveControls();
            for k = 1:length(controls)
                controls(k).Enable = 'on';
            end

            % Update trigger type options based on trigger source.
            % Source index 0 means "Sound", which provides behavioral
            % triggers (syllables, markers, etc.). Any other source is
            % an event detector, which provides neural event types.
            numEventSources = length(obj.eg.dbase.EventSources);
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
            % Read all inline option controls into properties before generating.
            arguments
                obj RasterGUI
            end

            % Trigger filter
            trigModes = obj.popup_TrigFilterMode.String;
            obj.P.trig.filterMode = trigModes{obj.popup_TrigFilterMode.Value};
            obj.P.trig.filterList = obj.edit_TrigFilterList.String;

            % Event series: save the currently selected series' detail
            % controls back to the series array
            if ~isempty(obj.eventSeries)
                obj.saveSelectedEventSeries();
            end

            % Window limits
            obj.P.preStartRef = str2double(obj.edit_PreStart.String);
            obj.P.postStopRef = str2double(obj.edit_PostStop.String);

            % File range
            try
                obj.FileRange = eval(obj.edit_FileRange.String);
            catch
                electro_gui.issueWarning('Invalid file range expression, using all files.', 'badFileRange');
                numFiles = electro_gui.getNumFiles(obj.eg.dbase);
                obj.FileRange = 1:numFiles;
            end

            % Apply file read state filter
            fileFilterStrs = obj.popup_Files.String;
            fileFilter = fileFilterStrs{obj.popup_Files.Value};
            switch fileFilter
                case 'Only read files'
                    readMask = obj.eg.dbase.FileReadState(obj.FileRange);
                    obj.FileRange = obj.FileRange(readMask);
                case 'Only unread files'
                    readMask = obj.eg.dbase.FileReadState(obj.FileRange);
                    obj.FileRange = obj.FileRange(~readMask);
            end

            % Apply property filter
            propModes = obj.popup_PropertyFilterMode.String;
            propMode = propModes{obj.popup_PropertyFilterMode.Value};
            switch propMode
                case 'Single'
                    propNames = obj.popup_PropertyName.String;
                    propName = propNames{obj.popup_PropertyName.Value};
                    if ~strcmp(propName, '(No properties)')
                        propValues = obj.eg.getPropertyValue(propName, obj.FileRange);
                        obj.FileRange = obj.FileRange(logical(propValues));
                    end
                case 'Expression'
                    expr = obj.edit_PropertyExpression.String;
                    if ~isempty(strtrim(expr))
                        try
                            obj.FileRange = obj.evaluatePropertyExpression(expr, obj.FileRange);
                        catch ME
                            warndlg(sprintf('Property expression error: %s', ME.message), 'Expression error');
                        end
                    end
            end

            % Plot settings
            obj.PlotXLim = [str2double(obj.edit_XMin.String), str2double(obj.edit_XMax.String)];
            obj.PlotTickSize(1) = str2double(obj.edit_TickHeight.String);
            obj.PlotTickSize(3) = str2double(obj.edit_TickLineWidth.String);
            obj.PSTHBinSize = str2double(obj.edit_BinSize.String);
            obj.PlotOverlap = str2double(obj.edit_Overlap.String);
        end
        function autoXLimChanged(obj)
            % Called when the Auto X limits checkbox changes.
            arguments
                obj RasterGUI
            end
            obj.updateControlStates();
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
            if isempty(fieldnames(obj.triggerInfo))
                return;
            end
            if obj.check_AutoXLim.Value
                % Recompute tight limits from raster data
                obj.plotRaster();  % Will compute and set tight X limits
            else
                obj.axes_Raster.XLim = obj.PlotXLim;  % PSTH follows via linkaxes
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
            % Replot from the current triggerInfo without regenerating data.
            arguments
                obj RasterGUI
            end
            if isempty(fieldnames(obj.triggerInfo))
                return;
            end
            obj.syncOptionsFromGUI();
            obj.plotRaster();
            obj.plotPSTH();
            obj.plotHist();
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
            arguments
                obj RasterGUI
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
        function onRasterClick(obj)
            % Handle clicks on the raster axes. Double-click resets
            % the Y zoom to show all trials.
            arguments
                obj RasterGUI
            end
            if strcmp(obj.figure_Main.SelectionType, 'open')
                obj.axes_Raster.YLim = obj.RasterFullYLim;
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
        function [ons, offs, inform, lst] = getEventStructure(obj, eventSourceIdx, eventTypeStr, P)
            % Extract triggers or events from the dbase across files.
            arguments
                obj RasterGUI
                eventSourceIdx (1, 1) double {mustBeInteger, mustBeNonnegative}
                eventTypeStr (1, :) char {mustBeMember(eventTypeStr, {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses', 'Syllables', 'Markers', 'Motifs', 'Bouts', 'Continuous function'})}
                P (1, 1) struct
            end
            %
            % Arguments:
            %   eventSourceIdx - index into EventTimes (0 = sound/segments)
            %   eventTypeStr - one of: 'Events', 'Bursts', 'Burst events',
            %       'Single events', 'Pauses', 'Syllables', 'Markers',
            %       'Motifs', 'Bouts', 'Continuous function'
            %   P - parameter struct with fields like burstFrequency,
            %       motifSequences, boutInterval, etc.
            %
            % Returns:
            %   ons - cell array of onset times (in samples) per file
            %   offs - cell array of offset times (in samples) per file
            %   inform - struct with .label (cell of label arrays) and
            %       .filenum (file numbers)
            %   lst - list of file indices processed

            dbase = obj.eg.dbase;
            fs = dbase.Fs;
            lst = obj.FileRange;

            % Filter file list based on file selection popup
            % (For now, use all files in range — file search filtering
            % can be added later when the file list widget is ported)

            numLstFiles = length(lst);
            ons = cell(1, numLstFiles);
            offs = cell(1, numLstFiles);
            inform.label = cell(1, numLstFiles);
            inform.filenum = zeros(1, numLstFiles);

            for fileListIdx = 1:numLstFiles
                filenum = lst(fileListIdx);

                % For spike event types, build the selection mask and
                % extract part times once before the type-specific logic.
                % P.selectionMode controls which events are included:
                % 'All', 'Selected only', or 'Unselected only'.
                if ismember(eventTypeStr, {'Events', 'Bursts', 'Burst events', 'Single events', 'Pauses'})
                    selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                    for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                        selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                    end
                    switch P.selectionMode
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
                        inform.label{fileListIdx} = zeros(size(allPartTimes, 1), 1);

                    case 'Bursts'
                        % Find bursts based on inter-event frequency
                        eventSamples = min(allPartTimes, [], 2);
                        burstOnsets = find(fs ./ (eventSamples(1:end-1) - [-inf; eventSamples(1:end-2)]) <= P.burstFrequency & ...
                            fs ./ (eventSamples(2:end) - eventSamples(1:end-1)) > (P.burstFrequency + eps));
                        burstOffsets = find(fs ./ (eventSamples(2:end) - eventSamples(1:end-1)) > P.burstFrequency & ...
                            fs ./ ([eventSamples(3:end); inf] - eventSamples(2:end)) <= P.burstFrequency) + 1;
                        validBursts = find(burstOffsets - burstOnsets >= P.burstMinSpikes - 1);
                        ons{fileListIdx} = eventSamples(burstOnsets(validBursts));
                        offs{fileListIdx} = eventSamples(burstOffsets(validBursts));
                        inform.label{fileListIdx} = 1000 + burstOffsets(validBursts) - burstOnsets(validBursts) + 1;

                    case {'Burst events', 'Single events'}
                        % Categorize individual spikes by burst membership
                        evOn = min(allPartTimes, [], 2);
                        evOff = max(allPartTimes, [], 2);
                        burstOnsets = find(fs ./ (evOn(1:end-1) - [-inf; evOn(1:end-2)]) <= P.burstFrequency & ...
                            fs ./ (evOn(2:end) - evOn(1:end-1)) > (P.burstFrequency + eps));
                        burstOffsets = find(fs ./ (evOn(2:end) - evOn(1:end-1)) > P.burstFrequency & ...
                            fs ./ ([evOn(3:end); inf] - evOn(2:end)) <= P.burstFrequency) + 1;
                        validBursts = find(burstOffsets - burstOnsets >= P.burstMinSpikes - 1);
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
                        inform.label{fileListIdx} = zeros(length(ons{fileListIdx}), 1);

                    case 'Pauses'
                        % Find gaps between events
                        gapOnsets = [min(allPartTimes, [], 2); obj.eg.getFileLength(filenum) + fs * P.pauseMinDuration];
                        gapOffsets = [-fs * P.pauseMinDuration; max(allPartTimes, [], 2)];
                        pauseIndices = find(gapOnsets - gapOffsets > fs * P.pauseMinDuration);
                        ons{fileListIdx} = gapOffsets(pauseIndices);
                        offs{fileListIdx} = gapOnsets(pauseIndices);
                        inform.label{fileListIdx} = zeros(length(pauseIndices), 1);

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
                            switch P.selectionMode
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
                            inform.label{fileListIdx} = labels;

                            % Apply filter based on mode
                            keepMask = RasterGUI.getLabelFilterMask(labels, P.filterMode, P.filterList);
                            ons{fileListIdx} = ons{fileListIdx}(keepMask);
                            offs{fileListIdx} = offs{fileListIdx}(keepMask);
                            inform.label{fileListIdx} = inform.label{fileListIdx}(keepMask);
                        end

                    case 'Motifs'
                        if ~isempty(dbase.SegmentTimes{filenum})
                            % Apply selection mode filter
                            switch P.selectionMode
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
                            inform.label{fileListIdx} = [];
                            for motifIdx = 1:length(P.motifSequences)
                                [matchStarts, matchEnds] = regexp(titleStr, P.motifSequences{motifIdx}, 'start', 'end');
                                % Validate motif continuity
                                for matchIdx = length(matchStarts):-1:1
                                    if max(syllOnsets(matchStarts(matchIdx)+1:matchEnds(matchIdx)) - syllOffsets(matchStarts(matchIdx):matchEnds(matchIdx)-1)) > fs * P.motifInterval
                                        matchStarts(matchIdx) = [];
                                        matchEnds(matchIdx) = [];
                                    end
                                end
                                ons{fileListIdx} = [ons{fileListIdx}; syllOnsets(matchStarts)];
                                offs{fileListIdx} = [offs{fileListIdx}; syllOffsets(matchEnds)];
                                inform.label{fileListIdx} = [inform.label{fileListIdx}; motifIdx * ones(length(matchStarts), 1)];
                            end
                            inform.label{fileListIdx} = 1000 + inform.label{fileListIdx};
                        end

                    case 'Bouts'
                        if ~isempty(dbase.SegmentTimes{filenum})
                            % Apply selection mode filter
                            switch P.selectionMode
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
                            keepMask = RasterGUI.getLabelFilterMask(labels, P.filterMode, P.filterList);
                            selectedIndices = selectedIndices(keepMask);

                            % Find bouts: groups of syllables separated by gaps
                            syllOnsets = [dbase.SegmentTimes{filenum}(selectedIndices, 1); inf];
                            syllOffsets = [-inf; dbase.SegmentTimes{filenum}(selectedIndices, 2)];
                            gapIndices = find(syllOnsets - syllOffsets > fs * P.boutInterval);
                            boutStarts = gapIndices(1:end-1);
                            boutEnds = gapIndices(2:end) - 1;
                            durationOK = find(syllOffsets(boutEnds + 1) - syllOnsets(boutStarts) > fs * P.boutMinDuration);
                            syllCountOK = find(boutEnds - boutStarts >= P.boutMinSyllables - 1);
                            validBouts = intersect(durationOK, syllCountOK);
                            ons{fileListIdx} = syllOnsets(boutStarts(validBouts));
                            offs{fileListIdx} = syllOffsets(boutEnds(validBouts) + 1);
                            inform.label{fileListIdx} = 1000 + boutEnds(validBouts) - boutStarts(validBouts) + 1;
                        end

                    case 'Continuous function'
                        ons{fileListIdx} = [];
                        offs{fileListIdx} = [];
                        inform.label{fileListIdx} = [];
                end

                inform.filenum(fileListIdx) = filenum;
                if size(ons{fileListIdx}, 2) == 0
                    ons{fileListIdx} = [];
                    offs{fileListIdx} = [];
                    inform.label{fileListIdx} = [];
                end
            end
        end

        function [triggerInfo] = alignEventsToTriggers(obj, trig, event)
            % Align events to triggers within a time window and compute
            % per-trial metadata.
            arguments
                obj RasterGUI
                trig (1, 1) struct  % Struct with .on, .off (cell arrays), .info
                event (1, 1) struct % Struct with .on, .off (cell arrays), .info
            end
            %
            % This is a simplified version of GetTriggerAlignedEvents that
            % handles the core alignment without correlation or warp points.
            % Those features can be added incrementally.

            dbase = obj.eg.dbase;
            fs = dbase.Fs;

            alignmentType = obj.popup_TriggerAlignment.String{obj.popup_TriggerAlignment.Value};
            startRefType = obj.popup_StartReference.String{obj.popup_StartReference.Value};
            stopRefType = obj.popup_StopReference.String{obj.popup_StopReference.Value};
            excludeIncomplete = obj.check_ExcludeIncomplete.Value;
            excludePartial = obj.check_ExcludePartialEvents.Value;

            count = 0;
            triggerInfo = struct();

            for fileIdx = 1:length(trig.on)
                for trigIdx = 1:length(trig.on{fileIdx})
                    % Determine alignment point
                    switch alignmentType
                        case 'Onset'
                            alignSample = trig.on{fileIdx}(trigIdx);
                        case 'Midpoint'
                            alignSample = round((trig.on{fileIdx}(trigIdx) + trig.off{fileIdx}(trigIdx)) / 2);
                        case 'Offset'
                            alignSample = trig.off{fileIdx}(trigIdx);
                    end

                    filenum = trig.info.filenum(fileIdx);
                    fileDatetime = electro_gui.getFileDatetime(obj.eg.dbase, filenum);
                    absTime = posixtime(fileDatetime) + alignSample / fs;

                    % Determine window start (in samples)
                    switch startRefType
                        case 'Trigger onset'
                            windowStart = trig.on{fileIdx}(trigIdx);
                        case 'Trigger offset'
                            windowStart = trig.off{fileIdx}(trigIdx);
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
                            windowEnd = trig.on{fileIdx}(trigIdx);
                        case 'Trigger offset'
                            windowEnd = trig.off{fileIdx}(trigIdx);
                        case 'Next trigger onset'
                            if trigIdx == length(trig.on{fileIdx})
                                windowEnd = inf;
                            else
                                windowEnd = trig.on{fileIdx}(trigIdx + 1);
                            end
                        case 'Next trigger offset'
                            if trigIdx == length(trig.on{fileIdx})
                                windowEnd = inf;
                            else
                                windowEnd = trig.off{fileIdx}(trigIdx + 1);
                            end
                    end

                    % Apply pre/post padding
                    windowStart = round(windowStart - obj.P.preStartRef * fs);
                    windowEnd = round(windowEnd + obj.P.postStopRef * fs);

                    % Check completeness
                    if windowStart < 1 || windowEnd > obj.eg.getFileLength(filenum)
                        if excludeIncomplete
                            continue;
                        end
                        isComplete = 0;
                    else
                        isComplete = 1;
                    end
                    windowStart = max(windowStart, 1);
                    windowEnd = min(windowEnd, obj.eg.getFileLength(filenum));

                    count = count + 1;

                    % Store trigger metadata
                    triggerInfo.fileNum(count) = fileIdx;
                    triggerInfo.isComplete(count) = isComplete;
                    triggerInfo.absTime(count) = absTime;
                    triggerInfo.label(count) = trig.info.label{fileIdx}(trigIdx);
                    triggerInfo.corrShift(count) = 0;
                    triggerInfo.dataStart{count} = (windowStart - alignSample) / fs + eps;
                    triggerInfo.dataStop{count} = (windowEnd - alignSample) / fs - eps;

                    % Previous/current/next trigger positions relative to alignment
                    triggerInfo.currTrigOnset(count) = (trig.on{fileIdx}(trigIdx) - alignSample) / fs;
                    triggerInfo.currTrigOffset(count) = (trig.off{fileIdx}(trigIdx) - alignSample) / fs;
                    if trigIdx == 1
                        triggerInfo.prevTrigOnset(count) = -inf;
                        triggerInfo.prevTrigOffset(count) = -inf;
                    else
                        triggerInfo.prevTrigOnset(count) = (trig.on{fileIdx}(trigIdx-1) - alignSample) / fs;
                        triggerInfo.prevTrigOffset(count) = (trig.off{fileIdx}(trigIdx-1) - alignSample) / fs;
                    end
                    if trigIdx == length(trig.on{fileIdx})
                        triggerInfo.nextTrigOnset(count) = inf;
                        triggerInfo.nextTrigOffset(count) = inf;
                    else
                        triggerInfo.nextTrigOnset(count) = (trig.on{fileIdx}(trigIdx+1) - alignSample) / fs;
                        triggerInfo.nextTrigOffset(count) = (trig.off{fileIdx}(trigIdx+1) - alignSample) / fs;
                    end

                    % Find events within the window
                    if excludePartial
                        eventIdx = find(event.on{fileIdx} > windowStart & event.off{fileIdx} < windowEnd);
                    else
                        onInWindow = find(event.on{fileIdx} > windowStart & event.on{fileIdx} < windowEnd);
                        offInWindow = find(event.off{fileIdx} > windowStart & event.off{fileIdx} < windowEnd);
                        spanning = find(event.on{fileIdx} < windowStart & event.off{fileIdx} > windowEnd);
                        eventIdx = union(union(onInWindow, offInWindow), spanning);
                    end
                    triggerInfo.eventOnsets{count} = (event.on{fileIdx}(eventIdx) - alignSample) / fs;
                    triggerInfo.eventOffsets{count} = (event.off{fileIdx}(eventIdx) - alignSample) / fs;
                    triggerInfo.eventLabels{count} = event.info.label{fileIdx}(eventIdx) / fs;
                end
            end

            % Warn if timestamps are not strictly increasing, which
            % indicates the dbase file timestamps may be incorrect
            % (e.g., chunked files sharing a parent timestamp).
            if count > 1 && any(diff(triggerInfo.absTime) <= 0)
                warning('RasterGUI:nonMonotonicTime', ...
                    ['Trigger absolute times are not strictly increasing. ' ...
                     'This may cause incorrect cross-trial trigger plotting. ' ...
                     'Consider running the "Fix chunked timestamps" macro.']);
            end
        end
    end

    methods (Static, Access = private)
        function [triggerInfo, ord] = sortTriggers(triggerInfo, sortType, descending, includeList, groupLabels)
            % Sort triggers according to the specified criterion.
            arguments
                triggerInfo (1, 1) struct
                sortType (1, :) char
                descending (1, 1) logical
                includeList (1, :) char = ''
                groupLabels (1, 1) logical = false
            end
            %
            % Arguments:
            %   triggerInfo - struct from alignEventsToTriggers
            %   sortType - one of the sort option strings
            %   descending - true for descending order
            %   includeList - label inclusion list (for label sorting)
            %   groupLabels - true to group triggers by label

            switch sortType
                case 'Absolute time'
                    sortValues = triggerInfo.absTime;
                case 'Trigger duration'
                    sortValues = triggerInfo.currTrigOffset - triggerInfo.currTrigOnset;
                case 'Prev trig onset'
                    sortValues = -triggerInfo.prevTrigOnset;
                case 'Prev trig offset'
                    sortValues = -triggerInfo.prevTrigOffset;
                case 'Prev trig interval'
                    sortValues = -(triggerInfo.prevTrigOffset - triggerInfo.prevTrigOnset);
                case 'Next trig onset'
                    sortValues = triggerInfo.nextTrigOnset;
                case 'Next trig offset'
                    sortValues = triggerInfo.nextTrigOffset;
                case 'Next trig interval'
                    sortValues = triggerInfo.nextTrigOffset - triggerInfo.nextTrigOnset;
                case 'Trigger label'
                    sortValues = triggerInfo.label;
                    if max(sortValues) > 0 && ~isempty(includeList)
                        escapeIdx = strfind(includeList, '''''');
                        includeList = double(includeList);
                        if ~isempty(escapeIdx)
                            includeList(escapeIdx + 1) = [];
                            includeList(escapeIdx) = 0;
                        end
                        for k = 1:length(includeList)
                            sortValues(sortValues == includeList(k)) = 1000 + k;
                        end
                    end
                case 'Preceding event onset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        preceding = find(triggerInfo.eventOnsets{k} < 0);
                        if ~isempty(preceding)
                            sortValues(k) = -triggerInfo.eventOnsets{k}(preceding(end));
                        end
                    end
                case 'Preceding event offset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        preceding = find(triggerInfo.eventOffsets{k} < 0);
                        if ~isempty(preceding)
                            sortValues(k) = -triggerInfo.eventOffsets{k}(preceding(end));
                        end
                    end
                case 'Following event onset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        following = find(triggerInfo.eventOnsets{k} > 0);
                        if ~isempty(following)
                            sortValues(k) = triggerInfo.eventOnsets{k}(following(1));
                        end
                    end
                case 'Following event offset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        following = find(triggerInfo.eventOffsets{k} > 0);
                        if ~isempty(following)
                            sortValues(k) = triggerInfo.eventOffsets{k}(following(1));
                        end
                    end
                case 'First event onset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        if ~isempty(triggerInfo.eventOnsets{k})
                            sortValues(k) = min(triggerInfo.eventOnsets{k});
                        end
                    end
                case 'First event offset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        if ~isempty(triggerInfo.eventOffsets{k})
                            sortValues(k) = min(triggerInfo.eventOffsets{k});
                        end
                    end
                case 'Last event onset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        if ~isempty(triggerInfo.eventOnsets{k})
                            sortValues(k) = max(triggerInfo.eventOnsets{k});
                        end
                    end
                case 'Last event offset'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        if ~isempty(triggerInfo.eventOffsets{k})
                            sortValues(k) = max(triggerInfo.eventOffsets{k});
                        end
                    end
                case 'Number of events'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        sortValues(k) = length(triggerInfo.eventOnsets{k});
                    end
                case 'Is in event'
                    sortValues = inf(size(triggerInfo.absTime));
                    for k = 1:length(sortValues)
                        sortValues(k) = (length(find(triggerInfo.eventOnsets{k} <= 0)) > ...
                            length(find(triggerInfo.eventOffsets{k} < 0)));
                    end
                otherwise
                    % (None) or unrecognized — no sort
                    ord = 1:length(triggerInfo.absTime);
                    return;
            end

            [~, ord] = sort(sortValues);
            if descending
                ord = ord(end:-1:1);
            end

            % Group by label if requested
            if groupLabels
                uniqueLabels = unique(triggerInfo.label);
                groupSort = zeros(size(triggerInfo.label));
                for k = 1:length(uniqueLabels)
                    groupSort(triggerInfo.label == uniqueLabels(k)) = ...
                        mean(find(triggerInfo.label(ord) == uniqueLabels(k)));
                end
                [~, ord] = sort(groupSort);
            end

            % Apply sort order to all fields
            fields = fieldnames(triggerInfo);
            for k = 1:length(fields)
                if ~strcmp(fields{k}, 'contLabel')
                    triggerInfo.(fields{k}) = triggerInfo.(fields{k})(ord);
                end
            end
        end
    end

    %% Sort options
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

        function reorderedTI = applyOrder(ti, ord)
            % Apply a sort order to a triggerInfo struct (reorder all fields).
            arguments
                ti (1, 1) struct
                ord (1, :) double
            end
            reorderedTI = ti;
            fields = fieldnames(ti);
            for k = 1:length(fields)
                if ~strcmp(fields{k}, 'contLabel') && length(ti.(fields{k})) == length(ord)
                    reorderedTI.(fields{k}) = ti.(fields{k})(ord);
                end
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
