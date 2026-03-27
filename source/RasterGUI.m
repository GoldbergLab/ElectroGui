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
        check_CopyEvents

        % Event panel
        popup_EventSource
        popup_EventType
        check_CopyTrigger

        % Window panel
        popup_StartReference
        popup_StopReference
        check_ExcludeIncomplete
        check_ExcludePartialEvents

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
        push_Hold

        % PSTH panel
        popup_PSTHUnits
        popup_PSTHCount

        % Window inline edits
        edit_PreStart
        edit_PostStop

        % Files inline edit
        edit_FileRange

        % Plot inline edits
        edit_XMin
        edit_XMax
        edit_TickHeight
        edit_BinSize
        edit_TickLineWidth
        edit_Overlap

        % Trigger options (inline in tab)
        popup_TrigFilterMode    % 'All', 'Include', 'Exclude'
        edit_TrigFilterList

        % Event options (inline in tab)
        popup_EventFilterMode   % 'All', 'Include', 'Exclude'
        edit_EventFilterList

        % Presets tab
        popup_Presets
        push_LoadPreset
        push_SavePreset
        push_DeletePreset

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
        text_EventType
        text_StartReference
        text_StopReference
        text_PreStart
        text_PostStop
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
        AllEventOnsets cell = {}
        AllEventOffsets cell = {}
        AllEventLabels cell = {}
        AllSelections cell = {}
        AllEventOptions cell = {}
        AllEventPlots double = zeros(0, 5)

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
        PlotTickSize double = [1, 0.25, 0.01, 0.5]
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
                obj.populateSourceMenus();
                obj.refreshPresetList();  % Also calls updateControlStates
            end
            obj.figure_Main.Visible = 'on';
            figure(obj.figure_Main);  % Bring to front
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
                % Validate filter settings
                if strcmp(obj.P.trig.filterMode, 'Include') && isempty(obj.P.trig.filterList)
                    obj.statusBar.Status = 'Error: Include mode requires labels';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('Trigger filter is set to "Include" but no labels are specified.', 'Empty include list');
                    return;
                end
                if strcmp(obj.P.event.filterMode, 'Include') && isempty(obj.P.event.filterList)
                    obj.statusBar.Status = 'Error: Include mode requires labels';
                    obj.statusBar.Progress = [];
                    obj.updateControlStates();
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    warndlg('Event filter is set to "Include" but no labels are specified.', 'Empty include list');
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

                % --- Step 2: Get event times ---
                obj.statusBar.Status = 'Extracting events...';
                obj.statusBar.Progress = 0.25;
                drawnow;
                eventSourceIdx = obj.popup_EventSource.Value - 1;
                eventTypeStrs = obj.popup_EventType.String;
                eventTypeStr = eventTypeStrs{obj.popup_EventType.Value};
                [event.on, event.off, event.info, ~] = obj.getEventStructure( ...
                    eventSourceIdx, eventTypeStr, obj.P.event);

                % --- Step 3: Align events to triggers ---
                obj.statusBar.Status = 'Aligning events to triggers...';
                obj.statusBar.Progress = 0.45;
                drawnow;
                ti = obj.alignEventsToTriggers(trig, event);

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

                % --- Step 4: Sort triggers ---
                obj.statusBar.Status = sprintf('Sorting %d triggers...', length(ti.absTime));
                obj.statusBar.Progress = 0.6;
                drawnow;
                primarySortStrs = obj.popup_PrimarySort.String;
                primarySortType = primarySortStrs{obj.popup_PrimarySort.Value};
                descending = obj.radio_Descending.Value;
                groupLabels = obj.check_GroupLabels.Value;

                % Apply secondary sort first (so primary is dominant)
                secondarySortStrs = obj.popup_SecondarySort.String;
                secondarySortType = secondarySortStrs{obj.popup_SecondarySort.Value};
                if ~strcmp(secondarySortType, '(None)')
                    ti = RasterGUI.sortTriggers(ti, secondarySortType, descending, ...
                        obj.P.event.filterList, false);
                end
                if ~strcmp(primarySortType, '(None)')
                    ti = RasterGUI.sortTriggers(ti, primarySortType, descending, ...
                        obj.P.event.filterList, groupLabels);
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
            obj.P.trig.pauseMinDuration = 0.05;
            obj.P.trig.contSmooth = 1;
            obj.P.trig.contSubsample = 0.001;
            obj.P.event = obj.P.trig;
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
            buttonY = bottomY;                      % Y position of Generate/Hold buttons
            buttonH = 0.08;                         % Height of Generate/Hold buttons
            tabGroupY = buttonY + buttonH + 0.01;   % Tab group starts above buttons
            tabGroupH = 0.97 - tabGroupY;           % Tab group fills to top

            % Axes panel (contains raster, PSTH, and histogram axes)
            axesPanelX = leftX + leftW + 0.005;
            axesPanelW = 1 - axesPanelX - 0.005;
            axesPanelY = bottomY;
            axesPanelH = 0.99;

            % Axes positions relative to the panel
            axesMargin = 0.035;
            rasterX = 0.08;                       % Left edge within panel
            rasterY = 0.35;                       % Raster bottom within panel
            rasterH = 0.58;                       % Raster height
            psthY = 0.10;                         % PSTH bottom within panel
            psthH = rasterY - psthY - axesMargin; % PSTH fills gap below raster
            axesW = 0.58;                         % Width of raster and PSTH
            histX = rasterX + axesW + axesMargin; % Histogram x within panel
            histW = 0.14;                         % Histogram width

            % Tab content layout in pixels (controls stay compact regardless
            % of window size; tab group itself uses normalized units)
            textHeight = 28;
            m = 5;                         % Margin (px)
            rowH = 22;                     % Row height (px)
            rowSpacing = 28;               % Vertical spacing between row tops (px)
            numRows = 8;
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
            obj.check_CopyEvents.Units = 'pixels';
            obj.check_CopyEvents.Position = [tabMargin, rowY(4), tabFullW, rowH];
            % Inline trigger filter (visible depending on type)
            filterModeW = 70;
            filterListX = tabMargin + filterModeW + 4;
            filterListW = fullW - filterListX;
            obj.popup_TrigFilterMode.Units = 'pixels';
            obj.popup_TrigFilterMode.Position = [tabMargin, rowY(5), filterModeW, rowH];
            obj.edit_TrigFilterList.Units = 'pixels';
            obj.edit_TrigFilterList.Position = [filterListX, rowY(5), filterListW, rowH];
            % --- Events tab ---
            obj.popup_EventSource.Units = 'pixels';
            obj.popup_EventSource.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.text_EventType.Units = 'pixels';
            obj.text_EventType.Position = [tabMargin, rowY(2), labelW, rowH];
            obj.popup_EventType.Units = 'pixels';
            obj.popup_EventType.Position = [popupAfterLabelX, rowY(2), popupAfterLabelW, rowH];
            obj.check_CopyTrigger.Units = 'pixels';
            obj.check_CopyTrigger.Position = [tabMargin, rowY(3), tabFullW, rowH];
            % Inline event filter (visible depending on type)
            obj.popup_EventFilterMode.Units = 'pixels';
            obj.popup_EventFilterMode.Position = [tabMargin, rowY(4), filterModeW, rowH];
            obj.edit_EventFilterList.Units = 'pixels';
            obj.edit_EventFilterList.Position = [filterListX, rowY(4), filterListW, rowH];
            % --- Window tab ---
            obj.text_StartReference.Units = 'pixels';
            obj.text_StartReference.Position = [tabMargin, rowY(1), winLabelW, rowH];
            obj.popup_StartReference.Units = 'pixels';
            obj.popup_StartReference.Position = [winPopupX, rowY(1), winPopupW, rowH];
            obj.text_StopReference.Units = 'pixels';
            obj.text_StopReference.Position = [tabMargin, rowY(2), winLabelW, rowH];
            obj.popup_StopReference.Units = 'pixels';
            obj.popup_StopReference.Position = [winPopupX, rowY(2), winPopupW, rowH];
            obj.text_PreStart.Units = 'pixels';
            obj.text_PreStart.Position = [tabMargin, rowY(3), winLabelW, rowH];
            obj.edit_PreStart.Units = 'pixels';
            obj.edit_PreStart.Position = [winPopupX, rowY(3), editW, rowH];
            obj.text_PostStop.Units = 'pixels';
            obj.text_PostStop.Position = [winPopupX + editW + 4, rowY(3), winLabelW, rowH];
            obj.edit_PostStop.Units = 'pixels';
            obj.edit_PostStop.Position = [winPopupX + editW + winLabelW + 8, rowY(3), editW, rowH];
            obj.check_ExcludeIncomplete.Units = 'pixels';
            obj.check_ExcludeIncomplete.Position = [tabMargin, rowY(4), tabFullW, rowH];
            obj.check_ExcludePartialEvents.Units = 'pixels';
            obj.check_ExcludePartialEvents.Position = [tabMargin, rowY(5), tabFullW, rowH];
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
            obj.text_XMin.Units = 'pixels';
            obj.text_XMin.Position = [tabMargin, rowY(1), plotLabelW, rowH];
            obj.edit_XMin.Units = 'pixels';
            obj.edit_XMin.Position = [tabMargin + plotLabelW + 2, rowY(1), plotEditW, rowH];
            obj.text_XMax.Units = 'pixels';
            obj.text_XMax.Position = [col2X, rowY(1), plotLabelW, rowH];
            obj.edit_XMax.Units = 'pixels';
            obj.edit_XMax.Position = [col2X + plotLabelW + 2, rowY(1), plotEditW, rowH];
            obj.text_TickHeight.Units = 'pixels';
            obj.text_TickHeight.Position = [tabMargin, rowY(2), plotLabelW, rowH];
            obj.edit_TickHeight.Units = 'pixels';
            obj.edit_TickHeight.Position = [tabMargin + plotLabelW + 2, rowY(2), plotEditW, rowH];
            obj.text_BinSize.Units = 'pixels';
            obj.text_BinSize.Position = [col2X, rowY(2), plotLabelW, rowH];
            obj.edit_BinSize.Units = 'pixels';
            obj.edit_BinSize.Position = [col2X + plotLabelW + 2, rowY(2), plotEditW, rowH];
            obj.text_TickLineWidth.Units = 'pixels';
            obj.text_TickLineWidth.Position = [tabMargin, rowY(3), plotLabelW, rowH];
            obj.edit_TickLineWidth.Units = 'pixels';
            obj.edit_TickLineWidth.Position = [tabMargin + plotLabelW + 2, rowY(3), plotEditW, rowH];
            obj.text_Overlap.Units = 'pixels';
            obj.text_Overlap.Position = [col2X, rowY(3), plotLabelW, rowH];
            obj.edit_Overlap.Units = 'pixels';
            obj.edit_Overlap.Position = [col2X + plotLabelW + 2, rowY(3), plotEditW, rowH];
            % --- Presets tab ---
            obj.popup_Presets.Units = 'pixels';
            obj.popup_Presets.Position = [tabMargin, rowY(1), tabFullW, rowH];
            obj.push_LoadPreset.Units = 'pixels';
            obj.push_LoadPreset.Position = [tabMargin, rowY(2), thirdW, rowH];
            obj.push_SavePreset.Units = 'pixels';
            obj.push_SavePreset.Position = [tabMargin + thirdW + thirdGap, rowY(2), thirdW, rowH];
            obj.push_DeletePreset.Units = 'pixels';
            obj.push_DeletePreset.Position = [tabMargin + 2*(thirdW + thirdGap), rowY(2), thirdW, rowH];
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
            % --- Generate / Hold buttons below the tab group ---
            obj.push_GenerateRaster.Units = 'normalized';
            obj.push_GenerateRaster.Position = [leftX, buttonY, leftW * 0.48, buttonH];
            obj.push_Hold.Units = 'normalized';
            obj.push_Hold.Position = [leftX + leftW * 0.52, buttonY, leftW * 0.48, buttonH];
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
                'CloseRequestFcn', @(~,~) obj.hide());

            % --- Status bar ---
            obj.statusBar = StatusBar(obj.figure_Main);
            obj.statusBar.Status = 'Ready';

            % --- Axes panel ---
            obj.panel_Axes = uipanel(obj.figure_Main, ...
                'BorderType', 'none');

            obj.axes_Raster = axes(obj.panel_Axes, ...
                'Box', 'on');
            obj.axes_PSTH = axes(obj.panel_Axes, ...
                'Box', 'on');
            obj.axes_Hist = axes(obj.panel_Axes, ...
                'Box', 'on');

            % --- Left side: tab group + generate buttons ---
            obj.tab_group = uitabgroup(obj.figure_Main);

            % --- Trigger tab ---
            trigTab = uitab(obj.tab_group, 'Title', 'Trigger');
            obj.popup_TriggerSource = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Sound'}, ...
                'Callback', @(~,~) obj.clearCache());
            obj.text__TriggerType = uicontrol(trigTab, 'Style', 'text', ...
                'String', 'Type:', ...
                'Tag', 'text__TriggerType', ...
                'HorizontalAlignment', 'right');
            obj.popup_TriggerType = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Syllables', 'Markers', 'Motifs', 'Bouts'}, ...
                'Callback', @(~,~) obj.upstreamSettingChanged());
            obj.text_TriggerAlignment = uicontrol(trigTab, 'Style', 'text', ...
                'String', 'Align:', ...
                'Tag', 'text_TriggerAlignment', ...
                'HorizontalAlignment', 'right');
            obj.popup_TriggerAlignment = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'Onset', 'Offset', 'Midpoint'});
            obj.check_CopyEvents = uicontrol(trigTab, 'Style', 'checkbox', ...
                'String', 'Copy events from trigger');
            % Inline trigger filter (visible depending on type)
            obj.popup_TrigFilterMode = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'String', {'All', 'Include', 'Exclude'}, ...
                'Callback', @(~,~) obj.upstreamSettingChanged());
            obj.edit_TrigFilterList = uicontrol(trigTab, 'Style', 'edit', ...
                'String', '', 'HorizontalAlignment', 'left', ...
                'Tooltip', 'Syllable/marker labels to include or exclude', ...
                'Callback', @(~,~) obj.clearCache());

            % --- Events tab ---
            eventTab = uitab(obj.tab_group, 'Title', 'Events');
            obj.popup_EventSource = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'String', {'Sound'}, ...
                'Callback', @(~,~) obj.upstreamSettingChanged());
            obj.text_EventType = uicontrol(eventTab, 'Style', 'text', ...
                'String', 'Type:', ...
                'Tag', 'text_EventType', ...
                'HorizontalAlignment', 'right');
            obj.popup_EventType = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'String', {'Syllables', 'Markers', 'Events', 'Bursts', 'Continuous'}, ...
                'Callback', @(~,~) obj.upstreamSettingChanged());
            obj.check_CopyTrigger = uicontrol(eventTab, 'Style', 'checkbox', ...
                'String', 'Copy trigger to events');
            % Inline event filter (visible depending on type)
            obj.popup_EventFilterMode = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'String', {'All', 'Include', 'Exclude'}, ...
                'Callback', @(~,~) obj.upstreamSettingChanged());
            obj.edit_EventFilterList = uicontrol(eventTab, 'Style', 'edit', ...
                'String', '', 'HorizontalAlignment', 'left', ...
                'Tooltip', 'Syllable/marker labels to include or exclude', ...
                'Callback', @(~,~) obj.clearCache());

            % --- Window tab ---
            windowTab = uitab(obj.tab_group, 'Title', 'Window');
            % editW defined in layout constants above
            obj.text_StartReference = uicontrol(windowTab, 'Style', 'text', ...
                'String', 'Start:', ...
                'Tag', 'text_StartReference', ...
                'HorizontalAlignment', 'right');
            obj.popup_StartReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'String', {'Trigger onset', 'Trigger offset', 'Prev trigger onset', 'Prev trigger offset'}, ...
                'Callback', @(~,~) obj.clearCache());
            obj.text_StopReference = uicontrol(windowTab, 'Style', 'text', ...
                'String', 'Stop:', ...
                'Tag', 'text_StopReference', ...
                'HorizontalAlignment', 'right');
            obj.popup_StopReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'String', {'Trigger onset', 'Trigger offset', 'Next trigger onset', 'Next trigger offset'}, ...
                'Callback', @(~,~) obj.clearCache());
            obj.text_PreStart = uicontrol(windowTab, 'Style', 'text', ...
                'String', 'Pre (s):', ...
                'Tag', 'text_PreStart', ...
                'HorizontalAlignment', 'right');
            obj.edit_PreStart = uicontrol(windowTab, 'Style', 'edit', ...
                'String', num2str(obj.P.preStartRef), ...
                'Tooltip', 'Time before start reference to include (seconds)');
            obj.text_PostStop = uicontrol(windowTab, 'Style', 'text', ...
                'String', 'Post (s):', ...
                'Tag', 'text_PostStop', ...
                'HorizontalAlignment', 'right');
            obj.edit_PostStop = uicontrol(windowTab, 'Style', 'edit', ...
                'String', num2str(obj.P.postStopRef), ...
                'Tooltip', 'Time after stop reference to include (seconds)');
            obj.check_ExcludeIncomplete = uicontrol(windowTab, 'Style', 'checkbox', ...
                'String', 'Exclude incomplete', 'Value', 1);
            obj.check_ExcludePartialEvents = uicontrol(windowTab, 'Style', 'checkbox', ...
                'String', 'Exclude partial events');

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
                'String', {'All files in range', 'Only selected by search', 'Only unselected'}, ...
                'Callback', @(~,~) obj.clearCache());
            obj.text_FileRange = uicontrol(filesTab, 'Style', 'text', ...
                'String', 'Range:', ...
                'Tag', 'text_FileRange', ...
                'HorizontalAlignment', 'right');
            numFiles = electro_gui.getNumFiles(obj.eg.dbase);
            obj.edit_FileRange = uicontrol(filesTab, 'Style', 'edit', ...
                'String', ['1:', num2str(numFiles)], ...
                'Tooltip', 'MATLAB expression for file range (e.g., 1:100 or [1 5 10])');
            obj.push_Open = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'String', 'Open dbase', 'Callback', @(~,~) obj.openCallback());

            % --- PSTH tab ---
            psthTab = uitab(obj.tab_group, 'Title', 'PSTH');
            obj.text_PSTHUnits = uicontrol(psthTab, 'Style', 'text', ...
                'String', 'Units:', ...
                'Tag', 'text_PSTHUnits', ...
                'HorizontalAlignment', 'right');
            obj.popup_PSTHUnits = uicontrol(psthTab, 'Style', 'popupmenu', ...
                'String', {'Rate (Hz)', 'Count/trial', 'Total count'});
            obj.text_PSTHCount = uicontrol(psthTab, 'Style', 'text', ...
                'String', 'Count:', ...
                'Tag', 'text_PSTHCount', ...
                'HorizontalAlignment', 'right');
            obj.popup_PSTHCount = uicontrol(psthTab, 'Style', 'popupmenu', ...
                'String', {'All events', 'Selected only', 'Unselected only'});

            % --- Plot tab ---
            plotTab = uitab(obj.tab_group, 'Title', 'Plot');

            obj.text_XMin = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'X min (s):', ...
                'Tag', 'text_XMin', ...
                'HorizontalAlignment', 'right');
            obj.edit_XMin = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotXLim(1)));
            obj.text_XMax = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'X max (s):', ...
                'Tag', 'text_XMax', ...
                'HorizontalAlignment', 'right');
            obj.edit_XMax = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotXLim(2)));

            obj.text_TickHeight = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Tick height:', ...
                'Tag', 'text_TickHeight', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickHeight = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotTickSize(1)));
            obj.text_BinSize = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Bin size (s):', ...
                'Tag', 'text_BinSize', ...
                'HorizontalAlignment', 'right');
            obj.edit_BinSize = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PSTHBinSize));

            obj.text_TickLineWidth = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Line width:', ...
                'Tag', 'text_TickLineWidth', ...
                'HorizontalAlignment', 'right');
            obj.edit_TickLineWidth = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotTickSize(3)));
            obj.text_Overlap = uicontrol(plotTab, 'Style', 'text', ...
                'String', 'Overlap %:', ...
                'Tag', 'text_Overlap', ...
                'HorizontalAlignment', 'right');
            obj.edit_Overlap = uicontrol(plotTab, 'Style', 'edit', ...
                'String', num2str(obj.PlotOverlap));

            % --- Presets tab ---
            presetsTab = uitab(obj.tab_group, 'Title', 'Presets');
            obj.popup_Presets = uicontrol(presetsTab, 'Style', 'popupmenu', ...
                'String', {'(No presets found)'}, 'Enable', 'off');
            obj.push_LoadPreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Load', 'Enable', 'off', ...
                'Callback', @(~,~) obj.loadPresetCallback());
            obj.push_SavePreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Save', ...
                'Callback', @(~,~) obj.savePresetCallback());
            obj.push_DeletePreset = uicontrol(presetsTab, 'Style', 'pushbutton', ...
                'String', 'Delete', 'Enable', 'off', ...
                'Callback', @(~,~) obj.deletePresetCallback());

            % --- Export tab ---
            exportTab = uitab(obj.tab_group, 'Title', 'Export');
            obj.push_ExportFigure = uicontrol(exportTab, 'Style', 'pushbutton', ...
                'String', 'Export to new figure', ...
                'Callback', @(~,~) obj.exportToFigure());
            obj.text_ExportToFile = uicontrol(exportTab, 'Style', 'text', ...
                'String', 'Export to file:', ...
                'Tag', 'text_ExportToFile', ...
                'HorizontalAlignment', 'left', 'FontWeight', 'bold');
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

            % --- Generate / Hold buttons below the tab group ---
            obj.push_GenerateRaster = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'String', 'Generate', ...
                'FontWeight', 'bold', ...
                'Callback', @(~,~) obj.generate());
            obj.push_Hold = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'String', 'Hold on', ...
                'Callback', @(~,~) obj.holdCallback());
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
            obj.popup_EventSource.String = sourceStrings;

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
            cla(ax);
            hold(ax, 'on');

            % Trial y-positions (trial 1 at top)
            trialY = 1:numTrials;

            % Tick height: each trial spans 1 unit, ticks fill most of it
            tickHalfHeight = 0.4;
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
                    'PickableParts', 'none', 'HitTest', 'off');
            end

            % --- Plot event ticks (vectorized as a single plot call) ---
            obj.statusBar.Status = 'Plotting event ticks...';
            obj.statusBar.Progress = 0.85;
            drawnow;
            eventColor = [0, 0, 0];  % Black
            % Pre-allocate: count total events across all trials
            totalEvents = sum(cellfun(@length, ti.eventOnsets));
            if totalEvents > 0
                allX = NaN(3 * totalEvents, 1);
                allY = NaN(3 * totalEvents, 1);
                idx = 0;
                for trialIdx = 1:numTrials
                    eventTimes = ti.eventOnsets{trialIdx};
                    nEvents = length(eventTimes);
                    if nEvents > 0
                        yBottom = trialY(trialIdx) - tickHalfHeight;
                        yTop = trialY(trialIdx) + tickHalfHeight;
                        range = idx + (1:3*nEvents);
                        allX(range) = reshape([eventTimes(:)'; eventTimes(:)'; NaN(1, nEvents)], [], 1);
                        allY(range) = reshape([repmat(yBottom, 1, nEvents); repmat(yTop, 1, nEvents); NaN(1, nEvents)], [], 1);
                        idx = idx + 3 * nEvents;
                    end
                end
                plot(ax, allX, allY, 'Color', eventColor, 'LineWidth', 0.5);
            end

            % --- Plot zero line (trigger alignment point) ---
            plot(ax, [0, 0], [0.5, numTrials + 0.5], '--', ...
                'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.5, ...
                'PickableParts', 'none', 'HitTest', 'off');

            % --- Axes formatting ---
            ax.YDir = 'reverse';
            ax.YLim = [0.5, numTrials + 0.5];
            ax.XLim = obj.PlotXLim;
            ax.YLabel.String = 'Trial';
            ax.XLabel.String = 'Time (s)';
            ax.Box = 'on';
            title(ax, sprintf('%d trials', numTrials));
            hold(ax, 'off');
        end

        function plotPSTH(obj)
            % Render the peri-stimulus time histogram from triggerInfo.
            arguments
                obj RasterGUI
            end
            ti = obj.triggerInfo;
            numTrials = length(ti.absTime);
            if numTrials == 0
                return;
            end

            ax = obj.axes_PSTH;
            cla(ax);
            hold(ax, 'on');

            % Collect all event times across trials
            allEventTimes = cat(1, ti.eventOnsets{:});

            if isempty(allEventTimes)
                hold(ax, 'off');
                return;
            end

            % Bin edges
            binSize = obj.PSTHBinSize;
            binEdges = obj.PlotXLim(1):binSize:obj.PlotXLim(2);
            if isempty(binEdges) || length(binEdges) < 2
                hold(ax, 'off');
                return;
            end

            % Compute histogram
            counts = histcounts(allEventTimes, binEdges);
            binCenters = (binEdges(1:end-1) + binEdges(2:end)) / 2;

            % Convert to the selected units
            psthUnitStrs = obj.popup_PSTHUnits.String;
            psthUnit = psthUnitStrs{obj.popup_PSTHUnits.Value};
            switch psthUnit
                case 'Rate (Hz)'
                    psthValues = counts / (numTrials * binSize);
                    yLabel = 'Firing rate (Hz)';
                case 'Count/trial'
                    psthValues = counts / numTrials;
                    yLabel = 'Count/trial';
                case 'Total count'
                    psthValues = counts;
                    yLabel = 'Total count';
                otherwise
                    psthValues = counts / (numTrials * binSize);
                    yLabel = 'Rate (Hz)';
            end

            % Smooth if requested
            if obj.PSTHSmoothingWindow > 1
                psthValues = movmean(psthValues, obj.PSTHSmoothingWindow);
            end

            % Plot as bar chart
            bar(ax, binCenters, psthValues, 1, ...
                'FaceColor', [0.3, 0.3, 0.3], 'EdgeColor', 'none');

            % Zero line
            plot(ax, [0, 0], ax.YLim, '--', ...
                'Color', [0.5, 0.5, 0.5], 'LineWidth', 0.5, ...
                'PickableParts', 'none', 'HitTest', 'off');

            % Formatting
            ax.XLim = obj.PlotXLim;
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
            numTrials = length(ti.absTime);
            if numTrials == 0
                return;
            end

            ax = obj.axes_Hist;
            cla(ax);
            hold(ax, 'on');

            % Count events per trial within the visible X range
            xLim = obj.PlotXLim;
            countsPerTrial = zeros(numTrials, 1);
            for trialIdx = 1:numTrials
                eventTimes = ti.eventOnsets{trialIdx};
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

            % Match Y axis to raster
            ax.YDir = 'reverse';
            ax.YLim = [0.5, numTrials + 0.5];
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
            preset.copyEvents = obj.check_CopyEvents.Value;

            % Event settings
            eventSourceStrs = obj.popup_EventSource.String;
            preset.eventSource = eventSourceStrs{obj.popup_EventSource.Value};
            eventTypeStrs = obj.popup_EventType.String;
            preset.eventType = eventTypeStrs{obj.popup_EventType.Value};
            preset.copyTrigger = obj.check_CopyTrigger.Value;

            % Window settings
            startRefStrs = obj.popup_StartReference.String;
            preset.startReference = startRefStrs{obj.popup_StartReference.Value};
            stopRefStrs = obj.popup_StopReference.String;
            preset.stopReference = stopRefStrs{obj.popup_StopReference.Value};
            preset.excludeIncomplete = obj.check_ExcludeIncomplete.Value;
            preset.excludePartialEvents = obj.check_ExcludePartialEvents.Value;

            % Sort settings
            primarySortStrs = obj.popup_PrimarySort.String;
            preset.primarySort = primarySortStrs{obj.popup_PrimarySort.Value};
            secondarySortStrs = obj.popup_SecondarySort.String;
            preset.secondarySort = secondarySortStrs{obj.popup_SecondarySort.Value};
            preset.ascending = obj.radio_Ascending.Value;
            preset.groupLabels = obj.check_GroupLabels.Value;

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
            obj.setCheckbox(obj.check_CopyEvents, preset, 'copyEvents');

            obj.setPopupByName(obj.popup_EventSource, preset, 'eventSource');
            obj.setPopupByName(obj.popup_EventType, preset, 'eventType');
            obj.setCheckbox(obj.check_CopyTrigger, preset, 'copyTrigger');

            obj.setPopupByName(obj.popup_StartReference, preset, 'startReference');
            obj.setPopupByName(obj.popup_StopReference, preset, 'stopReference');
            obj.setCheckbox(obj.check_ExcludeIncomplete, preset, 'excludeIncomplete');
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
                'Delete Preset', 'Delete', 'Cancel', 'Cancel');
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
            if ~strcmp(secondarySortType, '(None)')
                ti = RasterGUI.sortTriggers(ti, secondarySortType, descending, ...
                    obj.P.event.filterList, false);
            end
            if ~strcmp(primarySortType, '(None)')
                ti = RasterGUI.sortTriggers(ti, primarySortType, descending, ...
                    obj.P.event.filterList, groupLabels);
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
                obj.check_CopyEvents, ...
                obj.popup_TrigFilterMode, ...
                obj.edit_TrigFilterList, ...
                obj.popup_EventSource, ...
                obj.popup_EventType, ...
                obj.check_CopyTrigger, ...
                obj.popup_EventFilterMode, ...
                obj.edit_EventFilterList, ...
                obj.popup_StartReference, ...
                obj.popup_StopReference, ...
                obj.edit_PreStart, ...
                obj.edit_PostStop, ...
                obj.check_ExcludeIncomplete, ...
                obj.check_ExcludePartialEvents, ...
                obj.popup_PrimarySort, ...
                obj.popup_SecondarySort, ...
                obj.radio_Ascending, ...
                obj.radio_Descending, ...
                obj.check_GroupLabels, ...
                obj.popup_Files, ...
                obj.edit_FileRange, ...
                obj.push_Open, ...
                obj.popup_PSTHUnits, ...
                obj.popup_PSTHCount, ...
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
                obj.push_ExportFigure, ...
                obj.push_ExportPNG, ...
                obj.push_ExportPDF, ...
                obj.push_ExportJPG, ...
                obj.push_ExportSVG, ...
                obj.push_GenerateRaster, ...
                obj.push_Hold];
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

            % Trigger include/ignore: only when type needs them
            obj.updateTriggerOptionsVisibility();

            % Event include/ignore: only when type needs them
            obj.updateEventOptionsVisibility();

            % Preset Load/Delete: only when presets exist
            presetNames = obj.popup_Presets.String;
            hasPresets = ~isempty(presetNames) && ~strcmp(presetNames{1}, '(No presets found)');
            if ~hasPresets
                obj.popup_Presets.Enable = 'off';
                obj.push_LoadPreset.Enable = 'off';
                obj.push_DeletePreset.Enable = 'off';
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
        function updateEventOptionsVisibility(obj)
            % Show/hide event filter controls based on the selected type.
            arguments
                obj RasterGUI
            end
            eventTypeStrs = obj.popup_EventType.String;
            eventType = eventTypeStrs{obj.popup_EventType.Value};
            showFilter = ismember(eventType, {'Syllables', 'Markers', 'Bouts'});
            onOff = {'off', 'on'};
            vis = onOff{showFilter + 1};
            obj.popup_EventFilterMode.Visible = vis;
            obj.edit_EventFilterList.Visible = vis;
            % Disable text field when mode is "All"
            eventModes = obj.popup_EventFilterMode.String;
            isAll = strcmp(eventModes{obj.popup_EventFilterMode.Value}, 'All');
            obj.edit_EventFilterList.Enable = onOff{~isAll + 1};
        end
        function syncOptionsFromGUI(obj)
            % Read all inline option controls into properties before generating.
            arguments
                obj RasterGUI
            end

            % Trigger/Event filter
            trigModes = obj.popup_TrigFilterMode.String;
            obj.P.trig.filterMode = trigModes{obj.popup_TrigFilterMode.Value};
            obj.P.trig.filterList = obj.edit_TrigFilterList.String;
            eventModes = obj.popup_EventFilterMode.String;
            obj.P.event.filterMode = eventModes{obj.popup_EventFilterMode.Value};
            obj.P.event.filterList = obj.edit_EventFilterList.String;

            % Copy if linked
            if obj.check_CopyTrigger.Value
                obj.P.trig = obj.P.event;
            end
            if obj.check_CopyEvents.Value
                obj.P.event = obj.P.trig;
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

            % Plot settings
            obj.PlotXLim = [str2double(obj.edit_XMin.String), str2double(obj.edit_XMax.String)];
            obj.PlotTickSize(1) = str2double(obj.edit_TickHeight.String);
            obj.PlotTickSize(3) = str2double(obj.edit_TickLineWidth.String);
            obj.PSTHBinSize = str2double(obj.edit_BinSize.String);
            obj.PlotOverlap = str2double(obj.edit_Overlap.String);
        end
        function upstreamSettingChanged(obj)
            % Called when any upstream setting changes (trigger/event
            % source/type, window, file range, include/ignore lists).
            % Clears the cache and updates control states.
            arguments
                obj RasterGUI
            end
            obj.clearCache();
            obj.updateControlStates();
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
        function openCallback(obj) %#ok<MANU>
            % TODO: Port open dbase functionality
            arguments
                obj RasterGUI
            end

        end
        function holdCallback(obj)
            arguments
                obj RasterGUI
            end
            if strcmp(obj.push_Hold.String, 'Hold on')
                obj.push_Hold.String = 'Hold off';
            else
                obj.push_Hold.String = 'Hold on';
            end
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

                switch eventTypeStr
                    case 'Events'
                        % Get selected events across all event parts
                        selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                        for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                            selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                        end
                        selectedIndices = find(selectedMask);
                        allPartTimes = dbase.EventTimes{eventSourceIdx}{1, filenum}(selectedIndices);
                        for partIdx = 2:size(dbase.EventTimes{eventSourceIdx}, 1)
                            allPartTimes = [allPartTimes, dbase.EventTimes{eventSourceIdx}{partIdx, filenum}(selectedIndices)]; %#ok<AGROW>
                        end
                        ons{fileListIdx} = min(allPartTimes, [], 2);
                        offs{fileListIdx} = max(allPartTimes, [], 2);
                        inform.label{fileListIdx} = zeros(size(allPartTimes, 1), 1);

                    case 'Bursts'
                        % Find bursts based on inter-event frequency
                        selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                        for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                            selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                        end
                        selectedIndices = find(selectedMask);
                        allPartTimes = dbase.EventTimes{eventSourceIdx}{1, filenum}(selectedIndices);
                        for partIdx = 2:size(dbase.EventTimes{eventSourceIdx}, 1)
                            allPartTimes = [allPartTimes, dbase.EventTimes{eventSourceIdx}{partIdx, filenum}(selectedIndices)]; %#ok<AGROW>
                        end
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
                        selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                        for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                            selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                        end
                        selectedIndices = find(selectedMask);
                        allPartTimes = dbase.EventTimes{eventSourceIdx}{1, filenum}(selectedIndices);
                        for partIdx = 2:size(dbase.EventTimes{eventSourceIdx}, 1)
                            allPartTimes = [allPartTimes, dbase.EventTimes{eventSourceIdx}{partIdx, filenum}(selectedIndices)]; %#ok<AGROW>
                        end
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
                        selectedMask = dbase.EventIsSelected{eventSourceIdx}{1, filenum} == 1;
                        for partIdx = 2:size(dbase.EventIsSelected{eventSourceIdx}, 1)
                            selectedMask = selectedMask & (dbase.EventIsSelected{eventSourceIdx}{partIdx, filenum} == 1);
                        end
                        selectedIndices = find(selectedMask);
                        allPartTimes = dbase.EventTimes{eventSourceIdx}{1, filenum}(selectedIndices);
                        for partIdx = 2:size(dbase.EventTimes{eventSourceIdx}, 1)
                            allPartTimes = [allPartTimes, dbase.EventTimes{eventSourceIdx}{partIdx, filenum}(selectedIndices)]; %#ok<AGROW>
                        end
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
                            selectedIndices = find(selection == 1);
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
                            selectedIndices = find(dbase.SegmentIsSelected{filenum} == 1);
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
                            selectedIndices = find(dbase.SegmentIsSelected{filenum} == 1);

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
                    timestamp = obj.eg.getFileTime(filenum);
                    absTime = timestamp + alignSample / (fs * 24 * 60 * 60);

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
                    filterCodes = double(filterList);
                    keepMask = ismember(labels, filterCodes);
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
