function varargout = electro_gui(varargin)
    % ELECTRO_GUI M-file for electro_gui.fig
    %      ELECTRO_GUI, by itself, creates a new ELECTRO_GUI or raises the existing
    %      singleton*.
    %
    %      H = ELECTRO_GUI returns the handle to a new ELECTRO_GUI or the handle to
    %      the existing singleton*.
    %
    %      ELECTRO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in ELECTRO_GUI.M with the given input arguments.
    %
    %      ELECTRO_GUI('Property','Value',...) creates a new ELECTRO_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before electro_gui_OpeningFunction gets called.  An
    %      unrecognized property name or invalid value makes property
    %      application
    %      stop.  All inputs are passed to electro_gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help electro_gui
    
    % Last Modified by GUIDE v2.5 17-Feb-2024 22:17:26
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @electro_gui_OpeningFcn, ...
        'gui_OutputFcn',  @electro_gui_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
    
% --- Executes just before electro_gui is made visible.
function electro_gui_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to electro_gui (see VARARGIN)
    
    
    % Allow macros to call individual functions within ElectroGui
    if ~isempty(varargin)
        str = ['''' varargin{1} ''','];
        for c = 2:length(varargin)
            str = [str 'varargin{c},']; %#ok<*AGROW> 
        end
        str = str(1:end-1);
        handles.output = eval(['feval(' str ')']);
        guidata(hObject, handles);
        return
    end
    
    % Make ElectroGui's directory the current directory
    [pathstr, ~, ~] = fileparts(mfilename('fullpath'));
    cd(pathstr);

    % Get current logged in username
    lic = license('inuse');
    user = lic(1).user;
    f = regexpi(user,'[A-Z1-9]');
    user = user(f);
    
    % Ensure a defaults file exists for the user
    handles = ensureDefaultsFileExists(handles, user);
    
    % Prompt user to choose a defaults file, then load it.
    handles = chooseAndLoadDefaultsFile(handles);

    % Gather all electro_gui plugins
    handles = gatherPlugins(handles);
    
    % Default sound to display is the designated sound channel
    handles.SoundChannel = 0;
    handles.SoundExpression = '';
    
    % Keep track of whether or not the shift and control keys are down
    handles.ShiftKeyDown = false;
    handles.CtrlKeyDown = false;

    % Min and max time to display on axes
    handles.TLim = [0, 1];

    % Handle for box showing time viewing window
    handles.xlimbox = gobjects().empty;

    % Unread file marker:
    handles.UnreadFileMarker = '> ';
    handles.FileEntryOpenTag = '<HTML><FONT COLOR=000000>';
    handles.FileEntryCloseTag = '</FONT></HTML>';
    
    handles.SegmentHandles = gobjects().empty;
    handles.MarkerHandles = gobjects().empty;
    handles.SegmentLabelHandles = gobjects().empty;
    handles.MarkerLabelHandles = gobjects().empty;

    handles.ActiveSegmentNum = [];
    handles.ActiveMarkerNum = [];

    handles = setSegmentAndMarkerColors(handles);

    % Create a cell array of valid segment characters
    validSegmentCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%&*(){}[]_';
    handles.validSegmentCharacters = num2cell(validSegmentCharacters);

    % Set up event objects
    handles.EventWhichPlot = 0;
    handles.EventWaveHandles = gobjects().empty;
    
    handles.ActiveEventNum = [];
    handles.ActiveEventPartNum = [];
    handles.ActiveEventCursors = gobjects().empty;

    % General cursor
    handles.Cursors = gobjects().empty;
    handles.ShiftDown = false;
    handles.CtrlDown = false;

    % File caching settings
    handles.EnableFileCaching = true;
    handles.BackwardFileCacheSize = 1;
    handles.ForwardFileCacheSize = 3;
    handles = resetFileCache(handles);

    % Load temp file, or use defaults if it doesn't exist
    handles.tempFile = 'eg_temp.mat';
    handles = loadTempFile(handles);

    % If user has QuoteFile defined in their defaults, serve them up a
    % welcome message and a nice quote
    if isfield(handles, 'QuoteFile')
        quote = getQuote(handles.QuoteFile);
        fprintf('Welcome to electro_gui.\n\nRandom quote of the moment:\n\n%s\n\nTo stop getting quotes, remove the ''handles.QuoteFile'' parameter from your defaults file.\n\n', quote);
    end
    
    dr = dir([mfilename('fullpath') '*m']);
    handles.figure_Main.Name = ['ElectroGui v. ', dr.date];


    %% Set up axes-indexed lists of GUI elements, to make code more extensible    
    % handles.popup_Channels are dropdown menus for the channel axes to select a channel of data to display.
    handles.popup_Channels = [handles.popup_Channel1, handles.popup_Channel2];
    % handles.popup_Function are dropdown menus for the channel axes to select a filter function.
    handles.popup_Functions = [handles.popup_Function1, handles.popup_Function2];
    % handles.popup_EventDetector are dropdown menus for the channel axes to select an event detector algorithm.
    handles.popup_EventDetectors = [handles.popup_EventDetector1, handles.popup_EventDetector2];
    % handles.axes_Channel are the channel data display axes
    handles.axes_Channel = [handles.axes_Channel1, handles.axes_Channel2];
    % menu source top/bottom plot
    handles.menu_SourcePlots = [handles.menu_SourceTopPlot, handles.menu_SourceBottomPlot];
    % peak detect menu items
    handles.menu_PeakDetects = [handles.menu_PeakDetect1, handles.menu_PeakDetect2];
    handles.menu_AutoLimits = [handles.menu_AutoLimits1, handles.menu_AutoLimits2];
    handles.context_Channels = [handles.context_Channel1, handles.context_Channel2];
    handles.menu_AllowYZooms = [handles.menu_AllowYZoom1, handles.menu_AllowYZoom2];
    handles.menu_EventAutoDetect = [handles.menu_EventAutoDetect1, handles.menu_EventAutoDetect2];
    handles.menu_EventsDisplay = [handles.menu_EventsDisplay1, handles.menu_EventsDisplay2];
    
    % handles.loadedChannelData = {};
    % handles.Labels = {};
    % % handles.ChanLimits = {};
    
    handles.menu_Events = [handles.menu_Events1, handles.menu_Events2];
    handles.push_Detects = [handles.push_Detect1, handles.push_Detect2];
    
    handles.ChanLimits1 = handles.ChanLimits(1,:);
    handles.ChanLimits2 = handles.ChanLimits(2,:);
    
    % Sonogram overlay handles
    handles.Sonogram_Overlays = gobjects(1, 2);

    % Set values of various GUI controls based on default values
    handles = setGUIValues(handles);

    % Populate various GUI menus with available plugins found in the
    % electro_gui directory
    handles = populatePluginMenus(handles);

    %colormap('default');
    handles.Colormap = colormap();
    handles.Colormap(1,:) = handles.BackgroundColors(1,:);    
    
    % Position figure
    handles.figure_Main.Position = [.025 0.075 0.95 0.85];
    % Set scroll handler
    handles.figure_Main.WindowScrollWheelFcn = @scrollHandler;
    
    % Set initial parameter values
    handles.SegmenterParams.Names = {};
    handles.SegmenterParams.Values = {};
    handles.SonogramParams.Names = {};
    handles.SonogramParams.Values = {};
    handles.ChannelAxesEventParameters{1}.Names = {};       % Temporary place to record channel parameters before an event source is defined
    handles.ChannelAxesEventParameters{1}.Values = {};
    handles.ChannelAxesEventParameters{2}.Names = {};
    handles.ChannelAxesEventParameters{2}.Values = {};
    handles.FunctionParams{1}.Names = {};
    handles.FunctionParams{1}.Values = {};
    handles.FunctionParams{2}.Names = {};
    handles.FunctionParams{2}.Values = {};
    handles.FilterParams.Names = {};
    handles.FilterParams.Values = {};
    
    handles.menu_EditFigureTemplate.UserData = handles.template;
    
    handles = setUpWorksheet(handles);
    
    if handles.ExportReplotSonogram == 1
        handles.menu_CustomResolution.Checked = 'on';
    else
        handles.menu_ScreenResolution.Checked = 'on';
    end
    switch handles.ExportSonogramIncludeClip
        case 0
            handles.menu_IncludeSoundNone.Checked = 'on';
        case 1
            handles.menu_IncludeSoundOnly.Checked = 'on';
        case 2
            handles.menu_IncludeSoundMix.Checked = 'on';
    end
    if handles.ExportSonogramIncludeLabel == 1
        handles.menu_IncludeTimestamp.Checked = 'on';
    else
        handles.menu_IncludeTimestamp.Checked = 'off';
    end
    
    handles.ScalebarPresets = [0.001 0.002 0.005 0.01 0.02 0.025 0.05 0.1 0.2 0.25 0.5 1 2 5 10 20 30 60];
    handles.ScalebarLabels =  {'1 ms','2 ms','5 ms','10 ms','20 ms','25 ms','50 ms','100 ms','200 ms','250 ms','500 ms','1 s','2 s','5 s','10 s','20 s','30 s','1 min'};
    
    % Choose default command line output for electro_gui
    handles.output = hObject;
    
    if handles.EnableFileCaching
        try
            % Start up parallel pool for caching purposes
            p = gcp();
            p.IdleTimeout = 90;
        catch
            warning('Failed to start parallel pool - maybe the parallel computing toolbox is not installed? Disabling file caching.');
            handles.EnableFileCaching = false;
        end
    end
    
    handles = disableAxesPopupToolbars(handles);

    % Initialize event-related variables
    handles.EventSources = {};      % Array of event source channel names
    handles.EventChannels = [];     % Array of event source channel numbers
    handles.EventFunctions = {};    % Array of event source filter names
    handles.EventDetectors = {};    % Array of event source detector names
    handles.EventParameters = {};   % Array of event source detector parameters
    handles.EventParts = {};        % Array of event part options for the selected event detector
    handles.EventXLims = [];        % Array of event source x limits
    handles.EventTimes = {};
    handles.EventSelected = {};
    handles.EventHandles = {{}, {}};
    handles.EventWaveHandles = gobjects().empty;
    handles.EventThresholdHandles = gobjects(1, 2);  % Handles for event threshold lines
    handles.ActiveEventNum = [];        % Index of the currently active event
    handles.ActiveEventPartNum = [];    % Event part of the currently active event
    handles.ActiveEventSourceIdx = [];  % Event source index of the currently active event

    handles.menu_EventsDisplayList = {gobjects().empty, gobjects().empty};

    handles = UpdateEventSourceList(handles);

    handles.figure_Main.KeyPressFcn = @keyPressHandler;
    handles.figure_Main.KeyReleaseFcn = @keyReleaseHandler;
    handles.figure_Main.WindowButtonMotionFcn = @MouseMotionHandler;

    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes electro_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure_Main);

function handles = disableAxesPopupToolbars(handles)
    % Turn off the pop-up tool buttons for axes
    handles.axes_Sound.Toolbar.Visible = 'off';
    handles.axes_Sonogram.Toolbar.Visible = 'off';
    handles.axes_Amplitude.Toolbar.Visible = 'off';
    handles.axes_Channel1.Toolbar.Visible = 'off';
    handles.axes_Channel2.Toolbar.Visible = 'off';
    handles.axes_Segments.Toolbar.Visible = 'off';
    handles.axes_Events.Toolbar.Visible = 'off';

function handles = loadTempFile(handles)
    % Get temp file
    tempSettingsFields =        {'lastDirectory',         'lastDBase'};
    tempSettingsDefaultValues = {handles.DefaultRootPath, ''};
    if exist(handles.tempFile, 'file')
        try
            handles.tempSettings = load(handles.tempFile, tempSettingsFields{:});
        catch
            warning('Unable to open temp file, creating new one.');
        end
    else
        % No temp file - use defaults
        handles.tempSettings = struct();
    end
    % Loop over expected temp settings fields and set defaults if they
    % aren't there
    for k = 1:length(tempSettingsFields)
        if ~isfield(handles.tempSettings, tempSettingsFields{k})
            handles.tempSettings.(tempSettingsFields{k}) = tempSettingsDefaultValues{k};
        end
    end
    updateTempFile(handles);

function updateTempFile(handles)
    % Update temp file
    tempSettings = handles.tempSettings;
    save(handles.tempFile, '-struct', 'tempSettings');

function handles = setUpWorksheet(handles)
    sz = handles.figure_Main.PaperSize;
    if strcmp(handles.WorksheetOrientation,'portrait')
        handles.menu_Portrait.Checked = 'on';
    else
        handles.WorksheetOrientation = 'landscape';
        handles.menu_Landscape.Checked = 'on';
    end
    if ~strcmp(handles.WorksheetOrientation,handles.figure_Main.PaperOrientation)
        handles.WorksheetHeight = sz(1);
        handles.WorksheetWidth = sz(2);
    else
        handles.WorksheetHeight = sz(2);
        handles.WorksheetWidth = sz(1);
    end
    
    patch(handles.axes_Worksheet, [0, handles.WorksheetWidth, handles.WorksheetWidth, 0], [0, 0, handles.WorksheetHeight, handles.WorksheetHeight], 'w');
    axis(handles.axes_Worksheet, 'equal');
    axis(handles.axes_Worksheet, 'tight');
    axis(handles.axes_Worksheet, 'off');
    
    handles.WorksheetTitle = 'Untitled';
    
    handles.WorksheetXLims = {};
    handles.WorksheetYLims = {};
    handles.WorksheetXs = {};
    handles.WorksheetYs = {};
    handles.WorksheetMs = {};
    handles.WorksheetClim = {};
    handles.WorksheetColormap = {};
    handles.WorksheetSounds = {};
    handles.WorksheetFs = [];
    handles.WorksheetTimes = [];
    
    handles.WorksheetCurrentPage = 1;
    
    if handles.WorksheetIncludeTitle == 1
        handles.menu_IncludeTitle.Checked = 'on';
    end
    if handles.WorksheetChronological == 1
        handles.menu_SortChronologically.Checked = 'on';
    end
    if handles.WorksheetOnePerLine == 1
        handles.menu_OnePerLine.Checked = 'on';
    end    
    
    handles.WorksheetHandles = gobjects().empty();
    handles.WorksheetList = [];
    handles.WorksheetUsed = [];
    handles.WorksheetWidths = [];

function handles = setSegmentAndMarkerColors(handles)
    % Segment/Marker colors
    handles.SegmentSelectColor = 'r';
    handles.SegmentUnSelectColor = [0.7, 0.5, 0.5];
    handles.MarkerSelectColor = 'b';
    handles.MarkerUnSelectColor = [0.5, 0.5, 0.7];
    handles.SegmentActiveColor = 'y';  % Note the GUI depends on this being different from MarkerActiveColor.
    handles.MarkerActiveColor = 'g';
    handles.SegmentInactiveColor = 'k';
    handles.MarkerInactiveColor = 'k';
    
    handles.SegmentSelectColors = {handles.SegmentUnSelectColor, handles.SegmentSelectColor};
    handles.MarkerSelectColors = {handles.MarkerUnSelectColor, handles.MarkerSelectColor};
    handles.SegmentActiveColors = {handles.SegmentInactiveColor, handles.SegmentActiveColor};
    handles.MarkerActiveColors = {handles.MarkerInactiveColor, handles.MarkerActiveColor};

function [handles, isNewUser] = ensureDefaultsFileExists(handles, user)
    % Check if a defaults file exists for the given user. If not, create
    % one for the user using the settings in eg_Get_Defaults file.

    % Determine correct defaults filename for user
    handles.userfile = ['defaults_' user '.m'];
    % Check if defaults filename for current user exists
    isNewUser = isempty(dir(handles.userfile));

    if isNewUser
        % No defaults file exists - create a new one and copy defaults into
        % it

        % Open default defaults file
        fid1 = fopen('eg_Get_Defaults.m','r');
        % Create new defaults file for user
        fid2 = fopen(handles.userfile,'w');
        fgetl(fid1);
        str = ['function handles = ' handles.userfile(1:end-2) '(handles)'];
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

function handles = chooseAndLoadDefaultsFile(handles)
    % Prompt user to choose a defaults file, then load it.

    % Populate list of defaults files for user to choose from
    userList = {'(Default)'};
    defaultsFileList = dir('defaults_*.m');
    for c = 1:length(defaultsFileList)
        userList(end+1) = regexp(defaultsFileList(c).name, '(?<=defaults_).*(?=\.m)', 'match');
    end
    currentUserDefaultIndex = find(strcmp(handles.userfile, {defaultsFileList.name}));
    
    [chosenDefaultIndex, ok] = listdlg('ListString', userList, 'Name', 'Defaults', 'PromptString', 'Select default settings', 'SelectionMode', 'single', 'InitialValue', currentUserDefaultIndex);
    if ok || chosenDefaultIndex == 1
        handles = eg_Get_Defaults(handles);
    else
        handles = eval(['defaults_' userList{val} '(handles)']);
    end

function handles = setGUIValues(handles)
    % Set values of various GUI controls based on default values
    if handles.EventsDisplayMode == 1
        handles.menu_DisplayValues.Checked = 'on';
    else
        handles.menu_DisplayFeatures.Checked = 'on';
    end
    if handles.EventsAutoDisplay == 1
        handles.menu_AutoDisplayEvents.Checked = 'on';
    end
    
    if handles.SonogramAutoCalculate == 1
        handles.menu_AutoCalculate.Checked = 'on';
    end
    if handles.AllowFrequencyZoom == 1
        handles.menu_FrequencyZoom.Checked = 'on';
    end
    if handles.OverlayTop == 1
        handles.menu_OverlayTop.Checked = 'on';
    end
    if handles.OverlayBottom == 1
        handles.menu_OverlayBottom.Checked = 'on';
    end
    
    if handles.AutoSegment == 1
        handles.menu_AutoSegment.Checked = 'on';
    end
    
    if handles.AmplitudeAutoThreshold == 1
        handles.menu_AutoThreshold.Checked = 'on';
    end
    
    if handles.AmplitudeDontPlot == 1
        handles.menu_DontPlot.Checked = 'on';
    end
    
    if handles.PeakDetect(1) == 1
        handles.menu_PeakDetect1.Checked = 'on';
    end
    if handles.PeakDetect(2) == 1
        handles.menu_PeakDetect2.Checked = 'on';
    end
    
    if handles.AutoYZoom(1) == 1
        handles.menu_AllowYZoom1.Checked = 'on';
    end
    if handles.AutoYZoom(2) == 1
        handles.menu_AllowYZoom2.Checked = 'on';
    end
    
    if handles.AutoYLimits(1) == 1
        handles.menu_AutoLimits1.Checked = 'on';
    end
    if handles.AutoYLimits(2) == 1
        handles.menu_AutoLimits2.Checked = 'on';
    end
    
    if handles.EventsAutoDetect(1) == 1
        handles.menu_EventAutoDetect1.Checked = 'on';
    end
    if handles.EventsAutoDetect(2) == 1
        handles.menu_EventAutoDetect2.Checked = 'on';
    end
    
    ch = handles.menu_AmplitudeSource.Children;
    set(ch(3-handles.AmplitudeSource),'Checked','on');
    
    handles.CustomFreqLim = handles.FreqLim;
    
    if handles.FilterSound == 1
        handles.menu_FilterSound.Checked = 'on';
    end
    if handles.PlayReverse == 1
        handles.menu_PlayReverse.Checked = 'on';
    end
    
    handles.AnimationPlots = fliplr(handles.AnimationPlots);
    ch = handles.menu_ProgressBar.Children;
    for c = 1:length(ch)
        if handles.AnimationPlots(c) == 1
            ch(c).Checked = 'on';
        end
    end
    
    ch = handles.menu_Animation.Children;
    ischeck = false;
    for c = 1:length(ch)
        if strcmp(ch(c).Label,handles.AnimationType)
            ch(c).Checked = 'on';
            ischeck = true;
        end
    end
    if ~ischeck
        handles.menu_AnimationProgressBar.Checked = 'on';
    end
    
    handles.check_Sound.Value = handles.DefaultMix(1);
    handles.check_TopPlot.Value = handles.DefaultMix(2);
    handles.check_BottomPlot.Value = handles.DefaultMix(3);    

function [pluginNames, pluginTypes] = getPluginNamesFromFilenames(pluginFilenames)
    % Extract the plain names and types of electro_gui plugin from a list of their filenames
    pluginNames = cell(size(pluginFilenames));
    pluginTypes = cell(size(pluginFilenames));
    for k = 1:length(pluginFilenames)
        [pluginNames{k}, pluginTypes{k}] = getPluginNameFromFilename(pluginFilenames{k});
    end

function [pluginName, pluginType] = getPluginNameFromFilename(pluginFilename)
    % Extract the plain name and type of an electro_gui plugin from its filename
    pluginNamePattern = '(.*?)_(.*)\.m';
    tokens = regexp(pluginFilename, pluginNamePattern, 'tokens');
    pluginName = tokens{1}{2};
    pluginType = tokens{1}{1};

function handles = populatePluginMenus(handles)
    % Populate various GUI menus with available plugins found in the
    % electro_gui directory

    % Populate sonogram algorithm plugin menu
    [handles, handles.menu_Algorithm] = populatePluginMenuList(handles, 'egs', handles.DefaultSonogramPlotter, handles.menu_AlgorithmList, @AlgorithmMenuClick);
    
    % Populate segmenting algorithm plugin menu
    [handles, handles.menu_Segmenter] = populatePluginMenuList(handles, 'egg', handles.DefaultSegmenter, handles.menu_SegmenterList, @SegmenterMenuClick);

    % Populate filter algorithm plugin menu
    [handles, handles.menu_Filter] = populatePluginMenuList(handles, 'egf', handles.DefaultFilter, handles.menu_FilterList, @FilterMenuClick);

    % Populate colormap plugin menu
    handles.menu_ColormapList(1) = uimenu(handles.menu_Colormap, 'Label', '(Default)', 'Callback', @ColormapClick);
    [handles, handles.menu_ColormapList] = populatePluginMenuList(handles, 'egc', '(Default)', handles.menu_Colormap, @ColormapClick);

    % Populate macro plugin menu
    [handles, handles.menu_Macros] = populatePluginMenuList(handles, 'egm', [], handles.context_Macros, @MacrosMenuclick);

    % Populate x-axis event feature algorithm plugin menu
    [handles, handles.menu_XAxis_List] = populatePluginMenuList(handles, 'ega', handles.DefaultEventFeatureX, handles.menu_XAxis, @XAxisMenuClick);
    % Populate y-axis event feature algorithm plugin menu
    [handles, handles.menu_YAxis_List] = populatePluginMenuList(handles, 'ega', handles.DefaultEventFeatureY, handles.menu_YAxis, @YAxisMenuClick);

    % Find all function algorithms
    pluginList = dir('egf_*.m');
    pluginNames = getPluginNamesFromFilenames({pluginList.name});
    str = {'(Raw)'};
    for pluginIdx = 1:length(pluginNames)
        str{end+1} = pluginNames{pluginIdx};
    end
    handles.popup_Function1.String = str;
    handles.popup_Function1.UserData = cell(1,length(str));
    handles.popup_Function2.String = str;
    handles.popup_Function2.UserData = cell(1,length(str));
    
    % Find all event detector algorithms
    pluginList = dir('ege_*.m');
    pluginNames = getPluginNamesFromFilenames({pluginList.name});
    str = {'(None)'};
    for pluginIdx = 1:length(pluginNames)
        str{end+1} = pluginNames{pluginIdx};
    end
    handles.popup_EventDetector1.String = str;
    handles.popup_EventDetector1.UserData = cell(1,length(str));
    handles.popup_EventDetector2.String = str;
    handles.popup_EventDetector2.UserData = cell(1,length(str));
    
function [handles, menus] = populatePluginMenuList(handles, pluginPrefix, defaultPluginName, menuList, callback)
    % Populate a dropdown menu for selecting plugins

    % Find all plugin files of the desired type
    pluginList = dir([pluginPrefix, '_*.m']);
    % Get plugin names
    pluginNames = getPluginNamesFromFilenames({pluginList.name});
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

% --- Outputs from this function are returned to the command line.
function varargout = electro_gui_OutputFcn(hObject, ~, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
function isPlugin = isValidPlugin(plugins, name)
    % Check if name corresponds to one of the provided list of plugins
    for k = 1:length(plugins)
        if strcmp(name, plugins(k).name)
            isPlugin = true;
            return
        end
    end
    isPlugin = false;
    
function out = findPlugins(prefix)
    % Create a struct array containing the name and function handle for all
    % electro_gui plugin functions with the given prefix (for example 'egl_')
    allowedCharacters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
    f = dir([prefix, '*.m']);
    for k = 1:length(f)
        [~, fileName, ~] = fileparts(f(k).name);
        name = regexp(fileName, [prefix, '(.*)'], 'tokens', 'once');
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
        out(k).fileName = f(k).name;
    end
    
function handles = gatherPlugins(handles)
    % Gather all electro_gui plugins
    
    % Find all spectrum algorithms
    handles.plugins.spectrums = findPlugins('egs_');
    % Find all segmenting algorithms
    handles.plugins.segmenters = findPlugins('egg_');
    % Find all filters
    handles.plugins.filters = findPlugins('egf_');
    % Find all colormaps
    handles.plugins.ColorMaps = findPlugins('egc_');
    % % Find all function algorithms
    handles.plugins.functions = findPlugins('egf_');
    % Find all macros
    handles.plugins.macros = findPlugins('egm_');
    % Find all event detector algorithms
    handles.plugins.eventDetectors = findPlugins('ege_');
    % Find all event feature algorithms
    handles.plugins.eventFeatures = findPlugins('ega_');
    % Find all loaders
    handles.plugins.loaders= findPlugins('egl_');

function edit_FileNumber_Callback(hObject, ~, handles)
    % hObject    handle to edit_FileNumber (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_FileNumber as text
    %        str2double(hObject.String) returns contents of edit_FileNumber as a double
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
        
% --- Executes during object creation, after setting all properties.
function edit_FileNumber_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_FileNumber (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end

function handles = changeFile(handles, delta)
    % Switch file number by delta
    filenum = getCurrentFileNum(handles);
    if ~handles.check_Shuffle.Value
        % Decrement file number
        filenum = filenum + delta;
        if filenum < 1 || filenum > handles.TotalFileNumber
            filenum = mod(filenum-1, handles.TotalFileNumber)+1;
        end
    else
        % Decrement file number in shuffled order
        shufflenum = find(handles.ShuffleOrder==filenum);
        shufflenum = shufflenum + delta;
        if shufflenum < 1 || shufflenum > handles.TotalFileNumber
            shufflenum = mod(shufflenum-1, handles.TotalFileNumber)+1;
        end
        filenum = handles.ShuffleOrder(shufflenum);
    end
    handles.edit_FileNumber.String = num2str(filenum);
    
    handles = eg_LoadFile(handles);

% --- Executes on button press in push_PreviousFile.
function push_PreviousFile_Callback(hObject, ~, handles)
    % hObject    handle to push_PreviousFile (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = changeFile(handles, -1);
    guidata(hObject, handles);
    
% --- Executes on button press in push_NextFile.
function push_NextFile_Callback(hObject, ~, handles)
    % hObject    handle to push_NextFile (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    handles = changeFile(handles, 1);
    guidata(hObject, handles);
    
% --- Executes on selection change in list_Files.
function list_Files_Callback(hObject, ~, handles)
    % hObject    handle to list_Files (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns list_Files contents as cell array
    %        contents{hObject.Value} returns selected item from list_Files
    
    if strcmp(handles.figure_Main.SelectionType, 'open')
        % Double click
        handles.edit_FileNumber.String = num2str(handles.list_Files.Value);
    else
        return
    end
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function list_Files_CreateFcn(hObject, ~, handles)
    % hObject    handle to list_Files (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
% --- Executes on button press in push_Properties.
function push_Properties_Callback(hObject, ~, handles)
    % hObject    handle to push_Properties (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_Properties.UIContextMenu = handles.context_Properties;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    end
    
% --- Executes on slider movement.
function slider_Time_Callback(hObject, ~, handles)
    % hObject    handle to slider_Time (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.Value returns position of slider
    %        hObject.Min and hObject.Max to determine range of slider
    
    if ~isfield(handles, 'xlimbox')
        % No xlimbox yet, probably nothing to slide.
        return;
    end
    shift = handles.slider_Time.Value - handles.TLim(1);
    handles.TLim = handles.TLim + shift;
    handles = eg_EditTimescale(handles);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function slider_Time_CreateFcn(hObject, ~, handles)
    % hObject    handle to slider_Time (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = [.5 .5 .5];
    end

% --------------------------------------------------------------------
function menu_Experiment_Callback(hObject, ~, handles)
    % hObject    handle to menu_Experiment (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --- Executes on button press in push_Play.
function push_Play_Callback(hObject, ~, handles)
    % hObject    handle to push_Play (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    snd = GenerateSound(handles,'snd');
    progress_play(handles,snd);

function progress_play(handles,wav)
    % Get time limits for visible sonogram
    timeLimits = handles.axes_Sonogram.XLim;
    % Get audio sample limits for the visible sonogram
    sampleLimits = round(timeLimits*handles.fs);
    % Ensure sample number is in range
    sampleLimits(1) = sampleLimits(1)+1;
    sampleLimits(2) = sampleLimits(2)-1;
    if sampleLimits(1)<1
        sampleLimits(1) = 1;
    end
    [handles, numSamples] = eg_GetNumSamples(handles);
    if sampleLimits(2) > numSamples
        sampleLimits(2) = numSamples;
    end
    if sampleLimits(2)<=sampleLimits(1)
        return
    end


    axs = [handles.axes_Channel2 handles.axes_Channel1 handles.axes_Amplitude handles.axes_Segments handles.axes_Sonogram handles.axes_Sound];
    ch = handles.menu_ProgressBar.Children;
    indx = [];
    for c = 1:length(ch)
        if ch(c).Checked && axs(c).Visible
            indx = [indx, c];
        end
    end
    axs = axs(indx);
    
    fs = handles.fs * handles.SoundSpeed;
    if isempty(axs)
        sound(wav,fs);
    else
        for c = length(axs):-1:1
            if strcmp(axs(c).Visible,'off')
                axs(c) = [];
            end
        end
        for c = 1:length(axs)
            hold(axs(c), 'on')
            if ~handles.menu_PlayReverse.Checked
                h(c) = plot(axs(c), [sampleLimits(1) sampleLimits(1)]/handles.fs,ylim,'Color',handles.ProgressBarColor,'LineWidth',2);
            else
                h(c) = plot(axs(c), [sampleLimits(2) sampleLimits(2)]/handles.fs,ylim,'Color',handles.ProgressBarColor,'LineWidth',2);
            end
        end
        y = audioplayer(wav,fs);
        play(y);
        while isplaying(y)
            pos = y.CurrentSample;
            for c = 1:length(h)
                if ~handles.menu_PlayReverse.Checked
                    h(c).XData = ([pos pos]+sampleLimits(1)-1)/handles.fs;
                else
                    h(c).XData = (sampleLimits(2)-[pos pos]+1)/handles.fs;
                end
            end
            drawnow;
        end
        stop(y);
        clear(y);
        delete(h);
        hold(handles.axes_Sonogram, 'off');
    end
    
% --- Executes on button press in push_TimescaleRight.
function push_TimescaleRight_Callback(hObject, ~, handles)
    % hObject    handle to push_TimescaleRight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    tscale = str2double(handles.edit_Timescale.String);
    ord = 10^floor(log(tscale)/log(10));
    mult = tscale/ord;
    if mult == 1
        tscale = 0.5 * ord;
    elseif mult > 1 && mult <= 2
        tscale = ord;
    elseif mult > 2 && mult <= 5
        tscale = 2 * ord;
    elseif mult > 5
        tscale = 5 * ord;
    end
    handles.edit_Timescale.String  = num2str(tscale,4);
    electro_gui('edit_Timescale_Callback',gcbo,[],guidata(gcbo));
    
    guidata(hObject, handles);
    
% --- Executes on button press in push_TimescaleLeft.
function push_TimescaleLeft_Callback(hObject, ~, handles)
    % hObject    handle to push_TimescaleLeft (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent', handles.axes_Sonogram, 'type', 'text'))
        return
    end
    
    tscale = str2double(handles.edit_Timescale.String);
    ord = 10^floor(log(tscale)/log(10));
    mult = tscale/ord;
    if mult >= 5
        tscale = 10 * ord;
    elseif mult >= 2 && mult < 5
        tscale = 5 * ord;
    elseif mult >= 1 && mult < 2
        tscale = 2 * ord;
    end
    handles.edit_Timescale.String = num2str(tscale,4);
    electro_gui('edit_Timescale_Callback',gcbo,[],guidata(gcbo));
    
    guidata(hObject, handles);
    
function edit_Timescale_Callback(hObject, ~, handles)
    % hObject    handle to edit_Timescale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_Timescale as text
    %        str2double(hObject.String) returns contents of edit_Timescale as a double
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end

    tscale = str2double(handles.edit_Timescale.String);
    handles.TLim = [handles.TLim(1), handles.TLim(1) + tscale];
    handles = eg_EditTimescale(handles);
    guidata(hObject, handles);
    
function handles = centerTimescale(handles, centerTime, radiusTime)
    handles.TLim = [centerTime - radiusTime, centerTime + radiusTime];
    handles = eg_EditTimescale(handles);
    
% --- Executes during object creation, after setting all properties.
function edit_Timescale_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_Timescale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
function [handles, data] = retrieveFileFromCache(handles, filepath, loader)
    % Retrieve file from cache. If it has already been loaded, just return it.
    % If is done loading, but its data has not been transferred to the cache,
    % do so now. If it has not finished loading yet, wait until it loads.
    match_idx = isFileInCache(handles, filepath, loader);
    if ~match_idx
        handles = addToFileCache(handles, filepath, loader);
        match_idx = isFileInCache(handles, filepath, loader);
    end
    
    if isempty(handles.file_cache(match_idx).data)
        % Data hasn't been loaded from future yet - load it (and wait if
        % necssary)
        handles.file_cache(match_idx).data = cell(1, 5);
        [handles.file_cache(match_idx).data{:}] = fetchOutputs(handles.file_cache(match_idx).data_future);
    end
    data = handles.file_cache(match_idx).data;
    
function handles = addToFileCache(handles, filepath, loader)
    % Add the given file for the given loader to the cache, if it isn't already
    %   there.
    numLoaderOutputs = 5;
    if ~isFileInCache(handles, filepath, loader)
        next_idx = length(handles.file_cache)+1;
        handles.file_cache(next_idx).filepaths = filepath;
        handles.file_cache(next_idx).loaders = loader;
        handles.file_cache(next_idx).data = [];
        handles.file_cache(next_idx).data_future = parfeval(@eg_runPlugin, numLoaderOutputs, handles.plugins.loaders, loader, filepath, true);
    end
    
function inCache = isFileInCache(handles, filepath, loader)
    % Check if file is in the file cache or not. inCache is false if
    %   it is not in the cache, or a positive numerical cache index if it is in
    %   the cache.
    inCache = false;
    for k = 1:length(handles.file_cache)
        if strcmp(handles.file_cache(k).filepaths, filepath)
            if strcmp(handles.file_cache(k).loaders, loader)
                inCache = k;
                break;
            end
        end
    end
    
function handles = refreshFileCache(handles)
    % Get a list of files that should be in cache,
    filesInCache = {};
    loadersInCache = {};
    
    filenum = getCurrentFileNum(handles);
    minCacheNum = max(1, filenum - handles.BackwardFileCacheSize);
    maxCacheNum = min(handles.TotalFileNumber, filenum + handles.ForwardFileCacheSize);
    
    fileNums = minCacheNum:maxCacheNum;
    [selectedChannelNum1, ~, isSound1] = getSelectedChannel(handles, 1);
    [selectedChannelNum2, ~, isSound2] = getSelectedChannel(handles, 2);
    
    % Add sound files to list of necessary cache files:
    for filenum = fileNums
        % Add sound file to list
        filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);
        loadersInCache{end+1} = handles.sound_loader;
    
        % Add whatever channel is selected in axes1 to list
        if ~isempty(selectedChannelNum1)
            filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.chan_files{selectedChannelNum1}(filenum).name);
            if isSound1
                loadersInCache{end+1} = handles.sound_loader;
            else
                loadersInCache{end+1} = handles.chan_loader{selectedChannelNum1};
            end
        end
    
        if ~isempty(selectedChannelNum2)
            % Add whatever channel is selected in axes2 to list
            filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.chan_files{selectedChannelNum2}(filenum).name);
            if isSound2
                loadersInCache{end+1} = handles.sound_loader;
            else
                loadersInCache{end+1} = handles.chan_loader{selectedChannelNum2};
            end
        end
    end
    
    % Check if any unnecessary files are in the cache. If so, remove them.
    stale_idx = [];
    for k = 1:length(handles.file_cache)
        if ~any(strcmp(handles.file_cache(k).filepaths, filesInCache) & strcmp(handles.file_cache(k).loaders, loadersInCache))
            % This cache element is no longer needed.
            stale_idx(end+1) = k;
        end
    end
    % Remove unneeded cache elements
    handles.file_cache(stale_idx) = [];
    
    % Check if each necessary file is in the cache. If not, add it.
    for k = 1:length(filesInCache)
        if ~isFileInCache(handles, filesInCache{k}, loadersInCache{k})
            handles = addToFileCache(handles, filesInCache{k}, loadersInCache{k});
        end
    end
    
function handles = resetFileCache(handles)
    % Reset cache to empty state (or create it if it doesn't exist)
    handles.file_cache = struct.empty();
    handles.file_cache(1).filepaths = '';
    handles.file_cache(1).loaders = '';
    handles.file_cache(1).data = [];
    handles.file_cache(1).data_future = parallel.FevalFuture;
    handles.file_cache(:) = [];
    
function handles = eg_LoadFile(handles)
    if handles.EnableFileCaching
        handles = refreshFileCache(handles);
    end
    
    filenum = getCurrentFileNum(handles);
    handles.list_Files.Value = filenum;
    fileList = handles.list_Files.String;
    
    % Remove unread file marker from filename
    if isFileUnread(handles, fileList{filenum})
        fileList{filenum} = removeUnreadFileMarker(handles, fileList{filenum});
        handles.list_Files.String = fileList;
    end
    
    curr = pwd();
    cd(handles.DefaultRootPath);
    
    % Label
    handles.text_FileName.String = handles.sound_files(filenum).name;
    
    % Load properties
    handles = eg_LoadProperties(handles);
    
    % Load sound
    handles.sound = [];
    
    soundFilePath = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);

    if handles.EnableFileCaching
        [handles, data] = retrieveFileFromCache(handles, soundFilePath, handles.sound_loader);
        [handles.sound, handles.fs, dt] = data{:};
    else
        try
            soundFilePath = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);
            [handles.sound, handles.fs, dt, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, soundFilePath, true);
        catch ME
            if ~exist(soundFilePath, 'file')
                error('File not found: %s', soundFilePath);
            else
                rethrow(ME);
            end
        end
    end
    
    handles.DatesAndTimes(filenum) = dt;
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    handles.FileLength(filenum) = numSamples;
    handles.text_DateAndTime.String = string(datetime(dt, 'ConvertFrom', 'datenum'));
    
    handles = eg_FilterSound(handles);
    
    [handles, filtered_sound] = eg_GetSound(handles, true);
    
    h = eg_peak_detect(handles.axes_Sound, linspace(0, numSamples/handles.fs, numSamples), filtered_sound);

    [h.Color] = deal('c');
    handles.axes_Sound.XTick = [];
    handles.axes_Sound.YTick = [];
    handles.axes_Sound.Color = [0 0 0];
    axis(handles.axes_Sound, 'tight');
    yl = max(abs(ylim(handles.axes_Sound)));
    ylim(handles.axes_Sound, [-yl*1.2, yl*1.2]);
    
    box(handles.axes_Sound, 'on');
    
    handles = clearAxes(handles);

    tmax = numSamples/handles.fs;
    handles.TLim = [0, tmax];
    
    % If file too long
    if numSamples > handles.TooLong
        txt = text(mean(xlim),mean(ylim), 'Long file. Click to load.',...
            'HorizontalAlignment', 'center', 'Color', 'r', 'fontsize', 14, 'Parent', handles.axes_Sonogram);
        txt.ButtonDownFcn = @click_loadfile;
        cd(curr);
    
        handles = PlotAnnotations(handles);
    
        return
    end
    
    % Define callbacks
    handles = setClickSoundCallback(handles, handles.axes_Sonogram);
    handles = setClickSoundCallback(handles, handles.axes_Sound);
    
    % Plot channels
    handles = eg_LoadChannel(handles,1);
    handles = eg_LoadChannel(handles,2);
    
    handles = updateAmplitude(handles, true);
    
    cd(curr);

    handles = disableAxesPopupToolbars(handles);

    handles = eg_EditTimescale(handles);

function handles = setClickSoundCallback(handles, ax)
    % Set click_sound as button down callback for axes and children
    ax.ButtonDownFcn = @click_sound;
    for ch = ax.Children'
        ch.ButtonDownFcn = ax.ButtonDownFcn;
    end

function handles = clearAxes(handles)
    % Delete old plots
    cla(handles.axes_Sonogram);
    set(handles.axes_Sonogram,'ButtonDownFcn','%','UIContextMenu','');
    cla(handles.axes_Amplitude);
    set(handles.axes_Amplitude,'ButtonDownFcn','%','UIContextMenu','');
    cla(handles.axes_Segments);
    set(handles.axes_Segments,'ButtonDownFcn','%','UIContextMenu','');
    cla(handles.axes_Channel1);
    set(handles.axes_Channel1,'ButtonDownFcn','%','UIContextMenu','');
    cla(handles.axes_Channel2);
    set(handles.axes_Channel2,'ButtonDownFcn','%','UIContextMenu','');
    cla(handles.axes_Events);
    set(handles.axes_Events,'ButtonDownFcn','%','UIContextMenu','');
    
function handles = UpdateChannelLists(handles)
    % Update the channel selection popups based on file lists
    channelList = {'(None)', 'Sound'};
    for channelNum = 1:length(handles.chan_files)
        if ~isempty(handles.chan_files{channelNum})
            channelList{end+1} = channelNumToName(channelNum);
        end
    end
    for axnum = 1:2
        handles.popup_Channel(axnum).String = channelList;
    end

function currentFileNum = getCurrentFileNum(handles)
    currentFileNum = str2double(handles.edit_FileNumber.String);
function currentFileName = getCurrentFileName(handles)
    currentFileNum = getCurrentFileNum(handles);
    currentFileName = handles.sound_files(currentFileNum).name;

function eventParts = getSelectedEventParts(handles, axnum)
    % Get the labels for the event parts for the given channel axes
    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a know event source
        % Get default params from event detector
        eventDetector = getSelectedEventDetector(handles, axnum);
        if ~isempty(eventDetector)
            [~, eventParts] = eg_runPlugin(handles.plugins.eventDetectors, eventDetector, 'params');
        else
            eventParts = {};
        end
    else
        eventParts = handles.EventParts{eventSourceIdx};
    end
    
function selectedEventParameters = getSelectedEventParameters(handles, axnum)
    % Get the event parameters for the given channel axes
    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        % Current axis configuration does not correspond to a know event source
        % Use temporary axes params instead
        selectedEventParameters = handles.ChannelAxesEventParameters{axnum};
        if isempty(selectedEventParameters)
            % Get default params from event detector
            eventDetector = getSelectedEventDetector(handles, axnum);
            if ~isempty(eventDetector)
                selectedEventParameters = eg_runPlugin(handles.plugins.eventDetectors, eventDetector, 'params');
            else
                selectedEventParameters = struct.empty();
            end
            % Store for next time
            handles.ChannelAxesEventParameters{axnum} = selectedEventParameters;
        end
    else
        selectedEventParameters = handles.EventParameters{eventSourceIdx};
    end
function selectedEventLims = getSelectedEventLims(handles, axnum)
    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        % Use temporary axes params instead
        selectedEventLims = handles.EventLims;
    else
        selectedEventLims = handles.EventXLims(eventSourceIdx, :);
    end
function isSound = isChannelSound(channelNum)
    isSound = (channelNum == 0);
function [selectedChannelNum, selectedChannelName, isSound] = getSelectedChannel(handles, axnum)
    % Return the name and number of the selected channel from the specified
    %   axis. If the name is not a valid channel, selectedChannelNum will be
    %   empty.
    channelOptionList = handles.popup_Channels(axnum).String;
    selectedChannelName = channelOptionList{handles.popup_Channels(axnum).Value};
    selectedChannelNum = channelNameToNum(selectedChannelName);
    isSound = isChannelSound(selectedChannelNum);
function selectedEventDetector = getSelectedEventDetector(handles, axnum)
    % Return the name of the selected event detector from the specified axis.
    eventDetectorOptionList = handles.popup_EventDetectors(axnum).String;
    eventDetectorOptionListIndex = handles.popup_EventDetectors(axnum).Value;
    if eventDetectorOptionListIndex == 1
        % No event detector selected
        selectedEventDetector = '';
    else
        selectedEventDetector = eventDetectorOptionList{eventDetectorOptionListIndex};
    end
function selectedFilter = getSelectedFilter(handles, axnum)
    % Return the name of the selected event detector function (filter) from the
    %   specified axis.
    fiterOptionList = handles.popup_Functions(axnum).String;
    filterOptionListIndex = handles.popup_Functions(axnum).Value;
    if filterOptionListIndex == 1
        % No filter selected
        selectedFilter = '';
    else
        selectedFilter = fiterOptionList{filterOptionListIndex};
    end
function handles = setSelectedEventDetector(handles, axnum, eventDetector)
    % Set the currently selected event detector for the selected axis
    eventDetectorOptionList = handles.popup_EventDetectors(axnum).String;
    newIndex = find(strcmp(eventDetectorOptionList, eventDetector));
    if isempty(newIndex)
        error('Error: Could not set selected event detector to ''%s'', as it is not in the option list.', eventDetector);
    end
    handles.popup_EventDetectors(axnum).Value = newIndex;
function channelName = channelNumToName(channelNum)
    channelName = ['Channel ', num2str(channelNum)];
function channelNum = channelNameToNum(channelName)
    if strcmp(channelName, 'Sound')
        channelNum = 0;
    else
        channelNumMatch = regexp(channelName, 'Channel ([0-9]+)', 'tokens');
        if isempty(channelNumMatch)
            % Not a valid channel name
            channelNum = [];
        else
            channelNum = str2double(channelNumMatch{1});
        end
    end
    
function handles = setSelectedEventFunction(handles, axnum, eventFunction)
    % Set the currently selected event function for the selected axis
    eventFunctionOptionList = handles.popup_Functions(axnum).String;
    newIndex = find(strcmp(eventFunctionOptionList, eventFunction));
    if isempty(newIndex)
        error('Error: Could not set selected event function to ''%s'', as it is not in the option list.', eventFunction);
    end
    handles.popup_Functions(axnum).Value = newIndex;
    
function [handles, isValidEventDetector] = updateEventDetectorInfo(handles, channelNum, newEventDetector)
    % This appears to be unused? Kinda confused.
    % Update stored event detector info
    isValidEventDetector = isValidPlugin(handles.plugins.eventDetectors, newEventDetector);
    if isempty(channelNum)
        % Not a valid channel
        return
    end
    filenum = getCurrentFileNum(handles);
    if ~strcmp(getEventDetector(handles, filenum, channelNum), newEventDetector)
        % This is a different event detector from the one previously stored
        % Have to get new params
        if isValidEventDetector
            [handles.ChannelAxesEventParameters{filenum, channelNum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, newEventDetector, 'params');
        else
            handles.ChannelAxesEventParameters{filenum, channelNum} = [];
        end
        % This function appears to not exist? Kinda confused.
        handles = setEventDetector(handles, filenum, channelNum, newEventDetector);
    end
    % Get labels for current detector
    if ~strcmp(newEventDetector, handles.nullEventDetector)
        [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, newEventDetector, 'params');
    else
        labels = {};
    end
    % Add empty entry for event times for this new detector function.
    handles.EventTimes{filenum, channelNum} = cell(1, length(labels));
    handles.EventSelected = logical.empty();
    
function [handles, isValidEventFunction] = updateEventFunctionInfo(handles, channelNum, newEventFunction)
    % This appears to be unused? Kinda confused.
    isValidEventFunction = isValidPlugin(handles.plugins.filters, newEventFunction);
    if isempty(channelNum)
        % Not a valid channel
        return
    end
    filenum = getCurrentFileNum(handles);
    if ~strcmp(getEventFunction(handles, filenum, channelNum), newEventFunction)
        % This is a different event function (filter)
        % Have to get new params
        if isValidEventFunction
            [handles.EventFunctionParams{filenum, channelNum}, ~] = eg_runPlugin(handles.plugins.filters, newEventFunction, 'params');
        else
            handles.EventFunctionParams{filenum, channelNum} = [];
        end
        % This function appears to not exist? Kinda confused.
        handles = setEventFunction(handles, filenum, channelNum, newEventFunction);
    end

function [handles, channelData, channelLabels] = loadChannelData(handles, channelNum, filterName, filterParams, filenum)
    if ~exist('filenum', 'var') || isempty(filenum)
        % No file number provided, use the current one
        filenum = getCurrentFileNum(handles);
    end
    if ~exist('filterName', 'var')
        % No filter info provided, assume we want unfiltered data
        filterName = '';
        filterParams = [];
    end

    % Check if this channel represents sound
    isSound = isChannelSound(channelNum);
    if isSound
        % Load using the specified sound loader
        loader = handles.sound_loader;
        filePath = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);
    else
        % Load using the specified channel data loader
        loader = handles.chan_loader{channelNum};
        filePath = fullfile(handles.DefaultRootPath, handles.chan_files{channelNum}(filenum).name);
    end
    if handles.EnableFileCaching
        % File is already cached - retrieve data
        [handles, data] = retrieveFileFromCache(handles, filePath, loader);
        [rawChannelData, ~, ~, channelLabels, ~] = data{:};
    else
        % File is not cached - load data
        [rawChannelData, ~, ~, channelLabels, ~] = eg_runPlugin(handles.plugins.loaders, loader, filePath, true);
    end
    if isempty(filterName)
        % Raw data requested
        channelData = rawChannelData;
    else
        % Filter data
        [channelData, channelLabels] = eg_runPlugin(handles.plugins.filters, filterName, rawChannelData, handles.fs, filterParams);

        % Fix length of filtered channel data
        [handles, numSamples] = eg_GetNumSamples(handles);
        % Resample data appropriately?
        if length(channelData) < numSamples
            indx = fix(linspace(1, length(handles.loadedChannelData{axnum}), numSamples));
            channelData = channelData(indx);
        end
    end
    
function handles = eg_LoadChannel(handles,axnum)
    % Load a new channel of data
    
    if handles.popup_Channels(axnum).Value==1
        % This is "(None)" channel selection, so disable everything
        cla(handles.axes_Channel(axnum));
        handles.axes_Channel(axnum).Visible = 'off';
        handles.popup_Functions(axnum).Enable = 'off';
        handles.popup_EventDetectors(axnum).Enable = 'off';
        handles.push_Detects(axnum).Enable = 'off';
        handles.ActiveEventNum = [];
        handles.ActiveEventPartNum = [];
        handles.ActiveEventSourceIdx = [];
        handles.loadedChannelData{axnum} = [];
        handles = UpdateEventViewer(handles);
        return
    else
        % This is an actual channel selection, enable the axes and function
        % menu.
        handles.axes_Channel(axnum).Visible = 'on';
        handles.popup_Functions(axnum).Enable = 'on';
    end

    % Load channel data
    selectedChannelNum = getSelectedChannel(handles, axnum);
    selectedFilter = getSelectedFilter(handles, axnum);
    selectedFilterParams = handles.FunctionParams{axnum};
    [handles, handles.loadedChannelData{axnum}, handles.Labels{axnum}] = loadChannelData(handles, selectedChannelNum, selectedFilter, selectedFilterParams);
    
    % Plot channel data
    handles = eg_PlotChannel(handles,axnum);

    % Update event display
    handles = UpdateChannelEventDisplay(handles, axnum);
    
    % Adjust axes limits
    if handles.menu_AutoLimits(axnum).Checked
        yl = [min(handles.loadedChannelData{axnum}), max(handles.loadedChannelData{axnum})];
        if yl(1)==yl(2)
            yl = [yl(1)-1 yl(2)+1];
        end
        ylim(handles.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        handles.ChanLimits(axnum, :) = ylim(handles.axes_Channel(axnum));
    else
        ylim(handles.axes_Channel(axnum), handles.ChanLimits(axnum, :));
    end
    
    % If overlay is requested, overlay channel data on another axes
    handles = eg_Overlay(handles);

    % Update event viewer in case it was showing data from this axes
    handles = UpdateEventViewer(handles);
    
function [handles, numSamples] = eg_GetNumSamples(handles)
    [handles, sound] = eg_GetSound(handles, false);
    numSamples = length(sound);
    
function [handles, sound] = eg_GetSound(handles, filtered, soundChannel)
    % Get the timeseries specified by handles.SoundChannel to use as sound for
    %   the purposes of plotting the spectrogram, etc
    
    if ~exist('filtered', 'var') || isempty(filtered)
        filtered = false;
    end
    if ~exist('soundChannel', 'var') || isempty(soundChannel)
        soundChannel = handles.SoundChannel;
    end
    
    switch soundChannel
        case 0
            % Use channel 0 (the normal sound channel)
            if filtered
                % User requested filtered sound
                if isempty(handles.filtered_sound)
                    handles = eg_FilterSound(handles);
                end
                sound = handles.filtered_sound;
            else
                % User just wants unfiltered sound
                if isempty(handles.sound)
                    filenum = getCurrentFileNum(handles);
                    filePath = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);
                    loader = handles.sound_loader;
    
                    if handles.EnableFileCaching
                        [handles, data] = retrieveFileFromCache(handles, filePath, loader);
                        [handles.sound, handles.fs] = data{:};
                    else
                        [handles.sound, handles.fs] = eg_runPlugin(handles.plugins.loaders, loader, filePath, true);
                    end
    
                    if size(handles.sound,2)>size(handles.sound,1)
                        handles.sound = handles.sound';
                    end
                end
                sound = handles.sound;
            end
        case getSelectedChannel(handles, 1)
            % Use whatever is loaded in channel axes #1 as sound
            sound = handles.loadedChannelData{2};
        case getSelectedChannel(handles, 2)
            % Use whatever is loaded in channel axes #2 as sound
            sound = handles.loadedChannelData{2};
        case 'calculated'
            sourceIndices = handles.popup_SoundSource.UserData;
            for k = 1:(length(sourceIndices)-1)
                channelIdx = sourceIndices{k};
                switch channelIdx
                    case 0
                        varName = 'sound';
                    otherwise
                        varName = sprintf('chan%d', channelIdx);
                end
                if regexp(handles.SoundExpression, varName)
                    if strcmp(varName, 'sound')
                        [handles, data] = eg_GetSound(handles, false, 0);
                    else
                        filenum = getCurrentFileNum(handles);
                        filePath = fullfile(handles.DefaultRootPath, handles.chan_files{channelIdx}(filenum).name);
                        loader = handles.chan_loader{channelIdx};
    
                        if handles.EnableFileCaching
                            [handles, data] = retrieveFileFromCache(handles, filePath, loader);
                            data = data{1};
                        else
                            data = eg_runPlugin(handles.plugins.loaders, loader, filePath, true);
                        end
    
                    end
                    assignin('base', varName, data);
                end
                try
                    sound = evalin('base', handles.SoundExpression);
                catch ME
                    fprintf('Error evaluating calculated channel: %s\n', handles.SoundExpression);
                    disp(ME)
                end
    
            end
        otherwise
            % Use some other not-already-loaded channel data as sound
            filenum = getCurrentFileNum(handles);
            filePath = fullfile(handles.DefaultRootPath, handles.chan_files{soundChannel}(filenum).name);
            loader = handles.chan_loader{soundChannel};
    
            if handles.EnableFileCaching
                [handles, data] = retrieveFileFromCache(handles, filePath, loader);
                sound = data{:};
            else
                sound = eg_runPlugin(handles.plugins.loaders, loader, filePath, true);
            end
    
            if size(handles.sound,2)>size(handles.sound,1)
                handles.sound = handles.sound';
            end
    end
    
function handles = eg_FilterSound(handles)
    for c = 1:length(handles.menu_Filter)
        if handles.menu_Filter(c).Checked
            alg = handles.menu_Filter(c).Label;
        end
    end
    
    [handles, sound] = eg_GetSound(handles, false);
    
    handles.filtered_sound = eg_runPlugin(handles.plugins.filters, alg, sound, handles.fs, handles.FilterParams);
    
function handles = eg_PlotChannel(handles, axnum)
    if ~handles.axes_Channel(axnum).Visible
        return
    end
    handles.axes_Channel(axnum).Visible = 'on';
    handles.popup_Functions(axnum).Enable = 'on';
    str = handles.popup_Channels(axnum).String;
    str = str{handles.popup_Channels(axnum).Value};
    if ~contains(str,' - ')
        handles.popup_EventDetectors(axnum).Enable = 'on';
        handles.push_Detects(axnum).Enable = 'on';
    else
        handles.popup_EventDetectors(axnum).Enable = 'off';
        handles.push_Detects(axnum).Enable = 'off';
    end
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    t = linspace(0,numSamples/handles.fs,numSamples);
    tlimits = handles.axes_Channel(axnum).XLim;
    delete(findobj('Parent',handles.axes_Channel(axnum), 'LineStyle', '-'));
    hold(handles.axes_Channel(axnum), 'on');
    if handles.menu_PeakDetects(axnum).Checked
        % Plot peak detection trace
        visibleTimeIdx = find(t>=tlimits(1) & t<=tlimits(2));
        if ~isempty(visibleTimeIdx)
            h = eg_peak_detect(handles.axes_Channel(axnum), t(visibleTimeIdx), handles.loadedChannelData{axnum}(visibleTimeIdx));
        end
    else
        % Plot plain data
        h = plot(handles.axes_Channel(axnum), t, handles.loadedChannelData{axnum});
    end

    hold(handles.axes_Channel(axnum), 'off');
    set(h,'Color',handles.ChannelColor(axnum,:));
    set(h,'LineWidth',handles.ChannelLineWidth(axnum));
    xlim(handles.axes_Channel(axnum), tlimits);
    
    handles.axes_Channel(axnum).XTickLabel = [];
    box(handles.axes_Channel(axnum), 'off');
    ylabel(handles.axes_Channel(axnum), handles.Labels{axnum});
    
    handles.axes_Channel(axnum).UIContextMenu = handles.context_Channels(axnum);
    handles.axes_Channel(axnum).ButtonDownFcn = @click_Channel;
    set(handles.axes_Channel(axnum).Children, 'UIContextMenu', handles.axes_Channel(axnum).UIContextMenu);
    set(handles.axes_Channel(axnum).Children, 'ButtonDownFcn', handles.axes_Channel(axnum).ButtonDownFcn);
    
function handles = SetSegmentThreshold(handles)
    % Clear segments axes
    cla(handles.axes_Segments);
    
    % Find threshold line handle on amplitude axes
    thr = findobj('Parent',handles.axes_Amplitude,'LineStyle',':');
    if isempty(thr)
        % No threshold line has been created yet
        ax = handles.axes_Amplitude;
        hold(ax, 'on')
        xl = xlim(ax);
        % Create new threshold line
        [handles, numSamples] = eg_GetNumSamples(handles);
        plot(ax, [0, numSamples/handles.fs],[handles.CurrentThreshold handles.CurrentThreshold],':',...
            'Color',handles.AmplitudeThresholdColor);
        xlim(ax, xl);
        hold(ax, 'off');
    
        % Check if there are any segment times recorded
        if size(handles.SegmentTimes{getCurrentFileNum(handles)},2)==0
            % No segment times found
            if handles.menu_AutoSegment.Checked
                % User has requested auto-segmentation. Auto segment!
                handles = SegmentSounds(handles);
            end
        else
            % Segment times already exist, just plot them (probably preexisting
            % from loaded dbase?)
            handles = PlotAnnotations(handles);
        end
    else
        % Threshold line already exists, just update its Y position
        thr.YData = [handles.CurrentThreshold handles.CurrentThreshold];
        if handles.menu_AutoSegment.Checked
            % User has requested auto-segmentation. Auto-segment!
            handles = SegmentSounds(handles);
        end
    end
    
    % Link segment context menu to segment axes
    handles.axes_Segments.UIContextMenu = handles.context_Segments;
    handles.axes_Segments.ButtonDownFcn = @click_segmentaxes;
    
function handles = SegmentSounds(handles)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'Type','text'))
        return
    end
    
    for c = 1:length(handles.menu_Segmenter)
        if handles.menu_Segmenter(c).Checked
            alg = handles.menu_Segmenter(c).Label;
        end
    end
    
    filenum = getCurrentFileNum(handles);
    handles.SegmenterParams.IsSplit = 0;
    handles.SegmentTimes{filenum} = eg_runPlugin(handles.plugins.segmenters, ...
        alg, handles.amplitude, handles.fs, handles.CurrentThreshold, ...
        handles.SegmenterParams);
    handles.SegmentTitles{filenum} = cell(1,size(handles.SegmentTimes{filenum},1));
    handles.SegmentSelection{filenum} = ones(1,size(handles.SegmentTimes{filenum},1));
    
    handles = PlotAnnotations(handles);
    
function [annotationHandles, labelHandles] = CreateAnnotations(handles, ax, times, titles, selects, selectColor, unselectColor, activeColor, inactiveColor, yExtent, activeIndex)
    % Create the annotations for a set of timed segments (used for plotting both
    % "segments" and "markers")

    if ~exist('activeIndex', 'var')
        activeIndex = [];
    end
    
    % Create a time vector that corresponds to the loaded audio samples
    [handles, numSamples] = eg_GetNumSamples(handles);
    ts = linspace(0, numSamples/handles.fs, numSamples);
    
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
        newAnnotation.ButtonDownFcn = @click_segment;
        newLabel.ButtonDownFcn = @(hObject, event)click_segment(newAnnotation, event);

        % Put new handles in list
        labelHandles(annotationNum) = newLabel;
        annotationHandles(annotationNum) = newAnnotation;
    end

function handles = UpdateAnnotationTitleDisplay(handles, annotationNums, annotationType, filenum)
    % A function for updating only one or more annotation titles
    % Use this cautiously, only if you're sure the only change that needs
    % updating is a single title. If more things have changed, use
    % PlotAnnotations instead to fully refresh.
    
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    if ~exist('annotationNums', 'var') || isempty(annotationNums)
        % No annotation number provided - use the currently active one
        [annotationNums, ~] = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    if strcmp(annotationNums, 'all')
        numAnnotations = GetNumAnnotations(handles, annotationType);
        annotationNums = 1:numAnnotations;
    end

    switch annotationType
        case 'segment'
            for annotationNum = annotationNums
                handles.SegmentLabelHandles(annotationNum).String = handles.SegmentTitles{filenum}(annotationNum);
            end
        case 'marker'
            for annotationNum = annotationNums
                handles.MarkerLabelHandles(annotationNum).String = handles.MarkerTitles{filenum}(annotationNum);
            end
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
function handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum, oldAnnotationType, newAnnotationNum, newAnnotationType)
    % A function for updating only the active annotation highlight
    % Use this cautiously, only if you're sure the only change that needs
    % updating is the highlight. If more things have changed, use
    % PlotAnnotations instead to fully refresh.
    if ~exist('oldAnnotationNum', 'var') || isempty(oldAnnotationNum)
        % No annotation number provided - use the currently active one
        [oldAnnotationNum, ~] = FindActiveAnnotation(handles);
    end
    if ~exist('oldAnnotationType', 'var') || isempty(oldAnnotationType)
        % No annotation type provided - use the currently active type
        [~, oldAnnotationType] = FindActiveAnnotation(handles);
    end
    if ~exist('newAnnotationNum', 'var') || isempty(newAnnotationNum)
        % No annotation number provided - use the currently active one
        [newAnnotationNum, ~] = FindActiveAnnotation(handles);
    end
    if ~exist('newAnnotationType', 'var') || isempty(newAnnotationType)
        % No annotation type provided - use the currently active type
        [~, newAnnotationType] = FindActiveAnnotation(handles);
    end

    % Update old active segment display to inactive
    switch oldAnnotationType
        case 'segment'
            handles.SegmentHandles(oldAnnotationNum).EdgeColor = handles.SegmentInactiveColor;
            handles.SegmentHandles(oldAnnotationNum).LineWidth = 1;
            handles.SegmentHandles(oldAnnotationNum).LineStyle = '-';
        case 'marker'
            handles.MarkerHandles(oldAnnotationNum).EdgeColor = handles.MarkerInactiveColor;
            handles.MarkerHandles(oldAnnotationNum).LineWidth = 1;
            handles.MarkerHandles(oldAnnotationNum).LineStyle = '-';
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
    switch newAnnotationType
        case 'segment'
            handles.SegmentHandles(newAnnotationNum).EdgeColor = handles.SegmentActiveColor;
            handles.SegmentHandles(newAnnotationNum).LineWidth = 2;
            handles.SegmentHandles(oldAnnotationNum).LineStyle = '-';
        case 'marker'
            handles.MarkerHandles(newAnnotationNum).EdgeColor = handles.MarkerActiveColor;
            handles.MarkerHandles(newAnnotationNum).LineWidth = 2;
            handles.MarkerHandles(oldAnnotationNum).LineStyle = '-';
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
function handles = PlotAnnotations(handles, modes)
    % Get segment axes
    ax = handles.axes_Segments;

    % Set axes properties
    hold(ax, 'on');
    % Set time-zoom state of segment axes to match audio axes
    xlim(ax, handles.TLim);
    % Set y-scale of axes
    ylim(ax, [-2 3.5]);
    % Get figure background color
    % Set segment axes background & axis colors to the figure background color, I guess to hide them
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    ax.Color = 'none';
    % Assign context menu and click listener to segment axes
    ax.ButtonDownFcn = @click_segmentaxes;
    ax.UIContextMenu = handles.context_Segments;
    % Assign key press function to figure (keyPressHandler) for labeling segments
    handles.figure_Main.KeyPressFcn = @keyPressHandler;

    % Clear segment handles and segment label handles
    delete(handles.SegmentHandles);
    handles.SegmentHandles = gobjects().empty;
    delete(handles.SegmentLabelHandles);
    handles.SegmentLabelHandles = gobjects().empty;
    % Clear marker handles and marker label handles
    delete(handles.MarkerHandles);
    handles.MarkerHandles = gobjects().empty;
    delete(handles.MarkerLabelHandles);
    handles.MarkerLabelHandles = gobjects().empty;
    
    filenum = getCurrentFileNum(handles);
    
    [handles.SegmentHandles, handles.SegmentLabelHandles] = CreateAnnotations(handles, ...
        handles.axes_Segments, ...
        handles.SegmentTimes{filenum}, ...
        handles.SegmentTitles{filenum}, ...
        handles.SegmentSelection{filenum}, ...
        handles.SegmentSelectColor, handles.SegmentUnSelectColor, ...
        handles.SegmentActiveColor, handles.SegmentInactiveColor, [-1, 1]);
    
    [handles.MarkerHandles, handles.MarkerLabelHandles] = CreateAnnotations(handles, ...
        handles.axes_Segments, ...
        handles.MarkerTimes{filenum}, ...
        handles.MarkerTitles{filenum}, ...
        handles.MarkerSelection{filenum}, ...
        handles.MarkerSelectColor, handles.MarkerUnSelectColor, ...
        handles.MarkerActiveColor, handles.MarkerInactiveColor, [1, 3]);

    % Ensure active annotation setting is valid
    handles = SanityCheckActiveAnnotation(handles, filenum);

    % Update active segment highlight
    if ~isempty(handles.ActiveSegmentNum)
        handles.SegmentHandles(handles.ActiveSegmentNum).EdgeColor = handles.SegmentActiveColor;
        handles.SegmentHandles(handles.ActiveSegmentNum).LineWidth = 2;
        handles.SegmentHandles(handles.ActiveSegmentNum).LineStyle = '-';
    end
    % Update active marker highlight
    if ~isempty(handles.ActiveMarkerNum)
        handles.MarkerHandles(handles.ActiveMarkerNum).EdgeColor = handles.MarkerActiveColor;
        handles.MarkerHandles(handles.ActiveMarkerNum).LineWidth = 2;
        handles.MarkerHandles(handles.ActiveMarkerNum).LineStyle = '-';
    end

    hold(ax, 'off');
    
function handles = SanityCheckActiveAnnotation(handles, filenum)
    % Make sure the handles.ActiveSegmentNum and handles.ActiveMarkerNum
    % make sense

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    numSegments = GetNumAnnotations(handles, 'segment', filenum);
    numMarkers = GetNumAnnotations(handles, 'marker', filenum);
    if isempty(handles.ActiveSegmentNum) && isempty(handles.ActiveMarkerNum)
        % Nothing is active - make 1st segment active if there are any
        if numSegments > 0
            handles.ActiveSegmentNum = 1;
        end
    elseif isempty(handles.ActiveSegmentNum) && ~isempty(handles.ActiveMarkerNum)
        % Marker is active - make sure it's valid
        if numMarkers == 0
            % No markers
            handles.ActiveMarkerNum = [];
            if numSegments > 0
                % There is a segment - make the first one of those active
                handles.ActiveSegmentNum = 1;
            end
        elseif handles.ActiveMarkerNum > numMarkers
            % There are markers, but the active one is out of range
            handles.ActiveMarkerNum = numMarkers;
        end
    elseif ~isempty(handles.ActiveSegmentNum) && isempty(handles.ActiveMarkerNum)
        % Segment is active - make sure it's valid
        if numSegments== 0
            % No segments
            handles.ActiveSegmentNum = [];
            if numMarkers > 0
                % There is a marker - make the first one of those active
                handles.ActiveMarkerNum = 1;
            end
        elseif handles.ActiveSegmentNum > numSegments
            % There are segments, but the active one is out of range
            handles.ActiveSegmentNum = numSegments;
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
    
% --------------------------------------------------------------------
function context_Sonogram_Callback(hObject, ~, handles)
    % hObject    handle to context_Sonogram (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AlgorithmList_Callback(hObject, ~, handles)
    % hObject    handle to menu_AlgorithmList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AutoCalculate_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoCalculate (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_AutoCalculate.Checked
        handles.menu_AutoCalculate.Checked = 'off';
    else
        handles.menu_AutoCalculate.Checked = 'on';
        handles = eg_PlotSonogram(handles);
    end
    
    guidata(hObject, handles);
    
    
function AlgorithmMenuClick(hObject, ~, handles)
    
    for c = 1:length(handles.menu_Algorithm)
        handles.menu_Algorithm.Checked = 'off';
    end
    hObject.Checked = 'on';
    
    if isempty(hObject.UserData)
        alg = hObject.Label;
        handles.SonogramParams = eg_runPlugin(handles.plugins.spectrums, alg, 'params');
        hObject.UserData = handles.SonogramParams;
    else
        handles.SonogramParams = hObject.UserData;
    end
    
    handles = eg_PlotSonogram(handles);
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
    
function FilterMenuClick(hObject, event)
    handles = guidata(hObject);
    
    for c = 1:length(handles.menu_Filter)
        handles.menu_Filter(c).Checked = 'off';
    end
    hObject.Checked = 'on';
    
    if isempty(hObject.UserData)
        alg = hObject.Label;
        handles.FilterParams = eg_runPlugin(handles.plugins.functions, alg, 'params');
        hObject.UserData = handles.FilterParams;
    else
        handles.FilterParams = hObject.UserData;
    end
    
    handles = eg_FilterSound(handles);
    
    cla(handles.axes_Sound);
    [handles, filtered_sound] = eg_GetSound(handles, true);
    [handles, numSamples] = eg_GetNumSamples(handles);
    h = eg_peak_detect(handles.axes_Sound, linspace(0, numSamples/handles.fs, numSamples), filtered_sound);
    [h.Color] = deal('c');
    set(handles.axes_Sound,'XTick',[],'YTick',[]);
    handles.axes_Sound.Color = [0 0 0];
    axis(handles.axes_Sound, 'tight');
    yl = max(abs(ylim(handles.axes_Sound)));
    ylim(handles.axes_Sound, [-yl*1.2 yl*1.2]);
    
    handles = updateXLimBox(handles);

    box(handles.axes_Sound, 'on');
    
    handles = setClickSoundCallback(handles, handles.axes_Sonogram);
    handles = setClickSoundCallback(handles, handles.axes_Sound);

    handles = updateAmplitude(handles);

    guidata(hObject, handles);
    
function handles = updateXLimBox(handles)
    % Update the yellow dotted line box on the sound axes that shows what 
    % the zoomed in view is
    yl = ylim(handles.axes_Sound);

    % Calculate updated position of box
    xdata = [handles.TLim(1), handles.TLim(2), handles.TLim(2), handles.TLim(1), handles.TLim(1)];
    ydata = [yl(1), yl(1), yl(2), yl(2), yl(1)]*0.93;

    if ~isfield(handles, 'xlimbox') || isempty(handles.xlimbox) || ~isvalid(handles.xlimbox)
        % No xlimbox currently, create a new one
        hold(handles.axes_Sound, 'on');
        handles.xlimbox = plot(handles.axes_Sound, ...
            xdata, ydata, ':y', 'LineWidth', 2);
        hold(handles.axes_Sound, 'off');
    else
        % xlimbox already exists, just update position
        handles.xlimbox.XData = xdata;
        handles.xlimbox.YData = ydata;
    end

function handles = eg_EditTimescale(handles)
    % Function that handles updating all the axes to show the appropriate
    % timescale together, based on the value in handles.TLim
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    numSeconds = numSamples / handles.fs;

    % Adjust view time limits if they exceed the boundaries of the data
    handles.TLim(handles.TLim < 0) = 0;
    handles.TLim(handles.TLim > numSeconds) = numSeconds;
    % Ensure second time limit is greater than first
    if diff(handles.TLim) < 0
        handles.TLim = flip(handles.TLim);
    elseif diff(handles.TLim) == 0
        handles.TLim = [0, numSeconds];
    end

    xlim(handles.axes_Sound, [0, numSeconds]);

    if handles.menu_AutoCalculate.Checked
        handles = eg_PlotSonogram(handles);
    else
        xlim(handles.axes_Sonogram, handles.TLim);
%         handles.axes_Sonogram.UIContextMenu = handles.context_Sonogram;
    
%         handles = setClickSoundCallback(handles, handles.axes_Sonogram);
        handles = setClickSoundCallback(handles, handles.axes_Sound);
    end

    % Update xlimbox
    handles = updateXLimBox(handles);
    
    % Update string that shows the amount of time visible I guess?
    handles.edit_Timescale.String = num2str(diff(handles.TLim),4);
    

    % Set amplitude axes time limits to match
    xlim(handles.axes_Amplitude, handles.TLim);
    % Set segments axes limits to match
    xlim(handles.axes_Segments, handles.TLim);
    
    for axnum = 1:2
        yl = ylim(handles.axes_Channel(axnum));
        xlim(handles.axes_Channel(axnum), handles.TLim);
        if handles.menu_PeakDetects(axnum).Checked
            handles = eg_PlotChannel(handles, axnum);
        end
        ylim(handles.axes_Channel(axnum), yl);
    end
    
    handles.slider_Time.Min = 0;
    handles.slider_Time.Max = numSeconds - diff(handles.TLim) + eps;
    handles.slider_Time.Value = handles.TLim(1);
    stp = min([1 diff(handles.TLim)/((numSeconds-diff(handles.TLim))+eps)]);
    handles.slider_Time.SliderStep = [0.1*stp 0.5*stp];
    
    handles = eg_Overlay(handles);
    
function handles = eg_PlotSonogram(handles)
    [handles, sound] = eg_GetSound(handles);
    
    sampleLims = round(handles.TLim * handles.fs);
    % Ensure sample numbers are in range
    [handles, numSamples] = eg_GetNumSamples(handles);
    if sampleLims(1) < 1
        sampleLims(1) = 1;
    end
    if sampleLims(2) > numSamples
        sampleLims(2) = numSamples;
    end

    % Determine current spectrogram algorithm?
    for c = 1:length(handles.menu_Algorithm)
        if handles.menu_Algorithm(c).Checked
            alg = handles.menu_Algorithm(c).Label;
            break;
        end
    end
    
    cla(handles.axes_Sonogram);
    xlim(handles.axes_Sonogram, handles.TLim);
    if handles.menu_FrequencyZoom.Checked
        ylim(handles.axes_Sonogram, handles.CustomFreqLim);
    else
        ylim(handles.axes_Sonogram, handles.FreqLim);
    end
    handles.ispower = eg_runPlugin(handles.plugins.spectrums, alg, ...
        handles.axes_Sonogram, sound(sampleLims(1):sampleLims(2)), handles.fs, ...
        handles.SonogramParams);
    handles.axes_Sonogram.Units = 'normalized';
    handles.axes_Sonogram.YDir = 'normal';
    handles.axes_Sonogram.UIContextMenu = handles.context_Sonogram;
    
    handles.NewSlope = handles.DerivativeSlope;
    handles.DerivativeSlope = 0;
    handles = SetSonogramColors(handles);
    
    xt = handles.axes_Sonogram.YTick;
    handles.axes_Sonogram.YTickLabel  = xt/1000;
    ylabel(handles.axes_Sonogram, 'Frequency (kHz)');
    
    ch = handles.axes_Sonogram.Children;
    for c = 1:length(ch)
        ch(c).UIContextMenu = handles.axes_Sonogram.UIContextMenu;
    end

    handles = setClickSoundCallback(handles, handles.axes_Sonogram);
    xlim(handles.axes_Sonogram, handles.TLim);
    
function click_sound(hObject, event)
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

    handles = guidata(hObject);

    current_axes = hObject;
    
    if strcmp(handles.figure_Main.SelectionType, 'normal')
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
%             shift = rect(1) - handles.TLim(1);
%             handles.TLim = handles.TLim + shift;
        else
            if handles.menu_FrequencyZoom.Checked && (hObject==handles.axes_Sonogram || hObject.Parent==handles.axes_Sonogram)
                % We're zooming along the y-axis (frequency) as well as x
                rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
                handles.CustomFreqLim = [rect(2) rect(2)+rect(4)];
                ylim([rect(2) rect(2)+rect(4)]);
            end
            handles.TLim = [rect(1), rect(1)+rect(3)];
        end
        % Update spectrogram scales
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType, 'extend')
        % Shift-click
        %   Shift zoom box so the right side aligns with click location
        % Nah
%         pos = current_axes.CurrentPoint;
%         if pos(1,1) < handles.TLim(1)
%             return
%         end
%         handles.TLim(2) = pos(1,1);
%         % Update spectrogram scales
%         handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        % Double-click
        %   Reset zoom
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        handles.TLim = [0, numSamples/handles.fs];
        handles = eg_EditTimescale(handles);

        if handles.menu_FrequencyZoom.Checked
            % We're resetting y-axis (frequency) zoom too
            handles.CustomFreqLim = handles.FreqLim;
        end
        % Update spectrogram scales
    elseif strcmp(handles.figure_Main.SelectionType, 'alt') && ~isempty(handles.figure_Main.CurrentModifier) && strcmp(handles.figure_Main.CurrentModifier, 'control')
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
        x = round(handles.fs * x);
    
        % Add new marker to backend
        handles = CreateNewMarker(handles, x);

        % Replot frontend annotation display
        handles = PlotAnnotations(handles);
    end
    
    guidata(hObject, handles);

function click_segment(hObject, event)
    % Callback for clicking anything on the axes_Segments
    handles = guidata(hObject);
    
    % Search for clicked item among segments
    clickedAnnotationNum = find(handles.SegmentHandles==hObject);
    if isempty(clickedAnnotationNum)
        % No matching segment found. Must be a marker.
        clickedAnnotationNum = find(handles.MarkerHandles==hObject);
        clickedAnnotationType = 'marker';
    else
        clickedAnnotationType = 'segment';
    end
    
    filenum = getCurrentFileNum(handles);
    switch handles.figure_Main.SelectionType
        case 'normal'
            [oldAnnotationNum, oldAnnotationType] = FindActiveAnnotation(handles);
            switch clickedAnnotationType
                case 'segment'
                    handles = SetActiveSegment(handles, clickedAnnotationNum);
                case 'marker'
                    handles = SetActiveMarker(handles, clickedAnnotationNum);
            end
            handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum, oldAnnotationType, clickedAnnotationNum, clickedAnnotationType);
        case 'extend'
            switch clickedAnnotationType
                case 'segment'
                    handles.SegmentSelection{filenum}(clickedAnnotationNum) = ~handles.SegmentSelection{filenum}(clickedAnnotationNum);
                    hObject.FaceColor = handles.SegmentSelectColors{handles.SegmentSelection{filenum}(clickedAnnotationNum+1)};
                case 'marker'
                    handles.MarkerSelection{filenum}(clickedAnnotationNum) = ~handles.MarkerSelection{filenum}(clickedAnnotationNum);
                    hObject.FaceColor = handles.MarkerSelectColors{handles.MarkerSelection{filenum}(clickedAnnotationNum+1)};
            end
        case 'open'
            switch clickedAnnotationType
                case 'segment'
                    if clickedAnnotationNum < length(handles.SegmentHandles)
                        % Deselect active segment
                        handles = SetActiveSegment(handles, []);
                        handles.SegmentTimes{filenum}(clickedAnnotationNum,2) = handles.SegmentTimes{filenum}(clickedAnnotationNum+1,2);
                        handles.SegmentTimes{filenum}(clickedAnnotationNum+1,:) = [];
                        handles.SegmentTitles{filenum}(clickedAnnotationNum+1) = [];
                        handles.SegmentSelection{filenum}(clickedAnnotationNum+1) = [];
                        % Select new active segment
                        handles = SetActiveSegment(handles, clickedAnnotationNum);
                        handles.figure_Main.KeyPressFcn = @keyPressHandler;
                        handles = PlotAnnotations(handles);
                        hObject = handles.axes_Segments;
                    end
                case 'marker'
                    % Nah, doubt we need to implement concatenating adjacent
                    % markers.
            end
    end
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function context_Segments_Callback(hObject, ~, handles)
    % hObject    handle to context_Segments (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_SegmenterList_Callback(hObject, ~, handles)
    % hObject    handle to menu_SegmenterList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_DeleteAll_Callback(hObject, ~, handles)
    % hObject    handle to menu_DeleteAll (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    filenum = getCurrentFileNum(handles);
    handles.SegmentSelection{filenum} = zeros(size(handles.SegmentSelection{filenum}));
    
    handles = updateSegmentSelectHighlight(handles);
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_UndeleteAll_Callback(hObject, ~, handles)
    % hObject    handle to menu_UndeleteAll (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    filenum = getCurrentFileNum(handles);
    handles.SegmentSelection{filenum} = ones(size(handles.SegmentSelection{filenum}));
    
    handles = updateSegmentSelectHighlight(handles);
    
    guidata(hObject, handles);

% --- Executes on button press in push_Segment.
function push_Segment_Callback(hObject, ~, handles)
    % hObject    handle to push_Segment (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SegmentSounds(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_AutoSegment_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoSegment (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_AutoSegment.Checked
        handles.menu_AutoSegment.Checked = 'on';
        handles = SegmentSounds(handles);
    else
        handles.menu_AutoSegment.Checked = 'off';
    end
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_SegmentParameters_Callback(hObject, ~, handles)
    % hObject    handle to menu_SegmentParameters (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if isempty(handles.SegmenterParams.Names)
        errordlg('Current segmenter does not require parameters.','Segmenter error');
        return
    end
    
    answer = inputdlg(handles.SegmenterParams.Names,'Segmenter parameters',1,handles.SegmenterParams.Values);
    if isempty(answer)
        return
    end
    handles.SegmenterParams.Values = answer;
    
    for c = 1:length(handles.menu_Segmenter)
        if handles.menu_Segmenter(c).Checked
            h = handles.menu_Segmenter(c);
            h.UserData = handles.SegmenterParams;
        end
    end
    
    handles = SegmentSounds(handles);
    
    guidata(hObject, handles);
    
function SegmenterMenuClick(hObject, ~, handles)
    
    for c = 1:length(handles.menu_Segmenter)
        handles.menu_Segmenter(c).Checked = 'off';
    end
    hObject.Checked = 'on';
    
    if isempty(hObject.UserData)
        alg = hObject.Label;
        handles.SegmenterParams = eg_runPlugin(handles.plugins.segmenters, alg, 'params');
        hObject.UserData = handles.SegmenterParams;
    else
        handles.SegmenterParams = hObject.UserData;
    end
    
    handles = SetSegmentThreshold(handles);
    
    guidata(hObject, handles);

function handles = updateSegmentSelectHighlight(handles)
    % Set the color of the segment handle depending on whether or not
    % the segment is selected
    for segmentNum = 1:length(handles.SegmentHandles)
        if handles.SegmentSelection{filenum}(segmentNum)
            handles.SegmentHandles(k).FaceColor = handles.SegmentSelectColor;
        else
            handles.SegmentHandles(k).FaceColor = handles.SegmentUnSelectColor;
        end
    end
    
function click_segmentaxes(hObject, event)
    handles = guidata(hObject);
    
    filenum = getCurrentFileNum(handles);
    
    if strcmp(handles.figure_Main.SelectionType,'normal')
        % This code takes a selection of segments and toggles their selection
        %   status. Note that it used to set the selection status to unselected
        %   if less than half of the selected segments were selected. Which
        %   seems...convoluted and weird. So I changed it to just toggling all
        %   the selection statuses.
        handles.axes_Segment.Units = 'pixels';
        handles.axes_Segment.Parent.Units = 'pixels';
        rect = rbbox;
    
        if rect(3) < 10
        % This was probably not intended to be a click-and-drag - ignore it
            return
        end
    
        pos = handles.axes_Segment.Position;
        handles.axes_Segment.Parent.Units = 'normalized';
        handles.axes_Segment.Units = 'normalized';
        xl = xlim(handles.axes_Segment);
    
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    
        f = find(handles.SegmentTimes{filenum}(:,1)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*handles.fs);
        g = find(handles.SegmentTimes{filenum}(:,2)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*handles.fs);
        h = find(handles.SegmentTimes{filenum}(:,1)<rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*handles.fs);
        f = unique([f; g; h]);
    
        handles.SegmentSelection{filenum}(f) = ~handles.SegmentSelection{filenum}(f); %sum(handles.SegmentSelection{filenum}(f))<=length(f)/2;
        handles = updateSegmentSelectHighlight(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        handles.TLim = [0, numSamples/handles.fs];
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        if sum(handles.SegmentSelection{filenum})==length(handles.SegmentSelection{filenum})
            handles.SegmentSelection{filenum} = zeros(size(handles.SegmentSelection{filenum}));
        else
            handles.SegmentSelection{filenum} = ones(size(handles.SegmentSelection{filenum}));
        end
        handles = updateSegmentSelectHighlight(handles);
    end
    
    guidata(hObject, handles);

function handles = ToggleAnnotationSelect(handles, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    switch annotationType
        case 'segment'
            handles = ToggleSegmentSelect(handles, filenum, annotationNum);
        case 'marker'
            handles = ToggleMarkerSelect(handles, filenum, annotationNum);
    end
function handles = ToggleSegmentSelect(handles, filenum, segmentNum)
    handles.SegmentSelection{filenum}(segmentNum) = ~handles.SegmentSelection{filenum}(segmentNum);
    handles.SegmentHandles(segmentNum).FaceColor = handles.SegmentSelectColors{handles.SegmentSelection{filenum}(segmentNum)+1};
function handles = ToggleMarkerSelect(handles, filenum, markerNum)
    handles.MarkerSelection{filenum}(markerNum) = ~handles.MarkerSelection{filenum}(markerNum);
    handles.MarkerHandles(markerNum).FaceColor = handles.MarkerSelectColors{handles.MarkerSelection{filenum}(markerNum)+1};

function [annotationNum, annotationType] = FindActiveAnnotation(handles)
    % Get the index of the active segment or marker

    activeSegmentNum = FindActiveSegment(handles);
    activeMarkerNum = FindActiveMarker(handles);
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
function markerNum = FindActiveMarker(handles)
    % Get the index of the active marker
    markerNum = handles.ActiveMarkerNum;
function segmentNum = FindActiveSegment(handles)
    % Get the index of the active segment
    segmentNum = handles.ActiveSegmentNum;

function [newAnnotationNum, newAnnotationType] = FindClosestAnnotationOfOtherType(handles, filenum, annotationNum, annotationType)
    % Find the marker or segment closest in time to the currently selected
    %   segment or marker. If no annotations of the other type exist,
    %   return the same annotation.

    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end
    switch annotationType
        case 'segment'
            if isempty(handles.MarkerHandles)
                % No markers to switch to, do nothing
                newAnnotationNum = annotationNum;
                newAnnotationType = 'segment';
                return
            end
            segmentTime = mean(handles.SegmentTimes{filenum}(annotationNum, :));
            markerTimes = mean(handles.MarkerTimes{filenum}, 2);
            % Find segment closest in time to the active marker, and switch
            % to that active segment.
            [~, newAnnotationNum] = min(abs(markerTimes - segmentTime));
            newAnnotationType = 'marker';
        case 'marker'
            if isempty(handles.SegmentHandles)
                % No segments to switch to, do nothing
                newAnnotationNum = annotationNum;
                newAnnotationType = 'marker';
                return
            end
            markerTime = mean(handles.MarkerTimes{filenum}(annotationNum, :));
            segmentTimes = mean(handles.SegmentTimes{filenum}, 2);
            % Find segment closest in time to the active marker, and switch
            % to that active segment.
            [~, newAnnotationNum] = min(abs(segmentTimes - markerTime));
            newAnnotationType = 'segment';    
    end

function [handles, annotationNums, annotationType] = PasteAnnotationTitles(handles, annotationStartNum, annotationType, filenum)
    contents = clipboard('paste');
    newTitles = split(contents, ' ')';

    if ~exist('annotationStartNum', 'var') || isempty(annotationStartNum)
        % No annotation number provided - use the currently active one
        annotationStartNum = FindActiveAnnotation(handles);
    end
    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end
    numAnnotations = GetNumAnnotations(handles, annotationType, filenum);
    annotationNums = annotationStartNum:(annotationStartNum+length(newTitles)-1);
    inRangeNums = (annotationNums <= numAnnotations);
    newTitles = newTitles(inRangeNums);
    annotationNums = annotationNums(inRangeNums);
    handles = SetAnnotationTitles(handles, newTitles, filenum, annotationNums, annotationType);

function [handles, changedAnnotationNums] = InsertBlankAnnotationTitle(handles, annotationNum, annotationType, filenum)
    % Insert a blank annotation title at the specified location, then shift
    % existing annotation titles forward, stopping the shift at the first
    % blank title, if there is one.
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end
    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    switch annotationType
        case 'segment'
            remainingTitles = handles.SegmentTitles{filenum}(annotationNum:end);
        case 'marker'
            remainingTitles = handles.MarkerTitles{filenum}(annotationNum:end);
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
            handles.SegmentTitles{filenum}(annotationNum:end) = remainingTitles;
        case 'marker'
            handles.MarkerTitles{filenum}(annotationNum:end) = remainingTitles;
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
    
function handles = SetAnnotationTitles(handles, titles, filenum, annotationNums, annotationType)
    % Set the titles of specified segments or markers
    % Titles is a cell array of annotation titles and annotationNums is an 
    % array of annotation numbers to set.
    % They all must have the same filenum and annotationType

    if length(titles) ~= length(annotationNums)
        error('titles and annotationsNums must have the same length');
    end

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    switch annotationType
        case 'segment'
            % Set the segment title
            handles.SegmentTitles{filenum}(annotationNums) = titles;
        case 'marker'
            % Set the marker title
            handles.MarkerTitles{filenum}(annotationNums) = titles;
        otherwise
            % Do nothing for 'none' or invalid type
    end
    
function handles = SetAnnotationTitle(handles, title, filenum, annotationNum, annotationType)
    % Set the title of the specified segment or marker

    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    switch annotationType
        case 'segment'
            % Set the segment title
            handles.SegmentTitles{filenum}{annotationNum} = title;
        case 'marker'
            % Set the marker title
            handles.MarkerTitles{filenum}{annotationNum} = title;
        otherwise
            % Do nothing for 'none' or invalid type
    end

function handles = JoinSegmentWithNext(handles, filenum, segmentNum)
    if segmentNum < length(handles.SegmentHandles)
        % This is not the last segment in the file
        handles.SegmentTimes{filenum}(segmentNum,2) = handles.SegmentTimes{filenum}(segmentNum+1,2);
        handles.SegmentTimes{filenum}(segmentNum+1,:) = [];
        handles.SegmentTitles{filenum}(segmentNum+1) = [];
        handles.SegmentSelection{filenum}(segmentNum+1) = [];
        handles = PlotAnnotations(handles);
        handles = SetActiveSegment(handles, segmentNum);
        handles.figure_Main.KeyPressFcn = @keyPressHandler;
    end
    
function handles = CreateNewMarker(handles, x)
    % Create a new marker from time x(1) to time x(2)
    filenum = getCurrentFileNum(handles);
    handles.MarkerTimes{filenum}(end+1, :) = x;
    handles.MarkerSelection{filenum}(end+1) = 1;
    handles.MarkerTitles{filenum}{end+1} = '';
    
    % Sort markers chronologically to keep things neat
    [handles, order] = SortMarkers(handles, filenum);
    [~, mostRecentMarkerNum] = max(order);
    % Set active marker again, so the same marker is still active
    handles = SetActiveMarker(handles, mostRecentMarkerNum);
    
function handles = DeleteAnnotation(handles, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    switch annotationType
        case 'segment'
            % Delete the specified marker
            handles = DeleteSegment(handles, filenum, annotationNum);
        case 'marker'
            % Delete the specified marker
            handles = DeleteMarker(handles, filenum, annotationNum);
        otherwise
    end
function handles = DeleteMarker(handles, filenum, markerNum)
    % Delete the specified marker
    handles.MarkerTimes{filenum}(markerNum, :) = [];
    handles.MarkerSelection{filenum}(markerNum) = [];
    handles.MarkerTitles{filenum}(markerNum) = [];
function handles = DeleteSegment(handles, filenum, segmentNum)
    % Delete the specified marker
    handles.SegmentTimes{filenum}(segmentNum, :) = [];
    handles.SegmentSelection{filenum}(segmentNum) = [];
    handles.SegmentTitles{filenum}(segmentNum) = [];
function [handles, order] = SortMarkers(handles, filenum)
    % Sort the order of the markers. Note that this doesn't affect the marker
    % data at all, just keeps them stored in chronological order.
    
    % Get sort order based on marker start times
    [~, order] = sort(handles.MarkerTimes{filenum}(:, 1));
    handles.MarkerTimes{filenum} = handles.MarkerTimes{filenum}(order, :);
    handles.MarkerSelection{filenum} = handles.MarkerSelection{filenum}(order);
    handles.MarkerTitles{filenum} = handles.MarkerTitles{filenum}(order);
    handles.MarkerHandles = handles.MarkerHandles(order);
function numAnnotations = GetNumAnnotations(handles, annotationType, filenum)
    if ~exist('filenum', 'var') || isempty(filenum)
        filenum = getCurrentFileNum(handles);
    end

    switch annotationType
        case 'segment'
            numAnnotations = length(handles.SegmentTitles{filenum});
        case 'marker'
            numAnnotations = length(handles.MarkerTitles{filenum});
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
function handles = SetActiveAnnotation(handles, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end

    switch annotationType
        case 'segment'
            handles = SetActiveSegment(handles, annotationNum);
        case 'marker'
            handles = SetActiveMarker(handles, annotationNum);
        otherwise
            error('Invalid annotation type: %s', annotationType);
    end
function handles = SetActiveMarker(handles, markerNum)
    % Set new selected marker number
    numMarkers = GetNumAnnotations(handles, 'marker');
    if numMarkers > 0
        handles.ActiveMarkerNum = mod(markerNum-1, numMarkers)+1;
        handles.ActiveSegmentNum = [];
    else
        handles.ActiveMarkerNum = [];
    end
function handles = SetActiveSegment(handles, segmentNum)
    % Set new selected segment number
    numSegments = GetNumAnnotations(handles, 'segment');
    if numSegments > 0
        handles.ActiveSegmentNum = mod(segmentNum-1, numSegments)+1;
        handles.ActiveMarkerNum = [];
    else
        handles.ActiveSegmentNum = [];
    end
function handles = DeactivateActiveAnnotation(handles, annotationType)
    switch annotationType
        case 'segment'
            handles.ActiveSegmentNum = [];
        case 'marker'
                handles.ActiveMarkerNum = [];
        otherwise
    end
function [handles, oldAnnotationNum, newAnnotationNum] = IncrementActiveAnnotation(handles, delta, annotationType)
    % Get currently active annotation number and type
    [oldAnnotationNum, oldAnnotationType] = FindActiveAnnotation(handles);

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        annotationType = oldAnnotationType;
    end

    % Determine new annotation number
    newAnnotationNum = oldAnnotationNum + delta;

    % Set new annotation number
    handles = SetActiveAnnotation(handles, newAnnotationNum, annotationType);
function [handles, newAnnotationNum, newAnnotationType] = ConvertAnnotationType(handles, filenum, annotationNum, annotationType)
    if ~exist('annotationNum', 'var') || isempty(annotationNum)
        % No annotation number provided - use the currently active one
        annotationNum = FindActiveAnnotation(handles);
    end

    if ~exist('annotationType', 'var') || isempty(annotationType)
        % No annotation type provided - use the currently active type
        [~, annotationType] = FindActiveAnnotation(handles);
    end
    switch annotationType
        case 'segment'
            [handles, newAnnotationNum] = ConvertSegmentToMarker(handles, filenum, annotationNum);
            newAnnotationType = 'marker';
        case 'marker'
            [handles, newAnnotationNum] = ConvertMarkerToSegment(handles, filenum, annotationNum);
            newAnnotationType = 'segment';
        otherwise
    end
function [handles, newSegmentNum] = ConvertMarkerToSegment(handles, filenum, markerNum)
    activeMarkerNum = FindActiveMarker(handles);
    t0 = handles.MarkerTimes{filenum}(markerNum, 1);
    t1 = handles.MarkerTimes{filenum}(markerNum, 2);
    MS = handles.MarkerSelection{filenum}(markerNum);
    MN = handles.MarkerTitles{filenum}(markerNum);
    STs = handles.SegmentTimes{filenum};
    SSs = handles.SegmentSelection{filenum};
    SNs = handles.SegmentTitles{filenum};
    
    if isempty(STs)
        % No existing segments
        ind = 1;
    else
        % Insert marker into appropriate place in segment arrays
        ind = getSortedArrayInsertion(STs(:, 1), t0);
    end
    handles.SegmentTimes{filenum} = [STs(1:ind-1, :); [t0, t1]; STs(ind:end, :)];
    handles.SegmentSelection{filenum} = [SSs(1:ind-1), MS, SSs(ind:end)];
    handles.SegmentTitles{filenum} = [SNs(1:ind-1), MN, SNs(ind:end)];
    
    newSegmentNum = ind;
    
    handles = DeleteMarker(handles, filenum, markerNum);

    if markerNum < activeMarkerNum
        % We converted a marker before the active marker to a segment.
        % Adjust the active marker num to compensate for index shift
        handles = SetActiveAnnotation(handles, activeMarkerNum-1, 'marker');
    elseif markerNum == activeMarkerNum
        % We just converted the active segment to a marker - deactiveate
        % active segment and activate new marker
        handles = SetActiveAnnotation(handles, newSegmentNum, 'segment');
    end
function [handles, newMarkerNum] = ConvertSegmentToMarker(handles, filenum, segmentNum)
    activeSegmentNum = FindActiveSegment(handles);
    t0 = handles.SegmentTimes{filenum}(segmentNum, 1);
    t1 = handles.SegmentTimes{filenum}(segmentNum, 2);
    SS = handles.SegmentSelection{filenum}(segmentNum);
    SN = handles.SegmentTitles{filenum}(segmentNum);
    MTs = handles.MarkerTimes{filenum};
    MSs = handles.MarkerSelection{filenum};
    MNs = handles.MarkerTitles{filenum};
    
    if isempty(MTs)
        % No existing markers
        ind = 1;
    else
        % Insert segment into appropriate place in marker arrays
        ind = getSortedArrayInsertion(MTs(:, 1), t0);
    end
    handles.MarkerTimes{filenum} = [MTs(1:ind-1, :); [t0, t1]; MTs(ind:end, :)];
    handles.MarkerSelection{filenum} = [MSs(1:ind-1), SS, MSs(ind:end)];
    handles.MarkerTitles{filenum} = [MNs(1:ind-1), SN, MNs(ind:end)];
    
    newMarkerNum = ind;
    
    handles = DeleteSegment(handles, filenum, segmentNum);
    
    if segmentNum < activeSegmentNum
        % We converted a segment before the active segment to a marker.
        % Adjust the active segment num to compensate for index shift
        handles = SetActiveAnnotation(handles, 'segment', activeSegmentNum-1);
    elseif segmentNum == activeSegmentNum
        % We just converted the active segment to a marker - deactiveate
        % active segment and activate new marker
        handles = SetActiveAnnotation(handles, newMarkerNum, 'marker');
    end

function ind = getSortedArrayInsertion(sortedArr, value)
    [~, ind] = min(abs(sortedArr-value));
    ind = ind + (value > sortedArr(ind));
    
% --- Executes on button press in push_Calculate.
function push_Calculate_Callback(hObject, ~, handles)
    % hObject    handle to push_Calculate (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    handles = eg_PlotSonogram(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ColorScale_Callback(hObject, ~, handles)
    % hObject    handle to menu_ColorScale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.ispower == 1
        answer = inputdlg({'Offset','Brightness'},'Color scale',1,{num2str(handles.SonogramClim(1)),num2str(handles.SonogramClim(2))});
        if isempty(answer)
            return
        end
        handles.SonogramClim = [str2double(answer{1}) str2double(answer{2})];
    else
        answer = inputdlg({'Offset','Brightness'},'Color scale',1,{num2str(handles.DerivativeOffset),num2str(handles.DerivativeSlope)});
        if isempty(answer)
            return
        end
        handles.DerivativeOffset = str2double(answer{1});
        handles.NewSlope = str2double(answer{2});
    end
    
    handles = SetSonogramColors(handles);
    
    guidata(hObject, handles);
    
function handles = SetSonogramColors(handles)
    
    if handles.ispower == 1
        colormap(handles.axes_Sonogram, handles.Colormap);
        handles.axes_Sonogram.CLim = handles.SonogramClim;
    else
        ch = findobj('Parent', handles.axes_Sonogram, 'Type', 'image');
        for c = 1:length(ch)
            ch(c).CData = atan(tan(ch(c).CData)/10^handles.DerivativeSlope*10^handles.NewSlope);
        end
        handles.DerivativeSlope = handles.NewSlope;
        cl = repmat(linspace(0,1,201)',1,3);
        indx = round(101-handles.DerivativeOffset*100):round(101+handles.DerivativeOffset*100);
        indx = indx(indx>0 & indx<202);
        cl(indx,:) = repmat(handles.BackgroundColors(2,:),length(indx),1);
        colormap(handles.axes_Sonogram, cl);
        handles.axes_Sonogram.CLim = [-pi/2 pi/2];
    end
    
% --------------------------------------------------------------------
function menu_FreqLimits_Callback(hObject, ~, handles)
    % hObject    handle to menu_FreqLimits (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Minimum (Hz)','Maximum (Hz)'},'Frequency limits',1,{num2str(handles.FreqLim(1)),num2str(handles.FreqLim(2))});
    if isempty(answer)
        return
    end
    handles.FreqLim = [str2double(answer{1}) str2double(answer{2})];
    handles.CustomFreqLim = handles.FreqLim;
    
    handles = eg_PlotSonogram(handles);
    
    guidata(hObject, handles);
    
% --- Executes on button press in push_New.
function push_New_Callback(hObject, ~, handles)
    % hObject    handle to push_New (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_NewDbase(handles);
    
    guidata(hObject, handles);

function handles = eg_NewDbase(handles)
    handles.IsUpdating = 0;
    [handles, ischanged] = eg_NewExperiment(handles);
    if ischanged == 0
        return
    end
    
    handles.DefaultFile = 'analysis.mat';
    
    % Placeholder for custom fields
    handles.OriginalDbase = struct();
    
    if strcmp(handles.WorksheetTitle,'Untitled')
        f = strfind(handles.DefaultRootPath,'\');
        handles.WorksheetTitle = handles.DefaultRootPath(f(end)+1:end);
    end
    
    handles.TotalFileNumber = length(handles.sound_files);
    if handles.TotalFileNumber == 0
        return
    end
    
    handles = loadProperties(handles);
    
    handles.ShuffleOrder = randperm(handles.TotalFileNumber);
    
    handles.text_TotalFileNumber.String = ['of ' num2str(handles.TotalFileNumber)];
    handles.edit_FileNumber.String = '1';
    
    handles.list_Files.Value = 1;
    handles.popup_Channel1.Value = 1;
    handles.popup_Channel2.Value = 1;
    handles.popup_Function1.Value = 1;
    handles.popup_Function2.Value = 1;
    handles.popup_EventDetector1.Value = 1;
    handles.popup_EventDetector2.Value = 1;
    handles.popup_EventListAlign.Value = 1;
    
    fileEntries = {};
    for fileNum = 1:length(handles.sound_files)
        fileEntries{fileNum} = makeFileEntry(handles, handles.sound_files(fileNum).name, true);
    end
    handles.list_Files.String = fileEntries;
    
    sourceStrings = {'(None)','Sound'};
    for chanNum = 1:length(handles.chan_files)
        if ~isempty(handles.chan_files{chanNum})
            sourceStrings{end+1} = ['Channel ' num2str(chanNum)];
        end
    end
    handles.popup_Channel1.String = sourceStrings;
    handles.popup_Channel2.String = sourceStrings;
    
    handles = eg_PopulateSoundSources(handles);
    
    handles = SetEventViewerEventListElement(handles, 1, '(None)', [], []);
    
    handles = InitializeVariables(handles);
    
    handles.menu_Events1.Enable  = 'off';
    handles.menu_Events2.Enable  = 'off';
    handles.popup_Function1.Enable  = 'off';
    handles.popup_Function2.Enable  = 'off';
    handles.popup_EventDetector1.Enable  = 'off';
    handles.popup_EventDetector2.Enable  = 'off';
    handles.push_Detect1.Enable  = 'off';
    handles.push_Detect2.Enable  = 'off';
    
    handles.push_DisplayEvents.Enable = 'off';
    handles.axes_Events.Visible = 'off';
    
    % get segmenter parameters
    for c = 1:length(handles.menu_Segmenter)
        if handles.menu_Segmenter(c).Checked
            h = handles.menu_Segmenter(c);
            alg = handles.menu_Segmenter(c).Label;
        end
    end
    if isempty(h.UserData)
        handles.SegmenterParams = eg_runPlugin(handles.plugins.segmenters, alg, 'params');
        h.UserData = handles.SegmenterParams;
    else
        handles.SegmenterParams = h.UserData;
    end
    
    % get sonogram parameters
    for c = 1:length(handles.menu_Algorithm)
        if handles.menu_Algorithm(c).Checked
            h = handles.menu_Algorithm(c);
            alg = handles.menu_Algorithm(c).Label;
        end
    end
    if isempty(h.UserData)
        handles.SonogramParams = eg_runPlugin(handles.plugins.spectrums, alg, 'params');
        h.UserData = handles.SonogramParams;
    else
        handles.SonogramParams = h.UserData;
    end
    
    % get filter parameters
    for c = 1:length(handles.menu_Filter)
        if handles.menu_Filter(c).Checked
            h = handles.menu_Filter(c);
            alg = handles.menu_Filter(c).Label;
        end
    end
    if isempty(h.UserData)
        handles.FilterParams = eg_runPlugin(handles.plugins.filters, alg, 'params');
        h.UserData = handles.FilterParams;
    else
        handles.FilterParams = h.UserData;
    end
    
    % get event parameters
    for axnum = 1:2
        v = handles.popup_EventDetectors(axnum).Value;
        ud = handles.popup_EventDetectors(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = handles.popup_EventDetectors(axnum).String;
            dtr = str{v};
            [handles.ChannelAxesEventParameters{axnum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, 'params');
            ud{v} = handles.ChannelAxesEventParameters{axnum};
            handles.popup_EventDetectors(axnum).UserData = ud;
        else
            handles.ChannelAxesEventParameters{axnum} = ud{v};
        end
    end
    
    % get function parameters
    for axnum = 1:2
        v = handles.popup_Functions(axnum).Value;
        ud = handles.popup_Functions(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = handles.popup_Functions(axnum).String;
            dtr = str{v};
            [handles.FunctionParams{axnum}, ~] = eg_runPlugin(handles.plugins.filters, dtr, 'params');
            ud{v} = handles.FunctionParams{axnum};
            handles.popup_Functions(axnum).UserData = ud;
        else
            handles.FunctionParams{axnum} = ud{v};
        end
    end
    
    handles = eg_RestartProperties(handles);
    
    handles = eg_LoadFile(handles);
    
function handles = loadProperties(handles)
    % Load properties from files, add to default properties.
    
    defaultProps = [];
    if isfield(handles, 'DefaultProperties')
        % DefaultProperties was loaded from defaults_* file
        defaultProps = handles.DefaultProperties;
        % Check to make sure we have the same # of names, values, and types
        n = length(defaultProps.Names);
        v = length(defaultProps.Values);
        t = length(defaultProps.Types);
        if n~=v || v~= t
            errordlg('Loaded default properties have different #s of names, types, and values. Please fix your defaults file so handles.DefaultProperties has the same length vectors for Names, Values, and Types.', 'Error loading default properties');
            defaultProps = [];
        end
    end
    
    if isempty(defaultProps)
        % DefaultProperties was not loaded, or was invalid
        defaultProps.Names = {};
        defaultProps.Values = {};
        defaultProps.Types = {};
    end
    handles.Properties.Names = cell(1,handles.TotalFileNumber);
    handles.Properties.Values = cell(1,handles.TotalFileNumber);
    handles.Properties.Types = cell(1,handles.TotalFileNumber);
    for c = 1:handles.TotalFileNumber
        [~, ~, ~, ~, props] = eg_runPlugin(handles.plugins.loaders, ...
            handles.sound_loader, fullfile(handles.DefaultRootPath, ...
            handles.sound_files(c).name), 0);
        handles.Properties.Names{c} = [props.Names, defaultProps.Names];
        handles.Properties.Values{c} = [props.Values, defaultProps.Values];
        handles.Properties.Types{c} = [props.Types, defaultProps.Types];
    end
    
function handles = InitializeVariables(handles)
    
    %%%% Initialize variables
    handles.SoundThresholds = inf(1,handles.TotalFileNumber);
    handles.CurrentTheshold = inf;
    handles.DatesAndTimes = zeros(1,handles.TotalFileNumber);
    
    handles.SegmentTimes = cell(1,handles.TotalFileNumber);
    handles.SegmentTitles = cell(1,handles.TotalFileNumber);
    handles.SegmentSelection = cell(1,handles.TotalFileNumber);
    handles.MarkerTimes = cell(1,handles.TotalFileNumber);
    handles.MarkerTitles = cell(1,handles.TotalFileNumber);
    handles.MarkerSelection = cell(1,handles.TotalFileNumber);
    
    handles.EventThresholds = zeros(0,handles.TotalFileNumber);
    handles.EventCurrentThresholds = [];
    
    handles.EventWhichPlot = 0;

    handles.FileLength = zeros(1,handles.TotalFileNumber);
    
% --- Executes on button press in push_Open.
function push_Open_Callback(hObject, ~, handles)
    % hObject    handle to push_Open (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_OpenDbase(handles);
    
    guidata(hObject, handles);

% function handles = fillData(handles)
%     % Ensure all relevant fields are appropriately-sized
% 
%     % Check that event times are fully filled in
%     for eventSourceIdx = 1:length(handles.EventTimes)
%         fileCount = size(handles.EventTimes{eventSourceIdx}, 2);
%         if fileCount ~= handles.TotalFileNumber
%             handles.EventTimes{eventSourceIdx}(:, fileCount+1:handles.TotalFileNumber) = deal({[]});
%             handles.EventSelected{eventSourceIdx}(:, fileCount+1:handles.TotalFileNumber) = deal({[]});
%         end
%     end

function handles = eg_OpenDbase(handles)
    % Prompt user to select dbase .mat file
    [file, path] = uigetfile(fullfile(handles.tempSettings.lastDirectory, '*.mat'), 'Load analysis');
    if ~ischar(file)
        % User cancelled load
        return
    end
    
    % Load dbase into 'dbase' variable
    load(fullfile(path, file),'dbase');
    
    handles.DefaultRootPath = dbase.PathName;
    if ~isfolder(dbase.PathName)
        % Root path in dbase is not found on this system. Prompt user to
        % find the files in a different directory
        newDbasePathName = uigetdir(handles.tempSettings.lastDirectory, ...
            sprintf('Directory ''%s'' not found. Find the new location.', dbase.PathName));
        if ~ischar(path)
            % User cancelled
            return
        end
        handles.DefaultRootPath = newDbasePathName;
    end
    

    % Save the selected directory in temporary settings for next time
    handles.tempSettings.lastDirectory = path;
    updateTempFile(handles);

    handles.DefaultFile = fullfile(path, file);
    
    % Store original dbase in case it has custom fields, so we can restore them
    %   when we save the dbase
    handles.OriginalDbase = dbase;
    
    handles.DatesAndTimes = dbase.Times;
    handles.FileLength = dbase.FileLength;
    handles.sound_files = dbase.SoundFiles;
    handles.chan_files = dbase.ChannelFiles;
    handles.sound_loader = dbase.SoundLoader;
    handles.chan_loader = dbase.ChannelLoader;
    
    handles.SoundThresholds = dbase.SegmentThresholds;
    handles.SegmentTimes = dbase.SegmentTimes;
    handles.SegmentTitles = dbase.SegmentTitles;
    handles.SegmentSelection = dbase.SegmentIsSelected;
    
    handles.EventSources = dbase.EventSources;
    handles.EventFunctions = dbase.EventFunctions;
    handles.EventDetectors = dbase.EventDetectors;
    handles.EventThresholds = dbase.EventThresholds;
    handles.EventTimes = dbase.EventTimes;
    handles.EventSelected = dbase.EventIsSelected;
    % Ensure EventSelected field is all logical not double
    for axnum = 1:length(handles.EventSelected)
        for filenum = 1:length(handles.EventSelected{axnum})
            handles.EventSelected{axnum}{filenum} = logical(handles.EventSelected{axnum}{filenum});
        end
    end

    if isfield(dbase, 'EventChannels')
        handles.EventChannels = dbase.EventChannels;
    else
        % Legacy dbases do not have a list of channel numbers, only channel
        % names (stored in "EventSources" field)
        handles.EventChannels = cellfun(@channelNameToNum, handles.EventSources, 'UniformOutput', true);
    end
    if isfield(dbase, 'EventParameters')
        handles.EventParameters = dbase.EventParameters;
    else
        % Legacy dbases do not have a list of event parameters
        handles.EventParameters = cell(1, 1:length(handles.EventTimes));
        for eventSourceIdx = 1:length(handles.EventTimes)
            eventDetectorName = handles.EventDetectors{eventSourceIdx};
            eventParameters = eg_runPlugin(handles.plugins.eventDetectors, eventDetectorName, 'params');
            handles.EventParameters{eventSourceIdx} = eventParameters;
        end
    end
    if isfield(dbase, 'EventXLims')
        handles.EventXLims = dbase.EventXLims;
    else
        % Legacy dbases had event xlims stored in analysis state, and I
        % think it was per channel axes, not per file, so not complete.
        for eventSourceIdx = 1:length(handles.EventTimes)
            handles.EventXLims(eventSourceIdx, :) = handles.EventLims;
        end
    end
    if isfield(dbase, 'EventParts')
        handles.EventParts = dbase.EventParts;
    else
        % Legacy dbases did not have a list of event part names
        handles.EventParts = {};
        for eventSourceIdx = 1:length(handles.EventTimes)
            eventDetectorName = handles.EventDetectors{eventSourceIdx};
            [~, eventParts] = eg_runPlugin(handles.plugins.eventDetectors, eventDetectorName, 'params');
            handles.EventParts{eventSourceIdx} = eventParts;
        end
    end
    
    
    handles.Properties = dbase.Properties;
    
    handles.popup_Channel1.Value = 1;
    handles.popup_Channel2.Value = 1;
    handles.popup_EventListAlign.Value = 1;
    handles.axes_Events.Visible = 'off';
    
    if strcmp(handles.WorksheetTitle,'Untitled')
        f = strfind(handles.DefaultRootPath,'\');
        handles.WorksheetTitle = handles.DefaultRootPath(f(end)+1:end);
    end
    
    handles.TotalFileNumber = length(handles.sound_files);
    
    if isfield(dbase, 'MarkerTimes')
        handles.MarkerTimes = dbase.MarkerTimes;
    else
        % This must be an older type of dbase - add blank marker field
        handles.MarkerTimes = cell(1,handles.TotalFileNumber);
    end
    if isfield(dbase, 'MarkerTitles')
        handles.MarkerTitles = dbase.MarkerTitles;
    else
        % This must be an older type of dbase - add blank marker field
        handles.MarkerTitles = cell(1,handles.TotalFileNumber);
    end
    if isfield(dbase, 'MarkerIsSelected')
        handles.MarkerSelection = dbase.MarkerIsSelected;
    else
        % This must be an older type of dbase - add blank marker field
        handles.MarkerSelection = cell(1,handles.TotalFileNumber);
    end
    
    handles.ShuffleOrder = randperm(handles.TotalFileNumber);
    
    handles.text_TotalFileNumber.String = ['of ' num2str(handles.TotalFileNumber)];
    handles.popup_Function1.Value = 1;
    handles.popup_Function2.Value = 1;
    handles.popup_EventDetector1.Value = 1;
    handles.popup_EventDetector2.Value = 1;
    
    handles.edit_FileNumber.String = '1';
    handles.list_Files.Value = 1;
    str = {};
    for c = 1:length(handles.sound_files)
        str{c} = makeFileEntry(handles, handles.sound_files(c).name, handles.FileLength(c) <= 0);
    end
    handles.list_Files.String = str;
    
    if isfield(dbase,'AnalysisState')
        handles.EventCurrentThresholds = inf*ones(1,length(dbase.AnalysisState.EventList)-1);
        handles.popup_Channel1.String = dbase.AnalysisState.SourceList;
        handles.popup_Channel2.String = dbase.AnalysisState.SourceList;
%         handles.popup_EventListAlign.String = dbase.AnalysisState.EventList;
        handles.edit_FileNumber.String = num2str(dbase.AnalysisState.CurrentFile);
        handles.list_Files.Value = dbase.AnalysisState.CurrentFile;
        handles.EventWhichPlot = dbase.AnalysisState.EventWhichPlot;
        handles.EventXLims = dbase.AnalysisState.EventLims;
    else
        handles = UpdateChannelLists(handles);
        handles = UpdateEventSourcelist(handles);
        handles.EventXLims = [];
    end
    
    % get segmenter parameters
    for c = 1:length(handles.menu_Segmenter)
        if handles.menu_Segmenter(c).Checked
            h = handles.menu_Segmenter(c);
            alg = handles.menu_Segmenter(c).Label;
        end
    end
    if isempty(h.UserData)
        handles.SegmenterParams = eg_runPlugin(handles.plugins.segmenters, alg, 'params');
        h.UserData = handles.SegmenterParams;
    else
        handles.SegmenterParams = h.UserData;
    end
    
    % get sonogram parameters
    for c = 1:length(handles.menu_Algorithm)
        if handles.menu_Algorithm(c).Checked
            h = handles.menu_Algorithm(c);
            alg = handles.menu_Algorithm(c).Label;
        end
    end
    if isempty(h.UserData)
        handles.SonogramParams = eg_runPlugin(handles.plugins.spectrums, alg, 'params');
        h.UserData = handles.SonogramParams;
    else
        handles.SonogramParams = h.UserData;
    end
    
    % get event parameters
    for axnum = 1:2
        v = handles.popup_EventDetectors(axnum).Value;
        ud = handles.popup_EventDetectors(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = handles.popup_EventDetectors(axnum).String;
            dtr = str{v};
            [handles.ChannelAxesEventParameters{axnum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, 'params');
            ud{v} = handles.ChannelAxesEventParameters{axnum};
            handles.popup_EventDetectors(axnum).UserData = ud;
        else
            handles.ChannelAxesEventParameters{axnum} = ud{v};
        end
    end
    
    % get function parameters
    for axnum = 1:2
        v = handles.popup_Functions(axnum).Value;
        ud = handles.popup_Functions(axnum).UserData;
        if isempty(ud{v}) && v>1
            str = handles.popup_Functions(axnum).String;
            dtr = str{v};
            [handles.FunctionParams{axnum}, ~] = eg_runPlugin(handles.plugins.filters, dtr, 'params');
            ud{v} = handles.FunctionParams{axnum};
            handles.popup_Functions(axnum).UserData = ud;
        else
            handles.FunctionParams{axnum} = ud{v};
        end
    end
    
%     handles = fillData(handles);

    handles = eg_PopulateSoundSources(handles);
    
    handles = eg_RestartProperties(handles);
    
    handles = eg_LoadFile(handles);

% --- Executes on button press in push_Save.
function push_Save_Callback(hObject, ~, handles)
    % hObject    handle to push_Save (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_SaveDbase(handles);
    
    guidata(hObject, handles);

function handles = eg_SaveDbase(handles)
    if ~isfield(handles, 'DefaultFile')
        msgbox('Please create a new experiment or open an existing one before saving.');
        return;
    end
    
    [file, path] = uiputfile(handles.DefaultFile,'Save analysis');
    if ~ischar(file)
        return
    end
    
    dbase = GetDBase(handles);
    
    save([path file],'dbase');
    handles.DefaultFile = [path file];

% --- Executes on button press in push_Cancel.
function push_Cancel_Callback(hObject, ~, handles)
    % hObject    handle to push_Cancel (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        
% --------------------------------------------------------------------
function context_Amplitude_Callback(hObject, ~, handles)
    % hObject    handle to context_Amplitude (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_AutoThreshold_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_AutoThreshold.Checked
        handles.menu_AutoThreshold.Checked = 'on';
        handles.CurrentThreshold = eg_AutoThreshold(handles.amplitude);
        handles.SoundThresholds(getCurrentFileNum(handles)) = handles.CurrentThreshold;
        handles = SetSegmentThreshold(handles);
    else
        handles.menu_AutoThreshold.Checked = 'off';
    end
    
    guidata(hObject, handles);
    
function threshold = eg_AutoThreshold(amp)
    
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
    
    % by Aaron Andalman
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
    
    
% --------------------------------------------------------------------
function menu_AmplitudeAxisRange_Callback(hObject, ~, handles)
    % hObject    handle to menu_AmplitudeAxisRange (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Minimum','Maximum'},'Axis range',1,{num2str(handles.AmplitudeLims(1)) num2str(handles.AmplitudeLims(2))});
    if isempty(answer)
        return
    end
    
    handles.AmplitudeLims(1) = str2double(answer{1});
    handles.AmplitudeLims(2) = str2double(answer{2});
    handles.axes_Amplitude.YLim = handles.AmplitudeLims;
    
    guidata(hObject, handles);
    
    
    
% --------------------------------------------------------------------
function menu_SmoothingWindow_Callback(hObject, ~, handles)
    % hObject    handle to menu_SmoothingWindow (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Smoothing window (ms)'},'Smoothing window',1,{num2str(handles.SmoothWindow*1000)});
    if isempty(answer)
        return
    end
    handles.SmoothWindow = str2double(answer{1})/1000;
    
    handles = updateAmplitude(handles);
    
    guidata(hObject, handles);
    
    
function click_Amplitude(hObject, event)
    handles = guidata(hObject);
    
    if strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
        handles.TLim = [0, numSamples/handles.fs];
        handles = eg_EditTimescale(handles);
    
    elseif strcmp(handles.figure_Main.SelectionType,'normal')
        handles.axes_Amplitude.Units = 'pixels';
        handles.axes_Amplitude.Parent.Units = 'pixels';
        rect = rbbox;
    
        pos = handles.axes_Amplitude.Position;
        handles.axes_Amplitude.Units = 'normalized';
        handles.axes_Amplitude.Parent.Units = 'normalized';
        xl = xlim(handles.axes_Amplitude);
    
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    
        if rect(3) == 0
            shift = rect(1) - handles.TLim(1);
            handles.TLim = handles.TLim + shift;
        else
            handles.TLim = [rect(1), rect(1)+rect(3)];
        end
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        pos = handles.axes_Amplitude.CurrentPoint;
        handles.CurrentThreshold = pos(1,2);
        handles.SoundThresholds(getCurrentFileNum(handles)) = handles.CurrentThreshold;
        handles = SetSegmentThreshold(handles);
    end
    
    guidata(hObject, handles);
    
    
    
% --------------------------------------------------------------------
function menu_SetThreshold_Callback(hObject, ~, handles)
    % hObject    handle to menu_SetThreshold (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Threshold'},'Set threshold',1,{num2str(handles.CurrentThreshold)});
    if isempty(answer)
        return
    end
    handles.CurrentThreshold = str2double(answer{1});
    handles.SoundThresholds(getCurrentFileNum(handles)) = handles.CurrentThreshold;
    
    handles = SetSegmentThreshold(handles);
    
    guidata(hObject, handles);
    
    
function click_loadfile(hObject, ~, handles)
    
    temp = handles.TooLong;
    handles.TooLong = inf;
    cla(handles.axes_Sonogram);
    drawnow;
    handles = eg_LoadFile(handles);
    handles.TooLong = temp;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_LongFiles_Callback(hObject, ~, handles)
    % hObject    handle to menu_LongFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Number of points defining a long file'},'Long files',1,{num2str(handles.TooLong)});
    if isempty(answer)
        return
    end
    handles.TooLong = str2double(answer{1});
    
    guidata(hObject, handles);

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
            inside = true;
            return;
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

function scrollHandler(source, event)
    handles = guidata(source);
    xy = event.Source.CurrentPoint;
    x = xy(1);
    y = xy(2);
    if areCoordinatesIn(x, y, [handles.axes_Sonogram, handles.axes_Sound, handles.axes_Amplitude, handles.axes_Channel])
        [t, ~] = convertFigCoordsToChildAxesCoords(x, y, handles.axes_Sonogram);
        handles = zoomSonogram(handles, t, event.VerticalScrollCount);
    elseif areCoordinatesIn(x, y, handles.axes_Events)
        eventSourceIdx = GetEventViewerEventSourceIdx(handles);
        eventPartNum = GetEventViewerEventPartIdx(handles);
        numEvents = GetNumEvents(handles, eventSourceIdx, eventPartNum);
        newActiveEventNum = mod(handles.ActiveEventNum + event.VerticalScrollCount - 1, numEvents) + 1;
        handles = SetActiveEventDisplay(handles, newActiveEventNum);
    end
    guidata(source, handles);
    
function handles = zoomSonogram(handles, tCenter, zoomLevels)
    zoomFactor = 2^(zoomLevels/3);
    currentTWidth = diff(handles.TLim);
    tFraction = (tCenter - handles.TLim(1))/currentTWidth;
    newTWidth = currentTWidth*zoomFactor;
    handles.TLim = [tCenter - tFraction * newTWidth, tCenter + (1-tFraction) * newTWidth];
    handles = eg_EditTimescale(handles);

function exportView(handles)
    f_export = figure();

    % Determine how many channels are visible
    numChannels = 0;
    for c = 1:length(handles.axes_Channel)
        if handles.axes_Channel(c).Visible
            numChannels = numChannels + 1;
        end
    end

    % Copy sonogram
    sonogram_export = subplot(numChannels+1, 1, 1, 'Parent', f_export);
    sonogram_children = handles.axes_Sonogram.Children;
    for k = 1:length(sonogram_children)
        copyobj(sonogram_children(k), sonogram_export);
    end
    % Match axes limits
    xlim(sonogram_export, xlim(handles.axes_Sonogram));
    ylim(sonogram_export, ylim(handles.axes_Sonogram));
    sonogram_export.CLim = handles.axes_Sonogram.CLim;
    colormap(sonogram_export, handles.Colormap);

    % Set figure size to match contents
    sonogram_export.Units = handles.axes_Sonogram.Units;
%     curr_pos = sonogram_export.Position;
    son_pos = handles.axes_Sonogram.Position;
    aspect_ratio = 1.2*(1+numChannels)*son_pos(4) / son_pos(3);
    f_pos = f_export.Position;
    f_pos(4) = f_pos(3) * aspect_ratio;
    f_export.Position = f_pos;

    % Add title to sonogram (file name)
    currentFileName = getCurrentFileName(handles);
    title(sonogram_export, currentFileName, 'Interpreter', 'none');

    % Loop over any channels that are currently visible, and copy them
    chan = 0;
    for c = 1:length(handles.axes_Channel)
        if handles.axes_Channel(c).Visible
            chan = chan + 1;
            channel_export = subplot(numChannels+1, 1, 1+chan, 'Parent', f_export);
            channel_children = handles.axes_Channel(c).Children;
            for k = 1:length(channel_children)
                copyobj(channel_children(k), channel_export);
            end

%            [~, selectedChannelName, ~] = getSelectedChannel(handles, c);
%             title(channel_export, selectedChannelName, 'Interpreter', 'none');
        end
    end

function MouseMotionHandler(hObject, event)
    % Callback to handle mouse motion

    handles = guidata(hObject);
    if handles.ShiftDown
        % User is holding the shift key down

        % Get coordinates of mouse
        xy = handles.figure_Main.CurrentPoint;

        % Define list of axes that will have cursors
        cursor_axes = [handles.axes_Amplitude, handles.axes_Sonogram, handles.axes_Channel];

        % Check if mouse is inside one of the relevant display axes
        inside = areCoordinatesIn(xy(1), xy(2), cursor_axes);
        
        if inside
            % xlim will be the same for all the axes
            ax1 = cursor_axes(1);
            xl = xlim(ax1);
            x = (xy(1) - ax1.Position(1)) / ax1.Position(3);

            % Loop over cursor axes updating cursor
            for k = 1:length(cursor_axes)
                if k > length(handles.Cursors)
                    % We're adding a new cursor
                    handles.Cursors(k) = gobjects();
                end

                ax = cursor_axes(k);
                if ~isgraphics(handles.Cursors(k)) || ~isvalid(handles.Cursors(k))
                    % Cursor is not valid, create a new one
                    delete(handles.Cursors(k));
                    if ax.Visible
                        yl = ylim(ax);
                        t = x*diff(xl)+xl(1);
                        handles.Cursors(k) = line([t, t], yl, 'Parent', ax, 'Color', 'green');
                    end
                else
                    % Cursor is valid, update its values
                    if ax ~= handles.Cursors(k).Parent
                        % This cursor belongs to some other axes, fix it
                        handles.Cursors(k).Parent = ax;
                    end
                    if ax.Visible
                        yl = ylim(ax);
                        t = x*diff(xl)+xl(1);
                        handles.Cursors(k).XData = [t, t];
                        handles.Cursors(k).YData = yl;
                    end
                end
            end
    
            guidata(hObject, handles);
        end
    end

function keyReleaseHandler(hObject, event)
    % Callback to handle a key release

    handles = guidata(hObject);

    if strcmp(event.Key, 'control')
        handles.CtrlDown = false;
    end
    if strcmp(event.Key, 'shift')
        handles.ShiftDown = false;

        % Delete cursor objects, if they exist
        delete(handles.Cursors);
        handles.Cursors = gobjects().empty;
    end

    guidata(hObject, handles);


function keyPressHandler(hObject, event)
    % Callback to handle a key press

    handles = guidata(hObject);

    if strcmp(event.Key, 'control')
        handles.CtrlDown = true;
    end
    if strcmp(event.Key, 'shift')
        handles.ShiftDown = true;
    end

    % Get currently loaded file num
    filenum = getCurrentFileNum(handles);

    if any(strcmp('control', event.Modifier))
        % User pressed a key with 'control' down
        switch event.Key
            case 'e'
                % User pressed "control-e"
                % Press control-e to produce a export of the sonogram and any channel
                % views.
                exportView(handles);
                return
            case 'v'
                % Paste series of characters onto segments/markers
                [handles, annotationNums, annotationType] = PasteAnnotationTitles(handles, [], [], filenum);
                handles = UpdateAnnotationTitleDisplay(handles, annotationNums, annotationType);
                oldAnnotationNum = FindActiveAnnotation(handles);
                handles = SetActiveAnnotation(handles, max(annotationNums)+1, annotationType);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum, annotationType);
            case 'i'
                % Insert a blank annotation at the active spot, and shift
                % other annotations over, stopping when we get to a blank
                % annotation, or the last annotation.
                [annotationNum, annotationType] = FindActiveAnnotation(handles);
                [handles, changedAnnotationNums] = InsertBlankAnnotationTitle(handles, annotationNum, annotationType, filenum);
                handles = UpdateAnnotationTitleDisplay(handles, changedAnnotationNums, annotationType);
            case 'o'
                % User pressed control-o - activate open dbase dialog
                handles = eg_OpenDbase(handles);
            case 'n'
                % User pressed control-n - activate new dbase dialog
                handles = eg_NewDbase(handles);
            case 's'
                % User pressed control-s - activate save dbase dialog
                handles = eg_SaveDbase(handles);
        end
    else
        % User pressed a key without control down
        switch event.Key
            case ','
                % Keypress is a "comma" - load previous file
                filenum = getCurrentFileNum(handles);
                filenum = filenum-1;
                if filenum == 0
                    filenum = handles.TotalFileNumber;
                end
                handles.edit_FileNumber.String = num2str(filenum);
            
                handles = eg_LoadFile(handles);
                guidata(hObject, handles);
                return
            case '.'
                % Keypress is a "period" - load next file
                filenum = getCurrentFileNum(handles);
                filenum = filenum+1;
                if filenum > handles.TotalFileNumber
                    filenum = 1;
                end
                handles.edit_FileNumber.String = num2str(filenum);
            
                handles = eg_LoadFile(handles);
                guidata(hObject, handles);
                return
            case handles.validSegmentCharacters
                % Key was a valid character for naming a segment/marker
                handles = SetAnnotationTitle(handles, event.Key, filenum);
                handles = UpdateAnnotationTitleDisplay(handles);
                [handles, oldAnnotationNum] = IncrementActiveAnnotation(handles, +1);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum);
            case 'backspace'
                handles = SetAnnotationTitle(handles, '', filenum);
                handles = UpdateAnnotationTitleDisplay(handles);
                [handles, oldAnnotationNum] = IncrementActiveAnnotation(handles, +1);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum);
            case 'rightarrow'
                % User pressed right arrow
                [handles, oldAnnotationNum] = IncrementActiveAnnotation(handles, +1);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum);
            case 'leftarrow'
                % User pressed left arrow
                [handles, oldAnnotationNum] = IncrementActiveAnnotation(handles, -1);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum);
            case {'uparrow', 'downarrow'}
                % User pressed up or down arrow
                [oldAnnotationNum, oldAnnotationType] = FindActiveAnnotation(handles);
                [newAnnotationNum, newAnnotationType] = FindClosestAnnotationOfOtherType(handles, filenum);
                handles = SetActiveAnnotation(handles, newAnnotationNum, newAnnotationType);
                handles = UpdateActiveAnnotationDisplay(handles, oldAnnotationNum, oldAnnotationType, newAnnotationNum, newAnnotationType);
            case 'space'
                % User pressed "space" - join this segment with next segment
                [annotationNum, annotationType] = FindActiveAnnotation(handles);
                switch annotationType
                    case 'segment'
                        handles = JoinSegmentWithNext(handles, filenum, annotationNum);
                        handles = PlotAnnotations(handles);
                    case 'marker'
                        % Don't really need to do this with markers
                end
            case 'return'
                % User pressed "enter" key - toggle active segment "selection"
                % Note that "selected" segments/markers is not the same as
                % "active" segments/markers.
                handles = ToggleAnnotationSelect(handles, filenum);
                handles = PlotAnnotations(handles);
            case 'delete'
                % User pressed "delete" - delete active marker
                handles = DeleteAnnotation(handles, filenum);
                handles = PlotAnnotations(handles);
            case 'backquote'
                % User pressed the "`" / "~" button - transform active marker into
                %   segment or vice versa
                handles = ConvertAnnotationType(handles, filenum);
                handles = PlotAnnotations(handles);
        end
    end
    
    guidata(hObject, handles);

function handles = popup_Functions_Callback(handles, axnum)
    v = handles.popup_Functions(axnum).Value;
    ud = handles.popup_Functions(axnum).UserData;
    if isempty(ud{v}) && v>1
        str = handles.popup_Functions(axnum).String;
        dtr = str{v};
        f = strfind(dtr,' - ');
        if isempty(f)
            [handles.FunctionParams{axnum}, ~] = eg_runPlugin(handles.plugins.filters, dtr, 'params');
        else
            [handles.FunctionParams{axnum}, ~] = eg_runPlugin(handles.plugins.filters, dtr(1:f-1), 'params');
        end
        ud{v} = handles.FunctionParams{axnum};
        handles.popup_Functions(axnum).UserData = ud;
    else
        handles.FunctionParams{axnum} = ud{v};
    end
    
    % I think this is checking if theres a "data too long" message on the
    % axes. Probably should remove that check
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        handles.popup_EventDetectors(axnum).Value = 1;
        handles = eg_LoadChannel(handles, axnum);
    end
    str = handles.popup_Channels(axnum).String;
    str = str{handles.popup_Channels(axnum).Value};
    if contains(str,' - ') || strcmp(str,'(None)')
        handles.popup_EventDetectors(axnum).Enable = 'off';
    else
        handles.popup_EventDetectors(axnum).Enable = 'on';
    end
    
    if handles.menu_SourcePlots(axnum).Checked
        handles = updateAmplitude(handles);
    end
    
% --- Executes on selection change in popup_Function1.
function popup_Function1_Callback(hObject, ~, handles)
    % hObject    handle to popup_Function1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_Function1 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_Function1
    axnum = 1;
    
    handles = popup_Functions_Callback(handles, axnum);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_Function1_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_Function1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
% --- Executes on selection change in popup_Function2.
function popup_Function2_Callback(hObject, ~, handles)
    % hObject    handle to popup_Function2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_Function2 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_Function2
    
    axnum = 2;
    
    handles = popup_Functions_Callback(handles, axnum);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_Function2_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_Function2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
function handles = popup_Channels_Callback(handles, axnum)
    % Handle change in value of either channel source menu
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        % ??
        handles.popup_Functions(axnum).Value = 1;
        handles.popup_EventDetectors(axnum).Value = 1;
        handles = eg_LoadChannel(handles, axnum);
    end

    channelNum = getSelectedChannel(handles, axnum);
    if isempty(channelNum)
        handles.popup_EventDetectors(axnum).Enable = 'off';
    else
        handles.popup_EventDetectors(axnum).Enable = 'on';
    end
    
    if handles.menu_SourcePlots(axnum).Checked
        handles = updateAmplitude(handles);
    end
    
    %If available, use the default channel filter (from defaults file)
    if isfield(handles, 'DefaultChannelFunction')
        % handles.DefaultChannelFilter is defined
        allFunctionNames = handles.popup_Functions(axnum).String;
        defaultChannelFunctionIdx = find(strcmp(allFunctionNames, handles.DefaultChannelFunction));
        if ~isempty(defaultChannelFunctionIdx)
            % Default channel function is valid
            currentChannelFunctionIdx = handles.popup_Functions(axnum).Value;
            if currentChannelFunctionIdx ~= defaultChannelFunctionIdx
                % Default channel function does not match currently selected function. Switch it!
                handles.popup_Functions(axnum).Value = defaultChannelFunctionIdx;
                % Trigger callback for changed channel function
                handles = popup_Functions_Callback(handles, axnum);
            end
        else
            warning('Found a default channel function in the defaults file, but it was not a recognized function: %s', handles.DefaultChannelFunction);
        end
    end
    
% --- Executes on selection change in popup_Channel1.
function popup_Channel1_Callback(hObject, ~, handles)
    % hObject    handle to popup_Channel1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_Channel1 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_Channel1
    
    axnum = 1;
    
    handles = popup_Channels_Callback(handles, axnum);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_Channel1_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_Channel1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
% --- Executes on selection change in popup_Channel2.
function popup_Channel2_Callback(hObject, ~, handles)
    % hObject    handle to popup_Channel2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_Channel2 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_Channel2
    
    axnum = 2;
    
    handles = popup_Channels_Callback(handles, axnum);
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_Channel2_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_Channel2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
    
% --------------------------------------------------------------------
function context_Channel1_Callback(hObject, ~, handles)
    % hObject    handle to context_Channel1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_PeakDetect1_Callback(hObject, ~, handles)
    % hObject    handle to menu_PeakDetect1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_PeakDetect1.Checked
        handles.menu_PeakDetect1.Checked = 'off';
    else
        handles.menu_PeakDetect1.Checked = 'on';
    end
    handles = eg_LoadChannel(handles,1);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function context_Channel2_Callback(hObject, ~, handles)
    % hObject    handle to context_Channel2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_PeakDetect2_Callback(hObject, ~, handles)
    % hObject    handle to menu_PeakDetect2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_PeakDetect2.Checked
        handles.menu_PeakDetect2.Checked = 'off';
    else
        handles.menu_PeakDetect2.Checked = 'on';
    end
    handles = eg_LoadChannel(handles,2);
    
    guidata(hObject, handles);
    
    
    
function click_Channel(hObject, event)
    % Handle a click on the channel axes
    handles = guidata(hObject);

    obj = hObject;
    if ~strcmp(obj.Type,'axes')
        obj = obj.Parent;
    end
    if obj==handles.axes_Channel1
        axnum = 1;
    else
        axnum = 2;
    end

    ax = handles.axes_Channel(axnum);
    
    if strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        for axn = 1:2
            if handles.axes_Channel(axn).Visible
                if handles.menu_AutoLimits(axn).Checked
                    yl = [min(handles.loadedChannelData{axn}) max(handles.loadedChannelData{axn})];
                    if yl(1)==yl(2)
                        yl = [yl(1)-1 yl(2)+1];
                    end
                    handles.axes_Channel(axn).YLim = [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1];
                else
                    handles.axes_Channel(axn).YLim = handles.(['ChanLimits' num2str(axn)]);
                end
            end
        end
        handles.TLim = [0, numSamples/handles.fs];
        handles = eg_EditTimescale(handles);
    
    elseif strcmp(handles.figure_Main.SelectionType,'normal')
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
            shift = rect(1) - handles.TLim(1);
            handles.TLim = handles.TLim + shift;
        else
            handles.TLim = [rect(1), rect(1)+rect(3)];
            if handles.menu_AllowYZooms(axnum).Checked && rect(4) > 0
                ylim([rect(2) rect(4)+rect(2)]);
            end
        end
        handles = eg_EditTimescale(handles);
    
    elseif strcmp(handles.figure_Main.SelectionType, 'alt')
        % Control-click

        handles.ActiveEventNum = [];
        handles.ActiveEventPartNum = [];
        handles.ActiveEventSourceIdx = [];

        % Remove active event cursor
        delete(handles.ActiveEventCursors);
    
        ax.Units = 'pixels';
        ax.Parent.Units = 'pixels';
        rect = rbbox();
    
        eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);

        pos = ax.Position;
        ax.Parent.Units = 'normalized';
        ax.Units = 'normalized';
        xl = xlim(ax);
        yl = ylim(ax);
    
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
        rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
        rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

        if rect(3) < 0.01
            % Simple control-click on axes
            handles = SetEventThreshold(handles, axnum, rect(2));
        else
            % Control click and drag on channel axes

            if ~isempty(eventSourceIdx)
                % Set local threshold 
    
                filenum = getCurrentFileNum(handles);
    
                eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    
                [~, ~, eventDetectorName, eventParameters] = GetEventSourceInfo(handles, eventSourceIdx);
    
                % Get channel data
                chanData = handles.loadedChannelData{axnum};
    
                minTime = rect(1);
                maxTime = rect(1)+rect(3);
                minSample = max(1,                round(minTime*handles.fs));
                maxSample = min(length(chanData), round(maxTime*handles.fs));
                minVolt = -Inf;
                maxVolt = Inf;
    
                % Get a mask for events within box
                boxedEventMask = GetBoxedEventMask(handles, axnum, filenum, minTime, maxTime, minVolt, maxVolt);
                % Just combine the mask for all the event parts - we're
                % assuming we'll never want to select one part of an event but
                % not all others.
                boxedEventMask = or(boxedEventMask{:});
                % Delete events within box
                for eventPartNum = 1:size(handles.EventTimes{eventSourceIdx}, 1)
                    handles.EventTimes{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = [];
                    handles.EventSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = [];
                end
    
                % Restrict the data we're detecting events in  to the 
                % specified time limits
                chanData = chanData(minSample:maxSample);
    
                % Get the specified local threshold
                localThreshold = rect(2);
                
                % Run event detector plugin to get a list of detected event times
                [newEventTimes, eventParts] = eg_runPlugin(handles.plugins.eventDetectors, eventDetectorName, chanData, handles.fs, localThreshold, eventParameters);
                newEventSelected = true(1, length(newEventTimes{1}));
                for eventPartNum = 1:length(eventParts)
                    % Adjust event times based on start of time limits
                    newEventTimes{eventPartNum} = newEventTimes{eventPartNum} + (minSample-1);
                    % Store the original event times/selected
                    oldEventTimes = handles.EventTimes{eventSourceIdx}{eventPartNum, filenum};
                    oldEventSelected = handles.EventSelected{eventSourceIdx}{eventPartNum, filenum};
                    % Concatenate new event times/selected
                    eventTimes = vertcat(oldEventTimes, newEventTimes{eventPartNum});
                    eventSelected = [oldEventSelected, newEventSelected];
                    % Sort event times by time
                    [eventTimes, sortIdx] = sort(eventTimes);
                    eventSelected = eventSelected(sortIdx);
                    % Update event times/selected
                    handles.EventTimes{eventSourceIdx}{eventPartNum, filenum} = eventTimes;
                    handles.EventSelected{eventSourceIdx}{eventPartNum, filenum} = eventSelected;
                end
                handles = UpdateChannelEventDisplay(handles, axnum);
                handles = UpdateEventViewer(handles);
            end
        end

    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        % Shift-click

        % Check the event source the clicked channel axes is displaying
        eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);

        if ~isempty(eventSourceIdx)
            % The clicked channel axes is currently showing an event source

            handles.ActiveEventNum = [];
            handles.ActiveEventPartNum = [];
            handles.ActiveEventSourceIdx = [];
    
            % Remove active event cursor
            delete(handles.ActiveEventCursors);
        
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
            filenum = getCurrentFileNum(handles);
            minTime = rect(1);
            maxTime = rect(1)+rect(3);
            minVolt = rect(2);
            maxVolt = rect(2)+rect(4);

            % Get a mask for events within box
            boxedEventMask = GetBoxedEventMask(handles, axnum, filenum, minTime, maxTime, minVolt, maxVolt);
            % Just combine the mask for all the event parts - we're
            % assuming we'll never want to select one part of an event but
            % not all others.
            boxedEventMask = or(boxedEventMask{:});

            % Invert the selected status of any events that fell within box
            for eventPartNum = 1:length(handles.EventHandles{axnum})
                handles.EventSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask) = ~handles.EventSelected{eventSourceIdx}{eventPartNum, filenum}(boxedEventMask);
            end
    
            % Update event display for any axes displaying the same event source
            for axn = 1:2
                if eventSourceIdx == GetChannelAxesEventSourceIdx(handles, axn)
                    handles = UpdateChannelEventDisplay(handles, axn);
                end
            end

            % Update event viewer
            handles = UpdateEventViewer(handles);
        end
    end
    
    guidata(handles.axes_Channel(axnum), handles);
    
function boxedEventMask = GetBoxedEventMask(handles, axnum, filenum, minTime, maxTime, minVolt, maxVolt)

    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        boxedEventMask = logical.empty();
        return;
    end

    boxedEventMask = {};

    % Check all event parts to see if any fall within box
    for eventPartNum = 1:length(handles.EventTimes{eventSourceIdx})
        eventSamples = handles.EventTimes{eventSourceIdx}{eventPartNum, filenum};
        newEventTimes = eventSamples / handles.fs;
        eventVoltages = handles.loadedChannelData{axnum}(eventSamples);
        % Get mask of events that fall within box
        boxedMask = newEventTimes > minTime & newEventTimes < maxTime & eventVoltages > minVolt & eventVoltages < maxVolt;
        % Combine it with masks from previous event parts
        boxedEventMask{eventPartNum} = boxedMask;
    end

function handles = UpdateEventThresholdDisplay(handles, eventSourceIdx)
    for axnum = WhichChannelAxesMatchEventSource(handles, eventSourceIdx)
        if ~handles.axes_Channel(axnum).Visible
            % Channel is not visible, skip update
            continue;
        end
        filenum = getCurrentFileNum(handles);
        % Get threshold
        threshold = handles.EventThresholds(eventSourceIdx, filenum);
        % Get axes limits
        xl = xlim(handles.axes_Channel(axnum));
        yl = ylim(handles.axes_Channel(axnum));
        % Check if we need to create new threshold line, or just modify
        % existing one
        if ~isvalid(handles.EventThresholdHandles(axnum)) || ...
            isa(handles.EventThresholdHandles(axnum), 'matlab.graphics.GraphicsPlaceholder')
            % Create new threshold line
            hold(handles.axes_Channel(axnum), 'on');
            [handles, numSamples] = eg_GetNumSamples(handles);
            handles.EventThresholdHandles(axnum) = ...
                plot(handles.axes_Channel(axnum), ...
                     [0, numSamples/handles.fs], ...
                     [threshold, threshold], ...
                     ':', 'Color', handles.ChannelThresholdColor(axnum,:));
            hold(handles.axes_Channel(axnum), 'off');
        else
            % Update threshold line y data
            handles.EventThresholdHandles(axnum).YData = [threshold, threshold];
        end
        % Reset axes limits to what they were before
        xlim(handles.axes_Channel(axnum), xl);
        ylim(handles.axes_Channel(axnum), yl);
    end
    
function handles = AllowYZoom(handles, axnum)
    if handles.menu_AllowYZooms(axnum).Checked
        handles.menu_AllowYZooms(axnum).Checked = 'off';
        if handles.menu_AutoLimits1.Checked
            yl = [min(handles.loadedChannelData{axnum}), ...
                  max(handles.loadedChannelData{axnum})];
            if yl(1)==yl(2)
                yl = [yl(1)-1 yl(2)+1];
            end
            ylim(handles.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            ylim(handles.axes_Channel(axnum), handles.ChanLimits1);
        end
        handles = eg_Overlay(handles);
    else
        handles.menu_AllowYZooms(axnum).Checked = 'on';
    end
    
% --------------------------------------------------------------------
function menu_AllowYZoom1_Callback(hObject, ~, handles)
    % hObject    handle to menu_AllowYZoom1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 1;
    handles = AllowYZoom(handles, axnum);
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AllowYZoom2_Callback(hObject, ~, handles)
    % hObject    handle to menu_AllowYZoom2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 2;
    handles = AllowYZoom(handles, axnum);
    guidata(hObject, handles);
    

function handles = menu_AutoLimits_Callback(handles, axnum)
    if handles.menu_AutoLimits(axnum).Checked
        handles.menu_AutoLimits(axnum).Checked = 'off';
        handles.ChanLimits(axnum, :) = ylim(handles.axes_Channel(axnum));
    else
        handles.menu_AutoLimits(axnum).Checked = 'on';
        yl = [min(handles.loadedChannelData{axnum}), ...
              max(handles.loadedChannelData{axnum})];
        if yl(1)==yl(2)
            yl = [yl(1)-1 yl(2)+1];
        end
        ylim(handles.axes_Channel(axnum), [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        handles = eg_Overlay(handles);
    end

% --------------------------------------------------------------------
function menu_AutoLimits1_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoLimits1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 1;
    handles = menu_AutoLimits_Callback(handles, axnum);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_AutoLimits2_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoLimits2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 2;
    handles = menu_AutoLimits_Callback(handles, axnum);
    guidata(hObject, handles);


function handles = eg_SetLimits(handles,axnum)
    defaultLimits = handles.axes_Channel(axnum).YLim;
    answer = inputdlg({'Minimum','Maximum'},'Axes limits',1,{num2str(defaultLimits(1)),num2str(defaultLimits(2))});
    if isempty(answer)
        return
    end
    if ~handles.menu_AutoLimits(axnum).Checked
        handles.ChanLimits(axnum, :) = str2double(answer(1:2));
    end
    
    ylim(handles.axes_Channel(axnum), str2double(answer(1:2)));
    
    handles = eg_Overlay(handles);
    
% --------------------------------------------------------------------
function menu_SetLimits1_Callback(hObject, ~, handles)
    % hObject    handle to menu_SetLimits1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 1;
    handles = eg_SetLimits(handles, axnum);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_SetLimits2_Callback(hObject, ~, handles)
    % hObject    handle to menu_SetLimits2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    axnum = 2;
    handles = eg_SetLimits(handles, axnum);
    guidata(hObject, handles);
        
    
% --- Executes on selection change in popup_EventDetector1.
function popup_EventDetector1_Callback(hObject, ~, handles)
    % hObject    handle to popup_EventDetector1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_EventDetector1 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_EventDetector1
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        handles = UpdateChannelEventDisplay(handles, 1);
%        handles = eg_clickEventDetector(handles,1);
    end
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_EventDetector1_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_EventDetector1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end

% --- Executes on selection change in popup_EventDetector2.
function popup_EventDetector2_Callback(hObject, ~, handles)
    % hObject    handle to popup_EventDetector2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_EventDetector2 contents as cell array
    %        contents{hObject.Value} returns selected item from popup_EventDetector2
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        handles = UpdateChannelEventDisplay(handles, 2);
%        handles = eg_clickEventDetector(handles,2);
    end
    
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_EventDetector2_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_EventDetector2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end

% --------------------------------------------------------------------
function menu_Events1_Callback(hObject, ~, handles)
    % hObject    handle to menu_Events1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_EventAutoDetect1_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventAutoDetect1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_EventAutoDetect1.Checked
        handles.menu_EventAutoDetect1.Checked = 'off';
    else
        handles.menu_EventAutoDetect1.Checked = 'on';
        handles = DetectEvents(handles,1);
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventViewer(handles);
        end
    
        val = handles.popup_Channel2.Value;
        str = handles.popup_Channel2.String;
        nums = [];
        for c = 1:length(handles.EventTimes)
            nums(c) = size(handles.EventTimes{c},1);
        end
        if val > length(str)-sum(nums)
            indx = val-(length(str)-sum(nums));
            cs = cumsum(nums);
            f = length(find(cs<indx))+1;
            if f == handles.EventCurrentIndex(1)
                handles = eg_LoadChannel(handles,2);
            end
        end
    end
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_EventAutoThreshold1_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventAutoThreshold1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_UpdateEventThresholdDisplay1_Callback(hObject, ~, handles)
    % hObject    handle to menu_UpdateEventThresholdDisplay1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SetEventThreshold(handles,1);
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Events2_Callback(hObject, ~, handles)
    % hObject    handle to menu_Events2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_EventAutoDetect2_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventAutoDetect2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if handles.menu_EventAutoDetect2.Checked
        handles.menu_EventAutoDetect2.Checked = 'off';
    else
        handles.menu_EventAutoDetect2.Checked = 'on';
        handles = DetectEvents(handles,2);
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventViewer(handles);
        end
    
        val = handles.popup_Channel1.Value;
        str = handles.popup_Channel1.String;
        nums = [];
        for c = 1:length(handles.EventTimes)
            nums(c) = size(handles.EventTimes{c},1);
        end
        if val > length(str)-sum(nums)
            indx = val-(length(str)-sum(nums));
            cs = cumsum(nums);
            f = length(find(cs<indx))+1;
            if f == handles.EventCurrentIndex(2)
                handles = eg_LoadChannel(handles,1);
            end
        end
    
    end
    
    guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_EventAutoThreshold2_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventAutoThreshold2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_UpdateEventThresholdDisplay2_Callback(hObject, ~, handles)
    % hObject    handle to menu_UpdateEventThresholdDisplay2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SetEventThreshold(handles,2);
    
    guidata(hObject, handles);

% --- Executes on button press in push_Detect1.
function push_Detect1_Callback(hObject, ~, handles)
    % hObject    handle to push_Detect1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = DetectEvents(handles,1);
    
    if handles.menu_AutoDisplayEvents.Checked
        handles = UpdateEventViewer(handles);
    end
    
    val = handles.popup_Channel2.Value;
    str = handles.popup_Channel2.String;
    nums = [];
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    if val > length(str)-sum(nums)
        indx = val-(length(str)-sum(nums));
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if f == handles.EventCurrentIndex(1)
            handles = eg_LoadChannel(handles,2);
        end
    end
    
    guidata(hObject, handles);

% --- Executes on button press in push_Detect2.
function push_Detect2_Callback(hObject, ~, handles)
    % hObject    handle to push_Detect2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = DetectEvents(handles,2);
    
    if handles.menu_AutoDisplayEvents.Checked
        handles = UpdateEventViewer(handles);
    end
    
    val = handles.popup_Channel1.Value;
    str = handles.popup_Channel1.String;
    nums = [];
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    if val > length(str)-sum(nums)
        indx = val-(length(str)-sum(nums));
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if f == handles.EventCurrentIndex(2)
            handles = eg_LoadChannel(handles,1);
        end
    end
    
    guidata(hObject, handles);

% --- Executes on selection change in popup_EventListAlign.
function popup_EventListAlign_Callback(hObject, ~, handles)
    % hObject    handle to popup_EventListAlign (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_EventListAlign contents as cell array
    %        contents{hObject.Value} returns selected item from popup_EventListAlign
    
    handles.ActiveEventNum = [];
    handles.ActiveEventPartNum = [];
    handles.ActiveEventSourceIdx = [];

    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);

function handles = SetEventThreshold(handles, axnum, threshold)
    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        [handles, eventSourceIdx] = addNewEventSourceFromChannelAxes(handles, axnum);
    end

    filenum = getCurrentFileNum(handles);

    if ~exist('threshold', 'var') || isempty(threshold)
        % No threshold given, get it from the user
        answer = inputdlg({'Threshold'},'Threshold',1,{num2str(handles.EventThresholds(eventSourceIdx, filenum))});
        if isempty(answer)
            return
        end
        handles.EventThresholds(eventSourceIdx, filenum) = str2double(answer{1});
    end

    % Set the new event threshold
    handles.EventThresholds(eventSourceIdx, filenum) = threshold;

    % Update events for the event source configuration of this
    % channel axes.
    [handles, eventSourceIdx] = DetectEvents(handles, axnum);

    for axn = 1:2
        if GetChannelAxesEventSourceIdx(handles, axn)==eventSourceIdx
            % Axes is visible and is currently showing the same
            % event source
            handles = UpdateChannelEventDisplay(handles, axn);
        end
    end

    handles = UpdateEventViewer(handles);

% function handles = eg_clickEventDetector(handles, axnum)
% 
%     if ~handles.axes_Channel(axnum).Visible
%         return
%     end
% 
%     eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
% 
%     if isempty(eventSourceIdx)
%         % No event source for this channel configuration
%         eventDetector = getSelectedEventDetector(handles, axnum);
%         handles.EventParameters{eventSourceIdx} = eg_runPlugin(handles.plugins.eventDetectors, eventDetector, 'params');
%     else
%         handles.EventCurrentIndex(axnum) = length(handles.EventSources)+1;
%         handles.EventSources{end+1} = src;
%         handles.EventFunctions{end+1} = fun;
%         handles.EventDetectors{end+1} = dtr;
%         handles.EventThresholds = [handles.EventThresholds; inf*ones(1,size(handles.EventThresholds,2))];
%         handles.EventCurrentThresholds(end+1) = inf;
% 
%         [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, dtr, [], handles.fs, inf, handles.ChannelAxesEventParameters{axnum});
%         handles.EventTimes{end+1} = cell(length(labels),handles.TotalFileNumber);
%         handles.EventSelected{end+1} = cell(length(labels),handles.TotalFileNumber);
%     end
%     
%     % Delete list of event part display menu items (one set of menu
%     % items for each axes)
%     delete(handles.menu_EventsDisplay(axnum).Children);
%     handles.menu_EventsDisplayList{axnum} = gobjects.empty();
% 
%     indx = 0;
%     str = handles.popup_Channel1.String;
%     while 1
%         indx = indx + 1;
%         if ~isempty(strfind(str{indx},' - '))
%             break
%         end
%     end
%     indx = indx - 1;
%     for c = 1:handles.EventCurrentIndex(axnum)-1
%         indx = indx + size(handles.EventTimes{c},1);
%     end
%     for c = 1:size(handles.EventTimes{handles.EventCurrentIndex(axnum)},1)
%         label = str{indx+c};
%         f = strfind(label,' - ');
%         label = label(f(end)+3:end);
%         handles.menu_EventsDisplayList{axnum}(c) = uimenu(handles.menu_EventsDisplay(axnum),...
%             'Label',label,...
%             'Callback',@EventPartDisplayClick, ...
%             'Checked','on');
%     end
%     
%     handles = UpdateEventThresholdDisplay(handles,axnum);

function [handles, eventSourceIdx] = addNewEventSourceFromChannelAxes(handles, axnum)
    % Add a new event source based on the current settings in the given
    % channel axes
    [channelNum, channelName] = getSelectedChannel(handles, axnum);
    filterName = getSelectedFilter(handles, axnum);
    eventDetectorName = getSelectedEventDetector(handles, axnum);
    eventParameters = getSelectedEventParameters(handles, axnum);
    eventXLims = getSelectedEventLims(handles, axnum);
    eventParts = getSelectedEventParts(handles, axnum);
    [handles, eventSourceIdx] = addNewEventSource(handles, channelNum, channelName, filterName, eventDetectorName, eventParameters, eventXLims, eventParts);

function [handles, eventSourceIdx] = addNewEventSource(handles, channelNum, ...
        channelName, filterName, eventDetectorName, eventParameters, ...
        eventXLims, eventParts)
    % Add a new event source, update all event-source-indexed variables
    eventSourceIdx = length(handles.EventSources) + 1;
    handles.EventSources{eventSourceIdx} = channelName;
    handles.EventChannels(eventSourceIdx) = channelNum;
    handles.EventFunctions{eventSourceIdx} = filterName;
    handles.EventDetectors{eventSourceIdx} = eventDetectorName;
    handles.EventParameters{eventSourceIdx} = eventParameters;
    handles.EventXLims(eventSourceIdx, :) = eventXLims;
    handles.EventParts{eventSourceIdx} = eventParts;

    handles.EventTimes{eventSourceIdx} = cell(length(eventParts), handles.TotalFileNumber);
    handles.EventSelected{eventSourceIdx} = cell(length(eventParts), handles.TotalFileNumber);

function handles = UpdateEventSourceList(handles)
    % Update the list of event sources above the event viewer axes

    % Set up the "none" option at the top
    eventListItems = {'(None)'};
    % Set null event list info for the "none" option
    eventListInfo(1).eventSourceIdx = [];
    eventListInfo(1).eventPartIdx = [];
    % Loop over event sources
    listIdx = 1;
    for eventSourceIdx = 1:length(handles.EventSources)
        eventParts = handles.EventParts{eventSourceIdx};
        % Loop over the event parts for this event source
        for eventPartIdx = 1:length(eventParts)
            listIdx = listIdx + 1;
            % Get event source info
            channelName = handles.EventSources{eventSourceIdx};
            filterName = handles.EventFunctions{eventSourceIdx};
            eventPart = eventParts{eventPartIdx};
            % Assemble event list info
            eventListInfo(listIdx).eventSourceIdx = eventSourceIdx;
            eventListInfo(listIdx).eventPartIdx = eventPartIdx;
            % Assemble event source text
            eventListItems{listIdx} = [channelName, ' - ', filterName, ' - ', eventPart];
        end
    end
    % Update list
    handles.popup_EventListAlign.String = eventListItems;
    handles.popup_EventListAlign.UserData = eventListInfo;

function [handles, eventSourceIdx] = DetectEvents(handles, axnum)
    % Use the configuration of the given channel axes to either create a
    % new event source, or update an existing one, with detected events.

    % Get event source matching current channel configuration
    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    if isempty(eventSourceIdx)
        % No existing event source matches - create a blank one
        [handles, eventSourceIdx] = addNewEventSourceFromChannelAxes(handles, axnum);
        handles = UpdateEventSourceList(handles);
    end

    % Remove any active event
    handles.ActiveEventNum = [];
    handles.ActiveEventPartNum = [];
    handles.ActiveEventSourceIdx = [];

    % Remove active event cursor
    delete(handles.ActiveEventCursors);
    
    % Get channel data
    chanData = handles.loadedChannelData{axnum};

    [~, ~, eventDetectorName, eventParameters] = GetEventSourceInfo(handles, eventSourceIdx);

    filenum = getCurrentFileNum(handles);
    threshold = handles.EventThresholds(eventSourceIdx, filenum);

    if strcmp(eventDetectorName, '(None)')
        % No event detector selected
        return
    end

    % Run event detector plugin to get a list of detected event times
    [eventTimes, eventParts] = eg_runPlugin(handles.plugins.eventDetectors, eventDetectorName, chanData, handles.fs, threshold, eventParameters);

    % Update event part selection menu
    for eventPartNum = 1:length(eventParts)
        eventPart = eventParts{eventPartNum};
        handles.menu_EventsDisplayList{axnum}(eventPartNum) = uimenu(handles.menu_EventsDisplay(axnum),...
        'Label',eventPart,...
        'Callback',@EventPartDisplayClick, ...
        'Checked','on');
    end

    for eventPartNum = 1:length(eventTimes)
        handles.EventTimes{eventSourceIdx}{eventPartNum, filenum} = eventTimes{eventPartNum};
        handles.EventSelected{eventSourceIdx}{eventPartNum, filenum} = true(1,length(eventTimes{eventPartNum}));
    end
    
    handles = UpdateChannelEventDisplay(handles, axnum);
    handles = UpdateEventSourceList(handles);

function handles = ClearEventMarkers(handles, axnum)
    % Delete all event markers in channel axes
    for eventPartNum = 1:length(handles.EventHandles{axnum})
        delete(handles.EventHandles{axnum}{eventPartNum});
    end
    handles.EventHandles{axnum} = {};

function handles = UpdateDisplayForEventSource(handles, eventSourceIdx)
    % Update any displays (channel axes or event viewer) that are currently
    % displaying the given event source idx
    eventViewerEventSourceIdx = GetEventViewerEventSourceIdx(handles);
    if eventSourceIdx == eventViewerEventSourceIdx
        handles = UpdateEventViewer(handles);
    end
    for axnum = 1:2
        channelAxesEventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
        if eventSourceIdx == channelAxesEventSourceIdx
            handles = UpdateChannelEventDisplay(handles, axnum);
        end
    end

function handles = UpdateChannelEventDisplay(handles, axnum)
    % Get the index of the event source (a channel, but not in numerical
    % order, see handles.EventSources for order)
    if ~handles.axes_Channel(axnum).Visible
        % Axes isn't visible, no point in updating it.
        return;
    end

    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);

    handles = ClearEventMarkers(handles, axnum);

    if isempty(eventSourceIdx)
        % No event source
        return
    end

    handles = UpdateEventThresholdDisplay(handles, eventSourceIdx);

    filenum = getCurrentFileNum(handles);
    hold(handles.axes_Channel(axnum), 'on');
    eventTimes = {};
    eventSelected = {};
    handles.EventHandles{axnum} = {};
    for eventPartIdx = 1:size(handles.EventTimes{eventSourceIdx},1)
        eventTimes{eventPartIdx} = handles.EventTimes{eventSourceIdx}{eventPartIdx, filenum};
        eventSelected{eventPartIdx} = handles.EventSelected{eventSourceIdx}{eventPartIdx, filenum};
    end

    % Determine which of the event part to display (based on event parts
    % defined by event detection plugin)
    eventPartMenuItem = handles.menu_EventsDisplayList{axnum};

    % Get channel data
    chanData = handles.loadedChannelData{axnum};
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    times = linspace(0, numSamples/handles.fs, numSamples);
    for eventPartIdx = 1:length(eventTimes)
        storedInfo.eventPartIdx = eventPartIdx;
        if eventPartMenuItem(eventPartIdx).Checked
            % Hack to enable a single plot command to produce many separate
            % plot objects with no rendered 0-length lines
            eventXs = vertcat(times(eventTimes{eventPartIdx}), nan(1, length(eventTimes{eventPartIdx})));
            eventYs = vertcat(chanData(eventTimes{eventPartIdx})', nan(1, length(eventTimes{eventPartIdx})));
            % Plot all events with black markers
            handles.EventHandles{axnum}{eventPartIdx} = ...
                plot(handles.axes_Channel(axnum), eventXs, eventYs, 'o', ...
                    'LineStyle', 'none', 'MarkerEdgeColor', 'k', ...
                    'MarkerFaceColor', 'k', 'MarkerSize', 5, ...
                    'UserData', storedInfo, ...
                    'ButtonDownFcn', @ClickEventSymbol);
            % Set unselected event markers to white
            [handles.EventHandles{axnum}{eventPartIdx}(~eventSelected{eventPartIdx}).MarkerFaceColor] = deal('w');
        else
            handles.EventHandles{axnum}{eventPartIdx} = [];
        end
    end

    % Update event threshold line
    handles = UpdateEventThresholdDisplay(handles, eventSourceIdx);

function ClickEventSymbol(hObject, event)
    % Handle a click on an event marker in one of the channel axes
    handles = guidata(hObject);
    
    % Determine which axes the clicked marker was in
    if hObject.Parent==handles.axes_Channel1
        axnum = 1;
    else
        axnum = 2;
    end

    eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
    filenum = getCurrentFileNum(handles);
    for eventPartNum = 1:length(handles.EventHandles{axnum})
        eventNum = find(handles.EventHandles{axnum}{eventPartNum}==hObject, 1);
        if ~isempty(eventNum)
            break;
        end
    end

    if isempty(eventNum)
        error('Could not find clicked event marker in list');
    end
    
    if strcmp(handles.figure_Main.SelectionType,'extend')
        % User clicked event marker with shift held down

        % Clear previously highlighted event
        handles.ActiveEventNum = [];
        handles.ActiveEventPartNum = [];
        handles.ActiveEventSourceIdx = [];
        % Delete highlighted event markers
        delete(handles.ActiveEventCursors);
    
        handles.EventSelected{eventSourceIdx}{eventPartNum, filenum}(eventNum) = false;
    
        for axn = 1:2
            handles = UpdateChannelEventDisplay(handles, axnum);
        end

        % ?????
        val = handles.popup_Channels(3-axnum).Value;
        str = handles.popup_Channels(3-axnum).String;
        nums = [];
        for eventPartNum = 1:length(handles.EventTimes)
            nums(eventPartNum) = size(handles.EventTimes{eventPartNum},1);
        end
        if val > length(str)-sum(nums)
            indx = val-(length(str)-sum(nums));
            cs = cumsum(nums);
            f = length(find(cs<indx))+1;
            if f == handles.EventCurrentIndex(axnum)
                handles = eg_LoadChannel(handles,3-axnum);
            end
        end
    
        if strcmp(handles.axes_Channel(3-axnum).Visible','on') && handles.EventCurrentIndex(1)==handles.EventCurrentIndex(2)
            handles = UpdateChannelEventDisplay(handles,3-axnum);
        end
    
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventViewer(handles);
        end
    
    
    elseif strcmp(handles.figure_Main.SelectionType,'normal') && sum(hObject.MarkerFaceColor==[1 1 1])~=3
        indx = handles.popup_EventListAlign.Value-1;
        if indx==0
            return
        end
        nums = [];
        for eventPartNum = 1:length(handles.EventTimes)
            nums(eventPartNum) = size(handles.EventTimes{eventPartNum},1);
        end
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if f>1
            g = indx-cs(f-1);
        else
            g = indx;
        end
        filenum = getCurrentFileNum(handles);
        tm = handles.EventTimes{f}{g,filenum};
        sel = handles.EventSelected{f}{g,filenum};
    
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        xs = linspace(0, numSamples/handles.fs, numSamples);
        tm = xs(tm(sel==1));
        xclick = hObject.XData(1);
        [~, j] = min(abs(tm-xclick));
        handles = SetActiveEventDisplay(handles, j);
%        handles = ActivateEvent(handles,j);
    
    end
    
    guidata(hObject, handles);

function EventPartDisplayClick(hObject, event)
    % Handle a click on one of the event part display submenu
    % (R click on channel axes => Events => Display => click on event part)
    handles = guidata(hObject);
    
    if strcmp(hObject.Checked,'on')
        hObject.Checked = 'off';
    else
        hObject.Checked = 'on';
    end
    
    if hObject.Parent==handles.menu_EventsDisplay1
        handles = UpdateChannelEventDisplay(handles,1);
    else
        handles = UpdateChannelEventDisplay(handles,2);
    end
    
    guidata(hObject, handles);

function handles = UpdateEventViewer(handles)
    delete(handles.ActiveEventCursors);
    delete(handles.EventWaveHandles);
    handles.EventWaveHandles = gobjects().empty;

    hold(handles.axes_Events, 'on');
    
    eventSourceIdx = GetEventViewerEventSourceIdx(handles);

    if isempty(eventSourceIdx)
        handles.axes_Events.Visible = 'off';
        return
    else
        handles.axes_Events.Visible = 'on';
    end
    
    % Determine what data should be displayed
    val = handles.popup_EventListData.Value;
    dataSources = handles.popup_EventListData.String;
    dataSource = dataSources{val};
    switch dataSource
        case '<< Source'
            % Check if any of the channels match the event alignment data source
            channelData = [];
            for axnum = 1:2
                chanEventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum);
                if eventSourceIdx == chanEventSourceIdx
                    % This channel matches - use the loaded channel data
                    channelData = handles.loadedChannelData{axnum};
                    channelYLabel = handles.axes_Channel(axnum).YLabel.String;
                    break;
                end
            end
            if isempty(channelData)
                % None of the currently loaded channels have this data,
                % load it from file
                selectedChannelNum = getSelectedChannel(handles, axnum);
                selectedFilter = getSelectedFilter(handles, axnum);
                selectedFilterParams = handles.FunctionParams{axnum};
                [handles, channelData, channelYLabel] = loadChannelData(handles, selectedChannelNum, selectedFilter, selectedFilterParams);
            end
        case 'Top axes'
            channelData = handles.loadedChannelData{1};
            channelYLabel = (handles.axes_Channel(1).YLabel.String);
        case 'Bottom axes'
            channelData = handles.loadedChannelData{2};
            channelYLabel = (handles.axes_Channel(2).YLabel.String);
    end
    
    filenum = getCurrentFileNum(handles);
    eventPartIdx = GetEventViewerEventPartIdx(handles);

    allEventTimes = handles.EventTimes{eventSourceIdx}(:,filenum);
    eventTimes = handles.EventTimes{eventSourceIdx}{eventPartIdx,filenum};
    eventSelection = handles.EventSelected{eventSourceIdx}{eventPartIdx,filenum};
    
    if handles.menu_DisplayValues.Checked
        % "Display > Values" in Event axes context menu is selected
        handles.EventWaveHandles = gobjects().empty;
        % Check if there is channel data
        if ~isempty(channelData)
            % Loop over events
            for eventNum = 1:length(eventTimes)
                % Get the event time and time limits
                eventTime = eventTimes(eventNum);
                leftWidth = round(handles.EventXLims(eventSourceIdx, 1) * handles.fs);
                rightWidth = round(handles.EventXLims(eventSourceIdx, 2) * handles.fs);
                startTime = max([1, eventTime - leftWidth]);
                endTime = min([length(channelData), eventTime + rightWidth]);
                if eventSelection(eventNum)
                    % If event is selected, plot the wave
                    handles.EventWaveHandles(end+1) = plot(handles.axes_Events, ((startTime:endTime)-eventTimes(eventNum))/handles.fs*1000,channelData(startTime:endTime),'Color','k');
                end
            end
            xlabel(handles.axes_Events, 'Time (ms)');
            ylabel(handles.axes_Events, channelYLabel);
            xlim(handles.axes_Events, [-handles.EventXLims(eventSourceIdx, 1), handles.EventXLims(eventSourceIdx, 2)]*1000);
            axis(handles.axes_Events, 'tight');
            yl = ylim(handles.axes_Events);
            ylim(handles.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            delete(handles.EventWaveHandles);
            handles.EventWaveHandles = gobjects().empty();
            ylabel(handles.axes_Events, '');
        end
    else
        % "Display > Features" in Event axes context menu is selected
        handles.EventWaveHandles = gobjects().empty;
        if ~isempty(channelData)
            f = findobj('Parent',handles.menu_XAxis,'Checked','on');
            str = f.Label;
            [feature1, name1] = eg_runPlugin(handles.plugins.eventFeatures, ...
                str, channelData, handles.fs, allEventTimes, g, ...
                round(handles.EventXLims(handles.popup_EventListAlign.Value,:)*handles.fs));
            f = findobj('Parent',handles.menu_YAxis,'Checked','on');
            str = f.Label;
            [feature2, name2] = eg_runPlugin(handles.plugins.eventFeatures, ...
                str, channelData, handles.fs, allEventTimes, g, ...
                round(handles.EventXLims(handles.popup_EventListAlign.Value,:)*handles.fs));
    
            for c = 1:length(feature1)
                if eventSelection(c)==1
                    handles.EventWaveHandles(end+1) = plot(handles.axes_Events, ...
                        feature1(c),feature2(c), 'o', 'MarkerFaceColor', 'k', ...
                        'MarkerEdgeColor', 'k', 'MarkerSize', 2);
                end
            end
            xlabel(handles.axes_Events, name1);
            ylabel(handles.axes_Events, name2);
    
            axis(handles.axes_Events, 'tight');
            xl = xlim(handles.axes_Events);
            xlim(handles.axes_Events, [mean(xl)+(xl(1)-mean(xl))*1.1 mean(xl)+(xl(2)-mean(xl))*1.1]);
            yl = ylim(handles.axes_Events);
            ylim(handles.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            xlabel('');
            ylabel('');
        end
    end

    % Set click handlers for event waves
    for k = 1:length(handles.EventWaveHandles)
        handles.EventWaveHandles(k).ButtonDownFcn = @click_eventwave;
    end
    
    handles.axes_Events.UIContextMenu = handles.context_EventViewer;
    handles.axes_Events.ButtonDownFcn = @click_eventaxes;
    for child = handles.axes_Events.Children'
        child.UIContextMenu = handles.axes_Events.UIContextMenu;
    end
    
    if ~isempty(handles.ActiveEventNum)
        handles = SetActiveEventDisplay(handles, handles.ActiveEventNum, handles.ActiveEventPartNum, handles.ActiveEventSourceIdx);
    end
    
    if handles.menu_AutoApplyYLim.Checked && ~isempty(handles.EventWaveHandles)
        if handles.menu_DisplayValues.Checked
            % Update this
%             if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
%                 handles.axes_Channel1.YLim = handles.axes_Events.YLim;
%             elseif handles.menu_AutoLimits2.Checked
%                 handles.axes_Channel2.YLim = handles.axes_Events.YLim;
%             end
        end
    end

function [channelNum, filterName, eventDetectorName] = GetEventViewerSourceInfo(handles)
    % Return the channel number, filter name, and event detector name for
    % the currently displayed event source in the event viewer
    eventSourceIdx = GetEventViewerEventSourceIdx(handles);
    if isempty(eventSourceIdx)
        % No event source selected
        channelNum = [];
        filterName = '';
        eventDetectorName = '';
    else
        [channelNum, filterName, eventDetectorName] = GetEventSourceInfo(handles, eventSourceIdx);
    end
function [channelNum, filterName, eventDetectorName, eventParameters, eventLims, eventParts] = GetEventSourceInfo(handles, eventSourceIdx)
    % Return the channel number, filter name, and event detector name for
    % the given event source index
    channelNum = handles.EventChannels(eventSourceIdx);
    filterName = handles.EventFunctions(eventSourceIdx);
    eventDetectorName = handles.EventDetectors(eventSourceIdx);
    eventParameters = handles.EventParameters{eventSourceIdx};
    eventLims = handles.EventXLims(eventSourceIdx);
    eventParts = handles.EventParts{eventSourceIdx};
function [channelNum, filterName, eventDetectorName] = GetChannelAxesInfo(handles, axnum)
    % Return the current settings of specified channel axes
    channelNum = getSelectedChannel(handles, axnum);
    filterName = getSelectedFilter(handles, axnum);
    eventDetectorName = getSelectedEventDetector(handles, axnum);

% function [eventSourceTexts, eventSourceIdxs, eventPartIdxs] = ParseEventSourceListText(eventSourceListText)
%     % For legacy dbase loading, attempt to parse a stored event viewer
%     % event source list text
%     parts = split(eventSourceListText, ' - ');
% 
function handles = SetEventViewerEventListElement(handles, eventListIdx, eventSourceText, eventSourceIdx, eventPartIdx)
    % Set the specified element of the event viewer event source list
    if ~exists('eventListIdx', 'var') || isempty(eventListIdx)
        % Add element on to the end if no list index is provided
        eventListIdx = length(handles.popup_EventListAlign.String)+1;
    end
    handles.popup_EventListAlign.String{eventListIdx} = eventSourceText;
    handles.popup_EventListAlign.UserData(eventListIdx).eventSourceIdx = eventSourceIdx;
    handles.popup_EventListAlign.UserData(eventListIdx).eventPartIdx = eventPartIdx; 
function eventSourceIdx = GetEventViewerEventSourceIdx(handles)
    % Get the event source index from the currently selected item in the
    % event viewer event source list
    eventListIdx = handles.popup_EventListAlign.Value;
    eventSourceIdx = handles.popup_EventListAlign.UserData(eventListIdx).eventSourceIdx;
function eventPartIdx = GetEventViewerEventPartIdx(handles)
    % Get the event part index from the currently selected item in the
    % event viewer event source list
    eventListIdx = handles.popup_EventListAlign.Value;
    eventPartIdx = handles.popup_EventListAlign.UserData(eventListIdx).eventPartIdx;
function eventSourceIdx = GetChannelAxesEventSourceIdx(handles, axnum)
    % Get the event source index that matches the current settings of the
    % given channel axes. If there is no match, return an empty array
    [axChannelNum, axFilterName, axEventDetectorName] = GetChannelAxesInfo(handles, axnum);
    for eventSourceIdx = 1:length(handles.EventSources)
        [channelNum, filterName, eventDetectorName] = GetEventSourceInfo(handles, eventSourceIdx);
        if axChannelNum == channelNum && ...
           strcmp(axFilterName, filterName) && ...
           strcmp(axEventDetectorName, eventDetectorName)
            % Found a match
            return
        end
    end
    % No match found
    eventSourceIdx = [];

function matchingAxes = WhichChannelAxesMatchEventSource(handles, eventSourceIdx)
    % Return a list of axes indices indicating whether each of the channel
    % axes match the given event source index, or if that is not provided,
    % the currently displayed event viewer source.
    if ~exist('eventSourceIdx', 'var') || isempty(eventSourceIdx)
        % Use the event source index currently selected in the event viewer
        eventSourceIdx = GetEventViewerEventSourceIdx(handles);
    end

    matchingAxes = [];
    for axnum = 1:2
        [channelNum, filterName, eventDetectorName] = GetEventSourceInfo(handles, eventSourceIdx);
        [axChannelNum, axFilterName, axEventDetectorName] = GetChannelAxesInfo(handles, axnum);
        if channelNum == axChannelNum && ...
           strcmp(filterName, axFilterName) && ...
           strcmp(eventDetectorName, axEventDetectorName)
            matchingAxes(end+1) = axnum;
        end
    end

function axnum = GetAxnum(handles, obj)
    % Given a graphics object, determine which channel axes it belongs to.
    while ~isa(obj, 'matlab.graphics.axis.Axes')
        obj = obj.Parent;
    end
    axnum = find(obj==handles.handles.axes_Channel, 1);

function click_eventwave(eventWaveHandle, event)
    handles = guidata(eventWaveHandle);
    
    newActiveEventNum = find(handles.EventWaveHandles==eventWaveHandle);
    newActiveEventPart = GetEventViewerEventPartIdx(handles);
    newEventSourceIdx = GetEventViewerEventSourceIdx(handles);

    if strcmp(handles.figure_Main.SelectionType,'normal')
        handles = SetActiveEventDisplay(handles, newActiveEventNum, newActiveEventPart, newEventSourceIdx);
        guidata(eventWaveHandle, handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        eventWaveHandle.XData = [];
        eventWaveHandle.YData = [];
        hold(handles.axes_Events, 'on');
        % ???
        handles.EventWaveHandles(handles.ActiveEventNum) = plot(handles.axes_Events, mean(xlim(handles.axes_Events)),mean(ylim(handles.axes_Events)),'w.');
        hold(handles.axes_Events, 'off');
        handles = DeleteEvents(handles,handles.ActiveEventNum);
        guidata(eventWaveHandle, handles);
        delete(eventWaveHandle);
    end

function handles = DeactivateEventDisplay(handles)
    
function numEvents = GetNumEvents(handles, eventSourceIdx, eventPartNum)
    % Get the # of events for the specified event source index and event
    % part num. If not provided, use the currently active event source
    % index and event part num.
    if ~exist('eventSourceIdx', 'var') || isempty(eventSourceIdx)
        % User didn't provide event source index - use the active one
        eventSourceIdx = handles.ActiveEventSourceIdx;
    end
    if ~exist('eventPartNum', 'var') || isempty(eventPartNum)
        % User didn't provide event part number - use the active one
        eventPartNum = handles.ActiveEventPartNum;
    end
    if isempty(eventSourceIdx) || isempty(eventPartNum)
        % Invalid event source index or part number
        numEvents = [];
    else
        numEvents = length(handles.EventTimes{eventSourceIdx}{eventPartNum});
    end

function handles = SetActiveEventDisplay(handles, newActiveEventNum, newActiveEventPart, newEventSourceIdx)
    if ~exist('newActiveEventPart', 'var') || isempty(newActiveEventPart)
        % If not provided, assume we're not switching to a new event part
        newActiveEventPart = handles.ActiveEventPartNum;
    end
    if ~exist('newEventSourceIdx', 'var') || isempty(newEventSourceIdx)
         newEventSourceIdx = handles.ActiveEventSourceIdx;
    end
    
    oldActiveEventNum = handles.ActiveEventNum;
    oldActiveEventPart = handles.ActiveEventPartNum;
    oldActiveEventSourceIdx = handles.ActiveEventSourceIdx;
    handles.ActiveEventNum = newActiveEventNum;
    handles.ActiveEventPartNum = newActiveEventPart;
    handles.ActiveEventSourceIdx = newEventSourceIdx;
    handles = UpdateActiveEventDisplay(handles, oldActiveEventNum, oldActiveEventPart, oldActiveEventSourceIdx);

function handles = UpdateActiveEventDisplay(handles, oldActiveEventNum, oldActiveEventPart, oldEventSourceIdx)
    handles = SetEventDisplayActiveState(handles, oldActiveEventNum, oldActiveEventPart, oldEventSourceIdx, false);
    handles = SetEventDisplayActiveState(handles, handles.ActiveEventNum, handles.ActiveEventPartNum, oldEventSourceIdx, true);

function handles = SetEventDisplayActiveState(handles, eventNum, eventPartNum, eventSourceIdx, activeState)
    % Take the given event number, event part, and event source index, and
    % set it to the given active state (either true => active or false =>
    % inactive

    if isempty(eventNum) || isempty(eventPartNum) || isempty(eventSourceIdx)
        % Can't make an event active if it doesn't exist, now can we
        return
    end

    % Check if event viewer is currently displaying this event
    eventViewerEventSourceIdx = GetEventViewerEventSourceIdx(handles);
    if eventViewerEventSourceIdx == eventSourceIdx
        % Event viewer is displaying this event's source
        % Update active event wave plot (in the event axes)
        if activeState
            handles.EventWaveHandles(eventNum).LineWidth = 2;
            handles.EventWaveHandles(eventNum).Color = 'r';
            uistack(handles.EventWaveHandles(eventNum), 'top');
        else
            handles.EventWaveHandles(eventNum).LineWidth = 1;
            handles.EventWaveHandles(eventNum).Color = 'k';
        end
    end

    % Update active event marker (in any channel axes that are displaying this event)
    matchingAxes = WhichChannelAxesMatchEventSource(handles);
    for axnum = matchingAxes
        eventMarkerHandle = handles.EventHandles{axnum}{eventPartNum}(eventNum);
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

    % Update active event cursor in sound axes
    if activeState
        [handles, numSamples] = eg_GetNumSamples(handles);
        filenum = getCurrentFileNum(handles);
        ts = linspace(0, numSamples/handles.fs, numSamples);
        eventTimes = handles.EventTimes{eventSourceIdx}{eventPartNum,filenum};
        activeEventTime = ts(eventTimes(eventNum));
        
        handles = UpdateActiveEventCursors(handles, activeEventTime);
    else
        handles = UpdateActiveEventCursors(handles, []);
    end

function handles = UpdateActiveEventCursors(handles, eventTime)
    % Create, update, or delete the active event cursor

    % Delete the active event cursor
    delete(handles.ActiveEventCursors);

    if isempty(eventTime)
        return;
    end

%     if isempty(handles.ActiveEventCursors) || any(~isvalid(handles.ActiveEventCursors))
        % No active event cursor yet, reset them then create then
        handles.ActiveEventCursors = gobjects().empty;
        % Make list of axes to plot cursor on
        axesList = [handles.axes_Sound, handles.axes_Sonogram, handles.axes_Amplitude, handles.axes_Channel];
        % Remove any invalid or invisible axes
        axesList(~isvalid(axesList) | ~[axesList.Visible]) = [];
        for ax = axesList
            hold(ax, 'on');
            handles.ActiveEventCursors(end+1) = plot(ax, [eventTime, eventTime], ylim(ax), '-.', 'LineWidth' , 1, 'Color', 'r');
            hold(ax, 'off');
        end
%     else
%         % Active event cursor already exists, update its position
%         handles.ActiveEventCursors.XData = [activeEventTime, activeEventTime];
%         handles.ActiveEventCursors.YData = ylim(handles.axes_Sound);
%     end


% function handles = ActivateEvent(handles,i)
%     
%     if isempty(i)
%         return
%     end
%     delete(findobj('Parent',handles.axes_Events,'LineWidth',2));
%     delete(handles.ActiveEventCursors);
%     handles.ActiveEventNum = i;
%     
%     if i<=length(handles.EventWaveHandles)
%         hold(handles.axes_Events, 'on');
%         xl = xlim(handles.axes_Events);
%         yl = ylim(handles.axes_Events);
%         x = handles.EventWaveHandles(i).XData;
%         y = handles.EventWaveHandles(i).YData;
%         m = handles.EventWaveHandles(i).Marker;
%         if strcmp(m,'none')
%             h = plot(handles.axes_Events, x,y,'r','LineWidth',2);
%         else
%             ms = handles.EventWaveHandles(i).MarkerSize;
%             h = plot(handles.axes_Events, x,y,'LineWidth',2,'Marker',m,'MarkerSize',ms,'MarkerFaceColor','r','MarkerEdgeColor','r');
%         end
%         h.ButtonDownFcn = @unselect_event;
%         xlim(handles.axes_Events, xl);
%         ylim(handles.axes_Events, yl);
%         hold(handles.axes_Events, 'off');
%     end
%     
%     for k = 1:length(handles.EventWaveHandles)
%         handles.EventWaveHandles(k).ButtonDownFcn = @click_eventwave;
%     end
%     
%     filenum = getCurrentFileNum(handles);
%     nums = [];
%     for c = 1:length(handles.EventTimes)
%         nums(c) = size(handles.EventTimes{c},1);
%     end
%     indx = handles.popup_EventListAlign.Value-1;
%     cs = cumsum(nums);
%     f = length(find(cs<indx))+1;
%     if f>1
%         g = indx-cs(f-1);
%     else
%         g = indx;
%     end
%     eventTimes = handles.EventTimes{f}{g,filenum};
%     eventSelection = handles.EventSelected{f}{g,filenum};
%     eventTimes = eventTimes(eventSelection);
%     
%     [handles, numSamples] = eg_GetNumSamples(handles);
%     
%     ts = linspace(0, numSamples/handles.fs, numSamples);
%     hold(handles.axes_Sound, 'on');
%     plot(handles.axes_Sound, [ts(eventTimes(i)) ts(eventTimes(i))], ylim(handles.axes_Sound),'-.','LineWidth',2,'Color','r');
%     hold(handles.axes_Sound, 'off');
% 
%     % 
%     h = gobjects().empty;
%     for axnum = 1:2
%         if handles.axes_Channel(axnum).Visible
%             ys = handles.loadedChannelData{axnum};
%             hold(handles.axes_Channel(axnum), 'on');
%             h(end+1) = plot(handles.axes_Channel(axnum), ts(eventTimes(i)),ys(eventTimes(i)),'-.o','LineWidth',2,'MarkerSize',5,'MarkerFaceColor','r','MarkerEdgeColor','r');
%             hold(handles.axes_Channel(axnum), 'off');
%         end
%     end
%     [h.ButtonDownFcn] = deal(@unselect_event);
    
function unselect_event(hObject, ~, handles)
    
    handles = SetEventDisplayActiveState(handles, handles.ActiveEventNum, handles.ActiveEventPartNum, eventSourceIdx, activeState);

    handles.ActiveEventNum = [];
    handles.ActiveEventPartNum = [];
    guidata(hObject, handles);
    
    delete(handles.ActiveEventCursors);
    delete(findobj('Parent',handles.axes_Events,'LineWidth',2));

function click_eventaxes(hObject, event)
    handles = guidata(hObject);
    
    if strcmp(handles.figure_Main.SelectionType,'normal')
        handles.axes_Events.Units = 'pixels';
        handles.axes_Events.Parent.Units = 'pixels';
        handles.figure_Main.Units = 'pixels';
        rect = rbbox;
    
        if rect(3)>0 && rect(4)>0
            pos = handles.axes_Events.Position;
            pospan = handles.axes_Events.Parent.Position;
            xl = xlim;
            yl = ylim;
    
            rect(1) = xl(1)+(rect(1)-pos(1)-pospan(1))/pos(3)*(xl(2)-xl(1));
            rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
            rect(2) = yl(1)+(rect(2)-pos(2)-pospan(2))/pos(4)*(yl(2)-yl(1));
            rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
    
            xlim([rect(1) rect(1)+rect(3)]);
            ylim([rect(2) rect(2)+rect(4)]);
        end
    
        handles.figure_Main.Units = 'normalized';
        handles.axes_Events.Parent.Units = 'normalized';
        handles.axes_Events.Units = 'normalized';
    
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        axis(handles.axes_EventViewer, 'tight');
        yl = ylim(handles.axes_EventViewer);
        ylim(handles.axes_EventViewer, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        if handles.menu_DisplayFeatures.Checked
            xl = xlim(handles.axes_EventViewer);
            xlim(handles.axes_EventViewer, [mean(xl)+(xl(1)-mean(xl))*1.1 mean(xl)+(xl(2)-mean(xl))*1.1]);
        end
        if handles.menu_AutoApplyYLim.Checked
            if handles.menu_DisplayValues.Checked
                % UPDATE THIS
%                 if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
%                     handles.axes_Channel1.YLim = handles.axes_Events.YLim;
%                 elseif handles.menu_AutoLimits2.Checked
%                     handles.axes_Channel2.YLim = handles.axes_Events.YLim;
%                 end
            end
        end
    
    
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        delete(findobj('Parent',handles.axes_Events,'LineWidth',2));
        handles.ActiveEventNum = [];
        handles.ActiveEventPartNum = [];
        delete(handles.ActiveEventCursors);
    
        handles.axes_Events.Units = 'pixels';
        handles.axes_Events.Parent.Units = 'pixels';
        handles.figure_Main.Units = 'pixels';
        rect = rbbox;
    
        pos = handles.axes_Events.Position;
        pospan = handles.axes_Events.Parent.Position;
        handles.figure_Main.Units = 'normalized';
        handles.axes_Events.Parent.Units = 'normalized';
        handles.axes_Events.Units = 'normalized';
        xl = xlim;
        yl = ylim;
    
        x1 = xl(1)+(rect(1)-pos(1)-pospan(1))/pos(3)*(xl(2)-xl(1));
        x2 = rect(3)/pos(3)*(xl(2)-xl(1)) + x1;
        y1 = yl(1)+(rect(2)-pos(2)-pospan(2))/pos(4)*(yl(2)-yl(1));
        y2 = rect(4)/pos(4)*(yl(2)-yl(1)) + y1;
    
        todel = [];
        for c = 1:length(handles.EventWaveHandles)
            xs = handles.EventWaveHandles(c).XData;
            ys = handles.EventWaveHandles(c).YData;
            isin = find(xs>x1 & xs<x2 & ys>y1 & ys<y2, 1);
            if ~isempty(isin) && hObject ~= handles.EventWaveHandles(c)
                todel = [todel c];
            end
        end
    
        handles = DeleteEvents(handles,todel);
    end
    
    guidata(hObject, handles);

function handles = DeleteEvents(handles,todel)
    
    xlb = handles.axes_Events.XLim;
    ylb = handles.axes_Events.YLim;
    
    delete(handles.EventWaveHandles(todel));
    handles.EventWaveHandles(todel) = [];
    
    filenum = getCurrentFileNum(handles);
    nums = [];
    for eventSourceIdx = 1:length(handles.EventTimes)
        nums(eventSourceIdx) = size(handles.EventTimes{eventSourceIdx},1);
    end
    indx = handles.popup_EventListAlign.Value-1;
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    sel = handles.EventSelected{f}{g,filenum};
    alr = find(sel==1);
    
    handles.EventSelected{f}{g,filenum}(alr(todel)) = false;
    
    if ~isempty(todel) && handles.menu_DisplayValues.Checked
        axis tight
        yl = ylim;
        ylim([mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
    end
    
    for axn = 1:2
        indx = handles.popup_EventListAlign.Value-1;
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if handles.EventCurrentIndex(axn) == f && handles.axes_Channel(axn).Visible
            handles = UpdateChannelEventDisplay(handles,axn);
        end
    
        val = get(handles.popup_Channels(3-axn),'Value');
        str = get(handles.popup_Channels(3-axn),'String');
        nums = [];
        for eventSourceIdx = 1:length(handles.EventTimes)
            nums(eventSourceIdx) = size(handles.EventTimes{eventSourceIdx},1);
        end
        if val > length(str)-sum(nums)
            indx = val-(length(str)-sum(nums));
            cs = cumsum(nums);
            f = length(find(cs<indx))+1;
            if f == handles.EventCurrentIndex(axn)
                handles = eg_LoadChannel(handles,3-axn);
            end
        end
    end
    
    xlim(handles.axes_Events, xlb);
    ylim(handles.axes_Events, ylb);
    
% --- Executes during object creation, after setting all properties.
function popup_EventListAlign_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_EventListAlign (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
% --------------------------------------------------------------------
function context_EventViewer_Callback(hObject, ~, handles)
    % hObject    handle to context_EventViewer (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_ChannelColors1_Callback(hObject, ~, handles)
    % hObject    handle to menu_ChannelColors1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_PlotColor1_Callback(hObject, ~, handles)
    % hObject    handle to menu_PlotColor1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    c = uisetcolor(handles.ChannelColor(1,:), 'Select color');
    handles.ChannelColor(1,:) = c;
    obj = findobj('Parent',handles.axes_Channel1,'LineStyle','-');
    obj.Color = c;
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ThresholdColor1_Callback(hObject, ~, handles)
    % hObject    handle to menu_ThresholdColor1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    c = uisetcolor(handles.ChannelThresholdColor(1,:), 'Select color');
    handles.ChannelThresholdColor(1,:) = c;
    obj = findobj('Parent',handles.axes_Channel1,'LineStyle',':');
    obj.Color = c;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_ChannelColors2_Callback(hObject, ~, handles)
    % hObject    handle to menu_ChannelColors2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_PlotColor2_Callback(hObject, ~, handles)
    % hObject    handle to menu_PlotColor2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    c = uisetcolor(handles.ChannelColor(2,:), 'Select color');
    handles.ChannelColor(2,:) = c;
    obj = findobj('Parent',handles.axes_Channel2,'LineStyle','-');
    obj.Color = c;
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ThresholdColor2_Callback(hObject, ~, handles)
    % hObject    handle to menu_ThresholdColor2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    c = uisetcolor(handles.ChannelThresholdColor(2,:), 'Select color');
    handles.ChannelThresholdColor(2,:) = c;
    obj = findobj('Parent',handles.axes_Channel2,'LineStyle',':');
    obj.Color = c;
    
    guidata(hObject, handles);
    
    
    
    
% --- Executes on button press in push_BrightnessUp.
function push_BrightnessUp_Callback(hObject, ~, handles)
    % hObject    handle to push_BrightnessUp (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    if handles.ispower == 1
        if handles.SonogramClim(2) > handles.SonogramClim(1)+0.5
            handles.SonogramClim(2) = handles.SonogramClim(2)-0.5;
        end
    else
        handles.NewSlope = handles.DerivativeSlope+0.2;
    end
    
    handles = SetSonogramColors(handles);
    
    guidata(hObject, handles);
    
% --- Executes on button press in push_BrightnessDown.
function push_BrightnessDown_Callback(hObject, ~, handles)
    % hObject    handle to push_BrightnessDown (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    if handles.ispower == 1
        handles.SonogramClim(2) = handles.SonogramClim(2)+0.5;
    else
        handles.NewSlope = handles.DerivativeSlope-0.2;
    end
    
    handles = SetSonogramColors(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_OffsetUp.
function push_OffsetUp_Callback(hObject, ~, handles)
    % hObject    handle to push_OffsetUp (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    if handles.ispower == 1
        if handles.SonogramClim(1) < handles.SonogramClim(2)-0.5
            handles.SonogramClim(1) = handles.SonogramClim(1)+0.5;
        end
    else
        handles.DerivativeOffset = handles.DerivativeOffset + 0.05;
    end
    handles = SetSonogramColors(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_OffsetDown.
function push_OffsetDown_Callback(hObject, ~, handles)
    % hObject    handle to push_OffsetDown (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
    if handles.ispower == 1
        handles.SonogramClim(1) = handles.SonogramClim(1)-0.5;
    else
        handles.DerivativeOffset = handles.DerivativeOffset - 0.05;
    end
    handles = SetSonogramColors(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AmplitudeColors_Callback(hObject, ~, handles)
    % hObject    handle to menu_AmplitudeColors (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AmplitudeColor_Callback(hObject, ~, handles)
    % hObject    handle to menu_AmplitudeColor (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    c = uisetcolor(handles.AmplitudeColor, 'Select color');
    handles.AmplitudeColor = c;
    obj = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
    obj.Color = c;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AmplitudeThresholdColor_Callback(hObject, ~, handles)
    % hObject    handle to menu_AmplitudeThresholdColor (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    c = uisetcolor(handles.AmplitudeThresholdColor, 'Select color');
    handles.AmplitudeThresholdColor = c;
    obj = findobj('Parent',handles.axes_Amplitude,'LineStyle',':');
    obj.Color = c;
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_PlayMix.
function push_PlayMix_Callback(hObject, ~, handles)
    % hObject    handle to push_PlayMix (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    snd = GenerateSound(handles,'mix');
    progress_play(handles,snd);
    
    
    
function edit_SoundWeight_Callback(hObject, ~, handles)
    % hObject    handle to edit_SoundWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_SoundWeight as text
    %        str2double(hObject.String) returns contents of edit_SoundWeight as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_SoundWeight_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_SoundWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
function edit_TopWeight_Callback(hObject, ~, handles)
    % hObject    handle to edit_TopWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_TopWeight as text
    %        str2double(hObject.String) returns contents of edit_TopWeight as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_TopWeight_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_TopWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
function edit_BottomWeight_Callback(hObject, ~, handles)
    % hObject    handle to edit_BottomWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_BottomWeight as text
    %        str2double(hObject.String) returns contents of edit_BottomWeight as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_BottomWeight_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_BottomWeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
function edit_SoundClipper_Callback(hObject, ~, handles)
    % hObject    handle to edit_SoundClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_SoundClipper as text
    %        str2double(hObject.String) returns contents of edit_SoundClipper as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_SoundClipper_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_SoundClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
function edit_TopClipper_Callback(hObject, ~, handles)
    % hObject    handle to edit_TopClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_TopClipper as text
    %        str2double(hObject.String) returns contents of edit_TopClipper as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_TopClipper_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_TopClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
    
function edit_BottomClipper_Callback(hObject, ~, handles)
    % hObject    handle to edit_BottomClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: hObject.String returns contents of edit_BottomClipper as text
    %        str2double(hObject.String) returns contents of edit_BottomClipper as a double
    
    
% --- Executes during object creation, after setting all properties.
function edit_BottomClipper_CreateFcn(hObject, ~, handles)
    % hObject    handle to edit_BottomClipper (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
    
% --- Executes on button press in check_Sound.
function check_Sound_Callback(hObject, ~, handles)
    % hObject    handle to check_Sound (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of check_Sound
    
    
% --- Executes on button press in check_TopPlot.
function check_TopPlot_Callback(hObject, ~, handles)
    % hObject    handle to check_TopPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of check_TopPlot
    
    
% --- Executes on button press in check_BottomPlot.
function check_BottomPlot_Callback(hObject, ~, handles)
    % hObject    handle to check_BottomPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of check_BottomPlot
    
    
    
    
% --- Executes on button press in push_SoundOptions.
function push_SoundOptions_Callback(hObject, ~, handles)
    % hObject    handle to push_SoundOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_SoundOptions.UIContextMenu = handles.context_SoundOptions;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    end
    
    
% --------------------------------------------------------------------
function menu_EventsDisplay1_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventsDisplay1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_EventsDisplay2_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventsDisplay2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    
    
% --------------------------------------------------------------------
function menu_SelectionParameters1_Callback(hObject, ~, handles)
    % hObject    handle to menu_SelectionParameters1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SelectionParameters(handles,1);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_SelectionParameters2_Callback(hObject, ~, handles)
    % hObject    handle to menu_SelectionParameters2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SelectionParameters(handles,2);
    
    guidata(hObject, handles);
    
    
function handles = SelectionParameters(handles,axnum)
    
    answer = inputdlg({'Search before (ms)','Search after (ms)'},'Selection parameteres',1,{num2str(handles.SearchBefore(axnum)*1000),num2str(handles.SearchAfter(axnum)*1000)});
    if isempty(answer)
        return
    end
    
    handles.SearchBefore(axnum) = str2double(answer{1})/1000;
    handles.SearchAfter(axnum) = str2double(answer{2})/1000;
    
% --------------------------------------------------------------------
function menu_ViewerDisplay_Callback(hObject, ~, handles)
    % hObject    handle to menu_ViewerDisplay (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
        
% --------------------------------------------------------------------
function menu_DisplayValues_Callback(hObject, ~, handles)
    % hObject    handle to menu_DisplayValues (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_DisplayValues.Checked = 'on';
    handles.menu_DisplayFeatures.Checked = 'off';
    
    handles.menu_XAxis.Enable = 'off';
    handles.menu_YAxis.Enable = 'off';
    
    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_DisplayFeatures_Callback(hObject, ~, handles)
    % hObject    handle to menu_DisplayFeatures (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_DisplayValues.Checked = 'off';
    handles.menu_DisplayFeatures.Checked = 'on';
    
    handles.menu_XAxis.Enable = 'on';
    handles.menu_YAxis.Enable = 'on';
    
    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);
    
    
% % --- Executes on button press in push_DisplayEvents.
% function push_DisplayEvents_Callback(hObject, ~, handles)
%     % hObject    handle to push_DisplayEvents (see GCBO)
%     % eventdata  reserved - to be defined in a future version of MATLAB
%     % handles    structure with handles and user data (see GUIDATA)
%     
%     handles = UpdateEventViewer(handles);
%     
%     guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AutoDisplayEvents_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoDisplayEvents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_AutoDisplayEvents.Checked
        handles.menu_AutoDisplayEvents.Checked = 'off';
    else
        handles.menu_AutoDisplayEvents.Checked = 'on';
        handles = UpdateEventViewer(handles);
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EventsAxisLimits_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventsAxisLimits (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    v = handles.popup_EventListAlign.Value;
    answer = inputdlg({'Min (ms)','Max (ms)'},'Set limits',1,{num2str(-handles.EventXLims(v,1)*1000),num2str(handles.EventXLims(v,2)*1000)});
    if isempty(answer)
        return
    end
    handles.EventXLims(v,:) = [-str2double(answer{1})/1000, str2double(answer{2})/1000];
    
    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function context_SoundOptions_Callback(hObject, ~, handles)
    % hObject    handle to context_SoundOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    
    
% --------------------------------------------------------------------
function menu_SoundWeights_Callback(hObject, ~, handles)
    % hObject    handle to menu_SoundWeights (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Sound','Top plot','Bottom plot'},'Sound weights',1,{num2str(handles.SoundWeights(1)),num2str(handles.SoundWeights(2)),num2str(handles.SoundWeights(3))});
    if isempty(answer)
        return
    end
    handles.SoundWeights = [str2double(answer{1}), str2double(answer{2}), str2double(answer{3})];
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SoundClippers_Callback(hObject, ~, handles)
    % hObject    handle to menu_SoundClippers (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Top plot','Bottom plot'},'Sound clippers',1,{num2str(handles.SoundClippers(1)),num2str(handles.SoundClippers(2))});
    if isempty(answer)
        return
    end
    handles.SoundClippers = [str2double(answer{1}), str2double(answer{2})];
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_PlaySpeed_Callback(hObject, ~, handles)
    % hObject    handle to menu_PlaySpeed (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    answer = inputdlg({'Playback speed (relative to normal)'},'Play speed',1,{num2str(handles.SoundSpeed)});
    if isempty(answer)
        return
    end
    handles.SoundSpeed = str2double(answer{1});
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_ProgressBar_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressBar (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_ProgressSoundWave_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressSoundWave (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ProgressSonogram_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressSonogram (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ProgressSegments_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressSegments (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ProgressAmplitude_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressAmplitude (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ProgressTop_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressTop (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ProgressBottom_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressBottom (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ChangeProgress(handles,hObject);
    guidata(hObject, handles);
    
function handles = ChangeProgress(handles,obj)
    
    if strcmp(obj.Checked,'off')
        obj.Checked = 'on';
    else
        obj.Checked = 'off';
    end
    
% --------------------------------------------------------------------
function menu_XAxis_Callback(hObject, ~, handles)
    % hObject    handle to menu_XAxis (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_Yaxis_Callback(hObject, ~, handles)
    % hObject    handle to menu_Yaxis (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
% --------------------------------------------------------------------
function menu_YAxis_Callback(hObject, ~, handles)
    % hObject    handle to menu_YAxis (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
function XAxisMenuClick(hObject, ~, handles)
    
    handles.menu_XAxis_List.Checked = 'off';
    hObject.Checked = 'on';
    
    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);
    
function YAxisMenuClick(hObject, ~, handles)
    
    handles.menu_YAxis_List.Checked = 'off';
    hObject.Checked = 'on';
    
    handles = UpdateEventViewer(handles);
    
    guidata(hObject, handles);
    
% --- Executes on selection change in popup_Export.
function popup_Export_Callback(hObject, ~, handles)
    % hObject    handle to popup_Export (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_Export contents as cell array
    %        contents{hObject.Value} returns selected item from popup_Export
    
    radiohands = [handles.radio_Matlab handles.radio_PowerPoint handles.radio_Files handles.radio_Clipboard];
    
    str = handles.popup_Export.String;
    val = handles.popup_Export.Value;
    str = str{val};
    switch str
        case 'Sonogram'
            val = [1 1 1 1];
        case 'Figure'
            val = [0 1 0 0];
        case 'Worksheet'
            val = [1 1 0 0];
        case {'Current sound','Sound mix'}
            val = [0 1 1 0];
        case 'Segments'
            val = [0 0 1 0];
        case 'Events'
            val = [1 0 0 1];
    end
    
    states = {'off','on'};
    for c = 1:length(radiohands)
        radiohands(c).enable = states{1+val(c)};
    end
    for c = 1:length(radiohands)
        if strcmp(radiohands(c).Enable,'off') && radiohands(c).Value==1
            for d = 1:length(radiohands)
                if strcmp(radiohands(d).Enable,'on')
                    radiohands(d).Value = 1;
                end
            end
        end
    end
    
% --- Executes during object creation, after setting all properties.
function popup_Export_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_Export (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    
% --- Executes on button press in push_Export.
function push_Export_Callback(hObject, ~, handles)
    % hObject    handle to push_Export (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    txtexp = text(mean(xlim(handles.axes_Sonogram)),mean(ylim(handles.axes_Sonogram)),'Exporting...',...
        'HorizontalAlignment','center','Color','r','backgroundcolor',[1 1 1],'fontsize',14);
    drawnow
    
    tempFilename = 'eg_temp.wav';
    
    %%%
    
    [handles, sound] = eg_GetSound(handles);
    
    str = handles.popup_Export.String;
    val = handles.popup_Export.Value;
    str = str{val};
    switch str
        case 'Segments'
            path = uigetdir(handles.tempSettings.lastDirectory, 'Directory for segments');
            if ~ischar(path)
                delete(txtexp)
                return
            end
            handles.DefaultRootPath = path;
            handles.tempSettings.lastDirectory = path;
            updateTempFile(handles);
    
            filenum = getCurrentFileNum(handles);
    
            if isfield(handles,'DefaultLabels')
                labels = handles.DefaultLabels;
            else
                labels = [];
                for c = 1:length(handles.SegmentTitles{filenum})
                    labels = [labels handles.SegmentTitles{filenum}{c}];
                end
                if ~isempty(labels)
                    labels = unique(labels);
                end
                labels = ['''''' labels];
            end
    
            answer = inputdlg({'List of labels to export (leave empty for all segments, '''' = unlabeled)','File format'},'Export segments',1,{labels,handles.SegmentFileFormat});
            if isempty(answer)
                delete(txtexp)
                return
            end
            newLabel = answer{1};
            handles.SegmentFileFormat = answer{2};
    
            if ~strcmp(labels,newLabel)
                handles.DefaultLabels = newLabel;
            end
            if isempty(newLabel)
                handles = rmfield(handles,'DefaultLabels');
            end
    
            dtm = datetime(handles.text_DateAndTime.String);
            dtm.Format = 'yyyymmdd';
            sd = string(dtm);
            dtm.Format = 'HHMMSS';
            st = string(dtm);
            [~,name,~] = fileparts(handles.text_FileName.String);
            sf = name;
            for c = 1:length(handles.SegmentTitles{filenum})
                if ~isempty(strfind(newLabel,handles.SegmentTitles{filenum}{c})) || isempty(newLabel) || (isempty(handles.SegmentTitles{filenum}{c}) && contains(newLabel,''''''))
                    str = handles.SegmentFileFormat;
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
                        str = [str(1:j-1) handles.SegmentTitles{filenum}{c} str(j+2:end)];
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
    
                    wav = sound(handles.SegmentTimes{filenum}(c,1):handles.SegmentTimes{filenum}(c,2));
    
                    audiowrite(fullfile(path, [str, '.wav']), wav, handles.fs, 'BitsPerSample', 16);
                end
            end
        case 'Sonogram'
            if handles.radio_Files.Value==1
                [~, name, ~] = fileparts(handles.text_FileName.String);
                [file, path] = uiputfile([handles.DefaultRootPath '\' name '.jpg'],'Save image');
                if ~ischar(file)
                    delete(txtexp)
                    return
                end
                handles.DefaultRootPath = path;
            end
            xl = handles.axes_Sonogram.XLim;
            yl = handles.axes_Sonogram.YLim;
            fig = figure();
            set(fig,'Visible','off','Units','pixels');
            pos = get(fig,'Position');
            pos(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(xl(2)-xl(1));
            pos(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
            fig.Position = pos;
            subplot('Position',[0 0 1 1]);
            hold on
            if handles.ExportReplotSonogram == 0
                ch = findobj('Parent',handles.axes_Sonogram,'type',image);
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
                xlp = round(xl*handles.fs);
                if xlp(1)<1; xlp(1) = 1; end
    
                [handles, numSamples] = eg_GetNumSamples(handles);
    
                if xlp(2)>numSamples
                    xlp(2) = numSamples;
                end
                for c = 1:length(handles.menu_Algorithm)
                    if handles.menu_Algorithm(c).Checked
                        alg = handles.menu_Algorithm(c).Label;
                    end
                end
                eg_runPlugin(handles.plugins.spectrums, alg, handles.axes_Sonogram, ...
                    sound(xlp(1):xlp(2)), handles.fs, handles.SonogramParams);
                handles.axes_Sonogram.YDir = 'normal';
                handles.NewSlope = handles.DerivativeSlope;
                handles.DerivativeSlope = 0;
                handles = SetSonogramColors(handles);
            end
            cl = handles.axes_Sonogram.CLim;
            handles.axes_Sonogram.CLim = cl;
            col = handles.figure_Main.Colormap;
            handles.figure_Main.Colormap = col;
            axis tight;
            axis off;
    
    
        case 'Current sound'
            wav = GenerateSound(handles,'snd');
            fs = handles.fs * handles.SoundSpeed;
    
        case 'Sound mix'
            wav = GenerateSound(handles,'mix');
            fs = handles.fs * handles.SoundSpeed;
    
        case 'Events'
            if handles.radio_Matlab.Value==1
                fig = figure();
                ax = axes(fig);
                ch = handles.axes_Events.Children;
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
                    if handles.menu_DisplayFeatures.Checked && sum(col==[1 0 0])~=3
                        xs = [xs x];
                        ys = [ys y];
                    end
                end
    
                xl = handles.axes_Events.XLim;
                yl = handles.axes_Events.YLim;
                xlabel = handles.axes_Events.XLabel.String;
                ylabel = handles.axes_Events.YLabel.String;
                str = {};
                if handles.menu_DisplayFeatures.Checked
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
            elseif handles.radio_Clipboard.Value==1
                if handles.menu_DisplayFeatures.Checked
                    ch = handles.axes_Events.Children;
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
    if handles.radio_Matlab.Value==1
        switch str
            case 'Sonogram'
                fig.Units = 'inches';
                pos = fig.Position;
                pos(3) = handles.ExportSonogramWidth*(xl(2)-xl(1));
                pos(4) = handles.ExportSonogramHeight;
                fig.Position = pos;
                fig.Visible = 'on';
            case 'Worksheet'
                lst = handles.WorksheetList;
                used = handles.WorksheetUsed;
                widths = handles.WorksheetWidths;
    
                perpage = fix(0.001+(handles.WorksheetHeight - 2*handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight)/(handles.ExportSonogramHeight + handles.WorksheetVerticalInterval));
                pagenum = fix((0:length(lst)-1)/perpage)+1;
    
                for j = 1:max(pagenum)
                    fig = figure('Units','inches');
                    ud.Sounds = {};
                    ud.Fs = [];
                    bcg = axes('Position',[0 0 1 1],'Visible','off');
                    ps = fig.Position;
                    ps(3) = handles.WorksheetWidth;
                    ps(4) = handles.WorksheetHeight;
                    fig.Position = ps;
                    if handles.WorksheetIncludeTitle == 1
                        txt = text(bcg, handles.WorksheetMargin/handles.WorksheetWidth,(handles.WorksheetHeight-handles.WorksheetMargin)/handles.WorksheetHeight,handles.WorksheetTitle);
                        txt.HorizontalAlignment = 'left';
                        txt.VerticalAlignment = 'top';
                        txt.FontSize = 14;
                        txt = text(bcg, (handles.WorksheetWidth-handles.WorksheetMargin)/handles.WorksheetWidth,(handles.WorksheetHeight-handles.WorksheetMargin)/handles.WorksheetHeight,['Page ' num2str(j) '/' num2str(max(pagenum))]);
                        txt.HorizontalAlignment = 'right';
                        txt.VerticalAlignment = 'top';
                        txt.FontSize = 14;
                    end
                    f = find(pagenum==j);
                    for c = 1:length(f)
                        indx = f(c);
                        for d = 1:length(lst{indx})
                            ud.Sounds{end+1} = handles.WorksheetSounds{lst{indx}(d)};
                            ud.Fs(end+1) = handles.WorksheetFs(lst{indx}(d));
    
                            x = (handles.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + handles.WorksheetHorizontalInterval*(d-1);
                            wd = widths(lst{indx}(d));
                            y = handles.WorksheetHeight - handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight - handles.WorksheetVerticalInterval*c - handles.ExportSonogramHeight*c;
                            ax = axes('Position',[x/handles.WorksheetWidth y/handles.WorksheetHeight wd/handles.WorksheetWidth handles.ExportSonogramHeight/handles.WorksheetHeight]);
                            hold(ax, 'on');
                            for i = 1:length(handles.WorksheetMs{lst{indx}(d)})
                                p = handles.WorksheetMs{lst{indx}(d)}{i};
                                if size(p,3) == 1
                                    cl = handles.WorksheetClim{lst{indx}(d)};
                                    p = (p-cl(1))/(cl(2)-cl(1));
                                    p(p<0)=0;
                                    p(p>1)=1;
                                    p = round(p*(size(handles.WorksheetColormap{lst{indx}(d)},1)-1))+1;
                                    p1 = reshape(handles.WorksheetColormap{lst{indx}(d)}(p,1),size(p));
                                    p2 = reshape(handles.WorksheetColormap{lst{indx}(d)}(p,2),size(p));
                                    p3 = reshape(handles.WorksheetColormap{lst{indx}(d)}(p,3),size(p));
                                    p = cat(3,p1,p2,p3);
                                else
                                    ax.CLim = handles.WorksheetClim{lst{indx}(d)};
                                    fig.Colormap = handles.WorksheetColormap{lst{indx}(d)};
                                end
                                im = imagesc(ax, handles.WorksheetXs{lst{indx}(d)}{i},handles.WorksheetYs{lst{indx}(d)}{i},p);
                                if handles.ExportSonogramIncludeClip > 0
                                    im.ButtonDownFcn = ['ud=get(gcf,''UserData''); sound(ud.Sounds{' num2str(length(ud.Sounds)) '},ud.Fs(' num2str(length(ud.Fs)) '))'];
                                end
                            end
                            xlim(ax, handles.WorksheetXLims{lst{indx}(d)});
                            ylim(ax, handles.WorksheetYLims{lst{indx}(d)});
                            axis(ax, 'off');
                            if handles.ExportSonogramIncludeLabel == 1
                                fig.CurrentAxes = bcg;
                                txt = text(ax (x+wd/2)/handles.WorksheetWidth,(y+handles.ExportSonogramHeight)/handles.WorksheetHeight,string(datetime(handles.WorksheetTimes(lst{indx}(d)))));
                                txt.HorizontalAlignment = 'center';
                                txt.VerticalAlignment = 'bottom';
                            end
                        end
                    end
    
                    if handles.ExportSonogramIncludeClip > 0
                        fig.UserData = ud;
                    end
                    fig.Units = 'pixels';
                    screen_size = get(0,'screensize');
                    fig_pos = fig.Position;
                    fig.position = [(screen_size(3)-fig_pos(3))/2,(screen_size(4)-fig_pos(4))/2,fig_pos(3),fig_pos(4)];
    
                    fig.PaperOrientation = handles.WorksheetOrientation;
                    fig.PaperPositionMode = 'auto';
                end
        end
    
    elseif handles.radio_Clipboard.Value==1
        fig.Units = 'inches';
        pos = fig.Position;
        pos(3) = handles.ExportSonogramWidth*(xl(2)-xl(1));
        pos(4) = handles.ExportSonogramHeight;
        fig.Position = pos;
        fig.PaperPositionMode = 'manual';
        fig.Renderer = 'painters'; %#ok<*FGREN> 
    
        print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportSonogramResolution)]);
        delete(fig)
    
    elseif handles.radio_Files.Value==1
        switch str
            case 'Sonogram'
                fig.Units = 'inches';
                pos = fig.Position;
                pos(3) = handles.ExportSonogramWidth*(xl(2)-xl(1));
                pos(4) = handles.ExportSonogramHeight;
                fig.Position = pos;
                fig.PaperPositionMode = 'auto';
    
                print('-djpeg',['-f' num2str(fig)],[path file],['-r' num2str(handles.ExportSonogramResolution)]);
    
                delete(fig);
    
            case {'Current sound', 'Sound mix'}
                [~,name,~] = fileparts(handles.text_FileName.String);
                [file, path] = uiputfile([handles.DefaultRootPath '\' name '.wav'],'Save sound');
                if ~ischar(file)
                    delete(txtexp)
                    return
                end
                handles.DefaultRootPath = path;
    
                audiowrite(fullfile(path, file), wav, handles.fs, 'BitsPerSample', 16);
        end
    
    elseif handles.radio_PowerPoint.Value==1
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
    
        switch str
            case 'Sonogram'
                set(fig,'PaperPositionMode','manual','Renderer','painters')
                print('-dmeta',['-f' num2str(fig)]);
                pic = invoke(newslide.Shapes,'PasteSpecial',2);
                ug = invoke(pic,'Ungroup');
                ug.Fill.Visible = 'msoFalse';
                set(ug,'Height',72*handles.ExportSonogramHeight,'Width',72*handles.ExportSonogramWidth*(xl(2)-xl(1)));
    
                if handles.ExportSonogramIncludeClip > 0
                    wav = GenerateSound(handles,'snd');
                    fs = handles.fs * handles.SoundSpeed;
    
                    audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);
    
                    snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                    snd.Left = ug.Left;
                    snd.Top = ug.Top;
                    mt = dir(f.UserData.ax);
                    delete(mt(1).name);
                end
    
                if handles.ExportSonogramIncludeLabel == 1
                    txt = addWorksheetTextBox(handles, newslide, handles.text_DateAndTime.String, 8, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
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
    
                if handles.ExportSonogramIncludeLabel == 1
                    txt = addWorksheetTextBox(handles, newslide,  handles.text_DateAndTime.String, 8, snd.Left+snd.Width, [], [], 'msoAnchorMiddle');
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
    
                offx = (op.PageSetup.SlideWidth-72*handles.WorksheetWidth)/2;
                offy = (op.PageSetup.SlideHeight-72*handles.WorksheetHeight)/2;
    
                lst = handles.WorksheetList;
                used = handles.WorksheetUsed;
                widths = handles.WorksheetWidths;
    
                perpage = fix(0.001+(handles.WorksheetHeight - 2*handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight)/(handles.ExportSonogramHeight + handles.WorksheetVerticalInterval));
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
                    if handles.WorksheetIncludeTitle == 1
                        addWorksheetTextBox(handles, newslide, handles.WorksheetTitle, 14, 72*handles.WorksheetMargin+offx, 72*handles.WorksheetMargin+offy, [], 'msoAnchorTop');
                        txt = addWorksheetTextBox(handles, newslide, ['Page ' num2str(j) '/' num2str(max(pagenum))], 14, [], 72*handles.WorksheetMargin+offy, [], 'msoAnchorTop');
                        txt.Left = 72*(handles.WorksheetWidth-handles.WorksheetMargin-txt.Width+offx);
                    end
    
                    f = find(pagenum==j);
                    for c = 1:length(f)
                        indx = f(c);
    
                        for d = 1:length(lst{indx})
                            cla(ax);
                            hold(ax, 'on');
                            ps = fig.Position;
                            ps(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(handles.WorksheetXLims{lst{indx}(d)}(2)-handles.WorksheetXLims{lst{indx}(d)}(1));
                            ps(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
                            fig.Position = ps;
    
                            x = (handles.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + handles.WorksheetHorizontalInterval*(d-1);
                            wd = widths(lst{indx}(d));
                            y = handles.WorksheetMargin + handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight + handles.WorksheetVerticalInterval*(c-1) + handles.ExportSonogramHeight*(c-1);
    
                            for i = 1:length(handles.WorksheetMs{lst{indx}(d)})
                                p = handles.WorksheetMs{lst{indx}(d)}{i};
                                imagesc(ax, handles.WorksheetXs{lst{indx}(d)}{i},handles.WorksheetYs{lst{indx}(d)}{i},p);
                                ax.CLim = handles.WorksheetClim{lst{indx}(d)};
                                fig.Colormap = handles.WorksheetColormap{lst{indx}(d)};
                            end
                            xlim(ax, handles.WorksheetXLims{lst{indx}(d)});
                            ylim(ax, handles.WorksheetYLims{lst{indx}(d)});
    
                            print('-dmeta',['-f' num2str(fig)]);
                            pic = invoke(newslide.Shapes,'PasteSpecial',2);
                            ug = invoke(pic,'Ungroup');
                            ug.Fill.Visible = 'msoFalse';
                            ug.Height = 72*handles.ExportSonogramHeight;
                            ug.Width = 72*handles.ExportSonogramWidth*(handles.WorksheetXLims{lst{indx}(d)}(2)-handles.WorksheetXLims{lst{indx}(d)}(1));
                            ug.Left = 72*x+offx;
                            ug.Top = 72*(y+handles.WorksheetVerticalInterval)+offy;
    
                            if handles.ExportSonogramIncludeLabel == 1
                                txt = addWorksheetTextBox(handles, newslide, string(datetime(handles.WorksheetTimes(lst{indx}(d)))), 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
                                txt.Left = 72*(x+wd/2-txt.Width/2+offx);
                                txt.Top = 72*(y+handles.WorksheetVerticalInterval-txt.Height+offy);
                            end
    
                            if handles.ExportSonogramIncludeClip > 0
                                wav = handles.WorksheetSounds{lst{indx}(d)};
                                fs = handles.WorksheetFs(lst{indx}(d));
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
                handles.template = handles.menu_EditFigureTemplate.UserData;
    
                ppt = actxserver('PowerPoint.Application');
                op = ppt.ActivePresentation;
    
                fig = figure('Visible','off','Units','pixels');
                fig.PaperPositionMode = 'manual';
                fig.Renderer = 'painters';
                ax = subplot('Position',[0 0 1 1]);
    
                xl = handles.axes_Sonogram.XLim;
    
                offx = (op.PageSetup.SlideWidth-72*handles.ExportSonogramWidth*(xl(2)-xl(1)))/2;
                offy = (op.PageSetup.SlideHeight-72*(sum(handles.template.Height)+sum(handles.template.Interval(1:end-1))))/2;
    
                sound_inserted = 0;
    
                ch = handles.menu_ProgressBar.Children;
                progbar = [];
                axs = [handles.axes_Channel2 handles.axes_Channel1 handles.axes_Amplitude handles.axes_Segments handles.axes_Sonogram handles.axes_Sound];
                for c = 1:length(ch)
                    if ch(c).Checked && axs(c).Visible
                        progbar = [progbar c];
                    end
                end
                ycoord = zeros(0,4);
                coords = {};
    
                for c = 1:length(handles.template.Plot)
                    ps = fig.Position;
                    ps(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(xl(2)-xl(1));
                    ps(4) = handles.ExportSonogramResolution*handles.template.Height(c);
                    fig.Position = ps;
    
                    cla(ax);
    
                    include_progbar = 0;
    
                    switch handles.template.Plot{c}
    
                        case 'Sonogram'
                            if ~isempty(find(progbar==5, 1))
                                include_progbar = 1;
                            end
    
                            yl = handles.axes_Sonogram.YLim;
    
                            hold(ax, 'on');
                            if handles.ExportReplotSonogram == 0
                                ch = findobj('Parent',handles.axes_Sonogram,'type','image');
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
                                xlp = round(xl*handles.fs);
                                if xlp(1)<1; xlp(1) = 1; end
                                [handles, numSamples] = eg_GetNumSamples(handles);
    
                                if xlp(2)>numSamples; xlp(2) = numSamples; end
                                for j = 1:length(handles.menu_Algorithm)
                                    if handles.menu_Algorithm(j).Checked
                                        alg = handles.menu_Algorithm(j).Label;
                                    end
                                end
                                eg_runPlugin(handles.plugins.spectrums, ...
                                    alg, ax, sound(xlp(1):xlp(2)), ...
                                    handles.fs, handles.SonogramParams);
                                ax.YDir = 'normal';
                                handles.NewSlope = handles.DerivativeSlope;
                                handles.DerivativeSlope = 0;
                                handles = SetSonogramColors(handles);
                            end
                            cl = handles.axes_Sonogram.CLim;
                            ax.CLim = cl;
                            col = handles.figure_Main.Colormap;
                            fig.Colormap = col;
                            axis(ax, 'tight');
                            axis(ax, 'off');
    
                        case 'Segments'
                            if ~isempty(find(progbar==4, 1))
                                include_progbar = 1;
                            end
    
                            st = handles.SegmentTimes{getCurrentFileNum(handles)};
                            sel = handles.SegmentSelection{getCurrentFileNum(handles)};
                            f = find(st(:,1)>xl(1)*handles.fs & st(:,1)<xl(2)*handles.fs);
                            g = find(st(:,2)>xl(1)*handles.fs & st(:,2)<xl(2)*handles.fs);
                            h = find(st(:,1)<xl(1)*handles.fs & st(:,2)>xl(2)*handles.fs);
                            f = unique([f; g; h]);
    
                            hold(ax, 'on');
                            [handles, numSamples] = eg_GetNumSamples(handles);
    
                            xs = linspace(0, numSamples/handles.fs, numSamples);
                            for j = f'
                                if sel(j)==1
                                    patch(xs([st(j,1) st(j,2) st(j,2) st(j,1)]),[0 0 1 1],handles.SegmentSelectColor);
                                end
                            end
    
                            ylim(ax, [0, 1]);
                            axis(ax, 'off');
    
                        case 'Segment labels'
                            st = handles.SegmentTimes{getCurrentFileNum(handles)};
                            sel = handles.SegmentSelection{getCurrentFileNum(handles)};
                            lab = handles.SegmentTitles{getCurrentFileNum(handles)};
                            f = find(st(:,1)>xl(1)*handles.fs & st(:,1)<xl(2)*handles.fs);
                            g = find(st(:,2)>xl(1)*handles.fs & st(:,2)<xl(2)*handles.fs);
                            h = find(st(:,1)<xl(1)*handles.fs & st(:,2)>xl(2)*handles.fs);
                            f = unique([f; g; h]);
    
                            hold(ax, 'on');
                            [handles, numSamples] = eg_GetNumSamples(handles);
    
                            xs = linspace(0, numSamples/handles.fs, numSamples);
                            for j = f'
                                if sel(j)==1
                                    if ~isempty(lab{j})
                                        txt = addWorksheetTextBox(handles, newslide, lab{j}, 8, [], [], 'msoAnchorCenter', 'msoAnchorBottom');
                                        txt.Left = offx+72*handles.ExportSonogramWidth*mean(xs(st(j,:))-xl(1))-txt.Width/2;
                                        txt.Top = offy+72*(sum(handles.template.Interval(1:c-1)+sum(handles.template.Height(1:c-1))));
                                    end
                                end
                            end
    
                            axis(ax, 'off');
    
                        case 'Amplitude'
                            if ~isempty(find(progbar==3, 1))
                                include_progbar = 1;
                            end
    
                            m = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
                            x = m.XData;
                            y = m.YData;
                            col = m.Color;
                            linewidth = m.LineWidth;
                            f = find(x>=xl(1) & x<=xl(2));
                            if sum(col==1)==3
                                col = col-eps;
                            end
                            plot(ax, x(f),y(f),'Color',col);
    
                            ylim(ax, handles.axes_Amplitude.YLim);
                            ax.YDir = 'normal';
                            axis(ax, 'off');
    
                        case {'Top plot','Bottom plot'}
                            if ~isempty(find(progbar==1, 1)) && strcmp(handles.template.Plot{c},'Bottom plot')
                                include_progbar = 1;
                            end
                            if ~isempty(find(progbar==2, 1)) && strcmp(handles.template.Plot{c},'Top plot')
                                include_progbar = 1;
                            end
    
                            if strcmp(handles.template.Plot{c},'Top plot')
                                axnum = 1;
                            else
                                axnum = 2;
                            end
    
                            m = findobj('Parent',handles.axes_Channel(axnum),'LineStyle','-');
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
    
                            ylim(ax, handles.axes_Channel(axnum).YLim);
                            ax.YDir = 'normal';
                            axis(ax, 'off');
    
                        case 'Sound wave'
                            if ~isempty(find(progbar==6, 1))
                                include_progbar = 1;
                            end
    
                            m = findobj('Parent',handles.axes_Sound,'LineStyle','-');
                            hold(ax, 'on')
                            for j = 1:length(m)
                                x = m(j).XData;
                                y = m(j).YData;
                                f = find(x>=xl(1) & x<=xl(2));
                                plot(ax, x(f),y(f),'b');
                            end
                            linewidth = 1;
    
                            ylim(ax, handles.axes_Sound.YLim);
                            ax.YDir = 'normal';
                            axis(ax, 'off');
                    end
    
                    if handles.template.AutoYLimits(c)==1
                        axis tight;
                    end
                    yl = ylim;
                    xlim(xl);
    
    
                    if ~strcmp(handles.template.Plot{c},'Segment labels')
                        print('-dmeta',['-f' num2str(fig)]);
                        pic = invoke(newslide.Shapes,'PasteSpecial',2);
                        ug = invoke(pic,'Ungroup');
                        ug.Height = 72*handles.template.Height(c);
                        ug.Width = 72*handles.ExportSonogramWidth*(xl(2-xl(1)));
                        ug.Left = offx;
                        ug.Top = offy+72*(sum(handles.template.Interval(1:c-1))+sum(handles.template.Height(1:c-1)));
    
                        switch handles.template.YScaleType(c)
                            case 0
                                % no scale bar
                            case 1 % scalebar
                                approx = handles.ScalebarHeight/handles.template.Height(c)*(yl(2)-yl(1));
                                ord = floor(log10(approx));
                                val = approx/10^ord;
                                if ord == 0
                                    pres = [1 2 3 4 5 10];
                                else
                                    pres = [1 2 2.5 3 4 5 10];
                                end
                                [~, fnd] = min(abs(pres-val));
                                val = pres(fnd)*10^ord;
                                sb_height = 72*val/(yl(2)-yl(1))*handles.template.Height(c);
    
                                unit = '';
                                switch handles.template.Plot{c}
                                    case 'Sonogram'
                                        unit = ' kHz';
                                        val = val/1000;
                                    case 'Amplitude'
                                        txt = handles.axes_Amplitude.YLabel.String;
                                        fnd2 = strfind(txt,')');
                                        if ~isempty(fnd2)
                                            fnd1 = strfind(txt(1:fnd2(end)),'(');
                                            if ~isempty(fnd1)
                                                unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                            end
                                        end
                                    case 'Top plot'
                                        txt = handles.axes_Channel1.YLabel.String;
                                        fnd2 = strfind(txt,')');
                                        if ~isempty(fnd2)
                                            fnd1 = strfind(txt(1:fnd2(end)),'(');
                                            if ~isempty(fnd1)
                                                unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                            end
                                        end
                                    case 'Bottom plot'
                                        txt = handles.axes_Channel2.YLabel.String;
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
    
                                if handles.VerticalScalebarPosition <= 0
                                    sb_posx = offx + 72*handles.VerticalScalebarPosition;
                                else
                                    sb_posx = offx + 72*(handles.ExportSonogramWidth*(xl(2)-xl(1))+handles.VerticalScalebarPosition);
                                end
                                invoke(newslide.Shapes,'AddLine',sb_posx,sb_posy,sb_posx,sb_posy+sb_height);
    
                                txt = addWorksheetTextBox(handles, newslide, [num2str(val) unit], 8, [], [], [], 'msoAnchorMiddle');
                                if handles.VerticalScalebarPosition <= 0
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
                                ps(4) = handles.template.Height(c);
                                fig_yscale.Position = ps;
                                ax = subplot('Position',[0 0 1 1]);
                                ylim(ax, [yl(1) yl(2)]);
                                ytick = ax.YTick;
                                delete(fig_yscale);
    
                                switch handles.template.Plot{c}
                                    case 'Sonogram'
                                        str = handles.axes_Sonogram.YLabel.String;
                                    case 'Amplitude'
                                        str = handles.axes_Amplitude.YLabel.String;
                                    case 'Top plot'
                                        str = handles.axes_Channel1.YLabel.String;
                                    case 'Bottom plot'
                                        str = handles.axes_Channel2.YLabel.String;
                                    case 'Sound wave'
                                        str = 'Sound amplitude (ADU)';
                                end
    
                                mn = inf;
                                for j = 1:length(ytick')
                                    tickpos = ug.Top+ug.Height-(ytick(j)-yl(1))/(yl(2)-yl(1))*ug.Height;
                                    invoke(newslide.Shapes,'AddLine',offx,tickpos,offx+72*0.02,tickpos);
    
                                    txt = addWorksheetTextBox(handles, newslide, num2str(ytick(j)), 8, [], [], [], 'msoAnchorMiddle', 'ppAlignRight');
                                    txt.Left = offx-txt.Width-72*0.02;
                                    txt.Top = tickpos-0.5*txt.Height;
                                    mn = min([mn, txt.Left]);
                                end
    
    %                             if strcmp(handles.template.Plot{c},'Sonogram')
    %                                 ytick = ytick/1000;
    %                             end
    
                                addWorksheetTextBox(handles, newslide, str, 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom', 'ppAlignCenter', 270);
                                txt.Left = mn-0.5*txt.Width-72*0.15;
                                txt.Top = ug.Top+0.5*ug.Height-0.5*txt.Height;
                        end
    
                        if include_progbar == 1
                            ycoord = [ycoord; ug.Left ug.Top ug.Width ug.Height];
                            switch handles.template.Plot{c}
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
                                    ch = findobj('Parent',handles.axes_Sonogram,'type','image');
                                    crd = [];
                                    for j = 1:length(ch)
                                        if ch(j) ~= txtexp
                                            x = ch(j).XData;
                                            y = ch(j).YData;
                                            m = ch(j).CData;
                                            f = find(x>=xl(1) & x<=xl(2));
                                            g = find(y>=yl(1) & y<=yl(2));
                                            if handles.SonogramFollowerPower == inf
                                                [~, wh] = max(m(g,f),[],1);
                                                crd = [crd; x(f)' y(g(wh))'];
                                            else
                                                crd = [crd; x(f)' ((y(g)*abs(m(g,f)).^handles.SonogramFollowerPower)./sum(abs(m(g,f)).^handles.SonogramFollowerPower,1))'];
                                            end
                                        end
                                    end
                                    crd(:,1) = (crd(:,1)-xl(1))/(xl(2)-xl(1));
                                    crd(:,2) = (crd(:,2)-yl(1))/(yl(2)-yl(1));
                            end
                            crd(:,1) = crd(:,1)*ycoord(end,3)/op.PageSetup.SlideWidth;
                            crd(:,2) = -crd(:,2)*ycoord(end,4)/op.PageSetup.SlideHeight;
                            crd = sortrows(crd);
    
                            if handles.menu_PlayReverse.Checked
                                crd(:,1) = flipud(crd(:,1))-crd(end,1);
                                crd(:,2) = flipud(crd(:,2));
                            end
    
                            vals = [];
                            if ~strcmp(handles.template.Plot{c},'Segments')
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
    
                        if strcmp(handles.template.Plot{c},'Sonogram') && handles.ExportSonogramIncludeClip > 0
                            if handles.ExportSonogramIncludeClip == 1
                                wav = GenerateSound(handles,'snd');
                            else
                                wav = GenerateSound(handles,'mix');
                            end
                            fs = handles.fs * handles.SoundSpeed;
    
                            audiowrite(f.UserData.ax, wav, fs, 'BitsPerSample', 16);
    
                            snd = invoke(newslide.Shapes,'AddMediaObject', fullfile(pwd, tempFilename));
                            snd.Left = ug.Left;
                            snd.Top = ug.Top;
                            mt = dir(f.UserData.ax);
                            delete(mt(1).name);
                            sound_inserted = 1;
                        end
    
                        ug = invoke(ug,'Ungroup');
                        if ~strcmp(handles.template.Plot{c},'Segments')
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
    
                if handles.ExportSonogramIncludeLabel == 1
                    dt = datevec(handles.text_DateAndTime.String);
                    dt(6) = dt(6)+xl(1);
                    addWorksheetTextBox(handles, newslide, string(datetime(dt)), 10, [], [], 'msoAnchorCenter', 'msoAnchorBottom', 'ppAlignCenter');
                    txt.Left = op.PageSetup.SlideWidth-txt.Width/2;
                    txt.Top = offy-txt.Height;
                end
    
                if sound_inserted == 0 && handles.ExportSonogramIncludeClip > 0
                    if handles.ExportSonogramIncludeClip == 1
                        wav = GenerateSound(handles,'snd');
                    else
                        wav = GenerateSound(handles,'mix');
                    end
                    fs = handles.fs * handles.SoundSpeed;
    
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
    
                    animopt = findobj('Parent',handles.menu_Animation,'Checked','on');
                    animopt = animopt.Label;
    
                    if ~strcmp(animopt,'None')
                        for c = 1:size(ycoord,1)
                            if handles.menu_PlayReverse.Checked
                                ycoord(c,1) = ycoord(c,1)+ycoord(c,3);
                                ycoord(c,3) = -ycoord(c,3);
                            end
    
                            col = handles.ProgressBarColor;
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
    
                bestlength = handles.ScalebarWidth/handles.ExportSonogramWidth;
                errs = abs(handles.ScalebarPresets-bestlength);
                [~, j] = min(errs);
                y = offy+72*(sum(handles.template.Height)+sum(handles.template.Interval));
                x2 = op.PageSetup.SlideWidth-offx;
                x1 = x2-72*handles.ScalebarPresets(j)*handles.ExportSonogramWidth;
                invoke(newslide.Shapes,'AddLine',x1,y,x2,y);
                txt = addWorksheetTextBox(handles, newslide, handles.ScalebarLabels{j}, 8, [], y, 'msoAnchorCenter', 'msoAnchorTop', 'ppAlignCenter');
                txt.Left = (x1+x2/2-txt.Width/2);
        end
    end
    
    delete(txtexp);
    guidata(hObject, handles);
    
% --- Executes on button press in push_ExportOptions.
function push_ExportOptions_Callback(hObject, ~, handles)
    % hObject    handle to push_ExportOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_ExportOptions.UIContextMenu = handles.context_ExportOptions;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    end
    
% --- Executes on button press in radio_Matlab.
function radio_Matlab_Callback(hObject, ~, handles)
    % hObject    handle to radio_Matlab (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of radio_Matlab
    
% --- Executes on button press in radio_PowerPoint.
function radio_PowerPoint_Callback(hObject, ~, handles)
    % hObject    handle to radio_PowerPoint (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of radio_PowerPoint
    
% --- Executes on button press in radio_Files.
function radio_Files_Callback(hObject, ~, handles)
    % hObject    handle to radio_Files (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of radio_Files
    
% --- Executes on button press in radio_Clipboard.
function radio_Clipboard_Callback(hObject, ~, handles)
    % hObject    handle to radio_Clipboard (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of radio_Clipboard
    
% --- Executes on button press in push_UpdateFileList.
function push_UpdateFileList_Callback(hObject, ~, handles)
    % hObject    handle to push_UpdateFileList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_UpdateFileList.UIContextMenu = handles.context_UpdateList;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    end
    
function txt = addWorksheetTextBox(handles, newslide, text, fontSize, x, y, horizontalAnchor, verticalAnchor, paragraphAlignment, rotation)
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

% --- Executes on button press in push_WorksheetAppend.
function push_WorksheetAppend_Callback(hObject, ~, handles)
    % hObject    handle to push_WorksheetAppend (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    xl = handles.axes_Sonogram.XLim;
    yl = handles.axes_Sonogram.YLim;
    fig = figure;
    fig.Visible = 'off';
    fig.Units = 'pixels';
    pos = fig.Position;
    pos(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(xl(2)-xl(1));
    pos(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
    fig.Position = pos;
    ax = subplot('Position',[0 0 1 1]);
    hold(ax, 'on');
    xs = {};
    ys = {};
    ms = {};
    if handles.ExportReplotSonogram == 0
        ch = findobj('Parent',handles.axes_Sonogram,'type','image');
        for c = 1:length(ch)
            x = ch(c).XData;
            y = ch(c).YData;
            m = ch(c).CData;
            f = find(x>=xl(1) & x<=xl(2));
            g = find(y>=yl(1) & y<=yl(2));
            xs{end+1} = x(f);
            ys{end+1} = y(g);
            ms{end+1} = m(g,f);
        end
    else
        xlim(ax, xl);
        ylim(ax, yl);
        xlp = round(xl*handles.fs);
        if xlp(1)<1; xlp(1) = 1; end
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        if xlp(2)>numSamples; xlp(2) = numSamples; end
        for c = 1:length(handles.menu_Algorithm)
            if handles.menu_Algorithm(c).Checked
                alg = handles.menu_Algorithm(c).Label;
            end
        end
    
        [handles, sound] = eg_GetSound(handles);
    
        eg_runPlugin(handles.plugins.spectrums, alg, ax, ...
            sound(xlp(1):xlp(2)), handles.fs, handles.SonogramParams);
        ax.YDir = 'normal';
        handles.NewSlope = handles.DerivativeSlope;
        handles.DerivativeSlope = 0;
        handles = SetSonogramColors(handles);
        ch = ax.Children;
        for c = 1:length(ch)
            x = ch(c).XData;
            y = ch(c).YData;
            m = ch(c).CData;
            f = find(x>=xl(1) & x<=xl(2));
            g = find(y>=yl(1) & y<=yl(2));
            xs{end+1} = x(f);
            ys{end+1} = y(g);
            ms{end+1} = m(g,f);
        end
    end
    
    delete(fig);
    
    wav = GenerateSound(handles,'snd');
    fs = handles.fs * handles.SoundSpeed;
    
    handles.WorksheetXLims{end+1} = xl;
    handles.WorksheetYLims{end+1} = yl;
    handles.WorksheetXs{end+1} = xs;
    handles.WorksheetYs{end+1} = ys;
    handles.WorksheetMs{end+1} = ms;
    handles.WorksheetClim{end+1} = handles.axes_Sonogram.CLim;
    handles.WorksheetColormap{end+1} = handles.figure_Main.Colormap;
    handles.WorksheetSounds{end+1} = wav;
    handles.WorksheetFs(end+1) = fs;
    dt = datetime(handles.text_DateAndTime.String);
    xd = handles.axes_Sonogram.XLim;
    dt = dt + seconds(xd(1));
    handles.WorksheetTimes(end+1) = dt;
    
    handles = UpdateWorksheet(handles);
    
    str = handles.panel_Worksheet.Title ;
    f = strfind(str,'/');
    tot = str2double(str(f+1:end));
    handles.WorksheetCurrentPage = tot;
    handles = UpdateWorksheet(handles);
    
    if length(handles.WorksheetHandles)>=length(handles.WorksheetMs)
        if ishandle(handles.WorksheetHandles(length(handles.WorksheetMs)))
            handles.WorksheetHandles(length(handles.WorksheetMs)).FaceColor = 'r';
        end
    end
    
    guidata(hObject, handles);

function handles = UpdateWorksheet(handles)
    
    max_width = handles.WorksheetWidth - 2*handles.WorksheetMargin;
    widths = [];
    for c = 1:length(handles.WorksheetXLims)
        widths(c) = (handles.WorksheetXLims{c}(2)-handles.WorksheetXLims{c}(1))*handles.ExportSonogramWidth;
    end
    
    if handles.WorksheetChronological == 1
        [~, ord] = sort(handles.WorksheetTimes);
    else
        ord = 1:length(handles.WorksheetXLims);
    end
    
    lst = [];
    used = [];
    for c = 1:length(ord)
        indx = ord(c);
        if handles.WorksheetOnePerLine == 1 || isempty(used)
            lst{end+1} = indx;
            used(end+1) = widths(indx);
        else
            if handles.WorksheetChronological == 1
                if used(end)+widths(indx) <= max_width
                    lst{end}(end+1) = indx;
                    used(end) = used(end) + widths(indx) + handles.WorksheetHorizontalInterval;
                else
                    lst{end+1} = indx;
                    used(end+1) = widths(indx);
                end
            else
                f = find(used+widths(indx) <= max_width);
                if isempty(f)
                    lst{end+1} = indx;
                    used(end+1) = widths(indx);
                else
                    [~, j] = max(used(f));
                    ins = f(j(1));
                    lst{ins}(end+1) = indx;
                    used(ins) = used(ins) + widths(indx) + handles.WorksheetHorizontalInterval;
                end
            end
        end
    end
    
    handles.WorksheetList = lst;
    handles.WorksheetUsed = used;
    handles.WorksheetWidths = widths;
    
    perpage = fix(0.001+(handles.WorksheetHeight - 2*handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight)/(handles.ExportSonogramHeight + handles.WorksheetVerticalInterval));
    pagenum = fix((0:length(lst)-1)/perpage)+1;

    cla(handles.axes_Worksheet);
    patch(handles.axes_Worksheet, [0, handles.WorksheetWidth, handles.WorksheetWidth, 0], [0, 0, handles.WorksheetHeight, handles.WorksheetHeight],'w');
    hold(handles.axes_Worksheet, 'on');
    if handles.WorksheetCurrentPage > max(pagenum)
        handles.WorksheetCurrentPage = max(pagenum);
    end
    f = find(pagenum==handles.WorksheetCurrentPage);
    handles.WorksheetHandles = gobjects().empty;
    for c = 1:length(f)
        indx = f(c);
        for d = 1:length(lst{indx})
            x = (handles.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + handles.WorksheetHorizontalInterval*(d-1);
            wd = widths(lst{indx}(d));
            y = handles.WorksheetHeight - handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight - handles.WorksheetVerticalInterval*c - handles.ExportSonogramHeight*c;
            handles.WorksheetHandles(lst{indx}(d)) = patch(handles.axes_Worksheet, [x, x+wd, x+wd, x], [y, y, y+handles.ExportSonogramHeight, y+handles.ExportSonogramHeight], [.5, .5, .5]);
        end
    end
    
    for k = 1:length(handles.WorksheetHandles)
        handles.WorksheetHandles(k).ButtonDownFcn = @click_Worksheet;
        handles.WorksheetHandles(k).UIContextMenu = handles.context_Worksheet;
    end
    
    axis(handles.axes_Worksheet, 'equal');
    axis(handles.axes_Worksheet, 'tight');
    axis(handles.axes_Worksheet, 'off');
    
    handles.panel_Worksheet.Title = ['Worksheet: Page ' num2str(handles.WorksheetCurrentPage) '/' num2str(max([1 max(pagenum)]))];
    
function click_Worksheet(hObject, ~, handles)
    
    ch = handles.axes_Worksheet.Children;
    for c = 1:length(ch)
        if sum(ch(c).FaceColor==[1 1 1])<3
            ch(c).FaceColor = [.5 .5 .5];
        end
    end
    hObject.FaceColor = 'r';
    
    if strcmp(handles.figure_Main.SelectionType,'open')
        ViewWorksheet(handles);
    end
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_WorksheetOptions.
function push_WorksheetOptions_Callback(hObject, ~, handles)
    % hObject    handle to push_WorksheetOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_WorksheetOptions.UIContextMenu = handles.context_WorksheetOptions;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    end
    
    
% --- Executes on button press in push_PageLeft.
function push_PageLeft_Callback(hObject, ~, handles)
    % hObject    handle to push_PageLeft (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = handles.panel_Worksheet.Title ;
    f = strfind(str,'/');
    tot = str2double(str(f+1:end));
    
    handles.WorksheetCurrentPage = mod(handles.WorksheetCurrentPage-1,tot);
    if handles.WorksheetCurrentPage == 0
        handles.WorksheetCurrentPage = tot;
    end
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_PageRight.
function push_PageRight_Callback(hObject, ~, handles)
    % hObject    handle to push_PageRight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = handles.panel_Worksheet.Title ;
    f = strfind(str,'/');
    tot = str2double(str(f+1:end));
    
    handles.WorksheetCurrentPage = mod(handles.WorksheetCurrentPage+1,tot);
    if handles.WorksheetCurrentPage == 0
        handles.WorksheetCurrentPage = tot;
    end
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_FrequencyZoom_Callback(hObject, ~, handles)
    % hObject    handle to menu_FrequencyZoom (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_FrequencyZoom.Checked
        handles.menu_FrequencyZoom.Checked = 'off';
    else
        handles.menu_FrequencyZoom.Checked = 'on';
    end
    
    
% --------------------------------------------------------------------
function context_Worksheet_Callback(hObject, ~, handles)
    % hObject    handle to context_Worksheet (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_WorksheetDelete_Callback(hObject, ~, handles)
    % hObject    handle to menu_WorksheetDelete (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    f = find(handles.WorksheetHandles==findobj('Parent',handles.axes_Worksheet,'FaceColor','r'));
    
    handles.WorksheetXLims(f) = [];
    handles.WorksheetYLims(f) = [];
    handles.WorksheetXs(f) = [];
    handles.WorksheetYs(f) = [];
    handles.WorksheetMs(f) = [];
    handles.WorksheetClim(f) = [];
    handles.WorksheetColormap(f) = [];
    handles.WorksheetSounds(f) = [];
    handles.WorksheetFs(f) = [];
    handles.WorksheetTimes(f) = [];
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SortChronologically_Callback(hObject, ~, handles)
    % hObject    handle to menu_SortChronologically (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_SortChronologically.Checked
        handles.menu_SortChronologically.Checked = 'off';
        handles.WorksheetChronological = 0;
    else
        handles.menu_SortChronologically.Checked = 'on';
        handles.WorksheetChronological = 1;
    end
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function context_WorksheetOptions_Callback(hObject, ~, handles)
    % hObject    handle to context_WorksheetOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_OnePerLine_Callback(hObject, ~, handles)
    % hObject    handle to menu_OnePerLine (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_OnePerLine.Checked
        handles.menu_OnePerLine.Checked = 'off';
        handles.WorksheetOnePerLine = 0;
    else
        handles.menu_OnePerLine.Checked = 'on';
        handles.WorksheetOnePerLine = 1;
    end
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_IncludeTitle_Callback(hObject, ~, handles)
    % hObject    handle to menu_IncludeTitle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_IncludeTitle.Checked
        handles.menu_IncludeTitle.Checked = 'off';
        handles.WorksheetIncludeTitle = 0;
    else
        handles.menu_IncludeTitle.Checked = 'on';
        handles.WorksheetIncludeTitle = 1;
    end
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EditTitle_Callback(hObject, ~, handles)
    % hObject    handle to menu_EditTitle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Worksheet title'},'Title',1,{handles.WorksheetTitle});
    if isempty(answer)
        return
    end
    handles.WorksheetTitle = answer{1};
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_WorksheetDimensions_Callback(hObject, ~, handles)
    % hObject    handle to menu_WorksheetDimensions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Width (in)','Height (in)','Margin (in)','Title height (in)','Vertical interval (in)','Horizontal interval (in)'},'Worksheet dimensions',1,{num2str(handles.WorksheetWidth),num2str(handles.WorksheetHeight),num2str(handles.WorksheetMargin),num2str(handles.WorksheetTitleHeight),num2str(handles.WorksheetVerticalInterval),num2str(handles.WorksheetHorizontalInterval)});
    if isempty(answer)
        return
    end
    handles.WorksheetWidth = str2double(answer{1});
    handles.WorksheetHeight = str2double(answer{2});
    handles.WorksheetMargin = str2double(answer{3});
    handles.WorksheetTitleHeight = str2double(answer{4});
    handles.WorksheetVerticalInterval = str2double(answer{5});
    handles.WorksheetHorizontalInterval = str2double(answer{6});
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ClearWorksheet_Callback(hObject, ~, handles)
    % hObject    handle to menu_ClearWorksheet (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    button = questdlg('Delete all worksheet sounds?','Clear worksheet','Yes','No','No');
    if strcmp(button,'No')
        return
    end
    
    handles.WorksheetXLims = {};
    handles.WorksheetYLims = {};
    handles.WorksheetXs = {};
    handles.WorksheetYs = {};
    handles.WorksheetMs = {};
    handles.WorksheetClim = {};
    handles.WorksheetColormap = {};
    handles.WorksheetSounds = {};
    handles.WorksheetFs = [];
    handles.WorksheetTimes = [];
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function context_ExportOptions_Callback(hObject, ~, handles)
    % hObject    handle to context_ExportOptions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_SonogramDimensions_Callback(hObject, ~, handles)
    % hObject    handle to menu_SonogramDimensions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Sonogram height (in)'},'Height',1,{num2str(handles.ExportSonogramHeight)});
    if isempty(answer)
        return
    end
    handles.ExportSonogramHeight = str2double(answer{1});
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ScreenResolution_Callback(hObject, ~, handles)
    % hObject    handle to menu_ScreenResolution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_ScreenResolution.Checked = 'on';
    handles.menu_CustomResolution.Checked = 'off';
    handles.ExportReplotSonogram = 0;
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SonogramExport_Callback(hObject, ~, handles)
    % hObject    handle to menu_SonogramExport (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_CustomResolution_Callback(hObject, ~, handles)
    % hObject    handle to menu_CustomResolution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_ScreenResolution.Checked = 'off';
    handles.menu_CustomResolution.Checked = 'on';
    handles.ExportReplotSonogram = 1;
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_WorksheetView_Callback(hObject, ~, handles)
    % hObject    handle to menu_WorksheetView (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    ViewWorksheet(handles);
    
    
function ViewWorksheet(handles)
    
    f = find(handles.WorksheetHandles==findobj('Parent',handles.axes_Worksheet,'FaceColor','r'));
    
    fig = figure;
    fig.Visible = 'off';
    fig.Units = 'inches';
    pos = fig.Position;
    pos(3) = handles.ExportSonogramWidth*(handles.WorksheetXLims{f}(2)-handles.WorksheetXLims{f}(1));
    pos(4) = handles.ExportSonogramHeight;
    fig.Position = pos;
    ax = subplot('Position',[0 0 1 1]);
    hold(ax, 'on');
    for c = 1:length(handles.WorksheetMs{f})
        imagesc(ax, handles.WorksheetXs{f}{c},handles.WorksheetYs{f}{c},handles.WorksheetMs{f}{c});
    end
    ax.CLim = handles.WorksheetClim{f};
    fig.Colormap = handles.WorksheetColormap{f};
    axis(ax, 'tight');
    axis(ax, 'off');
    fig.Visible = 'on';
    
    
% --- Executes on button press in push_Macros.
function push_Macros_Callback(hObject, ~, handles)
    % hObject    handle to push_Macros (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    import java.awt.*;
    import java.awt.event.*;
    
    handles.push_Macros.UIContextMenu = handles.context_Macros;
    
    % Trigger a right-click event
    try
        rob = Robot;
        rob.mousePress(InputEvent.BUTTON3_MASK);
        pause(0.01);
        rob.mouseRelease(InputEvent.BUTTON3_MASK);
    catch
        errordlg('Java is not working properly. You must right-click the button.','Java error');
    disp('end')
    end
    
    
% --------------------------------------------------------------------
function context_Macros_Callback(hObject, ~, handles)
    % hObject    handle to context_Macros (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    
function MacrosMenuclick(hObject, ~, handles)
    
    handles.dbase = GetDBase(handles);
    
    f = find(handles.menu_Macros==hObject);
    
    mcr = handles.menu_Macros(f).Label;
    handles = eg_runPlugin(handles.plugins.macros, mcr, handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_IncludeTimestamp_Callback(hObject, ~, handles)
    % hObject    handle to menu_IncludeTimestamp (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_IncludeTimestamp.Checked
        handles.menu_IncludeTimestamp.Checked = 'off';
        handles.ExportSonogramIncludeLabel = 0;
    else
        handles.menu_IncludeTimestamp.Checked = 'on';
        handles.ExportSonogramIncludeLabel = 1;
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_Portrait_Callback(hObject, ~, handles)
    % hObject    handle to menu_Portrait (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_Portrait.Checked
        handles.menu_Portrait.Checked = 'on';
        handles.menu_Landscape.Checked = 'off';
        handles.WorksheetOrientation = 'portrait';
        dummy = handles.WorksheetWidth;
        handles.WorksheetWidth = handles.WorksheetHeight;
        handles.WorksheetHeight = dummy;
        handles = UpdateWorksheet(handles);
        guidata(hObject, handles);
    end
    
    
% --------------------------------------------------------------------
function menu_Orientation_Callback(hObject, ~, handles)
    % hObject    handle to menu_Orientation (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_Landscape_Callback(hObject, ~, handles)
    % hObject    handle to menu_Landscape (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if ~handles.menu_Landscape.Checked
        handles.menu_Portrait.Checked = 'off';
        handles.menu_Landscape.Checked = 'on';
        handles.WorksheetOrientation = 'landscape';
        dummy = handles.WorksheetWidth;
        handles.WorksheetWidth = handles.WorksheetHeight;
        handles.WorksheetHeight = dummy;
        handles = UpdateWorksheet(handles);
        guidata(hObject, handles);
    end
    
    
% --------------------------------------------------------------------
function menu_ImageResolution_Callback(hObject, ~, handles)
    % hObject    handle to menu_ImageResolution (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    answer = inputdlg({'Resolution (dpi)'},'Resolution',1,{num2str(handles.ExportSonogramResolution)});
    if isempty(answer)
        return
    end
    handles.ExportSonogramResolution = str2double(answer{1});
    
    
% --------------------------------------------------------------------
function menu_ImageTimescale_Callback(hObject, ~, handles)
    % hObject    handle to menu_ImageTimescale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    answer = inputdlg({'Image timescale (in/sec)'},'Timescale',1,{num2str(handles.ExportSonogramWidth)});
    if isempty(answer)
        return
    end
    handles.ExportSonogramWidth = str2double(answer{1});
    
    handles = UpdateWorksheet(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_ScalebarDimensions_Callback(hObject, ~, handles)
    % hObject    handle to menu_ScalebarDimensions (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Preferred horizontal scalebar width (in)','Preferred vertical scalebar height (in)','Vertical scalebar position (in), <0 for left, >0 for right'},'Scalebar',1,{num2str(handles.ScalebarWidth),num2str(handles.ScalebarHeight),num2str(handles.VerticalScalebarPosition)});
    if isempty(answer)
        return
    end
    handles.ScalebarWidth = str2double(answer{1});
    handles.ScalebarHeight = str2double(answer{2});
    handles.VerticalScalebarPosition = str2double(answer{3});
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EditFigureTemplate_Callback(hObject, ~, handles)
    % hObject    handle to menu_EditFigureTemplate (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    eg_Template_Editor(hObject);
    
    
% --------------------------------------------------------------------
function menu_LineWidth1_Callback(hObject, ~, handles)
    % hObject    handle to menu_LineWidth1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Line width'},'Line width',1,{num2str(handles.ChannelLineWidth(1))});
    if isempty(answer)
        return
    end
    handles.ChannelLineWidth(1) = str2double(answer{1});
    obj = findobj('Parent',handles.axes_Channel1,'LineStyle','-');
    obj.LineWidth  = handles.ChannelLineWidth(1);
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_LineWidth2_Callback(hObject, ~, handles)
    % hObject    handle to menu_LineWidth2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Line width'},'Line width',1,{num2str(handles.ChannelLineWidth(2))});
    if isempty(answer)
        return
    end
    handles.ChannelLineWidth(2) = str2double(answer{1});
    obj = findobj('Parent',handles.axes_Channel2,'LineStyle','-');
    obj.LineWidth  = handles.ChannelLineWidth(2);
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_BackgroundColor_Callback(hObject, ~, handles)
    % hObject    handle to menu_BackgroundColor (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    c = uisetcolor(handles.BackgroundColors(2-handles.ispower,:), 'Select color');
    handles.BackgroundColors(2-handles.ispower,:) = c;
    
    if handles.ispower == 1
        handles.Colormap(1,:) = c;
        colormap(handles.Colormap);
    else
        cl = repmat(linspace(0,1,201)',1,3);
        indx = round(101-handles.DerivativeOffset*100):round(101+handles.DerivativeOffset*100);
        indx = indx(indx>0 & indx<202);
        cl(indx,:) = repmat(handles.BackgroundColors(2,:),length(indx),1);
        colormap(cl);
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_Colormap_Callback(hObject, ~, handles)
    % hObject    handle to menu_Colormap (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
function ColormapClick(hObject, ~, handles)
    
    if strcmp(hObject.Label,'(Default)')
        colormap('parula');
        cmap = colormap;
        cmap(1,:) = [0 0 0];
    else
        cmap = eg_runPlugin(handles.plugins.ColorMaps, hObject.Label);
    end
    
    handles.Colormap = cmap;
    handles.BackgroundColors(1,:) = cmap(1,:);
    
    colormap(handles.Colormap);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_OverlayTop_Callback(hObject, ~, handles)
    % hObject    handle to menu_OverlayTop (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_OverlayTop.Checked
        handles.menu_OverlayTop.Checked = 'on';
    else
        handles.menu_OverlayTop.Checked = 'off';
    end
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_Overlay_Callback(hObject, ~, handles)
    % hObject    handle to menu_Overlay (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_OverlayBottom_Callback(hObject, ~, handles)
    % hObject    handle to menu_OverlayBottom (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_OverlayBottom.Checked
        handles.menu_OverlayBottom.Checked = 'on';
    else
        handles.menu_OverlayBottom.Checked = 'off';
    end
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
    
    
function handles = eg_Overlay(handles)
    % Show, delete, or update channel data overlaid directly on top of the
    % sonogram, depending on the settings within handles.menu_Overlay_Callback

    % Collect list of channel axes that will and will not be overlaid on 
    % top of the sonogram
    axnums = [];
    notAxnums = [];
    if handles.menu_OverlayTop.Checked
        axnums = [axnums 1];
    else
        notAxnums = [notAxnums, 1];
    end
    if handles.menu_OverlayBottom.Checked
        axnums = [axnums 2];
    else
        notAxnums = [notAxnums, 2];
    end
    
    % Delete unchecked overlays
    for axnum = notAxnums
        delete(handles.Sonogram_Overlays(axnum));
    end

    if ~isempty(axnums)
        % Create or update overlays
        hold(handles.axes_Sonogram, 'on');
        
        for axnum = axnums
            y = handles.loadedChannelData{axnum};
            % Scale data to fit nicely on top of sonogram
            yl1 = handles.axes_Channel(axnum).YLim;
            yl2 = handles.axes_Sonogram.YLim;
            y = (y - yl1(1)) / diff(yl1);
            y = y * diff(yl2) + yl2(1);
            if isvalid(handles.Sonogram_Overlays(axnum))
                handles.Sonogram_Overlays(axnum).YData = y;
            else
                [handles, numSamples] = eg_GetNumSamples(handles);
                t = linspace(0, numSamples/handles.fs, numSamples);
                handles.Sonogram_Overlays(axnum) = plot(handles.axes_Sonogram, t, y, 'Color', 'b', 'LineWidth', 1);
                handles.Sonogram_Overlays(axnum).UIContextMenu = handles.axes_Sonogram.UIContextMenu;
                handles.Sonogram_Overlays(axnum).ButtonDownFcn = handles.axes_Sonogram.ButtonDownFcn;
            end
        end
        
        hold(handles.axes_Sonogram, 'off');
    end
    
    
% --------------------------------------------------------------------
function menu_SonogramParameters_Callback(hObject, ~, handles)
    % hObject    handle to menu_SonogramParameters (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if isempty(handles.SonogramParams.Names)
        errordlg('Current sonogram algorithm does not require parameters.','Sonogram error');
        return
    end
    
    answer = inputdlg(handles.SonogramParams.Names,'Sonogram parameters',1,handles.SonogramParams.Values);
    if isempty(answer)
        return
    end
    handles.SonogramParams.Values = answer;
    
    for c = 1:length(handles.menu_Algorithm)
        if handles.menu_Algorithm(c).Checked
            h = handles.menu_Algorithm(c);
            h.UserData = handles.SonogramParams;
        end
    end
    
    handles = eg_PlotSonogram(handles);
    
    handles = eg_Overlay(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EventParams1_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventParams1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = menu_EventParams(handles,1);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EventParams2_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventParams2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = menu_EventParams(handles,2);
    
    guidata(hObject, handles);
    
    
function handles = menu_EventParams(handles,axnum)
    
    pr = handles.ChannelAxesEventParameters{axnum};
    
    if ~isfield(pr,'Names') || isempty(pr.Names)
        errordlg('Current event detector does not require parameters.','Event detector error');
        return
    end
    
    answer = inputdlg(pr.Names,'Event detector parameters',1,pr.Values);
    if isempty(answer)
        return
    end
    pr.Values = answer;
    
    handles.ChannelAxesEventParameters{axnum} = pr;
    
    v = handles.popup_EventDetectors(axnum).Value;
    ud = handles.popup_EventDetectors(axnum).UserData;
    ud{v} = handles.ChannelAxesEventParameters{axnum};
    handles.popup_EventDetectors(axnum).UserData = ud;
    
    handles = DetectEvents(handles,axnum);
    
    
% --------------------------------------------------------------------
function menu_FunctionParams1_Callback(hObject, ~, handles)
    % hObject    handle to menu_FunctionParams1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = menu_FunctionParams(handles,1);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_FunctionParams2_Callback(hObject, ~, handles)
    % hObject    handle to menu_FunctionParams2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = menu_FunctionParams(handles,2);
    
    guidata(hObject, handles);
    
    
    
function handles = menu_FunctionParams(handles,axnum)
    
    pr = handles.FunctionParams{axnum};
    
    if ~isfield(pr,'Names') || isempty(pr.Names)
        errordlg('Current function does not require parameters.','Function error');
        return
    end
    
    answer = inputdlg(pr.Names,'Function parameters',1,pr.Values);
    if isempty(answer)
        return
    end
    pr.Values = answer;
    
    handles.FunctionParams{axnum} = pr;
    
    v = handles.popup_Functions(axnum).Value;
    ud = handles.popup_Functions(axnum).UserData;
    ud{v} = handles.FunctionParams{axnum};
    handles.popup_Functions(axnum).UserData = ud;
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        handles = eg_LoadChannel(handles,axnum);
        handles = DetectEvents(handles, axnum);
    end
    
    
% --------------------------------------------------------------------
function menu_Split_Callback(hObject, ~, handles)
    % hObject    handle to menu_Split (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        return
    end
    
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
    
    for c = 1:length(handles.menu_Segmenter)
        if handles.menu_Segmenter(c).Checked
            alg = handles.menu_Segmenter(c).Label;
        end
    end
    
    filenum = getCurrentFileNum(handles);
    
    
    f = find(handles.SegmentTimes{filenum}(:,1)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*handles.fs);
    g = find(handles.SegmentTimes{filenum}(:,2)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*handles.fs);
    h = find(handles.SegmentTimes{filenum}(:,1)<rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*handles.fs);
    dl = unique([f; g; h]);
    if isempty(dl)
        return
    end
    
    handles.SegmenterParams.IsSplit = 1;
    sg = eg_runPlugin(handles.plugins.segmenters, alg, handles.amplitude, ...
        handles.fs, rect(2), handles.SegmenterParams);
    
    f = find(sg(:,1)>rect(1)*handles.fs & sg(:,1)<(rect(1)+rect(3))*handles.fs);
    g = find(sg(:,2)>rect(1)*handles.fs & sg(:,2)<(rect(1)+rect(3))*handles.fs);
    h = find(sg(:,1)<rect(1)*handles.fs & sg(:,2)>(rect(1)+rect(3))*handles.fs);
    nw = unique([f; g; h]);
    sg = sg(nw,:);
    
    handles.SegmentTimes{filenum} = [handles.SegmentTimes{filenum}(1:min(dl)-1,:); sg; handles.SegmentTimes{filenum}(max(dl)+1:end,:)];
    st = {};
    st = [st handles.SegmentTitles{filenum}(1:min(dl)-1)];
    st = [st cell(1,size(sg,1))];
    st = [st handles.SegmentTitles{filenum}(max(dl)+1:end)];
    handles.SegmentTitles{filenum} = st;
    handles.SegmentSelection{filenum} = [handles.SegmentSelection{filenum}(1:min(dl)-1) ones(1,size(sg,1)) handles.SegmentSelection{filenum}(max(dl)+1:end)];
    handles = PlotAnnotations(handles);
    handles.figure_Main.KeyPressFcn = @keyPressHandler;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceSoundAmplitude_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceSoundAmplitude (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_SourceSoundAmplitude.Checked = 'on';
    handles.menu_SourceTopPlot.Checked = 'off';
    handles.menu_SourceBottomPlot.Checked = 'off';
    
    handles = updateAmplitude(handles);

    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceTopPlot_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceTopPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_SourceSoundAmplitude.Checked = 'off';
    handles.menu_SourceTopPlot.Checked = 'on';
    handles.menu_SourceBottomPlot.Checked = 'off';
    
    handles = updateAmplitude(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceBottomPlot_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceBottomPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    handles.menu_SourceSoundAmplitude.Checked = 'off';
    handles.menu_SourceTopPlot.Checked = 'off';
    handles.menu_SourceBottomPlot.Checked = 'on';
    
    handles = updateAmplitude(handles);
    
    guidata(hObject, handles);
    
function handles = updateAmplitude(handles, forceRedraw)
    % Update amplitude axes according to data in handles.amplitude

    if ~exist('forceRedraw', 'var') || isempty(forceRedraw)
        forceRedraw = false;
    end

    % Check if amplitude plot already exists
    plt = findobj('Parent', handles.axes_Amplitude, 'LineStyle', '-');

    % Recalculate amplitude data
    [handles.amplitude, labels] = eg_CalculateAmplitude(handles);

    if (isempty(plt) || forceRedraw) && ~isempty(handles.amplitude)
        [handles, numSamples] = eg_GetNumSamples(handles);
        filenum = getCurrentFileNum(handles);

        plot(handles.axes_Amplitude, linspace(0, numSamples/handles.fs, numSamples),handles.amplitude,'Color',handles.AmplitudeColor);
        handles.axes_Amplitude.XTickLabel  = [];
        ylim(handles.axes_Amplitude, handles.AmplitudeLims);
        box(handles.axes_Amplitude, 'off');
        ylabel(handles.axes_Amplitude, labels);
        handles.axes_Amplitude.UIContextMenu = handles.context_Amplitude;
        handles.axes_Amplitude.ButtonDownFcn = @click_Amplitude;
        for child = handles.axes_Amplitude.Children'
            child.UIContextMenu = handles.axes_Amplitude.UIContextMenu;
        end
        for child = handles.axes_Amplitude.Children'
            child.ButtonDownFcn = handles.axes_Amplitude.ButtonDownFcn;
        end
    
        if handles.SoundThresholds(filenum)==inf
            if handles.menu_AutoThreshold.Checked
                handles.CurrentThreshold = eg_AutoThreshold(handles.amplitude);
            end
            handles.SoundThresholds(filenum) = handles.CurrentThreshold;
        else
            handles.CurrentThreshold = handles.SoundThresholds(filenum);
        end
        handles.SegmentLabelHandles = gobjects().empty;
        handles = SetSegmentThreshold(handles);
    else
        % Just update y values
        plt.YData = handles.amplitude;
        ylabel(handles.axes_Amplitude, labels);
    end


function [amp, labels] = eg_CalculateAmplitude(handles)
    
    [handles, sound] = eg_GetSound(handles);
    
    wind = round(handles.SmoothWindow*handles.fs);
    if handles.menu_DontPlot.Checked
        amp = zeros(size(sound));
        labels = '';
    else
        if handles.menu_SourceSoundAmplitude.Checked
            [~, filtered_sound] = eg_GetSound(handles, true);
            amp = smooth(10*log10(filtered_sound.^2+eps),wind);
            amp = amp-min(amp(wind:length(amp)-wind));
            amp(amp<0)=0;
            labels = 'Loudness (dB)';
        elseif handles.menu_SourceTopPlot.Checked
            if handles.axes_Channel1.Visible
                amp = smooth(handles.loadedChannelData{1},wind);
                labels = handles.axes_Channel1.YLabel.String;
            else
                amp = zeros(size(sound));
                labels = '';
            end
        elseif handles.menu_SourceBottomPlot.Checked
            if handles.axes_Channel2.Visible
                amp = smooth(handles.loadedChannelData{2},wind);
                labels = handles.axes_Channel2.YLabel.String;
            else
                amp = zeros(size(sound));
                labels = '';
            end
        end
    
    end
    
    
% --------------------------------------------------------------------
function menu_Concatenate_Callback(hObject, ~, handles)
    % hObject    handle to menu_Concatenate (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    filenum = getCurrentFileNum(handles);
    
    set(gca,'Units','pixels');
    set(get(gca,'Parent'),'Units','pixels');
    ginput(1);
    rect = rbbox;
    
    pos = get(gca,'Position');
    set(get(gca,'Parent'),'Units','normalized');
    set(gca,'Units','normalized');
    xl = xlim;
    
    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    
    f = find(handles.SegmentTimes{filenum}(:,1)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,1)<(rect(1)+rect(3))*handles.fs);
    g = find(handles.SegmentTimes{filenum}(:,2)>rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)<(rect(1)+rect(3))*handles.fs);
    h = find(handles.SegmentTimes{filenum}(:,1)<rect(1)*handles.fs & handles.SegmentTimes{filenum}(:,2)>(rect(1)+rect(3))*handles.fs);
    f = unique([f; g; h]);
    
    if isempty(f)
        return
    end
    
    handles.SegmentTimes{filenum}(min(f),2) = handles.SegmentTimes{filenum}(max(f),2);
    handles.SegmentTimes{filenum}(min(f)+1:max(f),:) = [];
    handles.SegmentTitles{filenum}(min(f)+1:max(f)) = [];
    handles.SegmentSelection{filenum}(min(f)+1:max(f)) = [];
    handles = PlotAnnotations(handles);
    
    handles = SetActiveSegment(handles, min(f));
    handles.figure_Main.KeyPressFcn = @keyPressHandler;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_DontPlot_Callback(hObject, ~, handles)
    % hObject    handle to menu_DontPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~handles.menu_DontPlot.Checked
        handles.menu_DontPlot.Checked = 'on';
    else
        handles.menu_DontPlot.Checked = 'off';
    end
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_IncludeSoundNone_Callback(hObject, ~, handles)
    % hObject    handle to menu_IncludeSoundNone (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.ExportSonogramIncludeClip = 0;
    for child = handles.menu_IncludeSoundClip.Children'
        child.Checked = 'off';
    end
    hObject.Checked = 'on';
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_IncludeSoundOnly_Callback(hObject, ~, handles)
    % hObject    handle to menu_IncludeSoundOnly (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.ExportSonogramIncludeClip = 1;
    for child = handles.menu_IncludeSoundClip.Children'
        child.Checked = 'off';
    end
    hObject.Checked = 'on';
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_IncludeSoundMix_Callback(hObject, ~, handles)
    % hObject    handle to menu_IncludeSoundMix (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.ExportSonogramIncludeClip = 2;
    for child = handles.menu_IncludeSoundClip.Children'
        child.Checked = 'off';
    end
    hObject.Checked = 'on';
    guidata(hObject, handles);
    
    
    
function snd = GenerateSound(handles,sound_type)
    % Generate sound with the selected options. Sound_type is either 'snd' or
    % 'mix'
    
    [handles, sound] = eg_GetSound(handles, false);
    [handles, filtered_sound] = eg_GetSound(handles, true);
    
    snd = zeros(size(sound));
    if handles.check_Sound.Value==1 || strcmp(sound_type,'snd')
        if handles.menu_FilterSound.Checked
            snd = snd + filtered_sound * handles.SoundWeights(1);
        else
            snd = snd + sound * handles.SoundWeights(1);
        end
    end
    
    if strcmp(sound_type,'mix')
        if handles.axes_Channel1.Visible && handles.check_TopPlot.Value==1
            addval = handles.loadedChannelData{1};
            addval(abs(addval) < handles.SoundClippers(1)) = 0;
            addval = addval * handles.SoundWeights(2);
            if size(addval,2)>size(addval,1)
                addval = addval';
            end
            snd = snd + addval;
        end
        if handles.axes_Channel2.Visible && handles.check_BottomPlot.Value==1
            addval = handles.loadedChannelData{2};
            addval(abs(addval) < handles.SoundClippers(2)) = 0;
            addval = addval * handles.SoundWeights(3);
            if size(addval,2)>size(addval,1)
                addval = addval';
            end
            snd = snd + addval;
        end
    end
    
    xd = handles.axes_Sonogram.XLim;
    xd = round(xd*handles.fs);
    xd(1) = xd(1)+1;
    xd(2) = xd(2)-1;
    if xd(1)<1
        xd(1) = 1;
    end
    if xd(2)>length(snd)
        xd(2) = length(snd);
    end
    snd = snd(xd(1):xd(2));
    
    if handles.menu_PlayReverse.Checked
        snd = snd(end:-1:1);
    end
    
    
% --------------------------------------------------------------------
function menu_PlayReverse_Callback(hObject, ~, handles)
    % hObject    handle to menu_PlayReverse (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if ~handles.menu_PlayReverse.Checked
        handles.menu_PlayReverse.Checked = 'on';
    else
        handles.menu_PlayReverse.Checked = 'off';
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_FilterList_Callback(hObject, ~, handles)
    % hObject    handle to menu_FilterList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_FilterParameters_Callback(hObject, ~, handles)
    % hObject    handle to menu_FilterParameters (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if isempty(handles.FilterParams.Names)
        errordlg('Current sound filter does not require parameters.','Filter error');
        return
    end
    
    answer = inputdlg(handles.FilterParams.Names,'Filter parameters',1,handles.FilterParams.Values);
    if isempty(answer)
        return
    end
    handles.FilterParams.Values = answer;
    
    for c = 1:length(handles.menu_Filter)
        if handles.menu_Filter(c).Checked
            h = handles.menu_Filter(c);
            h.UserData = handles.FilterParams;
        end
    end
    
    handles = eg_FilterSound(handles);
    
    [handles, filtered_sound] = eg_GetSound(handles, true);
    
    cla(handles.axes_Sound);
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    h = eg_peak_detect(handles.axes_Sound, linspace(0, numSamples/handles.fs, numSamples), filtered_sound);
    h.Color = 'c';
    handles.axes_Sound.XTick = [];
    handles.axes_Sound.YTick = [];
    handles.axes_Sound.Color = [0 0 0];
    axis(handles.axes_Sound, 'tight');
    yl = max(abs(handles.axes_Sound.YLim));
    handles.axes_Sound.YLim = [-yl*1.2 yl*1.2];
    
    handles = updateXLimBox(handles);

    box(handles.axes_Sound, 'on');
    
    handles = setClickSoundCallback(handles, handles.axes_Sonogram);
    handles = setClickSoundCallback(handles, handles.axes_Sound);
        
    handles = updateAmplitude(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in check_Shuffle.
function check_Shuffle_Callback(hObject, ~, handles)
    % hObject    handle to check_Shuffle (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: hObject.Value returns toggle state of check_Shuffle
    
    
    if handles.check_Shuffle.Value==1
        handles.ShuffleOrder = randperm(handles.TotalFileNumber);
    else
        str = handles.list_Files.String;
        for c = 1:handles.TotalFileNumber
            str{c}(19:20) = '00';
        end
        handles.list_Files.String = str;
        handles.check_Shuffle.String = 'Random';
    end
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AmplitudeAutoRange_Callback(hObject, ~, handles)
    % hObject    handle to menu_AmplitudeAutoRange (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    mn = min(handles.amplitude);
    mx = max(handles.amplitude);
    handles.AmplitudeLims = [mn-0.05*(mx-mn) mx+0.05*(mx-mn)];
    
    handles.axes_Amplitude.YLim = handles.AmplitudeLims;
    
    guidata(hObject, handles);
    
    
function handles = eg_RestartProperties(handles)
    
    if isfield(handles,'DefaultPropertyValues')
        bck_def = handles.DefaultPropertyValues;
        bck_nm = handles.PropertyNames;
        lst_menus = {};
        for c = 1:length(handles.PropertyNames)
            lst_menus{c} = handles.PropertyObjectHandles(c).String';
            lst_menus{c} = lst_menus{c}(1:end-1);
        end
    
    else
        bck_def = {};
        bck_nm = {};
        lst_menus = [];
    end
    
    names = {};
    values = {};
    types = [];
    for c = 1:length(handles.Properties.Names)
        names = [names handles.Properties.Names{c}];
        values = [values handles.Properties.Values{c}];
        types = [types handles.Properties.Types{c}];
    end
    
    [handles.PropertyNames, pos, indx] = unique(names);
    handles.PropertyTypes = types(pos);
    
    if isfield(handles,'PropertyTextHandles')
        delete(handles.PropertyTextHandles);
    end
    handles.PropertyTextHandles = gobjects().empty;
    if isfield(handles,'PropertyObjectHandles')
        delete(handles.PropertyObjectHandles);
    end
    handles.PropertyObjectHandles = gobjects().empty();
    
    handles.DefaultPropertyValues = {};
    
    lns = linspace(0,1,2*length(handles.PropertyNames)+1);
    lns = lns(2:2:end);
    for c = 1:length(handles.PropertyNames)
        wd = min([0.95*(1/7) 0.95*(1/length(handles.PropertyNames))]);
        x = lns(c)-wd/2;
    
        switch handles.PropertyTypes(c)
            case 1 % string
                handles.PropertyObjectHandles(c) = uicontrol(handles.panel_Properties,'Style','edit',...
                    'Units','normalized','String','','Position',[x 0.1 wd 0.55],...
                    'FontSize',10,'HorizontalAlignment','left','backgroundcolor',[1 1 1]);
                handles.DefaultPropertyValues{c} = '';
            case 2 % boolean
                handles.PropertyObjectHandles(c) = uicontrol(handles.panel_Properties,'Style','checkbox',...
                    'Units','normalized','String','a','Position',[x 0.1 wd/2 0.55],'FontSize',8);
                ext = handles.PropertyObjectHandles(c).Extent;
                set(handles.PropertyObjectHandles(c),'String','','Position',[x+wd/2-ext(4)/2 0.1 ext(4) 0.55]);
                handles.DefaultPropertyValues{c} = 0;
            case 3 % list
                str = values(indx==c);
                for d = 1:length(bck_nm)
                    if strcmp(bck_nm{d},handles.PropertyNames{c})
                        str = [str lst_menus{d}];
                    end
                end
    
                for d = 1:length(bck_nm)
                    if strcmp(bck_nm{d},handles.PropertyNames{c})
                        str{end+1} = bck_def{d};
                    end
                end
    
                str = unique(str);
                str{end+1} = 'New value...';
                handles.PropertyObjectHandles(c) = uicontrol(handles.panel_Properties,'Style','popupmenu',...
                    'Units','normalized','String',str,'Position',[x 0.1 wd 0.55],...
                    'FontSize',10,'HorizontalAlignment','center','backgroundcolor',[1 1 1]);
                handles.DefaultPropertyValues{c} = str{1};
        end
    
        handles.PropertyTextHandles(c) = uicontrol(handles.panel_Properties,'Style','text',...
            'Units','normalized','String',handles.PropertyNames{c},'Position',[x 0.65 wd 0.3],...
            'FontSize',8,'HorizontalAlignment','center');
    end
    
    for c = 1:length(bck_def)
        for d = 1:length(handles.PropertyNames)
            if strcmp(bck_nm{c},handles.PropertyNames{d})
                handles.DefaultPropertyValues{d} = bck_def{c};
            end
        end
    end
    
    if ~isempty(handles.PropertyObjectHandles)
        handles.PropertyObjectHandles.Callback = @ChangeProperty;
    end
    if ~isempty(handles.PropertyTextHandles)
        handles.PropertyTextHandles.ButtonDownFcn = @ClickPropertyText;
    end
    
function ChangeProperty(hObject, ~, handles)
    
    filenum = getCurrentFileNum(handles);
    f = find(handles.PropertyObjectHandles==hObject);
    
    for d = 1:length(handles.Properties.Names{filenum})
        if strcmp(handles.Properties.Names{filenum}{d},handles.PropertyTextHandles(f).String)
            indx = d;
        end
    end
    
    switch handles.PropertyTypes(f)
        case 1
            handles.Properties.Values{filenum}{indx} = handles.PropertyObjectHandles(f).String;
        case 2
            handles.Properties.Values{filenum}{indx} = handles.PropertyObjectHandles(f).Value;
        case 3
            str = handles.PropertyObjectHandles(f).String;
            if handles.PropertyObjectHandles(f).Value == length(str)
                % new value
                answer = inputdlg({'New list value'},'New value',1,{''});
                if ~isempty(answer)
                    handles.Properties.Values{filenum}{indx} = answer{1};
                end
    
                str = handles.PropertyObjectHandles(f).String;
                str = str(1:end-1);
                str{end+1} = handles.Properties.Values{filenum}{indx};
                str = unique(str);
                str{end+1} = 'New value...';
                set(handles.PropertyObjectHandles(f),'Value',1,'String',str);
                for c = 1:length(str)
                    if strcmp(str{c},handles.Properties.Values{filenum}{indx})
                        handles.PropertyObjectHandles(f).Value = c;
                    end
                end
            else
                handles.Properties.Values{filenum}{indx} = str{handles.PropertyObjectHandles(f).Value};
            end
    end
    
    guidata(hObject, handles);
    
    
function ClickPropertyText(hObject, ~, handles)
    
    if strcmp(hObject.Enable,'off')
        filenum = getCurrentFileNum(handles);
    
        handles.Properties.Names{filenum}{end+1} = hObject.String;
    
        f = find(handles.PropertyTextHandles==hObject);
        handles.Properties.Values{filenum}{end+1} = handles.DefaultPropertyValues{f};
        handles.Properties.Types{filenum}(end+1) = handles.PropertyTypes(f);
    
        handles = eg_LoadProperties(handles);
    end
    
    guidata(hObject, handles);
    
    
function handles = eg_LoadProperties(handles)
    
    filenum = getCurrentFileNum(handles);
    
    for c = 1:length(handles.PropertyNames)
        indx = [];
        for d = 1:length(handles.Properties.Names{filenum})
            if strcmp(handles.PropertyNames{c},handles.Properties.Names{filenum}{d})
                indx = d;
            end
        end
        if isempty(indx)
            set(handles.PropertyTextHandles(c),'Enable','off')
            set(handles.PropertyObjectHandles(c),'Visible','off')
        else
            set(handles.PropertyTextHandles(c),'Enable','on')
            set(handles.PropertyObjectHandles(c),'Visible','on')
            switch handles.PropertyObjectHandles(c).Style
                case 'edit'
                    handles.PropertyObjectHandles(c).String = handles.Properties.Values{filenum}{indx};
                case 'checkbox'
                    handles.PropertyObjectHandles(c).Value = handles.Properties.Values{filenum}{indx};
                case 'popupmenu'
                    str = handles.PropertyObjectHandles(c).String;
                    for d = 1:length(str)
                        if strcmp(str{d},handles.Properties.Values{filenum}{indx})
                            handles.PropertyObjectHandles(c).Value = d;
                        end
                    end
            end
        end
    end
    
    
% --------------------------------------------------------------------
function menu_FilterSound_Callback(hObject, ~, handles)
    % hObject    handle to menu_FilterSound (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if handles.menu_FilterSound.Checked
        handles.menu_FilterSound.Checked = 'off';
    else
        handles.menu_FilterSound.Checked = 'on';
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AddProperty_Callback(hObject, ~, handles)
    % hObject    handle to menu_AddProperty (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function context_Properties_Callback(hObject, ~, handles)
    % hObject    handle to context_Properties (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AddPropertyString_Callback(hObject, ~, handles)
    % hObject    handle to menu_AddPropertyString (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_AddProperty(handles,1);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AddPropertyBoolean_Callback(hObject, ~, handles)
    % hObject    handle to menu_AddPropertyBoolean (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_AddProperty(handles,2);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AddPropertyList_Callback(hObject, ~, handles)
    % hObject    handle to menu_AddPropertyList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = eg_AddProperty(handles,3);
    
    guidata(hObject, handles);
    
    
function handles = eg_AddProperty(handles,type)
    
    filenum = getCurrentFileNum(handles);
    
    typestr = {'String','boolean','list'};
    button = questdlg(['Add a new ' typestr{type} ' property to'],'Add property','Current file','Some files...','All files','All files');
    switch button
        case ''
            return
        case 'Current file'
            indx = filenum;
            selstr = 'current file';
        case 'Some files...'
            str = handles.list_Files.String;
            for c = 1:length(str)
                str{c} = [num2str(c), '. ', extractFileNameFromEntry(handles, str{c}, true)];
            end
            [indx,ok] = listdlg('ListString',str,'InitialValue',filenum,'ListSize',[300 450],'Name','Select files','PromptString','Files to add new property to');
            if ok == 0
                return
            end
            selstr = 'selected files';
        case 'All files'
            indx = 1:handles.TotalFileNumber;
            selstr = 'all files';
    end
    
    
    switch type
        case 1
            answer = inputdlg({'Property name',['Value for ' selstr]},'Add property',1,{'',''});
            if isempty(answer)
                return
            end
            name = answer{1};
            val = answer{2};
        case 2
            answer = inputdlg({'Property name'},'Add property',1,{''});
            if isempty(answer)
                return
            end
            name = answer{1};
            button = questdlg(['Value for ' selstr],'Add property','On','Off','Off');
            switch button
                case ''
                    return
                case 'On'
                    val = 1;
                case 'Off'
                    val = 0;
            end
        case 3
            answer = inputdlg({'Property name','List of possible values'},'Add property',[1; 5],{'',''});
            if isempty(answer)
                return
            end
            name = answer{1};
            lst = answer{2};
            str = {};
            for c = 1:size(lst,1)
                str{c} = strtrim(lst(c,:));
            end
    
            [val,ok] = listdlg('ListString',str,'Name','Add property','PromptString',['Value for ' selstr],'SelectionMode','single');
            if ok == 0
                return
            end
            val = str{val};
    
            str{end+1} = 'Dummy';
            handles.PropertyNames{end+1} = name;
            handles.PropertyObjectHandles(end+1) = uicontrol(handles.panel_Properties,'Style','popupmenu',...
                'Units','normalized','String',str,'Position',[0 0 .1 .1],'Visible','off',...
                'FontSize',10,'HorizontalAlignment','center','backgroundcolor',[1 1 1]);
            handles.DefaultPropertyValues{end+1} = str{1};
    end
    
    for c = 1:length(indx)
        isthere = 0;
        for d = 1:length(handles.Properties.Names{indx(c)})
            if strcmp(handles.Properties.Names{indx(c)}{d},name)
                isthere = 1;
            end
        end
        if isthere == 0
            handles.Properties.Names{indx(c)}{end+1} = name;
            handles.Properties.Values{indx(c)}{end+1} = val;
            handles.Properties.Types{indx(c)}(end+1) = type;
        end
    end
    
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    
% --------------------------------------------------------------------
function menu_RemoveProperty_Callback(hObject, ~, handles)
    % hObject    handle to menu_RemoveProperty (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    filenum = getCurrentFileNum(handles);
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('No properties to remove!','Error');
        return
    end
    
    button = questdlg('Remove property from', 'Remove property', 'Current file', 'Some files...', 'All files', 'All files');
    switch button
        case ''
            return
        case 'Current file'
            indx = filenum;
    %         selstr = 'current file';
        case 'Some files...'
            str = handles.list_Files.String;
            for c = 1:length(str)
                str{c} = [num2str(c) '. ' extractFileNameFromEntry(handles, str{c}, true)];
            end
            [indx,ok] = listdlg('ListString',str,'InitialValue',filenum,'ListSize',[300 450],'Name','Select files','PromptString','Files to remove property from');
            if ok == 0
                return
            end
    %         selstr = 'selected files';
        case 'All files'
            indx = 1:handles.TotalFileNumber;
    %         selstr = 'all files';
    end
    
    [delindx,ok] = listdlg('ListString',handles.PropertyNames,'InitialValue',[],'Name','Select propertries','PromptString','Remove properties');
    if ok == 0
        return
    end
    
    for c = 1:length(indx)
        todel = [];
        for d = 1:length(handles.Properties.Names{indx(c)})
            for e = 1:length(delindx)
                if strcmp(handles.Properties.Names{indx(c)}{d},handles.PropertyNames{delindx(e)})
                    todel = [todel d];
                end
            end
        end
        handles.Properties.Names{indx(c)}(todel) = [];
        handles.Properties.Values{indx(c)}(todel) = [];
        handles.Properties.Types{indx(c)}(todel) = [];
    end
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_Search_Callback(hObject, ~, handles)
    % hObject    handle to menu_Search (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
function handles = SearchProperties(handles,search_type)
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('No properties to search!','Error');
        return
    end
    
    [indx,ok] = listdlg('ListString',handles.PropertyNames,'InitialValue',[],'Name','Select property','SelectionMode','single','PromptString','Select property to search');
    if ok == 0
        return
    end
    
    prev_search = [];
    str = handles.list_Files.String;
    for c = 1:handles.TotalFileNumber
        if strcmp(str{c}(19),'F')
            prev_search = [prev_search c];
        end
    end
    
    nw = [];
    switch handles.PropertyTypes(indx)
        case 1
            answer = inputdlg({['String to search for in "' handles.PropertyNames{indx} '"']},'Search property',1,handles.DefaultPropertyValues(indx));
            if isempty(answer)
                return
            end
            for d = 1:handles.TotalFileNumber
                for e = 1:length(handles.Properties.Names{d})
                    if strcmp(handles.Properties.Names{d}{e},handles.PropertyNames{indx})
                        fnd = regexpi(handles.Properties.Values{d}{e},answer{1}, 'once');
                        if ~isempty(fnd)
                            nw = [nw d];
                        end
                    end
                end
            end
        case 2
            button = questdlg(['Value to search for in "' handles.PropertyNames{indx} '"'],'Search property','On','Off','Either','On');
            switch button
                case ''
                    return
                case 'On'
                    valnear = 1.5;
                case 'Off'
                    valnear = -0.5;
                case 'Either'
                    valnear = 0.5;
            end
            for d = 1:handles.TotalFileNumber
                for e = 1:length(handles.Properties.Names{d})
                    if strcmp(handles.Properties.Names{d}{e},handles.PropertyNames{indx})
                        if abs(handles.Properties.Values{d}{e}-valnear)<1
                            nw = [nw d];
                        end
                    end
                end
            end
        case 3
            str = handles.PropertyObjectHandles(indx).String;
            str = str(1:end-1);
            [val,ok] = listdlg('ListString',str,'InitialValue',[],'Name','Select values','PromptString',['Values to search for in "' handles.PropertyNames{indx} '"']);
            if ok == 0
                return
            end
            for d = 1:handles.TotalFileNumber
                for e = 1:length(handles.Properties.Names{d})
                    if strcmp(handles.Properties.Names{d}{e},handles.PropertyNames{indx})
                        for f = 1:length(val)
                            if strcmp(handles.Properties.Values{d}{e},str{val(f)})
                                nw = [nw d];
                            end
                        end
                    end
                end
            end
    end
    
    switch search_type
        case 1 % new search
            found = nw;
        case 2 % AND
            found = intersect(prev_search,nw);
        case 3 % OR
            found = union(prev_search,nw);
    end
    
    str = handles.list_Files.String;
    for c = 1:handles.TotalFileNumber
        str{c}(19:20) = '00';
    end
    for c = 1:length(found)
        str{found(c)}(19:20) = 'FF';
    end
    
    handles.list_Files.String = str;
    
    handles.ShuffleOrder = [found setdiff(1:handles.TotalFileNumber,found)];
    handles.check_Shuffle.Value = 1;
    handles.check_Shuffle.String = 'Searched';
    handles.edit_FileNumber.String = num2str(handles.ShuffleOrder(1));
    
    handles = eg_LoadFile(handles);
    
    
% --------------------------------------------------------------------
function menu_SearchNew_Callback(hObject, ~, handles)
    % hObject    handle to menu_SearchNew (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SearchProperties(handles,1);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_SearchAnd_Callback(hObject, ~, handles)
    % hObject    handle to menu_SearchAnd (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SearchProperties(handles,2);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_SearchOr_Callback(hObject, ~, handles)
    % hObject    handle to menu_SearchOr (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SearchProperties(handles,3);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_SearchNot_Callback(hObject, ~, handles)
    % hObject    handle to menu_SearchNot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = handles.list_Files.String;
    found = [];
    for c = 1:handles.TotalFileNumber
        if strcmp(str{c}(19),'F')
            str{c}(19:20) = '00';
        else
            str{c}(19:20) = 'FF';
            found = [found c];
        end
    end
    
    handles.list_Files.String = str;
    
    handles.ShuffleOrder = [found setdiff(1:handles.TotalFileNumber,found)];
    handles.check_Shuffle.Value = 1;
    handles.check_Shuffle.String = 'Searched';
    handles.edit_FileNumber.String = num2str(handles.ShuffleOrder(1));
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_RenameProperty_Callback(hObject, ~, handles)
    % hObject    handle to menu_RenameProperty (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('No properties to rename!','Error');
        return
    end
    
    [indx,ok] = listdlg('ListString',handles.PropertyNames,'InitialValue',[],'Name','Select property','SelectionMode','single','PromptString','Select property to rename');
    if ok == 0
        return
    end
    
    answer = inputdlg({['New name to replace "' handles.PropertyNames{indx} '"']},'Rename property',1,handles.PropertyNames(indx));
    if isempty(answer)
        return
    end
    
    for c = 1:handles.TotalFileNumber
        for d = 1:length(handles.Properties.Names{c})
            if strcmp(handles.Properties.Names{c}{d},handles.PropertyNames{indx})
                handles.Properties.Names{c}{d} = answer{1};
            end
        end
    end
    
    handles.PropertyNames{indx} = answer{1};
    handles.PropertyTextHandles(indx).String = answer{1};
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_FillProperty_Callback(hObject, ~, handles)
    % hObject    handle to menu_FillProperty (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('No properties to fill!','Error');
        return
    end
    
    filenum = getCurrentFileNum(handles);
    
    [indx,ok] = listdlg('ListString',handles.PropertyNames,'InitialValue',[],'Name','Select property','SelectionMode','single','PromptString','Select property to fill');
    if ok == 0
        return
    end
    
    str = handles.list_Files.String;
    for c = 1:length(str)
        str{c} = [num2str(c) '. ' extractFileNameFromEntry(handles, str{c}, true)];
    end
    [files, ~] = listdlg('ListString',str,'InitialValue',filenum,'ListSize',[300 450],'Name','Select files','PromptString',['Files in which to fill property "' handles.PropertyNames{indx} '"']);
    if isempty(files)
        return
    end
    
    
    switch handles.PropertyTypes(indx)
        case 1
            answer = inputdlg({['Fill property "' handles.PropertyNames{indx} '" with value']},'Fill property',1,handles.DefaultPropertyValues(indx));
            if isempty(answer)
                return
            end
            fill = answer{1};
        case 2
            switch handles.DefaultPropertyValues{indx}
                case 1
                    def = 'On';
                case 0
                    def = 'Off';
            end
            button = questdlg(['Fill property "' handles.PropertyNames{indx} '" with value'],'Fill property','On','Off',def);
            switch button
                case ''
                    return
                case 'On'
                    fill = 1;
                case 'Off'
                    fill = 0;
            end
        case 3
            str = handles.PropertyObjectHandles(indx).String;
            for c = 1:length(str)
                if strcmp(str{c},handles.DefaultPropertyValues{indx})
                    def = c;
                end
            end
            [val, ~] = listdlg('ListString',str,'InitialValue',def,'Name','Select value','SelectionMode','single','PromptString',['Fill property "' handles.PropertyNames{indx} '" with value']);
            if val==length(str)
                answer = inputdlg({['New value for "' handles.PropertyNames{indx} '"']},'Fill property',1,{''});
                if isempty(answer)
                    return
                end
                fill = answer{1};
                str = str(1:end-1);
                str{end+1} = fill;
                str{end+1} = 'New value...';
                handles.PropertyObjectHandles(indx).String = str;
            else
                fill = str{val};
            end
    end
    
    shouldadd = -1;
    for c = 1:length(files)
        f = [];
        for d = 1:length(handles.Properties.Names{files(c)})
            if strcmp(handles.Properties.Names{files(c)}{d},handles.PropertyNames{indx})
                f = d;
            end
        end
        if ~isempty(f)
            handles.Properties.Values{files(c)}{f} = fill;
        else
            switch shouldadd
                case -1
                    button = questdlg(['Not all selected files have property "' handles.PropertyNames{indx} '". Add property to these files?'],'Fill property');
                    switch button
                        case {'','Cancel'}
                            return
                        case 'Yes'
                            handles.Properties.Names{files(c)}{end+1} = handles.PropertyNames{indx};
                            handles.Properties.Values{files(c)}{end+1} = fill;
                            handles.Properties.Types{files(c)}(end+1) = handles.PropertyTypes(indx);
                            shouldadd = 1;
                        case 'No'
                            shouldadd = 0;
                    end
                case 0
                    % do nothing
                case 1
                    handles.Properties.Names{files(c)}{end+1} = handles.PropertyNames{indx};
                    handles.Properties.Values{files(c)}{end+1} = fill;
                    handles.Properties.Types{files(c)}(end+1) = handles.PropertyTypes(indx);
            end
        end
    end
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    guidata(hObject, handles);
    
    
    
% --------------------------------------------------------------------
function menu_DefaultPropertyValue_Callback(hObject, ~, handles)
    % hObject    handle to menu_DefaultPropertyValue (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('There are no properties!','Error');
        return
    end
    
    [indx,ok] = listdlg('ListString',handles.PropertyNames,'InitialValue',[],'Name','Select property','SelectionMode','single','PromptString','Set default value to property');
    if ok == 0
        return
    end
    
    switch handles.PropertyTypes(indx)
        case 1
            answer = inputdlg({['Default value for "' handles.PropertyNames{indx} '"']},'Default value',1,handles.DefaultPropertyValues(indx));
            if isempty(answer)
                return
            end
            defval = answer{1};
        case 2
            switch handles.DefaultPropertyValues{indx}
                case 1
                    def = 'On';
                case 0
                    def = 'Off';
            end
            button = questdlg(['Default value for "' handles.PropertyNames{indx} '"'],'Default value','On','Off',def);
            switch button
                case ''
                    return
                case 'On'
                    defval = 1;
                case 'Off'
                    defval = 0;
            end
        case 3
            str = handles.PropertyObjectHandles(indx).String;
            for c = 1:length(str)
                if strcmp(str{c},handles.DefaultPropertyValues{indx})
                    def = c;
                end
            end
            [val,ok] = listdlg('ListString',str,'InitialValue',def,'Name','Select value','SelectionMode','single','PromptString',['Default value for "' handles.PropertyNames{indx} '"']);
            if ok == 0
                return
            end
            if val==length(str)
                answer = inputdlg({['New value for "' handles.PropertyNames{indx} '"']},'Default value',1,{''});
                if isempty(answer)
                    return
                end
                defval = answer{1};
                str = str(1:end-1);
                str{end+1} = defval;
                str{end+1} = 'New value...';
                handles.PropertyObjectHandles(indx).String = str;
            else
                defval = str{val};
            end
    end
    
    handles.DefaultPropertyValues{indx} = defval;
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_CleanUpList_Callback(hObject, ~, handles)
    % hObject    handle to menu_CleanUpList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if ~isfield(handles,'PropertyNames') || isempty(handles.PropertyNames)
        errordlg('No lists to clean up!','Error');
        return
    end
    
    f = find(handles.PropertyTypes==3);
    if isempty(f)
        errordlg('No lists to clean up!','Error');
        return
    end
    
    str = {};
    for c = 1:length(f)
        str{end+1} = handles.PropertyNames{f(c)};
    end
    
    [indx,ok] = listdlg('ListString',str,'InitialValue',1:length(str),'Name','Select lists','PromptString','Select lists to clean up');
    if ok == 0
        return
    end
    
    for c = 1:length(indx)
        str = handles.PropertyObjectHandles(f(indx(c))).String;
        str(1:end-1) = [];
        handles.PropertyObjectHandles(f(indx(c))).String = str;
    end
    
    handles = eg_RestartProperties(handles);
    handles = eg_LoadProperties(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_ProgressBarColor_Callback(hObject, ~, handles)
    % hObject    handle to menu_ProgressBarColor (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    c = uisetcolor(handles.ProgressBarColor, 'Select color');
    handles.ProgressBarColor = c;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AnimationNone_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnimationNone (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ClickAnimation(handles, hObject);
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AnimationProgressBar_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnimationProgressBar (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ClickAnimation(handles, hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_AnimationArrowAbove_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnimationArrowAbove (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ClickAnimation(handles, hObject);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_AnimationArrowBelow_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnimationArrowBelow (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = ClickAnimation(handles, hObject);
    guidata(hObject, handles);
    
    
function handles = ClickAnimation(handles, hObject)
    
    ch = handles.menu_Animation.Children;
    for c = 1:length(ch)
        ch(c).Checked = 'off';
    end
    hObject.Checked = 'on';
    
    
% --------------------------------------------------------------------
function menu_Animation_Callback(hObject, ~, handles)
    % hObject    handle to menu_Animation (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    
    
% --------------------------------------------------------------------
function menu_ValueFollower_Callback(hObject, ~, handles)
    % hObject    handle to menu_ValueFollower (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    handles = ClickAnimation(handles, hObject);
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SonogramFollower_Callback(hObject, ~, handles)
    % hObject    handle to menu_SonogramFollower (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    answer = inputdlg({'Power weighting exponent (inf for maximum-follower)'},'Exponent',1,{num2str(handles.SonogramFollowerPower)});
    if isempty(answer)
        return
    end
    handles.SonogramFollowerPower = str2double(answer{1});
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_ScalebarHeight_Callback(hObject, ~, handles)
    % hObject    handle to menu_ScalebarHeight (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function context_UpdateList_Callback(hObject, ~, handles) %#ok<*INUSD>
    % hObject    handle to context_UpdateList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_ChangeFiles_Callback(hObject, ~, handles)
    % hObject    handle to menu_ChangeFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    handles.IsUpdating = 1;
    old_sound_files = handles.sound_files;
    [handles, ischanged] = eg_NewExperiment(handles);
    if ischanged == 0
        return
    end
    
    handles = UpdateFiles(handles,old_sound_files);
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_DeleteFiles_Callback(hObject, ~, handles)
    % hObject    handle to menu_DeleteFiles (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    str = handles.list_Files.String;
    
    [val,ok] = listdlg('ListString',str,'Name','Delete files','PromptString','Select files to DELETE','InitialValue',[],'ListSize',[300 450]);
    if ok == 0
        return
    end
    
    old_sound_files = handles.sound_files;
    
    handles.sound_files(val) = [];
    for c = 1:length(handles.chan_files)
        if ~isempty(handles.chan_files{c})
            handles.chan_files{c}(val) = [];
        end
    end
    
    handles = UpdateFiles(handles,old_sound_files);
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
    
function fileEntry = makeFileEntry(handles, fileName, unread)
    % Construct a file entry
    % filename = name of file
    % unread = boolean - has it been read or not?
    if strcmp(fileName(1:length(handles.UnreadFileMarker)), handles.UnreadFileMarker)
        warning('Loaded a file that starts with the same character in use as the unread file marker character. This will probably cause some problems.');
    end
    fileEntry = [handles.FileEntryOpenTag, repmat(handles.UnreadFileMarker, [1, unread]), fileName, handles.FileEntryCloseTag];
    
function fileName = extractFileNameFromEntry(handles, fileEntry, includeUnreadMarker)
    % Get the filename from the file entry (which may include the unread file
    % marker)
    % fileEntry = a file entry string from the file listbox
    % includeUnreadFileMarker = a boolean - should we include the unread file marker in the returned name?
    unreadFileMarkerStart = length(handles.FileEntryOpenTag)+1;
    unreadFileMarkerEnd = length(handles.FileEntryOpenTag)+length(handles.UnreadFileMarker)-1;
    if ~includeUnreadMarker && strcmp(fileEntry(unreadFileMarkerStart:unreadFileMarkerEnd), handles.UnreadFileMarker)
        fileName = fileEntry(unreadFileMarkerEnd+1:(end-length(handles.FileEntryCloseTag)));
    else
        fileName = fileEntry(length(handles.FileEntryOpenTag)+1:(end-length(handles.FileEntryCloseTag)));
    end
    
function newFileEntry = removeUnreadFileMarker(handles, fileEntry)
    % Remove the unread file marker from a file entry
    % fileEntry = a file entry string from the file listbox
    % newFileEntry = the same file entry string with the unread file marker removed.
    unreadFileMarkerStart = length(handles.FileEntryOpenTag)+1;
    unreadFileMarkerEnd = unreadFileMarkerStart+length(handles.UnreadFileMarker)-1;
    newFileEntry = [fileEntry(1:unreadFileMarkerStart-1), fileEntry(unreadFileMarkerEnd+1:end)];
    
function isUnread = isFileUnread(handles, fileEntry)
    % Check if file in this file entry is unread
    % fileEntry = a file entry string from the file listbox
    unreadFileMarkerStart = length(handles.FileEntryOpenTag)+1;
    unreadFileMarkerEnd = unreadFileMarkerStart+length(handles.UnreadFileMarker)-1;
    isUnread = strcmp(fileEntry(unreadFileMarkerStart:unreadFileMarkerEnd), handles.UnreadFileMarker);
    
    
function handles = UpdateFiles(handles, old_sound_files)
    
    handles.TotalFileNumber = length(handles.sound_files);
    if handles.TotalFileNumber == 0
        return
    end
    
    handles.ShuffleOrder = randperm(handles.TotalFileNumber);
    
    handles.text_TotalFileNumber.String = ['of ' num2str(handles.TotalFileNumber)];
    oldfilenum = handles.list_Files.Value;
    handles.edit_FileNumber.String = '1';
    handles.list_Files.Value = 1;
    
    bck = handles.list_Files.String;
    str = {};
    for c = 1:length(handles.sound_files)
        str{c} = makeFileEntry(handles, handles.sound_files(c).name, true);
    end
    
    % Generate translation lists
    oldnum = [];
    newnum = [];
    newfilenum = 0;
    for c = 1:length(old_sound_files)
        for d = 1:length(handles.sound_files)
            if strcmp(old_sound_files(c).name,handles.sound_files(d).name)
                oldnum(end+1) = c;
                newnum(end+1) = d;
                str{d} = removeUnreadFileMarker(handles, str{d});
                if c==oldfilenum
                    newfilenum = d;
                end
            end
        end
    end
    
    str(newnum) = bck(oldnum);
    handles.list_Files.String = str;
    if newfilenum > 0
        handles.edit_FileNumber.String = num2str(newfilenum);
        handles.list_Files.Value = newfilenum;
    end
    
    
    % Initialize variables for new files
    bck = handles.SoundThresholds(oldnum);
    handles.SoundThresholds = inf(1,handles.TotalFileNumber);
    handles.SoundThresholds(newnum) = bck;
    
    bck = handles.DatesAndTimes(oldnum);
    handles.DatesAndTimes = zeros(1,handles.TotalFileNumber);
    handles.DatesAndTimes(newnum) = bck;
    
    bck = handles.SegmentTimes(oldnum);
    handles.SegmentTimes = cell(1,handles.TotalFileNumber);
    handles.SegmentTimes(newnum) = bck;
    
    bck = handles.SegmentTitles(oldnum);
    handles.SegmentTitles = cell(1,handles.TotalFileNumber);
    handles.SegmentTitles(newnum) = bck;
    
    bck = handles.SegmentSelection(oldnum);
    handles.SegmentSelection = cell(1,handles.TotalFileNumber);
    handles.SegmentSelection(newnum) = bck;
    
    bck = handles.EventThresholds(:,oldnum);
    handles.EventThresholds = inf*ones(size(bck,1),handles.TotalFileNumber);
    handles.EventThresholds(:,newnum) = bck;
    
    bck = handles.MarkerTimes(oldnum);
    handles.MarkerTimes = cell(1,handles.TotalFileNumber);
    handles.MarkerTimes(newnum) = bck;
    
    bck = handles.MarkerTitles(oldnum);
    handles.MarkerTitles = cell(1,handles.TotalFileNumber);
    handles.MarkerTitles(newnum) = bck;
    
    bck = handles.MarkerSelection(oldnum);
    handles.MarkerSelection = cell(1,handles.TotalFileNumber);
    handles.MarkerSelection(newnum) = bck;
    
    
    bck = handles.EventTimes;
    for c = 1:length(bck)
        handles.EventTimes{c} = cell(size(bck{c},1),handles.TotalFileNumber);
        handles.EventTimes{c}(:,newnum) = bck{c}(:,oldnum);
    end
    
    bck = handles.EventSelected;
    for c = 1:length(bck)
        handles.EventSelected{c} = cell(size(bck{c},1),handles.TotalFileNumber);
        handles.EventSelected{c}(:,newnum) = bck{c}(:,oldnum);
    end
    
    bck = handles.Properties;
    
    handles = loadProperties(handles);
    
    handles.Properties.Names(newnum) = bck.Names(oldnum);
    handles.Properties.Values(newnum) = bck.Values(oldnum);
    handles.Properties.Types(newnum) = bck.Types(oldnum);
    
    bck = handles.FileLength(:,oldnum);
    handles.FileLength = zeros(1,handles.TotalFileNumber);
    handles.FileLength(newnum) = bck;
    
    
% --------------------------------------------------------------------
function menu_AutoApplyYLim_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoApplyYLim (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    if handles.menu_AutoApplyYLim.Checked
        handles.menu_AutoApplyYLim.Checked = 'off';
    else
        handles.menu_AutoApplyYLim.Checked = 'on';
        if handles.menu_AutoApplyYLim.Checked
            if handles.menu_DisplayValues.Checked
                % UPDATE THIS 

%                 if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
%                     handles.axes_Channel1.YLim = handles.axes_Events.YLim;
%                 elseif handles.menu_AutoLimits2.Checked
%                     handles.axes_Channel2.YLim = handles.axes_Events.YLim;
%                 end
            end
        end
    end
    guidata(hObject, handles);
    
    
function dbase = GetDBase(handles)
    
    dbase.PathName = handles.DefaultRootPath;
    dbase.Times = handles.DatesAndTimes;
    dbase.FileLength = handles.FileLength;
    dbase.SoundFiles = handles.sound_files;
    dbase.ChannelFiles = handles.chan_files;
    dbase.SoundLoader = handles.sound_loader;
    dbase.ChannelLoader = handles.chan_loader;
    dbase.Fs = handles.fs;
    
    dbase.SegmentThresholds = handles.SoundThresholds;
    dbase.SegmentTimes = handles.SegmentTimes;
    dbase.SegmentTitles = handles.SegmentTitles;
    dbase.SegmentIsSelected = handles.SegmentSelection;
    
    dbase.MarkerTimes = handles.MarkerTimes;
    dbase.MarkerTitles = handles.MarkerTitles;
    dbase.MarkerIsSelected = handles.MarkerSelection;
    
    dbase.EventChannels = handles.EventChannels;
    dbase.EventSources = handles.EventSources;
    dbase.EventFunctions = handles.EventFunctions;
    dbase.EventDetectors = handles.EventDetectors;
    dbase.EventThresholds = handles.EventThresholds;
    dbase.EventTimes = handles.EventTimes;
    dbase.EventIsSelected = handles.EventSelected;
    dbase.EventParameters = handles.EventParameters;
    dbase.EventXLims = handles.EventXLims;
    dbase.EventParts = handles.EventParts;

    dbase.Properties = handles.Properties;
    
    dbase.AnalysisState.SourceList = handles.popup_Channel1.String;
    dbase.AnalysisState.EventList = handles.popup_EventListAlign.String;
    dbase.AnalysisState.CurrentFile = getCurrentFileNum(handles);
    dbase.AnalysisState.EventWhichPlot = handles.EventWhichPlot;
    dbase.AnalysisState.EventLims = handles.EventXLims;
    
    % Add any other custom fields from the original dbase that might exist to
    % the exported dbase
    if isfield(handles, 'OriginalDbase')
        originalFields = fieldnames(handles.OriginalDbase);
        for k = 1:length(originalFields)
            fieldName = originalFields{k};
            if ~isfield(dbase, fieldName)
                dbase.(fieldName) = handles.OriginalDbase.(fieldName);
            end
        end
    end
    
function suppressStupidCallbackWarnings()
    edit_FileNumber_Callback;
    edit_FileNumber_CreateFcn;
    push_PreviousFile_Callback;
    push_NextFile_Callback;
    list_Files_Callback;
    list_Files_CreateFcn;
    push_Properties_Callback;
    slider_Time_Callback;
    slider_Time_CreateFcn;
    menu_Experiment_Callback;
    push_Play_Callback;
    push_TimescaleRight_Callback;
    push_TimescaleLeft_Callback;
    edit_Timescale_Callback;
    edit_Timescale_CreateFcn;
    context_Sonogram_Callback;
    menu_AlgorithmList_Callback;
    menu_AutoCalculate_Callback;
    AlgorithmMenuClick;
    FilterMenuClick;
    push_Calculate_Callback;
    menu_ColorScale_Callback;
    menu_FreqLimits_Callback;
    context_Amplitude_Callback;
    menu_AutoThreshold_Callback;
    menu_AmplitudeAxisRange_Callback;
    menu_SmoothingWindow_Callback;
    click_Amplitude;
    menu_SetThreshold_Callback;
    click_loadfile;
    menu_LongFiles_Callback;
    context_Segments_Callback;
    menu_SegmenterList_Callback;
    SegmenterMenuClick;
    click_segmentaxes;
    push_Segment_Callback;
    menu_AutoSegment_Callback;
    menu_SegmentParameters_Callback;
    menu_DeleteAll_Callback;
    menu_UndeleteAll_Callback;
    popup_Function1_Callback;
    popup_Function1_CreateFcn;
    popup_Function2_Callback;
    popup_Function2_CreateFcn;
    popup_Channel1_Callback;
    popup_Channel1_CreateFcn;
    popup_Channel2_Callback;
    popup_Channel2_CreateFcn;
    context_Channel1_Callback;
    menu_PeakDetect1_Callback;
    context_Channel2_Callback;
    menu_PeakDetect2_Callback;
    menu_AllowYZoom1_Callback;
    menu_AllowYZoom2_Callback;
    menu_AutoLimits1_Callback;
    menu_AutoLimits2_Callback;
    menu_SetLimits1_Callback;
    menu_SetLimits2_Callback;
    popup_EventDetector1_Callback;
    popup_EventDetector1_CreateFcn;
    popup_EventDetector2_Callback;
    popup_EventDetector2_CreateFcn;
    menu_Events1_Callback;
    menu_EventAutoDetect1_Callback;
    menu_EventAutoThreshold1_Callback;
    menu_UpdateEventThresholdDisplay1_Callback;
    menu_Events2_Callback;
    menu_EventAutoDetect2_Callback;
    menu_EventAutoThreshold2_Callback;
    menu_UpdateEventThresholdDisplay2_Callback;
    push_Detect1_Callback;
    push_Detect2_Callback;
    menu_ChannelColors1_Callback;
    menu_PlotColor1_Callback;
    menu_ThresholdColor1_Callback;
    menu_ChannelColors2_Callback;
    menu_PlotColor2_Callback;
    menu_ThresholdColor2_Callback;
    push_BrightnessUp_Callback;
    push_BrightnessDown_Callback;
    push_OffsetUp_Callback;
    push_OffsetDown_Callback;
    menu_AmplitudeColors_Callback;
    menu_AmplitudeColor_Callback;
    menu_AmplitudeThresholdColor_Callback;
    push_PlayMix_Callback;
    edit_SoundWeight_Callback;
    edit_SoundWeight_CreateFcn;
    edit_TopWeight_Callback;
    edit_TopWeight_CreateFcn;
    edit_BottomWeight_Callback;
    edit_BottomWeight_CreateFcn;
    edit_SoundClipper_Callback;
    edit_SoundClipper_CreateFcn;
    edit_TopClipper_Callback;
    edit_TopClipper_CreateFcn;
    edit_BottomClipper_Callback;
    edit_BottomClipper_CreateFcn;
    check_Sound_Callback;
    check_TopPlot_Callback;
    check_BottomPlot_Callback;
    push_SoundOptions_Callback;
    menu_EventsDisplay1_Callback;
    menu_EventsDisplay2_Callback;
    menu_SelectionParameters1_Callback;
    menu_SelectionParameters2_Callback;
    popup_EventList_CreateFcn;
    context_EventViewer_Callback;
    menu_ViewerDisplay_Callback;
    menu_DisplayValues_Callback;
    menu_DisplayFeatures_Callback;
    menu_AutoDisplayEvents_Callback;
    menu_EventsAxisLimits_Callback;
    context_SoundOptions_Callback;
    menu_SoundWeights_Callback;
    menu_SoundClippers_Callback;
    menu_PlaySpeed_Callback;
    menu_ProgressBar_Callback;
    menu_ProgressSoundWave_Callback;
    menu_ProgressSonogram_Callback;
    menu_ProgressSegments_Callback;
    menu_ProgressAmplitude_Callback;
    menu_ProgressTop_Callback;
    menu_ProgressBottom_Callback;
    ChangeProgress;
    menu_XAxis_Callback;
    menu_Yaxis_Callback;
    menu_YAxis_Callback;
    XAxisMenuClick;
    YAxisMenuClick;
    popup_Export_Callback;
    popup_Export_CreateFcn;
    push_Export_Callback;
    push_ExportOptions_Callback;
    radio_Matlab_Callback;
    radio_PowerPoint_Callback;
    radio_Files_Callback;
    radio_Clipboard_Callback;
    push_UpdateFileList_Callback;
    push_WorksheetAppend_Callback;
    UpdateWorksheet;
    click_Worksheet;
    push_WorksheetOptions_Callback;
    push_PageLeft_Callback;
    push_PageRight_Callback;
    menu_FrequencyZoom_Callback;
    context_Worksheet_Callback;
    menu_WorksheetDelete_Callback;
    menu_SortChronologically_Callback;
    context_WorksheetOptions_Callback;
    menu_OnePerLine_Callback;
    menu_IncludeTitle_Callback;
    menu_EditTitle_Callback;
    menu_WorksheetDimensions_Callback;
    menu_ClearWorksheet_Callback;
    context_ExportOptions_Callback;
    menu_SonogramDimensions_Callback;
    menu_ScreenResolution_Callback;
    menu_SonogramExport_Callback;
    menu_CustomResolution_Callback;
    menu_WorksheetView_Callback;
    ViewWorksheet;
    push_Macros_Callback;
    context_Macros_Callback;
    MacrosMenuclick;
    menu_IncludeTimestamp_Callback;
    menu_Portrait_Callback;
    menu_Orientation_Callback;
    menu_Landscape_Callback;
    menu_ImageResolution_Callback;
    menu_ImageTimescale_Callback;
    menu_ScalebarDimensions_Callback;
    menu_EditFigureTemplate_Callback;
    menu_LineWidth1_Callback;
    menu_LineWidth2_Callback;
    setLineWidth;
    menu_BackgroundColor_Callback;
    menu_Colormap_Callback;
    ColormapClick;
    menu_OverlayTop_Callback;
    menu_Overlay_Callback;
    menu_OverlayBottom_Callback;
    menu_SonogramParameters_Callback;
    menu_EventParams1_Callback;
    menu_EventParams2_Callback;
    menu_FunctionParams1_Callback;
    menu_FunctionParams2_Callback;
    menu_Split_Callback;
    menu_SourceSoundAmplitude_Callback;
    menu_SourceTopPlot_Callback;
    menu_SourceBottomPlot_Callback;
    menu_Concatenate_Callback;
    menu_DontPlot_Callback;
    menu_IncludeSoundNone_Callback;
    menu_IncludeSoundOnly_Callback;
    menu_IncludeSoundMix_Callback;
    menu_PlayReverse_Callback;
    menu_FilterList_Callback;
    menu_FilterParameters_Callback;
    menu_FilterSound_Callback;
    menu_AddProperty_Callback;
    context_Properties_Callback;
    menu_AddPropertyString_Callback;
    menu_AddPropertyBoolean_Callback;
    menu_AddPropertyList_Callback;
    menu_RemoveProperty_Callback;
    menu_Search_Callback;
    menu_SearchNew_Callback;
    menu_SearchAnd_Callback;
    menu_SearchOr_Callback;
    menu_SearchNot_Callback;
    menu_RenameProperty_Callback;
    menu_FillProperty_Callback;
    menu_DefaultPropertyValue_Callback;
    menu_CleanUpList_Callback;
    menu_ProgressBarColor_Callback;
    menu_AnimationNone_Callback;
    menu_AnimationProgressBar_Callback;
    menu_AnimationArrowAbove_Callback;
    menu_AnimationArrowBelow_Callback;
    menu_Animation_Callback;
    menu_ValueFollower_Callback;
    menu_SonogramFollower_Callback;
    menu_ScalebarHeight_Callback;
    context_UpdateList_Callback;
    menu_ChangeFiles_Callback;
    menu_DeleteFiles_Callback;
    menu_AutoApplyYLim_Callback;
    
    
% --- Executes on button press in ShowHelpButton.
function ShowHelpButton_Callback(hObject, eventdata, handles)
    % hObject    handle to ShowHelpButton (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    msgbox(eg_HelpText(handles), 'electro_gui info and help:');
    
    
% --------------------------------------------------------------------
function center_Timescale_Callback(hObject, eventdata, handles)
    % hObject    handle to center_Timescale (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % When user right clicks on axes_Sonogram, and selects "Center timescale",
    %   display a popup so they can select a center time (default is where they
    %   right-click), and a radius (how much time on either side of center time
    %   to display), then set the timescale accordingly
    
    handles = guidata(hObject);
    
    % Get time where user right-clicks
    click_position = handles.axes_Sonogram.CurrentPoint;
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
    handles = centerTimescale(handles, centerTime, radiusTime);
    
    guidata(hObject, handles);
    
function handles = eg_PopulateSoundSources(handles)
    
    % Set up list of sources for the sound axes
    sourceStrings = {'Sound'};
    for c = 1:length(handles.chan_files)
        if ~isempty(handles.chan_files{c})
            sourceStrings{end+1} = sprintf('Channel %d', c);
        end
    end
    sourceStrings{end+1} = 'Calculated';
    
    sourceIndices = num2cell(0:length(handles.chan_files));
    sourceIndices{end+1} = 'calculated';
    
    handles.popup_SoundSource.String = sourceStrings;
    handles.popup_SoundSource.UserData = sourceIndices;
    
    
% --- Executes on selection change in popup_SoundSource.
function popup_SoundSource_Callback(hObject, eventdata, handles)
    % hObject    handle to popup_SoundSource (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = cellstr(hObject.String) returns popup_SoundSource contents as cell array
    %        contents{hObject.Value} returns selected item from popup_SoundSource
    
    % Handle a user change of the "Sound source" popup menu.
    % This menu controls the handles.SoundChannel variable, which determines
    % which channel is used for displaying the spectrogram etc.
    sourceIndices = handles.popup_SoundSource.UserData;
    idx = handles.popup_SoundSource.Value;
    handles.SoundChannel = sourceIndices{idx};
    
    if strcmp(handles.SoundChannel, 'calculated')
        % Allow user to input expression for calculated sound channel
        expression = inputdlg('Enter expression for calculated channel, using ''sound'', ''chan1'', ''chan2'', etc. as variables.', 'Input calculated channel expression', 1, {handles.SoundExpression});
    
        if isempty(expression) || isempty(strtrim(expression{1}))
            % User did not provide an expression - default to normal sound
            % channel.
            handles.SoundChannel = sourceIndices{1};
            handles.SoundExpression = '';
        else
            handles.SoundExpression = expression{1};
        end
    end
    
    handles = eg_LoadFile(handles);
    guidata(hObject, handles);
    
% --- Executes during object creation, after setting all properties.
function popup_SoundSource_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to popup_SoundSource (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(hObject.BackgroundColor, get(0,'defaultUicontrolBackgroundColor'))
        hObject.BackgroundColor = 'white';
    end
    


% --- Executes on selection change in popup_EventListData.
function popup_EventListData_Callback(hObject, eventdata, handles)
% hObject    handle to popup_EventListData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_EventListData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventListData

handles = UpdateEventViewer(handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popup_EventListData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_EventListData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
