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

        % Trigger panel
        popup_TriggerSource
        popup_TriggerType
        popup_TriggerAlignment
        push_TriggerOptions
        check_CopyEvents

        % Event panel
        popup_EventSource
        popup_EventType
        push_EventOptions
        check_CopyTrigger

        % Window panel
        popup_StartReference
        popup_StopReference
        push_WindowLimits
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
        push_FileRange
        push_Open

        % Control buttons
        push_GenerateRaster
        push_Hold

        % PSTH panel
        popup_PSTHUnits
        popup_PSTHCount

        % Plot options
        list_PlotOptions
        push_PlotColor
        check_PlotShow
        push_PlotXLim
        push_PlotTickSize
    end

    %% Properties - state
    properties (Access = private)
        % Data
        triggerInfo struct = struct()  % Output of trigger alignment
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
            if isempty(obj.figure_Main) || ~isvalid(obj.figure_Main)
                obj.buildGUI();
                obj.populateSourceMenus();
            end
            obj.figure_Main.Visible = 'on';
            figure(obj.figure_Main);  % Bring to front
        end

        function hide(obj)
            % Hide the raster GUI window without destroying it.
            if ~isempty(obj.figure_Main) && isvalid(obj.figure_Main)
                obj.figure_Main.Visible = 'off';
            end
        end

        function generate(obj)
            % Generate the raster plot with current settings.
            % This is the main entry point that runs the full pipeline:
            % extract triggers -> align events -> filter -> sort -> warp -> plot

            if ~electro_gui.isDataLoaded(obj.eg.dbase)
                warndlg('No data loaded in electro_gui.');
                return;
            end

            obj.push_GenerateRaster.ForegroundColor = 'r';
            drawnow;

            try
                % --- Step 1: Get trigger times ---
                trigSourceIdx = obj.popup_TriggerSource.Value - 1;  % 0 = Sound
                trigTypeStrs = obj.popup_TriggerType.String;
                trigTypeStr = trigTypeStrs{obj.popup_TriggerType.Value};
                [trig.on, trig.off, trig.info, ~] = obj.getEventStructure( ...
                    trigSourceIdx, trigTypeStr, obj.P.trig);

                % --- Step 2: Get event times ---
                eventSourceIdx = obj.popup_EventSource.Value - 1;
                eventTypeStrs = obj.popup_EventType.String;
                eventTypeStr = eventTypeStrs{obj.popup_EventType.Value};
                [event.on, event.off, event.info, ~] = obj.getEventStructure( ...
                    eventSourceIdx, eventTypeStr, obj.P.event);

                % --- Step 3: Align events to triggers ---
                ti = obj.alignEventsToTriggers(trig, event);

                if isempty(ti) || ~isfield(ti, 'absTime') || isempty(ti.absTime)
                    warndlg('No triggers found!', 'Error');
                    obj.push_GenerateRaster.ForegroundColor = 'k';
                    return;
                end

                % --- Step 4: Sort triggers ---
                primarySortStrs = obj.popup_PrimarySort.String;
                primarySortType = primarySortStrs{obj.popup_PrimarySort.Value};
                descending = obj.radio_Descending.Value;
                groupLabels = obj.check_GroupLabels.Value;

                if ~strcmp(primarySortType, '(None)')
                    ti = RasterGUI.sortTriggers(ti, primarySortType, descending, ...
                        obj.P.event.includeSyllList, groupLabels);
                end

                % Secondary sort (applied first so primary sort is dominant)
                secondarySortStrs = obj.popup_SecondarySort.String;
                secondarySortType = secondarySortStrs{obj.popup_SecondarySort.Value};
                if ~strcmp(secondarySortType, '(None)')
                    % Re-sort: secondary first, then primary
                    [event.on, event.off, event.info, ~] = obj.getEventStructure( ...
                        eventSourceIdx, eventTypeStr, obj.P.event);
                    ti = obj.alignEventsToTriggers(trig, event);
                    ti = RasterGUI.sortTriggers(ti, secondarySortType, descending, ...
                        obj.P.event.includeSyllList, false);
                    if ~strcmp(primarySortType, '(None)')
                        ti = RasterGUI.sortTriggers(ti, primarySortType, descending, ...
                            obj.P.event.includeSyllList, groupLabels);
                    end
                end

                obj.triggerInfo = ti;

                % --- Step 5: Plot ---
                obj.plotRaster();
                obj.plotPSTH();

            catch ME
                warndlg(sprintf('Error generating raster: %s', ME.message), 'Error');
                rethrow(ME);
            end

            obj.push_GenerateRaster.ForegroundColor = 'k';
        end
    end

    %% GUI construction
    methods (Access = private)
        function initializeParameters(obj)
            % Initialize the default parameter structure
            obj.P.trig.includeSyllList = '';
            obj.P.trig.ignoreSyllList = '';
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

        function buildGUI(obj)
            % Programmatically create the raster GUI figure and all widgets.

            % --- Layout constants ---
            % Left control panel
            leftX = 0.005;                  % Left edge of control panel
            leftW = 0.215;                  % Width of control panel
            buttonY = 0.02;                 % Y position of Generate/Hold buttons
            buttonH = 0.08;                 % Height of Generate/Hold buttons
            tabGroupY = buttonY + buttonH + 0.01;  % Tab group starts above buttons
            tabGroupH = 0.97 - tabGroupY;   % Tab group fills to top

            % Main axes
            axesX = leftX + leftW + 0.01;   % Axes start right of control panel
            rasterY = 0.30;                 % Raster axes bottom
            rasterH = 0.47;                 % Raster axes height
            psthY = 0.05;                   % PSTH axes bottom
            psthH = rasterY - psthY - 0.05; % PSTH fills gap below raster
            axesW = 0.41;                   % Width of raster and PSTH axes
            histX = axesX + axesW + 0.03;   % Histogram axes start right of main axes
            histW = 0.10;                   % Histogram axes width

            % Right side controls
            rightX = 0.80;
            rightW = 0.19;

            % Tab content layout (shared across all tabs)
            tabMargin = 0.02;              % Left/right margin inside tabs
            tabFullW = 1 - 2 * tabMargin;  % Full width minus margins
            rowH = 0.06;                   % Row height for controls
            row1Y = 0.88;                  % Y positions for rows 1-5
            row2Y = 0.80;
            row3Y = 0.72;
            row4Y = 0.64;
            row5Y = 0.56;
            labelW = 0.25;                 % Width of text labels (Type:, Align:, etc.)
            popupAfterLabelX = tabMargin + labelW + 0.02;  % Popup x after standard label
            popupAfterLabelW = 0.44;       % Popup width after standard label
            optionsBtnX = 0.75;            % Options button x
            optionsBtnW = 0.23;            % Options button width

            % Sort tab label column (wider labels)
            sortLabelW = 0.30;
            sortPopupX = tabMargin + sortLabelW + 0.02;
            sortPopupW = 1 - sortPopupX - tabMargin;

            % Window tab label column (narrower labels)
            winLabelW = 0.20;
            winPopupX = tabMargin + winLabelW + 0.02;
            winPopupW = 1 - winPopupX - tabMargin;

            % --- Figure ---
            obj.figure_Main = figure( ...
                'Name', 'Sorted Raster Plots', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Units', 'normalized', ...
                'Position', [0.025, 0.05, 0.95, 0.9], ...
                'Visible', 'off', ...
                'CloseRequestFcn', @(~,~) obj.hide());

            % --- Main axes ---
            obj.axes_Raster = axes(obj.figure_Main, ...
                'Position', [axesX, rasterY, axesW, rasterH], ...
                'Box', 'on');
            obj.axes_PSTH = axes(obj.figure_Main, ...
                'Position', [axesX, psthY, axesW, psthH], ...
                'Box', 'on');
            obj.axes_Hist = axes(obj.figure_Main, ...
                'Position', [histX, rasterY, histW, rasterH], ...
                'Box', 'on');

            obj.AxisPosRaster = obj.axes_Raster.Position;
            obj.AxisPosPSTH = obj.axes_PSTH.Position;
            obj.AxisPosHist = obj.axes_Hist.Position;

            % --- Left side: tab group + generate buttons ---
            tabGroup = uitabgroup(obj.figure_Main, ...
                'Units', 'normalized', ...
                'Position', [leftX, tabGroupY, leftW, tabGroupH]);

            % --- Trigger tab ---
            trigTab = uitab(tabGroup, 'Title', 'Trigger');
            obj.popup_TriggerSource = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [tabMargin, row1Y, tabFullW, rowH], ...
                'String', {'Sound'});
            uicontrol(trigTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row2Y, labelW, rowH], ...
                'String', 'Type:', 'HorizontalAlignment', 'right');
            obj.popup_TriggerType = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [popupAfterLabelX, row2Y, popupAfterLabelW, rowH], ...
                'String', {'Syllables', 'Markers', 'Motifs', 'Bouts'});
            obj.push_TriggerOptions = uicontrol(trigTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [optionsBtnX, row2Y, optionsBtnW, rowH], ...
                'String', 'Options', 'Callback', @(~,~) obj.triggerOptionsCallback());
            uicontrol(trigTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row3Y, labelW, rowH], ...
                'String', 'Align:', 'HorizontalAlignment', 'right');
            obj.popup_TriggerAlignment = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [popupAfterLabelX, row3Y, popupAfterLabelW, rowH], ...
                'String', {'Onset', 'Offset', 'Midpoint'});
            obj.check_CopyEvents = uicontrol(trigTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [tabMargin, row4Y, tabFullW, rowH], ...
                'String', 'Copy events from trigger');

            % --- Events tab ---
            eventTab = uitab(tabGroup, 'Title', 'Events');
            obj.popup_EventSource = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [tabMargin, row1Y, tabFullW, rowH], ...
                'String', {'Sound'});
            uicontrol(eventTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row2Y, labelW, rowH], ...
                'String', 'Type:', 'HorizontalAlignment', 'right');
            obj.popup_EventType = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [popupAfterLabelX, row2Y, popupAfterLabelW, rowH], ...
                'String', {'Syllables', 'Markers', 'Events', 'Bursts', 'Continuous'});
            obj.push_EventOptions = uicontrol(eventTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [optionsBtnX, row2Y, optionsBtnW, rowH], ...
                'String', 'Options', 'Callback', @(~,~) obj.eventOptionsCallback());
            obj.check_CopyTrigger = uicontrol(eventTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [tabMargin, row3Y, tabFullW, rowH], ...
                'String', 'Copy trigger to events');

            % --- Window tab ---
            windowTab = uitab(tabGroup, 'Title', 'Window');
            uicontrol(windowTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row1Y, winLabelW, rowH], ...
                'String', 'Start:', 'HorizontalAlignment', 'right');
            obj.popup_StartReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [winPopupX, row1Y, winPopupW, rowH], ...
                'String', {'Trigger onset', 'Trigger offset', 'Prev trigger onset', 'Prev trigger offset'});
            uicontrol(windowTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row2Y, winLabelW, rowH], ...
                'String', 'Stop:', 'HorizontalAlignment', 'right');
            obj.popup_StopReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [winPopupX, row2Y, winPopupW, rowH], ...
                'String', {'Trigger onset', 'Trigger offset', 'Next trigger onset', 'Next trigger offset'});
            obj.push_WindowLimits = uicontrol(windowTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [tabMargin, row3Y, 0.30, rowH], ...
                'String', 'Limits', 'Callback', @(~,~) obj.windowLimitsCallback());
            obj.check_ExcludeIncomplete = uicontrol(windowTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [tabMargin, row4Y, tabFullW, rowH], ...
                'String', 'Exclude incomplete', 'Value', 1);
            obj.check_ExcludePartialEvents = uicontrol(windowTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [tabMargin, row5Y, tabFullW, rowH], ...
                'String', 'Exclude partial events');

            % --- Sort tab ---
            sortTab = uitab(tabGroup, 'Title', 'Sort');
            uicontrol(sortTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row1Y, sortLabelW, rowH], ...
                'String', 'Primary:', 'HorizontalAlignment', 'right');
            obj.popup_PrimarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [sortPopupX, row1Y, sortPopupW, rowH], ...
                'String', obj.getSortOptions());
            uicontrol(sortTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [tabMargin, row2Y, sortLabelW, rowH], ...
                'String', 'Secondary:', 'HorizontalAlignment', 'right');
            obj.popup_SecondarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [sortPopupX, row2Y, sortPopupW, rowH], ...
                'String', obj.getSortOptions());
            obj.radio_Ascending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'Units', 'normalized', 'Position', [tabMargin, row3Y, 0.45, rowH], ...
                'String', 'Ascending', 'Value', 1, ...
                'Callback', @(~,~) set(obj.radio_Descending, 'Value', 0));
            obj.radio_Descending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'Units', 'normalized', 'Position', [0.50, row3Y, 0.48, rowH], ...
                'String', 'Descending', 'Value', 0, ...
                'Callback', @(~,~) set(obj.radio_Ascending, 'Value', 0));
            obj.check_GroupLabels = uicontrol(sortTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [tabMargin, row4Y, tabFullW, rowH], ...
                'String', 'Group by label');

            % --- Files tab ---
            filesTab = uitab(tabGroup, 'Title', 'Files');
            obj.popup_Files = uicontrol(filesTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [tabMargin, row1Y, tabFullW, rowH], ...
                'String', {'All files in range', 'Only selected by search', 'Only unselected'});
            obj.push_FileRange = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [tabMargin, row2Y, 0.48, rowH], ...
                'String', 'File range', 'Callback', @(~,~) obj.fileRangeCallback());
            obj.push_Open = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.52, row2Y, 0.46, rowH], ...
                'String', 'Open dbase', 'Callback', @(~,~) obj.openCallback());

            % --- Generate / Hold buttons below the tab group ---
            obj.push_GenerateRaster = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [leftX, buttonY, leftW * 0.48, buttonH], ...
                'String', 'Generate', ...
                'FontWeight', 'bold', ...
                'Callback', @(~,~) obj.generate());
            obj.push_Hold = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [leftX + leftW * 0.52, buttonY, leftW * 0.48, buttonH], ...
                'String', 'Hold on', ...
                'Callback', @(~,~) obj.holdCallback());

            % --- Right side controls ---
            obj.push_PlotXLim = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [rightX, 0.92, rightW * 0.48, 0.04], ...
                'String', 'X Limits', ...
                'Callback', @(~,~) obj.plotXLimCallback());
            obj.push_PlotTickSize = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [rightX + rightW * 0.52, 0.92, rightW * 0.48, 0.04], ...
                'String', 'Tick size', ...
                'Callback', @(~,~) obj.plotTickSizeCallback());

            % PSTH controls
            psthPanel = uipanel(obj.figure_Main, 'Title', 'PSTH', ...
                'Units', 'normalized', 'Position', [rightX, buttonY, rightW, 0.12]);
            obj.popup_PSTHUnits = uicontrol(psthPanel, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [tabMargin, 0.55, tabFullW, 0.38], ...
                'String', {'Rate (Hz)', 'Count/trial', 'Total count'});
            obj.popup_PSTHCount = uicontrol(psthPanel, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [tabMargin, 0.10, tabFullW, 0.38], ...
                'String', {'All events', 'Selected only', 'Unselected only'});
        end

        function populateSourceMenus(obj)
            % Populate the trigger and event source dropdown menus from
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
            ti = obj.triggerInfo;
            numTrials = length(ti.absTime);
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

            % --- Plot trigger boxes (current trigger onset-offset) ---
            trigColor = [1.0, 0.85, 0.85];  % Light red
            for trialIdx = 1:numTrials
                trigOn = ti.currTrigOnset(trialIdx);
                trigOff = ti.currTrigOffset(trialIdx);
                if isfinite(trigOn) && isfinite(trigOff)
                    patch(ax, ...
                        [trigOn, trigOff, trigOff, trigOn], ...
                        [trialY(trialIdx) - tickHalfHeight, trialY(trialIdx) - tickHalfHeight, ...
                         trialY(trialIdx) + tickHalfHeight, trialY(trialIdx) + tickHalfHeight], ...
                        trigColor, 'EdgeColor', 'none', ...
                        'PickableParts', 'none', 'HitTest', 'off');
                end
            end

            % --- Plot event ticks ---
            eventColor = [0, 0, 0];  % Black
            for trialIdx = 1:numTrials
                eventTimes = ti.eventOnsets{trialIdx};
                if ~isempty(eventTimes)
                    yBottom = trialY(trialIdx) - tickHalfHeight;
                    yTop = trialY(trialIdx) + tickHalfHeight;
                    % Vectorized line drawing: NaN-separated segments
                    xCoords = [eventTimes(:)'; eventTimes(:)'; NaN(1, length(eventTimes))];
                    yCoords = [repmat(yBottom, 1, length(eventTimes)); ...
                               repmat(yTop, 1, length(eventTimes)); ...
                               NaN(1, length(eventTimes))];
                    plot(ax, xCoords(:), yCoords(:), 'Color', eventColor, 'LineWidth', 0.5);
                end
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
    end

    %% Callback stubs
    methods (Access = private)
        function triggerOptionsCallback(obj)
            % TODO: Port edit_Options dialog for trigger parameters
        end
        function eventOptionsCallback(obj)
            % TODO: Port edit_Options dialog for event parameters
        end
        function windowLimitsCallback(obj)
            answer = inputdlg({'Pre-start (s)', 'Post-stop (s)'}, 'Window limits', 1, ...
                {num2str(obj.P.preStartRef), num2str(obj.P.postStopRef)});
            if ~isempty(answer)
                obj.P.preStartRef = str2double(answer{1});
                obj.P.postStopRef = str2double(answer{2});
            end
        end
        function fileRangeCallback(obj)
            numFiles = electro_gui.getNumFiles(obj.eg.dbase);
            answer = inputdlg({'File range'}, 'File range', 1, ...
                {['1:', num2str(numFiles)]});
            if ~isempty(answer)
                obj.FileRange = eval(answer{1});
            end
        end
        function openCallback(obj)
            % TODO: Port open dbase functionality
        end
        function holdCallback(obj)
            if strcmp(obj.push_Hold.String, 'Hold on')
                obj.push_Hold.String = 'Hold off';
            else
                obj.push_Hold.String = 'Hold on';
            end
        end
        function plotXLimCallback(obj)
            answer = inputdlg({'X min (s)', 'X max (s)'}, 'Plot X limits', 1, ...
                {num2str(obj.PlotXLim(1)), num2str(obj.PlotXLim(2))});
            if ~isempty(answer)
                obj.PlotXLim = [str2double(answer{1}), str2double(answer{2})];
            end
        end
        function plotTickSizeCallback(obj)
            answer = inputdlg( ...
                {'Raster tick height', 'PSTH bin size (s)', 'Tick line width', 'Overlap %'}, ...
                'Tick size', 1, ...
                {num2str(obj.PlotTickSize(1)), num2str(obj.PSTHBinSize), ...
                 num2str(obj.PlotTickSize(3)), num2str(obj.PlotOverlap)});
            if ~isempty(answer)
                obj.PlotTickSize(1) = str2double(answer{1});
                obj.PSTHBinSize = str2double(answer{2});
                obj.PlotTickSize(3) = str2double(answer{3});
                obj.PlotOverlap = str2double(answer{4});
            end
        end
    end

    %% Core algorithms (ported from egm_Sorted_rasters)
    methods (Access = private)
        function [ons, offs, inform, lst] = getEventStructure(obj, eventSourceIdx, eventTypeStr, P)
            % Extract triggers or events from the dbase across files.
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
                        gapOnsets = [min(allPartTimes, [], 2); dbase.FileLength(filenum) + fs * P.pauseMinDuration];
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

                            % Apply include list
                            includeList = P.includeSyllList;
                            escapeIdx = strfind(includeList, '''''');
                            includeList([escapeIdx, escapeIdx + 1]) = [];
                            includeList = double(includeList);
                            if ~isempty(escapeIdx)
                                includeList = [includeList, 0]; %#ok<AGROW>
                            end
                            if ~isempty(includeList)
                                keepIdx = [];
                                for k = 1:length(includeList)
                                    keepIdx = union(keepIdx, find(labels == includeList(k)));
                                end
                                ons{fileListIdx} = ons{fileListIdx}(keepIdx);
                                offs{fileListIdx} = offs{fileListIdx}(keepIdx);
                                inform.label{fileListIdx} = inform.label{fileListIdx}(keepIdx);
                            end

                            % Apply ignore list
                            ignoreList = P.ignoreSyllList;
                            escapeIdx = strfind(ignoreList, '''''');
                            ignoreList([escapeIdx, escapeIdx + 1]) = [];
                            ignoreList = double(ignoreList);
                            if ~isempty(escapeIdx)
                                ignoreList = [ignoreList, 0]; %#ok<AGROW>
                            end
                            if ~isempty(ignoreList)
                                removeIdx = [];
                                for k = 1:length(ignoreList)
                                    removeIdx = union(removeIdx, find(inform.label{fileListIdx} == ignoreList(k)));
                                end
                                ons{fileListIdx}(removeIdx) = [];
                                offs{fileListIdx}(removeIdx) = [];
                                inform.label{fileListIdx}(removeIdx) = [];
                            end
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
                                ons{fileListIdx} = [ons{fileListIdx}; syllOnsets(matchStarts)]; %#ok<AGROW>
                                offs{fileListIdx} = [offs{fileListIdx}; syllOffsets(matchEnds)]; %#ok<AGROW>
                                inform.label{fileListIdx} = [inform.label{fileListIdx}; motifIdx * ones(length(matchStarts), 1)]; %#ok<AGROW>
                            end
                            inform.label{fileListIdx} = 1000 + inform.label{fileListIdx};
                        end

                    case 'Bouts'
                        if ~isempty(dbase.SegmentTimes{filenum})
                            selectedIndices = find(dbase.SegmentIsSelected{filenum} == 1);

                            % Apply include/ignore lists to filter syllables
                            labels = zeros(1, length(selectedIndices));
                            for labelIdx = 1:length(labels)
                                if ~isempty(dbase.SegmentTitles{filenum}{selectedIndices(labelIdx)})
                                    labels(labelIdx) = double(dbase.SegmentTitles{filenum}{selectedIndices(labelIdx)});
                                end
                            end
                            includeList = P.includeSyllList;
                            escapeIdx = strfind(includeList, '''''');
                            includeList([escapeIdx, escapeIdx + 1]) = [];
                            includeList = double(includeList);
                            if ~isempty(escapeIdx)
                                includeList = [includeList, 0]; %#ok<AGROW>
                            end
                            if ~isempty(includeList)
                                keepIdx = [];
                                for k = 1:length(includeList)
                                    keepIdx = union(keepIdx, find(labels == includeList(k)));
                                end
                                selectedIndices = selectedIndices(keepIdx);
                            end
                            ignoreList = P.ignoreSyllList;
                            escapeIdx = strfind(ignoreList, '''''');
                            ignoreList([escapeIdx, escapeIdx + 1]) = [];
                            ignoreList = double(ignoreList);
                            if ~isempty(escapeIdx)
                                ignoreList = [ignoreList, 0]; %#ok<AGROW>
                            end
                            if ~isempty(ignoreList)
                                removeIdx = [];
                                for k = 1:length(ignoreList)
                                    removeIdx = union(removeIdx, find(labels == ignoreList(k)));
                                end
                                selectedIndices(removeIdx) = [];
                            end

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
                    absTime = dbase.Times(filenum) + alignSample / (fs * 24 * 60 * 60);

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
                    if windowStart < 1 || windowEnd > dbase.FileLength(filenum)
                        if excludeIncomplete
                            continue;
                        end
                        isComplete = 0;
                    else
                        isComplete = 1;
                    end
                    windowStart = max(windowStart, 1);
                    windowEnd = min(windowEnd, dbase.FileLength(filenum));

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
                        [~, labelOrder] = sort(includeList);
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
            if ~isempty(obj.figure_Main) && isvalid(obj.figure_Main)
                delete(obj.figure_Main);
            end
        end
    end
end
