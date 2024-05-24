classdef electro_gui < handle
    properties
        dbase struct
        settings struct
        tempSettings struct
        plugins struct
        SourcePath char
        SourceDir char
        SourceName char
        UserFile
        OriginalDbase struct
    end
    properties
        History StateStack
        LastHistoryTimestamp datetime
        tempFile char
        file_cache struct
        sound
        filtered_sound
        amplitude
        loadedChannelData = {}
        loadedChannelFs = {}
        loadedChannelLabels = {}
        ChanYLimits
    end
    properties  % GUI widgets
        figure_Main
        panel_files                     % Panel for file widgets
        popup_FileSortOrder matlab.ui.control.UIControl
        axes_Sound matlab.graphics.axis.Axes
        axes_Sonogram matlab.graphics.axis.Axes
        axes_Amplitude matlab.graphics.axis.Axes
        axes_Segments matlab.graphics.axis.Axes
        axes_Events matlab.graphics.axis.Axes
        popup_Channels
        popup_Channel1
        popup_Channel2
        popup_Functions
        popup_Function1
        popup_Function2
        popup_EventDetectors
        popup_EventDetector1
        popup_EventDetector2
        axes_Channel
        axes_Channel1
        axes_Channel2
        menu_SourcePlots
        menu_SourceTopPlot
        menu_SourceBottomPlot
        menu_PeakDetects
        menu_PeakDetect1
        menu_PeakDetect2
        menu_AutoLimits
        menu_AutoLimits1
        menu_AutoLimits2
        context_Channels
        context_Channel1
        context_Channel2
        menu_AllowYZooms
        menu_AllowYZoom1
        menu_AllowYZoom2
        menu_EventAutoDetect
        menu_EventAutoDetect1
        menu_EventAutoDetect2
        menu_EventsDisplay
        menu_EventsDisplay1
        menu_EventsDisplay2
        menu_Events
        menu_Events1
        menu_Events2
        push_Detects
        push_Detect1
        push_Detect2
        menu_OpenRecent
        openRecent_None  % Placeholder menu item when there are no recently opened files
        menu_DisplayValues
        menu_DisplayFeatures
        menu_AutoDisplayEvents
        menu_AutoCalculate
        menu_FrequencyZoom
        menu_OverlayTop
        menu_OverlayBottom
        menu_AutoSegment
        menu_AutoThreshold
        menu_DontPlot
        menu_AmplitudeSource
        menu_Algorithm
        menu_Segmenter
        menu_Filter
        menu_ColormapList
        menu_Colormap
        menu_Macros
        menu_XAxis_List
        menu_YAxis_List
        menu_AlgorithmList
        menu_SegmenterList
        menu_FilterList
        playback_FilteredSound
        playback_Reverse
        menu_export_options_Animation
        menu_export_options_Animation_ProgressBar
        playback_SoundInMix
        playback_TopInMix
        playback_BottomInMix
        edit_FileNumber
        text1
        text_TotalFileNumber
        push_PreviousFile
        push_NextFile
        text26
        check_ReverseSort
        text_NotesLabel
        edit_FileNotes
        text_FileName
        text_DateAndTime
        text5
        edit_Timescale
        text6
        context_Sonogram
        menu_LongFiles
        menu_SonogramParameters
        center_Timescale
        menu_ColorScale
        menu_BackgroundColor
        menu_FreqLimits
        menu_AuxiliarySoundSources
        menu_Overlay
        push_Calculate
        context_Amplitude
        menu_SetThreshold
        menu_SmoothingWindow
        menu_FilterParameters
        menu_AmplitudeAxisRange
        menu_AmplitudeAutoRange
        menu_AmplitudeColors
        menu_AmplitudeColor
        menu_AmplitudeThresholdColor
        menu_SourceSoundAmplitude
        context_Segments
        menu_Split
        menu_Concatenate
        menu_DeleteAll
        menu_UndeleteAll
        menu_SegmentParameters
        push_Segment
        text8
        text9
        text10
        menu_ChannelColors1
        menu_PlotColor1
        menu_ThresholdColor1
        menu_LineWidth1
        menu_SetLimits1
        menu_SelectionParameters1
        menu_UpdateEventThresholdDisplay1
        menu_EventParams1
        menu_FunctionParams1
        menu_ChannelColors2
        menu_PlotColor2
        menu_ThresholdColor2
        menu_LineWidth2
        menu_SetLimits2
        menu_SelectionParameters2
        menu_UpdateEventThresholdDisplay2
        menu_EventParams2
        menu_FunctionParams2
        text12
        text14
        text15
        push_BrightnessUp
        push_BrightnessDown
        text17
        push_OffsetUp
        push_OffsetDown
        text18
        panel_Events
        text24
        text25
        popup_EventListAlign
        popup_EventListData
        context_EventViewer
        menu_ViewerDisplay
        menu_XAxis
        menu_YAxis
        menu_AutoApplyYLim
        menu_EventsAxisLimits
        panel_Worksheet
        axes_Worksheet
        push_WorksheetAppend
        push_WorksheetOptions
        push_PageLeft
        push_PageRight
        context_Worksheet
        menu_WorksheetView
        menu_WorksheetDelete
        context_WorksheetOptions
        menu_SortChronologically
        menu_OnePerLine
        menu_IncludeTitle
        menu_EditTitle
        menu_WorksheetDimensions
        menu_Orientation
        menu_Portrait
        menu_Landscape
        menu_ClearWorksheet
        popup_SoundSource
        text23
        context_EventListAlign
        EventViewerSourceToTopAxes
        EventViewerSourceToBottomAxes
        menu_File
        file_New
        file_Open
        file_Save
        menu_AlterFileList
        menu_ChangeFiles
        menu_DeleteFiles
        menu_Playback
        menu_PlaySound
        menu_PlayMix
        playback_Weights
        playback_Clippers
        playback_Speed
        menu_Animation
        playback_animation_SoundWave
        playback_animation_Sonogram
        playback_animation_Segments
        playback_animation_SoundAmplitude
        playback_animation_TopPlot
        playback_animation_BottomPlot
        playback_ProgressBarColor
        menu_Properties
        menu_AddProperty
        menu_RemoveProperty
        menu_RenameProperty
        menu_FillProperty
        menu_Search
        menu_SearchNew
        menu_SearchAnd
        menu_SearchOr
        menu_SearchNot
        menu_Export
        action_Export
        menu_ExportAs
        export_asSonogram
        export_asFigure
        export_asWorksheet
        export_asCurrentSound
        export_asSoundMix
        export_asEvents
        menu_ExportTo
        export_toMATLAB
        export_toPowerPoint
        export_toFile
        export_toClipboard
        export_Options
        export_options_SonogramHeight
        export_options_ImageTimescape
        export_options_IncludeTimestamp
        menu_export_options_IncludeSoundClip
        export_options_IncludeSoundClip_None
        export_options_IncludeSoundClip_SoundOnly
        export_options_IncludeSoundClip_SoundMix
        export_options_Animation_None
        export_options_Animation_ProgressBar
        export_options_Animation_ArrowAbove
        export_options_Animation_ArrowBelow
        export_options_Animation_ValueFollower
        export_options_Animation_SonogramFollower
        export_options_ImageResolution
        menu_export_options_SonogramImageMode
        export_options_SonogramImageMode_ScreenImage
        export_options_SonogramImageMode_Recalculate
        export_options_ScalebarDimensions
        export_options_EditFigureTemplate
        menu_Help
        help_ControlsHelp
    end
    properties  % Graphics elements
        EventWaveHandles matlab.graphics.Graphics
        EventThresholdHandles matlab.graphics.Graphics
        menu_EventsDisplayList
        FileInfoBrowser uitable2
        xlimbox matlab.graphics.Graphics
        TimeResolutionBarHandle matlab.graphics.Graphics
        TimeResolutionBarText matlab.graphics.Graphics
        AmplitudePlotHandle  matlab.graphics.Graphics    % Handle to amplitude plot
        SegmentThresholdHandle  matlab.graphics.Graphics % Handle for audio segment threshold line
        SegmentHandles matlab.graphics.Graphics
        MarkerHandles matlab.graphics.Graphics
        SegmentLabelHandles matlab.graphics.Graphics
        MarkerLabelHandles matlab.graphics.Graphics
        Cursors matlab.graphics.Graphics
        ChannelPlots cell
        Sonogram_Overlays matlab.graphics.Graphics
        WorksheetHandles
        EventHandles = {{}, {}};
        ActiveEventCursors matlab.graphics.Graphics
    end
    properties  % Graphics info
        Colormap double
        FileInfoBrowserFirstPropertyColumn double
    end
    methods
        function obj = electro_gui()
            if ~exist('MATLAB_utils', 'file')
                sz = matlab.desktop.commandwindow.size;
                fprintf('\n');
                fprintf(repmat('*', sz(1)))
                fprintf('\n')
                warning('MATLAB-utils repository does not appear to be on the MATLAB path. Please make sure it is installed and put on the path and try again.');
                fprintf(repmat('*', sz(1)))
                fprintf('\n')
                fprintf('\n')
                return;
            end

            % Get the ElectroGui source directory
            obj.SourcePath = mfilename('fullpath');
            [obj.SourceDir, obj.SourceName, ~] = fileparts(obj.SourcePath);

            % Get current logged in username
            user = electro_gui.getUser();

            % Ensure a defaults file exists for the user
            obj.ensureDefaultsFileExists(user);

            % Prompt user to choose a defaults file.
            [chosenDefaults, cancel] = obj.chooseDefaultsFile();
            if cancel
                % Abort
                delete(obj.figure_Main);
                return;
            end

            % Load default defaults - the user's values can overwrite this
            obj.settings = defaults_template(struct());

            % Load defaults
            obj.settings = feval(chosenDefaults, obj.settings);

            % Warn user of old defaults
            obj.settings = electro_gui.warnAndFixLegacyDefaults(obj.settings);

            % Initialize blank dbase
            obj.dbase = electro_gui.InitializeDbase(obj.settings, 'BaseDbase', obj.dbase);

            % Create the GUI widgets
            obj.setupGUI();

            % Gather all electro_gui plugins
            obj.plugins = electro_gui.gatherPlugins();

            progressBar = waitbar(0, 'Initializing electro_gui...');
            progressBar.Children.Title.Interpreter = 'none';

            % Setup Undo/Redo stack
            obj.History = StateStack(10);   % GUI state history for undo/redo purposes
            obj.LastHistoryTimestamp = datetime("now");

            % Initialize file cache
            obj.resetFileCache();

            waitbar(0.1, progressBar);

            % Load temp file, or use defaults if it doesn't exist
            obj.tempFile = fullfile(obj.SourceDir, 'eg_temp.mat');
            obj.loadTempFile();

            % Update list of recent files
            obj.updateRecentFileList();

            % If user has QuoteFile defined in their defaults, serve them up a
            % welcome message and a nice quote
            if isfield(obj.settings, 'QuoteFile')
                quote = getQuote(obj.settings.QuoteFile);
                fprintf('Welcome to electro_gui.\n\nRandom quote of the moment:\n\n%s\n\nTo stop getting quotes, remove the ''obj.QuoteFile'' parameter from your defaults file.\n\n', quote);
            end

            % Set values of various GUI controls based on default values
            obj.setGUIValues();

            % Populate various GUI menus with available plugins found in the
            % electro_gui directory
            obj.populatePluginMenus();

            %colormap('default');
            obj.Colormap = colormap(obj.figure_Main);
            obj.Colormap(1,:) = obj.settings.BackgroundColors(1,:);

            obj.InitializeExportOptions();

            waitbar(0.1, progressBar, {'Starting parallel pool for file caching...', 'This can be disabled in defaults file'});

            if obj.settings.EnableFileCaching
                try
                    % Start up parallel pool for caching purposes
                    p = gcp();
                    p.IdleTimeout = 90;
                catch
                    warning('Failed to start parallel pool - maybe the parallel computing toolbox is not installed? Disabling file caching.');
                    obj.settings.EnableFileCaching = false;
                end
            end
            waitbar(0.8, progressBar, 'Initializing electro_gui...');

            % Initialize event-related variables
            obj.dbase.EventParts = {};        % Array of event part options for the selected event detector

            % Initialize all graphics handles and GUI data
            obj.InitializeGraphics();

            waitbar(1, progressBar);
            close(progressBar);

        end
    end
    methods

function InitializeGraphics(obj)
    % Initialize and configure all the stored graphics handles for the GUI

    % Event-related graphics stuff
    obj.EventWaveHandles = gobjects().empty;
    obj.EventThresholdHandles = gobjects(1, 2);  % Handles for event threshold lines
    obj.settings.ActiveEventNum = [];
    obj.settings.ActiveEventPartNum = [];
    obj.settings.ActiveEventCursors = gobjects().empty;
    % Set up event objects
    obj.EventWaveHandles = gobjects().empty;
    obj.menu_EventsDisplayList = {gobjects().empty, gobjects().empty};
    obj.UpdateEventSourceList();

    % File browser-related stuff
    obj.FileInfoBrowser = uitable2(obj.panel_files, 'Units', 'normalized', 'Position', [0.025, 0.145, 0.944, 0.703], 'Data', {}, 'RowName', {});
    obj.FileInfoBrowser.ColumnRearrangeable = true;
    obj.FileInfoBrowserFirstPropertyColumn = 3;  % First column that contains boolean property checkboxes
    obj.FileInfoBrowser.KeyPressFcn = @obj.keyPressHandler;
    obj.FileInfoBrowser.KeyReleaseFcn = @obj.keyReleaseHandler;
    obj.FileInfoBrowser.CellSelectionCallback = @(src, event)obj.HandleFileListChange(src.Parent, event);
    obj.FileInfoBrowser.CellEditCallback = @obj.GUIPropertyChangeHandler;
    % File sort order stuff
    obj.popup_FileSortOrder.String = {'File number', 'Random', 'Property', 'Read status'};
    obj.popup_FileSortOrder.Value = 1;


    % Min and max time to display on axes
    obj.settings.TLim = [0, 1];

    % Handle for box showing time viewing window
    obj.xlimbox = gobjects().empty;

    obj.TimeResolutionBarHandle = gobjects();
    obj.TimeResolutionBarText = gobjects();

    % Handles for plotted data
    obj.AmplitudePlotHandle = gobjects();       % Handle to amplitude plot
    obj.SegmentThresholdHandle = gobjects();    % Handle for audio segment threshold line
    obj.SegmentHandles = gobjects().empty;
    obj.MarkerHandles = gobjects().empty;
    obj.SegmentLabelHandles = gobjects().empty;
    obj.MarkerLabelHandles = gobjects().empty;

    obj.settings.ActiveSegmentNum = [];
    obj.settings.ActiveMarkerNum = [];

    % General cursor
    obj.Cursors = gobjects().empty;

    % Channel data plot graphics objects
    obj.ChannelPlots = {gobjects().empty, gobjects().empty};

    % Sonogram overlay handles
    obj.Sonogram_Overlays = gobjects(1, 2);

    obj.setUpWorksheet();

    %% Set up axes-indexed lists of GUI elements, to make code more extensible
    % obj.popup_Channels are dropdown menus for the channel axes to select a channel of data to display.
    obj.popup_Channels = [obj.popup_Channel1, obj.popup_Channel2];
    % obj.popup_Function are dropdown menus for the channel axes to select a filter function.
    obj.popup_Functions = [obj.popup_Function1, obj.popup_Function2];
    % obj.popup_EventDetector are dropdown menus for the channel axes to select an event detector algorithm.
    obj.popup_EventDetectors = [obj.popup_EventDetector1, obj.popup_EventDetector2];
    % obj.axes_Channel are the channel data display axes
    obj.axes_Channel = [obj.axes_Channel1, obj.axes_Channel2];
    % menu source top/bottom plot
    obj.menu_SourcePlots = [obj.menu_SourceTopPlot, obj.menu_SourceBottomPlot];
    % peak detect menu items
    obj.menu_PeakDetects = [obj.menu_PeakDetect1, obj.menu_PeakDetect2];
    obj.menu_AutoLimits = [obj.menu_AutoLimits1, obj.menu_AutoLimits2];
    obj.context_Channels = [obj.context_Channel1, obj.context_Channel2];
    obj.menu_AllowYZooms = [obj.menu_AllowYZoom1, obj.menu_AllowYZoom2];
    obj.menu_EventAutoDetect = [obj.menu_EventAutoDetect1, obj.menu_EventAutoDetect2];
    obj.menu_EventsDisplay = [obj.menu_EventsDisplay1, obj.menu_EventsDisplay2];
    obj.menu_Events = [obj.menu_Events1, obj.menu_Events2];
    obj.push_Detects = [obj.push_Detect1, obj.push_Detect2];

    dr = dir(obj.SourcePath);
    obj.figure_Main.Name = ['ElectroGui v. ', dr.date];
    % Position figure
    obj.figure_Main.Position = [.025 0.075 0.95 0.85];
    % Set scroll handler
    obj.figure_Main.WindowScrollWheelFcn = @obj.scrollHandler;
    obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;
    obj.figure_Main.KeyReleaseFcn = @obj.keyReleaseHandler;
    obj.figure_Main.WindowButtonMotionFcn = @obj.mouseMotionHandler;

    obj.disableAxesPopupToolbars();

    % Clear all axes
    axes = [obj.axes_Sound, ...
            obj.axes_Sonogram, ...
            obj.axes_Amplitude, ...
            obj.axes_Segments, ...
            obj.axes_Channel, ...
            obj.axes_Events];
    for ax = axes
        for child = ax.Children
            delete(child);
        end
    end
end

function InitializeExportOptions(obj)
    obj.export_options_EditFigureTemplate.UserData = obj.settings.template;

    if obj.settings.ExportReplotSonogram == 1
        obj.export_options_SonogramImageMode_Recalculate.Checked = 'on';
    else
        obj.export_options_SonogramImageMode_ScreenImage.Checked = 'on';
    end
    switch obj.settings.ExportSonogramIncludeClip
        case 0
            obj.export_options_IncludeSoundClip_None.Checked = 'on';
        case 1
            obj.export_options_IncludeSoundClip_SoundOnly.Checked = 'on';
        case 2
            obj.export_options_IncludeSoundClip_SoundMix.Checked = 'on';
    end
    if obj.settings.ExportSonogramIncludeLabel
        obj.export_options_IncludeTimestamp.Checked = 'on';
    else
        obj.export_options_IncludeTimestamp.Checked = 'off';
    end

    obj.settings.ScalebarPresets = [0.001 0.002 0.005 0.01 0.02 0.025 0.05 0.1 0.2 0.25 0.5 1 2 5 10 20 30 60];
    obj.settings.ScalebarLabels =  {'1 ms','2 ms','5 ms','10 ms','20 ms','25 ms','50 ms','100 ms','200 ms','250 ms','500 ms','1 s','2 s','5 s','10 s','20 s','30 s','1 min'};
end

function SaveState(obj)
    if ~obj.settings.UndoEnabled
        return
    end
    newTimestamp = datetime("now");
    if (newTimestamp - obj.LastHistoryTimestamp) > (obj.settings.HistoryInterval / (60*60*24))
        try
            [dbase, settings] = obj.GetDBase(false);
            obj.History.SaveState({dbase, settings});
            obj.LastHistoryTimestamp = newTimestamp;
        catch
            % Eh, don't sweat it.
        end
    end
end

function Undo(obj)
    if ~obj.settings.UndoEnabled
        warning('Undo/redo is disabled - enable it by adding ''obj.settings.UndoEnabled = true;'' to your defaults file');
    end
    state = obj.History.UndoState(obj.GetDBase(false)); %#ok<*PROP>
    dbase = state{1};
    settings = state{2};
    obj.OpenDbase(dbase, 'Settings', settings);
end

function Redo(obj)
    if ~obj.settings.UndoEnabled
        warning('Undo/redo is disabled - enable it by adding ''obj.settings.UndoEnabled = true;'' to your defaults file');
    end
    state = obj.History.RedoState(obj.GetDBase(false));
    dbase = state{1};
    settings = state{2};
    obj.OpenDbase(dbase, 'Settings', settings);
end

function disableAxesPopupToolbars(obj)
    % Turn off the pop-up tool buttons for axes
    delete(obj.axes_Sound.Toolbar);
    delete(obj.axes_Sonogram.Toolbar);
    delete(obj.axes_Amplitude.Toolbar);
    delete(obj.axes_Channel1.Toolbar);
    delete(obj.axes_Channel2.Toolbar);
    delete(obj.axes_Segments.Toolbar);
    delete(obj.axes_Events.Toolbar);
end

function loadTempFile(obj)
    % Get temp file
    tempSettingsFields =        {'lastDirectory',   'lastDBase', 'recentFiles'};
    tempSettingsDefaultValues = {obj.SourceDir,     '',          {}};
    try
        obj.tempSettings = load(obj.tempFile, tempSettingsFields{:});
    catch ME
        switch ME.identifier
            case 'MATLAB:load:unableToReadMatFile'
                % temp file is messed up maybe?
                warning('Unable to open temp file, creating new one.');
            case 'MATLAB:load:couldNotReadFile'
                % temp file does not exist maybe?
                warning('Unable to find temp file, creating new one.');
                % No temp file - use defaults
            otherwise
                warning('Unknown error when attempting to read temp file. Creating new one.');
        end
        delete(obj.tempFile);
        obj.tempSettings = struct();
    end
    % Loop over expected temp settings fields and set defaults if they
    % aren't there
    for k = 1:length(tempSettingsFields)
        if ~isfield(obj.tempSettings, tempSettingsFields{k})
            obj.tempSettings.(tempSettingsFields{k}) = tempSettingsDefaultValues{k};
        end
    end
    obj.updateTempFile();
end

function updateTempFile(obj)
    % Update temp file
    tempSettings = obj.tempSettings;
    save(obj.tempFile, '-struct', 'tempSettings');
end

function updateRecentFileList(obj)
    % Update the list of recent files

    for recentFileItem = obj.menu_OpenRecent.Children'
        if recentFileItem ~= obj.openRecent_None
            delete(recentFileItem);
        end
    end
    obj.openRecent_None.Visible = isempty(obj.tempSettings.recentFiles);
    for k = 1:length(obj.tempSettings.recentFiles)
        recentFilePath = obj.tempSettings.recentFiles{k};
        uimenu(obj.menu_OpenRecent, 'Text', recentFilePath, 'UserData', recentFilePath, 'MenuSelectedFcn', @obj.click_recentFile);
    end
end

function addRecentFile(obj, filePath)
    % Add a file to a list of recent files in the temp settings struct
    if ~isfield(obj.tempSettings, 'recentFiles')
        obj.tempSettings.recentFiles = {};
    end
    % Add file
    obj.tempSettings.recentFiles = [filePath, obj.tempSettings.recentFiles];
    % Remove duplicates
    obj.tempSettings.recentFiles = unique(obj.tempSettings.recentFiles, 'stable');
    % Limit number of stored recent files
    maxFiles = 10;
    numFiles = min(maxFiles, length(obj.tempSettings.recentFiles));
    obj.tempSettings.recentFiles = obj.tempSettings.recentFiles(1:numFiles);
    obj.updateRecentFileList();
    obj.updateTempFile();
end

function setUpWorksheet(obj)
    sz = obj.figure_Main.PaperSize;
    if strcmp(obj.settings.WorksheetOrientation,'portrait')
        obj.menu_Portrait.Checked = 'on';
    else
        obj.settings.WorksheetOrientation = 'landscape';
        obj.menu_Landscape.Checked = 'on';
    end
    if ~strcmp(obj.settings.WorksheetOrientation,obj.figure_Main.PaperOrientation)
        obj.settings.WorksheetHeight = sz(1);
        obj.settings.WorksheetWidth = sz(2);
    else
        obj.settings.WorksheetHeight = sz(2);
        obj.settings.WorksheetWidth = sz(1);
    end

    patch(obj.axes_Worksheet, [0, obj.settings.WorksheetWidth, obj.settings.WorksheetWidth, 0], [0, 0, obj.settings.WorksheetHeight, obj.settings.WorksheetHeight], 'w');
    axis(obj.axes_Worksheet, 'equal');
    axis(obj.axes_Worksheet, 'tight');
    axis(obj.axes_Worksheet, 'off');

    obj.settings.WorksheetTitle = 'Untitled';

    obj.settings.WorksheetXLims = {};
    obj.settings.WorksheetYLims = {};
    obj.settings.WorksheetXs = {};
    obj.settings.WorksheetYs = {};
    obj.settings.WorksheetMs = {};
    obj.settings.WorksheetClim = {};
    obj.settings.WorksheetColormap = {};
    obj.settings.WorksheetSounds = {};
    obj.settings.WorksheetFs = [];
    obj.settings.WorksheetTimes = datetime.empty();

    obj.settings.WorksheetCurrentPage = 1;

    if obj.settings.WorksheetIncludeTitle == 1
        obj.menu_IncludeTitle.Checked = 'on';
    end
    if obj.settings.WorksheetChronological == 1
        obj.menu_SortChronologically.Checked = 'on';
    end
    if obj.settings.WorksheetOnePerLine == 1
        obj.menu_OnePerLine.Checked = 'on';
    end

    obj.WorksheetHandles = gobjects().empty();
    obj.settings.WorksheetList = [];
    obj.settings.WorksheetUsed = [];
    obj.settings.WorksheetWidths = [];
end

function isNewUser = ensureDefaultsFileExists(obj, user)
    % Check if a defaults file exists for the given user. If not, create
    % one for the user using the settings in defaults_template file.

    % Determine correct defaults filename for user
    obj.UserFile = fullfile(obj.SourceDir, sprintf('defaults_%s.m', user));
    % Check if defaults filename for current user exists
    isNewUser = isempty(dir(obj.UserFile));

    if isNewUser
        % No defaults file exists - create a new one and copy defaults into
        % it

        % Open default defaults file
        defaultsTemplate = fullfile(obj.SourceDir, 'defaults_template.m');
        fid1 = fopen(defaultsTemplate,'r');
        % Create new defaults file for user
        fid2 = fopen(obj.UserFile,'w');
        fgetl(fid1);
        str = ['function handles = ' obj.UserFile(1:end-2) '(handles)'];
        while ischar(str)
            f = strfind(str,'\');
            for d = length(f):-1:1
                str = [str(1:f(d)-1) '\\' str(f(d)+1:end)];
            end
            f = strfind(str,'%');
            for d = length(f):-1:1
                str = [str(1:f(d)-1) '%%' str(f(d)+1:end)];
            end
            fprintf(fid2,[str '\n']);
            str = fgetl(fid1);
        end
        fclose(fid1);
        fclose(fid2);
    end
end

function [chosenDefaults, cancel] = chooseDefaultsFile(obj)
    % Prompt user to choose a defaults file, then load it.

    chosenDefaults = '';

    % Populate list of defaults files for user to choose from
    userList = {'(Default)'};
    defaultsFileList = dir(fullfile(obj.SourceDir, 'defaults_*.m'));
    for c = 1:length(defaultsFileList)
        userList(end+1) = regexp(defaultsFileList(c).name, '(?<=defaults_).*(?=\.m)', 'match'); %#ok<*AGROW>
    end
    currentUserDefaultIndex = find(strcmp(obj.UserFile, {defaultsFileList.name}));

    [chosenDefaultIndex, ok] = listdlg('ListString', userList, 'Name', 'Defaults', 'PromptString', 'Select default settings', 'SelectionMode', 'single', 'InitialValue', currentUserDefaultIndex);
    cancel = ~ok;
    if ~cancel
        if chosenDefaultIndex > 1
            chosenDefaults = sprintf('defaults_%s', userList{chosenDefaultIndex});
        else
            chosenDefaults = 'defaults_template';
        end
    end
end

function setGUIValues(obj)
    % Set values of various GUI controls based on default values
if obj.settings.EventsDisplayMode == 1
    obj.menu_DisplayValues.Checked = 'on';
else
    obj.menu_DisplayFeatures.Checked = 'on';
end
if obj.settings.EventsAutoDisplay == 1
    obj.menu_AutoDisplayEvents.Checked = 'on';
end

if obj.settings.SonogramAutoCalculate == 1
    obj.menu_AutoCalculate.Checked = 'on';
end
if obj.settings.AllowFrequencyZoom == 1
    obj.menu_FrequencyZoom.Checked = 'on';
end
if obj.settings.OverlayTop == 1
    obj.menu_OverlayTop.Checked = 'on';
end
if obj.settings.OverlayBottom == 1
    obj.menu_OverlayBottom.Checked = 'on';
end

if obj.settings.AutoSegment == 1
    obj.menu_AutoSegment.Checked = 'on';
end

if obj.settings.AmplitudeAutoThreshold == 1
    obj.menu_AutoThreshold.Checked = 'on';
end

if obj.settings.AmplitudeDontPlot == 1
    obj.menu_DontPlot.Checked = 'on';
end

if obj.settings.PeakDetect(1) == 1
    obj.menu_PeakDetect1.Checked = 'on';
end
if obj.settings.PeakDetect(2) == 1
    obj.menu_PeakDetect2.Checked = 'on';
end

if obj.settings.AutoYZoom(1) == 1
    obj.menu_AllowYZoom1.Checked = 'on';
end
if obj.settings.AutoYZoom(2) == 1
    obj.menu_AllowYZoom2.Checked = 'on';
end

if obj.settings.AutoYLimits(1) == 1
    obj.menu_AutoLimits1.Checked = 'on';
end
if obj.settings.AutoYLimits(2) == 1
    obj.menu_AutoLimits2.Checked = 'on';
end

if obj.settings.EventsAutoDetect(1) == 1
    obj.menu_EventAutoDetect1.Checked = 'on';
end
if obj.settings.EventsAutoDetect(2) == 1
    obj.menu_EventAutoDetect2.Checked = 'on';
end

ch = obj.menu_AmplitudeSource.Children;
set(ch(3-obj.settings.AmplitudeSource),'Checked','on');

obj.settings.CustomFreqLim = obj.settings.FreqLim;

if obj.settings.FilterSound == 1
    obj.playback_FilteredSound.Checked = 'on';
end
if obj.settings.PlayReverse == 1
    obj.playback_Reverse.Checked = 'on';
end

obj.settings.AnimationPlots = fliplr(obj.settings.AnimationPlots);
ch = obj.menu_export_options_Animation.Children;
for c = 1:length(ch)
    if obj.settings.AnimationPlots(c) == 1
        ch(c).Checked = 'on';
    end
end

ch = obj.menu_export_options_Animation.Children;
ischeck = false;
for c = 1:length(ch)
    if strcmp(ch(c).Label, obj.settings.AnimationType)
        ch(c).Checked = 'on';
        ischeck = true;
    end
end
if ~ischeck
    obj.menu_export_options_Animation_ProgressBar.Checked = 'on';
end

obj.playback_SoundInMix.Checked = obj.settings.DefaultMix(1);
obj.playback_TopInMix.Checked = obj.settings.DefaultMix(2);
obj.playback_BottomInMix.Checked = obj.settings.DefaultMix(3);
end

function populatePluginMenus(obj)
    % Populate various GUI menus with available plugins found in the
    % electro_gui directory

    p = obj.plugins;

    % Populate sonogram algorithm plugin menu
    obj.menu_Algorithm = electro_gui.populatePluginMenuList(p.spectrums, obj.settings.DefaultSonogramPlotter, obj.menu_AlgorithmList, @obj.AlgorithmMenuClick);

    % Populate segmenting algorithm plugin menu
    obj.menu_Segmenter = electro_gui.populatePluginMenuList(p.segmenters, obj.settings.DefaultSegmenter, obj.menu_SegmenterList, @obj.SegmenterMenuClick);

    % Populate filter algorithm plugin menu
    obj.menu_Filter = electro_gui.populatePluginMenuList(p.filters, obj.settings.DefaultFilter, obj.menu_FilterList, @obj.FilterMenuClick);

    % Populate colormap plugin menu
    obj.menu_ColormapList(1) = uimenu(obj.menu_Colormap, 'Label', '(Default)', 'Callback', @obj.ColormapClick);
    obj.menu_ColormapList = electro_gui.populatePluginMenuList(p.colorMaps, '(Default)', obj.menu_Colormap, @ColormapClick);

    % Populate macro plugin menu
    obj.menu_Macros = electro_gui.populatePluginMenuList(p.macros, [], obj.menu_Macros, @obj.MacrosMenuclick);

    % Populate x-axis event feature algorithm plugin menu
    obj.menu_XAxis_List = electro_gui.populatePluginMenuList(p.eventFeatures, obj.settings.DefaultEventFeatureX, obj.menu_XAxis, @XAxisMenuClick);
    % Populate y-axis event feature algorithm plugin menu
    obj.menu_YAxis_List = electro_gui.populatePluginMenuList(p.eventFeatures, obj.settings.DefaultEventFeatureY, obj.menu_YAxis, @YAxisMenuClick);

    % Find all function algorithms
    pluginNames = {obj.plugins.filters.name};
    str = {'(Raw)'};
    for pluginIdx = 1:length(pluginNames)
        str{end+1} = pluginNames{pluginIdx};
    end
    obj.popup_Function1.String = str;
    obj.popup_Function1.UserData = cell(1,length(str));
    obj.popup_Function2.String = str;
    obj.popup_Function2.UserData = cell(1,length(str));

    % Find all event detector algorithms
    pluginNames = {obj.plugins.eventDetectors.name};
    str = {'(None)'};
    for pluginIdx = 1:length(pluginNames)
        str{end+1} = pluginNames{pluginIdx};
    end
    obj.popup_EventDetector1.String = str;
    obj.popup_EventDetector1.UserData = cell(1,length(str));
    obj.popup_EventDetector2.String = str;
    obj.popup_EventDetector2.UserData = cell(1,length(str));
end

function changeFile(obj, delta)
    % Switch file number by delta
    filenum = electro_gui.getCurrentFileNum(obj.settings);
    numFiles = electro_gui.getNumFiles(obj.dbase);
    if ~electro_gui.areFilesSorted(obj.settings)
        % Decrement file number
        filenum = filenum + delta;
        if filenum < 1 || filenum > numFiles
            filenum = mod(filenum-1, numFiles)+1;
        end
    else
        % Decrement file number in shuffled order
        shufflenum = obj.settings.InverseFileSortOrder(filenum);
        shufflenum = shufflenum + delta;
        if shufflenum < 1 || shufflenum > numFiles
            shufflenum = mod(shufflenum-1, numFiles)+1;
        end
        filenum = obj.settings.FileSortOrder(shufflenum);
    end
    obj.edit_FileNumber.String = num2str(filenum);
    obj.settings.CurrentFile = filenum;

    obj.LoadFile();
end
function progress_play(obj, wav)
    % Get time limits for visible sonogram
    timeLimits = obj.axes_Sonogram.XLim;
    % Get audio sample limits for the visible sonogram
    sampleLimits = round(timeLimits*obj.dbase.Fs);
    % Ensure sample number is in range
    sampleLimits(1) = sampleLimits(1)+1;
    sampleLimits(2) = sampleLimits(2)-1;
    if sampleLimits(1)<1
        sampleLimits(1) = 1;
    end
    numSamples = obj.eg_GetSamplingInfo();
    if sampleLimits(2) > numSamples
        sampleLimits(2) = numSamples;
    end
    if sampleLimits(2)<=sampleLimits(1)
        return
    end

    axs = [obj.axes_Channel2 obj.axes_Channel1 obj.axes_Amplitude obj.axes_Segments obj.axes_Sonogram obj.axes_Sound];
    ch = obj.menu_export_options_Animation.Children;
    indx = [];
    for c = 1:length(ch)
        if ch(c).Checked && axs(c).Visible
            indx = [indx, c];
        end
    end
    axs = axs(indx);

    fs = obj.dbase.Fs * obj.SoundSpeed;
    if isempty(axs)
        sound(wav,fs); %#ok<*CPROPLC> 
    else
        for c = length(axs):-1:1
            if ~axs(c).Visible
                axs(c) = [];
            end
        end
        for c = 1:length(axs)
            hold(axs(c), 'on')
            if ~obj.playback_Reverse.Checked
                h(c) = plot(axs(c), [sampleLimits(1) sampleLimits(1)]/obj.dbase.Fs,ylim,'Color',obj.ProgressBarColor,'LineWidth',2);
            else
                h(c) = plot(axs(c), [sampleLimits(2) sampleLimits(2)]/obj.dbase.Fs,ylim,'Color',obj.ProgressBarColor,'LineWidth',2);
            end
        end
        ap = audioplayer(wav,fs);
        play(ap);
        while isplaying(ap)
            pos = ap.CurrentSample;
            for c = 1:length(h)
                if ~obj.playback_Reverse.Checked
                    h(c).XData = ([pos pos]+sampleLimits(1)-1)/obj.dbase.Fs;
                else
                    h(c).XData = (sampleLimits(2)-[pos pos]+1)/obj.dbase.Fs;
                end
            end
            drawnow;
        end
        stop(ap);
        delete(ap);
        delete(h);
        hold(obj.axes_Sonogram, 'off');
    end
end

function centerTimescale(obj, centerTime, radiusTime)
    obj.settings.TLim = [centerTime - radiusTime, centerTime + radiusTime];
    obj.UpdateTimescaleView();
end

function data = retrieveFileFromCache(obj, filepath, loader)
    % Retrieve file from cache. If it has already been loaded, just return it.
    % If is done loading, but its data has not been transferred to the cache,
    % do so now. If it has not finished loading yet, wait until it loads.
    match_idx = obj.isFileInCache(filepath, loader);
    if ~match_idx
        obj.addToFileCache(filepath, loader);
        match_idx = obj.isFileInCache(filepath, loader);
    end

    if isempty(obj.file_cache(match_idx).data)
        % Data hasn't been loaded from future yet - load it (and wait if
        % necssary)
        obj.file_cache(match_idx).data = cell(1, 5);
        [obj.file_cache(match_idx).data{:}] = fetchOutputs(obj.file_cache(match_idx).data_future);
    end
    data = obj.file_cache(match_idx).data;
end

function addToFileCache(obj, filepath, loader)
    % Add the given file for the given loader to the cache, if it isn't already
    %   there.
    numLoaderOutputs = 5;
    if ~obj.isFileInCache(filepath, loader)
        next_idx = length(obj.file_cache)+1;
        obj.file_cache(next_idx).filepaths = filepath;
        obj.file_cache(next_idx).loaders = loader;
        obj.file_cache(next_idx).data = [];
        obj.file_cache(next_idx).data_future = parfeval(@electro_gui.eg_runPlugin, numLoaderOutputs, obj.plugins.loaders, loader, filepath, true);
    end
end

function inCache = isFileInCache(obj, filepath, loader)
    % Check if file is in the file cache or not. inCache is false if
    %   it is not in the cache, or a positive numerical cache index if it is in
    %   the cache.
    inCache = false;
    for k = 1:length(obj.file_cache)
        if strcmp(obj.file_cache(k).filepaths, filepath)
            if strcmp(obj.file_cache(k).loaders, loader)
                inCache = k;
                break;
            end
        end
    end
end

function refreshFileCache(obj)
    % Get a list of files that should be in cache,
    filesInCache = {};
    loadersInCache = {};

    filenum = electro_gui.getCurrentFileNum(obj.settings);
    minCacheNum = max(1, filenum - obj.settings.BackwardFileCacheSize);
    maxCacheNum = min(electro_gui.getNumFiles(obj.dbase), filenum + obj.settings.ForwardFileCacheSize);

    filenums = minCacheNum:maxCacheNum;
    [selectedChannelNum1, ~, isSound1] = obj.getSelectedChannel(1);
    [selectedChannelNum2, ~, isSound2] = obj.getSelectedChannel(2);

    % Add sound files to list of necessary cache files:
    for filenum = filenums
        % Add sound file to list
        filesInCache{end+1} = fullfile(obj.dbase.PathName, obj.dbase.SoundFiles(filenum).name);
        loadersInCache{end+1} = obj.dbase.SoundLoader;

        % Add whatever channel is selected in axes1 to list
        if ~isempty(selectedChannelNum1) && selectedChannelNum1 ~= 0
            filesInCache{end+1} = fullfile(obj.dbase.PathName, obj.dbase.ChannelFiles{selectedChannelNum1}(filenum).name);
            if isSound1
                loadersInCache{end+1} = obj.dbase.SoundLoader;
            else
                loadersInCache{end+1} = obj.dbase.ChannelLoader{selectedChannelNum1};
            end
        end

        if ~isempty(selectedChannelNum2) && selectedChannelNum2 ~= 0
            % Add whatever channel is selected in axes2 to list
            filesInCache{end+1} = fullfile(obj.dbase.PathName, obj.dbase.ChannelFiles{selectedChannelNum2}(filenum).name);
            if isSound2
                loadersInCache{end+1} = obj.dbase.SoundLoader;
            else
                loadersInCache{end+1} = obj.dbase.ChannelLoader{selectedChannelNum2};
            end
        end
    end

    % Check if any unnecessary files are in the cache. If so, remove them.
    stale_idx = [];
    for k = 1:length(obj.file_cache)
        if ~any(strcmp(obj.file_cache(k).filepaths, filesInCache) & strcmp(obj.file_cache(k).loaders, loadersInCache))
            % This cache element is no longer needed.
            stale_idx(end+1) = k;
        end
    end
    % Remove unneeded cache elements
    obj.file_cache(stale_idx) = [];

    % Check if each necessary file is in the cache. If not, add it.
    for k = 1:length(filesInCache)
        if ~obj.isFileInCache(filesInCache{k}, loadersInCache{k})
            obj.addToFileCache(filesInCache{k}, loadersInCache{k});
        end
    end
end

function resetFileCache(obj)
    % Reset cache to empty state (or create it if it doesn't exist)
    obj.file_cache = struct.empty();
    obj.file_cache(1).filepaths = '';
    obj.file_cache(1).loaders = '';
    obj.file_cache(1).data = [];
    obj.file_cache(1).data_future = parallel.FevalFuture;
    obj.file_cache(:) = [];
end

function LoadFile(obj, showWaitBar)
    arguments
        obj electro_gui
        showWaitBar (1, 1) logical = true
    end

    if showWaitBar
        progressBar = waitbar(0, 'Loading file...', 'WindowStyle', 'modal');
    end

    if obj.settings.EnableFileCaching
        obj.refreshFileCache();
    end

    if showWaitBar
        waitbar(0.3, progressBar);
    end

    filenum = electro_gui.getCurrentFileNum(obj.settings);
    obj.FileInfoBrowser.SelectedRow = filenum;

    % Remove unread file marker from filename
    obj.setFileReadState(filenum, true);

    % Label
    obj.text_FileName.String = obj.dbase.SoundFiles(filenum).name;

    % Load sound
    obj.sound = [];

    % Update file notes
    obj.updateFileNotes();

    soundFilePath = fullfile(obj.dbase.PathName, obj.dbase.SoundFiles(filenum).name);

    try
        obj.UpdateFilteredSound();
    catch ME
        if ~exist(soundFilePath, 'file')
            error('File not found: %s', soundFilePath);
        else
            rethrow(ME);
        end
    end
    if showWaitBar
        waitbar(0.5, progressBar);
    end

    [numSamples, fs] = obj.eg_GetSamplingInfo();

    obj.dbase.FileLength(filenum) = numSamples;
    obj.text_DateAndTime.String = string(datetime(obj.dbase.Times(filenum), 'ConvertFrom', 'datenum'));

    obj.RedrawSoundEnvelope();

    obj.clearAxes();

    tmax = numSamples/fs;
    obj.settings.TLim = [0, tmax];

    obj.PlotAnnotations();

    if showWaitBar
        waitbar(0.6, progressBar);
    end

    % Define callbacks
    obj.setClickSoundCallback(obj.axes_Sonogram);
    obj.setClickSoundCallback(obj.axes_Sound);

    % Plot channels
    obj.eg_LoadChannel(1);
    obj.eg_LoadChannel(2);

    if showWaitBar
        waitbar(0.7, progressBar);
    end

    obj.updateAmplitude('ForceRedraw', true);

    obj.UpdateTimescaleView();

    if showWaitBar
        waitbar(1, progressBar);
        close(progressBar);
    end
end

function clearAxes(obj)
    % Delete old plots
    cla(obj.axes_Sonogram);
    set(obj.axes_Sonogram,'ButtonDownFcn','%','UIContextMenu','');
    cla(obj.axes_Amplitude);
    set(obj.axes_Amplitude,'ButtonDownFcn','%','UIContextMenu','');
    cla(obj.axes_Segments);
    set(obj.axes_Segments,'ButtonDownFcn','%','UIContextMenu','');
    cla(obj.axes_Channel1);
    set(obj.axes_Channel1,'ButtonDownFcn','%','UIContextMenu','');
    cla(obj.axes_Channel2);
    set(obj.axes_Channel2,'ButtonDownFcn','%','UIContextMenu','');
    cla(obj.axes_Events);
    set(obj.axes_Events,'ButtonDownFcn','%','UIContextMenu','');
end

function UpdateChannelPopups(obj)
    % Update the channel selection popups based on stored channel info
    for axnum = 1:2
        channelDisplayNames = cell(1, length(obj.dbase.ChannelInfo));
        for channelIdx = 1:length(obj.dbase.ChannelInfo)
            channelInfo = obj.dbase.ChannelInfo(channelIdx);
            if ~channelInfo.IsPseudoChannel
                channelDisplayNames{channelIdx} = channelInfo.Name;
            else
                pseudoChannelInfo = channelInfo.PseudoChannelInfo;
                channelDisplayNames{channelIdx} = ...
                    sprintf('%s - %s (%s)', channelInfo.Name, ...
                                            pseudoChannelInfo.type, ...
                                            pseudoChannelInfo.description);
            end
        end
        obj.popup_Channels(axnum).String = channelDisplayNames;
    end
end

function eventParts = getSelectedEventParts(obj, axnum)
    % Get the labels for the event parts for the given channel axes
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a know event source
        % Get default params from event detector
        eventDetector = obj.getSelectedEventDetector(axnum);
        if ~isempty(eventDetector)
            [~, eventParts] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, eventDetector, 'params');
        else
            eventParts = {};
        end
    else
        eventParts = obj.dbase.EventParts{eventSourceIdx};
    end
end
function threshold = getDefaultEventThreshold(obj, axnum)
    % Get the default threshold for the event source of the given channel axes
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a known event source
        threshold = inf;
    else
        threshold = obj.settings.EventThresholdDefaults(eventSourceIdx);
    end
end

function selectedFunctionParameters = getSelectedFunctionParameters(obj, axnum)
    % Get the function parameters for the given channel axes
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a know event source
        % Use temporary axes params instead
        selectedFunctionParameters = obj.settings.ChannelAxesFunctionParams{axnum};
        if isempty(selectedFunctionParameters)
            % Get default params from event detector
            functionName = obj.getSelectedFilter(axnum);
            if ~isempty(functionName)
                selectedFunctionParameters = electro_gui.eg_runPlugin(obj.plugins.filters, functionName, 'params');
            else
                selectedFunctionParameters = struct.empty();
            end
            % Store for next time
            obj.settings.ChannelAxesFunctionParams{axnum} = selectedFunctionParameters;
        end
    else
        selectedFunctionParameters = obj.dbase.EventFunctionParameters{eventSourceIdx};
    end
end
function selectedEventParameters = getSelectedEventParameters(obj, axnum)
    % Get the event parameters for the given channel axes
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a know event source
        % Use temporary axes params instead
        selectedEventParameters = obj.settings.ChannelAxesEventParams{axnum};
        if isempty(selectedEventParameters)
            % Get default params from event detector
            eventDetector = obj.getSelectedEventDetector(axnum);
            if ~isempty(eventDetector)
                selectedEventParameters = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, eventDetector, 'params');
            else
                selectedEventParameters = struct.empty();
            end
            % Store for next time
            obj.settings.ChannelAxesEventParams{axnum} = selectedEventParameters;
        end
    else
        selectedEventParameters = obj.dbase.EventParameters{eventSourceIdx};
    end
end
function selectedEventLims = getSelectedEventLims(obj, axnum)
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % Use temporary axes params instead
        selectedEventLims = obj.settings.DefaultEventXLims;
    else
        selectedEventLims = obj.settings.EventXLims(eventSourceIdx, :);
    end
end


function [selectedChannelNum, selectedChannelName, isSound, isPseudoChannel] = getSelectedChannel(obj, axnum)
    % Return the name and number of the selected channel from the specified
    %   axis. If the name is not a valid channel, selectedChannelNum will be
    %   empty.
    channelNameList = {obj.dbase.ChannelInfo.Name};
    channelInfoList = obj.dbase.ChannelInfo;

    selectedIdx = obj.popup_Channels(axnum).Value;

    selectedChannelName = channelNameList{selectedIdx};
    selectedChannelInfo = channelInfoList(selectedIdx);
    isPseudoChannel = selectedChannelInfo.IsPseudoChannel;
    selectedChannelNum = selectedChannelInfo.Number;

    if isPseudoChannel
        isSound = false;
    else
        isSound = electro_gui.isChannelSound(selectedChannelNum);
    end
end

function selectedEventDetector = getSelectedEventDetector(obj, axnum)
    % Return the name of the selected event detector from the specified axis.
    eventDetectorOptionList = obj.popup_EventDetectors(axnum).String;
    eventDetectorOptionListIndex = obj.popup_EventDetectors(axnum).Value;
    if eventDetectorOptionListIndex == 1
        % No event detector selected
        selectedEventDetector = '';
    else
        selectedEventDetector = eventDetectorOptionList{eventDetectorOptionListIndex};
    end
end
function selectedFilter = getSelectedFilter(obj, axnum)
    % Return the name of the selected event detector function (filter) from the
    %   specified axis.
    fiterOptionList = obj.popup_Functions(axnum).String;
    filterOptionListIndex = obj.popup_Functions(axnum).Value;
    if filterOptionListIndex == 1
        % No filter selected
        selectedFilter = '';
    else
        selectedFilter = fiterOptionList{filterOptionListIndex};
    end
end
function setSelectedEventDetector(obj, axnum, eventDetectorName)
    % Set the currently selected event detector for the selected axis
    eventDetectorOptionList = obj.popup_EventDetectors(axnum).String;
    newIndex = find(strcmp(eventDetectorOptionList, eventDetectorName));
    if isempty(newIndex)
        error('Error: Could not set selected event detector to ''%s'', as it is not in the option list.', eventDetectorName);
    end
    obj.popup_EventDetectors(axnum).Value = newIndex;
end
function setSelectedFilter(obj, axnum, filterName)
    % Set the currently selected filter for the selected axis
    filterOptionList = obj.popup_Functions(axnum).String;
    newIndex = find(strcmp(filterOptionList, filterName));
    if isempty(newIndex)
        error('Error: Could not set selected filter to ''%s'', as it is not in the option list.', filterName);
    end
    obj.popup_Functions(axnum).Value = newIndex;
end
function setSelectedChannel(obj, axnum, channelName)
    % Set the currently selected filter for the selected axis
    channelOptionList = obj.popup_Channels(axnum).String;
    if ischar(channelOptionList)
        channelOptionList = {channelOptionList};
    end
    newIndex = find(strcmp(channelOptionList, channelName));
    if isempty(newIndex)
        error('Error: Could not set selected channel to ''%s'', as it is not in the option list.', filter);
    end
    obj.popup_Channels(axnum).Value = newIndex;
end

function setSelectedEventFunction(obj, axnum, eventFunction)
    % Set the currently selected event function for the selected axis
    eventFunctionOptionList = obj.popup_Functions(axnum).String;
    newIndex = find(strcmp(eventFunctionOptionList, eventFunction));
    if isempty(newIndex)
        error('Error: Could not set selected event function to ''%s'', as it is not in the option list.', eventFunction);
    end
    obj.popup_Functions(axnum).Value = newIndex;
end

function algorithm = getSelectedSoundFilter(obj)
    % Get sound filter algorithm currently selected in the GUI
    for k = 1:length(obj.menu_Filter)
        if obj.menu_Filter(k).Checked
            algorithm = obj.menu_Filter(k).Label;
            break;
        end
    end
end


function [channelData, channelSamplingRate, channelLabels, timestamp] = loadChannelData(obj, ...
                channelNum, options)
    arguments
        obj electro_gui
        channelNum double
        options.FilterName char = ''
        options.FilterParams struct = struct()
        options.FileNum double = electro_gui.getCurrentFileNum(obj.settings)
        options.IsPseudoChannel (1, 1) logical = false
    end
    fileNum = options.FileNum;
    filterParams = options.FilterParams;
    filterName = options.FilterName;
    isPseudoChannel = options.IsPseudoChannel;

    if isPseudoChannel
        % This is a pseudochannel - load it based on type
        channelIdx = electro_gui.getChannelIdxFromPseudoChannelNumber(obj.dbase, channelNum);
        pChannelInfo = obj.dbase.ChannelInfo(channelIdx).PseudoChannelInfo;
        switch pChannelInfo.type
            case 'event'
                % This is an "event" type of pseudochannel - it will be a
                % logical array with a "true" wherever an event in the base
                % channel occurred.
                eventSourceIdx = pChannelInfo.eventSourceIdx;
                eventPartIdx = pChannelInfo.eventPartIdx;
                [channelNum, ~, ~, ~, ~, ~, ~, ~, isSourcePseudoChannel] = obj.GetEventSourceInfo(eventSourceIdx);
                [numSamples, channelSamplingRate] = obj.eg_GetSamplingInfo(fileNum, channelNum, isSourcePseudoChannel);
                rawChannelData = zeros(numSamples, 1);
                eventTimes = obj.dbase.EventTimes{eventSourceIdx}{eventPartIdx, fileNum};
                rawChannelData(eventTimes) = 1;
                channelLabels = '';
                timestamp = '';
            otherwise
                error('PseudoChannel type %s not recognized', pChannelType);
        end
    else
        % Check if this channel represents sound
        isSound = electro_gui.isChannelSound(channelNum);
        if isSound
            % Load using the specified sound loader
            loader = obj.dbase.SoundLoader;
            filePath = fullfile(obj.dbase.PathName, obj.dbase.SoundFiles(fileNum).name);
        else
            % Load using the specified channel data loader
            loader = obj.dbase.ChannelLoader{channelNum};
            filePath = fullfile(obj.dbase.PathName, obj.dbase.ChannelFiles{channelNum}(fileNum).name);
        end

        if obj.settings.EnableFileCaching
            % File is already cached - retrieve data
            data = obj.retrieveFileFromCache(filePath, loader);
            [rawChannelData, channelSamplingRate, timestamp, channelLabels, ~] = data{:};
        else
            % File is not cached - load data
            [rawChannelData, channelSamplingRate, timestamp, channelLabels, ~] = electro_gui.eg_runPlugin(obj.plugins.loaders, loader, filePath, true);
        end
    end

    if isempty(filterName)
        % Raw data requested
        channelData = rawChannelData;
    else
        % Filter data
        [channelData, channelLabels] = electro_gui.eg_runPlugin(obj.plugins.filters, filterName, rawChannelData, channelSamplingRate, filterParams);

        % Resample data? This seems bad.
        if length(channelData) < length(rawChannelData)
            warning('Filter seems to be shortening channel data?')
            indx = fix(linspace(1, length(channelData), length(rawChannelData)));
            channelData = channelData(indx);
        end
    end
end

function eg_LoadChannel(obj, axnum)
    % Load a new channel of data

    if isempty(obj.getSelectedChannel(axnum))
        % This is "(None)" channel selection, so disable everything
        cla(obj.axes_Channel(axnum));
        obj.axes_Channel(axnum).Visible = 'off';
        obj.popup_Functions(axnum).Enable = 'off';
        obj.popup_EventDetectors(axnum).Enable = 'off';
        obj.push_Detects(axnum).Enable = 'off';
        obj.menu_Events(axnum).Enable = 'off';
        obj.settings.ActiveEventNum = [];
        obj.settings.ActiveEventPartNum = [];
        obj.settings.ActiveEventSourceIdx = [];
        obj.loadedChannelData{axnum} = [];
        obj.UpdateEventViewer();
        return
    else
        % This is an actual channel selection, enable the axes and function
        % menu.
        obj.axes_Channel(axnum).Visible = 'on';
        obj.popup_Functions(axnum).Enable = 'on';
    end

    % Load channel data
    [selectedChannelNum, ~, ~, isPseudoChannel] = obj.getSelectedChannel(axnum);
    selectedFilter = getSelectedFilter(obj, axnum);
    selectedFilterParams = obj.settings.ChannelAxesFunctionParams{axnum};
    [obj.loadedChannelData{axnum}, obj.loadedChannelFs{axnum}, obj.loadedChannelLabels{axnum}] = ...
        obj.loadChannelData(selectedChannelNum, ...
        'FilterName', selectedFilter, ...
        'FilterParams', selectedFilterParams, ...
        'IsPseudoChannel', isPseudoChannel);

    % Plot channel data
    obj.eg_PlotChannel(axnum);

    % Reset active event handles
    obj.settings.ActiveEventNum = [];
    obj.settings.ActiveEventPartNum = [];

    obj.updateEventThresholdInAxes(axnum);
    obj.AutoDetectEvents(axnum);

    % Update event display
    obj.UpdateChannelEventDisplay(axnum);

    % Adjust axes limits
    if obj.menu_AutoLimits(axnum).Checked
        yl = [min(obj.loadedChannelData{axnum}), max(obj.loadedChannelData{axnum})];
        if yl(1)==yl(2)
            yl = [yl(1)-1 yl(2)+1];
        end
        ylim(obj.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        obj.ChanYLimits(axnum, :) = ylim(obj.axes_Channel(axnum));
    else
        ylim(obj.axes_Channel(axnum), obj.ChanYLimits(axnum, :));
    end

    % If overlay is requested, overlay channel data on another axes
    obj.eg_Overlay();

    % Clear existing event waves
    obj.clearEventWaveHandles();

    % Update event viewer in case it was showing data from this axes
    obj.UpdateEventViewer();
end

function [numSamples, fs] = eg_GetSamplingInfo(obj, filenum, chan, isPseudoChannel)
    % Get the number of samples and sampling info for the specified file
    % and channel number. If filenumber is empty or omitted, the currently
    % loaded filenum will be used. If chan is empty or omitted, whatever
    % channel is being used for sound is used.
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end
    if ~exist('isPseudoChannel', 'var') || isempty(isPseudoChannel)
        isPseudoChannel = false;
    end
    if ~exist('chan', 'var') || isempty(chan)
        [data, fs] = obj.getSound([], filenum, isPseudoChannel);
    else
        [data, fs] = obj.loadChannelData(chan, 'FileNum', filenum, 'IsPseudoChannel', isPseudoChannel);
    end
    numSamples = length(data);
end

function [sound, fs, timestamp] = getSound(obj, soundChannel, filenum, isPseudoChannel)
    arguments
        obj electro_gui
        soundChannel = []
        filenum double = []
        isPseudoChannel (1, 1) logical = false
    end
    if isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end
    if isempty(soundChannel)
        soundChannel = obj.settings.SoundChannel;
    end
    if ischar(soundChannel)
        % User must have passed a channel name here - convert to channel
        % num instead
        [soundChannel, isPseudoChannel] = electro_gui.channelNameToNum(obj.dbase, soundChannel);
    end

    % Fetch sound based on which sound channel was selected
    if soundChannel == 0 && ~isPseudoChannel
        % Use channel 0 (the normal sound channel)
        filePath = fullfile(obj.dbase.PathName, obj.dbase.SoundFiles(filenum).name);
        loader = obj.dbase.SoundLoader;

        if obj.settings.EnableFileCaching
            data = obj.retrieveFileFromCache(filePath, loader);
            [sound, fs, timestamp] = data{:};
        else
            [sound, fs, timestamp] = electro_gui.eg_runPlugin(obj.plugins.loaders, loader, filePath, true);
        end
    elseif strcmp(soundChannel, 'calculated')
        % Calculate a sound vector based on the user-supplied
        % expression in obj.settings.SoundExpression
        [sound, fs, timestamp] = obj.getCalculatedSound(filenum);
    else
        % Use some other not-already-loaded channel data as sound
        [sound, fs, ~, timestamp] = obj.loadChannelData(soundChannel, 'FileNum', filenum, 'IsPseudoChannel', isPseudoChannel);
    end

    if size(sound,2) > size(sound,1)
        sound = sound';
    end
end

function [filteredSound, fs, timestamp] = getFilteredSound(obj, sound, algorithm, filterParams, filenum)
    arguments
        obj electro_gui
        sound = []
        algorithm = ''
        filterParams = obj.settings.FilterParams
        filenum = electro_gui.getCurrentFileNum(obj.settings)
    end
    if isempty(sound)
        [sound, fs, timestamp] = obj.getSound([], filenum);
    else
        if ischar(sound)
            % User passed in a channel name - get raw sound
            soundChannel = electro_gui.channelNameToNum(obj.dbase, sound);
            [sound, fs, timestamp] = obj.getSound(soundChannel, filenum);
        elseif isnumeric(sound) && length(sound) == 1
            % User passed in a channel number - get raw sound
            soundChannel = sound;
            [sound, fs, timestamp] = obj.getSound(soundChannel, filenum);
        else
            % User passed in a sound time series
            fs = obj.dbase.Fs;
            timestamp = [];
        end
    end
    if isempty(algorithm)
        % Get currently selected sound filter algorithm
        for k = 1:length(obj.menu_Filter)
            if obj.menu_Filter(k).Checked
                algorithm = obj.menu_Filter(k).Label;
                break;
            end
        end
    end

    filteredSound = obj.filterSound(sound, fs, algorithm, filterParams);
end

function [calculatedSound, fs, timestamp] = getCalculatedSound(obj, filenum, useFilter)
    % Calculate a sound vector based on the user-supplied
    % expression in obj.settings.SoundExpression
    arguments
        obj electro_gui
        filenum = electro_gui.getCurrentFileNum(obj.settings)
        useFilter = false
    end

    % Define all the variables used in the user-supplied expression
    sourceIndices = obj.popup_SoundSource.UserData;
    for k = 1:(length(sourceIndices)-1)
        channelNum = sourceIndices{k};
        switch channelNum
            case 0
                varName = 'sound';
            otherwise
                varName = sprintf('chan%d', channelNum);
        end
        if regexp(obj.settings.SoundExpression, varName)
            if strcmp(varName, 'sound')
                if useFilter
                    [data, fs, timestamp] = obj.getFilteredSound([], [], [], filenum);
                else
                    [data, fs, timestamp] = obj.getSound([], filenum);
                end
            else
                [data, fs, timestamp] = obj.loadChannelData(channelNum, 'FileNum', filenum);
            end
            assignin('base', varName, data);
        end
    end
    % Evaluate the user-supplied expression
    try
        calculatedSound = evalin('base', obj.settings.SoundExpression);
    catch ME
        fprintf('Error evaluating calculated channel: %s\n', obj.settings.SoundExpression);
        disp(ME)
        fprintf('Using default sound instead.\n');
        [calculatedSound, fs, timestamp] = obj.getFilteredSound([], [], [], filenum);
    end
end

function UpdateSound(obj, soundChannel)
    % Update the obj.sound field with the timeseries specified by
    %   soundChannel to use as sound for the purposes of plotting the
    %   spectrogram, etc.
    arguments
        obj electro_gui
        soundChannel = obj.settings.SoundChannel
    end

    [sound, fs, timestamp] = obj.getSound(soundChannel);
    obj.sound = sound;
    obj.dbase.Fs = fs;
    filenum = electro_gui.getCurrentFileNum(obj.settings);
    obj.dbase.Times(filenum) = timestamp;
end

function filtered_sound = filterSound(obj, sound, fs, algorithm, filterParams)
    % Apply a filtering algorithm to a sound vector
    arguments
        obj electro_gui
        sound
        fs = obj.dbase.Fs
        algorithm = obj.getSelectedSoundFilter()
        filterParams = obj.settings.FilterParams
    end
    % Run sound through filter algorithm
    filtered_sound = electro_gui.eg_runPlugin(obj.plugins.filters, algorithm, sound, fs, filterParams);
end

function UpdateFilteredSound(obj)
    % Update the obj.filtered_sound field
    obj.UpdateSound();
    obj.filtered_sound = obj.filterSound(obj.sound);
end

function RedrawSoundEnvelope(obj)
    % Redraw the sound envelope on the top navigation axes
    [numSamples, fs] = obj.eg_GetSamplingInfo();
    h = electro_gui.eg_peak_detect(obj.axes_Sound, linspace(0, numSamples/fs, numSamples), obj.filtered_sound);

    [h.Color] = deal('c');
    obj.axes_Sound.XTick = [];
    obj.axes_Sound.YTick = [];
    obj.axes_Sound.Color = [0 0 0];
    axis(obj.axes_Sound, 'tight');
    yl = max(abs(ylim(obj.axes_Sound)));
    ylim(obj.axes_Sound, [-yl*1.2, yl*1.2]);

    box(obj.axes_Sound, 'on');
end

function eg_PlotChannel(obj, axnum)
    ax = obj.axes_Channel(axnum);

    if ~ax.Visible
        return
    end
    ax.Visible = 'on';
    obj.popup_Functions(axnum).Enable = 'on';
    obj.popup_EventDetectors(axnum).Enable = 'on';
    obj.push_Detects(axnum).Enable = 'on';

    chan = obj.getSelectedChannel(axnum);
    [numSamples, fs] = obj.eg_GetSamplingInfo([], chan);
    t = linspace(0, numSamples/fs, numSamples);
    tlimits = ax.XLim;
    delete(obj.ChannelPlots{axnum});
    obj.ChannelPlots{axnum} = gobjects().empty;
    hold(ax, 'on');
    if obj.menu_PeakDetects(axnum).Checked
        % Plot peak detection trace
        visibleTimeIdx = find(t>=tlimits(1) & t<=tlimits(2));
        if ~isempty(visibleTimeIdx)
            obj.ChannelPlots{axnum} = electro_gui.eg_peak_detect(ax, t(visibleTimeIdx), obj.loadedChannelData{axnum}(visibleTimeIdx));
        end
    else
        % Plot plain data
        obj.ChannelPlots{axnum} = ...
            plot(ax, t, obj.loadedChannelData{axnum}, ...
                'Color',obj.settings.ChannelColor(axnum,:), ...
                'LineWidth',obj.settings.ChannelLineWidth(axnum));
    end

    hold(ax, 'off');
    xlim(ax, tlimits);

    ax.XTickLabel = [];
    box(ax, 'off');
    ylabel(ax, obj.loadedChannelLabels{axnum});

    ax.UIContextMenu = obj.context_Channels(axnum);
    ax.ButtonDownFcn = @obj.click_Channel;
    set(ax.Children, 'UIContextMenu', ax.UIContextMenu);
    set(ax.Children, 'ButtonDownFcn', ax.ButtonDownFcn);
end

function SetSegmentThreshold(obj)
    % Clear segments axes
    cla(obj.axes_Segments);

    if isempty(obj.SegmentThresholdHandle) || ~isvalid(obj.SegmentThresholdHandle) || ~isgraphics(obj.SegmentThresholdHandle)
        % No threshold line has been created yet
        ax = obj.axes_Amplitude;
        hold(ax, 'on')
        xl = xlim(ax);
        % Create new threshold line
        [numSamples, fs] = obj.eg_GetSamplingInfo();
        obj.SegmentThresholdHandle = plot(ax, [0, numSamples/fs], ...
            [obj.settings.CurrentThreshold, obj.settings.CurrentThreshold], ...
            ':', 'Color',obj.settings.AmplitudeThresholdColor);
        xlim(ax, xl);
        hold(ax, 'off');

        % Check if there are any segment times recorded
        if size(obj.dbase.SegmentTimes{electro_gui.getCurrentFileNum(obj.settings)},2)==0
            % No segment times found
            if obj.menu_AutoSegment.Checked
                % User has requested auto-segmentation. Auto segment!
                obj.SegmentSounds();
            end
        else
            % Segment times already exist, just plot them (probably preexisting
            % from loaded dbase?)
            obj.PlotAnnotations();
        end
    else
        % Threshold line already exists, just update its Y position
        obj.SegmentThresholdHandle.YData = [obj.settings.CurrentThreshold obj.settings.CurrentThreshold];
        if obj.menu_AutoSegment.Checked
            % User has requested auto-segmentation. Auto-segment!
            obj.SegmentSounds();
        end
    end

    % Link segment context menu to segment axes
    obj.axes_Segments.UIContextMenu = obj.context_Segments;
    obj.axes_Segments.ButtonDownFcn = @obj.click_segmentaxes;
end

function SegmentSounds(obj, updateGUI)
    arguments
        obj electro_gui
        updateGUI = true
    end

    for c = 1:length(obj.menu_SegmenterList.Children)
        if obj.menu_SegmenterList.Children(c).Checked
            segmentationAlgorithmName = obj.menu_SegmenterList.Children(c).Label;
        end
    end

    [sound, fs] = obj.getSound();

    filenum = electro_gui.getCurrentFileNum(obj.settings);
    obj.settings.SegmenterParams.IsSplit = 0;
    obj.dbase.SegmentTimes{filenum} = electro_gui.eg_runPlugin(obj.plugins.segmenters, ...
        segmentationAlgorithmName, sound, obj.amplitude, fs, obj.settings.CurrentThreshold, ...
        obj.settings.SegmenterParams);
    obj.dbase.SegmentTitles{filenum} = cell(1,size(obj.dbase.SegmentTimes{filenum},1));
    obj.dbase.SegmentIsSelected{filenum} = ones(1,size(obj.dbase.SegmentTimes{filenum},1));

    if updateGUI
        obj.PlotAnnotations();
    end
end

function [annotationHandles, labelHandles] = CreateAnnotations(obj, ax, times, titles, selects, selectColor, unselectColor, activeColor, inactiveColor, yExtent, activeIndex)
    % Create the annotations for a set of timed segments (used for plotting both
    % "segments" and "markers")

    if ~exist('activeIndex', 'var')
        activeIndex = [];
    end

    % Create a time vector that corresponds to the loaded audio samples
    numSamples = obj.eg_GetSamplingInfo();
    ts = linspace(0, numSamples/obj.dbase.Fs, numSamples);

    y0 = yExtent(1);
    y1 = yExtent(1) + (yExtent(2) - yExtent(1))*0.3;
    % y2 = yExtent(2);

    annotationHandles = gobjects().empty;
    labelHandles = gobjects().empty;

    % Loop over stored segment start/end times pairs
    for annotationNum = 1:size(times,1)
        % Extract the start (x1) and end (x2) times of this segment
        t1 = ts(times(annotationNum,1));
        t2 = ts(times(annotationNum,2));
        if selects(annotationNum)
            faceColor = selectColor;
        else
            faceColor = unselectColor;
        end
        % Create a rectangle to represent the segment
        newAnnotation = patch(ax, [t1 t2 t2 t1], [y0 y0 y1 y1], faceColor, 'ContextMenu', ax.ContextMenu);
        % Create a text graphics object right above the middle of the segment
        % rectangle
        newLabel = text(ax, (t1+t2)/2,y1,titles(annotationNum), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'ContextMenu', ax.ContextMenu);

        % Set annotation style to inactive
        if activeIndex == annotationNum
            newAnnotation.EdgeColor = activeColor;
            newAnnotation.LineWidth = 2;
            newAnnotation.LineStyle = '-';
        else
            newAnnotation.EdgeColor = inactiveColor;
            newAnnotation.LineWidth = 1;
            newAnnotation.LineStyle = '-';
        end

        % Attach click handler "click_segment" to segment rectangle
        newAnnotation.ButtonDownFcn = @obj.click_segment;
        newLabel.ButtonDownFcn = @(hObject, event)electro_gui.click_segment(newAnnotation, event);

        % Put new handles in list
        labelHandles(annotationNum) = newLabel;
        annotationHandles(annotationNum) = newAnnotation;
    end
end

function UpdateAnnotationTitleDisplay(obj, annotationNums, annotationType, filenum)
    % A function for updating only one or more annotation titles
    % Use this cautiously, only if you're sure the only change that needs
    % updating is a single title. If more things have changed, use
    % PlotAnnotations instead to fully refresh.
    arguments
        obj electro_gui
        annotationNums = obj.FindActiveAnnotation()
        annotationType = obj.FindActiveAnnotationType()
        filenum = electro_gui.getCurrentFileNum(obj.settings)
    end

    if strcmp(annotationNums, 'all')
        numAnnotations = obj.GetNumAnnotations(annotationType);
        annotationNums = 1:numAnnotations;
    end

    switch annotationType
        case 'segment'
            for annotationNum = annotationNums
                obj.SegmentLabelHandles(annotationNum).String = obj.dbase.SegmentTitles{filenum}(annotationNum);
            end
        case 'marker'
            for annotationNum = annotationNums
                obj.MarkerLabelHandles(annotationNum).String = obj.dbase.MarkerTitles{filenum}(annotationNum);
            end
        case 'none'
            % Do nothing
            return;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end
function UpdateActiveAnnotationDisplay(obj, oldAnnotationNum, oldAnnotationType, newAnnotationNum, newAnnotationType)
    % A function for updating only the active annotation highlight
    % Use this cautiously, only if you're sure the only change that needs
    % updating is the highlight. If more things have changed, use
    % PlotAnnotations instead to fully refresh.
    if ~exist('oldAnnotationNum', 'var') || isempty(oldAnnotationNum)
        % No annotation number provided - use the currently active one
        [oldAnnotationNum, ~] = obj.FindActiveAnnotation();
    end
    if ~exist('oldAnnotationType', 'var') || isempty(oldAnnotationType)
        % No annotation type provided - use the currently active type
        [~, oldAnnotationType] = obj.FindActiveAnnotation();
    end
    if ~exist('newAnnotationNum', 'var') || isempty(newAnnotationNum)
        % No annotation number provided - use the currently active one
        [newAnnotationNum, ~] = obj.FindActiveAnnotation();
    end
    if ~exist('newAnnotationType', 'var') || isempty(newAnnotationType)
        % No annotation type provided - use the currently active type
        [~, newAnnotationType] = obj.FindActiveAnnotation();
    end

    % Update old active segment display to inactive
    switch oldAnnotationType
        case 'segment'
            obj.SegmentHandles(oldAnnotationNum).EdgeColor = obj.settings.SegmentInactiveColor;
            obj.SegmentHandles(oldAnnotationNum).LineWidth = 1;
            obj.SegmentHandles(oldAnnotationNum).LineStyle = '-';
        case 'marker'
            obj.MarkerHandles(oldAnnotationNum).EdgeColor = obj.settings.MarkerInactiveColor;
            obj.MarkerHandles(oldAnnotationNum).LineWidth = 1;
            obj.MarkerHandles(oldAnnotationNum).LineStyle = '-';
        case 'none'
            % Do nothing
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    switch newAnnotationType
        case 'segment'
            obj.SegmentHandles(newAnnotationNum).EdgeColor = obj.settings.SegmentActiveColor;
            obj.SegmentHandles(newAnnotationNum).LineWidth = 2;
            obj.SegmentHandles(newAnnotationNum).LineStyle = '-';
            activeAnnotationTimes = obj.dbase.SegmentTimes{filenum}(newAnnotationNum, :) / obj.dbase.Fs;
        case 'marker'
            obj.MarkerHandles(newAnnotationNum).EdgeColor = obj.settings.SegmentInactiveColor;
            obj.MarkerHandles(newAnnotationNum).LineWidth = 2;
            obj.MarkerHandles(newAnnotationNum).LineStyle = '-';
            activeAnnotationTimes = obj.dbase.MarkerTimes{filenum}(newAnnotationNum, :) / obj.dbase.Fs;
        case 'none'
            % Do nothing
            return;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end

    % Make sure active annotation is not off-screen
    if any(min(obj.settings.TLim) > activeAnnotationTimes)
        % Active annotation is off screen to the left
        activeAnnotationEdge = activeAnnotationTimes(1);
        obj.setTimeViewEdge(activeAnnotationEdge, 'left');
        obj.UpdateTimescaleView();
    elseif any(max(obj.settings.TLim) < activeAnnotationTimes)
        % Active annotation is off screen to the right
        activeAnnotationEdge = activeAnnotationTimes(2);
        obj.setTimeViewEdge(activeAnnotationEdge, 'right');
        obj.UpdateTimescaleView();
    end
end

function PlotAnnotations(obj, modes)
    % Get segment axes
    ax = obj.axes_Segments;

    % Set axes properties
    hold(ax, 'on');
    % Set time-zoom state of segment axes to match audio axes
    xlim(ax, obj.settings.TLim);
    % Set y-scale of axes
    ylim(ax, [-2 3.5]);
    % Get figure background color
    % Set segment axes background & axis colors to the figure background color, I guess to hide them
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    ax.Color = 'none';
    % Assign context menu and click listener to segment axes
    ax.ButtonDownFcn = @obj.click_segmentaxes;
    ax.UIContextMenu = obj.context_Segments;
    % Assign key press function to figure (keyPressHandler) for labeling segments
    obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;

    % Clear segment handles and segment label handles
    delete(obj.SegmentHandles);
    obj.SegmentHandles = gobjects().empty;
    delete(obj.SegmentLabelHandles);
    obj.SegmentLabelHandles = gobjects().empty;
    % Clear marker handles and marker label handles
    delete(obj.MarkerHandles);
    obj.MarkerHandles = gobjects().empty;
    delete(obj.MarkerLabelHandles);
    obj.MarkerLabelHandles = gobjects().empty;

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    [obj.SegmentHandles, obj.SegmentLabelHandles] = obj.CreateAnnotations(...
        obj.axes_Segments, ...
        obj.dbase.SegmentTimes{filenum}, ...
        obj.dbase.SegmentTitles{filenum}, ...
        obj.dbase.SegmentIsSelected{filenum}, ...
        obj.settings.SegmentSelectColor, obj.settings.SegmentUnSelectColor, ...
        obj.settings.SegmentActiveColor, obj.settings.SegmentInactiveColor, [-1, 1]);

    [obj.MarkerHandles, obj.MarkerLabelHandles] = obj.CreateAnnotations(...
        obj.axes_Segments, ...
        obj.dbase.MarkerTimes{filenum}, ...
        obj.dbase.MarkerTitles{filenum}, ...
        obj.dbase.MarkerIsSelected{filenum}, ...
        obj.settings.MarkerSelectColor, obj.settings.MarkerUnSelectColor, ...
        obj.settings.SegmentInactiveColor, obj.settings.MarkerInactiveColor, [1, 3]);

    % Ensure active annotation setting is valid
    obj.SanityCheckActiveAnnotation(filenum);

    % Update active segment highlight
    if ~isempty(obj.settings.ActiveSegmentNum)
        obj.SegmentHandles(obj.settings.ActiveSegmentNum).EdgeColor = obj.settings.SegmentActiveColor;
        obj.SegmentHandles(obj.settings.ActiveSegmentNum).LineWidth = 2;
        obj.SegmentHandles(obj.settings.ActiveSegmentNum).LineStyle = '-';
    end
    % Update active marker highlight
    if ~isempty(obj.settings.ActiveMarkerNum)
        obj.MarkerHandles(obj.settings.ActiveMarkerNum).EdgeColor = obj.settings.SegmentInactiveColor;
        obj.MarkerHandles(obj.settings.ActiveMarkerNum).LineWidth = 2;
        obj.MarkerHandles(obj.settings.ActiveMarkerNum).LineStyle = '-';
    end

    hold(ax, 'off');
end

function SanityCheckActiveAnnotation(obj, filenum)
    % Make sure the obj.settings.ActiveSegmentNum and obj.settings.ActiveMarkerNum
    % make sense

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    numSegments = obj.GetNumAnnotations('segment', filenum);
    numMarkers = obj.GetNumAnnotations('marker', filenum);
    if isempty(obj.settings.ActiveSegmentNum) && isempty(obj.settings.ActiveMarkerNum)
        % Nothing is active - make 1st segment active if there are any
        if numSegments > 0
            obj.settings.ActiveSegmentNum = 1;
        end
    elseif isempty(obj.settings.ActiveSegmentNum) && ~isempty(obj.settings.ActiveMarkerNum)
        % Marker is active - make sure it's valid
        if numMarkers == 0
            % No markers
            obj.settings.ActiveMarkerNum = [];
            if numSegments > 0
                % There is a segment - make the first one of those active
                obj.settings.ActiveSegmentNum = 1;
            end
        elseif obj.settings.ActiveMarkerNum > numMarkers
            % There are markers, but the active one is out of range
            obj.settings.ActiveMarkerNum = numMarkers;
        end
    elseif ~isempty(obj.settings.ActiveSegmentNum) && isempty(obj.settings.ActiveMarkerNum)
        % Segment is active - make sure it's valid
        if numSegments== 0
            % No segments
            obj.settings.ActiveSegmentNum = [];
            if numMarkers > 0
                % There is a marker - make the first one of those active
                obj.settings.ActiveMarkerNum = 1;
            end
        elseif obj.settings.ActiveSegmentNum > numSegments
            % There are segments, but the active one is out of range
            obj.settings.ActiveSegmentNum = numSegments;
        end
    end
end

function updateXLimBox(obj)
    % Update the yellow dotted line box on the sound axes that shows what
    % the zoomed in view is
    yl = ylim(obj.axes_Sound);

    % Calculate updated position of box
    xdata = [obj.settings.TLim(1), obj.settings.TLim(2), obj.settings.TLim(2), obj.settings.TLim(1), obj.settings.TLim(1)];
    ydata = [yl(1), yl(1), yl(2), yl(2), yl(1)]*0.93;

    if isempty(obj.xlimbox) || ~isvalid(obj.xlimbox)
        % No xlimbox currently, create a new one
        hold(obj.axes_Sound, 'on');
        obj.xlimbox = plot(obj.axes_Sound, ...
            xdata, ydata, ':y', 'LineWidth', 2);
        hold(obj.axes_Sound, 'off');
    else
        % xlimbox already exists, just update position
        obj.xlimbox.XData = xdata;
        obj.xlimbox.YData = ydata;
    end
end

function fixTLim(obj, maxSeconds)
    % Record width of viewing window
    tWidth = diff(obj.settings.TLim);

    % Adjust view time limits if they exceed the boundaries of the data
    obj.settings.TLim(obj.settings.TLim < 0) = 0;
    obj.settings.TLim(obj.settings.TLim > maxSeconds) = maxSeconds;

    % Ensure second time limit is greater than first
    if tWidth < 0
        obj.settings.TLim = flip(obj.settings.TLim);
    elseif tWidth == 0
        obj.settings.TLim = [0, maxSeconds];
    end
end

function UpdateTimescaleView(obj, maintainViewWidth)
    % Function that handles updating all the axes to show the appropriate
    % timescale together, based on the value in obj.settings.TLim

    % maintainViewWidth:
    %   If obj.settings.TLim is out of bounds, try to make it in bounds such
    %   that the width of the viewing window stays the same.
    if ~exist('maintainViewWidth', 'var') || isempty(maintainViewWidth)
        maintainViewWidth = false;
    end

    [numSamples, fs] = obj.eg_GetSamplingInfo();
    numSeconds = numSamples / fs;

    % Record width of viewing window
    tWidth = abs(diff(obj.settings.TLim));

    if maintainViewWidth
        originalTLim = obj.settings.TLim;
    end

    obj.fixTLim(numSeconds);

    if maintainViewWidth
        matches = obj.settings.TLim == originalTLim;
        if all(matches == [0, 1])
            % First limit has changed
            obj.settings.TLim(2) = obj.settings.TLim(1) + tWidth;
            % Fix TLim again in case this messed them up.
            obj.fixTLim(numSeconds);
        elseif all(matches == [1, 0])
            % Second limit has changed
            obj.settings.TLim(1) = obj.settings.TLim(2) - tWidth;
            % Fix TLim again in case this messed them up.
            obj.fixTLim(numSeconds);
        end
    end

    xlim(obj.axes_Sound, [0, numSeconds]);

    if obj.menu_AutoCalculate.Checked
        obj.eg_PlotSonogram();
    else
        xlim(obj.axes_Sonogram, obj.settings.TLim);
%         obj.axes_Sonogram.UIContextMenu = obj.context_Sonogram;

%         obj.setClickSoundCallback(obj.axes_Sonogram);
        obj.setClickSoundCallback(obj.axes_Sound);
    end

    % Update xlimbox
    obj.updateXLimBox();

    % Update string that shows the amount of time visible I guess?
    obj.edit_Timescale.String = num2str(diff(obj.settings.TLim),4);


    % Set amplitude axes time limits to match
    xlim(obj.axes_Amplitude, obj.settings.TLim);
    % Set segments axes limits to match
    xlim(obj.axes_Segments, obj.settings.TLim);

    for axnum = 1:2
        yl = ylim(obj.axes_Channel(axnum));
        xlim(obj.axes_Channel(axnum), obj.settings.TLim);
        if obj.menu_PeakDetects(axnum).Checked
            obj.eg_PlotChannel(axnum);
        end
        ylim(obj.axes_Channel(axnum), yl);
    end

    obj.eg_Overlay();
end

function UpdateTimeResolutionBar(obj, timeResolution)
    % Update the bar in the sonogram axes that shows the time resolution of
    % the spectrogram.
    % timeResolution is in seconds

    delete(obj.TimeResolutionBarHandle);
    delete(obj.TimeResolutionBarText);

    if ~isempty(timeResolution) && ~isnan(timeResolution)
        % Get spectrogram axes data limits
        xl = xlim(obj.axes_Sonogram);
        yl = ylim(obj.axes_Sonogram);

        % Calculate bar coordinates (except the one determined by the text
        % height)
        xA = xl(2)-timeResolution;
        xB = xl(2);
        yB = yl(2);

        % Change number presentation style/units based on order of
        % magnitude of timeResolution
        if timeResolution >= 1
            numText = sprintf('Δt=%0.01f s', timeResolution);
        elseif timeResolution >= 0.01
            numText = sprintf('Δt=%d ms', round(timeResolution*1000));
        elseif timeResolution > 0.001
            numText = sprintf('Δt=%0.01f ms', timeResolution*1000);
        else
            numText = sprintf('Δt=%d us', round(timeResolution*1000000));
        end

        % Create the time resolution text label
        obj.TimeResolutionBarText = text(obj.axes_Sonogram, xB, yB, numText, 'VerticalAlignment', 'top', 'HorizontalAlignment' , 'right', 'Color', [0.5, 0.5, 0.5], 'FontSize', 8);

        % Get the height of the text
        obj.TimeResolutionBarText.Units = 'data';
        h = obj.TimeResolutionBarText.Extent(4);

        % Determine the final coordinates of the bar
        yA = yl(2) - h;
        xdata = [xA, xA, xB, xB];
        ydata = [yA, yB, yB, yA];

        % Create bar
        obj.TimeResolutionBarHandle = patch(xdata, ydata, 'w', 'Parent', obj.axes_Sonogram, 'FaceColor', 'w', 'EdgeColor', 'none');

        % Raise up text above bar
%         uistack(obj.TimeResolutionBarText);
        % Apparently this is equivalent to and faster than uistack?! Didn't
        %   know the Children property was writable
        barIdx =  find(obj.axes_Sonogram.Children == obj.TimeResolutionBarHandle, 1);
        textIdx = find(obj.axes_Sonogram.Children == obj.TimeResolutionBarText, 1);
        obj.axes_Sonogram.Children([barIdx, textIdx]) = obj.axes_Sonogram.Children([textIdx, barIdx]);
    end
end

function eg_PlotSonogram(obj)
    obj.UpdateFilteredSound();

    % Ensure sample numbers are in range
    [numSamples, fs] = obj.eg_GetSamplingInfo();
    sampleLims = round(obj.settings.TLim * fs);
    if sampleLims(1) < 1
        sampleLims(1) = 1;
    end
    if sampleLims(2) > numSamples
        sampleLims(2) = numSamples;
    end

    % Determine current spectrogram algorithm?
    for c = 1:length(obj.menu_Algorithm)
        if obj.menu_Algorithm(c).Checked
            alg = obj.menu_Algorithm(c).Label;
            break;
        end
    end

    cla(obj.axes_Sonogram);
    xlim(obj.axes_Sonogram, obj.settings.TLim);
    if obj.menu_FrequencyZoom.Checked
        ylim(obj.axes_Sonogram, obj.settings.CustomFreqLim);
    else
        ylim(obj.axes_Sonogram, obj.settings.FreqLim);
    end
    [obj.settings.CurrentSonnogramIsPower, timeResolution, spectrogram_handle] = ...
            electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, ...
                obj.axes_Sonogram, obj.sound(sampleLims(1):sampleLims(2)), fs, ...
                obj.settings.SonogramParams);

    auxiliarySoundSources = obj.getAuxiliarySoundSources();
    if ~isempty(auxiliarySoundSources)
        % User has one or more selected auxiliary sound sources
        auxiliary_spectrogram_handles = gobjects().empty;
        hold(obj.axes_Sonogram, 'on');
        for k = 1:length(auxiliarySoundSources)
            [auxiliarySound, fs] = obj.getSound(auxiliarySoundSources{k});
            [obj.settings.CurrentSonnogramIsPower, timeResolution, auxiliary_spectrogram_handles(k)] = electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, ...
                obj.axes_Sonogram, auxiliarySound(sampleLims(1):sampleLims(2)), fs, ...
                obj.settings.SonogramParams);
        end
        nSpectrograms = 1 + length(auxiliary_spectrogram_handles);
        if nSpectrograms > 1
            % Arrange spectrograms
            freqRange = obj.axes_Sonogram.YLim;
            freqBounds = linspace(freqRange(1), freqRange(2), nSpectrograms+1);
            allSpectrograms = [auxiliary_spectrogram_handles, spectrogram_handle];
            for k = 1:nSpectrograms
                allSpectrograms(k).YData = freqBounds(k:k+1);
            end
        end
        hold(obj.axes_Sonogram, 'off');
    end

    obj.axes_Sonogram.Units = 'normalized';
    obj.axes_Sonogram.YDir = 'normal';
    obj.axes_Sonogram.UIContextMenu = obj.context_Sonogram;

    obj.UpdateTimeResolutionBar(timeResolution);

    obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope;
    obj.settings.DerivativeSlope = 0;
    obj.SetSonogramColors();

    xt = obj.axes_Sonogram.YTick;
    obj.axes_Sonogram.YTickLabel  = xt/1000;
    ylabel(obj.axes_Sonogram, 'Frequency (kHz)');

    ch = obj.axes_Sonogram.Children;
    for c = 1:length(ch)
        ch(c).UIContextMenu = obj.axes_Sonogram.UIContextMenu;
    end

    obj.setClickSoundCallback(obj.axes_Sonogram);
    xlim(obj.axes_Sonogram, obj.settings.TLim);
    obj.axes_Sonogram.Box = 'off';
end

function click_sound(obj, hObject, event)
    % Callback for a mouse click on any of the sound axes

    % If the direct object clicked on was not an axes, find the axes
    % ancestor.
    while ~isa(hObject, 'matlab.graphics.axis.Axes')
        hObject = hObject.Parent;
        if isa(hObject, 'matlab.ui.Figure')
            % Something went wrong, we somehow clicked on something that
            % does not have an axes as an ancestor
            error('Error when clicking on one of the sound axes');
        end
    end


    current_axes = hObject;

    if strcmp(obj.figure_Main.SelectionType, 'normal')
        % Normal left mouse button click
        %   Zoom in (either with a box if it's a
        %   click/drag, or just shift the zoom box over to click location if
        %   it's just a click.

        % Temporarily switch axes units to pixels to make it easier to convert
        % the user click coordinates?
        current_axes.Units = 'pixels';
        current_axes.Parent.Units = 'pixels';
        % Set up a "rubber band box" to display user mouse click/drag. This
        %   blocks until user lets go of mouse, and returns the *figure*
        %   coordinates of the click/drag rectangle
        rect = rbbox;

        % Get axis upper left position to subtract off
        pos = current_axes.Position;

        % Switch the axes back to normalized units
        current_axes.Parent.Units = 'normalized';
        current_axes.Units = 'normalized';
        xl = xlim(current_axes);
        yl = ylim(current_axes);

        % I think we're converting the x coordinate and width of rectangle to
        % units of audio samples?
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));

        if rect(3) == 0
            % Click/drag box has zero width, so we're going to shift the zoom
            % box so the left size aligns with the cllick location
            % No we're not, no one likes this
%             shift = rect(1) - obj.settings.TLim(1);
%             obj.settings.TLim = obj.settings.TLim + shift;
        else
            if obj.menu_FrequencyZoom.Checked && (hObject==obj.axes_Sonogram || hObject.Parent==obj.axes_Sonogram)
                % We're zooming along the y-axis (frequency) as well as x
                rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
                obj.settings.CustomFreqLim = [rect(2) rect(2)+rect(4)];
                ylim([rect(2) rect(2)+rect(4)]);
            end
            obj.settings.TLim = [rect(1), rect(1)+rect(3)];
        end
        % Update spectrogram scales
        obj.UpdateTimescaleView();
    elseif strcmp(obj.figure_Main.SelectionType, 'extend')
        % Shift-click
        %   Shift zoom box so the right side aligns with click location
        % Nah
%         pos = current_axes.CurrentPoint;
%         if pos(1,1) < obj.settings.TLim(1)
%             return
%         end
%         obj.settings.TLim(2) = pos(1,1);
%         % Update spectrogram scales
%         obj.eg_EditTimescale();
    elseif strcmp(obj.figure_Main.SelectionType,'open')
        % Double-click
        %   Reset zoom
        [numSamples, fs] = obj.eg_GetSamplingInfo();

        obj.settings.TLim = [0, numSamples/fs];
        obj.UpdateTimescaleView();

        if obj.menu_FrequencyZoom.Checked
            % We're resetting y-axis (frequency) zoom too
            obj.settings.CustomFreqLim = obj.settings.FreqLim;
        end
        % Update spectrogram scales
    elseif strcmp(obj.figure_Main.SelectionType, 'alt') && ~isempty(obj.figure_Main.CurrentModifier) && strcmp(obj.figure_Main.CurrentModifier, 'control')
        % User control-clicked on axes_Spectrogram

        % Switch the axes back to normalized units
        current_axes.Parent.Units = 'normalized';
        current_axes.Units = 'normalized';
        % Set up a "rubber band box" to display user mouse click/drag. This
        %   blocks until user lets go of mouse, and returns the *figure*
        %   coordinates of the click/drag rectangle
        rect = rbbox;

        % Get axis upper left position to subtract off
        pos = current_axes.Position;

        xl = xlim(current_axes);
    %    yl = ylim(current_axes);

        % I think we're converting the x coordinate and width of rectangle to
        % units of audio samples?
        x = [];
        x(1) = (xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1)));
        x(2) = x(1) + (rect(3)/pos(3)*(xl(2)-xl(1)));
        x = round(obj.dbase.Fs * x);

        % Add new marker to backend
        obj.CreateNewMarker(x);
    end

end

function updateSegmentSelectHighlight(obj)
    % Set the color of the segment handle depending on whether or not
    % the segment is selected
    for segmentNum = 1:length(obj.SegmentHandles)
        if obj.dbase.SegmentIsSelected{filenum}(segmentNum)
            obj.SegmentHandles(k).FaceColor = obj.settings.SegmentSelectColor;
        else
            obj.SegmentHandles(k).FaceColor = obj.settings.SegmentUnSelectColor;
        end
    end
end

function click_segmentaxes(obj, hObject, event)

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    if strcmp(obj.figure_Main.SelectionType,'normal')
        % This code takes a selection of segments and toggles their selection
        %   status. Note that it used to set the selection status to unselected
        %   if less than half of the selected segments were selected. Which
        %   seems...convoluted and weird. So I changed it to just toggling all
        %   the selection statuses.
        obj.axes_Segments.Units = 'pixels';
        obj.axes_Segments.Parent.Units = 'pixels';
        rect = rbbox;

        if rect(3) < 10
        % This was probably not intended to be a click-and-drag - ignore it
            return
        end

        pos = obj.axes_Segments.Position;
        obj.axes_Segments.Parent.Units = 'normalized';
        obj.axes_Segments.Units = 'normalized';
        xl = xlim(obj.axes_Segments);

        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));

        f = find(obj.dbase.SegmentTimes{filenum}(:,1)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*obj.dbase.Fs);
        g = find(obj.dbase.SegmentTimes{filenum}(:,2)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*obj.dbase.Fs);
        h = find(obj.dbase.SegmentTimes{filenum}(:,1)<rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*obj.dbase.Fs);
        f = unique([f; g; h]);

        obj.dbase.SegmentIsSelected{filenum}(f) = ~obj.dbase.SegmentIsSelected{filenum}(f); %sum(obj.dbase.SegmentIsSelected{filenum}(f))<=length(f)/2;
        obj.updateSegmentSelectHighlight();
    elseif strcmp(obj.figure_Main.SelectionType,'open')
        [numSamples, fs] = obj.eg_GetSamplingInfo();

        obj.settings.TLim = [0, numSamples/fs];
        obj.UpdateTimescaleView();
    elseif strcmp(obj.figure_Main.SelectionType,'extend')
        if sum(obj.dbase.SegmentIsSelected{filenum})==length(obj.dbase.SegmentIsSelected{filenum})
            obj.dbase.SegmentIsSelected{filenum} = zeros(size(obj.dbase.SegmentIsSelected{filenum}));
        else
            obj.dbase.SegmentIsSelected{filenum} = ones(size(obj.dbase.SegmentIsSelected{filenum}));
        end
        obj.updateSegmentSelectHighlight();
    end

end

function ToggleAnnotationSelect(obj, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end

    switch annotationType
        case 'segment'
            obj.ToggleSegmentSelect(filenum, annotationNum);
        case 'marker'
            obj.ToggleMarkerSelect(filenum, annotationNum);
        case 'none'
            % Do nothing
    end
end
function color = getAnnotationFaceColor(obj, annotationType, selectionState)
    switch annotationType
        case 'segment'
            if selectionState
                color = obj.settings.SegmentSelectColor;
            else
                color = obj.settings.SegmentUnSelectColor;
            end
        case 'marker'
            if selectionState
                color = obj.settings.MarkerSelectColor;
            else
                color = obj.settings.MarkerUnSelectColor;
            end
        otherwise
            error('Unknown annotation type: %s', annotationType);
    end
end
function color = getAnnotationEdgeColor(obj, annotationType, activeState)
    switch annotationType
        case 'segment'
            if activeState
                color = obj.settings.SegmentActiveColor;
            else
                color = obj.settings.SegmentInactiveColor;
            end
        case 'marker'
            if activeState
                color = obj.settings.MarkerActiveColor;
            else
                color = obj.settings.MarkerInactiveColor;
            end
        otherwise
            error('Unknown annotation type: %s', annotationType);
    end
end
function ToggleSegmentSelect(obj, filenum, segmentNum)
    obj.dbase.SegmentIsSelected{filenum}(segmentNum) = ~obj.dbase.SegmentIsSelected{filenum}(segmentNum);
    obj.SegmentHandles(segmentNum).FaceColor = obj.getAnnotationFaceColor('segment', ...
        obj.dbase.SegmentIsSelected{filenum}(segmentNum));
end
function ToggleMarkerSelect(obj, filenum, markerNum)
    obj.dbase.MarkerIsSelected{filenum}(markerNum) = ~obj.dbase.MarkerIsSelected{filenum}(markerNum);
    obj.MarkerHandles(markerNum).FaceColor = obj.getAnnotationFaceColor('marker', ...
        obj.dbase.MarkerIsSelected{filenum}(markerNum));
end
function annotationType = FindActiveAnnotationType(obj)
    [~, annotationType] = FindActiveAnnotation(obj);
end
function [annotationNum, annotationType] = FindActiveAnnotation(obj)
    % Get the index of the active segment or marker

    activeSegmentNum = obj.FindActiveSegment();
    activeMarkerNum = obj.FindActiveMarker();
    if isempty(activeSegmentNum) && isempty(activeMarkerNum)
        % No active segment or active marker
        annotationNum = [];
        annotationType = 'none';
    elseif ~isempty(activeSegmentNum) && ~isempty(activeMarkerNum)
        error('Both a marker and a segment were active. This shouldn''t happen');
    else
        if ~isempty(activeSegmentNum)
            annotationNum = activeSegmentNum;
            annotationType = 'segment';
        elseif ~isempty(activeMarkerNum)
            annotationNum = activeMarkerNum;
            annotationType = 'marker';
        end
    end
end
function markerNum = FindActiveMarker(obj)
    % Get the index of the active marker
    markerNum = obj.settings.ActiveMarkerNum;
end
function segmentNum = FindActiveSegment(obj)
    % Get the index of the active segment
    segmentNum = obj.settings.ActiveSegmentNum;
end

function [newAnnotationNum, newAnnotationType] = FindClosestAnnotationOfOtherType(obj, filenum, annotationNum, annotationType)
    % Find the marker or segment closest in time to the currently selected
    %   segment or marker. If no annotations of the other type exist,
    %   return the same annotation.

    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end
    switch annotationType
        case 'segment'
            if isempty(obj.MarkerHandles)
                % No markers to switch to, do nothing
                newAnnotationNum = annotationNum;
                newAnnotationType = 'segment';
                return
            end
            segmentTime = mean(obj.dbase.SegmentTimes{filenum}(annotationNum, :));
            markerTimes = mean(obj.dbase.MarkerTimes{filenum}, 2);
            % Find segment closest in time to the active marker, and switch
            % to that active segment.
            [~, newAnnotationNum] = min(abs(markerTimes - segmentTime));
            newAnnotationType = 'marker';
        case 'marker'
            if isempty(obj.SegmentHandles)
                % No segments to switch to, do nothing
                newAnnotationNum = annotationNum;
                newAnnotationType = 'marker';
                return
            end
            markerTime = mean(obj.dbase.MarkerTimes{filenum}(annotationNum, :));
            segmentTimes = mean(obj.dbase.SegmentTimes{filenum}, 2);
            % Find segment closest in time to the active marker, and switch
            % to that active segment.
            [~, newAnnotationNum] = min(abs(segmentTimes - markerTime));
            newAnnotationType = 'segment';
        case 'none'
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end

function [annotationNums, annotationType] = PasteAnnotationTitles(obj, annotationStartNum, annotationType, filenum)
    contents = clipboard('paste');
    newTitles = split(contents, ' ')';

    if ~exist('annotationStartNum', 'var') || isempty(annotationStartNum)
        % No annotation number provided - use the currently active one
        annotationStartNum = obj.FindActiveAnnotation();
    end
    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
        if strcmp(annotationType, 'none')
            % No active annotation
            return;
        end
    end
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end
    numAnnotations = obj.GetNumAnnotations(annotationType, filenum);
    annotationNums = annotationStartNum:(annotationStartNum+length(newTitles)-1);
    inRangeNums = (annotationNums <= numAnnotations);
    newTitles = newTitles(inRangeNums);
    annotationNums = annotationNums(inRangeNums);
    obj.SetAnnotationTitles(newTitles, filenum, annotationNums, annotationType);
end

function changedAnnotationNums = InsertBlankAnnotationTitle(obj, annotationNum, annotationType, filenum)
    % Insert a blank annotation title at the specified location, then shift
    % existing annotation titles forward, stopping the shift at the first
    % blank title, if there is one.
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end
    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    switch annotationType
        case 'segment'
            remainingTitles = obj.dbase.SegmentTitles{filenum}(annotationNum:end);
        case 'marker'
            remainingTitles = obj.dbase.MarkerTitles{filenum}(annotationNum:end);
        case 'none'
            % No active annotation
            changedAnnotationNums = [];
            return
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end

    firstBlank = find(strcmp(remainingTitles, ''), 1);
    if isempty(firstBlank)
        % No blank in remaining titles
        firstBlank = length(remainingTitles);
    end

    % Shift over titles
    remainingTitles(2:firstBlank) = remainingTitles(1:firstBlank-1);
    % Set current title to blank
    remainingTitles{1} = '';

    changedAnnotationNums = annotationNum + (1:firstBlank) - 1;

    switch annotationType
        case 'segment'
            obj.dbase.SegmentTitles{filenum}(annotationNum:end) = remainingTitles;
        case 'marker'
            obj.dbase.MarkerTitles{filenum}(annotationNum:end) = remainingTitles;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end

function SetAnnotationTitles(obj, titles, filenum, annotationNums, annotationType)
    % Set the titles of specified segments or markers
    % Titles is a cell array of annotation titles and annotationNums is an
    % array of annotation numbers to set.
    % They all must have the same filenum and annotationType

    if length(titles) ~= length(annotationNums)
        error('titles and annotationsNums must have the same length');
    end

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end

    switch annotationType
        case 'segment'
            % Set the segment title
            obj.dbase.SegmentTitles{filenum}(annotationNums) = titles;
        case 'marker'
            % Set the marker title
            obj.dbase.MarkerTitles{filenum}(annotationNums) = titles;
        otherwise
            % Do nothing for 'none' or invalid type
    end
end

function SetAnnotationTitle(obj, title, filenum, annotationNum, annotationType)
    % Set the title of the specified segment or marker

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end

    switch annotationType
        case 'segment'
            % Set the segment title
            obj.dbase.SegmentTitles{filenum}{annotationNum} = title;
        case 'marker'
            % Set the marker title
            obj.dbase.MarkerTitles{filenum}{annotationNum} = title;
        case 'none'
            % Do nothing
            return
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end

function JoinSegmentWithNext(obj, filenum, segmentNum)
    if segmentNum < length(obj.SegmentHandles)
        % This is not the last segment in the file
        obj.dbase.SegmentTimes{filenum}(segmentNum,2) = obj.dbase.SegmentTimes{filenum}(segmentNum+1,2);
        obj.dbase.SegmentTimes{filenum}(segmentNum+1,:) = [];
        obj.dbase.SegmentTitles{filenum}(segmentNum+1) = [];
        obj.dbase.SegmentIsSelected{filenum}(segmentNum+1) = [];
        obj.PlotAnnotations();
        obj.SetActiveSegment(segmentNum);
        obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;
    end
end

function CreateNewMarker(obj, x)
    % Create a new marker from time x(1) to time x(2)
    filenum = electro_gui.getCurrentFileNum(obj.settings);
    obj.dbase.MarkerTimes{filenum}(end+1, :) = x;
    obj.dbase.MarkerIsSelected{filenum}(end+1) = 1;
    obj.dbase.MarkerTitles{filenum}{end+1} = '';

    % Replot frontend annotation display
    obj.PlotAnnotations();

    % Sort markers chronologically to keep things neat
    order = obj.SortMarkers(filenum);
    [~, mostRecentMarkerNum] = max(order);
    % Set active marker again, so the same marker is still active
    obj.SetActiveMarker(mostRecentMarkerNum);
end

function DeleteAnnotation(obj, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end

    switch annotationType
        case 'segment'
            % Delete the specified marker
            obj.DeleteSegment(filenum, annotationNum);
        case 'marker'
            % Delete the specified marker
            obj.DeleteMarker(filenum, annotationNum);
        case 'none'
            % Do nothing
            return;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end
function DeleteMarker(obj, filenum, markerNum)
    % Delete the specified marker
    obj.dbase.MarkerTimes{filenum}(markerNum, :) = [];
    obj.dbase.MarkerIsSelected{filenum}(markerNum) = [];
    obj.dbase.MarkerTitles{filenum}(markerNum) = [];
end
function DeleteSegment(obj, filenum, segmentNum)
    % Delete the specified marker
    obj.dbase.SegmentTimes{filenum}(segmentNum, :) = [];
    obj.dbase.SegmentIsSelected{filenum}(segmentNum) = [];
    obj.dbase.SegmentTitles{filenum}(segmentNum) = [];
end
function order = SortMarkers(obj, filenum)
    % Sort the order of the markers. Note that this doesn't affect the marker
    % data at all, just keeps them stored in chronological order.

    % Get sort order based on marker start times
    [~, order] = sort(obj.dbase.MarkerTimes{filenum}(:, 1));
    obj.dbase.MarkerTimes{filenum} = obj.dbase.MarkerTimes{filenum}(order, :);
    obj.dbase.MarkerIsSelected{filenum} = obj.dbase.MarkerIsSelected{filenum}(order);
    obj.dbase.MarkerTitles{filenum} = obj.dbase.MarkerTitles{filenum}(order);
    obj.MarkerHandles = obj.MarkerHandles(order);
end
function numAnnotations = GetNumAnnotations(obj, annotationType, filenum)
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    switch annotationType
        case 'segment'
            numAnnotations = length(obj.dbase.SegmentTitles{filenum});
        case 'marker'
            numAnnotations = length(obj.dbase.MarkerTitles{filenum});
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end
function SetActiveAnnotation(obj, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end

    switch annotationType
        case 'segment'
            obj.SetActiveSegment(annotationNum);
        case 'marker'
            obj.SetActiveMarker(annotationNum);
        case 'none'
            return;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end
function SetActiveMarker(obj, markerNum)
    % Set new selected marker number
    numMarkers = obj.GetNumAnnotations('marker');
    if numMarkers > 0
        obj.settings.ActiveMarkerNum = mod(markerNum-1, numMarkers)+1;
        obj.settings.ActiveSegmentNum = [];
    else
        obj.settings.ActiveMarkerNum = [];
    end
end
function SetActiveSegment(obj, segmentNum)
    % Set new selected segment number
    numSegments = obj.GetNumAnnotations('segment');
    if numSegments > 0
        obj.settings.ActiveSegmentNum = mod(segmentNum-1, numSegments)+1;
        obj.settings.ActiveMarkerNum = [];
    else
        obj.settings.ActiveSegmentNum = [];
    end
end
function DeactivateActiveAnnotation(obj, annotationType)
    switch annotationType
        case 'segment'
            obj.settings.ActiveSegmentNum = [];
        case 'marker'
                obj.settings.ActiveMarkerNum = [];
        otherwise
    end
end
function [oldAnnotationNum, newAnnotationNum] = IncrementActiveAnnotation(obj, delta, annotationType)
    % Get currently active annotation number and type
    [oldAnnotationNum, oldAnnotationType] = obj.FindActiveAnnotation();

    if strcmp(oldAnnotationType, 'none')
        return;
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        annotationType = oldAnnotationType;
    end

    % Determine new annotation number
    newAnnotationNum = oldAnnotationNum + delta;

    % Set new annotation number
    obj.SetActiveAnnotation(newAnnotationNum, annotationType);
end
function [newAnnotationNum, newAnnotationType] = ConvertAnnotationType(obj, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = obj.FindActiveAnnotation();
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = obj.FindActiveAnnotation();
    end
    switch annotationType
        case 'segment'
            newAnnotationNum = obj.ConvertSegmentToMarker(filenum, annotationNum);
            newAnnotationType = 'marker';
        case 'marker'
            newAnnotationNum = obj.ConvertMarkerToSegment(filenum, annotationNum);
            newAnnotationType = 'segment';
        case 'none'
            return;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
end
function newSegmentNum = ConvertMarkerToSegment(obj, filenum, markerNum)
    activeMarkerNum = obj.FindActiveMarker();
    t0 = obj.dbase.MarkerTimes{filenum}(markerNum, 1);
    t1 = obj.dbase.MarkerTimes{filenum}(markerNum, 2);
    MS = obj.dbase.MarkerIsSelected{filenum}(markerNum);
    MN = obj.dbase.MarkerTitles{filenum}(markerNum);
    STs = obj.dbase.SegmentTimes{filenum};
    SSs = obj.dbase.SegmentIsSelected{filenum};
    SNs = obj.dbase.SegmentTitles{filenum};

    if isempty(STs)
        % No existing segments
        ind = 1;
    else
        % Insert marker into appropriate place in segment arrays
        ind = electro_gui.getSortedArrayInsertion(STs(:, 1), t0);
    end
    obj.dbase.SegmentTimes{filenum} = [STs(1:ind-1, :); [t0, t1]; STs(ind:end, :)];
    obj.dbase.SegmentIsSelected{filenum} = [SSs(1:ind-1), MS, SSs(ind:end)];
    obj.dbase.SegmentTitles{filenum} = [SNs(1:ind-1), MN, SNs(ind:end)];

    newSegmentNum = ind;

    obj.DeleteMarker(filenum, markerNum);

    if markerNum < activeMarkerNum
        % We converted a marker before the active marker to a segment.
        % Adjust the active marker num to compensate for index shift
        obj.SetActiveAnnotation(activeMarkerNum-1, 'marker');
    elseif markerNum == activeMarkerNum
        % We just converted the active segment to a marker - deactiveate
        % active segment and activate new marker
        obj.SetActiveAnnotation(newSegmentNum, 'segment');
    end
end
function newMarkerNum = ConvertSegmentToMarker(obj, filenum, segmentNum)
    activeSegmentNum = obj.FindActiveSegment();
    t0 = obj.dbase.SegmentTimes{filenum}(segmentNum, 1);
    t1 = obj.dbase.SegmentTimes{filenum}(segmentNum, 2);
    SS = obj.dbase.SegmentIsSelected{filenum}(segmentNum);
    SN = obj.dbase.SegmentTitles{filenum}(segmentNum);
    MTs = obj.dbase.MarkerTimes{filenum};
    MSs = obj.dbase.MarkerIsSelected{filenum};
    MNs = obj.dbase.MarkerTitles{filenum};

    if isempty(MTs)
        % No existing markers
        ind = 1;
    else
        % Insert segment into appropriate place in marker arrays
        ind = electro_gui.getSortedArrayInsertion(MTs(:, 1), t0);
    end
    obj.dbase.MarkerTimes{filenum} = [MTs(1:ind-1, :); [t0, t1]; MTs(ind:end, :)];
    obj.dbase.MarkerIsSelected{filenum} = [MSs(1:ind-1), SS, MSs(ind:end)];
    obj.dbase.MarkerTitles{filenum} = [MNs(1:ind-1), SN, MNs(ind:end)];

    newMarkerNum = ind;

    obj.DeleteSegment(filenum, segmentNum);

    if segmentNum < activeSegmentNum
        % We converted a segment before the active segment to a marker.
        % Adjust the active segment num to compensate for index shift
        obj.SetActiveAnnotation('segment', activeSegmentNum-1);
    elseif segmentNum == activeSegmentNum
        % We just converted the active segment to a marker - deactiveate
        % active segment and activate new marker
        obj.SetActiveAnnotation(newMarkerNum, 'marker');
    end
end

% --- Executes on button press in push_Calculate.
function SetSonogramColors(obj)

    if obj.settings.CurrentSonnogramIsPower == 1
        colormap(obj.axes_Sonogram, obj.Colormap);
        obj.axes_Sonogram.CLim = obj.settings.SonogramClim;
    else
        ch = findobj('Parent', obj.axes_Sonogram, 'Type', 'image');
        for c = 1:length(ch)
            ch(c).CData = atan(tan(ch(c).CData)/10^obj.settings.DerivativeSlope*10^obj.settings.NewDerivativeSlope);
        end
        obj.settings.DerivativeSlope = obj.settings.NewDerivativeSlope;
        cl = repmat(linspace(0,1,201)',1,3);
        indx = round(101-obj.settings.DerivativeOffset*100):round(101+obj.settings.DerivativeOffset*100);
        indx = indx(indx>0 & indx<202);
        cl(indx,:) = repmat(obj.settings.BackgroundColors(2,:),length(indx),1);
        colormap(obj.axes_Sonogram, cl);
        obj.axes_Sonogram.CLim = [-pi/2 pi/2];
    end

end
function eg_NewDbase(obj)

    [dbase, cancel] = eg_GatherFiles('', obj.settings.FileString, ...
        obj.settings.DefaultFileLoader, obj.settings.DefaultChannelNumber, ...
        "TitleString", 'Identify files for new dbase', 'GUI', true, ...
        'DefaultPathName', obj.tempSettings.lastDirectory);

    if cancel
        return
    end

    numFiles = electro_gui.getNumFiles(obj.dbase);
    if numFiles == 0
        return
    end

    obj.SaveState();

    obj.dbase = electro_gui.InitializeDbase(obj.settings, 'NumFiles', numFiles, 'BaseDbase', dbase, 'IncludeHelp', false);

    % Placeholder for custom fields
    obj.OriginalDbase = struct();

    if strcmp(obj.settings.WorksheetTitle,'Untitled')
        f = strfind(obj.dbase.PathName,'\');
        obj.settings.WorksheetTitle = obj.dbase.PathName(f(end)+1:end);
    end

    obj.text_TotalFileNumber.String = ['of ' num2str(numFiles)];
    obj.edit_FileNumber.String = '1';

    obj.UpdateFileInfoBrowser();

    obj.updateFileNotes();

    obj.RefreshSortOrder();

    obj.FileInfoBrowser.SelectedRow = 1;
    obj.popup_Channel1.Value = 1;
    obj.popup_Channel2.Value = 1;
    obj.popup_Function1.Value = 1;
    obj.popup_Function2.Value = 1;
    obj.popup_EventDetector1.Value = 1;
    obj.popup_EventDetector2.Value = 1;
    obj.popup_EventListAlign.Value = 1;

    obj.setFileNames({obj.dbase.SoundFiles.name});
    obj.UpdateFileInfoBrowserReadState();

    sourceStrings = {'(None)','Sound'};
    for chanNum = 1:length(obj.dbase.ChannelFiles)
        if ~isempty(obj.dbase.ChannelFiles{chanNum})
            sourceStrings{end+1} = ['Channel ' num2str(chanNum)];
        end
    end
    obj.UpdateChannelPopups();

    obj.eg_PopulateSoundSources();

    obj.SetEventViewerEventListElement(1, '(None)', [], []);

    obj.menu_Events1.Enable  = 'off';
    obj.menu_Events2.Enable  = 'off';
    obj.popup_Function1.Enable  = 'off';
    obj.popup_Function2.Enable  = 'off';
    obj.popup_EventDetector1.Enable  = 'off';
    obj.popup_EventDetector2.Enable  = 'off';
    obj.push_Detect1.Enable  = 'off';
    obj.push_Detect2.Enable  = 'off';

    obj.axes_Events.Visible = 'off';

    % get segmenter parameters
    for c = 1:length(obj.menu_SegmenterList.Children)
        if obj.menu_SegmenterList.Children(c).Checked
            h = obj.menu_SegmenterList.Children(c);
            alg = obj.menu_SegmenterList.Children(c).Label;
        end
    end
    if isempty(h.UserData)
        obj.settings.SegmenterParams = electro_gui.eg_runPlugin(obj.plugins.segmenters, alg, 'params');
        h.UserData = obj.settings.SegmenterParams;
    else
        obj.settings.SegmenterParams = h.UserData;
    end

    % get sonogram parameters
    for c = 1:length(obj.menu_Algorithm)
        if obj.menu_Algorithm(c).Checked
            h = obj.menu_Algorithm(c);
            alg = obj.menu_Algorithm(c).Label;
        end
    end
    if isempty(h.UserData)
        obj.settings.SonogramParams = electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, 'params');
        h.UserData = obj.settings.SonogramParams;
    else
        obj.settings.SonogramParams = h.UserData;
    end

    % get filter parameters
    for c = 1:length(obj.menu_Filter)
        if obj.menu_Filter(c).Checked
            h = obj.menu_Filter(c);
            alg = obj.menu_Filter(c).Label;
        end
    end
    if isempty(h.UserData)
        obj.settings.FilterParams = electro_gui.eg_runPlugin(obj.plugins.filters, alg, 'params');
        h.UserData = obj.settings.FilterParams;
    else
        obj.settings.FilterParams = h.UserData;
    end

    % get event parameters
    for axnum = 1:2
        v = obj.popup_EventDetectors(axnum).Value;
        ud = obj.popup_EventDetectors(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = obj.popup_EventDetectors(axnum).String;
            dtr = str{v};
            [obj.settings.ChannelAxesEventParams{axnum}, ~] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, dtr, 'params');
            ud{v} = obj.settings.ChannelAxesEventParams{axnum};
            obj.popup_EventDetectors(axnum).UserData = ud;
        else
            obj.settings.ChannelAxesEventParams{axnum} = ud{v};
        end
    end

    % get function parameters
    for axnum = 1:2
        v = obj.popup_Functions(axnum).Value;
        ud = obj.popup_Functions(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = obj.popup_Functions(axnum).String;
            dtr = str{v};
            [obj.settings.ChannelAxesFunctionParams{axnum}, ~] = electro_gui.eg_runPlugin(obj.plugins.filters, dtr, 'params');
            ud{v} = obj.settings.ChannelAxesFunctionParams{axnum};
            obj.popup_Functions(axnum).UserData = ud;
        else
            obj.settings.ChannelAxesFunctionParams{axnum} = ud{v};
        end
    end

    obj.LoadFile();
end

function OpenDbase(obj, filePathOrDbase, options)
    arguments
        obj electro_gui
        filePathOrDbase = ''
        options.SkipDbaseFormatUpdate = false
        options.Settings = defaults_template()
    end

    settings = options.Settings;

    if ischar(filePathOrDbase)
        % User supplied a path name - load the dbase from that path
        progressMsg = 'Opening dbase...';
        progressBar = waitbar(0, progressMsg, 'WindowStyle', 'modal');
        if isempty(filePathOrDbase)
            % Prompt user to select dbase .mat file
            if isfield(settings, 'tempSettings')
                path = settings.tempSettings.lastDirectory;
            else
                path = '.';
            end
            [file, path] = uigetfile(fullfile(path, '*.mat'), 'Load analysis');
            if ~ischar(file)
                % User cancelled load
                close(progressBar)
                return
            end
            filePathOrDbase = fullfile(path, file);
            obj.addRecentFile(filePathOrDbase);
        else
            % File path already provided
            [path, file, ext] = fileparts(filePathOrDbase);
            file = [file, ext];
        end

        % Load dbase into 'dbase' variable
        S = load(fullfile(path, file), 'dbase');
        dbase = S.dbase;
        if isfield(S, 'settings')
            settings = S.settings;
        end
    elseif isstruct(filePathOrDbase)
        % We're loading a dbase from memory, not from file
        progressMsg = 'Loading state...';
        progressBar = waitbar(0, progressMsg, 'WindowStyle', 'modal');
        dbase = filePathOrDbase;
    else
        error('Unrecognized file path or dbase struct');
    end

    waitbar(0.26, progressBar)

    while ~isfolder(dbase.PathName)
        % Root path in dbase is not found on this system. Prompt user to
        % find the files in a different directory
        choice1 = 'Choose new drive letter';
        choice2 = 'Locate data directory manually';
        choice3 = 'Cancel';
        choice = questdlg({'Data directory not found:', '', dbase.PathName, '', 'What would you like to do?'}, 'Data directory not found', choice1, choice2, choice3, 'Cancel');
        switch choice
            case choice1
                oldRoot = getPathRoot(dbase.PathName);
                newRoot = inputdlg('Choose new drive letter:', 'Choose new drive letter', 1, {oldRoot});
                if isempty(newRoot)
                    % User cancelled
                    close(progressBar);
                    return;
                else
                    dbase.PathName = RootSwap(dbase.PathName, oldRoot, newRoot);
                end
            case choice2
                dbase.PathName = uigetdir(obj.tempSettings.lastDirectory, ...
                    'Locate the data directory manually:');
                if ~ischar(dbase.PathName)
                    % User cancelled
                    close(progressBar);
                    return
                end
            case {choice3, ''}
                % User cancelled
                close(progressBar);
                return
        end
    end
    obj.dbase.PathName = dbase.PathName;
    waitbar(0.30, progressBar)

    if exist('path', 'var')
        % Save the selected directory in temporary settings for next time
        obj.tempSettings.lastDirectory = path;
        obj.updateTempFile();

        obj.settings.DefaultDbaseFilename = fullfile(path, file);
    end

    if ~options.SkipDbaseFormatUpdate
        % Do not ensure the dbase is in the most up-to-date format
        [dbase, settings] = electro_gui.updateDbaseFormat(dbase, settings);
    end

    % Store original dbase in case it has custom fields, so we can restore them
    %   when we save the dbase
    obj.dbase = dbase;
    obj.settings = settings;

    % Adjust settings based on dbase contents

    obj.UpdateChannelPopups();
    obj.popup_Channel1.Value = 1;
    obj.popup_Channel2.Value = 1;

    obj.popup_EventListAlign.Value = 1;
    obj.axes_Events.Visible = 'off';

    if strcmp(obj.settings.WorksheetTitle,'Untitled')
        f = strfind(obj.dbase.PathName,'\');
        obj.settings.WorksheetTitle = obj.dbase.PathName(f(end)+1:end);
    end

    % Update channel lists again to include pseudochannels
    obj.UpdateChannelPopups();

    waitbar(0.38, progressBar)

    % Set properties
    obj.dbase = electro_gui.setProperties(obj.dbase, obj.dbase.Properties, obj.dbase.PropertyNames);
    obj.UpdateFileInfoBrowser();

    % Load file sorting info from dbase
    fileSortMethod = obj.settings.FileSortMethod;
    fileSortPropertyName = obj.settings.FileSortPropertyName;
    fileSortReversed = obj.settings.FileSortReversed;
    obj.setFileSortInfo(fileSortMethod, fileSortPropertyName, fileSortReversed);

    % Update file browser
    obj.UpdateFileInfoBrowser();
    waitbar(0.45, progressBar)

    % Update file read state
    obj.UpdateFileInfoBrowserReadState();

    % Update auxiliary sound sources
    obj.setAuxiliarySoundSources(settings.AuxiliarySoundSources, false);

    obj.RefreshSortOrder();
    waitbar(0.51, progressBar)

    obj.text_TotalFileNumber.String = ['of ' num2str(electro_gui.getNumFiles(obj.dbase))];
    obj.popup_Function1.Value = 1;
    obj.popup_Function2.Value = 1;
    obj.popup_EventDetector1.Value = 1;
    obj.popup_EventDetector2.Value = 1;

    obj.edit_FileNumber.String = '1';
    obj.FileInfoBrowser.SelectedRow = 1;
    obj.setFileNames({obj.dbase.SoundFiles.name});
    waitbar(0.57, progressBar)

    obj.edit_FileNumber.String = num2str(settings.CurrentFile);
    obj.FileInfoBrowser.SelectedRow = settings.CurrentFile;

    % get segmenter parameters
    for c = 1:length(obj.menu_SegmenterList.Children)
        if obj.menu_SegmenterList.Children(c).Checked
            h = obj.menu_SegmenterList.Children(c);
            alg = obj.menu_SegmenterList.Children(c).Label;
        end
    end
    if isempty(h.UserData)
        obj.settings.SegmenterParams = electro_gui.eg_runPlugin(obj.plugins.segmenters, alg, 'params');
        h.UserData = obj.settings.SegmenterParams;
    else
        obj.settings.SegmenterParams = h.UserData;
    end

    % get sonogram parameters
    for c = 1:length(obj.menu_Algorithm)
        if obj.menu_Algorithm(c).Checked
            h = obj.menu_Algorithm(c);
            alg = obj.menu_Algorithm(c).Label;
        end
    end
    if isempty(h.UserData)
        obj.settings.SonogramParams = electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, 'params');
        h.UserData = obj.settings.SonogramParams;
    else
        obj.settings.SonogramParams = h.UserData;
    end

    % get event parameters
    for axnum = 1:2
        v = obj.popup_EventDetectors(axnum).Value;
        ud = obj.popup_EventDetectors(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = obj.popup_EventDetectors(axnum).String;
            dtr = str{v};
            [obj.settings.ChannelAxesEventParams{axnum}, ~] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, dtr, 'params');
            ud{v} = obj.settings.ChannelAxesEventParams{axnum};
            obj.popup_EventDetectors(axnum).UserData = ud;
        else
            obj.settings.ChannelAxesEventParams{axnum} = ud{v};
        end
    end

    % get function parameters
    for axnum = 1:2
        v = obj.popup_Functions(axnum).Value;
        ud = obj.popup_Functions(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = obj.popup_Functions(axnum).String;
            dtr = str{v};
            [obj.settings.ChannelAxesFunctionParams{axnum}, ~] = electro_gui.eg_runPlugin(obj.plugins.filters, dtr, 'params');
            ud{v} = obj.settings.ChannelAxesFunctionParams{axnum};
            obj.popup_Functions(axnum).UserData = ud;
        else
            obj.settings.ChannelAxesFunctionParams{axnum} = ud{v};
        end
    end

    obj.eg_PopulateSoundSources();

    obj.UpdateEventSourceList();

    obj.LoadFile(false);

    waitbar(1, progressBar)
    close(progressBar)
end

function SaveDbase(obj)
    [file, path] = uiputfile(obj.settings.DefaultDbaseFilename,'Save analysis');
    if ~ischar(file)
        return
    end
    savePath = fullfile(path, file);

    dbase = obj.GetDBase(obj.settings.IncludeDocumentation);
    settings = obj.settings;

    save(savePath,'dbase', 'settings');
    obj.settings.DefaultDbaseFilename = savePath;
    obj.addRecentFile(savePath);
end

function scrollHandler(obj, source, event)

    xy = event.Source.CurrentPoint;
    x = xy(1);
    y = xy(2);
    if electro_gui.areCoordinatesIn(x, y, [obj.axes_Sonogram, obj.axes_Sound, obj.axes_Amplitude, obj.axes_Channel])
        % Scroll in any of the stacked axes
        [t, ~] = electro_gui.convertFigCoordsToChildAxesCoords(x, y, obj.axes_Sonogram);
        if obj.isShiftDown()
            obj.shiftInTime(event.VerticalScrollCount);
        else
            obj.zoomInTime(t, event.VerticalScrollCount);
        end
    elseif electro_gui.areCoordinatesIn(x, y, obj.axes_Events) && ~isempty(obj.settings.ActiveEventNum)
        % Scroll in event viewer axes
        visibleEventMask = isgraphics(obj.EventWaveHandles);
        newActiveEventNum = electro_gui.findNextTrueIdx(visibleEventMask, obj.settings.ActiveEventNum, event.VerticalScrollCount);
        obj.SetActiveEventDisplay(newActiveEventNum);
    end

end

function setTimeViewEdge(obj, edgeTime, edgeSide)
    % Shift view so that the specified edge of the viewing window is at the
    % given time, without changing the width of the viewing window
    % edgeSide should be "left" or "right"
    switch edgeSide
        case 'left'
            currentEdgeTime = obj.settings.TLim(1);
        case 'right'
            currentEdgeTime = obj.settings.TLim(2);
        otherwise
            error('edgeSide should be either ''left'' or ''right''');
    end
    shiftAmount = edgeTime - currentEdgeTime;
    obj.settings.TLim = obj.settings.TLim + shiftAmount;
    obj.UpdateTimescaleView();
end

function centerTime(obj, centerTime)
    % Shift view so that the given time is centered
    currentCenter = mean(obj.settings.TLim);
    shiftAmount = centerTime - currentCenter;
    obj.settings.TLim = obj.settings.TLim + shiftAmount;
    obj.UpdateTimescaleView();
end

function shiftInTime(obj, shiftLevel)
    % Shift view back/forward in time
    shiftDelta = diff(obj.settings.TLim) * 0.1;
    shiftAmount = shiftDelta * shiftLevel;
    obj.settings.TLim = obj.settings.TLim + shiftAmount;
    obj.UpdateTimescaleView(true);
end

function zoomInTime(obj, tCenter, zoomLevels)
    % Zoom view in/out in time
    zoomFactor = 2^(zoomLevels/3);
    currentTWidth = diff(obj.settings.TLim);
    tFraction = (tCenter - obj.settings.TLim(1))/currentTWidth;
    newTWidth = currentTWidth*zoomFactor;
    obj.settings.TLim = [tCenter - tFraction * newTWidth, tCenter + (1-tFraction) * newTWidth];
    obj.UpdateTimescaleView();
end

function exportView(obj)
    f_export = figure();

    % Determine how many channels are visible
    numChannels = 0;
    for c = 1:length(obj.axes_Channel)
        if obj.axes_Channel(c).Visible
            numChannels = numChannels + 1;
        end
    end

    % Copy sonogram
    sonogram_export = subplot(numChannels+1, 1, 1, 'Parent', f_export);
    sonogram_children = obj.axes_Sonogram.Children;
    for k = 1:length(sonogram_children)
        copyobj(sonogram_children(k), sonogram_export);
    end
    % Match axes limits
    xlim(sonogram_export, xlim(obj.axes_Sonogram));
    ylim(sonogram_export, ylim(obj.axes_Sonogram));
    sonogram_export.CLim = obj.axes_Sonogram.CLim;
    colormap(sonogram_export, obj.Colormap);

    % Set figure size to match contents
    sonogram_export.Units = obj.axes_Sonogram.Units;
%     curr_pos = sonogram_export.Position;
    son_pos = obj.axes_Sonogram.Position;
    aspect_ratio = 1.2*(1+numChannels)*son_pos(4) / son_pos(3);
    f_pos = f_export.Position;
    f_pos(4) = f_pos(3) * aspect_ratio;
    f_export.Position = f_pos;

    % Add title to sonogram (file name)
    currentFileName = electro_gui.getCurrentFileName(obj.dbase, obj.settings);
    title(sonogram_export, currentFileName, 'Interpreter', 'none');

    % Loop over any channels that are currently visible, and copy them
    chan = 0;
    for c = 1:length(obj.axes_Channel)
        if obj.axes_Channel(c).Visible
            chan = chan + 1;
            channel_export = subplot(numChannels+1, 1, 1+chan, 'Parent', f_export);
            channel_children = obj.axes_Channel(c).Children;
            for k = 1:length(channel_children)
                copyobj(channel_children(k), channel_export);
            end
        end
    end
end

function boxedEventMask = GetBoxedEventMask(obj, axnum, filenum, minTime, maxTime, minVolt, maxVolt)

    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        boxedEventMask = logical.empty();
        return;
    end

    boxedEventMask = {};

    fs = obj.loadedChannelFs{axnum};

    % Check all event parts to see if any fall within box
    for eventPartNum = 1:size(obj.dbase.EventTimes{eventSourceIdx}, 1)
        eventSamples = obj.dbase.EventTimes{eventSourceIdx}{eventPartNum, filenum};
        newEventTimes = eventSamples / fs;
        eventVoltages = obj.loadedChannelData{axnum}(eventSamples);
        % Get mask of events that fall within box
        boxedMask = newEventTimes > minTime & newEventTimes < maxTime & eventVoltages > minVolt & eventVoltages < maxVolt;
        % Combine it with masks from previous event parts
        boxedEventMask{eventPartNum} = boxedMask;
    end
end

function UpdateEventThresholdDisplay(obj, eventSourceIdx)
    for axnum = obj.WhichChannelAxesMatchEventSource(eventSourceIdx)
        if ~obj.axes_Channel(axnum).Visible
            % Channel is not visible, skip update
            continue;
        end
        filenum = electro_gui.getCurrentFileNum(obj.settings);
        % Get threshold
        threshold = obj.dbase.EventThresholds(eventSourceIdx, filenum);
        if threshold == inf
            % Use default threshold if it's set to inf
            threshold = obj.settings.EventThresholdDefaults(eventSourceIdx);
        end
        % Get axes limits
        xl = xlim(obj.axes_Channel(axnum));
        yl = ylim(obj.axes_Channel(axnum));
        % Check if we need to create new threshold line, or just modify
        % existing one
        if ~isvalid(obj.EventThresholdHandles(axnum)) || ...
            isa(obj.EventThresholdHandles(axnum), 'matlab.graphics.GraphicsPlaceholder')
            % Create new threshold line
            hold(obj.axes_Channel(axnum), 'on');
            chan = obj.getSelectedChannel(axnum);
            [numSamples, fs] = obj.eg_GetSamplingInfo(filenum, chan);
            obj.EventThresholdHandles(axnum) = ...
                plot(obj.axes_Channel(axnum), ...
                     [0, numSamples/fs], ...
                     [threshold, threshold], ...
                     ':', 'Color', obj.settings.ChannelThresholdColor(axnum,:), 'HitTest', 'off', 'PickableParts', 'none');
            hold(obj.axes_Channel(axnum), 'off');
        else
            % Update threshold line y data
            obj.EventThresholdHandles(axnum).YData = [threshold, threshold];
        end
        % Reset axes limits to what they were before
        xlim(obj.axes_Channel(axnum), xl);
        ylim(obj.axes_Channel(axnum), yl);
    end
end

function SetEventThreshold(obj, axnum, threshold)
    arguments
        obj electro_gui
        axnum (1, 1) double
        threshold double = []
    end
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        eventSourceIdx = obj.addNewEventSourceFromChannelAxes(axnum);
    end
    if isempty(eventSourceIdx)
        % Still no event source - axes must not be ready
        msgbox('Please select both a channel number and an event detector before setting the threshold.')
        return;
    end

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    if isempty(threshold)
        % No threshold given, get it from the user
        answer = inputdlg({'Threshold'},'Threshold',1,{num2str(obj.dbase.EventThresholds(eventSourceIdx, filenum))});
        if isempty(answer)
            return
        end
        threshold = str2double(answer{1});
    end

    % Set the new event threshold
    if size(obj.dbase.EventThresholds, 1) < eventSourceIdx
        % First time setting thresholds for this event source - fill it with inf
        obj.dbase.EventThresholds(eventSourceIdx, :) = inf;
    end
    obj.dbase.EventThresholds(eventSourceIdx, filenum) = threshold;
    obj.settings.EventThresholdDefaults(eventSourceIdx) = threshold;

    % Update events for the event source configuration of this
    % channel axes.
    eventSourceIdx = obj.DetectEventsInAxes(axnum);

    for axn = 1:2
        if obj.GetChannelAxesEventSourceIdx(axn)==eventSourceIdx
            % Axes is visible and is currently showing the same
            % event source
            obj.UpdateChannelEventDisplay(axn);
        end
    end

    obj.UpdateEventViewer();
end

function eventSourceIdx = addNewEventSourceFromChannelAxes(obj, axnum, createPseudoChannels)
    % Add a new event source based on the current settings in the given
    % channel axes
    arguments
        obj electro_gui
        axnum (1, 1) double
        createPseudoChannels (1, 1) logical = true
    end
    [channelNum, channelName, ~, baseChannelIsPseudo] = obj.getSelectedChannel(axnum);
    filterName = obj.getSelectedFilter(axnum);
    filterParameters = obj.getSelectedFunctionParameters(axnum);
    eventDetectorName = obj.getSelectedEventDetector(axnum);
    defaultEventThreshold = obj.getDefaultEventThreshold(axnum);
    eventParameters = obj.getSelectedEventParameters(axnum);
    eventXLims = obj.getSelectedEventLims(axnum);
    eventParts = obj.getSelectedEventParts(axnum);
    if isempty(channelNum) || isempty(eventDetectorName)
        % Can't create an event source without a channel number and an
        % event detector
        eventSourceIdx = [];
        return;
    end
    [eventSourceIdx] = obj.addNewEventSource(channelNum, channelName, ...
        filterName, eventDetectorName, filterParameters, eventParameters, ...
        eventXLims, eventParts, defaultEventThreshold, baseChannelIsPseudo, ...
        createPseudoChannels);

    obj.UpdateChannelPopups();
end

function UpdateEventSourceList(obj)
    % Update the list of event sources above the event viewer axes

    % Set up the "none" option at the top
    eventListItems = {'(None)'};
    % Set null event list info for the "none" option
    eventListInfo(1).eventSourceIdx = [];
    eventListInfo(1).eventPartIdx = [];
    % Loop over event sources
    listIdx = 1;
    for eventSourceIdx = 1:length(obj.dbase.EventSources)
        eventParts = obj.dbase.EventParts{eventSourceIdx};
        % Loop over the event parts for this event source
        for eventPartIdx = 1:length(eventParts)
            listIdx = listIdx + 1;
            % Get event source info
            channelName = obj.dbase.EventSources{eventSourceIdx};
            filterName = obj.dbase.EventFunctions{eventSourceIdx};
            eventPart = eventParts{eventPartIdx};
            % Assemble event list info
            eventListInfo(listIdx).eventSourceIdx = eventSourceIdx;
            eventListInfo(listIdx).eventPartIdx = eventPartIdx;
            % Assemble event source text
            eventListItems{listIdx} = [channelName, ' - ', filterName, ' - ', eventPart];
        end
    end
    % Update list
    obj.popup_EventListAlign.String = eventListItems;
    obj.popup_EventListAlign.UserData = eventListInfo;
end

function DetectEvents(obj, eventSourceIdx, filenum, chanData, fs)
    % Detect events given an event source index
    % Optionally provide pre-filtered channel data for speed

    if ~exist('chanData', 'var')
        % No pre-filtered channel data provided
        chanData = [];
    end
    if ~exist('fs', 'var')
        % No channel sampling rate provided
        fs = obj.dbase.Fs;
    end
    if ~exist('filenum', 'var') || isempty(filenum)
        % Use current filenum
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    % Get info about the specified event source
    [channelNum, filterName, eventDetectorName, eventParameters, filterParameters] = obj.GetEventSourceInfo(eventSourceIdx);

    if isempty(chanData)
        % Load and filter channel data
        [chanData, fs] = obj.loadChannelData(channelNum, 'FilterName', filterName, 'FilterParams', filterParameters, 'FileNum', filenum);
    end

    % Get event threshold
    threshold = obj.dbase.EventThresholds(eventSourceIdx, filenum);

    % Run event detector plugin to get a list of detected event times
    [eventTimes, ~] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, eventDetectorName, chanData, fs, threshold, eventParameters);

    % Store event info in relevant data structures
    for eventPartNum = 1:length(eventTimes)
        obj.dbase.EventTimes{eventSourceIdx}{eventPartNum, filenum} = eventTimes{eventPartNum};
        obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum} = true(1,length(eventTimes{eventPartNum}));
    end
end

function numEvents = CheckEventCount(obj, eventSourceIdx, filenum)
    % Check how many events have been detected for the given event source
    % and filenum
    if isempty(obj.dbase.EventTimes{eventSourceIdx})
        numEvents = 0;
    elseif filenum > size(obj.dbase.EventTimes{eventSourceIdx}, 2)
        numEvents = 0;
    else
        numEvents = length(obj.dbase.EventTimes{eventSourceIdx}{1, filenum});
    end
end

function threshold = updateEventThreshold(obj, eventSourceIdx, filenum)
    % Get the current threshold. If it is inf, set it instead to the
    % current default threshold for this event source. Return the
    % threshold.
    threshold = obj.dbase.EventThresholds(eventSourceIdx, filenum);
    if threshold == inf
        % If threshold is infinite, use the default threshold
        threshold = obj.settings.EventThresholdDefaults(eventSourceIdx);
    end
    obj.dbase.EventThresholds(eventSourceIdx, filenum) = threshold;
end

function threshold = updateEventThresholdInAxes(obj, axnum)
    % Get event source matching current channel configuration
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    filenum = electro_gui.getCurrentFileNum(obj.settings);
    threshold = obj.updateEventThreshold(eventSourceIdx, filenum);
end

function AutoDetectEvents(obj, axnum)
    % If appropriate, detect events in the axes

    % Get event source matching current channel configuration
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    if obj.menu_EventAutoDetect(axnum).Checked
        % User requests auto detect
        if isempty(eventSourceIdx)
            % Create an event source from the current axes configuration
            eventSourceIdx = obj.addNewEventSourceFromChannelAxes(axnum);
            obj.UpdateChannelPopups();
            obj.UpdateEventSourceList();
        end
        if isempty(eventSourceIdx)
            % If event source is still empty, channel must not be ready for
            % event detection - abort.
            return
        end
        if all(cellfun(@isempty, obj.dbase.EventTimes{eventSourceIdx}(:, filenum)), 'all')
            % No events currently exist for this event source/filenum
            obj.DetectEventsInAxes(axnum);
        end
    end
end

function eventSourceIdx = DetectEventsInAxes(obj, axnum)
    % Use the configuration of the given channel axes to either create a
    % new event source, or update an existing one, with detected events.

    % Get event source matching current channel configuration
    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
    if isempty(eventSourceIdx)
        % No existing event source matches - create a blank one
        eventSourceIdx = obj.addNewEventSourceFromChannelAxes(axnum);
        obj.UpdateEventSourceList();
    end

    [~, ~, eventDetectorName] = obj.GetEventSourceInfo(eventSourceIdx);
    if strcmp(eventDetectorName, '(None)')
        % No event detector selected
        return
    end

    % Get channel data
    chanData = obj.loadedChannelData{axnum};

    filenum = electro_gui.getCurrentFileNum(obj.settings);

    % Detect events
    obj.DetectEvents(eventSourceIdx, filenum, chanData);

    % Remove any active event
    obj.settings.ActiveEventNum = [];
    obj.settings.ActiveEventPartNum = [];
    obj.settings.ActiveEventSourceIdx = [];

    % Remove active event cursor, in case it already exists
    delete(obj.ActiveEventCursors);

    % Update GUI
    obj.UpdateChannelEventDisplay(axnum);
    obj.UpdateEventSourceList();
end

function clearEventMarkerHandles(obj, axnum)
    % Delete all event markers in channel axes
    for eventPartNum = 1:length(obj.EventHandles{axnum})
        delete(obj.EventHandles{axnum}{eventPartNum});
    end
    obj.EventHandles{axnum} = {};
end

function clearEventWaveHandles(obj)
    % Delete all event markers in channel axes
    delete(obj.EventWaveHandles);
    obj.EventWaveHandles = gobjects().empty();
    ylabel(obj.axes_Events, '');
end

function UpdateDisplayForEventSource(obj, eventSourceIdx)
    % Update any displays (channel axes or event viewer) that are currently
    % displaying the given event source idx
    eventViewerEventSourceIdx = obj.GetEventViewerEventSourceIdx();
    if eventSourceIdx == eventViewerEventSourceIdx
        obj.UpdateEventViewer();
    end
    for axnum = 1:2
        channelAxesEventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
        if eventSourceIdx == channelAxesEventSourceIdx
            obj.UpdateChannelEventDisplay(axnum);
        end
    end
end

function UpdateChannelEventDisplay(obj, axnum)
    % Get the index of the event source (a channel, but not in numerical
    % order, see obj.dbase.EventSources for order)
    if ~obj.axes_Channel(axnum).Visible
        % Axes isn't visible, no point in updating it.
        return;
    end

    eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);

    obj.clearEventMarkerHandles(axnum);

    if isempty(eventSourceIdx)
        % No event source
        obj.menu_Events(axnum).Enable = 'off';
        return
    else
        obj.menu_Events(axnum).Enable = 'on';
    end

    obj.UpdateEventThresholdDisplay(eventSourceIdx);

    filenum = electro_gui.getCurrentFileNum(obj.settings);
    hold(obj.axes_Channel(axnum), 'on');
    eventTimes = {};
    eventSelected = {};
    obj.EventHandles{axnum} = {};
    for eventPartIdx = 1:size(obj.dbase.EventTimes{eventSourceIdx},1)
        eventTimes{eventPartIdx} = obj.dbase.EventTimes{eventSourceIdx}{eventPartIdx, filenum};
        eventSelected{eventPartIdx} = obj.dbase.EventIsSelected{eventSourceIdx}{eventPartIdx, filenum};
    end

    % Get event detector name
    [~, ~, eventDetectorName] = obj.GetEventSourceInfo(eventSourceIdx);

    % Run event detector plugin to get a list of detected event times
    [~, eventParts] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, eventDetectorName, 'params');

    % Update event part selection menu
    for eventPartNum = 1:length(eventParts)
        eventPart = eventParts{eventPartNum};
        obj.menu_EventsDisplayList{axnum}(eventPartNum) = uimenu(obj.menu_EventsDisplay(axnum),...
        'Label',eventPart,...
        'Callback',@obj.EventPartDisplayClick, ...
        'Checked','on');
    end

    % Determine which of the event part to display (based on event parts
    % defined by event detection plugin)
    eventPartMenuItem = obj.menu_EventsDisplayList{axnum};

    % Get channel data
    chanData = obj.loadedChannelData{axnum};

    chan = obj.getSelectedChannel(axnum);
    [numSamples, fs] = obj.eg_GetSamplingInfo([], chan);

    times = linspace(0, numSamples/fs, numSamples);
    for eventPartIdx = 1:length(eventTimes)
        storedInfo.eventPartIdx = eventPartIdx;
        if eventPartMenuItem(eventPartIdx).Checked
            % Hack to enable a single plot command to produce many separate
            % plot objects with no rendered 0-length lines
            eventXs = vertcat(times(eventTimes{eventPartIdx}), nan(1, length(eventTimes{eventPartIdx})));
            eventYs = vertcat(chanData(eventTimes{eventPartIdx})', nan(1, length(eventTimes{eventPartIdx})));
            % Plot all events with black markers
            obj.EventHandles{axnum}{eventPartIdx} = ...
                plot(obj.axes_Channel(axnum), eventXs, eventYs, 'o', ...
                    'LineStyle', 'none', 'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', 'k', 'MarkerSize', 5, ...
                    'UserData', storedInfo, ...
                    'ButtonDownFcn', @obj.ClickEventSymbol);
            % Set unselected event markers to white
            [obj.EventHandles{axnum}{eventPartIdx}(~eventSelected{eventPartIdx}).MarkerFaceColor] = deal('w');
        else
            obj.EventHandles{axnum}{eventPartIdx} = [];
        end
    end

    % Update event threshold line
    obj.UpdateEventThresholdDisplay(eventSourceIdx);
end

function UpdateEventViewer(obj, keepView)
    arguments
        obj electro_gui
        keepView = false
    end
    if isempty(keepView)
        keepView = false;
    end

    if keepView
        storedXLim = xlim(obj.axes_Events);
        storedYLim = ylim(obj.axes_Events);
    end

    delete(obj.ActiveEventCursors);
    obj.clearEventWaveHandles();

    hold(obj.axes_Events, 'on');

    eventSourceIdx = obj.GetEventViewerEventSourceIdx();

    if isempty(eventSourceIdx)
        obj.axes_Events.Visible = 'off';
        return
    else
        obj.axes_Events.Visible = 'on';
    end

    % Determine what data should be displayed
    val = obj.popup_EventListData.Value;
    dataSources = obj.popup_EventListData.String;
    dataSource = dataSources{val};
    switch dataSource
        case '<< Source'
            % Check if any of the channels match the event alignment data source
            channelData = [];
            for axnum = 1:2
                chanEventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
                if eventSourceIdx == chanEventSourceIdx
                    % This channel matches - use the loaded channel data
                    channelData = obj.loadedChannelData{axnum};
                    fs = obj.loadedChannelFs{axnum};
                    channelYLabel = obj.axes_Channel(axnum).YLabel.String;
                    break;
                end
            end
            if isempty(channelData)
                % None of the currently loaded channels have this data,
                % load it from file
                [selectedChannelNum, selectedFilter, ~, ~, selectedFilterParams] = obj.GetEventSourceInfo(eventSourceIdx);
                [channelData, fs, channelYLabel] = ...
                    obj.loadChannelData(selectedChannelNum, ...
                    'FilterName', selectedFilter, ...
                    'FilterParams', selectedFilterParams);
            end
        case 'Top axes'
            channelData = obj.loadedChannelData{1};
            channelYLabel = (obj.axes_Channel(1).YLabel.String);
            fs = obj.loadedChannelFs{1};
        case 'Bottom axes'
            channelData = obj.loadedChannelData{2};
            channelYLabel = (obj.axes_Channel(2).YLabel.String);
            fs = obj.loadedChannelFs{2};
    end

    filenum = electro_gui.getCurrentFileNum(obj.settings);
    eventPartIdx = obj.GetEventViewerEventPartIdx();

    allEventTimes = obj.dbase.EventTimes{eventSourceIdx}(:,filenum);
    eventTimes = obj.dbase.EventTimes{eventSourceIdx}{eventPartIdx,filenum};
    eventSelection = obj.dbase.EventIsSelected{eventSourceIdx}{eventPartIdx,filenum};

    if obj.menu_DisplayValues.Checked
        % "Display > Values" in Event axes context menu is selected
        obj.EventWaveHandles = gobjects().empty;
        % Check if there is channel data
        if ~isempty(channelData)
            % Loop over events
            for eventNum = 1:length(eventTimes)
                % Get the event time and time limits
                eventTime = eventTimes(eventNum);
                leftWidth = round(obj.settings.EventXLims(eventSourceIdx, 1) * fs);
                rightWidth = round(obj.settings.EventXLims(eventSourceIdx, 2) * fs);
                startTime = max([1, eventTime - leftWidth]);
                endTime = min([length(channelData), eventTime + rightWidth]);
                if eventSelection(eventNum)
                    % If event is selected, plot the wave
                    obj.EventWaveHandles(eventNum) = plot(obj.axes_Events, ((startTime:endTime)-eventTimes(eventNum))/fs*1000,channelData(startTime:endTime),'Color','k');
                else
                    % If event is not selected, use graphics placeholder
                    obj.EventWaveHandles(eventNum) = gobjects();
                end
            end
            xlabel(obj.axes_Events, 'Time (ms)');
            ylabel(obj.axes_Events, channelYLabel);
            xlim(obj.axes_Events, [-obj.settings.EventXLims(eventSourceIdx, 1), obj.settings.EventXLims(eventSourceIdx, 2)]*1000);
            axis(obj.axes_Events, 'tight');
            yl = ylim(obj.axes_Events);
            ylim(obj.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            obj.clearEventWaveHandles();
        end
    else
        % "Display > Features" in Event axes context menu is selected
        obj.EventWaveHandles = gobjects().empty;
        if ~isempty(channelData)
            f = findobj('Parent',obj.menu_XAxis,'Checked','on');
            str = f.Label;
            [feature1, name1] = electro_gui.eg_runPlugin(obj.plugins.eventFeatures, ...
                str, channelData, fs, allEventTimes, g, ...
                round(obj.settings.EventXLims(obj.popup_EventListAlign.Value,:)*fs));
            f = findobj('Parent',obj.menu_YAxis,'Checked','on');
            str = f.Label;
            [feature2, name2] = electro_gui.eg_runPlugin(obj.plugins.eventFeatures, ...
                str, channelData, fs, allEventTimes, g, ...
                round(obj.settings.EventXLims(obj.popup_EventListAlign.Value,:)*fs));

            for c = 1:length(feature1)
                if eventSelection(c)==1
                    obj.EventWaveHandles(end+1) = plot(obj.axes_Events, ...
                        feature1(c),feature2(c), 'o', 'MarkerFaceColor', 'k', ...
                        'MarkerEdgeColor', 'k', 'MarkerSize', 2);
                else
                    obj.EventWaveHandles(end+1) = gobjects();
                end
            end
            xlabel(obj.axes_Events, name1);
            ylabel(obj.axes_Events, name2);

            axis(obj.axes_Events, 'tight');
            xl = xlim(obj.axes_Events);
            xlim(obj.axes_Events, [mean(xl)+(xl(1)-mean(xl))*1.1 mean(xl)+(xl(2)-mean(xl))*1.1]);
            yl = ylim(obj.axes_Events);
            ylim(obj.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            xlabel('');
            ylabel('');
        end
    end

    % Set click handlers for event waves
    for k = 1:length(obj.EventWaveHandles)
        if isgraphics(obj.EventWaveHandles(k))
            obj.EventWaveHandles(k).ButtonDownFcn = @obj.click_eventwave;
        end
    end

    obj.axes_Events.UIContextMenu = obj.context_EventViewer;
    obj.axes_Events.ButtonDownFcn = @obj.click_eventaxes;
    for child = obj.axes_Events.Children'
        child.UIContextMenu = obj.axes_Events.UIContextMenu;
    end

    obj.SetActiveEventDisplay(obj.settings.ActiveEventNum, obj.settings.ActiveEventPartNum, obj.settings.ActiveEventSourceIdx);

    if obj.menu_AutoApplyYLim.Checked && ~isempty(obj.EventWaveHandles)
        if obj.menu_DisplayValues.Checked
            % Update this
%             if obj.menu_AnalyzeTop.Checked && obj.menu_AutoLimits1.Checked
%                 obj.axes_Channel1.YLim = obj.axes_Events.YLim;
%             elseif obj.menu_AutoLimits2.Checked
%                 obj.axes_Channel2.YLim = obj.axes_Events.YLim;
%             end
        end
    end

    if keepView
        xlim(obj.axes_Events, storedXLim);
        ylim(obj.axes_Events, storedYLim);
    end
end

function [channelNum, filterName, eventDetectorName] = GetEventViewerSourceInfo(obj)
    % Return the channel number, filter name, and event detector name for
    % the currently displayed event source in the event viewer
    eventSourceIdx = obj.GetEventViewerEventSourceIdx();
    if isempty(eventSourceIdx)
        % No event source selected
        channelNum = [];
        filterName = '';
        eventDetectorName = '';
    else
        [channelNum, filterName, eventDetectorName] = obj.GetEventSourceInfo(eventSourceIdx);
    end
end
function [channelNum, filterName, eventDetectorName, eventParameters, ...
        filterParameters, eventLims, eventParts, defaultThreshold, ...
        isPseudoChannel] = GetEventSourceInfo(obj, eventSourceIdx)
    % Return the channel number, filter name, and event detector name for
    % the given event source index
    channelNum = obj.dbase.EventChannels(eventSourceIdx);
    filterName = obj.dbase.EventFunctions{eventSourceIdx};
    filterParameters = obj.dbase.EventFunctionParameters{eventSourceIdx};
    eventDetectorName = obj.dbase.EventDetectors{eventSourceIdx};
    eventParameters = obj.dbase.EventParameters{eventSourceIdx};
    eventLims = obj.settings.EventXLims(eventSourceIdx, :);
    eventParts = obj.dbase.EventParts{eventSourceIdx};
    defaultThreshold = obj.settings.EventThresholdDefaults(eventSourceIdx);
    isPseudoChannel = obj.dbase.EventChannelIsPseudo(eventSourceIdx);
end
function [channelNum, filterName, eventDetectorName] = GetChannelAxesInfo(obj, axnum)
    % Return the current settings of specified channel axes
    channelNum = obj.getSelectedChannel(axnum);
    filterName = obj.getSelectedFilter(axnum);
    eventDetectorName = obj.getSelectedEventDetector(axnum);

% function [eventSourceTexts, eventSourceIdxs, eventPartIdxs] = ParseEventSourceListText(eventSourceListText)
%     % For legacy dbase loading, attempt to parse a stored event viewer
%     % event source list text
%     parts = split(eventSourceListText, ' - ');
%
end
function SetEventViewerEventListElement(obj, eventListIdx, eventSourceText, eventSourceIdx, eventPartIdx)
    % Set the specified element of the event viewer event source list
    if ~exist('eventListIdx', 'var') || isempty(eventListIdx)
        % Add element on to the end if no list index is provided
        eventListIdx = length(obj.popup_EventListAlign.String)+1;
    end
    obj.popup_EventListAlign.String{eventListIdx} = eventSourceText;
    obj.popup_EventListAlign.UserData(eventListIdx).eventSourceIdx = eventSourceIdx;
    obj.popup_EventListAlign.UserData(eventListIdx).eventPartIdx = eventPartIdx;
end
function eventSourceIdx = GetEventViewerEventSourceIdx(obj)
    % Get the event source index from the currently selected item in the
    % event viewer event source list
    eventListIdx = obj.popup_EventListAlign.Value;
    eventSourceIdx = obj.popup_EventListAlign.UserData(eventListIdx).eventSourceIdx;
end
function eventPartIdx = GetEventViewerEventPartIdx(obj)
    % Get the event part index from the currently selected item in the
    % event viewer event source list
    eventListIdx = obj.popup_EventListAlign.Value;
    eventPartIdx = obj.popup_EventListAlign.UserData(eventListIdx).eventPartIdx;
end
function eventSourceIdx = GetChannelAxesEventSourceIdx(obj, axnum)
    % Get the event source index that matches the current settings of the
    % given channel axes. If there is no match, return an empty array
    [axChannelNum, axFilterName, axEventDetectorName] = obj.GetChannelAxesInfo(axnum);
    if ~isempty(axChannelNum) && ~isempty(axEventDetectorName)
        for eventSourceIdx = 1:length(obj.dbase.EventSources)
            [channelNum, filterName, eventDetectorName] = obj.GetEventSourceInfo(eventSourceIdx);
            if axChannelNum == channelNum && ...
               ((isempty(axFilterName) && isempty(filterName)) || ...
                    strcmp(axFilterName, filterName)) && ...
               ((isempty(axEventDetectorName) && isempty(eventDetectorname)) || ...
                    strcmp(axEventDetectorName, eventDetectorName))
                % Found a match
                return
            end
        end
    end
    % No match found
    eventSourceIdx = [];
end
function matchingEventSourceIdx = WhichEventSourceIdxMatch(obj, channelNum, filterName, eventDetectorName)
    % Get a list of eventSourceIdx that match a given set of channelNum,
    % filterName, eventDetectorName. If any of those are empty, they will
    % not be considered in the matching process
    if ~exist('channelNum', 'var')
        channelNum = [];
    end
    if ~exist('filterName', 'var')
        filterName = [];
    end
    if ~exist('eventDetectorName', 'var')
        eventDetectorName = [];
    end

    matchingEventSourceIdx = [];
    for eventSourceIdx = 1:length(obj.dbase.EventTimes)
        [channelNum2, filterName2, eventDetectorName2] = obj.GetEventSourceInfo(eventSourceIdx);
        if (isempty(channelNum) || channelNum==channelNum2) && ...
           (isempty(filterName) || strcmp(filterName, filterName2)) && ...
           (isempty(eventDetectorName) || eventDetectorName==eventDetectorName2)
            matchingEventSourceIdx(end+1) = eventSourceIdx;
        end
    end
end
function matchingAxnum = WhichChannelAxesMatchEventSource(obj, eventSourceIdx)
    % Return a list of axes indices indicating whether each of the channel
    % axes match the given event source index, or if that is not provided,
    % the currently displayed event viewer source.
    if ~exist('eventSourceIdx', 'var') || isempty(eventSourceIdx)
        % Use the event source index currently selected in the event viewer
        eventSourceIdx = obj.GetEventViewerEventSourceIdx();
    end

    matchingAxnum = [];
    for axnum = 1:2
        [channelNum, filterName, eventDetectorName] = obj.GetEventSourceInfo(eventSourceIdx);
        [axChannelNum, axFilterName, axEventDetectorName] = obj.GetChannelAxesInfo(axnum);
        if ~isempty(axChannelNum) && ~isempty(axFilterName) && ~isempty(axEventDetectorName)
            if channelNum == axChannelNum && ...
               strcmp(filterName, axFilterName) && ...
               strcmp(eventDetectorName, axEventDetectorName)
                matchingAxnum(end+1) = axnum;
            end
        end
    end
end

function axnum = GetAxnum(obj, hObject)
    % Given a graphics object, determine which channel axes it belongs to.
    while ~isa(hObject, 'matlab.graphics.axis.Axes')
        hObject = hObject.Parent;
    end
    axnum = find(hObject==obj.axes_Channel, 1);
end

function DeactivateEventDisplay(obj) %#ok<MANU> 
end

function numEvents = GetNumEvents(obj, eventSourceIdx, eventPartNum)
    % Get the # of events for the specified event source index and event
    % part num. If not provided, use the currently active event source
    % index and event part num.
    if ~exist('eventSourceIdx', 'var') || isempty(eventSourceIdx)
        % User didn't provide event source index - use the active one
        eventSourceIdx = obj.settings.ActiveEventSourceIdx;
    end
    if ~exist('eventPartNum', 'var') || isempty(eventPartNum)
        % User didn't provide event part number - use the active one
        eventPartNum = obj.settings.ActiveEventPartNum;
    end
    if isempty(eventSourceIdx) || isempty(eventPartNum)
        % Invalid event source index or part number
        numEvents = [];
    else
        numEvents = length(obj.dbase.EventTimes{eventSourceIdx}{eventPartNum});
    end
end

function UpdateAnythingShowingEventSource(obj, eventSourceIdx)
    % Update any event-related stuff that is currently displaying the given
    % event source index

    if isempty(eventSourceIdx)
        % Null event source, do nothing
        return;
    end

    matchingAxnums = obj.WhichChannelAxesMatchEventSource(eventSourceIdx);
    viewerEventSourceIdx = obj.GetEventViewerEventSourceIdx();

    % Update any channel axes that are showing that event source index
    for axnum = matchingAxnums
        obj.UpdateChannelEventDisplay(axnum);
    end

    % Update the event viewer if it is showing that event source index
    if eventSourceIdx == viewerEventSourceIdx
        obj.UpdateEventViewer();
    end
end

function SetActiveEventDisplay(obj, newActiveEventNum, newActiveEventPart, newEventSourceIdx)
    if ~exist('newActiveEventPart', 'var') || isempty(newActiveEventPart)
        % If not provided, assume we're not switching to a new event part
        newActiveEventPart = obj.settings.ActiveEventPartNum;
    end
    if ~exist('newEventSourceIdx', 'var') || isempty(newEventSourceIdx)
         newEventSourceIdx = obj.settings.ActiveEventSourceIdx;
    end

    oldActiveEventNum = obj.settings.ActiveEventNum;
    oldActiveEventPart = obj.settings.ActiveEventPartNum;
    oldActiveEventSourceIdx = obj.settings.ActiveEventSourceIdx;
    obj.settings.ActiveEventNum = newActiveEventNum;
    obj.settings.ActiveEventPartNum = newActiveEventPart;
    obj.settings.ActiveEventSourceIdx = newEventSourceIdx;
    obj.UpdateActiveEventDisplay(oldActiveEventNum, oldActiveEventPart, oldActiveEventSourceIdx);
end

function UpdateActiveEventDisplay(obj, oldActiveEventNum, oldActiveEventPart, oldEventSourceIdx)
    obj.SetEventDisplayActiveState(oldActiveEventNum, oldActiveEventPart, oldEventSourceIdx, false);
    obj.SetEventDisplayActiveState(obj.settings.ActiveEventNum, obj.settings.ActiveEventPartNum, oldEventSourceIdx, true);
end

function SetEventDisplayActiveState(obj, eventNum, eventPartNum, eventSourceIdx, activeState)
    % Take the given event number, event part, and event source index, and
    % set it to the given active state (either true => active or false =>
    % inactive

    if isempty(eventNum) || isempty(eventPartNum) || isempty(eventSourceIdx)
        % Can't make an event active if it doesn't exist or isn't visible, now can we
        return
    end

    % Check if event viewer is currently displaying this event
    eventViewerEventSourceIdx = obj.GetEventViewerEventSourceIdx();
    if ~isempty(eventViewerEventSourceIdx) && ...
       eventViewerEventSourceIdx == eventSourceIdx && ~isempty(obj.EventWaveHandles) && isgraphics(obj.EventWaveHandles(eventNum))
        % Event viewer is displaying this event's source
        % Update active event wave plot (in the event axes)
        if activeState
            obj.EventWaveHandles(eventNum).LineWidth = 2;
            obj.EventWaveHandles(eventNum).Color = 'r';
            uistack(obj.EventWaveHandles(eventNum), 'top');
        else
            obj.EventWaveHandles(eventNum).LineWidth = 1;
            obj.EventWaveHandles(eventNum).Color = 'k';
        end
    end

    % Update active event marker (in any channel axes that are displaying this event)
    matchingAxes = obj.WhichChannelAxesMatchEventSource(eventSourceIdx);
    for axnum = matchingAxes
        if ~isempty(obj.EventHandles{axnum}) && ~isempty(obj.EventHandles{axnum}{eventPartNum})
            eventMarkerHandle = obj.EventHandles{axnum}{eventPartNum}(eventNum);
            if activeState
                % Make event marker look active
                eventMarkerHandle.MarkerSize = 5;
                eventMarkerHandle.MarkerFaceColor = 'r';
                eventMarkerHandle.MarkerEdgeColor = 'r';
    %             uistack(eventMarkerHandle, 'top');
            else
                % Make event marker look inactive
                eventMarkerHandle.MarkerSize = 5;
                eventMarkerHandle.MarkerFaceColor = 'k';
                eventMarkerHandle.MarkerEdgeColor = 'k';
            end
        end
    end

    % Update active event cursor in sound axes
    if activeState
        sourceChannel = obj.GetEventSourceInfo(eventSourceIdx);
        [numSamples, fs] = obj.eg_GetSamplingInfo([], sourceChannel);
        filenum = electro_gui.getCurrentFileNum(obj.settings);
        ts = linspace(0, numSamples/fs, numSamples);
        eventTimes = obj.dbase.EventTimes{eventSourceIdx}{eventPartNum,filenum};
        if ~isempty(eventTimes)
            activeEventTime = ts(eventTimes(eventNum));
            obj.UpdateActiveEventCursors(activeEventTime);
        end
    else
        obj.UpdateActiveEventCursors([]);
    end
end

function UpdateActiveEventCursors(obj, eventTime)
    % Create, update, or delete the active event cursor

    % Delete the active event cursor
    delete(obj.ActiveEventCursors);

    if isempty(eventTime)
        return;
    end

%     if isempty(obj.ActiveEventCursors) || any(~isvalid(obj.ActiveEventCursors))
        % No active event cursor yet, reset them then create then
        obj.ActiveEventCursors = gobjects().empty;
        % Make list of axes to plot cursor on
        axesList = [obj.axes_Sound, obj.axes_Sonogram, obj.axes_Amplitude, obj.axes_Channel];
        % Remove any invalid or invisible axes
        axesList(~isvalid(axesList) | ~[axesList.Visible]) = [];
        for ax = axesList
            hold(ax, 'on');
            obj.ActiveEventCursors(end+1) = plot(ax, [eventTime, eventTime], ylim(ax), '-.', 'LineWidth' , 1, 'Color', 'r');
            hold(ax, 'off');
        end
end

function UnselectEvents(obj, eventNums, eventSourceIdx, filenum)
    arguments
        obj electro_gui
        eventNums (1, :) double
        eventSourceIdx double = obj.GetEventViewerEventSourceIdx()
            % Default is event source currently displayed on event viewer axes
        filenum double = electro_gui.getCurrentFileNum(obj.settings);
    end
    if isempty(eventSourceIdx)
        % Event viewer must be blank, can't delete events
        return;
    end
    if isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    % Unselect events
    for eventPartNum = 1:size(obj.dbase.EventIsSelected{eventSourceIdx}, 1)
        obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(eventNums) = false;
    end

    % Update GUI
    obj.UpdateEventViewer(true);
    axnums = obj.WhichChannelAxesMatchEventSource(eventSourceIdx);
    for axnum = axnums
        obj.UpdateChannelEventDisplay(axnum);
    end
end

function txt = addWorksheetTextBox(obj, newslide, text, fontSize, x, y, horizontalAnchor, verticalAnchor, paragraphAlignment, rotation)
    txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
    txt.TextFrame.TextRange.Text = text;
    if exist('verticalAnchor', 'var') && ~isempty(verticalAnchor)
        txt.TextFrame.VerticalAnchor = verticalAnchor;
    end
    if exist('horizontalAnchor', 'var') && ~isempty(horizontalAnchor)
        txt.TextFrame.HorizontalAnchor = horizontalAnchor;
    end
    txt.TextFrame.WordWrap = 'msoFalse';
    txt.TextFrame.MarginLeft = 0;
    txt.TextFrame.MarginRight = 0;
    txt.TextFrame.MarginTop = 0;
    txt.TextFrame.MarginBottom = 0;
    txt.TextFrame.TextRange.Font.Size = fontSize;
    txt.Height = txt.TextFrame.TextRange.BoundHeight;
    txt.Width = txt.TextFrame.TextRange.BoundWidth;
    if exist('x', 'var') && ~isempty(x)
        txt.Left = x;
    end
    if exist('y', 'var') && ~isempty(y)
        txt.Top = y;
    end
    if exist('paragraphAlignment', 'var') && ~isempty(paragraphAlignment)
        txt.TextFrame.TextRange.ParagraphFormat.Alignment = paragraphAlignment;
    end
    if exist('rotation', 'var') && ~isempty(rotation)
        txt.Rotation = rotation;
    end
end
function UpdateWorksheet(obj)

    max_width = obj.settings.WorksheetWidth - 2*obj.settings.WorksheetMargin;
    widths = [];
    for c = 1:length(obj.settings.WorksheetXLims)
        widths(c) = (obj.settings.WorksheetXLims{c}(2)-obj.settings.WorksheetXLims{c}(1))*obj.settings.ExportSonogramWidth;
    end

    if obj.settings.WorksheetChronological == 1
        [~, sortOrder] = sort(obj.settings.WorksheetTimes);
    else
        sortOrder = 1:length(obj.settings.WorksheetXLims);
    end

    worksheetList = [];
    used = [];
    for c = 1:length(sortOrder)
        indx = sortOrder(c);
        if obj.settings.WorksheetOnePerLine == 1 || isempty(used)
            worksheetList{end+1} = indx;
            used(end+1) = widths(indx);
        else
            if obj.settings.WorksheetChronological == 1
                if used(end)+widths(indx) <= max_width
                    worksheetList{end}(end+1) = indx;
                    used(end) = used(end) + widths(indx) + obj.settings.WorksheetHorizontalInterval;
                else
                    worksheetList{end+1} = indx;
                    used(end+1) = widths(indx);
                end
            else
                f = find(used+widths(indx) <= max_width);
                if isempty(f)
                    worksheetList{end+1} = indx;
                    used(end+1) = widths(indx);
                else
                    [~, j] = max(used(f));
                    ins = f(j(1));
                    worksheetList{ins}(end+1) = indx;
                    used(ins) = used(ins) + widths(indx) + obj.settings.WorksheetHorizontalInterval;
                end
            end
        end
    end

    obj.settings.WorksheetList = worksheetList;
    obj.settings.WorksheetUsed = used;
    obj.settings.WorksheetWidths = widths;

    perpage = fix(0.001+(obj.settings.WorksheetHeight - 2*obj.settings.WorksheetMargin - obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight)/(obj.settings.ExportSonogramHeight + obj.settings.WorksheetVerticalInterval));
    pagenum = fix((0:length(worksheetList)-1)/perpage)+1;

    cla(obj.axes_Worksheet);
    patch(obj.axes_Worksheet, [0, obj.settings.WorksheetWidth, obj.settings.WorksheetWidth, 0], [0, 0, obj.settings.WorksheetHeight, obj.settings.WorksheetHeight],'w');
    hold(obj.axes_Worksheet, 'on');
    if obj.settings.WorksheetCurrentPage > max(pagenum)
        obj.settings.WorksheetCurrentPage = max(pagenum);
    end
    f = find(pagenum==obj.settings.WorksheetCurrentPage);
    obj.WorksheetHandles = gobjects().empty;
    for c = 1:length(f)
        indx = f(c);
        for d = 1:length(worksheetList{indx})
            x = (obj.settings.WorksheetWidth-used(indx))/2 + sum(widths(worksheetList{indx}(1:d-1))) + obj.settings.WorksheetHorizontalInterval*(d-1);
            wd = widths(worksheetList{indx}(d));
            y = obj.settings.WorksheetHeight - obj.settings.WorksheetMargin - obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight - obj.settings.WorksheetVerticalInterval*c - obj.settings.ExportSonogramHeight*c;
            obj.WorksheetHandles(worksheetList{indx}(d)) = patch(obj.axes_Worksheet, [x, x+wd, x+wd, x], [y, y, y+obj.settings.ExportSonogramHeight, y+obj.settings.ExportSonogramHeight], [.5, .5, .5]);
        end
    end

    for k = 1:length(obj.WorksheetHandles)
        obj.WorksheetHandles(k).ButtonDownFcn = @obj.click_Worksheet;
        obj.WorksheetHandles(k).UIContextMenu = obj.context_Worksheet;
    end

    axis(obj.axes_Worksheet, 'equal');
    axis(obj.axes_Worksheet, 'tight');
    axis(obj.axes_Worksheet, 'off');

    obj.panel_Worksheet.Title = ['Worksheet: Page ' num2str(obj.settings.WorksheetCurrentPage) '/' num2str(max([1 max(pagenum)]))];
end

function ViewWorksheet(obj)

    f = find(obj.WorksheetHandles==findobj('Parent',obj.axes_Worksheet,'FaceColor','r'));

    fig = figure;
    fig.Visible = 'off';
    fig.Units = 'inches';
    pos = fig.Position;
    pos(3) = obj.settings.ExportSonogramWidth*(obj.settings.WorksheetXLims{f}(2)-obj.settings.WorksheetXLims{f}(1));
    pos(4) = obj.settings.ExportSonogramHeight;
    fig.Position = pos;
    ax = subplot('Position',[0 0 1 1]);
    hold(ax, 'on');
    for c = 1:length(obj.settings.WorksheetMs{f})
        imagesc(ax, obj.settings.WorksheetXs{f}{c},obj.settings.WorksheetYs{f}{c},obj.settings.WorksheetMs{f}{c});
    end
    ax.CLim = obj.settings.WorksheetClim{f};
    fig.Colormap = obj.settings.WorksheetColormap{f};
    axis(ax, 'tight');
    axis(ax, 'off');
    fig.Visible = 'on';
end


function eg_Overlay(obj)
    % Show, delete, or update channel data overlaid directly on top of the
    % sonogram, depending on the settings within obj.menu_Overlay_Callback

    % Collect list of channel axes that will and will not be overlaid on
    % top of the sonogram
    axnums = [];
    notAxnums = [];
    if obj.menu_OverlayTop.Checked
        axnums = [axnums 1];
    else
        notAxnums = [notAxnums, 1];
    end
    if obj.menu_OverlayBottom.Checked
        axnums = [axnums 2];
    else
        notAxnums = [notAxnums, 2];
    end

    % Delete unchecked overlays
    for axnum = notAxnums
        delete(obj.Sonogram_Overlays(axnum));
    end

    if ~isempty(axnums)
        % Create or update overlays
        hold(obj.axes_Sonogram, 'on');

        for axnum = axnums
            y = obj.loadedChannelData{axnum};
            if ~isempty(y)
                % Scale data to fit nicely on top of sonogram
                yl1 = obj.axes_Channel(axnum).YLim;
                yl2 = obj.axes_Sonogram.YLim;
                y = (y - yl1(1)) / diff(yl1);
                y = y * diff(yl2) + yl2(1);
                if isvalid(obj.Sonogram_Overlays(axnum))
                    obj.Sonogram_Overlays(axnum).YData = y;
                else
                    chan = obj.getSelectedChannel(axnum);
                    [numSamples, fs] = obj.eg_GetSamplingInfo([], chan);
                    t = linspace(0, numSamples/fs, numSamples);
                    obj.Sonogram_Overlays(axnum) = plot(obj.axes_Sonogram, t, y, 'Color', 'b', 'LineWidth', 1);
                    obj.Sonogram_Overlays(axnum).UIContextMenu = obj.axes_Sonogram.UIContextMenu;
                    obj.Sonogram_Overlays(axnum).ButtonDownFcn = obj.axes_Sonogram.ButtonDownFcn;
                end
            end
        end

        hold(obj.axes_Sonogram, 'off');
    end


end

function menu_FunctionParams(obj,axnum)

    pr = obj.settings.ChannelAxesFunctionParams{axnum};

    if ~isfield(pr,'Names') || isempty(pr.Names)
        errordlg('Current function does not require parameters.','Function error');
        return
    end

    answer = inputdlg(pr.Names,'Function parameters',1,pr.Values);
    if isempty(answer)
        return
    end
    pr.Values = answer;

    obj.settings.ChannelAxesFunctionParams{axnum} = pr;

    v = obj.popup_Functions(axnum).Value;
    ud = obj.popup_Functions(axnum).UserData;
    ud{v} = obj.settings.ChannelAxesFunctionParams{axnum};
    obj.popup_Functions(axnum).UserData = ud;

%     if isempty(findobj('Parent',obj.axes_Sonogram,'type','text'))
        obj.eg_LoadChannel(axnum);
        obj.DetectEventsInAxes(axnum);
%     end


end
function updateAmplitude(obj, options)
    % Update amplitude axes according to data in obj.amplitude
    arguments
        obj electro_gui
        options.ForceRedraw logical = false
    end

    forceRedraw = options.ForceRedraw;

    % Recalculate amplitude data
    if obj.menu_DontPlot.Checked
        obj.amplitude = zeros(size(obj.filtered_sound));
        labels = '';
    else
        obj.UpdateFilteredSound();
        [obj.amplitude, fs, labels] = obj.calculateAmplitude();
    end

    if (isempty(obj.AmplitudePlotHandle) || ~isgraphics(obj.AmplitudePlotHandle) || forceRedraw) ...
            && ~isempty(obj.amplitude)
        numSamples = obj.eg_GetSamplingInfo();
        filenum = electro_gui.getCurrentFileNum(obj.settings);

        obj.AmplitudePlotHandle = plot(obj.axes_Amplitude, linspace(0, numSamples/fs, numSamples),obj.amplitude,'Color',obj.settings.AmplitudeColor);
        obj.axes_Amplitude.XTickLabel  = [];
        ylim(obj.axes_Amplitude, obj.settings.AmplitudeLims);
        box(obj.axes_Amplitude, 'off');
        ylabel(obj.axes_Amplitude, labels);
        obj.axes_Amplitude.UIContextMenu = obj.context_Amplitude;
        obj.axes_Amplitude.ButtonDownFcn = @obj.click_Amplitude;
        for child = obj.axes_Amplitude.Children'
            child.UIContextMenu = obj.axes_Amplitude.UIContextMenu;
        end
        for child = obj.axes_Amplitude.Children'
            child.ButtonDownFcn = obj.axes_Amplitude.ButtonDownFcn;
        end

        if obj.dbase.SegmentThresholds(filenum)==inf
            if obj.menu_AutoThreshold.Checked
                obj.settings.CurrentThreshold = electro_gui.eg_AutoThreshold(obj.amplitude);
            end
            obj.dbase.SegmentThresholds(filenum) = obj.settings.CurrentThreshold;
        else
            obj.settings.CurrentThreshold = obj.dbase.SegmentThresholds(filenum);
        end
        obj.SegmentLabelHandles = gobjects().empty;
        obj.SetSegmentThreshold();
    else
        % Just update y values
        obj.AmplitudePlotHandle.YData = obj.amplitude;
        ylabel(obj.axes_Amplitude, labels);
    end
end

function [amp, fs, labels] = calculateAmplitude(obj, filenum)
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    [filteredSound, fs] = obj.getFilteredSound([], [], [], filenum);

    windowSize = round(obj.settings.SmoothWindow*fs);
    if obj.menu_SourceSoundAmplitude.Checked
        amp = smooth(10*log10(filteredSound.^2+eps), windowSize);
        amp = amp-min(amp(windowSize:length(amp)-windowSize));
        amp(amp<0)=0;
        labels = 'Loudness (dB)';
    else
        if obj.menu_SourceTopPlot.Checked
            axnum = 1;
        elseif obj.menu_SourceBottomPlot.Checked
            axnum = 2;
        else
            error('Nothing selected for amplitude source');
        end

        if obj.axes_Channel(axnum).Visible
            channelNum = obj.getSelectedChannel(axnum);
            filterName = obj.getSelectedFilter(axnum);
            filterParams = obj.getSelectedFunctionParameters(axnum);
            [channelData, fs] = obj.loadChannelData(...
                channelNum, 'FilterName', filterName, ...
                'FilterParams', filterParams, 'FileNum', filenum);
            amp = smooth(channelData, windowSize);
            labels = obj.axes_Channel1.YLabel.String;
        else
            amp = zeros(size(obj.filtered_sound));
            labels = '';
            fs = obj.dbase.Fs;
        end
    end

end
function snd = GenerateSound(obj, sound_type)
    % Generate sound with the selected options. Sound_type is either 'snd' or
    % 'mix'

    [sound, fs] = obj.getSound();

    snd = zeros(size(sound));
    if obj.playback_SoundInMix.Checked==1 || strcmp(sound_type,'snd')
        if obj.playback_FilteredSound.Checked
            filtered_sound = obj.filterSound(sound);
            snd = snd + filtered_sound * obj.SoundWeights(1);
        else
            snd = snd + sound * obj.SoundWeights(1);
        end
    end

    if strcmp(sound_type,'mix')
        if obj.axes_Channel1.Visible && obj.playback_TopInMix.Checked==1
            addval = obj.loadedChannelData{1};
            addval(abs(addval) < obj.SoundClippers(1)) = 0;
            addval = addval * obj.SoundWeights(2);
            if size(addval,2)>size(addval,1)
                addval = addval';
            end
            snd = snd + addval;
        end
        if obj.axes_Channel2.Visible && obj.playback_BottomInMix.Checked==1
            addval = obj.loadedChannelData{2};
            addval(abs(addval) < obj.SoundClippers(2)) = 0;
            addval = addval * obj.SoundWeights(3);
            if size(addval,2)>size(addval,1)
                addval = addval';
            end
            snd = snd + addval;
        end
    end

    xd = obj.axes_Sonogram.XLim;
    xd = round(xd * fs);
    xd(1) = xd(1)+1;
    xd(2) = xd(2)-1;
    if xd(1)<1
        xd(1) = 1;
    end
    if xd(2)>length(snd)
        xd(2) = length(snd);
    end
    snd = snd(xd(1):xd(2));

    if obj.playback_Reverse.Checked
        snd = snd(end:-1:1);
    end


end
function setFileSortMethod(obj, sortMethod, updateGUI)
    arguments
        obj electro_gui
        sortMethod char
        updateGUI logical = true
    end

    sortMethodIdx = find(strcmp(sortMethod, obj.popup_FileSortOrder.String), 1);
    if isempty(sortMethodIdx)
        error('Invalid sort method: ''%s''', sortMethod);
    end
    obj.settings.FileSortMethod = sortMethod;
    obj.popup_FileSortOrder.Value = sortMethodIdx;
    if updateGUI
        obj.RefreshSortOrder();
    end
end

function setFileSortInfo(obj, fileSortMethod, fileSortPropertyName, fileSortReversed, updateGUI)
    % Set all the file sort info at once, then update
    if ~exist('updateGUI', 'var') || isempty(updateGUI)
        updateGUI = true;
    end

    obj.setFileSortMethod(fileSortMethod, false);
    obj.settings.FileSortPropertyName = fileSortPropertyName;
    obj.setFileSortReversed(fileSortReversed);

    if updateGUI
        obj.RefreshSortOrder();
    end
end

function setFileSortReversed(obj, reversed)
    obj.settings.IsFileSortReversed = reversed;
    obj.check_ReverseSort.Value = reversed;
end

function RefreshSortOrder(obj)
    % Create a new random order for the files
    sortMethod = obj.settings.FileSortMethod;
    sortReversed = obj.settings.IsFileSortReversed;
    numFiles = electro_gui.getNumFiles(obj.dbase);

    switch sortMethod
        case 'File number'
            obj.settings.FileSortOrder = [];
        case 'Random'
            obj.settings.FileSortOrder = randperm(numFiles);
        case 'Property'
            propertyValues = obj.getPropertyValue(...
                obj.settings.FileSortPropertyName, 1:numFiles);
            [~, obj.settings.FileSortOrder] = sort(~propertyValues);
        case 'Read status'
            [~, obj.settings.FileSortOrder] = sort(obj.settings.FileReadState);
        otherwise
            error('Unknown sort method: ''%s''', sortMethod)
    end
    if sortReversed
        obj.settings.FileSortOrder = reverse(obj.settings.FileSortOrder);
    end
    if isempty(obj.settings.FileSortOrder)
        obj.settings.InverseFileSortOrder = [];
    else
        obj.settings.InverseFileSortOrder = zeros(size(obj.settings.FileSortOrder));
        obj.settings.InverseFileSortOrder(obj.settings.FileSortOrder) = 1:numFiles;
    end
    obj.UpdateFileInfoBrowser();
    obj.UpdateFileInfoBrowserReadState();

end

function note = getNote(obj, filenum)
    % Get the note for the given file
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    note = obj.dbase.Notes{filenum};
end

function setNote(obj, note, filenum)
    % Set the note for the given file
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    obj.dbase.Notes{filenum} = note;
end

function numProperties = getNumProperties(obj)
    numProperties = length(obj.dbase.PropertyNames);
end

function [propertyArray, propertyNames] = getProperties(obj)
    % Get the all properties info
    propertyArray = obj.dbase.Properties;
    propertyNames = obj.dbase.PropertyNames;
end

function propertyExists = isProperty(obj, propertyName)
    % This was unfinished?
    propertyExists=[];
end

function modifyProperties(obj, filenums, propertyNames, propertyValues, updateGUI)
    % Update only a subset of the property
    if ~exist('updateGUI', 'var') || isempty(updateGUI)
        updateGUI = true;
    end

    if ~iscell(propertyNames)
        % If only one property name char array is passed in, convert to
        % cell array
        propertyNames = {propertyNames};
    end

    propertyIdx = cellfun(@(name)find(strcmp(name, obj.dbase.PropertyNames), 1), propertyNames);
    obj.dbase.Properties(filenums, propertyIdx) = propertyValues;
    if updateGUI
        obj.FileInfoBrowser.Data(filenums, 2 + propertyIdx) = propertyValues;
    end
end

function propertyValue = getPropertyValue(obj, propertyName, filenum)
    % Get the property value for the given property name and file(s)
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end

    propertyIdx = find(strcmp(propertyName, obj.dbase.PropertyNames), 1);
    if isempty(propertyIdx)
        error('Unknown property name: %s', propertyName);
    end
    propertyValue = obj.dbase.Properties(filenum, propertyIdx);
end

function setPropertyValue(obj, propertyName, propertyValue, filenum, updateGUI)
    % Set the property value for the given property name and file
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = electro_gui.getCurrentFileNum(obj.settings);
    end
    if ~exist('updateGUI', 'var') || isempty(updateGUI)
        updateGUI = true;
    end

    propertyIdx = find(strcmp(propertyName, obj.dbase.PropertyNames), 1);
    if isempty(propertyIdx)
        error('Unknown property name: %s', propertyName);
    end
    obj.dbase.Properties(filenum, propertyIdx) = propertyValue;
    if updateGUI
        obj.UpdateFileInfoBrowser();
    end
end

function addProperty(obj, propertyName, initialPropertyValue, updateGUI)
    % Add a new property
    if ~exist('updateGUI', 'var') || isempty(updateGUI)
        updateGUI = true;
    end

    [propertyArray, propertyNames] = obj.getProperties();
    numProperties = length(propertyNames);
    propertyArray(:, numProperties + 1) = initialPropertyValue;
    propertyNames{end+1} = propertyName;
    obj.dbase.Properties = propertyArray;
    obj.dbase.PropertyNames = propertyNames;
    if updateGUI
        obj.UpdateFileInfoBrowser();
    end
end

function removeProperty(obj, propertyName, updateGUI)
    % Remove a property
    if ~exist('updateGUI', 'var') || isempty(updateGUI)
        updateGUI = true;
    end

    propertyIdx = find(strcmp(char(propertyName), obj.dbase.PropertyNames), 1);
    if isempty(propertyIdx)
        error('Unknown property name: %s', propertyName);
    end
    obj.dbase.Properties(:, propertyIdx) = [];
    obj.dbase.PropertyNames(propertyIdx) = [];
    if updateGUI
        obj.UpdateFileInfoBrowser();
    end
end

function eg_RestartProperties(obj)
    obj.dbase.Properties = false(electro_gui.getNumFiles(obj.dbase), 0);
    obj.dbase.PropertyNames = {};
    obj.UpdateFileInfoBrowser();

end
function eg_AddProperty(obj,type)
    defaultName = getUniqueName('newProperty', obj.dbase.PropertyNames, 'PadLength', 0);
    input = getInputs('Add new property', {'Property name', 'Default value'}, {defaultName, false}, {'Name of property to add', 'Default value to fill each file''s property with'});
    if ~isempty(input)
        newProperty = input{1};
        newValue = input{2};
        if any(strcmp(newProperty, obj.dbase.PropertyNames))
            % Property name already exists
            warndlg(sprintf('Property name ''%s'' is already in use - please choose another.', newProperty), 'Property name already in use');
            return;
        end
        obj.addProperty(newProperty, newValue);
    end

end

function shiftDown = isShiftDown(obj)
    shiftDown = any(strcmp(obj.figure_Main.CurrentModifier, 'shift'));
end

function controlDown = isControlDown(obj)
    controlDown = any(strcmp(obj.figure_Main.CurrentModifier, 'control'));
end

function GUIPropertyChangeHandler(obj, varargin)
    % Update stored property values from GUI

    firstPropertyColumn = obj.FileInfoBrowserFirstPropertyColumn;
    if obj.isShiftDown() && ~isempty(obj.FileInfoBrowser.PreviousSelection)
        % User was holding shift down - set all values in that range

        changeIndices = event.Indices - [0, firstPropertyColumn - 1];

        selection = obj.FileInfoBrowser.Selection;
        if any(all(changeIndices == selection, 2))
            % Change was inside selection

            obj.dbase.Properties(unique(selection(:, 1)), changeIndices(2)) = event.NewData;
            obj.UpdateFileInfoBrowser();
        end
    end
    obj.dbase.Properties = cell2mat(obj.FileInfoBrowser.Data(:, firstPropertyColumn:end));

end

function fileNames = getFileNames(obj)
    fileNames = {obj.dbase.SoundFiles.name};
end

function setFileNames(obj, fileList)
    % Set the filenames in the the file browser
    if electro_gui.areFilesSorted(obj.settings)
        fileList = fileList(obj.settings.FileSortOrder);
    end
    obj.FileInfoBrowser.Data(:, 2) = electro_gui.getMinimalFilenmes(fileList);
end

function setFileReadState(obj, filenums, readState)
    % Set background color of the given filenums to indicate the given
    % read/unread state of the files.

    obj.SaveState();

    if readState
        color = obj.settings.FileReadColor;
    else
        color = obj.settings.FileUnreadColor;
    end

    % Check if we need to extend obj.settings.FileReadState
    maxFilenum = electro_gui.getNumFiles(obj.dbase);
    if maxFilenum > length(obj.settings.FileReadState)
        % Extend file read state list
        numToAdd = maxFilenum - length(obj.settings.FileReadState);
        obj.settings.FileReadState(end+1:end+numToAdd) = false;
    elseif maxFilenum < length(obj.settings.FileReadState)
        % Shorten file read state list
        obj.settings.FileReadState(maxFileNum+1:end) = [];
    end

    obj.settings.FileReadState(filenums) = readState;
    backgroundColors = repmat(color, length(filenums), 1);
%     if electro_gui.areFilesSorted(obj.settings)
%         filenums = obj.settings.FileSortOrder(filenums)
%     end
    obj.FileInfoBrowser.BackgroundColor(filenums, :) = backgroundColors;
end

function UpdateFileInfoBrowserReadState(obj)
    % Update background color of all filenames in FileInfoBrowser to match
    % the read/unread state of the file, as stored in obj.settings.FileReadState
    readColor = [1, 1, 1];
    unreadColor = [1, 0.8, 0.8];
    readFilenums = find(obj.settings.FileReadState);
    unreadFilenums = find(~obj.settings.FileReadState);
    if electro_gui.areFilesSorted(obj.settings)
        readFilenums = obj.settings.InverseFileSortOrder(readFilenums);
        unreadFilenums = obj.settings.InverseFileSortOrder(unreadFilenums);
    end
    backgroundColors = zeros(electro_gui.getNumFiles(obj.dbase), 3);
    backgroundColors(readFilenums, :) =    repmat(readColor,   length(readFilenums),   1);
    backgroundColors(unreadFilenums, :) =  repmat(unreadColor, length(unreadFilenums), 1);
    obj.FileInfoBrowser.BackgroundColor = backgroundColors;
end

function UpdateFileInfoBrowser(obj, updateValues, updateNames, update)
    % Initialize table data
    % Column 1 is filenames
    % Rest of the columns are properties
    data = cell(electro_gui.getNumFiles(obj.dbase), obj.getNumProperties() + 2);
    data(:, 1) = num2cell(1:electro_gui.getNumFiles(obj.dbase));
    data(:, 2) = electro_gui.getMinimalFilenmes({obj.dbase.SoundFiles.name});
    [propertyArray, propertyNames] = obj.getProperties();
    data(:, 3:end) = num2cell(propertyArray);
    if electro_gui.areFilesSorted(obj.settings)
        % Shuffle data
        data = data(obj.settings.FileSortOrder, :);
    end
    obj.FileInfoBrowser.Data = data;
    obj.FileInfoBrowser.ColumnName = [{'#', 'Name'}, propertyNames];
    obj.FileInfoBrowser.ColumnEditable = [false, false, true(1, length(propertyNames))];
    obj.FileInfoBrowser.ColumnWidth = num2cell([20, 135, repmat(30, 1, length(propertyNames))]);
    obj.FileInfoBrowser.ColumnSelectable = [true, true, false(1, length(propertyNames))];
    obj.FileInfoBrowser.ColumnFormat = [{'char', 'char'}, repmat({'logical'}, 1, length(propertyNames))];
end

function UpdateFiles(obj, old_sound_files)

    numFiles = electro_gui.getNumFiles(dbase);
    if numFiles == 0
        return
    end

    obj.dbase = electro_gui.InitializeDbase(numFiles, obj.dbase);

    obj.text_TotalFileNumber.String = sprintf('of %s', numFiles);
    if electro_gui.areFilesSorted(obj.settings)
        oldSelectedFilenum = obj.settings.FileSortOrder(obj.FileInfoBrowser.SelectedRow);
    else
        oldSelectedFilenum = obj.FileInfoBrowser.SelectedRow;
    end
    obj.edit_FileNumber.String = '1';
    obj.FileInfoBrowser.SelectedRow = 1;

%     originalValues = obj.getFileNames();

    % Generate translation lists to map old file index to new file index,
    % after some files have been added somewhere in the list
    oldnum = [];
    newnum = [];
    newSelectedFilenum = [];
    for oldIdx = 1:length(old_sound_files)
        for newIdx = 1:length(obj.dbase.SoundFiles)
            if strcmp(old_sound_files(oldIdx).name,obj.dbase.SoundFiles(newIdx).name)
                oldnum(end+1) = oldIdx;
                newnum(end+1) = newIdx;
                if oldIdx==oldSelectedFilenum
                    newSelectedFilenum = newIdx;
                end
            end
        end
    end

    fileList = {obj.dbase.SoundFiles.name};
    obj.setFileNames(fileList);
    if ~isempty(newSelectedFilenum)
        obj.edit_FileNumber.String = num2str(newSelectedFilenum);
        if electro_gui.areFilesSorted(obj.settings)
            obj.RefreshSortOrder();
            obj.FileInfoBrowser.SelectedRow = obj.settings.InverseFileSortOrder(newSelectedFilenum);
        else
            obj.FileInfoBrowser.SelectedRow = newSelectedFilenum;
        end
    end

    % Initialize variables for new files
    originalValues = obj.dbase.SegmentThresholds(oldnum);
    obj.dbase.SegmentThresholds = inf(1,numFiles);
    obj.dbase.SegmentThresholds(newnum) = originalValues;

    % Shouldn't we be setting the correct date for the new files??
    originalValues = obj.dbase.Times(oldnum);
    obj.dbase.Times = zeros(1,numFiles);
    obj.dbase.Times(newnum) = originalValues;

    originalValues = obj.dbase.SegmentTimes(oldnum);
    obj.dbase.SegmentTimes = cell(1,numFiles);
    obj.dbase.SegmentTimes(newnum) = originalValues;

    originalValues = obj.dbase.SegmentTitles(oldnum);
    obj.dbase.SegmentTitles = cell(1,numFiles);
    obj.dbase.SegmentTitles(newnum) = originalValues;

    originalValues = obj.dbase.SegmentIsSelected(oldnum);
    obj.dbase.SegmentIsSelected = cell(1,numFiles);
    obj.dbase.SegmentIsSelected(newnum) = originalValues;

    originalValues = obj.dbase.EventThresholds(:,oldnum);
    obj.dbase.EventThresholds = inf*ones(size(originalValues,1),numFiles);
    obj.dbase.EventThresholds(:,newnum) = originalValues;

    originalValues = obj.dbase.MarkerTimes(oldnum);
    obj.dbase.MarkerTimes = cell(1,numFiles);
    obj.dbase.MarkerTimes(newnum) = originalValues;

    originalValues = obj.dbase.MarkerTitles(oldnum);
    obj.dbase.MarkerTitles = cell(1,numFiles);
    obj.dbase.MarkerTitles(newnum) = originalValues;

    originalValues = obj.dbase.MarkerIsSelected(oldnum);
    obj.dbase.MarkerIsSelected = cell(1,numFiles);
    obj.dbase.MarkerIsSelected(newnum) = originalValues;


    originalValues = obj.dbase.EventTimes;
    for eventSourceIdx = 1:length(originalValues)
        obj.dbase.EventTimes{eventSourceIdx} = cell(size(originalValues{eventSourceIdx},1),numFiles);
        obj.dbase.EventTimes{eventSourceIdx}(:,newnum) = originalValues{eventSourceIdx}(:,oldnum);
    end

    originalValues = obj.dbase.EventIsSelected;
    for eventSourceIdx = 1:length(originalValues)
        obj.dbase.EventIsSelected{eventSourceIdx} = cell(size(originalValues{eventSourceIdx},1),numFiles);
        obj.dbase.EventIsSelected{eventSourceIdx}(:,newnum) = originalValues{eventSourceIdx}(:,oldnum);
    end

    originalProperties = obj.dbase.Properties;
    obj.dbase.Properties = false(numFiles, obj.getNumProperties());
    obj.dbase.Properties(:, newnum) = originalProperties;

    originalValues = obj.dbase.FileLength(:,oldnum);
    obj.dbase.FileLength = zeros(1,numFiles);
    obj.dbase.FileLength(newnum) = originalValues;


end

function [dbase, settings] = GetDBase(obj, includeDocumentation)
    arguments
        obj electro_gui
        includeDocumentation (1,1) logical = obj.settings.IncludeDocumentation
    end

    dbase = obj.dbase;
    if obj.settings.LegacyOptions.IncludeAnalysisState
        dbase.AnalysisState = obj.settings;
    end

    % Add any other custom fields from the original dbase that might exist to
    % the exported dbase
    if isfield(obj, 'OriginalDbase')
        originalFields = fieldnames(obj.OriginalDbase);
        for k = 1:length(originalFields)
            fieldName = originalFields{k};
            if ~isfield(dbase, fieldName)
                dbase.(fieldName) = obj.OriginalDbase.(fieldName);
            end
        end
    end

    if ~includeDocumentation && isfield(dbase, 'help')
        dbase = rmfield(dbase, 'help');
    end

    settings = obj.settings;
end

function eg_PopulateSoundSources(obj)

    % Set up list of sources for the sound axes
    sourceStrings = {'Sound'};
    for c = 1:length(obj.dbase.ChannelFiles)
        if ~isempty(obj.dbase.ChannelFiles{c})
            sourceStrings{end+1} = sprintf('Channel %d', c);
        end
    end
    sourceStrings{end+1} = 'Calculated';

    sourceIndices = num2cell(0:length(obj.dbase.ChannelFiles));
    sourceIndices{end+1} = 'calculated';

    obj.popup_SoundSource.String = sourceStrings;
    obj.popup_SoundSource.UserData = sourceIndices;

    delete(obj.menu_AuxiliarySoundSources.Children);
    for k = 1:length(sourceStrings)
        uimenu(obj.menu_AuxiliarySoundSources, 'Label', sourceStrings{k}, 'Callback', @obj.HandleAuxiliarySoundSourceClick);
    end
end

function setAuxiliarySoundSources(obj, auxiliarySoundSources, updateSonogram)
    % Set sound sources programmatically (this will update the checked menu
    % items in the relevant axes_Sonogram context submenu, and optionally
    % update the sonogram too.
    if ~exist('updateSonogram', 'var') || isempty(updateSonogram)
        updateSonogram = false;
    end
    menuItems = obj.menu_AuxiliarySoundSources.Children;
    for k = 1:length(menuItems)
        if any(strcmp(menuItems(k).Text, auxiliarySoundSources))
            menuItems(k).Checked = true;
        else
            menuItems(k).Checked = false;
        end
    end
    if updateSonogram
        obj.eg_PlotSonogram();
        obj.eg_Overlay();
    end
end

function auxiliarySoundSources = getAuxiliarySoundSources(obj)
    % Get a list of auxiliary sound source names from the checked values in the
    % Sonogram context submenu "Auxiliary sound sources"
    % Used to plot multiple sonograms
    sources = {obj.menu_AuxiliarySoundSources.Children.Text};
    selected = [obj.menu_AuxiliarySoundSources.Children.Checked];
    auxiliarySoundSources = sources(selected);
end

function updateFileNotes(obj)
    % Update FileNotes text box with currently stored note
    if ~electro_gui.isDataLoaded(obj.dbase)
        % No data yet, do nothing
        obj.edit_FileNotes.Enable = 'off';
        return;
    end

    obj.edit_FileNotes.Enable = 'on';
    filenum = electro_gui.getCurrentFileNum(obj.settings);
    obj.edit_FileNotes.String = obj.dbase.Notes{filenum};
end

function setupGUI(obj)
    obj.figure_Main = figure(...
            'PaperUnits',get(0,'defaultfigurePaperUnits'),...
            'Units','normalized',...
            'Position',[0.0244791666666667 0.0191666666666667 0.990625 0.891666666666667],...
            'Visible',get(0,'defaultfigureVisible'),...
            'Color',get(0,'defaultfigureColor'),...
            'CloseRequestFcn',get(0,'defaultfigureCloseRequestFcn'),...
            'CurrentAxesMode','manual',...
            'CurrentObjectMode','manual',...
            'CurrentPointMode','manual',...
            'SelectionTypeMode','manual',...
            'ResizeFcn',blanks(0),...
            'IntegerHandle','off',...
            'NextPlot',get(0,'defaultfigureNextPlot'),...
            'Alphamap',get(0,'defaultfigureAlphamap'),...
            'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
            'WindowButtonDownFcn',blanks(0),...
            'WindowButtonUpFcn',blanks(0),...
            'WindowButtonMotionFcn',blanks(0),...
            'WindowScrollWheelFcn',blanks(0),...
            'WindowKeyPressFcn',blanks(0),...
            'WindowKeyReleaseFcn',blanks(0),...
            'MenuBar','none',...
            'ToolBar','none',...
            'Pointer',get(0,'defaultfigurePointer'),...
            'PointerShapeHotSpot',get(0,'defaultfigurePointerShapeHotSpot'),...
            'Name','Electro Gui',...
            'NumberTitle','off',...
            'Icon',blanks(0),...
            'HandleVisibility','callback',...
            'ButtonDownFcn',blanks(0),...
            'DeleteFcn',blanks(0),...
            'Tag','figure_Main',...
            'UserData',[],...
            'WindowStyle',get(0,'defaultfigureWindowStyle'),...
            'DockControls',get(0,'defaultfigureDockControls'),...
            'Resize',get(0,'defaultfigureResize'),...
            'PaperPosition',get(0,'defaultfigurePaperPosition'),...
            'PaperSize',get(0,'defaultfigurePaperSize'),...
            'PaperType',get(0,'defaultfigurePaperType'),...
            'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
            'PaperOrientation',get(0,'defaultfigurePaperOrientation'),...
            'ScreenPixelsPerInchMode','manual',...
            'KeyPressFcn',blanks(0),...
            'KeyReleaseFcn',blanks(0));

    obj.axes_Sound = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.055052790346908 0.055052790346908],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[],...
        'XTickLabel',[],...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[],...
        'YTickLabel',[],...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.018 0.905294171840009 0.697 0.0681818181818182],...
        'InnerPosition',[0.018 0.905294171840009 0.697 0.0681818181818182],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142706766917293 0.435638766519824 0.104285714285714 0.297026431718062],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Tag','axes_Sound');

    set(obj.axes_Sound.Title,...
        'Parent',obj.axes_Sound,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.03424657534247 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sound.XLabel,...
        'Parent',obj.axes_Sound,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.0365296803652946 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sound.YLabel,...
        'Parent',obj.axes_Sound,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.00201106083459025 0.50000047683716 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sound.ZLabel,...
        'Parent',obj.axes_Sound,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    % obj.axes_Sonogram
    obj.axes_Sonogram = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.211915535444947 0.211915535444947],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.2 0.4 0.6 0.8 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.2'; '0.4'; '0.6'; '0.8'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.0177824267782427 0.64265668849392 0.697175732217573 0.262862488306829],...
        'InnerPosition',[0.0177824267782427 0.64265668849392 0.697175732217573 0.262862488306829],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142510460251046 0.332583892617449 0.104142259414226 0.226761744966443],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Tag','axes_Sonogram');

    set(obj.axes_Sonogram.Title,...
        'Parent',obj.axes_Sonogram,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.00889679715303 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sonogram.XLabel,...
        'Parent',obj.axes_Sonogram,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.104389088377268 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sonogram.YLabel,...
        'Parent',obj.axes_Sonogram,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0268979390941714 0.500000476837159 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Sonogram.ZLabel,...
        'Parent',obj.axes_Sonogram,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    obj.axes_Segments = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.0452488687782805 0.0452488687782805],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XColor',[0.831372549019608 0.815686274509804 0.784313725490196],...
        'XTick',[],...
        'XTickLabel',[],...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YColor',[0.831372549019608 0.815686274509804 0.784313725490196],...
        'YTick',[],...
        'YTickLabel',[],...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'ZTick',[],...
        'Color',[0.831372549019608 0.815686274509804 0.784313725490196],...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.018 0.525568181818182 0.697 0.0558712121212122],...
        'InnerPosition',[0.018 0.525568181818182 0.697 0.0558712121212122],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142510460251046 0.454633027522936 0.104142259414226 0.309977064220183],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Tag','axes_Segments');

    set(obj.axes_Segments.Title,...
        'Parent',obj.axes_Segments,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.04166666666667 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Segments.XLabel,...
        'Parent',obj.axes_Segments,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.831372549019608 0.815686274509804 0.784313725490196],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.0444444444444425 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Segments.YLabel,...
        'Parent',obj.axes_Segments,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.831372549019608 0.815686274509804 0.784313725490196],...
        'ColorMode','auto',...
        'Position',[-0.00201106083459025 0.500000476837158 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Segments.ZLabel,...
        'Parent',obj.axes_Segments,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    % obj.axes_Amplitude
    obj.axes_Amplitude = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.0806938159879336 0.0806938159879336],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.5 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.5'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.018 0.425189393939394 0.697 0.100378787878788],...
        'InnerPosition',[0.018 0.425189393939394 0.697 0.100378787878788],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142510460251046 0.384147286821705 0.104142259414226 0.261918604651163],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Tag','axes_Amplitude',...
        'UserData',[]);

    set(obj.axes_Amplitude.Title,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.02336448598131 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.XLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.183800626840918 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.YLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0175967826442901 0.500000476837158 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.ZLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    % obj.axes_Amplitude
    obj.axes_Channel1 = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.117647058823529 0.117647058823529],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.5 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.5'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.018 0.21780303030303 0.697 0.145833333333333],...
        'InnerPosition',[0.018 0.21780303030303 0.697 0.145833333333333],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142510460251046 0.33258389261745 0.104142259414226 0.226761744966443],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Visible','off',...
        'Tag','axes_Channel1');

    set(obj.axes_Channel1.Title,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.01602564102564 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.XLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.147970088373901 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.YLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0197335347990225 0.500000476837158 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Amplitude.ZLabel,...
        'Parent',obj.axes_Amplitude,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    obj.axes_Channel2 = axes(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.118401206636501 0.118401206636501],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.5 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.5'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.018 0.0123106060606061 0.697 0.146780303030303],...
        'InnerPosition',[0.018 0.0123106060606061 0.697 0.146780303030303],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.142510460251046 0.331471571906354 0.104142259414226 0.226003344481605],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Visible','off',...
        'Tag','axes_Channel2',...
        'UserData',[]);

    set(obj.axes_Channel2.Title,...
        'Parent',obj.axes_Channel2,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000502009557 1.01592356687898 0.5],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Channel2.XLabel,...
        'Parent',obj.axes_Channel2,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.147027603734577 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Channel2.YLabel,...
        'Parent',obj.axes_Channel2,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0197335347990225 0.500000476837158 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Channel2.ZLabel,...
        'Parent',obj.axes_Channel2,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    % obj.panel_files
    obj.panel_files = uipanel(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultuipanelFontUnits'),...
        'Units',get(0,'defaultuipanelUnits'),...
        'BorderType','beveledout',...
        'TitlePosition','centertop',...
        'Title','Files',...
        'Tag','panel_files',...
        'Clipping','off',...
        'Position',[0.72489539748954 0.609915809167446 0.269874476987448 0.378858746492049],...
        'Layout',[]);

    obj.edit_FileNumber = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','0',...
        'Style','edit',...
        'Position',[0.315175097276265 0.88563829787234 0.118677042801556 0.0771276595744681],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.edit_FileNumber_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','edit_FileNumber',...
        'FontSize',10);

    obj.text1 = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','File',...
        'Style','text',...
        'Position',[0.243190661478599 0.898936170212766 0.0622568093385214 0.0558510638297872],...
        'Children',[],...
        'Tag','text1',...
        'FontSize',10);

    obj.text_TotalFileNumber = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','of 0',...
        'Style','text',...
        'Position',[0.449416342412452 0.898936170212766 0.136186770428016 0.0558510638297872],...
        'Children',[],...
        'Tag','text_TotalFileNumber',...
        'FontSize',10);

    obj.push_PreviousFile = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','<<',...
        'Position',[0.0252918287937743 0.872340425531915 0.1 0.101063829787234],...
        'Callback',@obj.push_PreviousFile_Callback,...
        'Children',[],...
        'Tag','push_PreviousFile');

    obj.push_NextFile = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','>>',...
        'Position',[0.134241245136187 0.872340425531915 0.1 0.101063829787234],...
        'Callback',@obj.push_NextFile_Callback,...
        'Children',[],...
        'Tag','push_NextFile');

    obj.text26 = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','Sort order',...
        'Style','text',...
        'Position',[0.608949416342413 0.941489361702127 0.186770428015564 0.0558510638297872],...
        'Children',[],...
        'ButtonDownFcn',blanks(0),...
        'DeleteFcn',blanks(0),...
        'Tag','text26',...
        'FontSize',get(0,'defaultuicontrolFontSize'));

    obj.check_ReverseSort = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Reverse',...
        'Style','checkbox',...
        'Position',[0.846303501945526 0.888297872340425 0.14 0.0691489361702128],...
        'Callback',@obj.check_ReverseSort_Callback,...
        'Children',[],...
        'Tag','check_ReverseSort');

    obj.popup_FileSortOrder = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment',get(0,'defaultuicontrolHorizontalAlignment'),...
        'ListboxTop',get(0,'defaultuicontrolListboxTop'),...
        'Max',get(0,'defaultuicontrolMax'),...
        'Min',get(0,'defaultuicontrolMin'),...
        'SliderStep',get(0,'defaultuicontrolSliderStep'),...
        'String','File number',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.612840466926071 0.877659574468085 0.221789883268483 0.0771276595744681],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_FileSortOrder_Callback,...
        'Children',[],...
        'Tooltip',blanks(0),...
        'ForegroundColor',get(0,'defaultuicontrolForegroundColor'),...
        'Enable',get(0,'defaultuicontrolEnable'),...
        'Visible',get(0,'defaultuicontrolVisible'),...
        'HandleVisibility',get(0,'defaultuicontrolHandleVisibility'),...
        'ButtonDownFcn',blanks(0),...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'DeleteFcn',blanks(0),...
        'Tag','popup_FileSortOrder',...
        'UserData',[],...
        'KeyPressFcn',blanks(0),...
        'KeyReleaseFcn',blanks(0),...
        'FontSize',get(0,'defaultuicontrolFontSize'),...
        'FontName',get(0,'defaultuicontrolFontName'),...
        'FontAngle',get(0,'defaultuicontrolFontAngle'),...
        'FontWeight',get(0,'defaultuicontrolFontWeight'));

    obj.text_NotesLabel = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','characters',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','Notes',...
        'Style','text',...
        'Position',[1.71428571428571 1.47058823529412 6.71428571428571 1.05882352941176],...
        'Children',[],...
        'Tag','text_NotesLabel');

    obj.edit_FileNotes = uicontrol(...
        'Parent',obj.panel_files,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'Max',100,...
        'String',blanks(0),...
        'Style','edit',...
        'Position',[0.1042 0.030690537084399 0.8646 0.0895140664961636],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.edit_FileNotes_Callback,...
        'Children',[],...
        'Tooltip','Write notes about this file',...
        'Enable','off',...
        'TooltipString','Write notes about this file',...
        'TooltipStringMode',get(0,'defaultuicontrolTooltipStringMode'),...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','edit_FileNotes');

    obj.text_FileName = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','Path name',...
        'Style','text',...
        'Position',[0.0280957336108221 0.975369929415767 0.343912591050989 0.0198863636363636],...
        'Children',[],...
        'Tag','text_FileName',...
        'FontSize',10);

    obj.text_DateAndTime = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Date and Time',...
        'Style','text',...
        'Position',[0.371488033298647 0.975369929415767 0.343912591050988 0.0198863636363636],...
        'Children',[],...
        'Tag','text_DateAndTime',...
        'FontSize',10);

    obj.text5 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','sec',...
        'Style','text',...
        'Position',[0.279916753381894 0.59280303030303 0.0239334027055151 0.0170454545454546],...
        'Children',[],...
        'Tag','text5');

    obj.edit_Timescale = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','10',...
        'Style','edit',...
        'Position',[0.233610822060354 0.588068181818182 0.0390218522372529 0.0255681818181818],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.edit_Timescale_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','edit_Timescale',...
        'FontSize',10);

    obj.text6 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Time range',...
        'Style','text',...
        'Position',[0.196670135275754 0.59280303030303 0.0306971904266389 0.0170454545454546],...
        'Children',[],...
        'Tag','text6');

    obj.context_Sonogram = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Sonogram_Callback,...
        'Tag','context_Sonogram');

    obj.menu_AutoCalculate = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_AutoCalculate_Callback,...
        'Label','Auto calculate',...
        'Tag','menu_AutoCalculate');

    obj.menu_LongFiles = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_LongFiles_Callback,...
        'Label','Long files...',...
        'Tag','menu_LongFiles');

    obj.menu_AlgorithmList = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_AlgorithmList_Callback,...
        'Label','Algorithm',...
        'Tag','menu_AlgorithmList');

    obj.menu_SonogramParameters = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_SonogramParameters_Callback,...
        'Label','Sonogram parameters...',...
        'Tag','menu_SonogramParameters');

    obj.center_Timescale = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.center_Timescale_Callback,...
        'Label','Center timescale',...
        'Tag','center_Timescale');

    obj.menu_ColorScale = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Separator','on',...
        'Callback',@obj.menu_ColorScale_Callback,...
        'Label','Color scale...',...
        'Tag','menu_ColorScale');

    obj.menu_BackgroundColor = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_BackgroundColor_Callback,...
        'Label','Background color...',...
        'Tag','menu_BackgroundColor');

    obj.menu_Colormap = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_Colormap_Callback,...
        'Label','Colormap',...
        'Tag','menu_Colormap');

    obj.menu_FreqLimits = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Separator','on',...
        'Callback',@obj.menu_FreqLimits_Callback,...
        'Label','Frequency limits...',...
        'Tag','menu_FreqLimits');

    obj.menu_FrequencyZoom = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Callback',@obj.menu_FrequencyZoom_Callback,...
        'Label','Allow frequency zoom',...
        'Tag','menu_FrequencyZoom');

    obj.menu_AuxiliarySoundSources = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Separator','on',...
        'Callback',@obj.menu_AuxiliarySoundSources_Callback,...
        'Label','Auxiliary sound sources',...
        'Tag','menu_AuxiliarySoundSources');

    obj.menu_Overlay = uimenu(...
        'Parent',obj.context_Sonogram,...
        'Separator',get(0,'defaultuimenuSeparator'),...
        'Callback',@obj.menu_Overlay_Callback,...
        'Label','Overlay',...
        'Tag','menu_Overlay');

    obj.menu_OverlayTop = uimenu(...
        'Parent',obj.menu_Overlay,...
        'Callback',@obj.menu_OverlayTop_Callback,...
        'Label','Top',...
        'Tag','menu_OverlayTop');

    obj.menu_OverlayBottom = uimenu(...
        'Parent',obj.menu_Overlay,...
        'Callback',@obj.menu_OverlayBottom_Callback,...
        'Label','Bottom',...
        'Tag','menu_OverlayBottom');

    obj.push_Calculate = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Calculate',...
        'Position',[0.609261186264308 0.582386363636364 0.0499479708636836 0.0350378787878788],...
        'Callback',@obj.push_Calculate_Callback,...
        'Children',[],...
        'Tag','push_Calculate');

    % obj.context_Amplitude
    obj.context_Amplitude = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Amplitude_Callback,...
        'Tag','context_Amplitude');

    obj.menu_AutoThreshold = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_AutoThreshold_Callback,...
        'Label','Auto theshold',...
        'Tag','menu_AutoThreshold');

    obj.menu_SetThreshold = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_SetThreshold_Callback,...
        'Label','Set threshold...',...
        'Tag','menu_SetThreshold');

    obj.menu_SmoothingWindow = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Separator','on',...
        'Callback',@obj.menu_SmoothingWindow_Callback,...
        'Label','Smoothing window...',...
        'Tag','menu_SmoothingWindow');

    obj.menu_FilterList = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Label','Sound filter',...
        'Tag','menu_FilterList');

    obj.menu_FilterParameters = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_FilterParameters_Callback,...
        'Label','Filter parameters...',...
        'Tag','menu_FilterParameters');

    obj.menu_AmplitudeAxisRange = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Separator','on',...
        'Callback',@obj.menu_AmplitudeAxisRange_Callback,...
        'Label','Axis range...',...
        'Tag','menu_AmplitudeAxisRange');

    obj.menu_AmplitudeAutoRange = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_AmplitudeAutoRange_Callback,...
        'Label','Set auto range',...
        'Tag','menu_AmplitudeAutoRange');

    % obj.menu_AmplitudeColors
    obj.menu_AmplitudeColors = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_AmplitudeColors_Callback,...
        'Label','Colors...',...
        'Tag','menu_AmplitudeColors');

    obj.menu_AmplitudeColor = uimenu(...
        'Parent',obj.menu_AmplitudeColors,...
        'Callback',@obj.menu_AmplitudeColor_Callback,...
        'Label','Plot...',...
        'Tag','menu_AmplitudeColor');

    obj.menu_AmplitudeThresholdColor = uimenu(...
        'Parent',obj.menu_AmplitudeColors,...
        'Callback',@obj.menu_AmplitudeThresholdColor_Callback,...
        'Label','Threshold...',...
        'Tag','menu_AmplitudeThresholdColor');

    % obj.menu_AmplitudeSource
    obj.menu_AmplitudeSource = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Separator','on',...
        'Label','Source',...
        'Tag','menu_AmplitudeSource');

    obj.menu_SourceSoundAmplitude = uimenu(...
        'Parent',obj.menu_AmplitudeSource,...
        'Callback',@obj.menu_SourceSoundAmplitude_Callback,...
        'Label','Sound amplitude',...
        'Tag','menu_SourceSoundAmplitude');

    obj.menu_SourceTopPlot = uimenu(...
        'Parent',obj.menu_AmplitudeSource,...
        'Callback',@obj.menu_SourceTopPlot_Callback,...
        'Label','Top plot',...
        'Tag','menu_SourceTopPlot');

    obj.menu_SourceBottomPlot = uimenu(...
        'Parent',obj.menu_AmplitudeSource,...
        'Callback',@obj.menu_SourceBottomPlot_Callback,...
        'Label','Bottom plot',...
        'Tag','menu_SourceBottomPlot');

    obj.menu_DontPlot = uimenu(...
        'Parent',obj.context_Amplitude,...
        'Callback',@obj.menu_DontPlot_Callback,...
        'Label','Don''t plot',...
        'Tag','menu_DontPlot');

    obj.context_Segments = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Segments_Callback,...
        'Tag','context_Segments');

    obj.menu_Split = uimenu(...
        'Parent',obj.context_Segments,...
        'Callback',@obj.menu_Split_Callback,...
        'Label','Split...',...
        'Tag','menu_Split');

    obj.menu_Concatenate = uimenu(...
        'Parent',obj.context_Segments,...
        'Callback',@obj.menu_Concatenate_Callback,...
        'Label','Concatenate...',...
        'Tag','menu_Concatenate');

    obj.menu_DeleteAll = uimenu(...
        'Parent',obj.context_Segments,...
        'Separator','on',...
        'Callback',@obj.menu_DeleteAll_Callback,...
        'Label','Delete all',...
        'Tag','menu_DeleteAll');

    obj.menu_UndeleteAll = uimenu(...
        'Parent',obj.context_Segments,...
        'Callback',@obj.menu_UndeleteAll_Callback,...
        'Label','Undelete all',...
        'Tag','menu_UndeleteAll');

    obj.menu_AutoSegment = uimenu(...
        'Parent',obj.context_Segments,...
        'Separator','on',...
        'Callback',@obj.menu_AutoSegment_Callback,...
        'Label','Auto segment',...
        'Tag','menu_AutoSegment');

    obj.menu_SegmenterList = uimenu(...
        'Parent',obj.context_Segments,...
        'Callback',@obj.menu_SegmenterList_Callback,...
        'Label','Algorithm',...
        'Tag','menu_SegmenterList');

    obj.menu_SegmentParameters = uimenu(...
        'Parent',obj.context_Segments,...
        'Callback',@obj.menu_SegmentParameters_Callback,...
        'Label','Segmenter parameters...',...
        'Tag','menu_SegmentParameters');

    obj.push_Segment = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Segment',...
        'Position',[0.665452653485952 0.582386363636364 0.0499479708636836 0.0350378787878788],...
        'Callback',@obj.push_Segment_Callback,...
        'Children',[],...
        'Tag','push_Segment');

    obj.popup_Channel1 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(None)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.0738813735691988 0.373106060606061 0.168574401664932 0.0284090909090909],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_Channel1_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_Channel1');

    obj.popup_Channel2 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(None)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.0738813735691988 0.170454545454545 0.168574401664932 0.0255681818181818],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_Channel2_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_Channel2');

    obj.text8 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Source',...
        'Style','text',...
        'Position',[0.0280957336108221 0.376893939393939 0.0390218522372529 0.0208333333333333],...
        'Children',[],...
        'Tag','text8');

    obj.text9 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Source',...
        'Style','text',...
        'Position',[0.0280957336108221 0.172348484848485 0.0390218522372529 0.0208333333333333],...
        'Children',[],...
        'Tag','text9');

    obj.text10 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Function',...
        'Style','text',...
        'Position',[0.257023933402706 0.37594696969697 0.0463059313215401 0.0236742424242424],...
        'Children',[],...
        'Tag','text10');

    obj.popup_Function1 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(Raw)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.310093652445369 0.375 0.122788761706556 0.0255681818181818],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_Function1_Callback,...
        'Children',[],...
        'Enable','off',...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_Function1');

    obj.popup_Function2 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(Raw)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.310093652445369 0.170454545454545 0.122788761706556 0.0255681818181818],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_Function2_Callback,...
        'Children',[],...
        'Enable','off',...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_Function2');

    % obj.context_Channel1
    obj.context_Channel1 = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Channel1_Callback,...
        'Tag','context_Channel1');

    obj.menu_PeakDetect1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Callback',@obj.menu_PeakDetect1_Callback,...
        'Label','Peak detect',...
        'Tag','menu_PeakDetect1');

    % obj.menu_ChannelColors1
    obj.menu_ChannelColors1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Callback',@obj.menu_ChannelColors1_Callback,...
        'Label','Colors',...
        'Tag','menu_ChannelColors1');

    obj.menu_PlotColor1 = uimenu(...
        'Parent',obj.menu_ChannelColors1,...
        'Callback',@obj.menu_PlotColor1_Callback,...
        'Label','Plot...',...
        'Tag','menu_PlotColor1');

    obj.menu_ThresholdColor1 = uimenu(...
        'Parent',obj.menu_ChannelColors1,...
        'Callback',@obj.menu_ThresholdColor1_Callback,...
        'Label','Threshold...',...
        'Tag','menu_ThresholdColor1');

    obj.menu_LineWidth1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Callback',@obj.menu_LineWidth1_Callback,...
        'Label','Line width...',...
        'Tag','menu_LineWidth1');

    obj.menu_AllowYZoom1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Separator','on',...
        'Callback',@obj.menu_AllowYZoom1_Callback,...
        'Label','Allow y-zoom',...
        'Tag','menu_AllowYZoom1');

    obj.menu_AutoLimits1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Callback',@obj.menu_AutoLimits1_Callback,...
        'Label','Auto limits',...
        'Tag','menu_AutoLimits1');

    obj.menu_SetLimits1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Callback',@obj.menu_SetLimits1_Callback,...
        'Label','Set limits...',...
        'Tag','menu_SetLimits1');

    obj.menu_Events1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Enable','off',...
        'Separator','on',...
        'Callback',@obj.menu_Events1_Callback,...
        'Label','Events',...
        'Tag','menu_Events1');

    obj.menu_EventsDisplay1 = uimenu(...
        'Parent',obj.menu_Events1,...
        'Callback',@obj.menu_EventsDisplay1_Callback,...
        'Label','Display',...
        'Tag','menu_EventsDisplay1');

    obj.menu_EventAutoDetect1 = uimenu(...
        'Parent',obj.menu_Events1,...
        'Callback',@obj.menu_EventAutoDetect1_Callback,...
        'Label','Auto detect',...
        'Tag','menu_EventAutoDetect1');

    obj.menu_SelectionParameters1 = uimenu(...
        'Parent',obj.menu_Events1,...
        'Callback',@obj.menu_SelectionParameters1_Callback,...
        'Label','Selection parameters...',...
        'Tag','menu_SelectionParameters1');

    obj.menu_UpdateEventThresholdDisplay1 = uimenu(...
        'Parent',obj.menu_Events1,...
        'Callback',@obj.menu_UpdateEventThresholdDisplay1_Callback,...
        'Label','Set threshold...',...
        'Tag','menu_UpdateEventThresholdDisplay1');

    obj.menu_EventParams1 = uimenu(...
        'Parent',obj.menu_Events1,...
        'Callback',@obj.menu_EventParams1_Callback,...
        'Label','Event parameters...',...
        'Tag','menu_EventParams1');

    obj.menu_FunctionParams1 = uimenu(...
        'Parent',obj.context_Channel1,...
        'Separator','on',...
        'Callback',@obj.menu_FunctionParams1_Callback,...
        'Label','Function parameters...',...
        'Tag','menu_FunctionParams1');

    % obj.context_Channel2
    obj.context_Channel2 = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Channel2_Callback,...
        'Tag','context_Channel2');

    obj.menu_PeakDetect2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Callback',@obj.menu_PeakDetect2_Callback,...
        'Label','Peak detect',...
        'Tag','menu_PeakDetect2');

    obj.menu_ChannelColors2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Callback',@obj.menu_ChannelColors2_Callback,...
        'Label','Colors',...
        'Tag','menu_ChannelColors2');

    obj.menu_PlotColor2 = uimenu(...
        'Parent',obj.menu_ChannelColors2,...
        'Callback',@obj.menu_PlotColor2_Callback,...
        'Label','Plot...',...
        'Tag','menu_PlotColor2');

    obj.menu_ThresholdColor2 = uimenu(...
        'Parent',obj.menu_ChannelColors2,...
        'Callback',@obj.menu_ThresholdColor2_Callback,...
        'Label','Threshold...',...
        'Tag','menu_ThresholdColor2');

    obj.menu_LineWidth2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Callback',@obj.menu_LineWidth2_Callback,...
        'Label','Line width...',...
        'Tag','menu_LineWidth2');

    obj.menu_AllowYZoom2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Separator','on',...
        'Callback',@obj.menu_AllowYZoom2_Callback,...
        'Label','Allow y-zoom',...
        'Tag','menu_AllowYZoom2');

    obj.menu_AutoLimits2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Callback',@obj.menu_AutoLimits2_Callback,...
        'Label','Auto limits',...
        'Tag','menu_AutoLimits2');

    obj.menu_SetLimits2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Callback',@obj.menu_SetLimits2_Callback,...
        'Label','Set limits...',...
        'Tag','menu_SetLimits2');

    obj.menu_Events2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Enable','off',...
        'Separator','on',...
        'Callback',@obj.menu_Events2_Callback,...
        'Label','Events',...
        'Tag','menu_Events2');

    obj.menu_EventsDisplay2 = uimenu(...
        'Parent',obj.menu_Events2,...
        'Callback',@obj.menu_EventsDisplay2_Callback,...
        'Label','Display',...
        'Tag','menu_EventsDisplay2');

    obj.menu_EventAutoDetect2 = uimenu(...
        'Parent',obj.menu_Events2,...
        'Callback',@obj.menu_EventAutoDetect2_Callback,...
        'Label','Auto detect',...
        'Tag','menu_EventAutoDetect2');

    obj.menu_SelectionParameters2 = uimenu(...
        'Parent',obj.menu_Events2,...
        'Callback',@obj.menu_SelectionParameters2_Callback,...
        'Label','Selection parameters...',...
        'Tag','menu_SelectionParameters2');

    obj.menu_UpdateEventThresholdDisplay2 = uimenu(...
        'Parent',obj.menu_Events2,...
        'Callback',@obj.menu_UpdateEventThresholdDisplay2_Callback,...
        'Label','Set threshold...',...
        'Tag','menu_UpdateEventThresholdDisplay2');

    obj.menu_EventParams2 = uimenu(...
        'Parent',obj.menu_Events2,...
        'Callback',@obj.menu_EventParams2_Callback,...
        'Label','Event parameters...',...
        'Tag','menu_EventParams2');

    obj.menu_FunctionParams2 = uimenu(...
        'Parent',obj.context_Channel2,...
        'Separator','on',...
        'Callback',@obj.menu_FunctionParams2_Callback,...
        'Label','Function parameters...',...
        'Tag','menu_FunctionParams2');

    obj.text12 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Event detector',...
        'Style','text',...
        'Position',[0.45525494276795 0.376893939393939 0.0697190426638917 0.0208333333333333],...
        'Children',[],...
        'Tag','text12');

    obj.popup_EventDetector1 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(None)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.531737773152966 0.373106060606061 0.107700312174818 0.0274621212121212],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_EventDetector1_Callback,...
        'Children',[],...
        'Enable','off',...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_EventDetector1');

    obj.text14 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Event detector',...
        'Style','text',...
        'Position',[0.45525494276795 0.172348484848485 0.0697190426638917 0.0208333333333333],...
        'Children',[],...
        'Tag','text14');

    obj.popup_EventDetector2 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(None)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.531737773152966 0.169507575757576 0.107700312174818 0.0274621212121212],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_EventDetector2_Callback,...
        'Children',[],...
        'Enable','off',...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_EventDetector2');

    obj.push_Detect1 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Detect',...
        'Position',[0.654006243496358 0.370265151515152 0.0619146722164412 0.0340909090909091],...
        'Callback',@obj.push_Detect1_Callback,...
        'Children',[],...
        'Enable','off',...
        'Tag','push_Detect1');

    obj.push_Detect2 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Detect',...
        'Position',[0.654006243496358 0.165719696969697 0.0619146722164412 0.0340909090909091],...
        'Callback',@obj.push_Detect2_Callback,...
        'Children',[],...
        'Enable','off',...
        'Tag','push_Detect2');

    obj.text15 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Function',...
        'Style','text',...
        'Position',[0.257023933402706 0.171401515151515 0.0463059313215401 0.0236742424242424],...
        'Children',[],...
        'Tag','text15');

    obj.push_BrightnessUp = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','/\',...
        'Position',[0.569719042663892 0.582386363636364 0.0312174817898023 0.0350378787878788],...
        'Callback',@obj.push_BrightnessUp_Callback,...
        'Children',[],...
        'Tag','push_BrightnessUp');

    obj.push_BrightnessDown = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','\/',...
        'Position',[0.531217481789802 0.582386363636364 0.0312174817898023 0.0350378787878788],...
        'Callback',@obj.push_BrightnessDown_Callback,...
        'Children',[],...
        'Tag','push_BrightnessDown',...
        'UserData',[]);

    obj.text17 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Brightness',...
        'Style','text',...
        'Position',[0.488553590010406 0.59375 0.036420395421436 0.0160984848484849],...
        'Children',[],...
        'Tag','text17');

    obj.push_OffsetUp = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','/\',...
        'Position',[0.451612903225806 0.582386363636364 0.0312174817898023 0.0350378787878788],...
        'Callback',@obj.push_OffsetUp_Callback,...
        'Children',[],...
        'Tag','push_OffsetUp');

    obj.push_OffsetDown = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','\/',...
        'Position',[0.413111342351717 0.582386363636364 0.0312174817898023 0.0350378787878788],...
        'Callback',@obj.push_OffsetDown_Callback,...
        'Children',[],...
        'Tag','push_OffsetDown',...
        'UserData',[]);

    obj.text18 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Offset',...
        'Style','text',...
        'Position',[0.384495317377732 0.59280303030303 0.022372528616025 0.0170454545454546],...
        'Children',[],...
        'Tag','text18');

    obj.panel_Events = uipanel(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultuipanelFontUnits'),...
        'Units',get(0,'defaultuipanelUnits'),...
        'BorderType','beveledout',...
        'TitlePosition','centertop',...
        'Title','Event viewer',...
        'Tag','uipanel3',...
        'Clipping','off',...
        'Position',[0.72489539748954 0.187090739008419 0.269874476987448 0.417212347988774],...
        'Layout',[]);

    obj.axes_Events = axes(...
        'Parent',obj.panel_Events,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.758771929824561 0.758771929824561],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.2 0.4 0.6 0.8 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.2'; '0.4'; '0.6'; '0.8'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.2 0.4 0.6 0.8 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.2'; '0.4'; '0.6'; '0.8'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.0616740088105727 0.0634920634920635 0.894273127753304 0.777777777777778],...
        'InnerPosition',[0.0616740088105727 0.0634920634920635 0.894273127753304 0.777777777777778],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.126474576271186 0.128669724770642 0.0924237288135594 0.0877293577981652],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Visible','off',...
        'Tag','axes_Events');

    set(obj.axes_Events.Title,...
        'Parent',obj.axes_Events,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000545853063 1.00722543352601 0.500000000000007],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Events.XLabel,...
        'Parent',obj.axes_Events,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.0847784214855849 7.105427357601e-15],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Events.YLabel,...
        'Parent',obj.axes_Events,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0782163755238405 0.500000476837158 7.105427357601e-15],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Events.ZLabel,...
        'Parent',obj.axes_Events,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    obj.text24 = uicontrol(...
        'Parent',obj.panel_Events,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','Alignment source:',...
        'Style','text',...
        'Position',[0.026431718061674 0.954554726843883 0.233480176211454 0.0476190476190477],...
        'Children',[],...
        'Tag','text24');

    obj.text25 = uicontrol(...
        'Parent',obj.panel_Events,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','left',...
        'String','Waveform source:',...
        'Style','text',...
        'Position',[0.621145374449339 0.954554726843883 0.233480176211454 0.0476190476190477],...
        'Children',[],...
        'ButtonDownFcn',blanks(0),...
        'DeleteFcn',blanks(0),...
        'Tag','text25');

    obj.popup_EventListAlign = uicontrol(...
        'Parent',obj.panel_Events,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','(None)',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.0291828793774319 0.898148148148148 0.552529182879378 0.0555555555555556],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_EventListAlign_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_EventListAlign');

    obj.popup_EventListData = uicontrol(...
        'Parent',obj.panel_Events,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String',{  '<< Source'; 'Top axes'; 'Bottom axes' },...
        'Style','popupmenu',...
        'Value',1,...
        'ValueMode',get(0,'defaultuicontrolValueMode'),...
        'Position',[0.626459143968872 0.898795180722892 0.319066147859922 0.0578313253012048],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_EventListData_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_EventListData');

    % obj.context_EventViewer
    obj.context_EventViewer = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_EventViewer_Callback,...
        'Tag','context_EventViewer');

    % obj.menu_ViewerDisplay
    obj.menu_ViewerDisplay = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Callback',@obj.menu_ViewerDisplay_Callback,...
        'Label','Display',...
        'Tag','menu_ViewerDisplay');

    obj.menu_DisplayValues = uimenu(...
        'Parent',obj.menu_ViewerDisplay,...
        'Callback',@obj.menu_DisplayValues_Callback,...
        'Label','Values',...
        'Tag','menu_DisplayValues');

    obj.menu_DisplayFeatures = uimenu(...
        'Parent',obj.menu_ViewerDisplay,...
        'Callback',@obj.menu_DisplayFeatures_Callback,...
        'Label','Features',...
        'Tag','menu_DisplayFeatures');

    obj.menu_XAxis = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Enable','off',...
        'Separator','on',...
        'Callback',@obj.menu_XAxis_Callback,...
        'Label','X-axis',...
        'Tag','menu_XAxis');

    obj.menu_YAxis = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Enable','off',...
        'Callback',@obj.menu_YAxis_Callback,...
        'Label','Y-axis',...
        'Tag','menu_YAxis');

    obj.menu_AutoDisplayEvents = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Separator','on',...
        'Callback',@obj.menu_AutoDisplayEvents_Callback,...
        'Checked','on',...
        'Label','Auto display',...
        'Tag','menu_AutoDisplayEvents');

    obj.menu_AutoApplyYLim = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Callback',@obj.menu_AutoApplyYLim_Callback,...
        'Checked','on',...
        'Label','Auto apply Y limits',...
        'Tag','menu_AutoApplyYLim');

    obj.menu_EventsAxisLimits = uimenu(...
        'Parent',obj.context_EventViewer,...
        'Callback',@obj.menu_EventsAxisLimits_Callback,...
        'Label','Set limits...',...
        'Tag','menu_EventsAxisLimits');

    obj.panel_Worksheet = uipanel(...
        'Parent',obj.figure_Main,...
        'FontUnits',get(0,'defaultuipanelFontUnits'),...
        'Units',get(0,'defaultuipanelUnits'),...
        'BorderType','beveledout',...
        'TitlePosition','centertop',...
        'Title','Worksheet: Page 1/1',...
        'Tag','panel_Worksheet',...
        'Clipping','off',...
        'Position',[0.725 0.0112254443405051 0.27 0.165575304022451],...
        'Layout',[]);

    obj.axes_Worksheet = axes(...
        'Parent',obj.panel_Worksheet,...
        'FontUnits',get(0,'defaultaxesFontUnits'),...
        'Units',get(0,'defaultaxesUnits'),...
        'CameraPosition',[0.5 0.5 9.16025403784439],...
        'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
        'CameraTarget',[0.5 0.5 0.5],...
        'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
        'CameraViewAngle',6.60861036031192,...
        'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
        'PlotBoxAspectRatio',[1 0.466867469879518 0.466867469879518],...
        'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
        'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
        'ColormapMode',get(0,'defaultaxesColormapMode'),...
        'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
        'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
        'XTick',[0 0.2 0.4 0.6 0.8 1],...
        'XTickMode',get(0,'defaultaxesXTickMode'),...
        'XTickLabel',{  '0'; '0.2'; '0.4'; '0.6'; '0.8'; '1' },...
        'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
        'YTick',[0 0.5 1],...
        'YTickMode',get(0,'defaultaxesYTickMode'),...
        'YTickLabel',{  '0'; '0.5'; '1' },...
        'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
        'Color',get(0,'defaultaxesColor'),...
        'CameraMode',get(0,'defaultaxesCameraMode'),...
        'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
        'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
        'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
        'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
        'BoxFrame',[],...
        'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
        'XRulerMode',get(0,'defaultaxesXRulerMode'),...
        'YRulerMode',get(0,'defaultaxesYRulerMode'),...
        'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
        'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
        'Position',[0.029126213592233 0.0661764705882361 0.650485436893204 0.889705882352941],...
        'InnerPosition',[0.029126213592233 0.0661764705882361 0.650485436893204 0.889705882352941],...
        'ActivePositionProperty','position',...
        'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
        'PositionConstraint','innerposition',...
        'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
        'LooseInset',[0.148777777777778 0.101081081081081 0.108722222222222 0.0689189189189189],...
        'ColorOrder',get(0,'defaultaxesColorOrder'),...
        'SortMethod','childorder',...
        'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
        'Tag','axes_Worksheet');

    set(obj.axes_Worksheet.Title,...
        'Parent',obj.axes_Worksheet,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0 0 0],...
        'ColorMode','auto',...
        'Position',[0.500000522797366 1.01612903225806 0.500000000000007],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','Axes Title',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Worksheet.XLabel,...
        'Parent',obj.axes_Worksheet,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0.500000476837158 -0.148924734105346 7.105427357601e-15],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','top',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Worksheet.YLabel,...
        'Parent',obj.axes_Worksheet,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[-0.0788152624804332 0.500000476837158 7.105427357601e-15],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',90,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','bottom',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','back',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','on',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    set(obj.axes_Worksheet.ZLabel,...
        'Parent',obj.axes_Worksheet,...
        'Units','data',...
        'FontUnits','points',...
        'DecorationContainer',[],...
        'DecorationContainerMode','auto',...
        'Color',[0.15 0.15 0.15],...
        'ColorMode','auto',...
        'Position',[0 0 0],...
        'PositionMode','auto',...
        'String',blanks(0),...
        'Interpreter','tex',...
        'Rotation',0,...
        'RotationMode','auto',...
        'FontName','Helvetica',...
        'FontSize',10,...
        'FontAngle','normal',...
        'FontWeight','normal',...
        'HorizontalAlignment','center',...
        'HorizontalAlignmentMode','auto',...
        'VerticalAlignment','middle',...
        'VerticalAlignmentMode','auto',...
        'EdgeColor','none',...
        'LineStyle','-',...
        'LineWidth',0.5,...
        'BackgroundColor','none',...
        'Margin',2,...
        'Clipping','off',...
        'Layer','middle',...
        'LayerMode','auto',...
        'FontSmoothing','on',...
        'FontSmoothingMode','auto',...
        'DisplayName',blanks(0),...
        'IncludeRenderer','on',...
        'IsContainer','off',...
        'IsContainerMode','auto',...
        'DimensionNames',{  'X' 'Y' 'Z' },...
        'DimensionNamesMode','auto',...
        'XLimInclude','on',...
        'YLimInclude','on',...
        'ZLimInclude','on',...
        'CLimInclude','on',...
        'ALimInclude','on',...
        'Description','AxisRulerBase Label',...
        'DescriptionMode','auto',...
        'Visible','off',...
        'Serializable','on',...
        'HandleVisibility','off',...
        'TransformForPrintFcnImplicitInvoke','on',...
        'TransformForPrintFcnImplicitInvokeMode','auto',...
        'HelpTopicKey',blanks(0),...
        'ButtonDownFcn',blanks(0),...
        'BusyAction','queue',...
        'Interruptible','on',...
        'DeleteFcn',blanks(0),...
        'Tag',blanks(0),...
        'HitTest','on',...
        'PickableParts','visible',...
        'PickablePartsMode','auto');

    obj.push_WorksheetAppend = uicontrol(...
        'Parent',obj.panel_Worksheet,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Append',...
        'Position',[0.70873786407767 0.727941176470589 0.262135922330097 0.227941176470588],...
        'Callback',@obj.push_WorksheetAppend_Callback,...
        'Children',[],...
        'Tag','push_WorksheetAppend');

    obj.push_WorksheetOptions = uicontrol(...
        'Parent',obj.panel_Worksheet,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Options...',...
        'Position',[0.70873786407767 0.433823529411765 0.262135922330097 0.227941176470588],...
        'Callback',@obj.push_WorksheetOptions_Callback,...
        'Children',[],...
        'Tag','push_WorksheetOptions');

    obj.push_PageLeft = uicontrol(...
        'Parent',obj.panel_Worksheet,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','<<',...
        'Position',[0.70873786407767 0.0661764705882359 0.121359223300971 0.227941176470588],...
        'Callback',@obj.push_PageLeft_Callback,...
        'Children',[],...
        'Tag','push_PageLeft',...
        'UserData',[]);

    obj.push_PageRight = uicontrol(...
        'Parent',obj.panel_Worksheet,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','>>',...
        'Position',[0.84789644012945 0.0661764705882359 0.122977346278317 0.227941176470588],...
        'Callback',@obj.push_PageRight_Callback,...
        'Children',[],...
        'Tag','push_PageRight');

    obj.context_Worksheet = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_Worksheet_Callback,...
        'Tag','context_Worksheet');

    obj.menu_WorksheetView = uimenu(...
        'Parent',obj.context_Worksheet,...
        'Callback',@obj.menu_WorksheetView_Callback,...
        'Label','View',...
        'Tag','menu_WorksheetView');

    obj.menu_WorksheetDelete = uimenu(...
        'Parent',obj.context_Worksheet,...
        'Callback',@obj.menu_WorksheetDelete_Callback,...
        'Label','Delete',...
        'Tag','menu_WorksheetDelete');

    % obj.context_WorksheetOptions
    obj.context_WorksheetOptions = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_WorksheetOptions_Callback,...
        'Tag','context_WorksheetOptions');

    obj.menu_SortChronologically = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Callback',@obj.menu_SortChronologically_Callback,...
        'Label','Sort chronologically',...
        'Tag','menu_SortChronologically');

    obj.menu_OnePerLine = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Callback',@obj.menu_OnePerLine_Callback,...
        'Label','One per line',...
        'Tag','menu_OnePerLine');

    obj.menu_IncludeTitle = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Separator','on',...
        'Callback',@obj.menu_IncludeTitle_Callback,...
        'Label','Include title',...
        'Tag','menu_IncludeTitle');

    obj.menu_EditTitle = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Callback',@obj.menu_EditTitle_Callback,...
        'Label','Edit title...',...
        'Tag','menu_EditTitle');

    obj.menu_WorksheetDimensions = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Separator','on',...
        'Callback',@obj.menu_WorksheetDimensions_Callback,...
        'Label','Dimensions...',...
        'Tag','menu_WorksheetDimensions');

    obj.menu_Orientation = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Callback',@obj.menu_Orientation_Callback,...
        'Label','Orientation',...
        'Tag','menu_Orientation');

    obj.menu_Portrait = uimenu(...
        'Parent',obj.menu_Orientation,...
        'Callback',@obj.menu_Portrait_Callback,...
        'Label','Portrait',...
        'Tag','menu_Portrait');

    obj.menu_Landscape = uimenu(...
        'Parent',obj.menu_Orientation,...
        'Callback',@obj.menu_Landscape_Callback,...
        'Label','Landscape',...
        'Tag','menu_Landscape');

    obj.menu_ClearWorksheet = uimenu(...
        'Parent',obj.context_WorksheetOptions,...
        'Separator','on',...
        'Callback',@obj.menu_ClearWorksheet_Callback,...
        'Label','Clear worksheet',...
        'Tag','menu_ClearWorksheet');

    obj.popup_SoundSource = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'String','Sound',...
        'Style','popupmenu',...
        'Value',1,...
        'Position',[0.0759625390218522 0.59375 0.111342351716961 0.0189393939393939],...
        'BackgroundColor',[1 1 1],...
        'Callback',@obj.popup_SoundSource_Callback,...
        'Children',[],...
        'CreateFcn',@electro_gui.GenericCreateFcn,...
        'Tag','popup_SoundSource');

    obj.text23 = uicontrol(...
        'Parent',obj.figure_Main,...
        'Units','normalized',...
        'FontUnits',get(0,'defaultuicontrolFontUnits'),...
        'HorizontalAlignment','right',...
        'String','Sound source',...
        'Style','text',...
        'Position',[0.0254942767950052 0.589015151515151 0.0463059313215401 0.0208333333333334],...
        'Children',[],...
        'Tag','text23');

    % obj.context_EventListAlign
    obj.context_EventListAlign = uicontextmenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.context_EventListAlign_Callback,...
        'Tag','context_EventListAlign');

    obj.EventViewerSourceToTopAxes = uimenu(...
        'Parent',obj.context_EventListAlign,...
        'Callback',@obj.EventViewerSourceToTopAxes_Callback,...
        'Label','View in top axes',...
        'Tag','EventViewerSourceToTopAxes');

    obj.EventViewerSourceToBottomAxes = uimenu(...
        'Parent',obj.context_EventListAlign,...
        'Callback',@obj.EventViewerSourceToBottomAxes_Callback,...
        'Label','View in bottom axes',...
        'Tag','EventViewerSourceToBottomAxes');

    % obj.menu_File
    obj.menu_File = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_File_Callback,...
        'Label','File',...
        'Tag','menu_File');

    obj.file_New = uimenu(...
        'Parent',obj.menu_File,...
        'Callback',@obj.file_New_Callback,...
        'Label','New...',...
        'Tag','file_New');

    obj.file_Open = uimenu(...
        'Parent',obj.menu_File,...
        'Callback',@obj.file_Open_Callback,...
        'Label','Open...',...
        'Tag','file_Open');

    % obj.menu_OpenRecent
    obj.menu_OpenRecent = uimenu(...
        'Parent',obj.menu_File,...
        'Callback',@obj.menu_OpenRecent_Callback,...
        'Label','Open recent',...
        'Tag','menu_OpenRecent');

    obj.openRecent_None = uimenu(...
        'Parent',obj.menu_OpenRecent,...
        'Enable','off',...
        'Callback',@obj.openRecent_None_Callback,...
        'Label','<None>',...
        'Tag','openRecent_None');

    obj.file_Save = uimenu(...
        'Parent',obj.menu_File,...
        'Callback',@obj.file_Save_Callback,...
        'Label','Save...',...
        'Tag','file_Save');

    % obj.menu_AlterFileList
    obj.menu_AlterFileList = uimenu(...
        'Parent',obj.menu_File,...
        'Callback',@obj.menu_AlterFileList_Callback,...
        'Label','File List',...
        'Tag','menu_AlterFileList');

    obj.menu_ChangeFiles = uimenu(...
        'Parent',obj.menu_AlterFileList,...
        'Separator',get(0,'defaultuimenuSeparator'),...
        'Callback',@obj.menu_ChangeFiles_Callback,...
        'Label','Change files...',...
        'Tag','menu_ChangeFiles');

    obj.menu_DeleteFiles = uimenu(...
        'Parent',obj.menu_AlterFileList,...
        'Callback',@obj.menu_DeleteFiles_Callback,...
        'Label','Delete files...',...
        'Tag','menu_DeleteFiles');

    % obj.menu_Playback
    obj.menu_Playback = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_Playback_Callback,...
        'Label','Playback',...
        'Tag','menu_Playback');

    obj.menu_PlaySound = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.menu_PlaySound_Callback,...
        'Label','Play sound',...
        'Tag','menu_PlaySound');

    obj.menu_PlayMix = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.menu_PlayMix_Callback,...
        'Label','Play mix',...
        'Tag','menu_PlayMix');

    obj.playback_SoundInMix = uimenu(...
        'Parent',obj.menu_Playback,...
        'Separator','on',...
        'Callback',@obj.playback_SoundInMix_Callback,...
        'Label','Mix sound',...
        'Tag','playback_SoundInMix');

    obj.playback_TopInMix = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_TopInMix_Callback,...
        'Label','Mix top plot',...
        'Tag','playback_TopInMix');

    obj.playback_BottomInMix = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_BottomInMix_Callback,...
        'Label','Mix bottom plot',...
        'Tag','playback_BottomInMix');

    obj.playback_Weights = uimenu(...
        'Parent',obj.menu_Playback,...
        'Separator','on',...
        'Callback',@obj.playback_Weights_Callback,...
        'Label','Weights...',...
        'Tag','playback_Weights');

    obj.playback_Clippers = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_Clippers_Callback,...
        'Label','Clippers...',...
        'Tag','playback_Clippers');

    obj.playback_Speed = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_Speed_Callback,...
        'Label','Speed...',...
        'Tag','playback_Speed');

    obj.playback_Reverse = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_Reverse_Callback,...
        'Label','Reverse',...
        'Tag','playback_Reverse');

    obj.playback_FilteredSound = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_FilteredSound_Callback,...
        'Label','Filtered sound',...
        'Tag','playback_FilteredSound');

    obj.menu_Animation = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.menu_Animation_Callback,...
        'Label','Animation',...
        'Tag','menu_Animation');

    obj.playback_animation_SoundWave = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_SoundWave_Callback,...
        'Label','Sound Wave',...
        'Tag','playback_animation_SoundWave');

    obj.playback_animation_Sonogram = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_Sonogram_Callback,...
        'Label','Sonogram',...
        'Tag','playback_animation_Sonogram');

    obj.playback_animation_Segments = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_Segments_Callback,...
        'Label','Segments',...
        'Tag','playback_animation_Segments');

    obj.playback_animation_SoundAmplitude = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_SoundAmplitude_Callback,...
        'Label','Sound amplitude',...
        'Tag','playback_animation_SoundAmplitude');

    obj.playback_animation_TopPlot = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_TopPlot_Callback,...
        'Label','Top Plot',...
        'Tag','playback_animation_TopPlot');

    obj.playback_animation_BottomPlot = uimenu(...
        'Parent',obj.menu_Animation,...
        'Callback',@obj.playback_animation_BottomPlot_Callback,...
        'Label','Bottom Plot',...
        'Tag','playback_animation_BottomPlot');

    obj.playback_ProgressBarColor = uimenu(...
        'Parent',obj.menu_Playback,...
        'Callback',@obj.playback_ProgressBarColor_Callback,...
        'Label','Animation pointer color...',...
        'Tag','playback_ProgressBarColor');

    obj.menu_Properties = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_Properties_Callback,...
        'Label','Properties',...
        'Tag','menu_Properties');

    obj.menu_AddProperty = uimenu(...
        'Parent',obj.menu_Properties,...
        'Callback',@obj.menu_AddProperty_Callback,...
        'Label','Add...',...
        'Tag','menu_AddProperty');

    obj.menu_RemoveProperty = uimenu(...
        'Parent',obj.menu_Properties,...
        'Callback',@obj.menu_RemoveProperty_Callback,...
        'Label','Remove...',...
        'Tag','menu_RemoveProperty');

    obj.menu_RenameProperty = uimenu(...
        'Parent',obj.menu_Properties,...
        'Callback',@obj.menu_RenameProperty_Callback,...
        'Label','Rename...',...
        'Tag','menu_RenameProperty');

    obj.menu_FillProperty = uimenu(...
        'Parent',obj.menu_Properties,...
        'Callback',@obj.menu_FillProperty_Callback,...
        'Label','Fill with value...',...
        'Tag','menu_FillProperty');

    obj.menu_Search = uimenu(...
        'Parent',obj.menu_Properties,...
        'Callback',@obj.menu_Search_Callback,...
        'Label','Search',...
        'Tag','menu_Search');

    obj.menu_SearchNew = uimenu(...
        'Parent',obj.menu_Search,...
        'Callback',@obj.menu_SearchNew_Callback,...
        'Label','New...',...
        'Tag','menu_SearchNew');

    obj.menu_SearchAnd = uimenu(...
        'Parent',obj.menu_Search,...
        'Callback',@obj.menu_SearchAnd_Callback,...
        'Label','AND...',...
        'Tag','menu_SearchAnd');

    obj.menu_SearchOr = uimenu(...
        'Parent',obj.menu_Search,...
        'Callback',@obj.menu_SearchOr_Callback,...
        'Label','OR...',...
        'Tag','menu_SearchOr');

    obj.menu_SearchNot = uimenu(...
        'Parent',obj.menu_Search,...
        'Callback',@obj.menu_SearchNot_Callback,...
        'Label','NOT current',...
        'Tag','menu_SearchNot');

    % obj.menu_Export
    obj.menu_Export = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_Export_Callback,...
        'Label','Export',...
        'Tag','menu_Export');

    obj.action_Export = uimenu(...
        'Parent',obj.menu_Export,...
        'Callback',@obj.action_Export_Callback,...
        'Label','Export',...
        'Tag','action_Export');

    % obj.menu_ExportAs
    obj.menu_ExportAs = uimenu(...
        'Parent',obj.menu_Export,...
        'Callback',@obj.menu_ExportAs_Callback,...
        'Label','Export as',...
        'Tag','menu_ExportAs');

    obj.export_asSonogram = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Separator','on',...
        'Callback',@obj.export_asSonogram_Callback,...
        'Checked','on',...
        'Label','Sonogram',...
        'Tag','export_asSonogram');

    obj.export_asFigure = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Callback',@obj.export_asFigure_Callback,...
        'Label','Figure',...
        'Tag','export_asFigure');

    obj.export_asWorksheet = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Callback',@obj.export_asWorksheet_Callback,...
        'Label','Worksheet',...
        'Tag','export_asWorksheet');

    obj.export_asCurrentSound = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Callback',@obj.export_asCurrentSound_Callback,...
        'Label','Current sound',...
        'Tag','export_asCurrentSound');

    obj.export_asSoundMix = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Callback',@obj.export_asSoundMix_Callback,...
        'Label','Sound mix',...
        'Tag','export_asSoundMix');

    obj.export_asEvents = uimenu(...
        'Parent',obj.menu_ExportAs,...
        'Callback',@obj.export_asEvents_Callback,...
        'Label','Events',...
        'Tag','export_asEvents');

    % obj.menu_ExportTo
    obj.menu_ExportTo = uimenu(...
        'Parent',obj.menu_Export,...
        'Separator','on',...
        'Callback',@obj.menu_ExportTo_Callback,...
        'Label','Export to',...
        'Tag','menu_ExportTo');

    obj.export_toMATLAB = uimenu(...
        'Parent',obj.menu_ExportTo,...
        'Callback',@obj.export_toMATLAB_Callback,...
        'Checked','on',...
        'Label','MATLAB',...
        'Tag','export_toMATLAB');

    obj.export_toPowerPoint = uimenu(...
        'Parent',obj.menu_ExportTo,...
        'Callback',@obj.export_toPowerPoint_Callback,...
        'Label','PowerPoint',...
        'Tag','export_toPowerPoint');

    obj.export_toFile = uimenu(...
        'Parent',obj.menu_ExportTo,...
        'Callback',@obj.export_toFile_Callback,...
        'Label','File',...
        'Tag','export_toFile');

    obj.export_toClipboard = uimenu(...
        'Parent',obj.menu_ExportTo,...
        'Callback',@obj.export_toClipboard_Callback,...
        'Label','Clipboard',...
        'Tag','export_toClipboard');

    obj.export_Options = uimenu(...
        'Parent',obj.menu_Export,...
        'Callback',@obj.export_Options_Callback,...
        'Label','Options',...
        'Tag','export_Options');

    obj.export_options_SonogramHeight = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.export_options_SonogramHeight_Callback,...
        'Label','Sonogram height...',...
        'Tag','export_options_SonogramHeight');

    obj.export_options_ImageTimescape = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.export_options_ImageTimescape_Callback,...
        'Label','Image timescale...',...
        'Tag','export_options_ImageTimescape');

    obj.export_options_IncludeTimestamp = uimenu(...
        'Parent',obj.export_Options,...
        'Separator','on',...
        'Callback',@obj.export_options_IncludeTimestamp_Callback,...
        'Label','Include timestamp',...
        'Tag','export_options_IncludeTimestamp');

    obj.menu_export_options_IncludeSoundClip = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.menu_export_options_IncludeSoundClip_Callback,...
        'Label','Include sound clip',...
        'Tag','menu_export_options_IncludeSoundClip');

    obj.export_options_IncludeSoundClip_None = uimenu(...
        'Parent',obj.menu_export_options_IncludeSoundClip,...
        'Callback',@obj.export_options_IncludeSoundClip_None_Callback,...
        'Label','None',...
        'Tag','export_options_IncludeSoundClip_None');

    obj.export_options_IncludeSoundClip_SoundOnly = uimenu(...
        'Parent',obj.menu_export_options_IncludeSoundClip,...
        'Callback',@obj.export_options_IncludeSoundClip_SoundOnly_Callback,...
        'Checked','on',...
        'Label','Sound only',...
        'Tag','export_options_IncludeSoundClip_SoundOnly');

    obj.export_options_IncludeSoundClip_SoundMix = uimenu(...
        'Parent',obj.menu_export_options_IncludeSoundClip,...
        'Callback',@obj.export_options_IncludeSoundClip_SoundMix_Callback,...
        'Label','Sound mix',...
        'Tag','export_options_IncludeSoundClip_SoundMix');

    obj.menu_export_options_Animation = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.menu_export_options_Animation_Callback,...
        'Label','Animation',...
        'Tag','menu_export_options_Animation');

    obj.export_options_Animation_None = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_None_Callback,...
        'Label','None',...
        'Tag','export_options_Animation_None');

    obj.export_options_Animation_ProgressBar = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_ProgressBar_Callback,...
        'Label','Progress bar',...
        'Tag','export_options_Animation_ProgressBar');

    obj.export_options_Animation_ArrowAbove = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_ArrowAbove_Callback,...
        'Label','Arrow above',...
        'Tag','export_options_Animation_ArrowAbove');

    obj.export_options_Animation_ArrowBelow = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_ArrowBelow_Callback,...
        'Label','Arrow below',...
        'Tag','export_options_Animation_ArrowBelow');

    obj.export_options_Animation_ValueFollower = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_ValueFollower_Callback,...
        'Label','Value follower',...
        'Tag','export_options_Animation_ValueFollower');

    obj.export_options_Animation_SonogramFollower = uimenu(...
        'Parent',obj.menu_export_options_Animation,...
        'Callback',@obj.export_options_Animation_SonogramFollower_Callback,...
        'Label','Sonogram follower...',...
        'Tag','export_options_Animation_SonogramFollower');

    obj.export_options_ImageResolution = uimenu(...
        'Parent',obj.export_Options,...
        'Separator','on',...
        'Callback',@obj.export_options_ImageResolution_Callback,...
        'Label','Image resolution...',...
        'Tag','export_options_ImageResolution');

    obj.menu_export_options_SonogramImageMode = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.menu_export_options_SonogramImageMode_Callback,...
        'Label','Sonogram image mode',...
        'Tag','menu_export_options_SonogramImageMode');

    obj.export_options_SonogramImageMode_ScreenImage = uimenu(...
        'Parent',obj.menu_export_options_SonogramImageMode,...
        'Callback',@obj.export_options_SonogramImageMode_ScreenImage_Callback,...
        'Label','Screen image',...
        'Tag','export_options_SonogramImageMode_ScreenImage');

    obj.export_options_SonogramImageMode_Recalculate = uimenu(...
        'Parent',obj.menu_export_options_SonogramImageMode,...
        'Callback',@obj.export_options_SonogramImageMode_Recalculate_Callback,...
        'Label','Recalculate',...
        'Tag','export_options_SonogramImageMode_Recalculate');

    obj.export_options_ScalebarDimensions = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.export_options_ScalebarDimensions_Callback,...
        'Label','Scalebar dimensions...',...
        'Tag','export_options_ScalebarDimensions');

    obj.export_options_EditFigureTemplate = uimenu(...
        'Parent',obj.export_Options,...
        'Callback',@obj.export_options_EditFigureTemplate_Callback,...
        'Label','Edit figure template',...
        'Tag','export_options_EditFigureTemplate');

    obj.menu_Macros = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_Macros_Callback,...
        'Label','Macros',...
        'Tag','menu_Macros');

    % obj.menu_Help
    obj.menu_Help = uimenu(...
        'Parent',obj.figure_Main,...
        'Callback',@obj.menu_Help_Callback,...
        'Label','Help',...
        'Tag','menu_Help');

    obj.help_ControlsHelp = uimenu(...
        'Parent',obj.menu_Help,...
        'Separator',get(0,'defaultuimenuSeparator'),...
        'Callback',@obj.help_ControlsHelp_Callback,...
        'Label','Controls Help',...
        'Tag','help_ControlsHelp');

    obj.axes_Sonogram.UIContextMenu = obj.context_Sonogram;
    
    obj.axes_Amplitude.UIContextMenu = obj.context_Amplitude;
    
    obj.axes_Segments.UIContextMenu = obj.context_Segments;
    
    obj.push_WorksheetOptions.UIContextMenu = obj.context_WorksheetOptions;
    
    obj.popup_EventListAlign.UIContextMenu = obj.context_EventListAlign;

end

function eventSourceIdx = addNewEventSource(obj, channelNum, ...
        channelName, filterName, eventDetectorName, EventFunctionParameters, ...
        eventParameters, eventXLims, eventParts, defaultEventThreshold, ...
        baseChannelIsPseudo, createPseudoChannels)
    % Add a new event source, update all event-source-indexed variables
    arguments
        obj electro_gui
        channelNum (1, 1) double
        channelName (1, :) char
        filterName (1, :) char
        eventDetectorName (1, :) char
        EventFunctionParameters struct
        eventParameters struct
        eventXLims (:, 2) double
        eventParts (1, :) cell {mustBeText}
        defaultEventThreshold (1, 1) double
        baseChannelIsPseudo (1, 1) logical = false
        createPseudoChannels (1, 1) logical = true
    end
    eventSourceIdx = length(obj.dbase.EventSources) + 1;
    obj.dbase.EventSources{eventSourceIdx} = channelName;
    obj.dbase.EventChannels(eventSourceIdx) = channelNum;
    obj.dbase.EventFunctions{eventSourceIdx} = filterName;
    obj.dbase.EventFunctionParameters{eventSourceIdx} = EventFunctionParameters;
    obj.dbase.EventDetectors{eventSourceIdx} = eventDetectorName;
    obj.settings.EventThresholdDefaults(eventSourceIdx) = defaultEventThreshold;
    obj.dbase.EventParameters{eventSourceIdx} = eventParameters;
    obj.settings.EventXLims(eventSourceIdx, :) = eventXLims;
    obj.dbase.EventParts{eventSourceIdx} = eventParts;
    obj.dbase.EventChannelIsPseudo(eventSourceIdx) = baseChannelIsPseudo;
    obj.dbase.EventTimes{eventSourceIdx} = cell(length(eventParts), electro_gui.getNumFiles(obj.dbase));
    obj.dbase.EventIsSelected{eventSourceIdx} = cell(length(eventParts), electro_gui.getNumFiles(obj.dbase));

    if createPseudoChannels
        for eventPartIdx = 1:length(eventParts)
            obj.dbase = electro_gui.createEventPseudoChannel(obj.dbase, eventSourceIdx, eventPartIdx);
        end
    end
end


    end
    methods            % GUI Callbacks
        function click_recentFile(obj, hObject, event)
            % Click an item in the recent files menu
            obj.SaveState();

            % Get recent file path from menu item
            recentFilePath = hObject.UserData;
            % Update recent file list
            obj.addRecentFile(recentFilePath);
            % Open the dbase
            obj.OpenDbase(recentFilePath);
        end
        function edit_FileNumber_Callback(obj, hObject, event)

            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                obj.edit_FileNumber.String = '0';
                return;
            end

            filenum = str2double(obj.edit_FileNumber.String);

            if isnan(filenum)
                warndlg('Please enter a valid file number.');
                filenum = 1;
            end

            obj.settings.CurrentFile = filenum;

            obj.SaveState();

            obj.LoadFile();
        end

        % --- Executes on button press in push_PreviousFile.
        function push_PreviousFile_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            obj.changeFile(-1);

        end
        % --- Executes on button press in push_NextFile.
        function push_NextFile_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            obj.changeFile(1);

        end
        function menu_Experiment_Callback(obj, hObject, event)
        end
        function edit_Timescale_Callback(obj, hObject, event)
            tscale = str2double(obj.edit_Timescale.String);
            obj.settings.TLim = [obj.settings.TLim(1), obj.settings.TLim(1) + tscale];
            obj.UpdateTimescaleView();

        end
        function context_Sonogram_Callback(obj, hObject, event)

        end
        function menu_AlgorithmList_Callback(obj, hObject, event)

        end
        function menu_AutoCalculate_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            if obj.menu_AutoCalculate.Checked
                obj.menu_AutoCalculate.Checked = 'off';
            else
                obj.menu_AutoCalculate.Checked = 'on';
                obj.eg_PlotSonogram();
            end

        end

        function AlgorithmMenuClick(obj, hObject, event)

            for c = 1:length(obj.menu_Algorithm)
                obj.menu_Algorithm.Checked = 'off';
            end
            hObject.Checked = 'on';

            if isempty(hObject.UserData)
                alg = hObject.Label;
                obj.settings.SonogramParams = electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, 'params');
                hObject.UserData = obj.settings.SonogramParams;
            else
                obj.settings.SonogramParams = hObject.UserData;
            end

            obj.eg_PlotSonogram();

            obj.eg_Overlay();

        end

        function FilterMenuClick(obj, hObject, event)
            % Handle a click on the sound filter menu item

            for c = 1:length(obj.menu_Filter)
                obj.menu_Filter(c).Checked = 'off';
            end
            hObject.Checked = 'on';

            if isempty(hObject.UserData)
                alg = hObject.Label;
                obj.settings.FilterParams = electro_gui.eg_runPlugin(obj.plugins.functions, alg, 'params');
                hObject.UserData = obj.settings.FilterParams;
            else
                obj.settings.FilterParams = hObject.UserData;
            end

            obj.UpdateFilteredSound();

            cla(obj.axes_Sound);
            obj.UpdateFilteredSound();

            obj.RedrawSoundEnvelope();

            obj.updateXLimBox();

            obj.setClickSoundCallback(obj.axes_Sonogram);
            obj.setClickSoundCallback(obj.axes_Sound);

            obj.updateAmplitude();

        end
        function click_segment(obj, hObject, event)
            % Callback for clicking anything on the axes_Segments

            % Search for clicked item among segments
            clickedAnnotationNum = find(obj.SegmentHandles==hObject);
            if isempty(clickedAnnotationNum)
                % No matching segment found. Must be a marker.
                clickedAnnotationNum = find(obj.MarkerHandles==hObject);
                clickedAnnotationType = 'marker';
            else
                clickedAnnotationType = 'segment';
            end

            filenum = electro_gui.getCurrentFileNum(obj.settings);
            switch obj.figure_Main.SelectionType
                case 'normal'
                    [oldAnnotationNum, oldAnnotationType] = obj.FindActiveAnnotation();
                    switch clickedAnnotationType
                        case 'segment'
                            obj.SetActiveSegment(clickedAnnotationNum);
                        case 'marker'
                            obj.SetActiveMarker(clickedAnnotationNum);
                    end
                    obj.UpdateActiveAnnotationDisplay(oldAnnotationNum, oldAnnotationType, clickedAnnotationNum, clickedAnnotationType);
                case 'extend'
                    switch clickedAnnotationType
                        case 'segment'
                            obj.dbase.SegmentIsSelected{filenum}(clickedAnnotationNum) = ~obj.dbase.SegmentIsSelected{filenum}(clickedAnnotationNum);
                            hObject.FaceColor = obj.getAnnotationFaceColor('segment', obj.dbase.SegmentIsSelected{filenum}(clickedAnnotationNum));
                        case 'marker'
                            obj.dbase.MarkerIsSelected{filenum}(clickedAnnotationNum) = ~obj.dbase.MarkerIsSelected{filenum}(clickedAnnotationNum);
                            hObject.FaceColor = obj.getAnnotationFaceColor('marker',  obj.dbase.MarkerIsSelected{filenum}(clickedAnnotationNum));
                    end
                case 'open'
                    switch clickedAnnotationType
                        case 'segment'
                            if clickedAnnotationNum < length(obj.SegmentHandles)
                                % Deselect active segment
                                obj.SetActiveSegment([]);
                                obj.dbase.SegmentTimes{filenum}(clickedAnnotationNum,2) = obj.dbase.SegmentTimes{filenum}(clickedAnnotationNum+1,2);
                                obj.dbase.SegmentTimes{filenum}(clickedAnnotationNum+1,:) = [];
                                obj.dbase.SegmentTitles{filenum}(clickedAnnotationNum+1) = [];
                                obj.dbase.SegmentIsSelected{filenum}(clickedAnnotationNum+1) = [];
                                % Select new active segment
                                obj.SetActiveSegment(clickedAnnotationNum);
                                obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;
                                obj.PlotAnnotations();
                            end
                        case 'marker'
                            % Nah, doubt we need to implement concatenating adjacent
                            % markers.
                    end
            end


        end
        function context_Segments_Callback(obj, hObject, event)
        end
        function menu_SegmenterList_Callback(obj, hObject, event)
        end
        function menu_DeleteAll_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            filenum = electro_gui.getCurrentFileNum(obj.settings);
            obj.dbase.SegmentIsSelected{filenum} = zeros(size(obj.dbase.SegmentIsSelected{filenum}));

            obj.updateSegmentSelectHighlight();


        end
        function menu_UndeleteAll_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            filenum = electro_gui.getCurrentFileNum(obj.settings);
            obj.dbase.SegmentIsSelected{filenum} = ones(size(obj.dbase.SegmentIsSelected{filenum}));

            obj.updateSegmentSelectHighlight();

        end
        % --- Executes on button press in push_Segment.
        function push_Segment_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            obj.SegmentSounds();


        end
        function menu_AutoSegment_Callback(obj, hObject, event)
            obj.SaveState();

            if ~obj.menu_AutoSegment.Checked
                obj.menu_AutoSegment.Checked = 'on';
                obj.SegmentSounds();
            else
                obj.menu_AutoSegment.Checked = 'off';
            end


        end
        function menu_SegmentParameters_Callback(obj, hObject, event)
            if isempty(obj.settings.SegmenterParams.Names)
                errordlg('Current segmenter does not require parameters.','Segmenter error');
                return
            end

            answer = inputdlg(obj.settings.SegmenterParams.Names,'Segmenter parameters',1,obj.settings.SegmenterParams.Values);
            if isempty(answer)
                return
            end

            obj.SaveState();

            obj.settings.SegmenterParams.Values = answer;

            for c = 1:length(obj.menu_SegmenterList.Children)
                if obj.menu_SegmenterList.Children(c).Checked
                    h = obj.menu_SegmenterList.Children(c);
                    h.UserData = obj.settings.SegmenterParams;
                end
            end

            obj.SegmentSounds();

        end

        function SegmenterMenuClick(obj, hObject, event)

            obj.SaveState();

            for c = 1:length(obj.menu_SegmenterList.Children)
                obj.menu_SegmenterList.Children(c).Checked = 'off';
            end
            hObject.Checked = 'on';

            if isempty(hObject.UserData)
                alg = hObject.Label;
                obj.settings.SegmenterParams = electro_gui.eg_runPlugin(obj.plugins.segmenters, alg, 'params');
                hObject.UserData = obj.settings.SegmenterParams;
            else
                obj.settings.SegmenterParams = hObject.UserData;
            end

            obj.SetSegmentThreshold();

        end

        function menu_AmplitudeAxisRange_Callback(obj, hObject, event)
            answer = inputdlg({'Minimum','Maximum'},'Axis range',1,{num2str(obj.settings.AmplitudeLims(1)) num2str(obj.settings.AmplitudeLims(2))});
            if isempty(answer)
                return
            end

            obj.settings.AmplitudeLims(1) = str2double(answer{1});
            obj.settings.AmplitudeLims(2) = str2double(answer{2});
            obj.axes_Amplitude.YLim = obj.settings.AmplitudeLims;




        end
        function menu_SmoothingWindow_Callback(obj, hObject, event)
            answer = inputdlg({'Smoothing window (ms)'},'Smoothing window',1,{num2str(obj.settings.SmoothWindow*1000)});
            if isempty(answer)
                return
            end
            obj.settings.SmoothWindow = str2double(answer{1})/1000;

            obj.updateAmplitude();

        end


        function click_Amplitude(obj, hObject, event)

            if strcmp(obj.figure_Main.SelectionType,'open')
                [numSamples, fs] = obj.eg_GetSamplingInfo();
                obj.settings.TLim = [0, numSamples/fs];
                obj.UpdateTimescaleView();

            elseif strcmp(obj.figure_Main.SelectionType,'normal')
                obj.axes_Amplitude.Units = 'pixels';
                obj.axes_Amplitude.Parent.Units = 'pixels';
                rect = rbbox;

                pos = obj.axes_Amplitude.Position;
                obj.axes_Amplitude.Units = 'normalized';
                obj.axes_Amplitude.Parent.Units = 'normalized';
                xl = xlim(obj.axes_Amplitude);

                rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
                rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));

                if rect(3) == 0
                    shift = rect(1) - obj.settings.TLim(1);
                    obj.settings.TLim = obj.settings.TLim + shift;
                else
                    obj.settings.TLim = [rect(1), rect(1)+rect(3)];
                end
                obj.UpdateTimescaleView();
            elseif strcmp(obj.figure_Main.SelectionType,'extend')
                pos = obj.axes_Amplitude.CurrentPoint;
                obj.settings.CurrentThreshold = pos(1,2);
                obj.dbase.SegmentThresholds(electro_gui.getCurrentFileNum(obj.settings)) = obj.settings.CurrentThreshold;
                obj.SetSegmentThreshold();
            end




        end
        function menu_SetThreshold_Callback(obj, hObject, event)
            answer = inputdlg({'Threshold'},'Set threshold',1,{num2str(obj.settings.CurrentThreshold)});
            if isempty(answer)
                return
            end
            obj.settings.CurrentThreshold = str2double(answer{1});
            obj.dbase.SegmentThresholds(electro_gui.getCurrentFileNum(obj.settings)) = obj.settings.CurrentThreshold;

            obj.SetSegmentThreshold();


        end
        function menu_LongFiles_Callback(obj, hObject, event)
            answer = inputdlg({'Number of points defining a long file'},'Long files',1,{num2str(obj.TooLong)});
            if isempty(answer)
                return
            end
            obj.TooLong = str2double(answer{1});

        end

        function mouseMotionHandler(obj, hObject, event)
            % Callback to handle mouse motion

            if obj.isShiftDown()
                % User is holding the shift key down

                % Get coordinates of mouse
                xy = obj.figure_Main.CurrentPoint;

                % Define list of axes that will have cursors
                cursor_axes = [obj.axes_Amplitude, obj.axes_Sonogram, obj.axes_Segments, obj.axes_Channel, obj.axes_Sound];

                % Check if mouse is inside one of the relevant display axes
                inside = electro_gui.areCoordinatesIn(xy(1), xy(2), cursor_axes);

                if inside
                    % User is moving mouse within one of the designated cursor axes
                    % with the shift key down - draw or update the cursors

                    % ax1 is the particular axes the mouse is currently inside
                    ax1 = cursor_axes(inside);
                    % xlim will be the same for all the axes
                    xl = xlim(ax1);
                    % get the x position as a fraction of the axes limits
                    x = (xy(1) - ax1.Position(1)) / ax1.Position(3);
                    % Get the x position is a time in the axes coordinate system
                    t = x*diff(xl)+xl(1);
                    if ax1 == obj.axes_Segments
                        % Mouse is in segment axes
                        % Snap to close by segment start/end
                        filenum = electro_gui.getCurrentFileNum(obj.settings);
                        sampleNum = t*obj.dbase.Fs;
                        % Check how far away we are from the nearest segment
                        [minSampleDistance, minIdx] = min(abs(obj.dbase.SegmentTimes{filenum}(:) - sampleNum));
                        threshold = diff(xlim(ax1)) / 50;
                        if minSampleDistance / obj.dbase.Fs < threshold
                            % We're close to a segment boundary - snap to it
                            t = obj.dbase.SegmentTimes{filenum}(minIdx) / obj.dbase.Fs;
                        end
                    elseif any(ax1 == obj.axes_Channel)
                        % Mouse is in one of the channel axes

                        % Determine which channel axes
                        axnum = find(ax1 == obj.axes_Channel);
                        % Check if axes is displaying events
                        eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
                        fs = obj.loadedChannelFs{axnum};
                        if ~isempty(eventSourceIdx)
                            % Axes is currently displaying events
                            filenum = electro_gui.getCurrentFileNum(obj.settings);
                            sampleNum = t*fs;
                            eventSamples = vertcat(obj.dbase.EventTimes{eventSourceIdx}{:, filenum});
                            % Check how far away we are from the nearest event
                            [minSampleDistance, minIdx] = min(abs(eventSamples - sampleNum));
                            threshold = diff(xlim(ax1)) / 50;
                            if minSampleDistance / fs < threshold
                                % We're close to an event - snap to it
                                t = eventSamples(minIdx) / fs;
                            end
                        end
                    end

                    % Loop over cursor axes updating cursor
                    for k = 1:length(cursor_axes)
                        if k > length(obj.Cursors)
                            % We're adding a new cursor
                            obj.Cursors(k) = gobjects();
                        end

                        ax = cursor_axes(k);
                        if ~isgraphics(obj.Cursors(k)) || ~isvalid(obj.Cursors(k))
                            % Cursor is not valid, create a new one
                            delete(obj.Cursors(k));
                            if ax.Visible
                                yl = ylim(ax);
                                obj.Cursors(k) = line([t, t], yl, 'Parent', ax, 'Color', 'green', 'PickableParts', 'none', 'HitTest', 'off');
                            end
                        else
                            % Cursor is valid, update its values
                            if ax ~= obj.Cursors(k).Parent
                                % This cursor belongs to some other axes, fix it
                                obj.Cursors(k).Parent = ax;
                            end
                            if ax.Visible
                                yl = ylim(ax);
                                obj.Cursors(k).XData = [t, t];
                                obj.Cursors(k).YData = yl;
                            end
                        end
                    end

                    return;
                end
            else
                if ~isempty(obj.Cursors)
                    delete(obj.Cursors);
                    obj.Cursors = gobjects().empty;
                end
            end

        end

        function keyReleaseHandler(obj, hObject, event)
            % Callback to handle a key release

        %     if strcmp(event.Key, 'control')
        %     end

            if strcmp(event.Key, 'shift')

                % Delete cursor objects, if they exist
                delete(obj.Cursors);
                obj.Cursors = gobjects().empty;
            end

        end


        function keyPressHandler(obj, hObject, event)
            % Callback to handle a key press


        %     if strcmp(event.Key, 'control')
        %     end
        %     if strcmp(event.Key, 'shift')
        %     end

            % Get currently loaded file num
            filenum = electro_gui.getCurrentFileNum(obj.settings);

            if any(strcmp('control', event.Modifier))
                % User pressed a key with 'control' down
                switch event.Key
                    case 'e'
                        % User pressed "control-e"
                        % Press control-e to produce a export of the sonogram and any channel
                        % views.
                        obj.exportView();
                        return
                    case 'v'
                        % Paste series of characters onto segments/markers
                        [annotationNums, annotationType] = obj.PasteAnnotationTitles([], [], filenum);
                        obj.UpdateAnnotationTitleDisplay(annotationNums, annotationType);
                        oldAnnotationNum = obj.FindActiveAnnotation();
                        obj.SetActiveAnnotation(max(annotationNums)+1, annotationType);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum, annotationType);
                    case 'i'
                        % Insert a blank annotation at the active spot, and shift
                        % other annotations over, stopping when we get to a blank
                        % annotation, or the last annotation.
                        [annotationNum, annotationType] = obj.FindActiveAnnotation();
                        changedAnnotationNums = obj.InsertBlankAnnotationTitle(annotationNum, annotationType, filenum);
                        obj.UpdateAnnotationTitleDisplay(changedAnnotationNums, annotationType);
                    case 'o'
                        % User pressed control-o - activate open dbase dialog
                        if any(strcmp('shift', event.Modifier)) && ~isempty(obj.tempSettings.recentFiles)
                            % Shift is also down - open the most recent one
                            obj.OpenDbase(obj.tempSettings.recentFiles{1});
                        else
                            obj.OpenDbase();
                        end
                    case 'n'
                        % User pressed control-n - activate new dbase dialog
                        obj.eg_NewDbase();
                    case 's'
                        % User pressed control-s - activate save dbase dialog
                        obj.SaveDbase();
                    case 'space'
                        % User pressed control-space - start playback
                        snd = obj.GenerateSound('snd');
                        obj.progress_play(snd);
                    case 'z'
                        if obj.isShiftDown()
                            % User pressed control-shift-z
                            obj.Redo();
                        else
                            % User pressed control-z - undo last action
                            obj.Undo();
                        end
                    case 'y'
                        % User pressed control-z - undo last action
                        obj.Redo();
                end
            else
                % User pressed a key without control down
                if ~electro_gui.isDataLoaded(obj.dbase)
                    % No data, none of the other key handlers should be attempted.
                    return
                end
                switch event.Key
                    case 'comma'
                        % Keypress is a "comma" - load previous file
                        filenum = electro_gui.getCurrentFileNum(obj.settings);
                        filenum = filenum-1;
                        if filenum == 0
                            filenum = electro_gui.getNumFiles(obj.dbase);
                        end
                        obj.edit_FileNumber.String = num2str(filenum);

                        obj.LoadFile();

                        return
                    case 'period'
                        % Keypress is a "period" - load next file
                        filenum = electro_gui.getCurrentFileNum(obj.settings);
                        filenum = filenum+1;
                        if filenum > electro_gui.getNumFiles(obj.dbase)
                            filenum = 1;
                        end
                        obj.edit_FileNumber.String = num2str(filenum);

                        obj.LoadFile();

                        return
                    case obj.settings.ValidSegmentCharacters
                        % Key was a valid character for naming a segment/marker
                        obj.SaveState();
                        obj.SetAnnotationTitle(event.Key, filenum);
                        obj.UpdateAnnotationTitleDisplay();
                        oldAnnotationNum = obj.IncrementActiveAnnotation(+1);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum);
                    case 'backspace'
                        obj.SaveState();
                        obj.SetAnnotationTitle('', filenum);
                        obj.UpdateAnnotationTitleDisplay();
                        oldAnnotationNum = obj.IncrementActiveAnnotation(+1);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum);
                    case 'rightarrow'
                        % User pressed right arrow
                        oldAnnotationNum = obj.IncrementActiveAnnotation(+1);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum);
                    case 'leftarrow'
                        % User pressed left arrow
                        oldAnnotationNum = obj.IncrementActiveAnnotation(-1);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum);
                    case {'uparrow', 'downarrow'}
                        % User pressed up or down arrow
                        [oldAnnotationNum, oldAnnotationType] = obj.FindActiveAnnotation();
                        [newAnnotationNum, newAnnotationType] = obj.FindClosestAnnotationOfOtherType(filenum);
                        obj.SetActiveAnnotation(newAnnotationNum, newAnnotationType);
                        obj.UpdateActiveAnnotationDisplay(oldAnnotationNum, oldAnnotationType, newAnnotationNum, newAnnotationType);
                    case 'space'
                        % User pressed "space" - join this segment with next segment
                        obj.SaveState();
                        [annotationNum, annotationType] = obj.FindActiveAnnotation();
                        switch annotationType
                            case 'segment'
                                obj.JoinSegmentWithNext(filenum, annotationNum);
                                obj.PlotAnnotations();
                            case 'marker'
                                % Don't really need to do this with markers
                            case 'none'
                                % Do nothing
                        end
                    case 'return'
                        % User pressed "enter" key - toggle active segment "selection"
                        % Note that "selected" segments/markers is not the same as
                        % "active" segments/markers.
                        obj.SaveState();
                        obj.ToggleAnnotationSelect(filenum);
                        obj.PlotAnnotations();
                    case 'delete'
                        % User pressed "delete" - delete active marker
                        obj.SaveState();
                        obj.DeleteAnnotation(filenum);
                        obj.PlotAnnotations();
                    case 'backquote'
                        % User pressed the "`" / "~" button - transform active marker into
                        %   segment or vice versa
                        obj.SaveState();
                        obj.ConvertAnnotationType(filenum);
                        obj.PlotAnnotations();
                end
            end

        end

        function popup_Functions_Callback(obj, axnum)
            % Update the function parameters for this axis
            obj.settings.ChannelAxesFunctionParams{axnum} = obj.getSelectedFunctionParameters(axnum);

            % Set the event detector back to none? Not sure why
            obj.popup_EventDetectors(axnum).Value = 1;

            % Update channel plot
            obj.eg_LoadChannel(axnum);

            if obj.menu_SourcePlots(axnum).Checked
                obj.updateAmplitude();
            end
        end
        % --- Executes on selection change in popup_Function1.
        function popup_Function1_Callback(obj, hObject, event)
            axnum = 1;

            obj.popup_Functions_Callback(axnum);

        end

        % --- Executes on selection change in popup_Function2.
        function popup_Function2_Callback(obj, hObject, event)

            axnum = 2;

            obj.popup_Functions_Callback(axnum);

        end

        function popup_Channels_Callback(obj, axnum)
            % Handle change in value of either channel source menu

        %     if isempty(findobj('Parent',obj.axes_Sonogram,'type','text'))
                % ?? is this for the long file thing?
                obj.popup_Functions(axnum).Value = 1;
                obj.popup_EventDetectors(axnum).Value = 1;
                obj.eg_LoadChannel(axnum);
        %     end

            channelNum = obj.getSelectedChannel(axnum);
            if isempty(channelNum)
                obj.popup_EventDetectors(axnum).Enable = 'off';
                matchingEventSourceIdx = [];
            else
                obj.popup_EventDetectors(axnum).Enable = 'on';
                matchingEventSourceIdx = obj.WhichEventSourceIdxMatch(channelNum);
            end

            if obj.menu_SourcePlots(axnum).Checked
                obj.updateAmplitude();
            end

            if ~isempty(matchingEventSourceIdx)
                % If this channel is involved in an event source, load it up now
                eventSourceIdx = matchingEventSourceIdx(end);
                obj.setChannelAxesEventSource(axnum, eventSourceIdx);
            elseif isfield(obj.settings, 'DefaultChannelFunction')
                %If available, use the default channel filter (from defaults file)
                % obj.DefaultChannelFilter is defined
                allFunctionNames = obj.popup_Functions(axnum).String;
                defaultChannelFunctionIdx = find(strcmp(allFunctionNames, obj.settings.DefaultChannelFunction));
                if ~isempty(defaultChannelFunctionIdx)
                    % Default channel function is valid
                    currentChannelFunctionIdx = obj.popup_Functions(axnum).Value;
                    if currentChannelFunctionIdx ~= defaultChannelFunctionIdx
                        % Default channel function does not match currently selected function. Switch it!
                        obj.popup_Functions(axnum).Value = defaultChannelFunctionIdx;
                        % Trigger callback for changed channel function
                        obj.popup_Functions_Callback(axnum);
                    end
                else
                    warning('Found a default channel function in the defaults file, but it was not a recognized function: %s', obj.settings.DefaultChannelFunction);
                end
            end
        end
        % --- Executes on selection change in popup_Channel1.
        function popup_Channel1_Callback(obj, hObject, event)

            axnum = 1;

            obj.popup_Channels_Callback(axnum);

        end

        % --- Executes on selection change in popup_Channel2.
        function popup_Channel2_Callback(obj, hObject, event)

            axnum = 2;

            obj.popup_Channels_Callback(axnum);

        end

        function context_Channel1_Callback(obj, hObject, event)

        end
        function menu_PeakDetect1_Callback(obj, hObject, event)
            if obj.menu_PeakDetect1.Checked
                obj.menu_PeakDetect1.Checked = 'off';
            else
                obj.menu_PeakDetect1.Checked = 'on';
            end
            obj.eg_LoadChannel(1);



        end
        function context_Channel2_Callback(obj, hObject, event)

        end
        function menu_PeakDetect2_Callback(obj, hObject, event)
            if obj.menu_PeakDetect2.Checked
                obj.menu_PeakDetect2.Checked = 'off';
            else
                obj.menu_PeakDetect2.Checked = 'on';
            end
            obj.eg_LoadChannel(2);

        end

        function click_Channel(obj, hObject, event)
            % Handle a click on the channel axes

            if ~strcmp(hObject.Type,'axes')
                hObject = hObject.Parent;
            end
            if hObject==obj.axes_Channel1
                axnum = 1;
            else
                axnum = 2;
            end

            ax = obj.axes_Channel(axnum);

            if strcmp(obj.figure_Main.SelectionType,'open')
                chan = obj.getSelectedChannel(axnum);
                [numSamples, fs] = obj.eg_GetSamplingInfo([], chan);

                for axn = 1:2
                    if obj.axes_Channel(axn).Visible
                        if obj.menu_AutoLimits(axn).Checked
                            yl = [min(obj.loadedChannelData{axn}) max(obj.loadedChannelData{axn})];
                            if yl(1)==yl(2)
                                yl = [yl(1)-1 yl(2)+1];
                            end
                            obj.axes_Channel(axn).YLim = [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1];
                        else
                            obj.axes_Channel(axn).YLim = obj.(['ChanYLimits' num2str(axn)]);
                        end
                    end
                end
                obj.settings.TLim = [0, numSamples/fs];
                obj.UpdateTimescaleView();

            elseif strcmp(obj.figure_Main.SelectionType,'normal')
                % Left click

                ax.Units = 'pixels';
                ax.Parent.Units = 'pixels';
                rect = rbbox();

                pos = ax.Position;
                ax.Parent.Units = 'normalized';
                ax.Units = 'normalized';
                xl = xlim(ax);
                yl = ylim(ax);

                rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
                rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
                rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

                if rect(3) == 0
                    shift = rect(1) - obj.settings.TLim(1);
                    obj.settings.TLim = obj.settings.TLim + shift;
                else
                    obj.settings.TLim = [rect(1), rect(1)+rect(3)];
                    if obj.menu_AllowYZooms(axnum).Checked && rect(4) > 0
                        ylim([rect(2) rect(4)+rect(2)]);
                    end
                end
                obj.UpdateTimescaleView();

            elseif strcmp(obj.figure_Main.SelectionType, 'alt')
                % Control-click or right click
                if ~obj.isControlDown()
                    % False alarm, this is just a right click, stand down
                    return;
                end

                obj.SaveState();

                obj.settings.ActiveEventNum = [];
                obj.settings.ActiveEventPartNum = [];
                obj.settings.ActiveEventSourceIdx = [];

                % Remove active event cursor
                delete(obj.ActiveEventCursors);

                ax.Units = 'pixels';
                ax.Parent.Units = 'pixels';
                rect = rbbox();
                boxWidthPixels = rect(3);

                eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);

                pos = ax.Position;
                ax.Parent.Units = 'normalized';
                ax.Units = 'normalized';
                xl = xlim(ax);
                yl = ylim(ax);

                rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
                rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
                rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

                if boxWidthPixels < 3
                    % Simple control-click on axes
                    obj.SetEventThreshold(axnum, rect(2));
                else
                    % Control click and drag on channel axes

                    if ~isempty(eventSourceIdx)
                        % Set local threshold
                        obj.SaveState();

                        filenum = electro_gui.getCurrentFileNum(obj.settings);

                        eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);

                        [~, ~, eventDetectorName, eventParameters] = obj.GetEventSourceInfo(eventSourceIdx);

                        % Get channel data
                        chanData = obj.loadedChannelData{axnum};
                        fs = obj.loadedChannelFs{axnum};

                        minTime = rect(1);
                        maxTime = rect(1)+rect(3);
                        minSample = max(1,                round(minTime*fs));
                        maxSample = min(length(chanData), round(maxTime*fs));
                        minVolt = -Inf;
                        maxVolt = Inf;

                        % Get a mask for events within box
                        boxedEventMask = obj.GetBoxedEventMask(axnum, filenum, minTime, maxTime, minVolt, maxVolt);
                        % Just combine the mask for all the event parts - we're
                        % assuming we'll never want to select one part of an event but
                        % not all others.
                        boxedEventMask = or(boxedEventMask{:});
                        % Delete events within box
                        for eventPartNum = 1:size(obj.dbase.EventTimes{eventSourceIdx}, 1)
                            obj.dbase.EventTimes{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = [];
                            obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = [];
                        end

                        % Restrict the data we're detecting events in  to the
                        % specified time limits
                        chanData = chanData(minSample:maxSample);

                        % Get the specified local threshold
                        localThreshold = rect(2);

                        % Run event detector plugin to get a list of detected event times
                        [newEventTimes, eventParts] = electro_gui.eg_runPlugin(obj.plugins.eventDetectors, eventDetectorName, chanData, fs, localThreshold, eventParameters);
                        newEventSelected = true(1, length(newEventTimes{1}));
                        for eventPartNum = 1:length(eventParts)
                            % Adjust event times based on start of time limits
                            newEventTimes{eventPartNum} = newEventTimes{eventPartNum} + (minSample-1);
                            % Store the original event times/selected
                            oldEventTimes = obj.dbase.EventTimes{eventSourceIdx}{eventPartNum, filenum};
                            oldEventSelected = obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum};
                            % Concatenate new event times/selected
                            eventTimes = vertcat(oldEventTimes, newEventTimes{eventPartNum});
                            eventSelected = [oldEventSelected, newEventSelected];
                            % Sort event times by time
                            [eventTimes, sortIdx] = sort(eventTimes);
                            eventSelected = eventSelected(sortIdx);
                            % Update event times/selected
                            obj.dbase.EventTimes{eventSourceIdx}{eventPartNum, filenum} = eventTimes;
                            obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum} = eventSelected;
                        end
                        obj.UpdateChannelEventDisplay(axnum);
                        obj.UpdateEventViewer();
                    end
                end

            elseif strcmp(obj.figure_Main.SelectionType,'extend')
                % Shift-click
                obj.SaveState();

                % Check the event source the clicked channel axes is displaying
                eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);

                if ~isempty(eventSourceIdx)
                    % The clicked channel axes is currently showing an event source

                    obj.settings.ActiveEventNum = [];
                    obj.settings.ActiveEventPartNum = [];
                    obj.settings.ActiveEventSourceIdx = [];

                    % Remove active event cursor
                    delete(obj.ActiveEventCursors);

                    ax.Units = 'pixels';
                    ax.Parent.Units = 'pixels';
                    rect = rbbox();

                    pos = ax.Position;
                    ax.Parent.Units = 'normalized';
                    ax.Units = 'normalized';
                    xl = xlim(ax);
                    yl = ylim(ax);

                    % Get coordinates of box in data coordinate system
                    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
                    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
                    rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                    rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

                    % Find events that fall within time bounds of box
                    filenum = electro_gui.getCurrentFileNum(obj.settings);
                    minTime = rect(1);
                    maxTime = rect(1)+rect(3);
                    minVolt = rect(2);
                    maxVolt = rect(2)+rect(4);

                    % Get a mask for events within box
                    boxedEventMask = obj.GetBoxedEventMask(axnum, filenum, minTime, maxTime, minVolt, maxVolt);
                    % Just combine the mask for all the event parts - we're
                    % assuming we'll never want to select one part of an event but
                    % not all others.
                    boxedEventMask = or(boxedEventMask{:});

                    % Invert the selected status of any events that fell within box
                    for eventPartNum = 1:length(obj.EventHandles{axnum})
                        obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = ~obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask);
                    end

                    % Update event display for any axes displaying the same event source
                    for axn = 1:2
                        if eventSourceIdx == obj.GetChannelAxesEventSourceIdx(axn)
                            obj.UpdateChannelEventDisplay(axn);
                        end
                    end

                    % Update event viewer
                    obj.UpdateEventViewer();
                end
            end
        end
        function AllowYZoom(obj, axnum)
            if obj.menu_AllowYZooms(axnum).Checked
                obj.menu_AllowYZooms(axnum).Checked = 'off';
                if obj.menu_AutoLimits1.Checked
                    yl = [min(obj.loadedChannelData{axnum}), ...
                          max(obj.loadedChannelData{axnum})];
                    if yl(1)==yl(2)
                        yl = [yl(1)-1 yl(2)+1];
                    end
                    ylim(obj.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
                else
                    ylim(obj.axes_Channel(axnum), obj.ChanYLimits(axnum, :));
                end
                obj.eg_Overlay();
            else
                obj.menu_AllowYZooms(axnum).Checked = 'on';
            end

        end
        function menu_AllowYZoom1_Callback(obj, hObject, event)
            axnum = 1;
            obj.AllowYZoom(axnum);



        end
        function menu_AllowYZoom2_Callback(obj, hObject, event)
            axnum = 2;
            obj.AllowYZoom(axnum);

        end


        function menu_AutoLimits_Callback(obj, axnum)
            if obj.menu_AutoLimits(axnum).Checked
                obj.menu_AutoLimits(axnum).Checked = 'off';
                obj.ChanYLimits(axnum, :) = ylim(obj.axes_Channel(axnum));
            else
                obj.menu_AutoLimits(axnum).Checked = 'on';
                yl = [min(obj.loadedChannelData{axnum}), ...
                      max(obj.loadedChannelData{axnum})];
                if yl(1)==yl(2)
                    yl = [yl(1)-1 yl(2)+1];
                end
                ylim(obj.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
                obj.eg_Overlay();
            end

        end
        function menu_AutoLimits1_Callback(obj, hObject, event)
            axnum = 1;
            obj.menu_AutoLimits_Callback(axnum);


        end
        function menu_AutoLimits2_Callback(obj, hObject, event)
            axnum = 2;
            obj.menu_AutoLimits_Callback(axnum);

        end
        function eg_SetLimits(obj,axnum)
            defaultLimits = obj.axes_Channel(axnum).YLim;
            answer = inputdlg({'Minimum','Maximum'},'Axes limits',1,{num2str(defaultLimits(1)),num2str(defaultLimits(2))});
            if isempty(answer)
                return
            end
            if ~obj.menu_AutoLimits(axnum).Checked
                obj.ChanYLimits(axnum, :) = str2double(answer(1:2));
            end

            ylim(obj.axes_Channel(axnum), str2double(answer(1:2)));

            obj.eg_Overlay();

        end
        function menu_SetLimits1_Callback(obj, hObject, event)
            axnum = 1;
            obj.eg_SetLimits(axnum);


        end
        function menu_SetLimits2_Callback(obj, hObject, event)
            axnum = 2;
            obj.eg_SetLimits(axnum);


        end
        % --- Executes on selection change in popup_EventDetector1.
        function popup_EventDetector1_Callback(obj, hObject, event)

            obj.UpdateChannelEventDisplay(1);

        end

        % --- Executes on selection change in popup_EventDetector2.
        function popup_EventDetector2_Callback(obj, hObject, event)

        %     if isempty(findobj('Parent',obj.axes_Sonogram,'type','text'))
                obj.UpdateChannelEventDisplay(2);
        %        obj.eg_clickEventDetector(2);
        %     end

        end

        function menu_Events1_Callback(obj, hObject, event)
        end

        function menu_EventAutoDetect_Callback(obj, axnum)
            if obj.menu_EventAutoDetect(axnum).Checked
                obj.menu_EventAutoDetect(axnum).Checked = 'off';
            else
                obj.menu_EventAutoDetect(axnum).Checked = 'on';
                obj.DetectEventsInAxes(1);

                eventSourceIdx = obj.GetChannelAxesEventSourceIdx(1);
                obj.UpdateAnythingShowingEventSource(eventSourceIdx);
            end

        %         if obj.menu_AutoDisplayEvents.Checked
        %             obj.UpdateEventViewer();
        %         end


        end
        function menu_EventAutoDetect1_Callback(obj, hObject, event)
            obj.menu_EventAutoDetect_Callback(1);


        end
        function menu_EventAutoThreshold1_Callback(obj, hObject, event)
        end
        function menu_UpdateEventThresholdDisplay1_Callback(obj, hObject, event)
            obj.SetEventThreshold(1);


        end
        function menu_Events2_Callback(obj, hObject, event)
        end
        function menu_EventAutoDetect2_Callback(obj, hObject, event)
            obj.menu_EventAutoDetect_Callback(2);


        end
        function menu_EventAutoThreshold2_Callback(obj, hObject, event)
        end
        function menu_UpdateEventThresholdDisplay2_Callback(obj, hObject, event)
            obj.SetEventThreshold(2);

        end

        function push_Detect_Callback(obj, axnum)
            obj.DetectEventsInAxes(axnum);

            % Update other channel axes if necessary
            eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
            matchingAxnum = obj.WhichChannelAxesMatchEventSource(eventSourceIdx);
            matchingAxnum(matchingAxnum == axnum) = [];
            for axn = matchingAxnum
                obj.UpdateChannelEventDisplay(axn);
            end

            if obj.menu_AutoDisplayEvents.Checked
                obj.UpdateEventViewer();
            end
        end
        % --- Executes on button press in push_Detect1.
        function push_Detect1_Callback(obj, hObject, event)
            obj.push_Detect_Callback(1);

        end
        % --- Executes on button press in push_Detect2.
        function push_Detect2_Callback(obj, hObject, event)
            obj.push_Detect_Callback(2);

        end
        % --- Executes on selection change in popup_EventListAlign.
        function popup_EventListAlign_Callback(obj, hObject, event)

            obj.settings.ActiveEventNum = [];
            obj.settings.ActiveEventPartNum = [];
            obj.settings.ActiveEventSourceIdx = [];

            obj.UpdateEventViewer();

        end

        function ClickEventSymbol(obj, eventMarker, event)
            % Handle a click on an event marker in one of the channel axes

            % Determine which axes the clicked marker was in
            if eventMarker.Parent==obj.axes_Channel1
                axnum = 1;
            else
                axnum = 2;
            end

            eventSourceIdx = obj.GetChannelAxesEventSourceIdx(axnum);
            filenum = electro_gui.getCurrentFileNum(obj.settings);
            for eventPartNum = 1:length(obj.EventHandles{axnum})
                eventNum = find(obj.EventHandles{axnum}{eventPartNum}==eventMarker, 1);
                if ~isempty(eventNum)
                    break;
                end
            end

            if isempty(eventNum)
                error('Could not find clicked event marker in list - this shouldn''t happen');
            end

            switch obj.figure_Main.SelectionType
                case 'extend'
                    % User clicked event marker with shift held down

                    % Clear previously highlighted event
                    obj.settings.ActiveEventNum = [];
                    obj.settings.ActiveEventPartNum = [];
                    obj.settings.ActiveEventSourceIdx = [];

                    % Delete highlighted event markers
                    delete(obj.ActiveEventCursors);

                    % Toggle whether or not the clicked event is selected
                    for eventPartNum = 1:size(obj.dbase.EventIsSelected{eventSourceIdx}, 1)
                        obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(eventNum) = ~obj.dbase.EventIsSelected{eventSourceIdx}{eventPartNum, filenum}(eventNum);
                    end

                    % Update display
                    obj.UpdateAnythingShowingEventSource(eventSourceIdx);

                case 'normal'
                    obj.SetActiveEventDisplay(eventNum, eventPartNum, eventSourceIdx);
            end

        end

        function EventPartDisplayClick(obj, hObject, event)
            % Handle a click on one of the event part display submenu
            % (R click on channel axes => Events => Display => click on event part)

            if strcmp(hObject.Checked,'on')
                hObject.Checked = 'off';
            else
                hObject.Checked = 'on';
            end

            if hObject.Parent==obj.menu_EventsDisplay1
                obj.UpdateChannelEventDisplay(1);
            else
                obj.UpdateChannelEventDisplay(2);
            end

        end
        function click_eventwave(obj, eventWaveHandle, event)
            newActiveEventNum = find(obj.EventWaveHandles==eventWaveHandle);
            newActiveEventPart = obj.GetEventViewerEventPartIdx();
            newEventSourceIdx = obj.GetEventViewerEventSourceIdx();

            if strcmp(obj.figure_Main.SelectionType,'normal')
                obj.SetActiveEventDisplay(newActiveEventNum, newActiveEventPart, newEventSourceIdx);
            elseif strcmp(obj.figure_Main.SelectionType,'extend')
                eventWaveHandle.XData = [];
                eventWaveHandle.YData = [];
                hold(obj.axes_Events, 'on');
                % ???
                obj.EventWaveHandles(obj.settings.ActiveEventNum) = plot(obj.axes_Events, mean(xlim(obj.axes_Events)),mean(ylim(obj.axes_Events)),'w.');
                hold(obj.axes_Events, 'off');
                obj.UnselectEvents(obj.settings.ActiveEventNum);
                delete(eventWaveHandle);
            end

        end
        function unselect_event(obj, hObject, event)

            obj.SetEventDisplayActiveState(obj.settings.ActiveEventNum, obj.settings.ActiveEventPartNum, eventSourceIdx, activeState);

            obj.settings.ActiveEventNum = [];
            obj.settings.ActiveEventPartNum = [];


            delete(obj.ActiveEventCursors);
            delete(findobj('Parent',obj.axes_Events,'LineWidth',2));
        end

        function click_eventaxes(obj, hObject, event)
            % Handle clicks on event viewer axes

            if strcmp(obj.figure_Main.SelectionType,'normal')
                % Left click
                obj.axes_Events.Units = 'pixels';
                obj.axes_Events.Parent.Units = 'pixels';
                obj.figure_Main.Units = 'pixels';
                rect = rbbox;

                if rect(3)>0 && rect(4)>0
                    % Left click and drag
                    pos = obj.axes_Events.Position;
                    pospan = obj.axes_Events.Parent.Position;
                    xl = xlim(obj.axes_Events);
                    yl = ylim(obj.axes_Events);

                    rect(1) = xl(1)+(rect(1)-pos(1)-pospan(1))/pos(3)*(xl(2)-xl(1));
                    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
                    rect(2) = yl(1)+(rect(2)-pos(2)-pospan(2))/pos(4)*(yl(2)-yl(1));
                    rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

                    xlim(obj.axes_Events, [rect(1) rect(1)+rect(3)]);
                    ylim(obj.axes_Events, [rect(2) rect(2)+rect(4)]);
                end

                obj.figure_Main.Units = 'normalized';
                obj.axes_Events.Parent.Units = 'normalized';
                obj.axes_Events.Units = 'normalized';

            elseif strcmp(obj.figure_Main.SelectionType,'open')
                % Double click
                axis(obj.axes_Events, 'tight');
                yl = ylim(obj.axes_Events);
                ylim(obj.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
                if obj.menu_DisplayFeatures.Checked
                    xl = xlim(obj.axes_Events);
                    xlim(obj.axes_Events, [mean(xl)+(xl(1)-mean(xl))*1.1 mean(xl)+(xl(2)-mean(xl))*1.1]);
                end
                if obj.menu_AutoApplyYLim.Checked
                    if obj.menu_DisplayValues.Checked
                        % UPDATE THIS
        %                 if obj.menu_AnalyzeTop.Checked && obj.menu_AutoLimits1.Checked
        %                     obj.axes_Channel1.YLim = obj.axes_Events.YLim;
        %                 elseif obj.menu_AutoLimits2.Checked
        %                     obj.axes_Channel2.YLim = obj.axes_Events.YLim;
        %                 end
                    end
                end

            elseif strcmp(obj.figure_Main.SelectionType,'extend')
                % Shift-click
                obj.SaveState();

                obj.axes_Events.Units = 'pixels';
                obj.axes_Events.Parent.Units = 'pixels';
                obj.figure_Main.Units = 'pixels';

                % User defines a rectangle such that any waves that pass through
                % the rectangle get de-selected
                rect = rbbox;

                pos = obj.axes_Events.Position;
                pospan = obj.axes_Events.Parent.Position;
                obj.figure_Main.Units = 'normalized';
                obj.axes_Events.Parent.Units = 'normalized';
                obj.axes_Events.Units = 'normalized';
                xl = xlim(obj.axes_Events);
                yl = ylim(obj.axes_Events);

                x1 = xl(1)+(rect(1)-pos(1)-pospan(1))/pos(3)*(xl(2)-xl(1));
                x2 = rect(3)/pos(3)*(xl(2)-xl(1)) + x1;
                y1 = yl(1)+(rect(2)-pos(2)-pospan(2))/pos(4)*(yl(2)-yl(1));
                y2 = rect(4)/pos(4)*(yl(2)-yl(1)) + y1;

                % Determine which event numbers to delete
                eventNums = [];
                for eventNum = 1:length(obj.EventWaveHandles)
                    if isgraphics(obj.EventWaveHandles(eventNum))
                        xs = obj.EventWaveHandles(eventNum).XData;
                        ys = obj.EventWaveHandles(eventNum).YData;
                        isin = find(xs>x1 & xs<x2 & ys>y1 & ys<y2, 1);
                        if ~isempty(isin)
                            eventNums = [eventNums eventNum];
                        end
                    end
                end

                if ~isempty(eventNums)
                    % Deselect the events that pass through the rectangle
                    obj.UnselectEvents(eventNums);
                end
            end

        end

        function HandleAuxiliarySoundSourceClick(obj, src, event)
            % Handle a click on an auxiliary sound source menu

            src.Checked = ~src.Checked;

            obj.eg_PlotSonogram();

            obj.eg_Overlay();

        end
        % --- Executes on selection change in popup_SoundSource.
        function popup_SoundSource_Callback(obj, hObject, event)

            % Handle a user change of the "Sound source" popup menu.
            % This menu controls the obj.settings.SoundChannel variable, which determines
            % which channel is used for displaying the spectrogram etc.
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            sourceIndices = obj.popup_SoundSource.UserData;
            idx = obj.popup_SoundSource.Value;
            obj.settings.SoundChannel = sourceIndices{idx};

            if strcmp(obj.settings.SoundChannel, 'calculated')
                % Allow user to input expression for calculated sound channel
                expression = inputdlg('Enter expression for calculated channel, using ''sound'', ''chan1'', ''chan2'', etc. as variables.', 'Input calculated channel expression', 1, {obj.settings.SoundExpression});

                if isempty(expression) || isempty(strtrim(expression{1}))
                    % User did not provide an expression - default to normal sound
                    % channel.
                    obj.settings.SoundChannel = sourceIndices{1};
                    obj.settings.SoundExpression = '';
                else
                    obj.settings.SoundExpression = expression{1};
                end
            end

            obj.LoadFile();

        end

        % --- Executes on selection change in popup_EventListData.
        function popup_EventListData_Callback(obj, hObject, event)

            obj.UpdateEventViewer();

        end

        function context_EventListAlign_Callback(obj, hObject, eventdata)

        end
        function EventViewerSourceToTopAxes_Callback(obj, hObject, eventdata)
            % Display currently selected event viewer event source in the top channel
            % axes

            eventSourceIdx = obj.GetEventViewerEventSourceIdx();
            obj.setChannelAxesEventSource(1, eventSourceIdx);


        end
        function EventViewerSourceToBottomAxes_Callback(obj, hObject, eventdata)
            % Display currently selected event viewer event source in the bottom channel
            % axes

            eventSourceIdx = obj.GetEventViewerEventSourceIdx();
            obj.setChannelAxesEventSource(2, eventSourceIdx);

        end

        function setChannelAxesEventSource(obj, axnum, eventSourceIdx)
            if isempty(eventSourceIdx)
                obj.popup_Channel(axnum).Value = 1;
            else
                [channelNum, filterName, eventDetectorName, eventParameters, ...
                    filterParameters, ~, ~] = ...
                    obj.GetEventSourceInfo(eventSourceIdx);
                channelName = electro_gui.channelNumToName(channelNum);
                obj.setSelectedChannel(axnum, channelName);
                obj.setSelectedFilter(axnum, filterName);
                obj.setSelectedEventDetector(axnum, eventDetectorName);
                obj.settings.ChannelAxesEventParams{axnum} = eventParameters;
                obj.settings.ChannelAxesFunctionParams{axnum} = filterParameters;
            end

            obj.eg_LoadChannel(axnum);


        end
        function menu_File_Callback(obj, hObject, eventdata)

        end
        function file_New_Callback(obj, hObject, eventdata)
            obj.eg_NewDbase();


        end
        function file_Open_Callback(obj, hObject, eventdata)
            obj.OpenDbase();


        end
        function file_Save_Callback(obj, hObject, eventdata)
            obj.SaveDbase();


        end
        function help_ControlsHelp_Callback(obj, hObject, eventdata)
            msgbox(electro_gui.HelpText(), 'electro_gui info and help:');
        end
        function menu_Playback_Callback(obj, hObject, eventdata)

        end
        function menu_PlaySound_Callback(obj, hObject, eventdata)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            snd = obj.GenerateSound('snd');
            obj.progress_play(snd);

        end
        function menu_PlayMix_Callback(obj, hObject, eventdata)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            snd = obj.GenerateSound('mix');
            obj.progress_play(snd);

        end
        function playback_SoundInMix_Callback(obj, hObject, eventdata)

        end
        function playback_TopInMix_Callback(obj, hObject, eventdata)

        end
        function playback_BottomInMix_Callback(obj, hObject, eventdata)

        end
        function playback_Weights_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Sound','Top plot','Bottom plot'},'Sound weights',1,{num2str(obj.SoundWeights(1)),num2str(obj.SoundWeights(2)),num2str(obj.SoundWeights(3))});
            if isempty(answer)
                return
            end
            obj.SoundWeights = [str2double(answer{1}), str2double(answer{2}), str2double(answer{3})];


        end
        function playback_Clippers_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Top plot','Bottom plot'},'Sound clippers',1,{num2str(obj.SoundClippers(1)),num2str(obj.SoundClippers(2))});
            if isempty(answer)
                return
            end
            obj.SoundClippers = [str2double(answer{1}), str2double(answer{2})];


        end
        function playback_Speed_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Playback speed (relative to normal)'},'Play speed',1,{num2str(obj.SoundSpeed)});
            if isempty(answer)
                return
            end
            obj.SoundSpeed = str2double(answer{1});


        end
        function playback_Reverse_Callback(obj, hObject, eventdata)
            if ~obj.playback_Reverse.Checked
                obj.playback_Reverse.Checked = 'on';
            else
                obj.playback_Reverse.Checked = 'off';
            end


        end
        function playback_FilteredSound_Callback(obj, hObject, eventdata)
            if obj.playback_FilteredSound.Checked
                obj.playback_FilteredSound.Checked = 'off';
            else
                obj.playback_FilteredSound.Checked = 'on';
            end


        end
        function playback_ProgressBarColor_Callback(obj, hObject, eventdata)
            selectedColor = uisetcolor(obj.ProgressBarColor, 'Select color');
            obj.ProgressBarColor = selectedColor;


        end
        function playback_animation_SoundWave_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);


        end
        function playback_animation_Sonogram_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);


        end
        function ChangeProgress(obj, hObject)
            if strcmp(obj.Checked,'off')
                hObject.Checked = 'on';
            else
                hObject.Checked = 'off';
            end

        end
        function playback_animation_Segments_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);


        end
        function playback_animation_SoundAmplitude_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);


        end
        function playback_animation_TopPlot_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);


        end
        function playback_animation_BottomPlot_Callback(obj, hObject, eventdata)
            obj.ChangeProgress(hObject);



        end
        function menu_Export_Callback(obj, hObject, eventdata)
        end
        function action_Export_Callback(obj, hObject, eventdata)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            txtexp = text(mean(xlim(obj.axes_Sonogram)),mean(ylim(obj.axes_Sonogram)),'Exporting...',...
                'HorizontalAlignment','center','Color','r','backgroundcolor',[1 1 1],'fontsize',14);
            drawnow

            tempFilename = 'eg_temp.wav';

            %%%

            obj.UpdateFilteredSound();

            exportAs = getMenuGroupValue(obj.menu_ExportAs.Children');
            exportTo = getMenuGroupValue(obj.menu_ExportTo.Children');

            switch exportAs
                case 'Segments'
                    path = uigetdir(obj.tempSettings.lastDirectory, 'Directory for segments');
                    if ~ischar(path)
                        delete(txtexp)
                        return
                    end
                    obj.dbase.PathName = path;
                    obj.tempSettings.lastDirectory = path;
                    obj.updateTempFile();

                    filenum = electro_gui.getCurrentFileNum(obj.settings);

                    if isfield(obj.settings, 'DefaultLabels')
                        labels = obj.settings.DefaultLabels;
                    else
                        labels = [];
                        for c = 1:length(obj.dbase.SegmentTitles{filenum})
                            labels = [labels obj.dbase.SegmentTitles{filenum}{c}];
                        end
                        if ~isempty(labels)
                            labels = unique(labels);
                        end
                        labels = ['''''' labels];
                    end

                    answer = inputdlg({'List of labels to export (leave empty for all segments, '''' = unlabeled)','File format'},'Export segments',1,{labels,obj.SegmentFileFormat});
                    if isempty(answer)
                        delete(txtexp)
                        return
                    end
                    newLabel = answer{1};
                    obj.SegmentFileFormat = answer{2};

                    if ~strcmp(labels,newLabel)
                        obj.DefaultLabels = newLabel;
                    end
                    if isempty(newLabel)
                        obj.rmfield('DefaultLabels');
                    end

                    dtm = datetime(obj.text_DateAndTime.String);
                    dtm.Format = 'yyyymmdd';
                    sd = string(dtm);
                    dtm.Format = 'HHMMSS';
                    st = string(dtm);
                    [~,name,~] = fileparts(obj.text_FileName.String);
                    sf = name;
                    for c = 1:length(obj.dbase.SegmentTitles{filenum})
                        if ~isempty(strfind(newLabel,obj.dbase.SegmentTitles{filenum}{c})) || isempty(newLabel) || (isempty(obj.dbase.SegmentTitles{filenum}{c}) && contains(newLabel,''''''))
                            str = obj.SegmentFileFormat;
                            f = strfind(str,'\d');
                            for j = f
                                str = [str(1:j-1) sd str(j+2:end)];
                            end
                            f = strfind(str,'\t');
                            for j = f
                                str = [str(1:j-1) st str(j+2:end)];
                            end
                            f = strfind(str,'\f');
                            for j = f
                                str = [str(1:j-1) sf str(j+2:end)];
                            end
                            f = strfind(str,'\l');
                            for j = f
                                str = [str(1:j-1) obj.dbase.SegmentTitles{filenum}{c} str(j+2:end)];
                            end
                            f = strfind(str,'\i');
                            for j = f
                                num = num2str(str(j+2));
                                if num>0
                                    indx = num2str(c,['%0.' num2str(num) 'd']);
                                else
                                    indx = num2str(c);
                                end
                                str = [str(1:j-1) indx str(j+3:end)];
                            end
                            f = strfind(str,'\n');
                            for j = f
                                num = num2str(str(j+2));
                                if num>0
                                    indx = num2str(filenum,['%0.' num2str(num) 'd']);
                                else
                                    indx = num2str(filenum);
                                end
                                str = [str(1:j-1) indx str(j+3:end)];
                            end

                            wav = obj.filtered_sound(obj.dbase.SegmentTimes{filenum}(c,1):obj.dbase.SegmentTimes{filenum}(c,2));

                            audiowrite(fullfile(path, [str, '.wav']), wav, obj.dbase.Fs, 'BitsPerSample', 16);
                        end
                    end
                case 'Sonogram'
                    if strcmp(exportTo, 'File')
                        [~, name, ~] = fileparts(obj.text_FileName.String);
                        [file, path] = uiputfile([obj.dbase.PathName '\' name '.jpg'],'Save image');
                        if ~ischar(file)
                            delete(txtexp)
                            return
                        end
                        obj.dbase.PathName = path;
                    end
                    xl = obj.axes_Sonogram.XLim;
                    yl = obj.axes_Sonogram.YLim;
                    fig = figure();
                    set(fig,'Visible','off','Units','pixels');
                    pos = get(fig,'Position');
                    pos(3) = obj.ExportSonogramResolution*obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
                    pos(4) = obj.ExportSonogramResolution*obj.settings.ExportSonogramHeight;
                    fig.Position = pos;
                    subplot('Position',[0 0 1 1]);
                    hold on
                    if obj.settings.ExportReplotSonogram == 0
                        ch = findobj('Parent',obj.axes_Sonogram,'type',image);
                        for c = 1:length(ch)
                            if ch(c) ~= txtexp
                                x = ch(c).XData;
                                y = ch(c).YData;
                                m = ch(c).CData;
                                f = find(x>=xl(1) & x<=xl(2));
                                g = find(y>=yl(1) & y<=yl(2));
                                imagesc(x(f),y(g),m(g,f));
                            end
                        end
                    else
                        xlim(xl);
                        ylim(yl);
                        xlp = round(xl*obj.dbase.Fs);
                        if xlp(1)<1; xlp(1) = 1; end

                        numSamples = obj.eg_GetSamplingInfo();

                        if xlp(2)>numSamples
                            xlp(2) = numSamples;
                        end
                        for c = 1:length(obj.menu_Algorithm)
                            if obj.menu_Algorithm(c).Checked
                                alg = obj.menu_Algorithm(c).Label;
                            end
                        end
                        electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, obj.axes_Sonogram, ...
                            obj.filtered_sound(xlp(1):xlp(2)), obj.dbase.Fs, obj.settings.SonogramParams);
                        obj.axes_Sonogram.YDir = 'normal';
                        obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope;
                        obj.settings.DerivativeSlope = 0;
                        obj.SetSonogramColors();
                    end
                    cl = obj.axes_Sonogram.CLim;
                    obj.axes_Sonogram.CLim = cl;
                    col = obj.figure_Main.Colormap;
                    obj.figure_Main.Colormap = col;
                    axis tight;
                    axis off;


                case 'Current sound'
                    wav = obj.GenerateSound('snd');
                    fs = obj.dbase.Fs * obj.SoundSpeed;

                case 'Sound mix'
                    wav = obj.GenerateSound('mix');
                    fs = obj.dbase.Fs * obj.SoundSpeed;

                case 'Events'
                    switch exportTo
                        case 'MATLAB'
                            fig = figure();
                            ax = axes(fig);
                            ch = obj.axes_Events.Children;
                            xs = [];
                            ys = [];
                            for c = length(ch):-1:1
                                x = ch(c).XData;
                                y = ch(c).YData;
                                col = ch(c).Color;
                                ls = ch(c).LineStyle;
                                lw = ch(c).LineWidth;
                                ma = ch(c).Marker;
                                ms = ch(c).MarkerSize;
                                mf = ch(c).MarkerFaceColor;
                                me = ch(c).MarkerEdgeColor;
                                plot(ax, x,y,'Color',col,'LineStyle',ls,'LineWidth',lw,'Marker',ma,'MarkerSize',ms,'MarkerFaceColor',mf,'MarkerEdgeColor',me);
                                hold(ax, 'on');
                                if obj.menu_DisplayFeatures.Checked && sum(col==[1 0 0])~=3
                                    xs = [xs x];
                                    ys = [ys y];
                                end
                            end

                            xl = obj.axes_Events.XLim;
                            yl = obj.axes_Events.YLim;
                            xlabel = obj.axes_Events.XLabel.String;
                            ylabel = obj.axes_Events.YLabel.String;
                            str = {};
                            if obj.menu_DisplayFeatures.Checked
                                xs = xs(xs>=xl(1) & xs<=xl(2));
                                ys = ys(ys>=yl(1) & ys<=yl(2));
                                str{1} = ['N = ' num2str(length(xs))];
                                str{2} = ['Mean ' xlabel ' = ' num2str(mean(xs))];
                                str{3} = ['Stdev ' xlabel ' = ' num2str(std(xs))];
                                str{4} = ['Mean ' ylabel ' = ' num2str(mean(ys))];
                                str{5} = ['Stdev ' ylabel ' = ' num2str(std(ys))];
                                txt = text(xl(1),yl(2),str);
                                txt.HorizontalAlignment = 'Left';
                                txt.VerticalAlignment = 'top';
                                txt.FontSize = 8;
                            end
                            xlabel(ax, xlabel);
                            ylabel(ax, ylabel);
                            xlim(ax, xl);
                            ylim(ax, yl);
                            box(ax, 'off');
                        case 'Clipboard'
                            if obj.menu_DisplayFeatures.Checked
                                ch = obj.axes_Events.Children;
                                xs = [];
                                ys = [];
                                for c = length(ch):-1:1
                                    x = ch(c).XData;
                                    y = ch(c).YData;
                                    col = ch(c).Color;
                                    if sum(col==[1 0 0])~=3
                                        xs = [xs x];
                                        ys = [ys y];
                                    end
                                end
                                str = [num2str(length(xs)) char(9) num2str(mean(xs)) char(9) num2str(std(xs)) char(9) num2str(mean(ys)) char(9) num2str(std(ys))];
                                clipboard('copy',str);
                            else
                                errordlg('Must be in the Display->Features mode!','Error');
                            end
                    end

                    delete(txtexp)
                    return
            end


            %%%
            switch exportTo
                case 'MATLAB'
                    switch exportAs
                        case 'Sonogram'
                            fig.Units = 'inches';
                            pos = fig.Position;
                            pos(3) = obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
                            pos(4) = obj.settings.ExportSonogramHeight;
                            fig.Position = pos;
                            fig.Visible = 'on';
                        case 'Worksheet'
                            lst = obj.settings.WorksheetList;
                            used = obj.settings.WorksheetUsed;
                            widths = obj.settings.WorksheetWidths;

                            perpage = fix(0.001+(obj.settings.WorksheetHeight - 2*obj.settings.WorksheetMargin - obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight)/(obj.settings.ExportSonogramHeight + obj.settings.WorksheetVerticalInterval));
                            pagenum = fix((0:length(lst)-1)/perpage)+1;

                            for j = 1:max(pagenum)
                                fig = figure('Units','inches');
                                ud.Sounds = {};
                                ud.Fs = [];
                                bcg = axes('Position',[0 0 1 1],'Visible','off');
                                ps = fig.Position;
                                ps(3) = obj.settings.WorksheetWidth;
                                ps(4) = obj.settings.WorksheetHeight;
                                fig.Position = ps;
                                if obj.settings.WorksheetIncludeTitle == 1
                                    txt = text(bcg, obj.settings.WorksheetMargin/obj.settings.WorksheetWidth,(obj.settings.WorksheetHeight-obj.settings.WorksheetMargin)/obj.settings.WorksheetHeight,obj.settings.WorksheetTitle);
                                    txt.HorizontalAlignment = 'left';
                                    txt.VerticalAlignment = 'top';
                                    txt.FontSize = 14;
                                    txt = text(bcg, (obj.settings.WorksheetWidth-obj.settings.WorksheetMargin)/obj.settings.WorksheetWidth,(obj.settings.WorksheetHeight-obj.settings.WorksheetMargin)/obj.settings.WorksheetHeight,['Page ' num2str(j) '/' num2str(max(pagenum))]);
                                    txt.HorizontalAlignment = 'right';
                                    txt.VerticalAlignment = 'top';
                                    txt.FontSize = 14;
                                end
                                f = find(pagenum==j);
                                for c = 1:length(f)
                                    indx = f(c);
                                    for d = 1:length(lst{indx})
                                        ud.Sounds{end+1} = obj.settings.WorksheetSounds{lst{indx}(d)};
                                        ud.Fs(end+1) = obj.settings.WorksheetFs(lst{indx}(d));

                                        x = (obj.settings.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + obj.settings.WorksheetHorizontalInterval*(d-1);
                                        wd = widths(lst{indx}(d));
                                        y = obj.settings.WorksheetHeight - obj.settings.WorksheetMargin - obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight - obj.settings.WorksheetVerticalInterval*c - obj.settings.ExportSonogramHeight*c;
                                        ax = axes('Position',[x/obj.settings.WorksheetWidth y/obj.settings.WorksheetHeight wd/obj.settings.WorksheetWidth obj.settings.ExportSonogramHeight/obj.settings.WorksheetHeight]);
                                        hold(ax, 'on');
                                        for i = 1:length(obj.settings.WorksheetMs{lst{indx}(d)})
                                            p = obj.settings.WorksheetMs{lst{indx}(d)}{i};
                                            if size(p,3) == 1
                                                cl = obj.settings.WorksheetClim{lst{indx}(d)};
                                                p = (p-cl(1))/(cl(2)-cl(1));
                                                p(p<0)=0;
                                                p(p>1)=1;
                                                p = round(p*(size(obj.settings.WorksheetColormap{lst{indx}(d)},1)-1))+1;
                                                p1 = reshape(obj.settings.WorksheetColormap{lst{indx}(d)}(p,1),size(p));
                                                p2 = reshape(obj.settings.WorksheetColormap{lst{indx}(d)}(p,2),size(p));
                                                p3 = reshape(obj.settings.WorksheetColormap{lst{indx}(d)}(p,3),size(p));
                                                p = cat(3,p1,p2,p3);
                                            else
                                                ax.CLim = obj.settings.WorksheetClim{lst{indx}(d)};
                                                fig.Colormap = obj.settings.WorksheetColormap{lst{indx}(d)};
                                            end
                                            im = imagesc(ax, obj.settings.WorksheetXs{lst{indx}(d)}{i},obj.settings.WorksheetYs{lst{indx}(d)}{i},p);
                                            if obj.settings.ExportSonogramIncludeClip > 0
                                                im.ButtonDownFcn = ['ud=get(gcf,''UserData''); sound(ud.Sounds{' num2str(length(ud.Sounds)) '},ud.Fs(' num2str(length(ud.Fs)) '))'];
                                            end
                                        end
                                        xlim(ax, obj.settings.WorksheetXLims{lst{indx}(d)});
                                        ylim(ax, obj.settings.WorksheetYLims{lst{indx}(d)});
                                        axis(ax, 'off');
                                        if obj.settings.ExportSonogramIncludeLabel == 1
                                            fig.CurrentAxes = bcg;
                                            xText = (x+wd/2)/obj.settings.WorksheetWidth;
                                            yText = (y+obj.settings.ExportSonogramHeight)/obj.settings.WorksheetHeight;
                                            timestamp = char(datetime(obj.settings.WorksheetTimes(lst{indx}(d))));
                                            txt = text(ax, xText, yText, timestamp);
                                            txt.HorizontalAlignment = 'center';
                                            txt.VerticalAlignment = 'bottom';
                                        end
                                    end
                                end

                                if obj.settings.ExportSonogramIncludeClip > 0
                                    fig.UserData = ud;
                                end
                                fig.Units = 'pixels';
                                screen_size = get(0,'screensize');
                                fig_pos = fig.Position;
                                fig.Position = [(screen_size(3)-fig_pos(3))/2,(screen_size(4)-fig_pos(4))/2,fig_pos(3),fig_pos(4)];

                                fig.PaperOrientation = obj.settings.WorksheetOrientation;
                                fig.PaperPositionMode = 'auto';
                            end
                    end
                case 'Clipboard'
                    fig.Units = 'inches';
                    pos = fig.Position;
                    pos(3) = obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
                    pos(4) = obj.settings.ExportSonogramHeight;
                    fig.Position = pos;
                    fig.PaperPositionMode = 'manual';
                    fig.Renderer = 'painters'; %#ok<*FGREN>

                    print('-dmeta',['-f' num2str(fig)],['-r' num2str(obj.ExportSonogramResolution)]);
                    delete(fig)

                case 'File'
                    switch exportAs
                        case 'Sonogram'
                            fig.Units = 'inches';
                            pos = fig.Position;
                            pos(3) = obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
                            pos(4) = obj.settings.ExportSonogramHeight;
                            fig.Position = pos;
                            fig.PaperPositionMode = 'auto';

                            print('-djpeg',['-f' num2str(fig)],[path file],['-r' num2str(obj.ExportSonogramResolution)]);

                            delete(fig);

                        case {'Current sound', 'Sound mix'}
                            [~,name,~] = fileparts(obj.text_FileName.String);
                            [file, path] = uiputfile([obj.dbase.PathName '\' name '.wav'],'Save sound');
                            if ~ischar(file)
                                delete(txtexp)
                                return
                            end
                            obj.dbase.PathName = path;

                            audiowrite(fullfile(path, file), wav, obj.dbase.Fs, 'BitsPerSample', 16);
                    end

                case 'PowerPoint'
                    ppt = actxserver('PowerPoint.Application');
                    op = ppt.ActivePresentation;
                    slide_count = op.Slides.Count;
                    if slide_count>0
                        oldslide = ppt.ActiveWindow.View.Slide;
                        slide_count = int32(double(slide_count)+1);
                %         newslide = invoke(op.Slides,'Add',slide_count,'ppLayoutBlank');
                        newslide = invoke(op.Slides,'Add',slide_count,11); %mod by VG
                    else
                        slide_count = int32(double(slide_count)+1);
                %         newslide = invoke(op.Slides,'Add',slide_count,'ppLayoutBlank');
                        newslide = invoke(op.Slides,'Add',slide_count,11); %mod by VG
                        oldslide = ppt.ActiveWindow.View.Slide;
                    end

                    switch exportAs
                        case 'Sonogram'
                            set(fig,'PaperPositionMode','manual','Renderer','painters')
                            print('-dmeta',['-f' num2str(fig)]);
                            pic = invoke(newslide.Shapes,'PasteSpecial',2);
                            ug = invoke(pic,'Ungroup');
                            ug.Fill.Visible = 'msoFalse';
                            set(ug,'Height',72*obj.settings.ExportSonogramHeight,'Width',72*obj.settings.ExportSonogramWidth*(xl(2)-xl(1)));

                            if obj.settings.ExportSonogramIncludeClip > 0
                                wav = obj.GenerateSound('snd');
                                fs = obj.dbase.Fs * obj.SoundSpeed;

                                audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);

                                snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                                snd.Left = ug.Left;
                                snd.Top = ug.Top;
                                mt = dir(f.UserData.ax);
                                delete(mt(1).name);
                            end

                            if obj.settings.ExportSonogramIncludeLabel == 1
                                txt = obj.addWorksheetTextBox(newslide, obj.text_DateAndTime.String, 8, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
                                txt.Left = ug.Left+ug.Width/2-txt.Width/2;
                                txt.Top = ug.Top-txt.Height;
                            end

                            if newslide.Shapes.Range.Count>1
                                invoke(newslide.Shapes.Range,'Group');
                            end
                            invoke(newslide.Shapes.Range,'Cut');
                            pic = invoke(oldslide.Shapes,'Paste');
                            slideHeight = op.PageSetup.SlideHeight;
                            slideWidth = op.PageSetup.SlideWidth;
                            pic.Top = slideHeight/2-pic.Height/2;
                            pic.Left = slideWidth/2-pic.Width/2;

                            delete(fig);

                            if newslide.SlideIndex~=oldslide.SlideIndex
                                invoke(newslide,'Delete');
                            end

                        case {'Current sound', 'Sound mix'}
                            audiowrite(tempFilename, wav, fs, 'BitsPerSample', 16);
                            snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                            mt = dir(tempFilename);
                            delete(mt(1).name);

                            if obj.settings.ExportSonogramIncludeLabel == 1
                                txt = obj.addWorksheetTextBox(newslide,  obj.text_DateAndTime.String, 8, snd.Left+snd.Width, [], [], 'msoAnchorMiddle');
                                txt.Top = snd.Top+snd.Height/2-txt.Height/2;
                            end

                            if newslide.Shapes.Range.Count>1
                                invoke(newslide.Shapes.Range,'Group');
                            end
                            invoke(newslide.Shapes.Range, 'Cut');
                            invoke(oldslide.Shapes, 'Paste');

                            if newslide.SlideIndex~=oldslide.SlideIndex
                                invoke(newslide,'Delete');
                            end


                        case 'Worksheet'
                            ppt = actxserver('PowerPoint.Application');
                            op = ppt.ActivePresentation;

                            offx = (op.PageSetup.SlideWidth-72*obj.settings.WorksheetWidth)/2;
                            offy = (op.PageSetup.SlideHeight-72*obj.settings.WorksheetHeight)/2;

                            lst = obj.settings.WorksheetList;
                            used = obj.settings.WorksheetUsed;
                            widths = obj.settings.WorksheetWidths;

                            perpage = fix(0.001+(obj.settings.WorksheetHeight - 2*obj.settings.WorksheetMargin - obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight)/(obj.settings.ExportSonogramHeight + obj.settings.WorksheetVerticalInterval));
                            pagenum = fix((0:length(lst)-1)/perpage)+1;


                            fig = figure('Visible','off','Units','pixels');
                            set(fig,'PaperPositionMode','manual','Renderer','painters');
                            ax = subplot('Position',[0 0 1 1]);
                            axis(ax, 'off');
                            for j = 1:max(pagenum)
                                if j > 1
                                    slide_count = op.Slides.Count;
                                    newslide = invoke(op.Slides,'Add',slide_count+1,'ppLayoutBlank');
                                end
                                if obj.settings.WorksheetIncludeTitle == 1
                                    obj.addWorksheetTextBox(newslide, obj.settings.WorksheetTitle, 14, 72*obj.settings.WorksheetMargin+offx, 72*obj.settings.WorksheetMargin+offy, [], 'msoAnchorTop');
                                    txt = obj.addWorksheetTextBox(newslide, ['Page ' num2str(j) '/' num2str(max(pagenum))], 14, [], 72*obj.settings.WorksheetMargin+offy, [], 'msoAnchorTop');
                                    txt.Left = 72*(obj.settings.WorksheetWidth-obj.settings.WorksheetMargin-txt.Width+offx);
                                end

                                f = find(pagenum==j);
                                for c = 1:length(f)
                                    indx = f(c);

                                    for d = 1:length(lst{indx})
                                        cla(ax);
                                        hold(ax, 'on');
                                        ps = fig.Position;
                                        ps(3) = obj.ExportSonogramResolution*obj.settings.ExportSonogramWidth*(obj.settings.WorksheetXLims{lst{indx}(d)}(2)-obj.settings.WorksheetXLims{lst{indx}(d)}(1));
                                        ps(4) = obj.ExportSonogramResolution*obj.settings.ExportSonogramHeight;
                                        fig.Position = ps;

                                        x = (obj.settings.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + obj.settings.WorksheetHorizontalInterval*(d-1);
                                        wd = widths(lst{indx}(d));
                                        y = obj.settings.WorksheetMargin + obj.settings.WorksheetIncludeTitle*obj.settings.WorksheetTitleHeight + obj.settings.WorksheetVerticalInterval*(c-1) + obj.settings.ExportSonogramHeight*(c-1);

                                        for i = 1:length(obj.settings.WorksheetMs{lst{indx}(d)})
                                            p = obj.settings.WorksheetMs{lst{indx}(d)}{i};
                                            imagesc(ax, obj.settings.WorksheetXs{lst{indx}(d)}{i},obj.settings.WorksheetYs{lst{indx}(d)}{i},p);
                                            ax.CLim = obj.settings.WorksheetClim{lst{indx}(d)};
                                            fig.Colormap = obj.settings.WorksheetColormap{lst{indx}(d)};
                                        end
                                        xlim(ax, obj.settings.WorksheetXLims{lst{indx}(d)});
                                        ylim(ax, obj.settings.WorksheetYLims{lst{indx}(d)});

                                        print('-dmeta',['-f' num2str(fig)]);
                                        pic = invoke(newslide.Shapes,'PasteSpecial',2);
                                        ug = invoke(pic,'Ungroup');
                                        ug.Fill.Visible = 'msoFalse';
                                        ug.Height = 72*obj.settings.ExportSonogramHeight;
                                        ug.Width = 72*obj.settings.ExportSonogramWidth*(obj.settings.WorksheetXLims{lst{indx}(d)}(2)-obj.settings.WorksheetXLims{lst{indx}(d)}(1));
                                        ug.Left = 72*x+offx;
                                        ug.Top = 72*(y+obj.settings.WorksheetVerticalInterval)+offy;

                                        if obj.settings.ExportSonogramIncludeLabel == 1
                                            txt = obj.addWorksheetTextBox(newslide, string(datetime(obj.settings.WorksheetTimes(lst{indx}(d)))), 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
                                            txt.Left = 72*(x+wd/2-txt.Width/2+offx);
                                            txt.Top = 72*(y+obj.settings.WorksheetVerticalInterval-txt.Height+offy);
                                        end

                                        if obj.settings.ExportSonogramIncludeClip > 0
                                            wav = obj.settings.WorksheetSounds{lst{indx}(d)};
                                            fs = obj.settings.WorksheetFs(lst{indx}(d));
                                            audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);
                                            snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                                            snd.Left = ug.Left;
                                            snd.Top = ug.Top;
                                            mt = dir(f.UserData.ax);
                                            delete(mt(1).name);
                                        end
                                    end
                                end
                            end
                            delete(fig);

                        case 'Figure'
                            obj.settings.template = obj.export_options_EditFigureTemplate.UserData;

                            ppt = actxserver('PowerPoint.Application');
                            op = ppt.ActivePresentation;

                            fig = figure('Visible','off','Units','pixels');
                            fig.PaperPositionMode = 'manual';
                            fig.Renderer = 'painters';
                            ax = subplot('Position',[0 0 1 1]);

                            xl = obj.axes_Sonogram.XLim;

                            offx = (op.PageSetup.SlideWidth-72*obj.settings.ExportSonogramWidth*(xl(2)-xl(1)))/2;
                            offy = (op.PageSetup.SlideHeight-72*(sum(obj.settings.template.Height)+sum(obj.settings.template.Interval(1:end-1))))/2;

                            sound_inserted = 0;

                            ch = obj.menu_export_options_Animation.Children;
                            progbar = [];
                            axs = [obj.axes_Channel2 obj.axes_Channel1 obj.axes_Amplitude obj.axes_Segments obj.axes_Sonogram obj.axes_Sound];
                            for c = 1:length(ch)
                                if ch(c).Checked && axs(c).Visible
                                    progbar = [progbar c];
                                end
                            end
                            ycoord = zeros(0,4);
                            coords = {};

                            for c = 1:length(obj.settings.template.Plot)
                                ps = fig.Position;
                                ps(3) = obj.ExportSonogramResolution*obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
                                ps(4) = obj.ExportSonogramResolution*obj.settings.template.Height(c);
                                fig.Position = ps;

                                cla(ax);

                                include_progbar = 0;

                                switch obj.settings.template.Plot{c}

                                    case 'Sonogram'
                                        if ~isempty(find(progbar==5, 1))
                                            include_progbar = 1;
                                        end

                                        yl = obj.axes_Sonogram.YLim;

                                        hold(ax, 'on');
                                        if obj.settings.ExportReplotSonogram == 0
                                            ch = findobj('Parent',obj.axes_Sonogram,'type','image');
                                            for j = 1:length(ch)
                                                if ch(j) ~= txtexp
                                                    x = ch(j).XData;
                                                    y = ch(j).YData;
                                                    m = ch(j).CData;
                                                    f = find(x>=xl(1) & x<=xl(2));
                                                    g = find(y>=yl(1) & y<=yl(2));
                                                    imagesc(ax, x(f),y(g),m(g,f));
                                                end
                                            end
                                        else
                                            xlim(ax, xl);
                                            ylim(ax, yl);
                                            xlp = round(xl*obj.dbase.Fs);
                                            if xlp(1)<1; xlp(1) = 1; end
                                            numSamples = obj.eg_GetSamplingInfo();

                                            if xlp(2)>numSamples; xlp(2) = numSamples; end
                                            for j = 1:length(obj.menu_Algorithm)
                                                if obj.menu_Algorithm(j).Checked
                                                    alg = obj.menu_Algorithm(j).Label;
                                                end
                                            end
                                            electro_gui.eg_runPlugin(obj.plugins.spectrums, ...
                                                alg, ax, obj.filtered_sound(xlp(1):xlp(2)), ...
                                                obj.dbase.Fs, obj.settings.SonogramParams);
                                            ax.YDir = 'normal';
                                            obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope;
                                            obj.settings.DerivativeSlope = 0;
                                            obj.SetSonogramColors();
                                        end
                                        cl = obj.axes_Sonogram.CLim;
                                        ax.CLim = cl;
                                        col = obj.figure_Main.Colormap;
                                        fig.Colormap = col;
                                        axis(ax, 'tight');
                                        axis(ax, 'off');

                                    case 'Segments'
                                        if ~isempty(find(progbar==4, 1))
                                            include_progbar = 1;
                                        end

                                        st = obj.dbase.SegmentTimes{electro_gui.getCurrentFileNum(obj.settings)};
                                        sel = obj.dbase.SegmentIsSelected{electro_gui.getCurrentFileNum(obj.settings)};
                                        f = find(st(:,1)>xl(1)*obj.dbase.Fs & st(:,1)<xl(2)*obj.dbase.Fs);
                                        g = find(st(:,2)>xl(1)*obj.dbase.Fs & st(:,2)<xl(2)*obj.dbase.Fs);
                                        h = find(st(:,1)<xl(1)*obj.dbase.Fs & st(:,2)>xl(2)*obj.dbase.Fs);
                                        f = unique([f; g; h]);

                                        hold(ax, 'on');
                                        numSamples = obj.eg_GetSamplingInfo();

                                        xs = linspace(0, numSamples/obj.dbase.Fs, numSamples);
                                        for j = f'
                                            if sel(j)==1
                                                patch(xs([st(j,1) st(j,2) st(j,2) st(j,1)]),[0 0 1 1],obj.settings.SegmentSelectColor);
                                            end
                                        end

                                        ylim(ax, [0, 1]);
                                        axis(ax, 'off');

                                    case 'Segment labels'
                                        st = obj.dbase.SegmentTimes{electro_gui.getCurrentFileNum(obj.settings)};
                                        sel = obj.dbase.SegmentIsSelected{electro_gui.getCurrentFileNum(obj.settings)};
                                        lab = obj.dbase.SegmentTitles{electro_gui.getCurrentFileNum(obj.settings)};
                                        f = find(st(:,1)>xl(1)*obj.dbase.Fs & st(:,1)<xl(2)*obj.dbase.Fs);
                                        g = find(st(:,2)>xl(1)*obj.dbase.Fs & st(:,2)<xl(2)*obj.dbase.Fs);
                                        h = find(st(:,1)<xl(1)*obj.dbase.Fs & st(:,2)>xl(2)*obj.dbase.Fs);
                                        f = unique([f; g; h]);

                                        hold(ax, 'on');
                                        numSamples = obj.eg_GetSamplingInfo();

                                        xs = linspace(0, numSamples/obj.dbase.Fs, numSamples);
                                        for j = f'
                                            if sel(j)==1
                                                if ~isempty(lab{j})
                                                    txt = obj.addWorksheetTextBox(newslide, lab{j}, 8, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
                                                    txt.Left = offx+72*obj.settings.ExportSonogramWidth*mean(xs(st(j,:))-xl(1))-txt.Width/2;
                                                    txt.Top = offy+72*(sum(obj.settings.template.Interval(1:c-1)+sum(obj.settings.template.Height(1:c-1))));
                                                end
                                            end
                                        end

                                        axis(ax, 'off');

                                    case 'Amplitude'
                                        if ~isempty(find(progbar==3, 1))
                                            include_progbar = 1;
                                        end

                                        m = findobj('Parent',obj.axes_Amplitude,'LineStyle','-');
                                        x = m.XData;
                                        y = m.YData;
                                        col = m.Color;
                                        linewidth = m.LineWidth;
                                        f = find(x>=xl(1) & x<=xl(2));
                                        if sum(col==1)==3
                                            col = col-eps;
                                        end
                                        plot(ax, x(f),y(f),'Color',col);

                                        ylim(ax, obj.axes_Amplitude.YLim);
                                        ax.YDir = 'normal';
                                        axis(ax, 'off');

                                    case {'Top plot','Bottom plot'}
                                        if ~isempty(find(progbar==1, 1)) && strcmp(obj.settings.template.Plot{c},'Bottom plot')
                                            include_progbar = 1;
                                        end
                                        if ~isempty(find(progbar==2, 1)) && strcmp(obj.settings.template.Plot{c},'Top plot')
                                            include_progbar = 1;
                                        end

                                        if strcmp(obj.settings.template.Plot{c},'Top plot')
                                            axnum = 1;
                                        else
                                            axnum = 2;
                                        end

                                        m = findobj('Parent',obj.axes_Channel(axnum),'LineStyle','-');
                                        hold(ax, 'on')
                                        for j = 1:length(m)
                                            x = m(j).XData;
                                            y = m(j).YData;
                                            col = m(j).Color;
                                            linewidth = m(j).LineWidth;
                                            f = find(x>=xl(1) & x<=xl(2));
                                            if sum(col==1)==3
                                                col = col-eps;
                                            end
                                            plot(ax, x(f),y(f),'Color',col);
                                        end

                                        ylim(ax, obj.axes_Channel(axnum).YLim);
                                        ax.YDir = 'normal';
                                        axis(ax, 'off');

                                    case 'Sound wave'
                                        if ~isempty(find(progbar==6, 1))
                                            include_progbar = 1;
                                        end

                                        m = findobj('Parent',obj.axes_Sound,'LineStyle','-');
                                        hold(ax, 'on')
                                        for j = 1:length(m)
                                            x = m(j).XData;
                                            y = m(j).YData;
                                            f = find(x>=xl(1) & x<=xl(2));
                                            plot(ax, x(f),y(f),'b');
                                        end
                                        linewidth = 1;

                                        ylim(ax, obj.axes_Sound.YLim);
                                        ax.YDir = 'normal';
                                        axis(ax, 'off');
                                end

                                if obj.settings.template.AutoYLimits(c)==1
                                    axis tight;
                                end
                                yl = ylim;
                                xlim(xl);


                                if ~strcmp(obj.settings.template.Plot{c},'Segment labels')
                                    print('-dmeta',['-f' num2str(fig)]);
                                    pic = invoke(newslide.Shapes,'PasteSpecial',2);
                                    ug = invoke(pic,'Ungroup');
                                    ug.Height = 72*obj.settings.template.Height(c);
                                    ug.Width = 72*obj.settings.ExportSonogramWidth*(xl(2-xl(1)));
                                    ug.Left = offx;
                                    ug.Top = offy+72*(sum(obj.settings.template.Interval(1:c-1))+sum(obj.settings.template.Height(1:c-1)));

                                    switch obj.settings.template.YScaleType(c)
                                        case 0
                                            % no scale bar
                                        case 1 % scalebar
                                            approx = obj.ScalebarHeight/obj.settings.template.Height(c)*(yl(2)-yl(1));
                                            ord = floor(log10(approx));
                                            val = approx/10^ord;
                                            if ord == 0
                                                pres = [1 2 3 4 5 10];
                                            else
                                                pres = [1 2 2.5 3 4 5 10];
                                            end
                                            [~, fnd] = min(abs(pres-val));
                                            val = pres(fnd)*10^ord;
                                            sb_height = 72*val/(yl(2)-yl(1))*obj.settings.template.Height(c);

                                            unit = '';
                                            switch obj.settings.template.Plot{c}
                                                case 'Sonogram'
                                                    unit = ' kHz';
                                                    val = val/1000;
                                                case 'Amplitude'
                                                    txt = obj.axes_Amplitude.YLabel.String;
                                                    fnd2 = strfind(txt,')');
                                                    if ~isempty(fnd2)
                                                        fnd1 = strfind(txt(1:fnd2(end)),'(');
                                                        if ~isempty(fnd1)
                                                            unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                                        end
                                                    end
                                                case 'Top plot'
                                                    txt = obj.axes_Channel1.YLabel.String;
                                                    fnd2 = strfind(txt,')');
                                                    if ~isempty(fnd2)
                                                        fnd1 = strfind(txt(1:fnd2(end)),'(');
                                                        if ~isempty(fnd1)
                                                            unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                                        end
                                                    end
                                                case 'Bottom plot'
                                                    txt = obj.axes_Channel2.YLabel.String;
                                                    fnd2 = strfind(txt,')');
                                                    if ~isempty(fnd2)
                                                        fnd1 = strfind(txt(1:fnd2(end)),'(');
                                                        if ~isempty(fnd1)
                                                            unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                                        end
                                                    end
                                                case 'Sound wave'
                                                    unit = 'ADU';
                                            end

                                            sb_posy = ug.Top+0.5*ug.Height-0.5*sb_height;

                                            if obj.VerticalScalebarPosition <= 0
                                                sb_posx = offx + 72*obj.VerticalScalebarPosition;
                                            else
                                                sb_posx = offx + 72*(obj.settings.ExportSonogramWidth*(xl(2)-xl(1))+obj.VerticalScalebarPosition);
                                            end
                                            invoke(newslide.Shapes,'AddLine',sb_posx,sb_posy,sb_posx,sb_posy+sb_height);

                                            txt = obj.addWorksheetTextBox(newslide, [num2str(val) unit], 8, [], [], [], 'msoAnchorMiddle');
                                            if obj.VerticalScalebarPosition <= 0
                                                txt.Left = sb_posx-txt.Width-72*0.05;
                                                txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignRight';
                                            else
                                                txt.Left = sb_posx+72*0.05;
                                                txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignLeft';
                                            end
                                            txt.Top = ug.Top+0.5*ug.Height-0.5*txt.Height;

                                        case 2 % axis
                                            invoke(newslide.Shapes,'AddLine',offx,ug.Top,offx,ug.Top+ug.Height);
                                            fig_yscale = figure('Visible','off','Units','inches');
                                            ps = fig_yscale.Position;
                                            ps(4) = obj.settings.template.Height(c);
                                            fig_yscale.Position = ps;
                                            ax = subplot('Position',[0 0 1 1]);
                                            ylim(ax, [yl(1) yl(2)]);
                                            ytick = ax.YTick;
                                            delete(fig_yscale);

                                            switch obj.settings.template.Plot{c}
                                                case 'Sonogram'
                                                    str = obj.axes_Sonogram.YLabel.String;
                                                case 'Amplitude'
                                                    str = obj.axes_Amplitude.YLabel.String;
                                                case 'Top plot'
                                                    str = obj.axes_Channel1.YLabel.String;
                                                case 'Bottom plot'
                                                    str = obj.axes_Channel2.YLabel.String;
                                                case 'Sound wave'
                                                    str = 'Sound amplitude (ADU)';
                                            end

                                            mn = inf;
                                            for j = 1:length(ytick')
                                                tickpos = ug.Top+ug.Height-(ytick(j)-yl(1))/(yl(2)-yl(1))*ug.Height;
                                                invoke(newslide.Shapes,'AddLine',offx,tickpos,offx+72*0.02,tickpos);

                                                txt = obj.addWorksheetTextBox(newslide, num2str(ytick(j)), 8, [], [], [], 'msoAnchorMiddle', 'ppAlignRight');
                                                txt.Left = offx-txt.Width-72*0.02;
                                                txt.Top = tickpos-0.5*txt.Height;
                                                mn = min([mn, txt.Left]);
                                            end

                %                             if strcmp(obj.settings.template.Plot{c},'Sonogram')
                %                                 ytick = ytick/1000;
                %                             end

                                            obj.addWorksheetTextBox(newslide, str, 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom', 'ppAlignCenter', 270);
                                            txt.Left = mn-0.5*txt.Width-72*0.15;
                                            txt.Top = ug.Top+0.5*ug.Height-0.5*txt.Height;
                                    end

                                    if include_progbar == 1
                                        ycoord = [ycoord; ug.Left ug.Top ug.Width ug.Height];
                                        switch obj.settings.template.Plot{c}
                                            case {'Amplitude','Top plot','Bottom plot'}
                                                xs = (x(f)-xl(1))/(xl(2)-xl(1));
                                                ys = (y(f)-yl(1))/(yl(2)-yl(1));
                                                crd = [xs' ys'];
                                            case 'Sound wave'
                                                xs = (x(f)-xl(1))/(xl(2)-xl(1));
                                                ys = (y(f)-yl(1))/(yl(2)-yl(1));
                                                crd = [xs' abs(ys')];
                                            case 'Segments'
                                                crd = [];
                                                for j = f'
                                                    if sel(j)==1
                                                        crd = [crd; xs(st(j,1)) 0; xs(st(j,2)) 1];
                                                    end
                                                end
                                                crd = [xl(1) 0; crd; xl(2) 0];
                                                crd(:,1) = (crd(:,1)-xl(1))/(xl(2)-xl(1));
                                                crd(:,2) = (crd(:,2)-yl(1))/(yl(2)-yl(1));
                                            case 'Sonogram'
                                                ch = findobj('Parent',obj.axes_Sonogram,'type','image');
                                                crd = [];
                                                for j = 1:length(ch)
                                                    if ch(j) ~= txtexp
                                                        x = ch(j).XData;
                                                        y = ch(j).YData;
                                                        m = ch(j).CData;
                                                        f = find(x>=xl(1) & x<=xl(2));
                                                        g = find(y>=yl(1) & y<=yl(2));
                                                        if obj.SonogramFollowerPower == inf
                                                            [~, wh] = max(m(g,f),[],1);
                                                            crd = [crd; x(f)' y(g(wh))'];
                                                        else
                                                            crd = [crd; x(f)' ((y(g)*abs(m(g,f)).^obj.SonogramFollowerPower)./sum(abs(m(g,f)).^obj.SonogramFollowerPower,1))'];
                                                        end
                                                    end
                                                end
                                                crd(:,1) = (crd(:,1)-xl(1))/(xl(2)-xl(1));
                                                crd(:,2) = (crd(:,2)-yl(1))/(yl(2)-yl(1));
                                        end
                                        crd(:,1) = crd(:,1)*ycoord(end,3)/op.PageSetup.SlideWidth;
                                        crd(:,2) = -crd(:,2)*ycoord(end,4)/op.PageSetup.SlideHeight;
                                        crd = sortrows(crd);

                                        if obj.playback_Reverse.Checked
                                            crd(:,1) = flipud(crd(:,1))-crd(end,1);
                                            crd(:,2) = flipud(crd(:,2));
                                        end

                                        vals = [];
                                        if ~strcmp(obj.settings.template.Plot{c},'Segments')
                                            lst = linspace(crd(1,1),crd(end,1),round(ug.Width)*2);
                                            for j=1:length(lst)
                                                fnd = find(abs(crd(:,1)-lst(j))<abs(lst(end)-lst(1))/length(lst));
                                                [~, ind] = max(abs(crd(fnd,2)-mean(crd(:,2))));
                                                vals(j) = crd(fnd(ind),2);
                                            end
                                            crd = [crd(round(linspace(1,size(crd,1),length(lst))),1) vals'];
                                        end
                                        coords{end+1} = crd;
                                    end

                                    if strcmp(obj.settings.template.Plot{c},'Sonogram') && obj.settings.ExportSonogramIncludeClip > 0
                                        if obj.settings.ExportSonogramIncludeClip == 1
                                            wav = obj.GenerateSound('snd');
                                        else
                                            wav = obj.GenerateSound('mix');
                                        end
                                        fs = obj.dbase.Fs * obj.SoundSpeed;

                                        audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);

                                        snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                                        snd.Left = ug.Left;
                                        snd.Top = ug.Top;
                                        mt = dir(f.UserData.ax);
                                        delete(mt(1).name);
                                        sound_inserted = 1;
                                    end

                                    ug = invoke(ug,'Ungroup');
                                    if ~strcmp(obj.settings.template.Plot{c},'Segments')
                                        for j = 1:ug.Count
                                            if strcmp(ug.Item(j).Type,'msoAutoShape')
                                                invoke(ug.Item(j),'Delete');
                                            else
                                                if exist('LineWidth', 'var')
                                                    ug.Item(j).Line.Weight = linewidth;
                                                end
                                            end
                                        end
                                    end
                                end
                            end

                            if obj.settings.ExportSonogramIncludeLabel == 1
                                dt = datevec(obj.text_DateAndTime.String);
                                dt(6) = dt(6)+xl(1);
                                obj.addWorksheetTextBox(newslide, string(datetime(dt)), 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom', 'ppAlignCenter');
                                txt.Left = op.PageSetup.SlideWidth-txt.Width/2;
                                txt.Top = offy-txt.Height;
                            end

                            if sound_inserted == 0 && obj.settings.ExportSonogramIncludeClip > 0
                                if obj.settings.ExportSonogramIncludeClip == 1
                                    wav = obj.GenerateSound('snd');
                                else
                                    wav = obj.GenerateSound('mix');
                                end
                                fs = obj.dbase.Fs * obj.SoundSpeed;

                                audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);

                                snd = invoke(newslide.Shapes,'AddMediaObject',[pwd '\eg_temp.wav']);
                                snd.Left = offx;
                                snd.Top = offy;
                                mt = dir(f.UserData.ax);
                                delete(mt(1).name);
                            end

                            % Insert animation

                            if exist('snd', 'var')
                                anim = invoke(snd.ActionSettings,'Item',1);
                                anim.Action = 'ppActionNone';

                                seq = newslide.TimeLine;
                                seq = seq.InteractiveSequences;
                                seq = invoke(seq,'Item',1);
                                itm(1) = invoke(seq,'Item',1);

                                animopt = findobj('Parent',obj.menu_export_options_Animation,'Checked','on');
                                animopt = animopt.Label;

                                if ~strcmp(animopt,'None')
                                    for c = 1:size(ycoord,1)
                                        if obj.playback_Reverse.Checked
                                            ycoord(c,1) = ycoord(c,1)+ycoord(c,3);
                                            ycoord(c,3) = -ycoord(c,3);
                                        end

                                        col = obj.ProgressBarColor;
                                        col = 255*col(1) + 256*255*col(2) + 256^2*255*col(3);
                                        switch animopt
                                            case 'Progress bar'
                                                animline = invoke(newslide.Shapes,'Addline',ycoord(c,1),ycoord(c,2),ycoord(c,1),ycoord(c,2)+ycoord(c,4));
                                                animline.Line.Weight = 2;
                                                animline.Line.ForeColor.RGB = col;
                                            case 'Arrow above'
                                                animline = invoke(newslide.Shapes,'Addline',ycoord(c,1),ycoord(c,2),ycoord(c,1),ycoord(c,2)-15);
                                                animline.Line.BeginArrowheadStyle = 'msoArrowheadTriangle';
                                                animline.Line.BeginArrowheadWidth = 'msoArrowheadWidthMedium';
                                                animline.Line.BeginArrowheadLength = 'msoArrowheadLengthMedium';
                                                animline.Line.Weight = 2;
                                                animline.Line.ForeColor.RGB = col;
                                            case 'Arrow below'
                                                animline = invoke(newslide.Shapes,'Addline',ycoord(c,1),ycoord(c,2)+ycoord(c,4),ycoord(c,1),ycoord(c,2)+ycoord(c,4)+15);
                                                animline.Line.BeginArrowheadStyle = 'msoArrowheadTriangle';
                                                animline.Line.BeginArrowheadWidth = 'msoArrowheadWidthMedium';
                                                animline.Line.BeginArrowheadLength = 'msoArrowheadLengthMedium';
                                                animline.Line.Weight = 2;
                                                animline.Line.ForeColor.RGB = col;
                                            case 'Value follower'
                                                animline = invoke(newslide.Shapes,'Addshape',9,ycoord(c,1)-2,ycoord(c,2)+ycoord(c,4)-2,4,4);
                                                animline.Fill.Forecolor.RGB = col;
                                                animline.Line.Forecolor.RGB = col;
                                        end


                                        itm(end+1) = invoke(newslide.TimeLine.MainSequence,'AddEffect',animline,'msoAnimEffectAppear');
                                        itm(end).Timing.TriggerType = 'msoAnimTriggerWithPrevious';
                                        invoke(itm(end),'MoveAfter',itm(end-1));

                                        itm(end+1) = invoke(newslide.TimeLine.MainSequence,'AddEffect',animline,'msoAnimEffectPathRight');
                                        itm(end).Timing.TriggerType = 'msoAnimTriggerWithPrevious';
                                        set(itm(end).Timing,'SmoothStart','msoFalse','SmoothEnd','msoFalse');
                                        itm(end).Timing.Duration = length(wav)/fs;

                                        beh = itm(end).Behaviors;
                                        beh = invoke(beh,'Item',1);
                                        mef = beh.MotionEffect;

                                        if strcmp(animopt,'Value follower')
                                            crp = coords{c};
                                            crp(:,1) = [0; crp(1:end-1,1)];
                                            m = [repmat(' M ',size(coords{c},1),1) num2str(crp) repmat(' L ',size(coords{c},1),1) num2str(coords{c})];
                                            m = reshape(m',1, ...
                                                numel(m));
                                            str = [m ' E'];
                                            mef.Path = str;
                                        else
                                            set(mef,'Path',['M 0 0 L ' num2str(ycoord(c,3)/op.PageSetup.SlideWidth) ' 0 E']);
                                        end

                                        invoke(itm(end),'MoveAfter',itm(end-1));

                                        itm(end+1) = invoke(newslide.TimeLine.MainSequence,'AddEffect',animline,'msoAnimEffectFade');
                                        itm(end).Exit = 'msoTrue';
                                        set(itm(end).Timing,'TriggerDelayTime',length(wav)/fs,'Duration',0.01)
                                        itm(end).Timing.TriggerType = 'msoAnimTriggerWithPrevious';
                                        invoke(itm(end),'MoveAfter',itm(end-1));
                                    end
                                end
                            end



                            delete(fig);

                            bestlength = obj.ScalebarWidth/obj.settings.ExportSonogramWidth;
                            errs = abs(obj.settings.ScalebarPresets-bestlength);
                            [~, j] = min(errs);
                            y = offy+72*(sum(obj.settings.template.Height)+sum(obj.settings.template.Interval));
                            x2 = op.PageSetup.SlideWidth-offx;
                            x1 = x2-72*obj.settings.ScalebarPresets(j)*obj.settings.ExportSonogramWidth;
                            invoke(newslide.Shapes,'AddLine',x1,y,x2,y);
                            txt = obj.addWorksheetTextBox(newslide, obj.settings.ScalebarLabels{j}, 8, [], y, 'msoAnchorCenter', 'msoAnchorTop', 'ppAlignCenter');
                            txt.Left = (x1+x2/2-txt.Width/2);
                    end
            end

            delete(txtexp);

        end

        function handleMenuGroupCheck(group, itemToCheck)
            for item = group
                if item == itemToCheck
                    item.Checked = 'on';
                else
                    item.Checked = 'off';
                end
            end
        end

        function [checkedItemName, checkedItemNum] = getMenuGroupValue(group)
            for k = 1:length(group)
                item = group(k);
                if item.Checked
                    checkedItemNum = k;
                    checkedItemName = item.Text;
                    return;
                end
            end
            % No checked item found
            checkedItemNum = [];
            checkedItemName = '';

        end
        function menu_ExportAs_Callback(obj, hObject, eventdata)
        end

        function handleExportAsChange(obj, hObject, event)
            exportAs = getMenuGroupValue(obj.menu_ExportAs.Children');

            exportToOptions = [obj.export_toMATLAB, ...
                               obj.export_toPowerPoint, ...
                               obj.export_toFile, ...
                               obj.export_toClipboard];

            % Depending on what the "export as" setting is, enable/disable the
            % options for "export to"
            switch exportAs
                case 'Sonogram'
                    enablePattern = [1 1 1 1];
                case 'Figure'
                    enablePattern = [0 1 0 0];
                case 'Worksheet'
                    enablePattern = [1 1 0 0];
                case {'Current sound','Sound mix'}
                    enablePattern = [0 1 1 0];
                case 'Segments'
                    enablePattern = [0 0 1 0];
                case 'Events'
                    enablePattern = [1 0 0 1];
            end

            for k = 1:length(exportToOptions)
                exportToOptions(k).Enable = enablePattern(k);
                if ~enablePattern(k)
                    exportToOptions(k).Checked = false;
                end
            end

        end
        function export_asSonogram_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();


        end
        function export_asFigure_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();



        end
        function export_asWorksheet_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();



        end
        function export_asCurrentSound_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();



        end
        function export_asSoundMix_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();



        end
        function export_asEvents_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportAs.Children', hObject);
            obj.handleExportAsChange();



        end
        function menu_ExportTo_Callback(obj, hObject, eventdata)

        end
        function export_Options_Callback(obj, hObject, eventdata)

        end
        function export_options_SonogramHeight_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Sonogram height (in)'},'Height',1,{num2str(obj.settings.ExportSonogramHeight)});
            if isempty(answer)
                return
            end
            obj.settings.ExportSonogramHeight = str2double(answer{1});

            obj.UpdateWorksheet();


        end
        function export_options_ImageTimescape_Callback(obj, hObject, eventdata)

            answer = inputdlg({'Image timescale (in/sec)'},'Timescale',1,{num2str(obj.settings.ExportSonogramWidth)});
            if isempty(answer)
                return
            end
            obj.settings.ExportSonogramWidth = str2double(answer{1});

            obj.UpdateWorksheet();


        end
        function export_options_IncludeTimestamp_Callback(obj, hObject, eventdata)
            if obj.export_options_IncludeTimestamp.Checked
                obj.export_options_IncludeTimestamp.Checked = 'off';
                obj.settings.ExportSonogramIncludeLabel = 0;
            else
                obj.export_options_IncludeTimestamp.Checked = 'on';
                obj.settings.ExportSonogramIncludeLabel = 1;
            end



        end
        function menu_export_options_IncludeSoundClip_Callback(obj, hObject, eventdata)

        end
        function menu_export_options_Animation_Callback(obj, hObject, eventdata)

        end
        function export_options_ImageResolution_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Resolution (dpi)'},'Resolution',1,{num2str(obj.ExportSonogramResolution)});
            if isempty(answer)
                return
            end
            obj.ExportSonogramResolution = str2double(answer{1});

        end
        function menu_export_options_SonogramImageMode_Callback(obj, hObject, eventdata)

        end
        function export_options_ScalebarDimensions_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Preferred horizontal scalebar width (in)','Preferred vertical scalebar height (in)','Vertical scalebar position (in), <0 for left, >0 for right'},'Scalebar',1,{num2str(obj.ScalebarWidth),num2str(obj.ScalebarHeight),num2str(obj.VerticalScalebarPosition)});
            if isempty(answer)
                return
            end
            obj.ScalebarWidth = str2double(answer{1});
            obj.ScalebarHeight = str2double(answer{2});
            obj.VerticalScalebarPosition = str2double(answer{3});


        end
        function export_options_EditFigureTemplate_Callback(obj, hObject, eventdata)
            eg_Template_Editor(hObject);

        end
        function export_toMATLAB_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportTo.Children', hObject);


        end
        function export_toPowerPoint_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportTo.Children', hObject);


        end
        function export_toFile_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportTo.Children', hObject);


        end
        function export_toClipboard_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_ExportTo.Children', hObject);


        end
        function export_options_SonogramImageMode_ScreenImage_Callback(obj, hObject, eventdata)
            obj.export_options_SonogramImageMode_ScreenImage.Checked = 'on';
            obj.export_options_SonogramImageMode_Recalculate.Checked = 'off';
            obj.settings.ExportReplotSonogram = 0;


        end
        function export_options_SonogramImageMode_Recalculate_Callback(obj, hObject, eventdata)
            obj.export_options_SonogramImageMode_ScreenImage.Checked = 'off';
            obj.menu_CustomResolution.Checked = 'on';
            obj.settings.ExportReplotSonogram = 1;


        end
        function export_options_Animation_None_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_export_options_Animation.Children', hObject);

        end
        function export_options_Animation_ProgressBar_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_export_options_Animation.Children', hObject);

        end
        function export_options_Animation_ArrowAbove_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_export_options_Animation.Children', hObject);

        end
        function export_options_Animation_ArrowBelow_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_export_options_Animation.Children', hObject);

        end
        function export_options_Animation_ValueFollower_Callback(obj, hObject, eventdata)
            handleMenuGroupCheck(obj.menu_export_options_Animation.Children', hObject);

        end
        function export_options_Animation_SonogramFollower_Callback(obj, hObject, eventdata)
            answer = inputdlg({'Power weighting exponent (inf for maximum-follower)'},'Exponent',1,{num2str(obj.SonogramFollowerPower)});
            if isempty(answer)
                return
            end
            obj.SonogramFollowerPower = str2double(answer{1});


        end
        function export_options_IncludeSoundClip_None_Callback(obj, hObject, eventdata)
            obj.settings.ExportSonogramIncludeClip = 0;
            for child = obj.menu_export_options_IncludeSoundClip.Children'
                child.Checked = 'off';
            end
            hObject.Checked = 'on';


        end
        function export_options_IncludeSoundClip_SoundOnly_Callback(obj, hObject, eventdata)
            obj.settings.ExportSonogramIncludeClip = 1;
            for child = obj.menu_export_options_IncludeSoundClip.Children'
                child.Checked = 'off';
            end
            hObject.Checked = 'on';


        end
        function export_options_IncludeSoundClip_SoundMix_Callback(obj, hObject, eventdata)
            obj.settings.ExportSonogramIncludeClip = 2;
            for child = obj.menu_export_options_IncludeSoundClip.Children'
                child.Checked = 'off';
            end
            hObject.Checked = 'on';




        end
        function menu_OpenRecent_Callback(obj, hObject, eventdata)

        end
        function openRecent_None_Callback(obj, hObject, eventdata)

        end
        function menu_Help_Callback(obj, hObject, eventdata)

        end
        function menu_Macros_Callback(obj, hObject, eventdata)

        end
        function menu_AlterFileList_Callback(obj, hObject, eventdata)
        end
        % --- Executes on selection change in popup_FileSortOrder.
        function popup_FileSortOrder_Callback(obj, hObject, eventdata)

            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            sortMethodIdx = obj.popup_FileSortOrder.Value;
            sortMethod = obj.popup_FileSortOrder.String{sortMethodIdx};
            obj.settings.FileSortMethod = sortMethod;

            if strcmp(sortMethod, 'Property')
                % If we're switching to Property sorting, have to ask user which
                % property to sort by
                if isempty(obj.dbase.PropertyNames)
                    msgbox('No properties to sort by yet - please add one first')
                    return;
                end

                obj.SaveState();

                % Determine what default property name to offer the user
                defaultProperty = obj.settings.FileSortPropertyName;  % Try the previously used sort property first
                if isempty(defaultProperty) || ~any(strcmp(defaultProperty, obj.dbase.PropertyNames))
                    % That one's empty, go with the first one
                    defaultProperty = obj.dbase.PropertyNames{1};
                end
                % Query the user
                defaultProperty = categorical({defaultProperty}, obj.dbase.PropertyNames);
                inputs = getInputs('Sort by which property?', {'Property name'}, {defaultProperty}, {''});

                % Use user's choice
                if ~isempty(inputs)
                    obj.settings.FileSortPropertyName = char(inputs{1});
                else
                    % User cancelled - go back to File number sort order
                    obj.setFileSortMethod('File number');
                end
            end

            obj.RefreshSortOrder();


        end

        % --- Executes on button press in check_ReverseSort.
        function check_ReverseSort_Callback(obj, hObject, eventdata)
        % Hint: get(hObject,'Value') returns toggle state of check_ReverseSort


        end
        function menu_AuxiliarySoundSources_Callback(obj, hObject, eventdata)
        end

        function edit_FileNotes_Callback(obj, hObject, eventdata)

            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end

            obj.SaveState();

            filenum = electro_gui.getCurrentFileNum(obj.settings);
            obj.dbase.Notes{filenum} = obj.edit_FileNotes.String;

        end

        function HandleFileListChange(obj, hObject, event)

            if isempty(obj.FileInfoBrowser)
                return;
            end

            obj.SaveState();

            % Only switch files if selected cell is actually on the filename
            fileNameColumn = 2;
            if any(obj.FileInfoBrowser.Selection(:, 2) ~= fileNameColumn)
                % Do nothing
                return
            end
            newFileNum = obj.FileInfoBrowser.SelectedRow;
            obj.edit_FileNumber.String = num2str(newFileNum);
            obj.settings.CurrentFile = newFileNum;
            obj.LoadFile();


        end
        function setClickSoundCallback(obj, ax)
            % Set click_sound as button down callback for axes and children
            ax.ButtonDownFcn = @obj.click_sound;
            for ch = ax.Children'
                ch.ButtonDownFcn = ax.ButtonDownFcn;
            end
        end
        function menu_Animation_Callback(obj, hObject, event) 
        end
        function push_Calculate_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            obj.eg_PlotSonogram();
        
        
        end
        function menu_ColorScale_Callback(obj, hObject, event)
            if obj.settings.CurrentSonnogramIsPower == 1
                climGUI = CLimGUI(obj.axes_Sonogram);
                uiwait(climGUI.ParentFigure);
                obj.settings.SonogramClim = climGUI.CLim;
            else
                answer = inputdlg({'Offset','Brightness'},'Color scale',1,{num2str(obj.settings.DerivativeOffset),num2str(obj.settings.DerivativeSlope)});
                if isempty(answer)
                    return
                end
                obj.settings.DerivativeOffset = str2double(answer{1});
                obj.settings.NewDerivativeSlope = str2double(answer{2});
            end
        
            obj.SetSonogramColors();
        
        end
        function menu_FreqLimits_Callback(obj, hObject, event)
            answer = inputdlg({'Minimum (Hz)','Maximum (Hz)'},'Frequency limits',1,{num2str(obj.settings.FreqLim(1)),num2str(obj.settings.FreqLim(2))});
            if isempty(answer)
                return
            end
            obj.settings.FreqLim = [str2double(answer{1}) str2double(answer{2})];
            obj.settings.CustomFreqLim = obj.settings.FreqLim;
        
            obj.eg_PlotSonogram();
        
        end
        
        function push_Cancel_Callback(obj, hObject, event)
        end
        function context_Amplitude_Callback(obj, hObject, event)
        end
        function menu_AutoThreshold_Callback(obj, hObject, event)
            if ~obj.menu_AutoThreshold.Checked
                obj.menu_AutoThreshold.Checked = 'on';
                obj.settings.CurrentThreshold = electro_gui.eg_AutoThreshold(obj.amplitude);
                obj.dbase.SegmentThresholds(electro_gui.getCurrentFileNum(obj.settings)) = obj.settings.CurrentThreshold;
                obj.SetSegmentThreshold();
            else
                obj.menu_AutoThreshold.Checked = 'off';
            end
        
        end
        function context_EventViewer_Callback(obj, hObject, event)
        end
        function menu_ChannelColors1_Callback(obj, hObject, event)
        
        end
        function menu_PlotColor1_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.ChannelColor(1,:), 'Select color');
            obj.settings.ChannelColor(1,:) = c;
            obj = findobj('Parent',obj.axes_Channel1,'LineStyle','-');
            obj.Color = c;
        
            obj.eg_Overlay();
        
        
        end
        function menu_ThresholdColor1_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.ChannelThresholdColor(1,:), 'Select color');
            obj.settings.ChannelThresholdColor(1,:) = c;
            obj = findobj('Parent',obj.axes_Channel1,'LineStyle',':');
            obj.Color = c;
        
        
        
        end
        function menu_ChannelColors2_Callback(obj, hObject, event)
        
        end
        function menu_PlotColor2_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.ChannelColor(2,:), 'Select color');
            obj.settings.ChannelColor(2,:) = c;
            obj = findobj('Parent',obj.axes_Channel2,'LineStyle','-');
            obj.Color = c;
        
            obj.eg_Overlay();
        
        
        end
        function menu_ThresholdColor2_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.ChannelThresholdColor(2,:), 'Select color');
            obj.settings.ChannelThresholdColor(2,:) = c;
            obj = findobj('Parent',obj.axes_Channel2,'LineStyle',':');
            obj.Color = c;
        
        
        
        
        end
        % --- Executes on button press in push_BrightnessUp.
        function push_BrightnessUp_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            if obj.settings.CurrentSonnogramIsPower == 1
                if obj.settings.SonogramClim(2) > obj.settings.SonogramClim(1)+0.5
                    obj.settings.SonogramClim(2) = obj.settings.SonogramClim(2)-0.5;
                end
            else
                obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope+0.2;
            end
        
            obj.SetSonogramColors();
        
        end
        % --- Executes on button press in push_BrightnessDown.
        function push_BrightnessDown_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            if obj.settings.CurrentSonnogramIsPower == 1
                obj.settings.SonogramClim(2) = obj.settings.SonogramClim(2)+0.5;
            else
                obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope-0.2;
            end
        
            obj.SetSonogramColors();
        
        
        end
        % --- Executes on button press in push_OffsetUp.
        function push_OffsetUp_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            if obj.settings.CurrentSonnogramIsPower == 1
                if obj.settings.SonogramClim(1) < obj.settings.SonogramClim(2)-0.5
                    obj.settings.SonogramClim(1) = obj.settings.SonogramClim(1)+0.5;
                end
            else
                obj.settings.DerivativeOffset = obj.settings.DerivativeOffset + 0.05;
            end
            obj.SetSonogramColors();
        
        
        end
        % --- Executes on button press in push_OffsetDown.
        function push_OffsetDown_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            if obj.settings.CurrentSonnogramIsPower == 1
                obj.settings.SonogramClim(1) = obj.settings.SonogramClim(1)-0.5;
            else
                obj.settings.DerivativeOffset = obj.settings.DerivativeOffset - 0.05;
            end
            obj.SetSonogramColors();
        
        
        
        end
        function menu_AmplitudeColors_Callback(obj, hObject, event)
        
        end
        function menu_AmplitudeColor_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.AmplitudeColor, 'Select color');
            obj.settings.AmplitudeColor = c;
        
            if isempty(obj.AmplitudePlotHandle) || ~isgraphics(obj.AmplitudePlotHandle)
                obj.AmplitudePlotHandle.Color = c;
            end
        
        
        
        end
        function menu_AmplitudeThresholdColor_Callback(obj, hObject, event)
            c = uisetcolor(obj.settings.AmplitudeThresholdColor, 'Select color');
            obj.settings.AmplitudeThresholdColor = c;
            if ~isempty(obj.SegmentThresholdHandle) && isgraphics(obj.SegmentThresholdHandle)
                obj.SegmentThresholdHandle.Color = c;
            end
        
        end
        
        function edit_SoundWeight_Callback(obj, hObject, event)
        
        end
        
        function edit_TopWeight_Callback(obj, hObject, event)
        
        end
        
        function edit_BottomWeight_Callback(obj, hObject, event)
        
        end
        
        function edit_SoundClipper_Callback(obj, hObject, event)
        
        end
        
        function edit_TopClipper_Callback(obj, hObject, event)
        
        end
        
        function edit_BottomClipper_Callback(obj, hObject, event)
        
        end
        
        function menu_EventsDisplay1_Callback(obj, hObject, event)
        end
        function menu_EventsDisplay2_Callback(obj, hObject, event)
        end
        function menu_SelectionParameters1_Callback(obj, hObject, event)
            obj.SelectionParameters(1);
        
        
        end
        function menu_SelectionParameters2_Callback(obj, hObject, event)
            obj.SelectionParameters(2);
        
        end
        
        function SelectionParameters(obj,axnum)
        
            answer = inputdlg({'Search before (ms)','Search after (ms)'},'Selection parameteres',1,{num2str(obj.SearchBefore(axnum)*1000),num2str(obj.SearchAfter(axnum)*1000)});
            if isempty(answer)
                return
            end
        
            obj.SearchBefore(axnum) = str2double(answer{1})/1000;
            obj.SearchAfter(axnum) = str2double(answer{2})/1000;
        
        end
        function menu_ViewerDisplay_Callback(obj, hObject, event)
        end
        function menu_DisplayValues_Callback(obj, hObject, event)
            obj.menu_DisplayValues.Checked = 'on';
            obj.menu_DisplayFeatures.Checked = 'off';
        
            obj.menu_XAxis.Enable = 'off';
            obj.menu_YAxis.Enable = 'off';
        
            obj.UpdateEventViewer();
        
        
        end
        function menu_DisplayFeatures_Callback(obj, hObject, event)
            obj.menu_DisplayValues.Checked = 'off';
            obj.menu_DisplayFeatures.Checked = 'on';
        
            obj.menu_XAxis.Enable = 'on';
            obj.menu_YAxis.Enable = 'on';
        
            obj.UpdateEventViewer();
        
        
        
        end
        function menu_AutoDisplayEvents_Callback(obj, hObject, event)
            if obj.menu_AutoDisplayEvents.Checked
                obj.menu_AutoDisplayEvents.Checked = 'off';
            else
                obj.menu_AutoDisplayEvents.Checked = 'on';
                obj.UpdateEventViewer();
            end
        
        
        
        end
        function menu_EventsAxisLimits_Callback(obj, hObject, event)
            eventSourceIdx = obj.GetEventViewerEventSourceIdx();
            tmin = -obj.settings.EventXLims(eventSourceIdx, 1)*1000;
            tmax =  obj.settings.EventXLims(eventSourceIdx, 2)*1000;
            answer = inputdlg({'Min (ms)', 'Max (ms)'}, 'Set limits', 1, {num2str(tmin),num2str(tmax)});
            if isempty(answer)
                return
            end
            obj.settings.EventXLims(eventSourceIdx,:) = [-str2double(answer{1})/1000, str2double(answer{2})/1000];
        
            obj.UpdateEventViewer();
        
        end
        
        function menu_XAxis_Callback(obj, hObject, event)
        end
        function menu_Yaxis_Callback(obj, hObject, event)
        end
        function menu_YAxis_Callback(obj, hObject, event)
        end
        
        function XAxisMenuClick(obj, hObject, event)
        
            obj.menu_XAxis_List.Checked = 'off';
            hObject.Checked = 'on';
        
            obj.UpdateEventViewer();
        
        end
        
        function YAxisMenuClick(obj, hObject, event)
        
            obj.menu_YAxis_List.Checked = 'off';
            hObject.Checked = 'on';
        
            obj.UpdateEventViewer();
        
        end
        % --- Executes on button press in push_WorksheetAppend.
        function push_WorksheetAppend_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            xl = obj.axes_Sonogram.XLim;
            yl = obj.axes_Sonogram.YLim;
            fig = figure;
            fig.Visible = 'off';
            fig.Units = 'pixels';
            pos = fig.Position;
            pos(3) = obj.ExportSonogramResolution*obj.settings.ExportSonogramWidth*(xl(2)-xl(1));
            pos(4) = obj.ExportSonogramResolution*obj.settings.ExportSonogramHeight;
            fig.Position = pos;
            ax = subplot('Position',[0 0 1 1]);
            hold(ax, 'on');
            ts = {};
            ys = {};
            ds = {};
            if obj.settings.ExportReplotSonogram == 0
                sonogramImage = findobj('Parent',obj.axes_Sonogram, 'type', 'image');
                for sonogramNum = 1:length(sonogramImage)
                    t = sonogramImage(sonogramNum).XData;
                    f = sonogramImage(sonogramNum).YData;
                    data = sonogramImage(sonogramNum).CData;
                    timeMask = t>=xl(1) & t<=xl(2);
                    freqMask = f>=yl(1) & f<=yl(2);
                    ts{end+1} = t(timeMask);
                    ys{end+1} = f(freqMask);
                    ds{end+1} = data(timeMask, freqMask);
                end
            else
                xlim(ax, xl);
                ylim(ax, yl);
                xlp = round(xl*obj.dbase.Fs);
                if xlp(1)<1
                    xlp(1) = 1;
                end
                numSamples = obj.eg_GetSamplingInfo();
                if xlp(2)>numSamples
                    xlp(2) = numSamples; 
                end
                for c = 1:length(obj.menu_Algorithm)
                    if obj.menu_Algorithm(c).Checked
                        alg = obj.menu_Algorithm(c).Label;
                    end
                end
        
                obj.UpdateFilteredSound();
        
                electro_gui.eg_runPlugin(obj.plugins.spectrums, alg, ax, ...
                    obj.filtered_sound(xlp(1):xlp(2)), obj.dbase.Fs, obj.settings.SonogramParams);
                ax.YDir = 'normal';
                obj.settings.NewDerivativeSlope = obj.settings.DerivativeSlope;
                obj.settings.DerivativeSlope = 0;
                obj.SetSonogramColors();
                ch = ax.Children;
                for c = 1:length(ch)
                    x = ch(c).XData;
                    y = ch(c).YData;
                    m = ch(c).CData;
                    f = find(x>=xl(1) & x<=xl(2));
                    g = find(y>=yl(1) & y<=yl(2));
                    ts{end+1} = x(f);
                    ys{end+1} = y(g);
                    ds{end+1} = m(g,f);
                end
            end
        
            delete(fig);
        
            wav = obj.GenerateSound('snd');
            ys = obj.dbase.Fs * obj.SoundSpeed;
        
            obj.settings.WorksheetXLims{end+1} = xl;
            obj.settings.WorksheetYLims{end+1} = yl;
            obj.settings.WorksheetXs{end+1} = ts;
            obj.settings.WorksheetYs{end+1} = ys;
            obj.settings.WorksheetMs{end+1} = ds;
            obj.settings.WorksheetClim{end+1} = obj.axes_Sonogram.CLim;
            obj.settings.WorksheetColormap{end+1} = obj.figure_Main.Colormap;
            obj.settings.WorksheetSounds{end+1} = wav;
            obj.settings.WorksheetFs(end+1) = ys;
            dt = datetime(obj.text_DateAndTime.String);
            xd = obj.axes_Sonogram.XLim;
            dt = dt + seconds(xd(1));
            obj.settings.WorksheetTimes(end+1) = dt;
        
            obj.UpdateWorksheet();
        
            str = obj.panel_Worksheet.Title ;
            f = strfind(str,'/');
            tot = str2double(str(f+1:end));
            obj.settings.WorksheetCurrentPage = tot;
            obj.UpdateWorksheet();
        
            if length(obj.WorksheetHandles)>=length(obj.settings.WorksheetMs)
                if ishandle(obj.WorksheetHandles(length(obj.settings.WorksheetMs)))
                    obj.WorksheetHandles(length(obj.settings.WorksheetMs)).FaceColor = 'r';
                end
            end
        
        end
        function click_Worksheet(obj, hObject, event)
        
            ch = obj.axes_Worksheet.Children;
            for c = 1:length(ch)
                if sum(ch(c).FaceColor==[1 1 1])<3
                    ch(c).FaceColor = [.5 .5 .5];
                end
            end
            hObject.FaceColor = 'r';
        
            if strcmp(obj.figure_Main.SelectionType,'open')
                obj.ViewWorksheet();
            end
        
        
        end
        % --- Executes on button press in push_WorksheetOptions.
        function push_WorksheetOptions_Callback(obj, hObject, event)
            import java.awt.*;
            import java.awt.event.*;
        
            obj.push_WorksheetOptions.UIContextMenu = obj.context_WorksheetOptions;
        
            % Trigger a right-click event
            try
                rob = Robot;
                rob.mousePress(InputEvent.BUTTON3_MASK);
                pause(0.01);
                rob.mouseRelease(InputEvent.BUTTON3_MASK);
            catch
                errordlg('Java is not working properly. You must right-click the button.','Java error');
            end
        
        end
        % --- Executes on button press in push_PageLeft.
        function push_PageLeft_Callback(obj, hObject, event)
            str = obj.panel_Worksheet.Title ;
            f = strfind(str,'/');
            tot = str2double(str(f+1:end));
        
            obj.settings.WorksheetCurrentPage = mod(obj.settings.WorksheetCurrentPage-1,tot);
            if obj.settings.WorksheetCurrentPage == 0
                obj.settings.WorksheetCurrentPage = tot;
            end
        
            obj.UpdateWorksheet();
        
        
        end
        % --- Executes on button press in push_PageRight.
        function push_PageRight_Callback(obj, hObject, event)
            str = obj.panel_Worksheet.Title ;
            f = strfind(str,'/');
            tot = str2double(str(f+1:end));
        
            obj.settings.WorksheetCurrentPage = mod(obj.settings.WorksheetCurrentPage+1,tot);
            if obj.settings.WorksheetCurrentPage == 0
                obj.settings.WorksheetCurrentPage = tot;
            end
        
            obj.UpdateWorksheet();
        
        
        
        end
        function menu_FrequencyZoom_Callback(obj, hObject, event)
            if obj.menu_FrequencyZoom.Checked
                obj.menu_FrequencyZoom.Checked = 'off';
            else
                obj.menu_FrequencyZoom.Checked = 'on';
            end
        
        
        end
        function context_Worksheet_Callback(obj, hObject, event)
        
        end
        function menu_WorksheetDelete_Callback(obj, hObject, event)
            f = find(obj.WorksheetHandles==findobj('Parent',obj.axes_Worksheet,'FaceColor','r'));
        
            obj.settings.WorksheetXLims(f) = [];
            obj.settings.WorksheetYLims(f) = [];
            obj.settings.WorksheetXs(f) = [];
            obj.settings.WorksheetYs(f) = [];
            obj.settings.WorksheetMs(f) = [];
            obj.settings.WorksheetClim(f) = [];
            obj.settings.WorksheetColormap(f) = [];
            obj.settings.WorksheetSounds(f) = [];
            obj.settings.WorksheetFs(f) = [];
            obj.settings.WorksheetTimes(f) = [];
        
            obj.UpdateWorksheet();
        
        
        
        end
        function menu_SortChronologically_Callback(obj, hObject, event)
            if obj.menu_SortChronologically.Checked
                obj.menu_SortChronologically.Checked = 'off';
                obj.settings.WorksheetChronological = 0;
            else
                obj.menu_SortChronologically.Checked = 'on';
                obj.settings.WorksheetChronological = 1;
            end
        
            obj.UpdateWorksheet();
        
        
        
        end
        function context_WorksheetOptions_Callback(obj, hObject, event)
        
        end
        function menu_OnePerLine_Callback(obj, hObject, event)
            if obj.menu_OnePerLine.Checked
                obj.menu_OnePerLine.Checked = 'off';
                obj.settings.WorksheetOnePerLine = 0;
            else
                obj.menu_OnePerLine.Checked = 'on';
                obj.settings.WorksheetOnePerLine = 1;
            end
        
            obj.UpdateWorksheet();
        
        
        
        end
        function menu_IncludeTitle_Callback(obj, hObject, event)
            if obj.menu_IncludeTitle.Checked
                obj.menu_IncludeTitle.Checked = 'off';
                obj.settings.WorksheetIncludeTitle = 0;
            else
                obj.menu_IncludeTitle.Checked = 'on';
                obj.settings.WorksheetIncludeTitle = 1;
            end
        
            obj.UpdateWorksheet();
        
        
        
        end
        function menu_EditTitle_Callback(obj, hObject, event)
            answer = inputdlg({'Worksheet title'},'Title',1,{obj.settings.WorksheetTitle});
            if isempty(answer)
                return
            end
            obj.settings.WorksheetTitle = answer{1};
        
        
        
        end
        function menu_WorksheetDimensions_Callback(obj, hObject, event)
            answer = inputdlg({'Width (in)',                         'Height (in)',                         'Margin (in)',                         'Title height (in)',                        'Vertical interval (in)',                        'Horizontal interval (in)'},'Worksheet dimensions',1, ...
                              {num2str(obj.settings.WorksheetWidth), num2str(obj.settings.WorksheetHeight), num2str(obj.settings.WorksheetMargin), num2str(obj.settings.WorksheetTitleHeight), num2str(obj.settings.WorksheetVerticalInterval), num2str(obj.settings.WorksheetHorizontalInterval)});
            if isempty(answer)
                return
            end
            obj.settings.WorksheetWidth = str2double(answer{1});
            obj.settings.WorksheetHeight = str2double(answer{2});
            obj.settings.WorksheetMargin = str2double(answer{3});
            obj.settings.WorksheetTitleHeight = str2double(answer{4});
            obj.settings.WorksheetVerticalInterval = str2double(answer{5});
            obj.settings.WorksheetHorizontalInterval = str2double(answer{6});
        
            obj.UpdateWorksheet();
        
        
        end
        function menu_ClearWorksheet_Callback(obj, hObject, event)
            button = questdlg('Delete all worksheet sounds?','Clear worksheet','Yes','No','No');
            if strcmp(button,'No')
                return
            end
        
            obj.settings.WorksheetXLims = {};
            obj.settings.WorksheetYLims = {};
            obj.settings.WorksheetXs = {};
            obj.settings.WorksheetYs = {};
            obj.settings.WorksheetMs = {};
            obj.settings.WorksheetClim = {};
            obj.settings.WorksheetColormap = {};
            obj.settings.WorksheetSounds = {};
            obj.settings.WorksheetFs = [];
            obj.settings.WorksheetTimes = datetime.empty();
        
            obj.UpdateWorksheet();
        
        
        end
        function menu_WorksheetView_Callback(obj, hObject, event)
            obj.ViewWorksheet();
        end
        function MacrosMenuclick(obj, hObject, event)
            obj.SaveState();
        
            f = find(obj.menu_Macros==hObject);
        
            mcr = obj.menu_Macros(f).Label;
            electro_gui.eg_runPlugin(obj.plugins.macros, mcr, obj);
        
        end
        function menu_Portrait_Callback(obj, hObject, event)
            if ~obj.menu_Portrait.Checked
                obj.menu_Portrait.Checked = 'on';
                obj.menu_Landscape.Checked = 'off';
                obj.settings.WorksheetOrientation = 'portrait';
                dummy = obj.settings.WorksheetWidth;
                obj.settings.WorksheetWidth = obj.settings.WorksheetHeight;
                obj.settings.WorksheetHeight = dummy;
                obj.UpdateWorksheet();
        
            end
        
        
        end
        function menu_Orientation_Callback(obj, hObject, event)
        
        end
        function menu_Landscape_Callback(obj, hObject, event)
        
            if ~obj.menu_Landscape.Checked
                obj.menu_Portrait.Checked = 'off';
                obj.menu_Landscape.Checked = 'on';
                obj.settings.WorksheetOrientation = 'landscape';
                dummy = obj.settings.WorksheetWidth;
                obj.settings.WorksheetWidth = obj.settings.WorksheetHeight;
                obj.settings.WorksheetHeight = dummy;
                obj.UpdateWorksheet();
        
            end
        
        end
        function menu_LineWidth1_Callback(obj, hObject, event)
            answer = inputdlg({'Line width'},'Line width',1,{num2str(obj.settings.ChannelLineWidth(1))});
            if isempty(answer)
                return
            end
            obj.settings.ChannelLineWidth(1) = str2double(answer{1});
            obj = findobj('Parent',obj.axes_Channel1,'LineStyle','-');
            obj.LineWidth  = obj.settings.ChannelLineWidth(1);
        
            obj.eg_Overlay();
        
        
        end
        function menu_LineWidth2_Callback(obj, hObject, event)
            answer = inputdlg({'Line width'},'Line width',1,{num2str(obj.settings.ChannelLineWidth(2))});
            if isempty(answer)
                return
            end
            obj.settings.ChannelLineWidth(2) = str2double(answer{1});
            obj = findobj('Parent',obj.axes_Channel2,'LineStyle','-');
            obj.LineWidth  = obj.settings.ChannelLineWidth(2);
        
            obj.eg_Overlay();
        
        
        
        end
        function menu_BackgroundColor_Callback(obj, hObject, event)
        
            c = uisetcolor(obj.settings.BackgroundColors(2-obj.settings.CurrentSonnogramIsPower,:), 'Select color');
            obj.settings.BackgroundColors(2-obj.settings.CurrentSonnogramIsPower,:) = c;
        
            if obj.settings.CurrentSonnogramIsPower == 1
                obj.Colormap(1,:) = c;
                colormap(obj.Colormap);
            else
                cl = repmat(linspace(0,1,201)',1,3);
                indx = round(101-obj.settings.DerivativeOffset*100):round(101+obj.settings.DerivativeOffset*100);
                indx = indx(indx>0 & indx<202);
                cl(indx,:) = repmat(obj.settings.BackgroundColors(2,:),length(indx),1);
                colormap(cl);
            end
        
        
        
        end
        function menu_Colormap_Callback(obj, hObject, event)
        end
        
        function ColormapClick(obj, hObject, event)
        
            if strcmp(hObject.Label,'(Default)')
                colormap('parula');
                cmap = colormap;
                cmap(1,:) = [0 0 0];
            else
                cmap = electro_gui.eg_runPlugin(obj.plugins.colorMaps, hObject.Label);
            end
        
            obj.Colormap = cmap;
            obj.settings.BackgroundColors(1,:) = cmap(1,:);
        
            colormap(obj.Colormap);
        
        
        
        end
        function menu_OverlayTop_Callback(obj, hObject, event)
            if ~obj.menu_OverlayTop.Checked
                obj.menu_OverlayTop.Checked = 'on';
            else
                obj.menu_OverlayTop.Checked = 'off';
            end
        
            obj.eg_Overlay();
        
        
        
        end
        function menu_Overlay_Callback(obj, hObject, event)
        
        end
        function menu_OverlayBottom_Callback(obj, hObject, event)
            if ~obj.menu_OverlayBottom.Checked
                obj.menu_OverlayBottom.Checked = 'on';
            else
                obj.menu_OverlayBottom.Checked = 'off';
            end
        
            obj.eg_Overlay();
        
        end
        function menu_SonogramParameters_Callback(obj, hObject, event)
        
            if isempty(obj.settings.SonogramParams.Names)
                errordlg('Current sonogram algorithm does not require parameters.','Sonogram error');
                return
            end
        
            answer = inputdlg(obj.settings.SonogramParams.Names,'Sonogram parameters',1,obj.settings.SonogramParams.Values);
            if isempty(answer)
                return
            end
            obj.settings.SonogramParams.Values = answer;
        
            for c = 1:length(obj.menu_Algorithm)
                if obj.menu_Algorithm(c).Checked
                    h = obj.menu_Algorithm(c);
                    h.UserData = obj.settings.SonogramParams;
                end
            end
        
            obj.eg_PlotSonogram();
        
            obj.eg_Overlay();
        
        
        
        end
        function menu_EventParams1_Callback(obj, hObject, event)
            obj.menu_EventParams(1);
        
        
        
        end
        function menu_EventParams2_Callback(obj, hObject, event)
            obj.menu_EventParams(2);
        
        end
        
        function menu_EventParams(obj,axnum)
        
            pr = obj.settings.ChannelAxesEventParams{axnum};
        
            if ~isfield(pr,'Names') || isempty(pr.Names)
                errordlg('Current event detector does not require parameters.','Event detector error');
                return
            end
        
            answer = inputdlg(pr.Names,'Event detector parameters',1,pr.Values);
            if isempty(answer)
                return
            end
            pr.Values = answer;
        
            obj.settings.ChannelAxesEventParams{axnum} = pr;
        
            v = obj.popup_EventDetectors(axnum).Value;
            ud = obj.popup_EventDetectors(axnum).UserData;
            ud{v} = obj.settings.ChannelAxesEventParams{axnum};
            obj.popup_EventDetectors(axnum).UserData = ud;
        
            obj.DetectEventsInAxes(axnum);
        
        
        end
        function menu_FunctionParams1_Callback(obj, hObject, event)
            obj.menu_FunctionParams(1);
        
        
        end
        function menu_FunctionParams2_Callback(obj, hObject, event)
            obj.menu_FunctionParams(2);
        
        end
        function menu_Split_Callback(obj, hObject, event)
        
            % ginput(1);
            myginput(1); %mod by VG
            set(gca,'Units','pixels');
            set(get(gca,'Parent'),'Units','pixels');
            rect = rbbox;
            pos = get(gca,'Position');
            set(get(gca,'Parent'),'Units','normalized');
            set(gca,'Units','normalized');
            xl = xlim;
            yl = ylim;
            rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
            rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
            rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
        
            for c = 1:length(obj.menu_SegmenterList.Children)
                if obj.menu_SegmenterList.Children(c).Checked
                    alg = obj.menu_SegmenterList.Children(c).Label;
                end
            end
        
            filenum = electro_gui.getCurrentFileNum(obj.settings);
        
        
            f = find(obj.dbase.SegmentTimes{filenum}(:,1)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*obj.dbase.Fs);
            g = find(obj.dbase.SegmentTimes{filenum}(:,2)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*obj.dbase.Fs);
            h = find(obj.dbase.SegmentTimes{filenum}(:,1)<rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*obj.dbase.Fs);
            dl = unique([f; g; h]);
            if isempty(dl)
                return
            end
        
            sound = obj.getSound();
        
            obj.settings.SegmenterParams.IsSplit = 1;
            sg = electro_gui.eg_runPlugin(obj.plugins.segmenters, alg, obj.amplitude, ...
                sound, obj.dbase.Fs, rect(2), obj.settings.SegmenterParams);
        
            f = find(sg(:,1)>rect(1)*obj.dbase.Fs & sg(:,1)<(rect(1)+rect(3))*obj.dbase.Fs);
            g = find(sg(:,2)>rect(1)*obj.dbase.Fs & sg(:,2)<(rect(1)+rect(3))*obj.dbase.Fs);
            h = find(sg(:,1)<rect(1)*obj.dbase.Fs & sg(:,2)>(rect(1)+rect(3))*obj.dbase.Fs);
            nw = unique([f; g; h]);
            sg = sg(nw,:);
        
            obj.dbase.SegmentTimes{filenum} = [obj.dbase.SegmentTimes{filenum}(1:min(dl)-1,:); sg; obj.dbase.SegmentTimes{filenum}(max(dl)+1:end,:)];
            st = {};
            st = [st obj.dbase.SegmentTitles{filenum}(1:min(dl)-1)];
            st = [st cell(1,size(sg,1))];
            st = [st obj.dbase.SegmentTitles{filenum}(max(dl)+1:end)];
            obj.dbase.SegmentTitles{filenum} = st;
            obj.dbase.SegmentIsSelected{filenum} = [obj.dbase.SegmentIsSelected{filenum}(1:min(dl)-1) ones(1,size(sg,1)) obj.dbase.SegmentIsSelected{filenum}(max(dl)+1:end)];
            obj.PlotAnnotations();
            obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;
        end
        function menu_SourceSoundAmplitude_Callback(obj, hObject, event)
            obj.menu_SourceSoundAmplitude.Checked = 'on';
            obj.menu_SourceTopPlot.Checked = 'off';
            obj.menu_SourceBottomPlot.Checked = 'off';
        
            obj.updateAmplitude();
        
        
        
        end
        function menu_SourceTopPlot_Callback(obj, hObject, event)
            obj.menu_SourceSoundAmplitude.Checked = 'off';
            obj.menu_SourceTopPlot.Checked = 'on';
            obj.menu_SourceBottomPlot.Checked = 'off';
        
            obj.updateAmplitude();
        
        
        
        end
        function menu_SourceBottomPlot_Callback(obj, hObject, event)
        
            obj.menu_SourceSoundAmplitude.Checked = 'off';
            obj.menu_SourceTopPlot.Checked = 'off';
            obj.menu_SourceBottomPlot.Checked = 'on';
        
            obj.updateAmplitude();
        
        end
        
        function menu_Concatenate_Callback(obj, hObject, event)
            filenum = electro_gui.getCurrentFileNum(obj.settings);
        
            obj.axes_Segments.Units = 'pixels';
            obj.figure_Main.Units = 'pixels';
            ginput(1);
            rect = rbbox;
        
            pos = obj.axes_Segments.Position;
            obj.figure_Main.Units = 'normalized';
            obj.axes_Segments.Units = 'normalized';
            xl = xlim;
        
            rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
            rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
        
            f = find(obj.dbase.SegmentTimes{filenum}(:,1)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*obj.dbase.Fs);
            g = find(obj.dbase.SegmentTimes{filenum}(:,2)>rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*obj.dbase.Fs);
            h = find(obj.dbase.SegmentTimes{filenum}(:,1)<rect(1)*obj.dbase.Fs & obj.dbase.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*obj.dbase.Fs);
            f = unique([f; g; h]);
        
            if isempty(f)
                return
            end
        
            obj.dbase.SegmentTimes{filenum}(min(f),2) = obj.dbase.SegmentTimes{filenum}(max(f),2);
            obj.dbase.SegmentTimes{filenum}(min(f)+1:max(f),:) = [];
            obj.dbase.SegmentTitles{filenum}(min(f)+1:max(f)) = [];
            obj.dbase.SegmentIsSelected{filenum}(min(f)+1:max(f)) = [];
            obj.PlotAnnotations();
        
            obj.SetActiveSegment(min(f));
            obj.figure_Main.KeyPressFcn = @obj.keyPressHandler;
        
        
        
        end
        function menu_DontPlot_Callback(obj, hObject, event)
            if ~obj.menu_DontPlot.Checked
                obj.menu_DontPlot.Checked = 'on';
            else
                obj.menu_DontPlot.Checked = 'off';
            end
        
            obj.LoadFile();
        
        end
        function menu_FilterList_Callback(obj, hObject, event)
        
        end
        function menu_FilterParameters_Callback(obj, hObject, event)
        
            if isempty(obj.settings.FilterParams.Names)
                errordlg('Current sound filter does not require parameters.','Filter error');
                return
            end
        
            answer = inputdlg(obj.settings.FilterParams.Names,'Filter parameters',1,obj.settings.FilterParams.Values);
            if isempty(answer)
                return
            end
            obj.settings.FilterParams.Values = answer;
        
            for c = 1:length(obj.menu_Filter)
                if obj.menu_Filter(c).Checked
                    h = obj.menu_Filter(c);
                    h.UserData = obj.settings.FilterParams;
                end
            end
        
            obj.UpdateFilteredSound();
        
            cla(obj.axes_Sound);

            obj.RedrawSoundEnvelope();
        
            obj.updateXLimBox();
        
            obj.setClickSoundCallback(obj.axes_Sonogram);
            obj.setClickSoundCallback(obj.axes_Sound);
        
            obj.updateAmplitude();
        
        end
        function menu_AmplitudeAutoRange_Callback(obj, hObject, event)
            mn = min(obj.amplitude);
            mx = max(obj.amplitude);
            obj.settings.AmplitudeLims = [mn-0.05*(mx-mn) mx+0.05*(mx-mn)];
        
            obj.axes_Amplitude.YLim = obj.settings.AmplitudeLims;
        
        end
        function menu_Properties_Callback(obj, hObject, eventdata)
        
        end
        function menu_AddProperty_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            obj.SaveState();
        
            obj.eg_AddProperty();
        
        
        end
        function context_Properties_Callback(obj, hObject, event)
        end
        
        function menu_RemoveProperty_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return;
            end
        
            obj.SaveState();
        
            [~, propertyNames] = obj.getProperties();
            if isempty(propertyNames)
                % No properties to remove, do nothing
                msgbox('No properties to remove');
                return;
            end
            propertyName = categorical(propertyNames(1), propertyNames);
            input = getInputs('Remove property', {'Property name'}, {propertyName}, {'Name of property to remove'});
            if ~isempty(input)
                obj.removeProperty(input{1});
            end
        
        
        end
        function menu_Search_Callback(obj, hObject, event)
        end
        
        function SearchProperties(obj,search_type)
            error('Searching properties not implemented yet')
        
        
        %     if ~isfield(handles,'PropertyNames') || isempty(obj.dbase.PropertyNames)
        %         errordlg('No properties to search!','Error');
        %         return
        %     end
        %
        %     [indx,ok] = listdlg('ListString',obj.dbase.PropertyNames,'InitialValue',[],'Name','Select property','SelectionMode','single','PromptString','Select property to search');
        %     if ok == 0
        %         return
        %     end
        %
        %     prev_search = [];
        %     fileNames = obj.getFileNames();
        %     str = obj.list_Files.String;
        %     for c = 1:obj.TotalFileNumber
        %         if strcmp(str{c}(19),'F')
        %             prev_search = [prev_search c];
        %         end
        %     end
        %
        %     nw = [];
        %     switch obj.PropertyTypes(indx)
        %         case 1
        %             answer = inputdlg({['String to search for in "' obj.dbase.PropertyNames{indx} '"']},'Search property',1,obj.DefaultPropertyValues(indx));
        %             if isempty(answer)
        %                 return
        %             end
        %             for d = 1:obj.TotalFileNumber
        %                 for e = 1:length(obj.dbase.Properties.Names{d})
        %                     if strcmp(obj.dbase.Properties.Names{d}{e},obj.dbase.PropertyNames{indx})
        %                         fnd = regexpi(obj.dbase.Properties.Values{d}{e},answer{1}, 'once');
        %                         if ~isempty(fnd)
        %                             nw = [nw d];
        %                         end
        %                     end
        %                 end
        %             end
        %         case 2
        %             button = questdlg(['Value to search for in "' obj.dbase.PropertyNames{indx} '"'],'Search property','On','Off','Either','On');
        %             switch button
        %                 case ''
        %                     return
        %                 case 'On'
        %                     valnear = 1.5;
        %                 case 'Off'
        %                     valnear = -0.5;
        %                 case 'Either'
        %                     valnear = 0.5;
        %             end
        %             for d = 1:obj.TotalFileNumber
        %                 for e = 1:length(obj.dbase.Properties.Names{d})
        %                     if strcmp(obj.dbase.Properties.Names{d}{e},obj.dbase.PropertyNames{indx})
        %                         if abs(obj.dbase.Properties.Values{d}{e}-valnear)<1
        %                             nw = [nw d];
        %                         end
        %                     end
        %                 end
        %             end
        %         case 3
        %             str = obj.PropertyObjectHandles(indx).String;
        %             str = str(1:end-1);
        %             [val,ok] = listdlg('ListString',str,'InitialValue',[],'Name','Select values','PromptString',['Values to search for in "' obj.dbase.PropertyNames{indx} '"']);
        %             if ok == 0
        %                 return
        %             end
        %             for d = 1:obj.TotalFileNumber
        %                 for e = 1:length(obj.dbase.Properties.Names{d})
        %                     if strcmp(obj.dbase.Properties.Names{d}{e},obj.dbase.PropertyNames{indx})
        %                         for f = 1:length(val)
        %                             if strcmp(obj.dbase.Properties.Values{d}{e},str{val(f)})
        %                                 nw = [nw d];
        %                             end
        %                         end
        %                     end
        %                 end
        %             end
        %     end
        %
        %     switch search_type
        %         case 1 % new search
        %             found = nw;
        %         case 2 % AND
        %             found = intersect(prev_search,nw);
        %         case 3 % OR
        %             found = union(prev_search,nw);
        %     end
        %
        %     str = obj.list_Files.String;
        %     for c = 1:obj.TotalFileNumber
        %         str{c}(19:20) = '00';
        %     end
        %     for c = 1:length(found)
        %         str{found(c)}(19:20) = 'FF';
        %     end
        %
        %     obj.list_XXFiles.String = str;
        %
        %     obj.settings.FileSortOrder = [found setdiff(1:obj.TotalFileNumber,found)];
        %     obj.check_Shuffle.Value = 1;
        %     obj.check_Shuffle.String = 'Searched';
        %     obj.edit_FileNumber.String = num2str(obj.settings.FileSortOrder(1));
        %
        %     obj.eg_LoadFile();
        
        
        end
        function menu_SearchNew_Callback(obj, hObject, event)
            obj.SearchProperties(1);
        end
        function menu_SearchAnd_Callback(obj, hObject, event)
            obj.SearchProperties(2);
        end
        function menu_SearchOr_Callback(obj, hObject, event)
            obj.SearchProperties(3);
        end
        function menu_SearchNot_Callback(obj, hObject, event)
            error('Searching not implemented yet')
        
        %     str = obj.list_XXFiles.String;
        %     found = [];
        %     for c = 1:obj.TotalFileNumber
        %         if strcmp(str{c}(19),'F')
        %             str{c}(19:20) = '00';
        %         else
        %             str{c}(19:20) = 'FF';
        %             found = [found c];
        %         end
        %     end
        %
        %     obj.list_XXFiles.String = str;
        %
        %     obj.settings.FileSortOrder = [found setdiff(1:obj.TotalFileNumber,found)];
        %     obj.check_Shuffle.Value = 1;
        %     obj.check_Shuffle.String = 'Searched';
        %     obj.edit_FileNumber.String = num2str(obj.settings.FileSortOrder(1));
        %
        %     obj.eg_LoadFile();
        %
        %     guidata(hObject, handles);
        
        
        end
        function menu_RenameProperty_Callback(obj, hObject, event)
            obj.SaveState();
        
            if obj.getNumProperties() == 0
                % No properties to rename, do nothing
                return;
            end
        
            defaultProperty = categorical(obj.dbase.PropertyNames(1), obj.dbase.PropertyNames);
        
            inputs = getInputs('Rename property', {'Property to rename', 'New property name'}, {defaultProperty, char(defaultProperty)}, {'', ''});
            if isempty(inputs)
                % User cancelled, do nothing
                return;
            end
        
            propertyToRename = char(inputs{1});
            newPropertyName = char(inputs{2});
        
            propertyIdx = find(strcmp(propertyToRename, obj.dbase.PropertyNames), 1);
            obj.dbase.PropertyNames{propertyIdx} = newPropertyName;
            obj.UpdateFileInfoBrowser();
        
        
        end
        function menu_FillProperty_Callback(obj, hObject, event)
            if obj.getNumProperties() == 0
                % No properties to fill, do nothing
                return;
            end
        
            defaultProperty = categorical(obj.dbase.PropertyNames(1), obj.dbase.PropertyNames);
            defaultValue = false;
        
            inputs = getInputs('Fill property with value', {'Property to fill', 'Fill value'}, {defaultProperty, defaultValue}, {'', ''});
            if isempty(inputs)
                % User cancelled, do nothing
                return;
            end
        
            obj.SaveState();
        
            propertyToFill = char(inputs{1});
            fillValue = inputs{2};
        
            propertyIdx = find(strcmp(propertyToFill, obj.dbase.PropertyNames), 1);
            obj.dbase.Properties(:, propertyIdx) = fillValue;
            obj.UpdateFileInfoBrowser();
        
        
        
        end
        function menu_ScalebarHeight_Callback(obj, hObject, event)
        
        end
        function menu_ChangeFiles_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return
            end
        
            obj.IsUpdating = 1;
            old_sound_files = obj.dbase.SoundFiles;
            [dbase, cancel] = eg_GatherFiles(obj.PathName, obj.settings.FileString, ...
                obj.settings.DefaultFileLoader, obj.settings.DefaultChannelNumber, ...
                "TitleString", "Update file lists", "GUI", true);
        
            if cancel
                return
            end
        
            obj.SaveState();
        
            obj.dbase = mergeStructures(obj.dbase, dbase);
        
            obj.UpdateFiles(old_sound_files);
        
            obj.LoadFile();
        
        
        
        end
        function menu_DeleteFiles_Callback(obj, hObject, event)
            if ~electro_gui.isDataLoaded(obj.dbase)
                % No data yet, do nothing
                return
            end
        
            obj.SaveState();
        
            fileNames = obj.getFileNames();
        
            [fileNumsToDelete,ok] = listdlg('ListString',fileNames,'Name','Delete files','PromptString','Select files to DELETE','InitialValue',[],'ListSize',[300 450]);
            if ok == 0
                return
            end
        
            old_sound_files = obj.dbase.SoundFiles;
        
            obj.dbase.SoundFiles(fileNumsToDelete) = [];
            for channelNum = 1:length(obj.dbase.ChannelFiles)
                if ~isempty(obj.dbase.ChannelFiles{channelNum})
                    obj.dbase.ChannelFiles{channelNum}(fileNumsToDelete) = [];
                end
            end
        
            obj.UpdateFiles(old_sound_files);
        
            obj.LoadFile();
        
        end
        function menu_AutoApplyYLim_Callback(obj, hObject, event)
        
            if obj.menu_AutoApplyYLim.Checked
                obj.menu_AutoApplyYLim.Checked = 'off';
            else
                obj.menu_AutoApplyYLim.Checked = 'on';
                if obj.menu_AutoApplyYLim.Checked
                    if obj.menu_DisplayValues.Checked
                        % UPDATE THIS
        
        %                 if obj.menu_AnalyzeTop.Checked && obj.menu_AutoLimits1.Checked
        %                     obj.axes_Channel1.YLim = obj.axes_Events.YLim;
        %                 elseif obj.menu_AutoLimits2.Checked
        %                     obj.axes_Channel2.YLim = obj.axes_Events.YLim;
        %                 end
                    end
                end
            end
        
        end
        
        function center_Timescale_Callback(obj, hObject, eventdata) %#ok<*INUSD>
            % When user right clicks on axes_Sonogram, and selects "Center timescale",
            %   display a popup so they can select a center time (default is where they
            %   right-click), and a radius (how much time on either side of center time
            %   to display), then set the timescale accordingly
        
        
            % Get time where user right-clicks
            click_position = obj.axes_Sonogram.CurrentPoint;
            centerTime = click_position(1, 1);
        
            % Prompt user to alter center time if desired, and choose a radius
            prompt = {'Time radius (sec):', 'Center time (sec):'};
            dlgtitle = 'Center timescale';
            dims = [1 35];
            definput = {'1', num2str(centerTime)};
            answer = inputdlg(prompt,dlgtitle,dims,definput);
            if isempty(answer)
                % User pressed cancel
                return;
            end
            radiusTime = str2double(answer{1});
            centerTime = str2double(answer{2});
        
            % Set time
            obj.centerTimescale(centerTime, radiusTime);
        
        end


    end
    methods (Static)   % dbase manipulation methods
        function dbase = InitializeDbase(settings, options)
            % Build empty structure for dbase data to go into, or if a baseDbase is
            % supplied, clear the analyzed data without clearing the settings
            arguments
                settings = defaults_template()   % electro_gui settings, such as that output by defaults_template
                options.NumFiles (1, 1) double = NaN
                options.NumChannels (1, 1) double = NaN
                options.BaseDbase struct = struct()  %InitializeDbase(0, struct())
                options.IncludeHelp (1, 1) logical = false
            end

            if ischar(settings)
                % User passed defaults name instead of function handle
                if ~contains(settings, 'defaults_')
                    % User passed only defaults name, not full filename
                    settings = sprintf('defaults_%s', settings);
                end
                settings = feval(settings);
            end

            gvod = @electro_gui.getValueOrDefault;

            numFiles = options.NumFiles;
            numChannels = options.NumChannels;
            baseDbase = options.BaseDbase;

            if isnan(numFiles)
                try
                    numFiles = electro_gui.getNumFiles(baseDbase);
                catch
                    numFiles = 0;
                end
            end
            if isnan(numChannels)
                try
                    numChannels = electro_gui.getNumChannels(baseDbase);
                catch
                    numChannels = 0;
                end
            end

            if options.IncludeHelp
                dbase.help.General = sprintf('This is a dbase created by electro_gui on %s. In the documentation, ''N'' refers to the number of groups of channel files, and ''C'' refers to the number of non-sound channels. Channel 0 is typically the sound channel.', datetime());
                dbase.help.PathName = 'The root directory where the data can be found';
                dbase.help.Times = 'A 1xN list of timestamps for each group of channel files referenced in the dbase';
                dbase.help.FileLength = 'A 1xN list of the # of samples for each channel 0 (typically the sound channel) file. Note that this will only populate if it has been loaded by electro_gui, otherwise it will remain 0';
                dbase.help.FileReadState = 'A 1xN logical array indicating if each group of channel files has been loaded in electro_gui yet';
                dbase.help.Notes = '';
                dbase.help.SoundFiles = 'A Nx1 struct array of information about the channel 0 (typically the sound channel) files, of the same form returned by the built in ''dir'' function';
                dbase.help.ChannelFiles = 'A 1xC cell array of struct arrays (each of which are Nx1), one for each non-sound channels (channels 1 - C, excluding 0, which is typically the sound channel). Each struct array contains information about the files, of the same form returned by the built in ''dir'' function';
                dbase.help.SoundLoader = 'The name of the function used by electro_gui to load the sound files (channel 0), with the format ''egl_*.m''';
                dbase.help.ChannelLoader = 'A 1xC cell array containing the names of the functions used by electro_gui to load each of the non-sound (channels 1-C) files, with the format ''egl_*.m''';
                dbase.help.Fs = 'The sampling rate of channel 0. Note that this may not be the same for all other channels.';
                dbase.help.SegmentThresholds = 'Threshold value used for segmenting channel 0 (sound) into segments, a.k.a. syllables.';
                dbase.help.SegmentTimes = 'A 1xN cell array containing Sx2 arrays of segment (syllable) start and end times. For example, dbase.SegmentTimes{11}(7, 1) would give you the start time of segment #7 in file #11.';
                dbase.help.SegmentTitles = 'A 1xN cell array of 1xS cell arrays. Each sub-cell array contains the titles given to each segment. For example, dbase.SegmentTitles{11}{7} would give you the title of segment #7 in file #11';
                dbase.help.SegmentIsSelected = 'A 1xN cell array of 1xS logical arrays. Each logical array contains the selected/unselected state of each segment. For example, dbase.SegmentIsSelected{11}(7) would give you true/false indicating whether or not segment #7 in file #11 is selected';
                dbase.help.MarkerTimes = 'A 1xN cell array containing Sx2 arrays of marker start and end times. For example, dbase.SegmentTimes{11}(7, 1) would give you the start time of syllable #7 in file #11.';
                dbase.help.MarkerTitles = 'A 1xN cell array of 1xS cell arrays. Each sub-cell array contains the titles given to each marker. For example, dbase.MarkerTitles{11}{7} would give you the title of marker #7 in file #11';
                dbase.help.MarkerIsSelected = 'A 1xN cell array of 1xS logical arrays. Each logical array contains the selected/unselected state of each marker. For example, dbase.MarkerIsSelected{11}(7) would give you true/false indicating whether or not marker #7 in file #11 is selected';
                dbase.help.EventChannels = '';
                dbase.help.EventChannelIsPseudo = '';
                dbase.help.EventSources = '';
                dbase.help.EventFunctions = '';
                dbase.help.EventFunctionParameters = '';
                dbase.help.EventDetectors = '';
                dbase.help.EventParameters = '';
                dbase.help.EventThresholds = '';
                dbase.help.EventTimes = '';
                dbase.help.EventIsSelected = '';
                dbase.help.EventParts = '';
                dbase.help.Properties = '';
                dbase.help.PropertyNames = '';
            end

            dbase.SoundFiles =          gvod(baseDbase, 'SoundFiles', cell(1, numFiles));
            dbase.ChannelFiles =        gvod(baseDbase, 'ChannelFiles', repmat(cell(1, numFiles), 1, numChannels));
            dbase.SoundLoader =         gvod(baseDbase, 'SoundLoader', '');
            dbase.ChannelLoader =       gvod(baseDbase, 'Channelloader', {});
            dbase.PathName =            gvod(baseDbase, 'PathName', '');

            dbase.Times =               zeros(1,numFiles);
            dbase.FileLength =          zeros(1,numFiles);
            dbase.FileReadState =       false(1, numFiles);
            dbase.Notes =               repmat({''}, 1, numFiles);
            dbase.SegmentThresholds =   inf(1,numFiles);
            dbase.SegmentTimes =        cell(1,numFiles);
            dbase.SegmentTitles =       cell(1,numFiles);
            dbase.SegmentIsSelected =   cell(1,numFiles);
            dbase.MarkerTimes =         cell(1,numFiles);
            dbase.MarkerTitles =        cell(1,numFiles);
            dbase.MarkerIsSelected =    cell(1,numFiles);
            dbase.EventThresholds =     zeros(0,numFiles);

            % Create properties info
            dbase.PropertyNames =       gvod(baseDbase, 'PropertyNames', settings.DefaultProperties.Names);
            dbase.Properties =          gvod(baseDbase, 'Properties', repmat(settings.DefaultProperties.Values, numFiles, 1));

            % Initialize event-related variables
            dbase.EventSources =            gvod(baseDbase, 'EventSources', {});      % Array of event source channel names
            dbase.EventChannels =           gvod(baseDbase, 'EventChannels', {});     % Array of event source channel numbers
            dbase.EventChannelIsPseudo =    gvod(baseDbase, 'EventChannelIsPseudo', logical.empty());  % Array of flags indicating if the source channel is a pseudochannel
            dbase.EventFunctions =          gvod(baseDbase, 'EventFunctions', {});    % Array of event source filter names
            dbase.EventFunctionParameters = gvod(baseDbase, 'EventFunctionParameters', {});  % Array of event source filter parameters
            dbase.EventDetectors =          gvod(baseDbase, 'EventDetectors', {});    % Array of event source detector names
            dbase.EventParameters =         gvod(baseDbase, 'EventParameters', {});   % Array of event source detector parameters
            dbase.EventParts =              gvod(baseDbase, 'EventParts', {});        % Array of event parts
            for eventSourceIdx = 1:length(dbase.EventSources)
                dbase.EventTimes{eventSourceIdx} = cell(0, numFiles);
                dbase.EventIsSelected{eventSourceIdx} = cell(0, numFiles);
            end

            % PseudoChannels are computed channels that show up like regular
            % channels, but they are not directly from one of the channel files on
            % disk; they are computed from other information.

            dbase = electro_gui.UpdateChannelInfo(dbase);
        end
        function isLoaded = isDataLoaded(dbase)
            % Check if data is loaded yet
            isLoaded = (electro_gui.getNumFiles(dbase) > 0);
        end
        function dbase = UpdateChannelInfo(dbase, options)
            % Update the dbase channel info structure based on the files in the
            % dbase
            arguments
                dbase struct
                options.KeepPseudoChannels (1, 1) logical = false
            end

            % Do not discard pseudochannels
            if options.KeepPseudoChannels
                pseudoChannelInfo = dbase.ChannelInfo([dbase.ChannelInfo.IsPseudoChannel]);
            else
                pseudoChannelInfo = struct.empty();
            end

            dbase.ChannelInfo(1) = electro_gui.CreateChannelInfo('(None)', [], 'None', false, struct());
            dbase.ChannelInfo(2) = electro_gui.CreateChannelInfo('Sound', 0, 'Sound', false, struct());
            idx = length(dbase.ChannelInfo)+1;
            for channelNum = 1:length(dbase.ChannelFiles)
                if ~isempty(dbase.ChannelFiles{channelNum})
                    name = sprintf('Channel %d', channelNum);
                    dbase.ChannelInfo(idx) = electro_gui.CreateChannelInfo(name, channelNum, 'Channel', false, struct());
                    idx = idx + 1;
                end
            end
            if ~isempty(pseudoChannelInfo)
                dbase.ChannelInfo = [dbase.ChannelInfo, pseudoChannelInfo];
            end
        end
        function pseudoChannelNum = channelIdxToPseudoChannelNum(dbase, channelIdx)
            % Convert a channel index (for which base and pseudo channels are
            %   numbered together consecutively) to a pseudo channel number (which
            %   is numbered only for pseudo channels). If the given channel number
            %   does not correspond to a pseudo channel, then pseudoChannelNum will
            %   be an empty array
            channelInfo = dbase.ChannelInfo(channelIdx);
            if channelInfo.IsPseudoChannel
                pseudoChannelNum = channelInfo.Number;
            else
                pseudoChannelNum = [];
            end
        end
        function isPseudoChannel = isChannelPseudo(dbase, channelIdx)
            % Return whether or not the given channel number corresponds to a
            % pseudo channel (true) or a base channel (false)
            isPseudoChannel = dbase.ChannelInfo(channelIdx).IsPseudoChannel;
        end
        function str = getPseudoChannelDescription(name, type, desc)
            str = sprintf('%s - %s` (%s)', name, type, desc);
        end
        function numFiles = getNumFiles(dbase)
            numFiles = length(dbase.SoundFiles);
        end
        function numChannels = getNumChannels(dbase)
            % Return number of channels (not including pseudochannels)
            numChannels = length(dbase.ChannelFiles);
        end
        function currentFileNum = getCurrentFileNum(settings)
            currentFileNum = settings.CurrentFile;
        end
        function currentFileName = getCurrentFileName(dbase, settings)
            currentFileNum = electro_gui.getCurrentFileNum(settings);
            currentFileName = dbase.SoundFiles(currentFileNum).name;
        end
        function isSound = isChannelSound(channelNum)
            isSound = (channelNum == 0);
        end
        function channelName = channelNumToName(channelNum, isPseudoChannel)
            arguments
                channelNum (1, 1) double
                isPseudoChannel (1, 1) logical = false
            end
            if isPseudoChannel
                channelName = sprintf('PseudoChannel %d', channelNum);
            else
                channelName = sprintf('Channel %d', channelNum);
            end
        end
        function [channelNum, isPseudoChannel] = channelNameToNum(dbase, channelName)
            listIdx = find(strcmp(channelName, {dbase.ChannelInfo.Name}), 1);
            if length(listIdx) ~= 1 || listIdx == 1
                % Either not found, multiple matches, or the (None) entry
                channelNum = [];
                isPseudoChannel = false;
            else
                % One match found
                channelInfo = dbase.ChannelInfo(listIdx);
                channelNum = channelInfo.Number;
                isPseudoChannel = channelInfo.IsPseudoChannel;
            end
        end
        function [channelNum, isPseudoChannel] = channelNameToNumLegacy(channelName)
            tokens = regexp(channelName, 'Channel ([0-9]+)', 'tokens');
            if isempty(tokens) || isempty(tokens{1})
                channelNum = NaN;
            else
                channelNum = str2double(tokens{1}{1});
            end
            isPseudoChannel = false;
        end
        function numPseudoChannels = getNumPseudoChannels(dbase)
            numPseudoChannels = sum([dbase.ChannelInfo.IsPseudoChannel]);
        end
        function sorted = areFilesSorted(settings)
            % Check if files are sorted in some way other than as normal (by file
            % number)
            sorted = ~strcmp(settings.FileSortMethod, 'File number');
        end

        function dbase = createEventPseudoChannel(dbase, eventSourceIdx, eventPartIdx)
            % Create an "event" type pseudochannel
            pseudoChannelNum = electro_gui.getNumPseudoChannels(dbase) + 1;
            eventPartName = dbase.EventParts{eventSourceIdx}{eventPartIdx};
            baseChannelIsPseudo = dbase.EventChannelIsPseudo(eventSourceIdx);
            baseChannelName = electro_gui.channelNumToName(dbase.EventChannels(eventSourceIdx), baseChannelIsPseudo);
            pseudoChannelInfo.type = 'event';
            pseudoChannelInfo.eventSourceIdx = eventSourceIdx;
            pseudoChannelInfo.eventPartIdx = eventPartIdx;
            pseudoChannelInfo.description = sprintf('%s of events in %s', eventPartName, baseChannelName);
        
            % Make sure this isn't a duplicate pseudochannel
            for k = 1:length(dbase.ChannelInfo)
                if strcmp(dbase.ChannelInfo(k).Type, 'PseudoChannel') && ...
                   strcmp(dbase.ChannelInfo(k).PseudoChannelInfo.type, 'event')
                    % This is an event-type pseudochannel
                    if eventSourceIdx == dbase.ChannelInfo(k).PseudoChannelInfo.eventSourceIdx && ...
                       eventPartIdx ==   dbase.ChannelInfo(k).PseudoChannelInfo.eventPartIdx
                        % This pseudochannel already exists
                        error('PseudoChannel already exists - eventSourceIdx=%d, eventPartIdx=%d', eventSourceIdx, eventPartIdx);
                    end
                end
            end
        
            name = sprintf('PseudoChannel %d', pseudoChannelNum);
            number = electro_gui.getNumPseudoChannels(dbase) + 1;
            type = 'PseudoChannel';
            dbase.ChannelInfo(end+1) = electro_gui.CreateChannelInfo(name, number, type, true, pseudoChannelInfo);
        end
        function dbase = setProperties(dbase, properties, propertyNames)
            % Set all property info
            arguments
                dbase struct
                properties
                propertyNames
            end
            if isempty(properties)
                % If there are no properties, initialize the property vector to an
                % appropriate empty size
                dbase.Properties = false(electro_gui.getNumFiles(dbase), 0);
            else
                % Assign properties
                dbase.Properties = properties;
            end
            dbase.PropertyNames = propertyNames;
        end
        function channelIdx = getChannelIdxFromPseudoChannelNumber(dbase, pseudoChannelNum)
            channelIdx = [];
            for k = 1:length(dbase.ChannelInfo)
                if dbase.ChannelInfo(k).IsPseudoChannel && ...
                   ~isempty(dbase.ChannelInfo(k).Number) && ...
                   pseudoChannelNum == dbase.ChannelInfo(k).Number
                    channelIdx = k;
                    return;
                end
            end
        end
    end
    methods (Static)   % Other utility functions
        function user = getUser()
            % Get current logged in username
            lic = license('inuse');
            user = lic(1).user;
            f = regexpi(user,'[A-Z1-9]');
            user = user(f);
        end
        function defaults = warnAndFixLegacyDefaults(defaults)
            msgs = {};
            if isfield(defaults, 'EventLims')
                msgs{end+1} = 'Replace ''EventLims'' with ''DefaultEventXLims''';
                defaults.DefaultEventXLims = defaults.EventLims;
                defaults = rmfield(defaults, 'EventLims');
            end
            if iscell(defaults.DefaultProperties.Values)
                msgs{end+1} = 'DefaultProperties.Values should be a logical array, not a cell array (for example [false, false, true])';
                defaults.DefaultProperties.Values = cell2mat(defaults.DefaultProperties.Values);
            end
            if ~isempty(msgs)
                fprintf('\n*************************************************************************************************************\n')
                warning('Your defaults file is out of date - please address the following issues:');
                for k = 1:length(msgs)
                    fprintf('\t%d) %s\n', k, msgs{k});
                end
                fprintf('***************************************************************************************************************\n\n')
            end
        end
        function settingValue = getValueOrDefault(dbase, settingKey, default)
            if ~isfield(dbase, settingKey) || isempty(dbase.settingKey)
                settingValue = default;
            else
                settingValue = dbase.(settingKey);
            end
        end
        %% Plugin related utility functions
        function [pluginNames, pluginTypes] = getPluginNamesFromFilenames(pluginFilenames)
            % Extract the plain names and types of electro_gui plugin from a list of their filenames
            pluginNames = cell(size(pluginFilenames));
            pluginTypes = cell(size(pluginFilenames));
            for k = 1:length(pluginFilenames)
                [pluginNames{k}, pluginTypes{k}] = electro_gui.getPluginNameFromFilename(pluginFilenames{k});
            end
        end
        function [pluginName, pluginType] = getPluginNameFromFilename(pluginFilename)
            % Extract the plain name and type of an electro_gui plugin from its filename
            pluginNamePattern = '(.*?)_(.*)\.m';
            tokens = regexp(pluginFilename, pluginNamePattern, 'tokens');
            pluginName = tokens{1}{2};
            pluginType = tokens{1}{1};
        end
        function menus = populatePluginMenuList(pluginInfoList, defaultPluginName, menuList, callback)
            % Populate a dropdown menu for selecting plugins

            % Get plugin names
            pluginNames = {pluginInfoList.name};
            % Create a menu item for each plugin
            menus = gobjects().empty;
            for pluginIdx = 1:length(pluginNames)
                menus(end+1) = uimenu(menuList, 'Label', pluginNames{pluginIdx}, 'Callback', callback);
            end
            if ~isempty(defaultPluginName)
                % Identify where the default plugin is in the list
                defaultPluginIdx = find(strcmp(defaultPluginName, pluginNames), 1);
                if isempty(defaultPluginIdx)
                    % Default plugin did not match any available plugins
                    defaultPluginIdx = 1;
                end
                % Check the default plugin if it's in the list, otherwise the first one
                menus(defaultPluginIdx).Checked = 'on';
            end
        end
        function isPlugin = isValidPlugin(plugins, name)
            % Check if name corresponds to one of the provided list of plugins
            for k = 1:length(plugins)
                if strcmp(name, plugins(k).name)
                    isPlugin = true;
                    return
                end
            end
            isPlugin = false;
        end
        function out = findPlugins(root, prefix)
            % Create a struct array containing the name and function handle for all
            % electro_gui plugin functions with the given prefix (for example 'egl_')
            allowedCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
            pattern = sprintf('%s_.*\\.m', prefix);
            pluginPaths = findFiles(root, "RegexPattern", pattern, "SearchSubdirectories", false);
            for k = 1:length(pluginPaths)
                [~, fileName, ~] = fileparts(pluginPaths{k});
                name = regexp(fileName, [prefix, '_(.*)'], 'tokens', 'once');
                name = name{1};
                okChars = ismember(name, allowedCharacters);
                if any(~okChars)
                    % Name contains disallowed characters
                    disallowedChars = sort(unique(name(~okChars)));
                    warning('Name of plugin ''%s'' contains disallowed characters: ''%s''\nPlease change plugin name so it only includes the characters: \n%s', name, disallowedChars, allowedCharacters);
                    continue;
                end
                func = str2func(fileName);
                out(k).name = name;
                out(k).func = func;
                out(k).nargout = nargout(func);
                out(k).prefix = prefix;
                out(k).path = pluginPaths{k};
            end
        end
        function plugins = gatherPlugins(sourceDir)
            % Gather all electro_gui plugins
            arguments
                sourceDir char = fileparts(mfilename("fullpath"))
            end

            % Find all spectrum algorithms
            plugins.spectrums = electro_gui.findPlugins(sourceDir, 'egs');
            % Find all segmenting algorithms
            plugins.segmenters = electro_gui.findPlugins(sourceDir, 'egg');
            % Find all filters
            plugins.filters = electro_gui.findPlugins(sourceDir, 'egf');
            % Find all colormaps
            plugins.colorMaps = electro_gui.findPlugins(sourceDir, 'egc');
            % % Find all function algorithms
            plugins.functions = electro_gui.findPlugins(sourceDir, 'egf');
            % Find all macros
            plugins.macros = electro_gui.findPlugins(sourceDir, 'egm');
            % Find all event detector algorithms
            plugins.eventDetectors = electro_gui.findPlugins(sourceDir, 'ege');
            % Find all event feature algorithms
            plugins.eventFeatures = electro_gui.findPlugins(sourceDir, 'ega');
            % Find all loaders
            plugins.loaders= electro_gui.findPlugins(sourceDir, 'egl');
        end
        function channelEntry = CreateChannelInfo(name, number, type, isPseudoChannel, pseudoChannelInfo)
            channelEntry.Name = name;
            channelEntry.Number = number;
            channelEntry.Type = type;
            channelEntry.IsPseudoChannel = isPseudoChannel;
            channelEntry.PseudoChannelInfo = pseudoChannelInfo;
        end
        function varargout = eg_runPlugin(pluginGroup, name, varargin)
            % Look for the requested plugin by name, then run it with the
            %   given arguments, and return arbitrary output arguments
            %
            % pluginGroup: A struct array containing plugin info, created by the
            %   electro_gui.gatherPlugins/electro_gui.findPlugins functions. This is stored in the electro_gui
            %   obj structure as obj.plugins.(groupName) where groupName is the
            %   name of a plugin type, such as:
            %   - spectrums
            %   - segmenters
            %   - filters
            %   - colormaps
            %   - macros
            %   - eventDetectors
            %   - eventFeatures
            %   - loaders
            % name: The name of the plugin, without the 'eg*_' prefix, and without the
            %   file extension.
            % varargin: Arbitrary number of input arguments for the plugin
            % varargout: Arbitrary output arguments from the plugin

            foundIt = false;
            for k = 1:length(pluginGroup)
                if strcmp(pluginGroup(k).name, name)
                    plugin = pluginGroup(k).func;
                    foundIt = true;
                    break;
                end
            end
            if foundIt
                varargout = cell(1, nargout);
                % Run plugin and gather output arguments.
                [varargout{:}] = plugin(varargin{:});
            else
                error('Attempted to run plugin ''%s'', but it could not be found.', name);
            end
        end
        function GenericCreateFcn(hObject, eventdata)
            if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
                hObject.BackgroundColor = 'white';
            end
        end
        function shortFilenames = getMinimalFilenmes(filenames)
            % Look through a list of filenames and discard chunks at the beginning
            % and/or end that are the same for all of them. A chunk is delimited by
            % '_', '-', '.', or ' '
            delimiters = {'_', '-', '.', ' '};
            [filenameChunks, chunkDelimiters] = cellfun(@(filename)split(filename, delimiters), filenames, 'UniformOutput', false);
            numChunks = cellfun(@length, filenameChunks);
            numStartChunksToDiscard = 0;
            numEndChunksToDiscard = 0;
            minChunkNum = min(numChunks);
            for chunkNum = 1:minChunkNum
                chunks = cellfun(@(chunks)chunks{chunkNum}, filenameChunks, 'UniformOutput', false);
                if ~all(strcmp(chunks{1}, chunks))
                    % This chunk differs
                    numStartChunksToDiscard = chunkNum - 1;
                    break;
                end
            end
            for chunkNum = 1:minChunkNum
                chunks = cellfun(@(chunks)chunks{end-chunkNum+1}, filenameChunks, 'UniformOutput', false);
                if ~all(strcmp(chunks{1}, chunks))
                    % This chunk differs
                    numEndChunksToDiscard = chunkNum - 1;
                    break;
                end
            end
            reassembler = @(chunks, chunkDelims) ...
                join(chunks(numStartChunksToDiscard+1:end-numEndChunksToDiscard), ...
                     chunkDelims(numStartChunksToDiscard+1:end-numEndChunksToDiscard));
            shortFilenames = cellfun(reassembler, filenameChunks, chunkDelimiters, 'UniformOutput', false);
            shortFilenames = cellfun(@(x)x{1}, shortFilenames, 'UniformOutput', false);
        end
        function helpText = HelpText()

            helpText = sprintf('%s\n', ...
            'electro_gui:', ...
            '',...
            'A graphical tool for analyzing audio and neural data. Created a long',...
            'time ago, possibly by Aaron Andalman. Modified by Brian Kardon, and ',...
            'probably others before him.',...
            '',...
            'Keyboard actions:', ...
            '    General:', ...
            '        Ctrl-N - New experiment', ...
            '        Ctrl-O - Open dbase', ...
            '        Ctrl-Shift-O - Open most recently used dbase', ...
            '        Ctrl-S - Save dbase', ...
            '        Ctrl-space - play sound', ...
            '        . (period) - switch to previous file', ...
            '        , (comma) - switch to next file', ...
            '        ctrl-e - create export figure', ...
            '    Segment/Marker related:', ...
            '        a-z, A-Z, 0-9 - label the active segment or marker', ...
            '        ` (backtick or tilde key) - convert active segment to marker',...
            '            or vice versa.', ...
            '        backspace - clear the label for the active segment or marker', ...
            '        right/left arrow - make previous or next segment or marker',...
            '            active', ...
            '        up/down arrow - switch active element from marker to segment',...
            '            or back', ...
            '        space - if segment is active, join it with the next one (no',...
            '            effect on markers)', ...
            '        enter - toggle whether the segment is selected or not', ...
            '        delete - delete currently active segment or marker', ...
            'Mouse actions:', ...
            '    General:', ...
            '        Shift-move mouse over axes - see alignment cursor', ...
            '        Scroll wheel - zoom view in/out', ...
            '        Shift-scroll wheel - shift view forward/back in time', ...
            '        Click on spectrogram: Set left side of zoom window at click',...
            '            time', ...
            '        Shift-click on spectrogram: Set right side of zoom window at',...
            '            click time', ...
            '        Click-drag on spectrogram: Zoom in', ...
            '        Double-click on spectrogram: Zoom all the way out', ...
            '        Scroll wheel over any axes: Zoom in/out', ...
            '    Segment/Marker related:', ...
            '        Ctrl-click-drag on spectrogram: Create marker', ...
            '        Shift-click on sound amplitude: Set segment threshold',...
            '            (destroys all existing segments): ', ...
            '    Event related', ...
            '        Click on event viewer: Set active event', ...
            '        Ctrl-click on channel axes: Set event detector threshold', ...
            '        Ctrl-click+drag on channel axes: Set local threshold', ...
            '        Shift-click+drag on channel axes: Unselect events', ...
            '        Ctrl-click+drag on event viewer: Unselect events', ...
            '', ...
            '', ...
            '');
        end
        
        function threshold = eg_AutoThreshold(amp)
            % by Aaron Andalman

            if mean(amp)<0
                amp = -amp;
                isneg=1;
            else
                isneg=0;
            end
            if range(amp)==0
                threshold = inf;
                return;
            end
        
            try
                % Code from Aaron Andalman
                [noiseEst, soundEst, noiseStd, soundStd] = eg_estimateTwoMeans(amp);
                if (noiseEst>soundEst)
                    disc = max(amp)+eps;
                else
                    %Compute the optimal classifier between the two gaussians...
                    p(1) = 1/(2*soundStd^2+eps) - 1/(2*noiseStd^2);
                    p(2) = (noiseEst)/(noiseStd^2) - (soundEst)/(soundStd^2+eps);
                    p(3) = (soundEst^2)/(2*soundStd^2+eps) - (noiseEst^2)/(2*noiseStd^2) + log(soundStd/noiseStd+eps);
                    disc = roots(p);
                    disc = disc(disc>noiseEst & disc<soundEst);
                    if(isempty(disc))
                        disc = max(amp)+eps;
                    else
                        disc = disc(1);
                        disc = soundEst - 0.5 * (soundEst - disc);
                    end
                end
                threshold = disc;
        
                if ~isreal(threshold)
                    threshold = max(amp)*1.1;
                end
            catch
                threshold = max(amp)*1.1;
            end
        
            if isneg
                threshold = -threshold;
            end
        
        end
        function [dbase, settings] = updateDbaseFormat(dbase, settings, options)
            % Update legacy dbase format to current format
            arguments
                dbase struct
                settings struct = defaults_template()
                options.SourceDir = fileparts(mfilename("fullpath"))
            end
        
            % If the legacy field AnalysisState exists, merge the given settings
            % with the settings from defaults_template.
            if isfield(dbase, 'AnalysisState')
                settings = mergeStructures(settings, dbase.AnalysisState, "Overwrite", true);
                dbase = rmfield(dbase, 'AnalysisState');
            end
        
            sourceDir = options.SourceDir;
        
            numFiles = length(dbase.SoundFiles);
            numEventSources = length(dbase.EventTimes);
        
            if ~isfield(dbase, 'EventParts')
                % Legacy dbases did not have a list of event part names
                dbase.EventParts = {};
                if ~exist('plugins', 'var')
                    plugins = electro_gui.gatherPlugins(sourceDir); %#ok<*PROPLC>
                end
                for eventSourceIdx = 1:length(dbase.EventTimes)
                    eventDetectorName = dbase.EventDetectors{eventSourceIdx};
                    [~, eventParts] = electro_gui.eg_runPlugin(plugins.eventDetectors, eventDetectorName, 'params');
                    dbase.EventParts{eventSourceIdx} = eventParts;
                end
            end
        
            if ~isfield(dbase, 'EventChannels')
                % Legacy dbases do not have a list of channel numbers, only channel
                % names (stored in "EventSources" field)
                dbase.EventChannels = cellfun(@electro_gui.channelNameToNumLegacy, dbase.EventSources, 'UniformOutput', true);
            end
        
            if ~isfield(dbase, 'EventChannelIsPseudo')
                dbase.EventChannelIsPseudo = false(1, numEventSources);
            end
        
            if ~isfield(dbase, 'ChannelInfo')
                dbase = electro_gui.UpdateChannelInfo(dbase);
                if isfield(dbase, 'PseudoChannelNames') || ...
                   isfield(dbase, 'PseudoChannelTypes') || ...
                   isfield(dbase, 'PseudoChannelInfo')
                    % Dbases briefly had these fields to keep track of
                    % pseudochannel info, but this has been combined into
                    % dbase.ChannelInfo
                    for k = 1:length(dbase.PseudoChannelNames)
                        info = dbase.PseudoChannelInfo{k};
                        dbase = electro_gui.createEventPseudoChannel(dbase, info.eventSourceIdx, info.eventPartIdx);
                    end
                else
                    % For older legacy databases, we have to generate the pseudochannels
                    for eventSourceIdx = 1:length(dbase.EventTimes)
                        for eventPartIdx = 1:length(dbase.EventParts{eventSourceIdx})
                            dbase = electro_gui.createEventPseudoChannel(dbase, eventSourceIdx, eventPartIdx);
                        end
                    end
                end
            end
        
            % Ensure EventSelected field is all logical not double
            for eventSourceIdx = 1:numEventSources
                for filenum = 1:numFiles   %length(dbase.EventIsSelected{eventSourceIdx})
                    dbase.EventIsSelected{eventSourceIdx}{filenum} = logical(dbase.EventIsSelected{eventSourceIdx}{filenum});
                end
            end
        
            if ~isfield(dbase, 'EventParameters')
                % Legacy dbases do not have a list of event parameters
                dbase.EventParameters = cell(1, numEventSources);
                if ~exist('plugins', 'var')
                    plugins = electro_gui.gatherPlugins(sourceDir);
                end
        
                for eventSourceIdx = 1:numEventSources
                    eventDetectorName = dbase.EventDetectors{eventSourceIdx};
                    eventParameters = electro_gui.eg_runPlugin(plugins.eventDetectors, eventDetectorName, 'params');
                    dbase.EventParameters{eventSourceIdx} = eventParameters;
                end
            end
        
            if ~isfield(dbase, 'EventFunctionParameters')
                % Legacy dbases do not have a list of event parameters
                dbase.EventFunctionParameters = cell(1, numEventSources);
                if ~exist('plugins', 'var')
                    plugins = electro_gui.gatherPlugins(sourceDir);
                end
                for eventSourceIdx = 1:numEventSources
                    filterName = dbase.EventFunctions{eventSourceIdx};
                    try
                        filterParameters = electro_gui.eg_runPlugin(plugins.filters, filterName, 'params');
                        dbase.EventFunctionParameters{eventSourceIdx} = filterParameters;
                    catch
                        emptyParams.Names = {};
                        emptyParams.Values = {};
                        dbase.EventFunctionParameters{eventSourceIdx} = emptyParams;
                    end
                end
            end
        
            % FileReadState has been moved from main dbase to settings
            if ~isfield(settings, 'FileReadstate')
                if isfield(dbase, 'FileReadState')
                    settings.FileReadState = dbase.FileReadState;
                else
                    settings.FileReadState = false(1, numFiles);
                end
            end
            if isfield(dbase, 'FileReadState')
                dbase = rmfield(dbase, 'FileReadState');
            end
        
            if ~isfield(settings, 'EventThresholdDefaults') || length(settings.EventThresholdDefaults) ~= numEventSources
                % Legacy dbases did not have stored defaults - initialize a new one
                if isempty(dbase.EventThresholds)
                    settings.EventThresholdDefaults = inf(1, numEventSources);
                else
                    % Use the most common non-infinite threshold for each event
                    % source
        
                    % Make a copy of all the thresholds
                    thresholds = dbase.EventThresholds;
                    % Replace inf with NaN to exclude it from the mode calculation
                    thresholds(thresholds == inf) = NaN;
                    % Find the most commonly used threshold
                    thresholds = mode(thresholds, 2);
                    % If one of the event sources was all infinity ==> all nan,
                    % then the mode will show up as nan. Replace those with inf.
                    thresholds(isnan(thresholds)) = inf;
                    % Copy into defaults variable
                    settings.EventThresholdDefaults = thresholds;
                end
            end
        
            if ~isfield(settings, 'CurrentFile')
                settings.CurrentFile = 1;
            end
        
            if isstruct(dbase.Properties)
                % This is a legacy format for properties - import it
                % Get every property name across dbase
                propertyNames = unique([dbase.Properties.Names{:}], 'stable');
                propertyValues = false(numFiles, length(propertyNames));
                for filenum = 1:numFiles
                    for oldPropertyIdx = 1:length(dbase.Properties.Names{filenum})
                        propertyType = dbase.Properties.Types{filenum}(oldPropertyIdx);
                        switch propertyType
                            case 1
                                %
                            case 2
                                % Boolean
                                propertyName = dbase.Properties.Names{filenum}{oldPropertyIdx};
                                newPropertyIdx = find(strcmp(propertyName, propertyNames), 1);
                                propertyValues(filenum, newPropertyIdx) = dbase.Properties.Values{filenum}{oldPropertyIdx};
                            case 3
                                %
                        end
                    end
                end
                % Set properties
                dbase = electro_gui.setProperties(dbase, propertyValues, propertyNames);
            end
        
            if ~isfield(settings, 'FileSortMethod')
                settings.FileSortMethod = 'File number';
            end
        
            if ~isfield(settings, 'FileSortPropertyName')
                if isfield(dbase, 'FileSortPropertyName')
                    settings.FileSortPropertyName = dbase.FileSortPropertyName;
                else
                    settings.FileSortPropertyName = '';
                end
            end
            if isfield(dbase, 'FileSortPropertyName')
                dbase = rmfield(dbase, 'FileSortPropertyName');
            end
        
            if ~isfield(settings, 'FileSortReversed')
                settings.FileSortReversed = false;
            end
        
            if ~isfield(dbase, 'Notes')
                % Legacy dbase - create empty notes
                dbase.Notes = repmat({''}, 1, numFiles);
            end
        
            if ~isfield(settings, 'AuxiliarySoundSources')
                settings.AuxiliarySoundSources = {};
            end
        
            if ~isfield(dbase, 'MarkerTimes')
                % This must be an older type of dbase - add blank marker field
                dbase.MarkerTimes = cell(1,numFiles);
            end
            if ~isfield(dbase, 'MarkerTitles')
                % This must be an older type of dbase - add blank marker field
                dbase.MarkerTitles = cell(1,numFiles);
            end
            if ~isfield(dbase, 'MarkerIsSelected')
                % This must be an older type of dbase - add blank marker field
                dbase.MarkerIsSelected = cell(1,numFiles);
            end
        
            if isfield(dbase, 'EventXLims')
                % This is now in settings.EventXLims, but legacy dbases
                % may have it simply in dbase.EventXLims, so look for it here too
                settings.EventXLims = dbase.EventXLims;
            end
            if isfield(dbase, 'EventLims')
                % Due to a typo some dbases may have this as EventLims
                settings.EventXLims = dbase.EventXLims;
            end
            if ~isfield(settings, 'EventXLims') || isempty(settings.EventXLims)
                settings.EventXLims = settings.DefaultEventXLims;
            end
        
            if size(settings.EventXLims, 1) ~= length(dbase.EventSources)
                % Legacy dbases had event xlims per channel axes, not per file,
                % so not complete.
                for eventSourceIdx = 1:length(dbase.EventTimes)
                    settings.EventXLims(eventSourceIdx, :) = settings.EventXLims;
                end
            end
        end
        function [uNoise, uSound, sdNoise, sdSound] = eg_estimateTwoMeans(audioLogPow)
        
            %Run EM algorithm on mixture of two gaussian model:
        
            %set initial conditions
            l = length(audioLogPow);
            len = 1/l;
            m = sort(audioLogPow);
            uNoise = median(m(fix(1:length(m)/2)));
            uSound = median(m(fix(length(m)/2:length(m))));
            sdNoise = 5;
            sdSound = 20;
        
            %compute estimated log likelihood given these initial conditions...
            prob = zeros(2,l);
            prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2)))./sdNoise;
            prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2)))./sdSound;
            [estProb, class] = max(prob);
            warning off
            logEstLike = sum(log(estProb)) * len;
            warning on
            logOldEstLike = -Inf;
        
            %maximize using Estimation Maximization
            while(abs(logEstLike-logOldEstLike) > .005)
                logOldEstLike = logEstLike;
        
                %Which samples are noise and which are sound.
                nndx = find(class==1);
                sndx = find(class==2);
        
                %Maximize based on this classification.
                uNoise = mean(audioLogPow(nndx));
                sdNoise = std(audioLogPow(nndx));
                if ~isempty(sndx)
                    uSound = mean(audioLogPow(sndx));
                    sdSound = std(audioLogPow(sndx));
                else
                    uSound = max(audioLogPow);
                    sdSound = 0;
                end
        
                %Given new parameters, recompute log likelihood.
                prob(1,:) = (exp(-(audioLogPow - uNoise).^2 / (2*sdNoise^2+eps)))./(sdNoise+eps);
                prob(2,:) = (exp(-(audioLogPow - uSound).^2 / (2*sdSound^2+eps)))./(sdSound+eps)+eps;
                [estProb, class] = max(prob);
                logEstLike = sum(log(estProb+eps)) * len;
            end
        
        
        end
        function inside = areCoordinatesIn(x, y, figureChild)
            % Check if given normalized figure coordinates are inside the borders
            % of one or more children of that figure.
            for k = 1:length(figureChild)
                if x < figureChild(k).Position(1)
                    inside = false;
                elseif x > figureChild(k).Position(1) + figureChild(k).Position(3)
                    inside = false;
                elseif y < figureChild(k).Position(2)
                    inside = false;
                elseif y > figureChild(k).Position(2) + figureChild(k).Position(4)
                    inside = false;
                else
                    inside = k;
                    return;
                end
            end
        end
        function [x, y] = convertFigCoordsToChildAxesCoords(xFig, yFig, childAxes)
            xAx0 = childAxes.Position(1);
            yAx0 = childAxes.Position(2);
            wAx = childAxes.Position(3);
            hAx = childAxes.Position(4);
            xAx = (xFig - xAx0)/wAx;
            yAx = (yFig - yAx0)/hAx;
            x = childAxes.XLim(1) + diff(childAxes.XLim)*xAx;
            y = childAxes.YLim(1) + diff(childAxes.YLim)*yAx;
        end
        function nextIdx = findNextTrueIdx(mask, startIdx, direction)
            % Given a mask and a starting index, find the next true value in
            % the mask in the given direction.
        
            if direction > 0
                nextIdx = find(mask(startIdx+1:end), 1) + startIdx;
                if isempty(nextIdx)
                    % None found between startIdx and end - try from the beginning
                    % to the startIdx
                    nextIdx = find(mask(1:startIdx-1), 1);
                end
            elseif direction < 0
                nextIdx = find(mask(1:startIdx-1), 1, "last");
                if isempty(nextIdx)
                    % None found from startIdx to 1 - try from the end to startIdx
                    nextIdx = find(mask(startIdx+1:end), 1, "last") + startIdx;
                end
            else
                nextIdx = startIdx;
            end
        end
        function h = eg_peak_detect(ax,x,y)
            % Plot an envelope of the signal "y", downsampled to fit in the axes width
            ax.Units = 'pixels';
            ax.Parent.Units = 'pixels';
            pos = ax.Position;
            width = fix(pos(3));
            ax.Parent.Units = 'normalized';
            ax.Units = 'normalized';
        
            xl = xlim(ax);
            if length(y) < width*3
                h = plot(ax, x,y);
            else
                ynew = zeros(1,ceil(length(y)/width)*width);
                nadd = length(ynew)-length(y);
                pos = round(linspace(1,length(ynew),nadd+2));
                pos = pos(2:end-1);
                ynew(setdiff(1:length(ynew),pos)) = y;
                ynew(pos) = ynew(pos-1);
                y = reshape(ynew,length(ynew)/width,width);
        
                h(1) = plot(ax, linspace(min(x),max(x),size(y,2)),max(y,[],1));
                hold(ax, 'on');
                h(2) = plot(ax, linspace(min(x),max(x),size(y,2)),min(y,[],1));
                hold(ax, 'off');
            end
            xlim(ax, xl);
        end
        function ind = getSortedArrayInsertion(sortedArr, value)
            [~, ind] = min(abs(sortedArr-value));
            ind = ind + (value > sortedArr(ind));
        end
    end
end
