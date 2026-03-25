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

            % TODO: Port the full GenerateRaster pipeline from
            % push_GenerateRaster_Callback in the original code.
            % For now this is a stub.
            disp('RasterGUI.generate() - not yet implemented');
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

            obj.figure_Main = figure( ...
                'Name', 'Sorted Raster Plots', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'Units', 'normalized', ...
                'Position', [0.025, 0.05, 0.95, 0.9], ...
                'Visible', 'off', ...
                'CloseRequestFcn', @(~,~) obj.hide());

            % Main axes
            obj.axes_Raster = axes(obj.figure_Main, ...
                'Position', [0.23, 0.30, 0.41, 0.47], ...
                'Box', 'on');
            obj.axes_PSTH = axes(obj.figure_Main, ...
                'Position', [0.23, 0.05, 0.41, 0.20], ...
                'Box', 'on');
            obj.axes_Hist = axes(obj.figure_Main, ...
                'Position', [0.67, 0.30, 0.10, 0.47], ...
                'Box', 'on');

            obj.AxisPosRaster = obj.axes_Raster.Position;
            obj.AxisPosPSTH = obj.axes_PSTH.Position;
            obj.AxisPosHist = obj.axes_Hist.Position;

            % --- Left side: tab group + generate buttons ---
            panelX = 0.005;
            panelW = 0.215;
            tabGroupHeight = 0.86;

            tabGroup = uitabgroup(obj.figure_Main, ...
                'Units', 'normalized', ...
                'Position', [panelX, 0.11, panelW, tabGroupHeight]);

            % --- Trigger tab ---
            trigTab = uitab(tabGroup, 'Title', 'Trigger');
            obj.popup_TriggerSource = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.02, 0.88, 0.96, 0.06], ...
                'String', {'Sound'});
            uicontrol(trigTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.80, 0.25, 0.06], ...
                'String', 'Type:', 'HorizontalAlignment', 'right');
            obj.popup_TriggerType = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.29, 0.80, 0.44, 0.06], ...
                'String', {'Syllables', 'Markers', 'Motifs', 'Bouts'});
            obj.push_TriggerOptions = uicontrol(trigTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.75, 0.80, 0.23, 0.06], ...
                'String', 'Options', 'Callback', @(~,~) obj.triggerOptionsCallback());
            uicontrol(trigTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.72, 0.25, 0.06], ...
                'String', 'Align:', 'HorizontalAlignment', 'right');
            obj.popup_TriggerAlignment = uicontrol(trigTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.29, 0.72, 0.44, 0.06], ...
                'String', {'Onset', 'Offset', 'Midpoint'});
            obj.check_CopyEvents = uicontrol(trigTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [0.02, 0.64, 0.96, 0.06], ...
                'String', 'Copy events from trigger');

            % --- Events tab ---
            eventTab = uitab(tabGroup, 'Title', 'Events');
            obj.popup_EventSource = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.02, 0.88, 0.96, 0.06], ...
                'String', {'Sound'});
            uicontrol(eventTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.80, 0.25, 0.06], ...
                'String', 'Type:', 'HorizontalAlignment', 'right');
            obj.popup_EventType = uicontrol(eventTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.29, 0.80, 0.44, 0.06], ...
                'String', {'Syllables', 'Markers', 'Events', 'Bursts', 'Continuous'});
            obj.push_EventOptions = uicontrol(eventTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.75, 0.80, 0.23, 0.06], ...
                'String', 'Options', 'Callback', @(~,~) obj.eventOptionsCallback());
            obj.check_CopyTrigger = uicontrol(eventTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [0.02, 0.72, 0.96, 0.06], ...
                'String', 'Copy trigger to events');

            % --- Window tab ---
            windowTab = uitab(tabGroup, 'Title', 'Window');
            uicontrol(windowTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.88, 0.20, 0.06], ...
                'String', 'Start:', 'HorizontalAlignment', 'right');
            obj.popup_StartReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.24, 0.88, 0.74, 0.06], ...
                'String', {'Trigger onset', 'Trigger offset', 'Prev trigger onset', 'Prev trigger offset'});
            uicontrol(windowTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.80, 0.20, 0.06], ...
                'String', 'Stop:', 'HorizontalAlignment', 'right');
            obj.popup_StopReference = uicontrol(windowTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.24, 0.80, 0.74, 0.06], ...
                'String', {'Trigger onset', 'Trigger offset', 'Next trigger onset', 'Next trigger offset'});
            obj.push_WindowLimits = uicontrol(windowTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.02, 0.72, 0.30, 0.06], ...
                'String', 'Limits', 'Callback', @(~,~) obj.windowLimitsCallback());
            obj.check_ExcludeIncomplete = uicontrol(windowTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [0.02, 0.64, 0.96, 0.06], ...
                'String', 'Exclude incomplete', 'Value', 1);
            obj.check_ExcludePartialEvents = uicontrol(windowTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [0.02, 0.56, 0.96, 0.06], ...
                'String', 'Exclude partial events');

            % --- Sort tab ---
            sortTab = uitab(tabGroup, 'Title', 'Sort');
            uicontrol(sortTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.88, 0.30, 0.06], ...
                'String', 'Primary:', 'HorizontalAlignment', 'right');
            obj.popup_PrimarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.34, 0.88, 0.64, 0.06], ...
                'String', obj.getSortOptions());
            uicontrol(sortTab, 'Style', 'text', ...
                'Units', 'normalized', 'Position', [0.02, 0.80, 0.30, 0.06], ...
                'String', 'Secondary:', 'HorizontalAlignment', 'right');
            obj.popup_SecondarySort = uicontrol(sortTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.34, 0.80, 0.64, 0.06], ...
                'String', obj.getSortOptions());
            obj.radio_Ascending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'Units', 'normalized', 'Position', [0.02, 0.72, 0.45, 0.06], ...
                'String', 'Ascending', 'Value', 1, ...
                'Callback', @(~,~) set(obj.radio_Descending, 'Value', 0));
            obj.radio_Descending = uicontrol(sortTab, 'Style', 'radiobutton', ...
                'Units', 'normalized', 'Position', [0.50, 0.72, 0.48, 0.06], ...
                'String', 'Descending', 'Value', 0, ...
                'Callback', @(~,~) set(obj.radio_Ascending, 'Value', 0));
            obj.check_GroupLabels = uicontrol(sortTab, 'Style', 'checkbox', ...
                'Units', 'normalized', 'Position', [0.02, 0.64, 0.96, 0.06], ...
                'String', 'Group by label');

            % --- Files tab ---
            filesTab = uitab(tabGroup, 'Title', 'Files');
            obj.popup_Files = uicontrol(filesTab, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.02, 0.88, 0.96, 0.06], ...
                'String', {'All files in range', 'Only selected by search', 'Only unselected'});
            obj.push_FileRange = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.02, 0.80, 0.48, 0.06], ...
                'String', 'File range', 'Callback', @(~,~) obj.fileRangeCallback());
            obj.push_Open = uicontrol(filesTab, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [0.52, 0.80, 0.46, 0.06], ...
                'String', 'Open dbase', 'Callback', @(~,~) obj.openCallback());

            % --- Generate / Hold buttons below the tab group ---
            obj.push_GenerateRaster = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [panelX, 0.02, panelW * 0.48, 0.08], ...
                'String', 'Generate', ...
                'FontWeight', 'bold', ...
                'Callback', @(~,~) obj.generate());
            obj.push_Hold = uicontrol(obj.figure_Main, 'Style', 'pushbutton', ...
                'Units', 'normalized', 'Position', [panelX + panelW * 0.52, 0.02, panelW * 0.48, 0.08], ...
                'String', 'Hold on', ...
                'Callback', @(~,~) obj.holdCallback());

            % --- Right side controls ---
            rightX = 0.80;
            rightW = 0.19;

            % Plot X limits
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
                'Units', 'normalized', 'Position', [rightX, 0.02, rightW, 0.12]);
            obj.popup_PSTHUnits = uicontrol(psthPanel, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.02, 0.55, 0.96, 0.38], ...
                'String', {'Rate (Hz)', 'Count/trial', 'Total count'});
            obj.popup_PSTHCount = uicontrol(psthPanel, 'Style', 'popupmenu', ...
                'Units', 'normalized', 'Position', [0.02, 0.10, 0.96, 0.38], ...
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
                obj.FileRange = eval(answer{1}); %#ok<EVLC>
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
