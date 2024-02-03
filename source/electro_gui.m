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
    
    % Last Modified by GUIDE v2.5 04-May-2023 10:21:37
    
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
    
    % Gather all electro_gui plugins
    handles = gatherPlugins(handles);
    
    % Default sound to display is the designated sound channel
    handles.SoundChannel = 0;
    handles.SoundExpression = '';
    
    % Unread file marker:
    handles.UnreadFileMarker = '> ';
    handles.FileEntryOpenTag = '<HTML><FONT COLOR=000000>';
    handles.FileEntryCloseTag = '</FONT></HTML>';
    
    handles = setSegmentAndMarkerColors(handles);

    % File caching settings
    handles.EnableFileCaching = true;
    handles.BackwardFileCacheSize = 1;
    handles.ForwardFileCacheSize = 3;
    handles = resetFileCache(handles);
    
    % Get current logged in username
    lic = license('inuse');
    user = lic(1).user;
    f = regexpi(user,'[A-Z1-9]');
    user = user(f);
    
    % Ensure a defaults file exists for the user
    handles = ensureDefaultsFileExists(handles, user);
    
    % Prompt user to choose a defaults file, then load it.
    handles = chooseAndLoadDefaultsFile(handles);

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
    
    % Set initial parameter values
    handles.SegmenterParams.Names = {};
    handles.SegmenterParams.Values = {};
    handles.SonogramParams.Names = {};
    handles.SonogramParams.Values = {};
    handles.EventParams{1}.Names = {};
    handles.EventParams{1}.Values = {};
    handles.EventParams{2}.Names = {};
    handles.EventParams{2}.Values = {};
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
            gcp();
        catch
            warning('Failed to start parallel pool - maybe the parallel computing toolbox is not installed? Disabling file caching.');
            handles.EnableFileCaching = false;
        end
    end
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes electro_gui wait for user response (see UIRESUME)
    % uiwait(handles.figure_Main);

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
    
    handles.WorksheetHandles = [];
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
    set(ch(3-handles.AmplitudeSource),'checked','on');
    
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
            set(ch(c),'checked','on');
        end
    end
    
    ch = handles.menu_Animation.Children;
    ischeck = false;
    for c = 1:length(ch)
        if strcmp(ch(c).Label,handles.AnimationType)
            set(ch(c),'checked','on');
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
    [handles, handles.menu_Algorithm] = populatePluginMenuList(handles, 'egs', handles.DefaultSonogramPlotter, handles.menu_AlgorithmList, 'electro_gui(''AlgorithmMenuClick'',gcbo,[],guidata(gcbo))');
    
    % Populate segmenting algorithm plugin menu
    [handles, handles.menu_Segmenter] = populatePluginMenuList(handles, 'egg', handles.DefaultSegmenter, handles.menu_SegmenterList, 'electro_gui(''SegmenterMenuClick'',gcbo,[],guidata(gcbo))');

    % Populate filter algorithm plugin menu
    [handles, handles.menu_Filter] = populatePluginMenuList(handles, 'egf', handles.DefaultFilter, handles.menu_FilterList, 'electro_gui(''FilterMenuClick'',gcbo,[],guidata(gcbo))');

    % Populate colormap plugin menu
    handles.menu_ColormapList(1) = uimenu(handles.menu_Colormap, 'Label', '(Default)', 'callback','electro_gui(''ColormapClick'', gcbo,[],guidata(gcbo))');
    [handles, handles.menu_ColormapList] = populatePluginMenuList(handles, 'egc', '(Default)', handles.menu_Colormap, 'electro_gui(''ColormapClick'',gcbo,[],guidata(gcbo))');

    % Populate macro plugin menu
    [handles, handles.menu_Macros] = populatePluginMenuList(handles, 'egm', [], handles.context_Macros, 'electro_gui(''MacrosMenuclick'',gcbo,[],guidata(gcbo))');

    % Populate x-axis event feature algorithm plugin menu
    [handles, handles.menu_XAxis_List] = populatePluginMenuList(handles, 'ega', handles.DefaultEventFeatureX, handles.menu_XAxis, 'electro_gui(''XAxisMenuClick'',gcbo,[],guidata(gcbo))');
    % Populate y-axis event feature algorithm plugin menu
    [handles, handles.menu_YAxis_List] = populatePluginMenuList(handles, 'ega', handles.DefaultEventFeatureY, handles.menu_YAxis, 'electro_gui(''YAxisMenuClick'',gcbo,[],guidata(gcbo))');

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
        menus(end+1) = uimenu(menuList, 'Label', pluginNames{pluginIdx}, 'callback', callback);
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
    xd = handles.xlimbox.XData;
    shift = handles.slider_Time.Value-xd(1);
    xd = xd+shift;
    handles.xlimbox.XData = xd;
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
    
    tmin = getTimescale(handles);
    tscale = str2double(handles.edit_Timescale.String);
    handles = setTimescale(handles, tmin, tmin+tscale);
    
    guidata(hObject, handles);
    
function [tmin, tmax] = getTimescale(handles)
    xd = handles.xlimbox.XData;
    tmin = xd(1);
    tmax = xd(2);
    
function handles = setTimescale(handles, minTime, maxTime)
    xd = handles.xlimbox.XData;
    xd([1, 4, 5]) = minTime;
    xd([2, 3]) = maxTime;
    handles.xlimbox.XData = xd;
    handles = eg_EditTimescale(handles);
    
function handles = centerTimescale(handles, centerTime, radiusTime)
    handles = setTimescale(handles, centerTime - radiusTime, centerTime + radiusTime);
    
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
    
    fileNum = getCurrentFileNum(handles);
    minCacheNum = max(1, fileNum - handles.BackwardFileCacheSize);
    maxCacheNum = min(handles.TotalFileNumber, fileNum + handles.ForwardFileCacheSize);
    
    fileNums = minCacheNum:maxCacheNum;
    [selectedChannelNum1, ~, isSound1] = getSelectedChannel(handles, 1);
    [selectedChannelNum2, ~, isSound2] = getSelectedChannel(handles, 2);
    
    % Add sound files to list of necessary cache files:
    for fileNum = fileNums
        % Add sound file to list
        filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.sound_files(fileNum).name);
        loadersInCache{end+1} = handles.sound_loader;
    
        % Add whatever channel is selected in axes1 to list
        if ~isnan(selectedChannelNum1)
            filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.chan_files{selectedChannelNum1}(fileNum).name);
            if isSound1
                loadersInCache{end+1} = handles.sound_loader;
            else
                loadersInCache{end+1} = handles.chan_loader{selectedChannelNum1};
            end
        end
    
        if ~isnan(selectedChannelNum2)
            % Add whatever channel is selected in axes2 to list
            filesInCache{end+1} = fullfile(handles.DefaultRootPath, handles.chan_files{selectedChannelNum2}(fileNum).name);
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
    
    fileNum = getCurrentFileNum(handles);
    handles.list_Files.Value = fileNum;
    fileList = handles.list_Files.String;
    
    % Remove unread file marker from filename
    if isFileUnread(handles, fileList{fileNum})
        fileList{fileNum} = removeUnreadFileMarker(handles, fileList{fileNum});
        handles.list_Files.String = fileList;
    end
    
    curr = pwd();
    cd(handles.DefaultRootPath);
    
    % Label
    handles.text_FileName.String = handles.sound_files(fileNum).name;
    
    handles.BackupTitle = {'',''};
    
    % Load properties
    handles = eg_LoadProperties(handles);
    
    % Load sound
    handles.sound = [];
    
    soundFilePath = fullfile(handles.DefaultRootPath, handles.sound_files(fileNum).name);

    if handles.EnableFileCaching
        [handles, data] = retrieveFileFromCache(handles, soundFilePath, handles.sound_loader);
        [handles.sound, handles.fs, dt] = data{:};
    else
        try
            soundFilePath = fullfile(handles.DefaultRootPath, handles.sound_files(fileNum).name);
            [handles.sound, handles.fs, dt, ~, ~] = eg_runPlugin(handles.plugins.loaders, handles.sound_loader, soundFilePath, true);
        catch ME
            if ~exist(soundFilePath, 'file')
                error('File not found: %s', soundFilePath);
            else
                rethrow(ME);
            end
        end
    end
    
    handles.DatesAndTimes(fileNum) = dt;
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    handles.FileLength(fileNum) = numSamples;
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
    
    % Set limits
    yl = ylim(handles.axes_Sound);
    xmax = numSamples/handles.fs;
    hold(handles.axes_Sound, 'on');
    handles.xlimbox = plot(handles.axes_Sound, [0, xmax, xmax, 0, 0],[yl(1), yl(1), yl(2), yl(2), yl(1)]*.93,':y', 'LineWidth', 2);
    xlim(handles.axes_Sound, [0, xmax]);
    hold(handles.axes_Sound, 'off');
    box(handles.axes_Sound, 'on');
    
    handles = clearAxes(handles);
        
    % Set xlimits
    handles.axes_Sonogram.XLim = [0, xmax];
    handles.axes_Amplitude.XLim = [0, xmax];
    handles.axes_Channel1.XLim = [0, xmax];
    handles.axes_Channel2.XLim = [0, xmax];
    
    % If file too long
    if numSamples > handles.TooLong
        txt = text(mean(xlim),mean(ylim), 'Long file. Click to load.',...
            'horizontalalignment', 'center', 'Color', 'r', 'fontsize', 14, 'Parent', handles.axes_Sonogram);
        set(txt, 'ButtonDownFcn', 'electro_gui(''click_loadfile'',gcbo,[],guidata(gcbo))');
        cd(curr);
    
        handles.edit_Timescale.String = num2str(numSamples/handles.fs,4);
    
        handles = PlotSegments(handles);
    
        return
    end
    
    % Define callbacks
    handles.axes_Sonogram.ButtonDownFcn = 'electro_gui(''click_sound'',gcbo,[],guidata(gcbo))';
    for child = handles.axes_Sonogram.Children'
        child.ButtonDownFcn = handles.axes_Sonogram.ButtonDownFcn;
    end
    
    handles.axes_Sound.ButtonDownFcn = 'electro_gui(''click_sound'',gcbo,[],guidata(gcbo))';
    for child = handles.axes_Sound.Children'
        child.ButtonDownFcn = handles.axes_Sound.ButtonDownFcn;
    end
    
    % Plot channels
    val = handles.popup_Channel1.Value;
    str = handles.popup_Channel1.String;
    if isempty(strfind(str{val},' - '))
        handles = eg_LoadChannel(handles,1);
        handles = EventSetThreshold(handles,1);
        handles = eg_LoadChannel(handles,2);
        handles = EventSetThreshold(handles,2);
    else
        handles = eg_LoadChannel(handles,2);
        handles = EventSetThreshold(handles,2);
        handles = eg_LoadChannel(handles,1);
        handles = EventSetThreshold(handles,1);
    end
    
    % Plot amplitude
    [handles.amplitude, labs] = eg_CalculateAmplitude(handles);
    
    if ~isempty(handles.amplitude)
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        plot(handles.axes_Amplitude, linspace(0, numSamples/handles.fs, numSamples),handles.amplitude,'Color',handles.AmplitudeColor);
        handles.axes_Amplitude.XTickLabel  = [];
        ylim(handles.axes_Amplitude, handles.AmplitudeLims);
        box(handles.axes_Amplitude, 'off');
        ylabel(handles.axes_Amplitude, labs);
        handles.axes_Amplitude.UIContextMenu = handles.context_Amplitude;
        set(handles.axes_Amplitude, 'ButtonDownFcn','electro_gui(''click_Amplitude'',gcbo,[],guidata(gcbo))');
        for child = handles.axes_Amplitude.Children'
            child.UIContextMenu = handles.axes_Amplitude.UIContextMenu;
        end
        for child = handles.axes_Amplitude.Children'
            child.ButtonDownFcn = handles.axes_Amplitude.ButtonDownFcn;
        end
    
        if handles.SoundThresholds(fileNum)==inf
            if handles.menu_AutoThreshold.Checked
                handles.CurrentThreshold = eg_AutoThreshold(handles.amplitude);
            end
            handles.SoundThresholds(fileNum) = handles.CurrentThreshold;
        else
            handles.CurrentThreshold = handles.SoundThresholds(fileNum);
        end
        handles.SegmentLabelHandles = [];
        handles = SetThreshold(handles);
    end
    
    handles = eg_EditTimescale(handles);
    
    cd(curr);

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
    
function currentFileNum = getCurrentFileNum(handles)
    currentFileNum = str2double(handles.edit_FileNumber.String);
function currentFileName = getCurrentFileName(handles)
    currentFileNum = getCurrentFileNum(handles);
    currentFileName = handles.sound_files(currentFileNum).name;
    
function [selectedChannelNum, selectedChannelName, isSound] = getSelectedChannel(handles, axnum)
    % Return the name and number of the selected channel from the specified
    %   axis. If the name is not a valid channel, selectedChannelNum will be
    %   NaN.
    channelOptionList = handles.popup_Channels(axnum).String;
    selectedChannelName = channelOptionList{handles.popup_Channels(axnum).Value};
    selectedChannelNum = channelNameToNum(selectedChannelName);
    isSound = (selectedChannelNum == 0);
function selectedEventDetector = getSelectedEventDetector(handles, axnum)
    % Return the name of the selected event detector from the specified axis.
    eventDetectorOptionList = handles.popup_EventDetectors(axnum).String;
    selectedEventDetector = eventDetectorOptionList{handles.popup_EventDetectors(axnum).Value};
function selectedEventFunction = getSelectedEventFunction(handles, axnum)
    % Return the name of the selected event detector function (filter) from the
    %   specified axis.
functionOptionList = handles.popup_Functions(axnum).String;
    selectedEventFunction = functionOptionList{handles.popup_Functions(axnum).Value};
function handles = setSelectedEventDetector(handles, axnum, eventDetector)
    % Set the currently selected event detector for the selected axis
    eventDetectorOptionList = handles.popup_EventDetectors(axnum).String;
    newIndex = find(strcmp(eventDetectorOptionList, eventDetector));
    if isempty(newIndex)
        error('Error: Could not set selected event detector to ''%s'', as it is not in the option list.', eventDetector);
    end
    set(handles.popup_EventDetectors(axnum), 'value', newIndex);
function channelName = channelNumToName(channelNum)
    channelName = ['Channel ', num2str(channelNum)];
function channelNum = channelNameToNum(channelName)
    if strcmp(channelName, 'Sound')
        channelNum = 0;
    else
        channelNumMatch = regexp(channelName, 'Channel ([0-9]+)', 'tokens');
        if isempty(channelNumMatch)
            % Not a valid channel name
            channelNum = NaN;
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
    set(handles.popup_Functions(axnum), 'value', newIndex);
    
function [handles, isValidEventDetector] = updateEventDetectorInfo(handles, channelNum, newEventDetector)
    % Update stored event detector info
    isValidEventDetector = isValidPlugin(handles.plugins.eventDetectors, newEventDetector);
    if isnan(channelNum)
        % Not a valid channel
        return
    end
    fileNum = getCurrentFileNum(handles);
    if ~strcmp(getEventDetector(handles, fileNum, channelNum), newEventDetector)
        % This is a different event detector from the one previously stored
        % Have to get new params
        if isValidEventDetector
            [handles.EventParams{fileNum, channelNum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, newEventDetector, 'params');
        else
            handles.EventParams{fileNum, channelNum} = [];
        end
        handles = setEventDetector(handles, fileNum, channelNum, newEventDetector);
    end
    % Get labels for current detector
    if ~strcmp(newEventDetector, handles.nullEventDetector)
        [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, newEventDetector, 'params');
    else
        labels = {};
    end
    % Add empty entry for event times for this new detector function.
    handles.EventTimes{fileNum, channelNum} = cell(1, length(labels));
    handles.EventSelected = [];
    
function [handles, isValidEventFunction] = updateEventFunctionInfo(handles, channelNum, newEventFunction)
    isValidEventFunction = isValidPlugin(handles.plugins.filters, newEventFunction);
    if isnan(channelNum)
        % Not a valid channel
        return
    end
    fileNum = getCurrentFileNum(handles);
    if ~strcmp(getEventFunction(handles, fileNum, channelNum), newEventFunction)
        % This is a different event function (filter)
        % Have to get new params
        if isValidEventFunction
            [handles.EventFunctionParams{fileNum, channelNum}, ~] = eg_runPlugin(handles.plugins.filters, newEventFunction, 'params');
        else
            handles.EventFunctionParams{fileNum, channelNum} = [];
        end
        handles = setEventFunction(handles, fileNum, channelNum, newEventFunction);
    end
    
function handles = eg_LoadChannel(handles,axnum)
    % Load a new channel of data
    
    if handles.popup_Channels(axnum).Value==1
        % This is "(None)" channel selection, so disable everything
        cla(handles.axes_Channel(axnum));
        set(handles.axes_Channel(axnum),'visible','off');
        set(handles.popup_Functions(axnum),'enable','off');
        set(handles.popup_EventDetectors(axnum),'enable','off');
        set(handles.(['push_Detect',num2str(axnum)]),'enable','off');
        handles.SelectedEvent = [];
        handles = UpdateEventBrowser(handles);
        return
    else
        % This is an actual channel selection, enable the axes and function
        % menu.
        set(handles.axes_Channel(axnum),'visible','on');
        set(handles.popup_Functions(axnum),'enable','on');
    end
    
    filenum = getCurrentFileNum(handles);
    [selectedChannelNum, ~, isSound] = getSelectedChannel(handles, axnum);
    
    val = handles.popup_Channels(axnum).Value;
    str = handles.popup_Channels(axnum).String;
    nums = [];
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    if val <= length(str)-sum(nums)
        % No idea what this signifies
        try
            if isSound
                loader = handles.sound_loader;
                filePath = fullfile(handles.DefaultRootPath, handles.sound_files(filenum).name);
            else
                loader = handles.chan_loader{selectedChannelNum};
                filePath = fullfile(handles.DefaultRootPath, handles.chan_files{selectedChannelNum}(filenum).name);
            end
        
            if handles.EnableFileCaching
                [handles, data] = retrieveFileFromCache(handles, filePath, loader);
                [handles.loadedChannelData{axnum}, ~, ~, handles.Labels{axnum}, ~] = data{:};
            else
                [handles.loadedChannelData{axnum}, ~, ~, handles.Labels{axnum}, ~] = eg_runPlugin(handles.plugins.loaders, loader, filePath, true);
            end
        catch ME
            if ~exist(filePath, 'file')
                error('File not found: %s', filePath);
            else
                rethrow(ME);
            end
        end
    else
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        ev = zeros(1, numSamples);
        indx = val-(length(str)-sum(nums));
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if f>1
            g = indx-cs(f-1);
        else
            g = indx;
        end
        tm = handles.EventTimes{f}{g,filenum};
        issel = handles.EventSelected{f}{g,filenum};
        ev(tm(issel==1)) = 1;
        handles.loadedChannelData{axnum} = ev;
        str = str{val};
        f = strfind(str,' - ');
        f = f(end);
        handles.Labels{axnum} = str(f+3:end);
    end
    
    if handles.popup_Functions(axnum).Value > 1
        % This is not the "(Raw)" function - apply the selected function
        allFunctionNames = handles.popup_Functions(axnum).String;
        str = allFunctionNames{handles.popup_Functions(axnum).Value};
        val = handles.loadedChannelData{axnum};
        f = strfind(str,' - ');
        if isempty(f)
            [chan, lab] = eg_runPlugin(handles.plugins.filters, str, val, handles.fs, handles.FunctionParams{axnum});
            if iscell(lab)
                handles.Labels{axnum} = lab{1};
                handles.loadedChannelData{axnum} = chan{1};
                handles.BackupChan{axnum} = chan;
                handles.BackupLabel{axnum} = lab;
                handles.BackupTitle{axnum} = str;
                str = handles.popup_Functions(axnum).String;
                ud1 = handles.popup_Function1.UserData;
                ud2 = handles.popup_Function2.UserData;
                str2 = {};
                udn1 = {};
                udn2 = {};
                for c = 1:length(str)
                    if c==handles.popup_Functions(axnum).Value
                        for d = 1:length(lab)
                            str2{end+1} = [str{c} ' - ' lab{d}];
                            udn1{end+1} = ud1{c};
                            udn2{end+1} = ud2{c};
                        end
                    else
                        str2{end+1} = str{c};
                        udn1{end+1} = ud1{c};
                        udn2{end+1} = ud2{c};
                    end
                end
                set(handles.popup_Function1,'string',str2,'userdata',udn1);
                set(handles.popup_Function2,'string',str2,'userdata',udn2);
            else
                handles.Labels{axnum} = lab;
                handles.loadedChannelData{axnum} = chan;
            end
        else
            strall = handles.popup_Functions(axnum).String;
            count = 0;
            for c = 1:handles.popup_Functions(axnum).Value
                count = count + strcmp(strall{c}(1:min([f-1 length(strall{c})])),str(1:f-1));
            end
            if strcmp(handles.BackupTitle{axnum},str(1:f-1))
                handles.Labels{axnum} = handles.BackupLabel{axnum}{count};
                handles.loadedChannelData{axnum} = handles.BackupChan{axnum}{count};
            else
                [chan, lab] = eg_runPlugin(handles.plugins.filters, str(1:f-1), val, handles.fs, handles.FunctionParams{axnum});
                handles.Labels{axnum} = lab{count};
                handles.loadedChannelData{axnum} = chan{count};
                handles.BackupChan{axnum} = chan;
                handles.BackupLabel{axnum} = lab;
                handles.BackupTitle{axnum} = str(1:f-1);
            end
        end
    end
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    if length(handles.loadedChannelData{axnum}) < numSamples
        indx = fix(linspace(1, length(handles.loadedChannelData{axnum}), numSamples));
        chan = handles.loadedChannelData{axnum};
        handles.loadedChannelData{axnum} = chan(indx);
    end
    
    handles = eg_PlotChannel(handles,axnum);
    
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
    
    handles = eg_Overlay(handles);
    
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
                    fileNum = getCurrentFileNum(handles);
                    filePath = fullfile(handles.DefaultRootPath, handles.sound_files(fileNum).name);
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
                        fileNum = getCurrentFileNum(handles);
                        filePath = fullfile(handles.DefaultRootPath, handles.chan_files{channelIdx}(fileNum).name);
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
            fileNum = getCurrentFileNum(handles);
            filePath = fullfile(handles.DefaultRootPath, handles.chan_files{soundChannel}(fileNum).name);
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
        if strcmp(handles.menu_Filter(c).Checked,'on')
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
        h = plot(t, handles.loadedChannelData{axnum});
    end

    hold(handles.axes_Channel(axnum), 'off');
    set(h,'Color',handles.ChannelColor(axnum,:));
    set(h,'LineWidth',handles.ChannelLineWidth(axnum));
    xlim(handles.axes_Channel(axnum), tlimits);
    
    handles.axes_Channel(axnum).XTickLabel = [];
    box(handles.axes_Channel(axnum), 'off');
    ylabel(handles.axes_Channel(axnum), handles.Labels{axnum});
    
    handles.axes_Channel(axnum).UIContextMenu = handles.context_Channels(axnum);
    handles.axes_Channel(axnum).ButtonDownFcn = 'electro_gui(''click_Channel'',gcbo,[],guidata(gcbo))';
    set(handles.axes_Channel(axnum).Children, 'UIContextMenu', handles.axes_Channel(axnum).UIContextMenu);
    set(handles.axes_Channel(axnum),Children, 'ButtonDownFcn', handles.axes_Channel(axnum).ButtonDownFcn);
    
function handles = SetThreshold(handles)
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
            handles = PlotSegments(handles);
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
    set(handles.axes_Segments,'UIContextMenu',handles.context_Segments,'ButtonDownFcn','electro_gui(''click_segmentaxes'',gcbo,[],guidata(gcbo))');
    
function handles = SegmentSounds(handles)
    
    if ~isempty(findobj('Parent',handles.axes_Sonogram,'Type','text'))
        return
    end
    
    for c = 1:length(handles.menu_Segmenter)
        if strcmp(handles.menu_Segmenter(c).Checked,'on')
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
    
    handles = PlotSegments(handles);
    
function [markerHandles, labelHandles] = CreateMarkers(handles, ax, times, titles, selects, selectColor, unselectColor, activeColor, inactiveColor, yExtent)
    % Create the markers for a set of timed segments (used for plotting both
    % "segments" and "markers")
    
    % Create a time vector that corresponds to the loaded audio samples
    [handles, numSamples] = eg_GetNumSamples(handles);
    xs = linspace(0, numSamples/handles.fs, numSamples);
    
    y0 = yExtent(1);
    y1 = yExtent(1) + (yExtent(2) - yExtent(1))*0.3;
    % y2 = yExtent(2);
    
    markerHandles = gobjects().empty;
    labelHandles = gobjects().empty;
    
    % Loop over stored segment start/end times pairs
    for c = 1:size(times,1)
        % Extract the start (x1) and end (x2) times of this segment
        x1 = xs(times(c,1));
        x2 = xs(times(c,2));
        if selects(c)
            faceColor = selectColor;
        else
            faceColor = unselectColor;
        end
        % Create a rectangle to represent the segment
        markerHandles(c) = patch(ax, [x1 x2 x2 x1], [y0 y0 y1 y1], faceColor);
        % Create a text graphics object right above the middle of the segment
        % rectangle
        labelHandles(c) = text(ax, (x1+x2)/2,y1,titles(c), 'VerticalAlignment', 'bottom');
    %     if c==1
    %         % Set the first segment to be the selected one
    %         set(markerHandles(c), 'edgecolor', activeColor, 'LineWidth', 2);
    %     else
            markerHandles(c).EdgeColor = inactiveColor;
            markerHandles(c).LineWidth = 1;
    %     end
    end
    % Attach click handler "click_segment" to segment rectangle
    set(markerHandles,'ButtonDownFcn','electro_gui(''click_segment'',gcbo,[],guidata(gcbo))');
    
function handles = PlotSegments(handles, activeSegmentNum, activeMarkerNum)
    if ~exist('activeSegmentNum', 'var')
        activeSegmentNum = [];
    end
    if ~exist('activeMarkerNum', 'var')
        activeMarkerNum = [];
    end
    
    if isempty(activeMarkerNum)
        activeType = 'segment';
        if isempty(activeSegmentNum)
            % No active segment or marker? Set it to active segment #1
            activeSegmentNum = 1;
        end
    else
        activeType = 'marker';
    end
    
    % Get segment axes
    ax = handles.axes_Segments;
    % Clear segment axes
    cla(ax);
    hold(ax, 'on');
    % Clear segment handles and segment label handles
    handles.SegmentHandles = [];
    handles.SegmentLabelHandles = [];
    % Clear marker handles and marker label handles
    handles.MarkerHandles = [];
    handles.MarkerLabelHandles = [];
    
    filenum = getCurrentFileNum(handles);
    
    [handles.SegmentHandles, handles.SegmentLabelHandles] = CreateMarkers(handles, ...
        handles.axes_Segments, ...
        handles.SegmentTimes{filenum}, ...
        handles.SegmentTitles{filenum}, ...
        handles.SegmentSelection{filenum}, ...
        handles.SegmentSelectColor, handles.SegmentUnSelectColor, ...
        handles.SegmentActiveColor, handles.SegmentInactiveColor, [-1, 1]);
    
    [handles.MarkerHandles, handles.MarkerLabelHandles] = CreateMarkers(handles, ...
        handles.axes_Segments, ...
        handles.MarkerTimes{filenum}, ...
        handles.MarkerTitles{filenum}, ...
        handles.MarkerSelection{filenum}, ...
        handles.MarkerSelectColor, handles.MarkerUnSelectColor, ...
        handles.MarkerActiveColor, handles.MarkerInactiveColor, [1, 3]);
    
    % Set any unselected segments to have a gray face color
    set(handles.SegmentHandles(find(handles.SegmentSelection{filenum}==0)),'facecolor',handles.SegmentUnSelectColor);
    % Center-justify segment label text
    set(handles.SegmentLabelHandles,'horizontalalignment','center','verticalalignment','bottom');
    % Get current time-zoom state of audio data
    xd = handles.xlimbox.XData;
    % Set time-zoom state of segment axes to match audio axes
    xlim(ax, xd(1:2));
    % Set y-scale of axes
    ylim(ax, [-2 3.5]);
    % Get figure background color
    bg = handles.figure_Main.Color;
    % Set segment axes background & axis colors to the figure background color, I guess to hide them
    set(ax,'xcolor',bg,'ycolor',bg,'Color',bg);
    % Assign context menu and click listener to segment axes
    set(ax,'UIContextMenu',handles.context_Segments,'ButtonDownFcn','electro_gui(''click_segmentaxes'',gcbo,[],guidata(gcbo))');
    % Assign context menu to all children of segment axes (segments and labels)
    for child = ax.Children'
        child.UIContextMenu = ax.UIContextMenu;
    end
    % Assign key press function to figure (labelsegment) for labeling segments
    handles.figure_Main.KeyPressFcn = 'electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))';
    
    switch activeType
        case 'segment'
            handles = SetActiveSegment(handles, activeSegmentNum);
        case 'marker'
            handles = SetActiveMarker(handles, activeMarkerNum);
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
    
    
function FilterMenuClick(hObject, ~, handles)
    
    for c = 1:length(handles.menu_Filter)
        handles.menu_Filter.Checked = 'off';
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
    
    xd = handles.xlimbox.XData;
    cla(handles.axes_Sound);
    [handles, filtered_sound] = eg_GetSound(handles, true);
    [handles, numSamples] = eg_GetNumSamples(handles);
    h = eg_peak_detect(handles.axes_Sound, linspace(0, numSamples/handles.fs, numSamples), filtered_sound);
    [h.Color] = deal('c');
    set(handles.axes_Sound,'XTick',[],'YTick',[]);
    set(handles.axes_Sound,'Color',[0 0 0]);
    axis(handles.axes_Sound, 'tight');
    yl = max(abs(ylim(handles.axes_Sound)));
    ylim(handles.axes_Sound, [-yl*1.2 yl*1.2]);
    
    yl = ylim(handles.axes_Sound);
    hold(handles.axes_Sound, 'on');
    handles.xlimbox = plot(handles.axes_Sound, [xd(1) xd(2) xd(2) xd(1) xd(1)],[yl(1) yl(1) yl(2) yl(2) yl(1)]*.93,':y','LineWidth',2);
    xlim(handles.axes_Sound, [0, numSamples/handles.fs]);
    hold(handles.axes_Sound, 'off');
    box(handles.axes_Sound, 'on');
    
    set(handles.axes_Sonogram,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
    ch = handles.axes_Sonogram.Children;
    [ch.ButtonDownFcn] = deal(handles.axes_Sonogram.ButtonDownFcn);
    
    set(handles.axes_Sound,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
    ch = handles.axes_Sound.Children;
    [ch.ButtonDownFcn] = deal(handles.axes_Sound.ButtonDownFcn);
    
    [handles.amplitude, ~] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent', handles.axes_Amplitude, 'LineStyle', '-');
    plt.YData = handles.amplitude;
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
function handles = eg_EditTimescale(handles)
    
    xd = handles.xlimbox.XData;
    if xd(1) < 0
        xd([1 4:5]) = 0;
    end
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    if xd(2) > numSamples/handles.fs
        xd(2:3) = numSamples/handles.fs;
    end
    
    handles.xlimbox.XData = xd;
    
    handles.edit_Timescale.String = num2str(xd(2)-xd(1),4);
    
    if handles.menu_AutoCalculate.Checked
        handles = eg_PlotSonogram(handles);
    else
        xlim(handles.axes_Sonogram, xd(1:2));
        handles.axes_Sonogram.UIContextMenu = handles.context_Sonogram;
    
        set(handles.axes_Sonogram,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
        ch = handles.axes_Sonogram.Children;
        ch.ButtonDownFcn = handles.axes_Sonogram.ButtonDownFcn;
    
        set(handles.axes_Sound,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
        ch = handles.axes_Sound.Children;
        ch.ButtonDownFcn = handles.axes_Sound.ButtonDownFcn;
    end
    
    xlim(handles.axes_Amplitude, xd(1:2));
    xlim(handles.axes_Segments, xd(1:2));
    
    for axnum = 1:2
        yl = ylim(handles.axes_Channel(axnum));
        xlim(handles.axes_Channel(axnum), xd(1:2));
        if handles.menu_PeakDetects(axnum).Checked
            handles = eg_PlotChannel(handles, axnum);
        end
        ylim(handles.axes_Channel(axnum), yl);
    end
    
    handles.slider_Time.Min = 0;
    handles.slider_Time.Max = numSamples/handles.fs-(xd(2)-xd(1))+eps;
    handles.slider_Time.Value = xd(1);
    stp = min([1 (xd(2)-xd(1))/((numSamples/handles.fs-(xd(2)-xd(1)))+eps)]);
    handles.slider_Time.SliderStep = [0.1*stp 0.5*stp];
    
    for c = 1:length(handles.SegmentLabelHandles)
        if ishandle(handles.SegmentLabelHandles(c))
            pos = get(handles.SegmentLabelHandles(c), 'Extent');
            if pos(1)<xd(1) || pos(1)+pos(3)>xd(2)
                handles.SegmentLabelHandles(c).Visible = 'off';
            else
                handles.SegmentLabelHandles(c).Visible = 'on';
            end
        end
    end
    
    handles = eg_Overlay(handles);
    
function handles = eg_PlotSonogram(handles)
    [handles, sound] = eg_GetSound(handles);
    
    xd = handles.xlimbox.XData;
    xl = xd(1:2);
    if xl(1)>=xl(2)
        xl(1) = xl(2)-1;
    end
    xlp = round(xl*handles.fs);
    if xlp(1)<1; xlp(1) = 1; end
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    if xlp(2)>numSamples; xlp(2) = numSamples; end
    
    for c = 1:length(handles.menu_Algorithm)
        if strcmp(handles.menu_Algorithm(c).Checked,'on')
            alg = handles.menu_Algorithm(c).Label;
        end
    end
    
    cla(handles.axes_Sonogram);
    xlim(handles.axes_Sonogram, xl);
    if handles.menu_FrequencyZoom.Checked
        ylim(handles.axes_Sonogram, handles.CustomFreqLim);
    else
        ylim(handles.axes_Sonogram, handles.FreqLim);
    end
    handles.ispower = eg_runPlugin(handles.plugins.spectrums, alg, ...
        handles.axes_Sonogram, sound(xlp(1):xlp(2)), handles.fs, ...
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
        set(ch(c),'UIContextMenu',handles.axes_Sonogram.UIContextMenu);
    end
    
    set(handles.axes_Sonogram,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
    ch = handles.axes_Sonogram.Children;
    for c = 1:length(ch)
        set(ch(c),'ButtonDownFcn',handles.axes_Sonogram.ButtonDownFcn);
    end
    
    
function click_sound(hObject, ~, handles)
    % Callback for a mouse click on the spectrogram
    
    current_axes = gca();
    
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
    
        % Get x bounds of zoom box in top plot
        xd = handles.xlimbox.XData;
    
        if rect(3) == 0
            % Click/drag box has zero width, so we're going to shift the zoom
            % box so the left size aligns with the cllick location
            shift = rect(1)-xd(1);
            xd = xd+shift;
        else
            if handles.menu_FrequencyZoom.Checked && (hObject==handles.axes_Sonogram || hObject.Parent==handles.axes_Sonogram)
                % We're zooming along the y-axis (frequency) as well as x
                rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
                rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
                handles.CustomFreqLim = [rect(2) rect(2)+rect(4)];
                ylim([rect(2) rect(2)+rect(4)]);
            end
            xd([1 4:5]) = rect(1);
            xd(2:3) = rect(1)+rect(3);
        end
        % Update zoom box in top plot
        handles.xlimbox.XData = xd;
        % Update spectrogram scales
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType, 'extend')
        % Shift-click
        %   Shift zoom box so the right side aligns with click location
        pos = current_axes.CurrentPoint;
        xd = handles.xlimbox.XData;
        if pos(1,1) < xd(1)
            return
        end
        xd(2:3) = pos(1,1);
        handles.xlimbox.XData = xd;
        % Update spectrogram scales
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        % Double-click
        %   Reset zoom
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        xd = [0 numSamples/handles.fs numSamples/handles.fs 0 0];
        % Update zoom box in top plot
        handles.xlimbox.XData = xd;
        if handles.menu_FrequencyZoom.Checked
            % We're resetting y-axis (frequency) zoom too
            handles.CustomFreqLim = handles.FreqLim;
        end
        % Update spectrogram scales
        handles = eg_EditTimescale(handles);
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
    
        handles = CreateNewMarker(handles, x);
    end
    
    guidata(gca, handles);
    
function handles = CreateNewMarker(handles, x)
    % Create a new marker from time x(1) to time x(2)
    filenum = getCurrentFileNum(handles);
    handles.MarkerTimes{filenum}(end+1, :) = x;
    handles.MarkerSelection{filenum}(end+1) = 1;
    handles.MarkerTitles{filenum}{end+1} = '';
    % Replot all markers & segments
    handles = PlotSegments(handles);
    
    % Sort markers chronologically to keep things neat
    [handles, order] = SortMarkers(handles, filenum);
    [~, mostRecentMarkerNum] = max(order);
    % Set active marker again, so the same marker is still active
    handles = PlotSegments(handles);
    handles = SetActiveMarker(handles, mostRecentMarkerNum);
    
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
    
function handles = SetActiveMarker(handles, markerNum)
    % Inactivate all markers
    set(handles.MarkerHandles, 'edgecolor', handles.MarkerInactiveColor, 'LineWidth', 1);
    % Inactivate all segments
    set(handles.SegmentHandles, 'edgecolor', handles.SegmentInactiveColor, 'LineWidth', 1);
    % Activate requested marker
    if ~isempty(handles.MarkerHandles)
        markerNum = coerceToRange(markerNum, [1, length(handles.MarkerHandles)]);
        set(handles.MarkerHandles(markerNum), 'edgecolor', handles.MarkerActiveColor, 'LineWidth', 2);
    else
        % No markers? Set active segment instead.
        handles = SetActiveSegment(handles, 1);
    end
    
function handles = SetActiveSegment(handles, segmentNum)
    % Inactivate all segments
    set(handles.SegmentHandles, 'edgecolor', handles.SegmentInactiveColor, 'LineWidth', 1);
    % Inactivate all markers
    set(handles.MarkerHandles, 'edgecolor', handles.MarkerInactiveColor, 'LineWidth', 1);
    % Activate requested segment
    if ~isempty(handles.SegmentHandles)
        segmentNum = coerceToRange(segmentNum, [1, length(handles.SegmentHandles)]);
        set(handles.SegmentHandles(segmentNum), 'edgecolor', handles.SegmentActiveColor, 'LineWidth', 2);
    end
    
function value = coerceToRange(value, valueRange)
    value = min(max(value, valueRange(1)), valueRange(2));
    
function [handles, newSegmentNum] = ConvertMarkerToSegment(handles, filenum, markerNum)
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
    
function [handles, newMarkerNum] = ConvertSegmentToMarker(handles, filenum, segmentNum)
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
        set(handles.axes_Sonogram,'CLim',[-pi/2 pi/2]);
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
    handles.popup_EventList.Value = 1;
    
    str = {};
    for c = 1:length(handles.sound_files)
        str{c} = makeFileEntry(handles, handles.sound_files(c).name, true);
    end
    handles.list_Files.String = str;
    
    
    sourceStrings = {'(None)','Sound'};
    for c = 1:length(handles.chan_files)
        if ~isempty(handles.chan_files{c})
            sourceStrings{end+1} = ['Channel ' num2str(c)];
        end
    end
    handles.popup_Channel1.String = sourceStrings;
    handles.popup_Channel2.String = sourceStrings;
    
    handles = eg_PopulateSoundSources(handles);
    
    handles.popup_EventList.String = {'(None)'};
    
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
        if strcmp(handles.menu_Segmenter(c).Checked,'on')
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
        if strcmp(handles.menu_Algorithm(c).Checked,'on')
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
        if strcmp(handles.menu_Filter(c).Checked,'on')
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
        v = get(handles.(['popup_EventDetector' num2str(axnum)]),'value');
        ud = get(handles.(['popup_EventDetector' num2str(axnum)]),'userdata');
        if isempty(ud{v}) && v>1
            str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
            dtr = str{v};
            [handles.EventParams{axnum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, 'params');
            ud{v} = handles.EventParams{axnum};
            set(handles.(['popup_EventDetector' num2str(axnum)]),'userdata',ud);
        else
            handles.EventParams{axnum} = ud{v};
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
            set(handles.popup_Functions(axnum),'userdata',ud);
        else
            handles.FunctionParams{axnum} = ud{v};
        end
    end
    
    handles = eg_RestartProperties(handles);
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
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
    
    
    
    handles.BackupChan = cell(1,2);
    handles.BackupLabel = cell(1,2);
    handles.BackupTitle = cell(1,2);
    
    handles.EventSources = {};
    handles.EventFunctions = {};
    handles.EventDetectors = {};
    handles.EventThresholds = zeros(0,handles.TotalFileNumber);
    handles.EventCurrentThresholds = [];
    handles.EventCurrentIndex = [0 0];
    
    handles.EventTimes = {};
    handles.EventSelected = {};
    handles.EventHandles = {};
    
    handles.EventWhichPlot = 0;
    handles.EventWaveHandles = [];
    
    handles.FileLength = zeros(1,handles.TotalFileNumber);
    
    
% --- Executes on button press in push_Open.
function push_Open_Callback(hObject, ~, handles)
    % hObject    handle to push_Open (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    [file, path] = uigetfile(fullfile(handles.DefaultRootPath, '*.mat'),'Load analysis');
    if ~ischar(file)
        return
    end
    
    load([path file],'dbase');
    
    handles.BackupChan = cell(1,2);
    handles.BackupLabel = cell(1,2);
    handles.BackupTitle = cell(1,2);
    
    handles.DefaultRootPath = dbase.PathName;
    if ~isfolder(handles.DefaultRootPath)
        path2 = uigetdir(pwd,['Directory ''' handles.DefaultRootPath ''' not found. Find the new location.']);
        if ~ischar(path2)
            return
        end
        handles.DefaultRootPath = path2;
    end
    
    handles.DefaultFile = [path file];
    
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
    
    handles.Properties = dbase.Properties;
    handles.EventCurrentIndex = [0 0];
    
    handles.popup_Channel1.Value = 1;
    handles.popup_Channel2.Value = 1;
    handles.popup_EventList.Value = 1;
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
        handles.popup_EventList.String = dbase.AnalysisState.EventList;
        handles.edit_FileNumber.String = num2str(dbase.AnalysisState.CurrentFile);
        handles.list_Files.Value = dbase.AnalysisState.CurrentFile;
        handles.EventWhichPlot = dbase.AnalysisState.EventWhichPlot;
        handles.EventLims = dbase.AnalysisState.EventLims;
    else
        str = {'(None)','Sound'};
        for c = 1:length(handles.chan_files)
            if ~isempty(handles.chan_files{c})
                str{end+1} = ['Channel ' num2str(c)];
            end
        end
        for c = 1:length(dbase.EventTimes)
            [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, ...
                dbase.EventDetectors{c}, 'params');
            for d = 1:length(labels)
                str{end+1} = [dbase.EventSources{c} ' - ' dbase.EventFunctions{c} ' - ' labels{d}];
            end
        end
        handles.popup_Channel1.String = str;
        handles.popup_Channel2.String = str;
    
        str = {'(None)'};
        for c = 1:length(dbase.EventTimes)
            [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, dbase.EventDetectors{c}, 'params');
            for d = 1:length(labels)
                str{end+1} = [dbase.EventSources{c} ' - ' dbase.EventFunctions{c} ' - ' labels{d}];
            end
        end
        handles.popup_EventList.String = str;
    
        handles.EventCurrentThresholds = inf*ones(1,length(str)-1);
    
        handles.EventWhichPlot = zeros(1,length(str));
        handles.EventLims = repmat(handles.EventLims,length(str),1);
    end
    
    % get segmenter parameters
    for c = 1:length(handles.menu_Segmenter)
        if strcmp(handles.menu_Segmenter(c).Checked,'on')
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
        if strcmp(handles.menu_Algorithm(c).Checked,'on')
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
        v = get(handles.(['popup_EventDetector' num2str(axnum)]),'value');
        ud = get(handles.(['popup_EventDetector' num2str(axnum)]),'userdata');
        if isempty(ud{v}) && v>1
            str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
            dtr = str{v};
            [handles.EventParams{axnum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, 'params');
            ud{v} = handles.EventParams{axnum};
            set(handles.(['popup_EventDetector' num2str(axnum)]),'userdata',ud);
        else
            handles.EventParams{axnum} = ud{v};
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
            set(handles.popup_Functions(axnum),'userdata',ud);
        else
            handles.FunctionParams{axnum} = ud{v};
        end
    end
    
    handles = eg_PopulateSoundSources(handles);
    
    handles = eg_RestartProperties(handles);
    
    handles = eg_LoadFile(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_Save.
function push_Save_Callback(hObject, ~, handles)
    % hObject    handle to push_Save (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
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
    
    guidata(hObject, handles);
    
    
    
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
        handles = SetThreshold(handles);
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
        if(noiseEst>soundEst)
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
    
    [handles.amplitude, ~] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
    plt.YData = handles.amplitude;
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
    
function click_Amplitude(hObject, ~, handles)
    
    if strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
        xd = [0 numSamples/handles.fs numSamples/handles.fs 0 0];
        handles.xlimbox.XData = xd;
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
    
        xd = handles.xlimbox.XData;
        if rect(3) == 0
            shift = rect(1)-xd(1);
            xd = xd+shift;
        else
            xd([1 4:5]) = rect(1);
            xd(2:3) = rect(1)+rect(3);
        end
        handles.xlimbox.XData = xd;
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        pos = handles.axes_Amplitude.CurrentPoint;
        handles.CurrentThreshold = pos(1,2);
        handles.SoundThresholds(getCurrentFileNum(handles)) = handles.CurrentThreshold;
        handles = SetThreshold(handles);
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
    
    handles = SetThreshold(handles);
    
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
    
    
function SegmenterMenuClick(hObject, ~, handles)
    
    for c = 1:length(handles.menu_Segmenter)
        handles.menu_Segmenter.Checked = 'off';
    end
    hObject.Checked = 'on';
    
    if isempty(hObject.UserData)
        alg = hObject.Label;
        handles.SegmenterParams = eg_runPlugin(handles.plugins.segmenters, alg, 'params');
        hObject.UserData = handles.SegmenterParams;
    else
        handles.SegmenterParams = hObject.UserData;
    end
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
    
    
function click_segmentaxes(hObject, ~, handles)
    
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
    
        handles.SegmentHandles.FaceColor = handles.SegmentSelectColor;
        set(handles.SegmentHandles(find(handles.SegmentSelection{filenum}==0)),'facecolor',handles.SegmentUnSelectColor);
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        xd = [0, numSamples/handles.fs, numSamples/handles.fs, 0, 0];
        handles.xlimbox.XData = xd;
        handles = eg_EditTimescale(handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        if sum(handles.SegmentSelection{filenum})==length(handles.SegmentSelection{filenum})
            handles.SegmentSelection{filenum} = zeros(size(handles.SegmentSelection{filenum}));
            handles.SegmentHandles.FaceColor = handles.SegmentUnSelectColor;
        else
            handles.SegmentSelection{filenum} = ones(size(handles.SegmentSelection{filenum}));
            handles.SegmentHandles.FaceColor = handles.SegmentSelectColor;
        end
    end
    
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
        if strcmp(handles.menu_Segmenter(c).Checked,'on')
            h = handles.menu_Segmenter(c);
            h.UserData = handles.SegmenterParams;
        end
    end
    
    handles = SegmentSounds(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_DeleteAll_Callback(hObject, ~, handles)
    % hObject    handle to menu_DeleteAll (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    filenum = getCurrentFileNum(handles);
    handles.SegmentSelection{filenum} = zeros(size(handles.SegmentSelection{filenum}));
    
    handles.SegmentHandles.FaceColor = handles.SegmentUnSelectColor;
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_UndeleteAll_Callback(hObject, ~, handles)
    % hObject    handle to menu_UndeleteAll (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    filenum = getCurrentFileNum(handles);
    handles.SegmentSelection{filenum} = ones(size(handles.SegmentSelection{filenum}));
    
    handles.SegmentHandles.FaceColor = handles.SegmentSelectColor;
    
    guidata(hObject, handles);
    
    
function click_segment(hObject, ~, handles)
    % Callback for clicking anything on the axes_Segments
    
    % Search for clicked item among segments
    activeSegNum = find(handles.SegmentHandles==hObject);
    if isempty(activeSegNum)
        % No matching segment found. Must be a marker.
        activeSegNum = find(handles.MarkerHandles==hObject);
        elementType = 'marker';
    else
        elementType = 'segment';
    end
    
    filenum = getCurrentFileNum(handles);
    switch handles.figure_Main.SelectionType
        case 'normal'
            switch elementType
                case 'segment'
                    handles = SetActiveSegment(handles, activeSegNum);
                case 'marker'
                    handles = SetActiveMarker(handles, activeSegNum);
            end
    %         set(handles.SegmentHandles,'edgecolor',handles.SegmentInactiveColor,'LineWidth',1);
    %         set(hObject,'edgecolor',handles.SegmentActiveColor,'LineWidth',2);
            handles.figure_Main.KeyPressFcn = 'electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))';
        case 'extend'
            switch elementType
                case 'segment'
                    handles.SegmentSelection{filenum}(activeSegNum) = ~handles.SegmentSelection{filenum}(activeSegNum);
                    hObject.FaceColor = handles.SegmentSelectColors{handles.SegmentSelection{filenum}(activeSegNum+1)};
                case 'marker'
                    handles.MarkerSelection{filenum}(activeSegNum) = ~handles.MarkerSelection{filenum}(activeSegNum);
                    hObject.FaceColor = handles.MarkerSelectColors{handles.MarkerSelection{filenum}(activeSegNum+1)};
            end
        case 'open'
            switch elementType
                case 'segment'
                    if activeSegNum < length(handles.SegmentHandles)
                        handles.SegmentTimes{filenum}(activeSegNum,2) = handles.SegmentTimes{filenum}(activeSegNum+1,2);
                        handles.SegmentTimes{filenum}(activeSegNum+1,:) = [];
                        handles.SegmentTitles{filenum}(activeSegNum+1) = [];
                        handles.SegmentSelection{filenum}(activeSegNum+1) = [];
                        handles = PlotSegments(handles);
                        hObject = handles.SegmentHandles(activeSegNum);
                        set(handles.SegmentHandles,'edgecolor',handles.SegmentInactiveColor,'LineWidth',1);
                        handles = SetActiveSegment(handles, activeSegNum);
    %                     set(hObject,'edgecolor',handles.SegmentActiveColor,'LineWidth',2);
                        handles.figure_Main.KeyPressFcn = 'electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))';
                    end
                case 'marker'
                    % Nah, doubt we need to implement concatenating adjacent
                    % markers.
            end
    end
    
    guidata(hObject, handles);
    
function handles = ToggleSegmentSelect(handles, filenum, segmentNum)
    handles.SegmentSelection{filenum}(segmentNum) = ~handles.SegmentSelection{filenum}(segmentNum);
    set(handles.SegmentHandles(segmentNum),'facecolor',handles.SegmentSelectColors{handles.SegmentSelection{filenum}(segmentNum)+1});
    
function handles = ToggleMarkerSelect(handles, filenum, markerNum)
    handles.MarkerSelection{filenum}(markerNum) = ~handles.MarkerSelection{filenum}(markerNum);
    set(handles.MarkerHandles(markerNum),'facecolor',handles.MarkerSelectColors{handles.MarkerSelection{filenum}(markerNum)+1});
    
function markerNum = FindActiveMarker(handles)
    marker = findobj('Parent',handles.axes_Segments,'edgecolor',handles.MarkerActiveColor);
    if isempty(marker)
        markerNum = [];
        return;
    end
    markerNum = find(handles.MarkerHandles == marker);
function segmentNum = FindActiveSegment(handles)
    segment = findobj('Parent',handles.axes_Segments,'edgecolor',handles.SegmentActiveColor);
    if isempty(segment)
        segmentNum = [];
        return;
    end
    segmentNum = find(handles.SegmentHandles == segment);
    
function handles = JoinSegmentWithNext(handles, filenum, segmentNum)
    if segmentNum < length(handles.SegmentHandles)
        % This is not the last segment in the file
        handles.SegmentTimes{filenum}(segmentNum,2) = handles.SegmentTimes{filenum}(segmentNum+1,2);
        handles.SegmentTimes{filenum}(segmentNum+1,:) = [];
        handles.SegmentTitles{filenum}(segmentNum+1) = [];
        handles.SegmentSelection{filenum}(segmentNum+1) = [];
        handles = PlotSegments(handles);
        handles = SetActiveSegment(handles, segmentNum);
        handles.figure_Main.KeyPressFcn = 'electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))';
    end
    
function labelsegment(hObject, ~, handles)
    % Callback to handle a key press labeling the selected segment
    % Ok on closer examination this is a poorly named general keypress handler.
    
    % Get currently loaded file num
    filenum = getCurrentFileNum(handles);
    % Get the last key press captured by the figure
    ch = handles.figure_Main.CurrentCharacter;
    % I think this is an awkward way of converting the character to a numeric ASCII code?
    chn = sum(ch);
    
    % Keypress is a "comma" - load previous file
    if chn==44
        filenum = getCurrentFileNum(handles);
        filenum = filenum-1;
        if filenum == 0
            filenum = handles.TotalFileNumber;
        end
        handles.edit_FileNumber.String = num2str(filenum);
    
        handles = eg_LoadFile(handles);
        guidata(hObject, handles);
        return
    end
    % Keypress is a "period" - load next file
    if chn==46
        filenum = getCurrentFileNum(handles);
        filenum = filenum+1;
        if filenum > handles.TotalFileNumber
            filenum = 1;
        end
        handles.edit_FileNumber.String = num2str(filenum);
    
        handles = eg_LoadFile(handles);
        guidata(hObject, handles);
        return
    end
    % User pressed "control-e"
    if chn == 5
        % Press control-e to produce a export of the sonogram and any channel
        % views.
        f_export = figure();
    
        % Determine how many channels are visible
        numChannels = 0;
        for c = 1:length(handles.axes_Channel)
            if strcmp(handles.axes_Channel(c).Visible, 'on')
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
            if strcmp(handles.axes_Channel(c).Visible, 'on')
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
        return
    end
    
    % Find the handle for the currently active segment
    segmentNum = FindActiveSegment(handles);
    markerNum = FindActiveMarker(handles);
    
    if isempty(handles.SegmentHandles) && isempty(handles.MarkerHandles)
        % No segments or markers defined, do nothing
        return
    end
    if isempty(segmentNum) && isempty(markerNum)
        % No active segment or active marker, do nothing
        return
    elseif ~isempty(segmentNum) && ~isempty(markerNum)
        error('Both a marker and a segment were active. This shouldn''t happen');
    else
        if ~isempty(segmentNum)
            activeType = 'segment';
        elseif ~isempty(markerNum)
            activeType = 'marker';
        end
    end
    if chn>32 && chn<127 && chn~=44 && chn~=46 && chn~=96
        % Key was in the range of normal printable keyboard characters, but
        %   isn't a comma or period
        switch activeType
            case 'segment'
                % Set the currently active segment title to the pressed key
                handles.SegmentTitles{filenum}{segmentNum} = ch;
                % Update the segment label to reflect the new segment title
                set(handles.SegmentLabelHandles(segmentNum),'string',ch);
                newSegmentNum = segmentNum + 1;
            case 'marker'
                % Set the currently active marker title to the pressed key
                handles.MarkerTitles{filenum}{markerNum} = ch;
                % Update the segment label to reflect the new segment title
                set(handles.MarkerLabelHandles(markerNum),'string',ch);
                newMarkerNum = markerNum + 1;
        end
    elseif chn==8
        switch activeType
            case 'segment'
                % User pressed "backspace" - clear segment title
                handles.SegmentTitles{filenum}{segmentNum} = '';
                % Clear segment label
                set(handles.SegmentLabelHandles(segmentNum),'string','');
                newSegmentNum = segmentNum + 1;
            case 'marker'
                % User pressed "backspace" - clear marker title
                handles.MarkerTitles{filenum}{markerNum} = '';
                % Clear segment label
                set(handles.MarkerLabelHandles(markerNum),'string','');
                newMarkerNum = markerNum + 1;
        end
    elseif chn==28
        % User pressed right arrow
        switch activeType
            case 'segment'
                newSegmentNum = segmentNum - 1;
            case 'marker'
                newMarkerNum = markerNum - 1;
        end
    elseif chn==29
        % User pressed left arrow
        switch activeType
            case 'segment'
                newSegmentNum = segmentNum + 1;
            case 'marker'
                newMarkerNum = markerNum + 1;
        end
    elseif chn==31
        % User pressed down arrow
        switch activeType
            case 'segment'
                % This is the bottom row - do nothing
                return
            case 'marker'
                if isempty(handles.SegmentHandles)
                    % No segments to switch to, do nothing
                    return
                end
                markerTime = mean(handles.MarkerTimes{filenum}(markerNum, :));
                segmentTimes = mean(handles.SegmentTimes{filenum}, 2);
                % Find segment closest in time to the active marker, and switch
                % to that active segment.
                [~, newSegmentNum] = min(abs(segmentTimes - markerTime));
                activeType = 'segment';
        end
    elseif chn==30
        % User pressed up arrow
        switch activeType
            case 'segment'
                if isempty(handles.MarkerHandles)
                    % No markers to switch to, do nothing
                    return
                end
                segmentTime = mean(handles.SegmentTimes{filenum}(segmentNum, :));
                markerTimes = mean(handles.MarkerTimes{filenum}, 2);
                % Find segment closest in time to the active marker, and switch
                % to that active segment.
                [~, newMarkerNum] = min(abs(markerTimes - segmentTime));
                activeType = 'marker';
            case 'marker'
                % This is the bottom row - do nothing
                return
        end
    elseif chn==32
        % User pressed "space" - join this segment with next segment
        switch activeType
            case 'segment'
                handles = JoinSegmentWithNext(handles, filenum, segmentNum);
                newSegmentNum = segmentNum;
            case 'marker'
                % Don't really need to do this with markers
                return
        end
    elseif chn==13
        % User pressed "enter" key - toggle active segment "selection"
        switch activeType
            case 'segment'
                handles = ToggleSegmentSelect(handles, filenum, segmentNum);
                newSegmentNum = segmentNum;
            case 'marker'
                handles = ToggleMarkerSelect(handles, filenum, markerNum);
                newMarkerNum = markerNum;
        end
    elseif chn==127
        % User pressed "delete" - delete selected marker
        switch activeType
            case 'segment'
                handles = DeleteSegment(handles, filenum, segmentNum);
                newSegmentNum = segmentNum;
            case 'marker'
                handles = DeleteMarker(handles, filenum, markerNum);
                newMarkerNum = markerNum;
        end
        handles = PlotSegments(handles);
    elseif chn==96
        % User pressed the "`" / "~" button - transform active marker into
        %   segment or vice versa
        switch activeType
            case 'segment'
                [handles, newMarkerNum] = ConvertSegmentToMarker(handles, filenum, segmentNum);
                activeType = 'marker';
            case 'marker'
                [handles, newSegmentNum] = ConvertMarkerToSegment(handles, filenum, markerNum);
                activeType = 'segment';
        end
        handles = PlotSegments(handles);
    else
        return
    end
    
    switch activeType
        case 'segment'
            handles = SetActiveSegment(handles, newSegmentNum);
        case 'marker'
            handles = SetActiveMarker(handles, newMarkerNum);
    end
    
    % % Update previously active segment to not active
    % set(handles.SegmentHandles(segnum),'edgecolor',handles.SegmentInactiveColor,'LineWidth',1);
    % % Mark new active segment as active
    % set(handles.SegmentHandles(newseg),'edgecolor',handles.SegmentActiveColor,'LineWidth',2);
    
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
        set(handles.popup_Functions(axnum),'userdata',ud);
    else
        handles.FunctionParams{axnum} = ud{v};
    end
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        set(handles.popup_EventDetectors(axnum),'value', 1);
        handles = eg_LoadChannel(handles, axnum);
        handles = eg_clickEventDetector(handles, axnum);
    end
    str = handles.popup_Channels(axnum).String;
    str = str{handles.popup_Channels(axnum).Value};
    if contains(str,' - ') || strcmp(str,'(None)')
        set(handles.popup_EventDetectors(axnum),'enable','off');
    else
        set(handles.popup_EventDetectors(axnum),'enable','on');
    end
    
    if strcmp(handles.menu_SourcePlots(axnum).Checked,'on')
        [handles.amplitude, labels] = eg_CalculateAmplitude(handles);
    
        plt = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
        plt.YData = handles.amplitude;
        ylabel(handles.axes_Amplitude, labels);
    
        handles = SetThreshold(handles);
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
        set(handles.popup_Functions(axnum),'value',1);
        set(handles.popup_EventDetectors(axnum),'value',1);
        handles = eg_LoadChannel(handles, axnum);
        handles = eg_clickEventDetector(handles, axnum);
    end
    str = handles.popup_Channels(axnum).String;
    str = str{handles.popup_Channels(axnum).Value};
    if contains(str,' - ') || strcmp(str,'(None)')
        set(handles.popup_EventDetectors(axnum),'enable','off');
    else
        set(handles.popup_EventDetectors(axnum),'enable','on');
    end
    
    handles.BackupTitle = cell(1,2);
    
    if strcmp(handles.menu_SourcePlots(axnum).Checked,'on')
        [handles.amplitude, labels] = eg_CalculateAmplitude(handles);
    
        plt = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
        plt.YData = handles.amplitude;
        ylabel(handles.axes_Amplitude, labels);
    
        handles = SetThreshold(handles);
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
                set(handles.popup_Functions(axnum), 'value', defaultChannelFunctionIdx);
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
    handles = eg_clickEventDetector(handles,1);
    
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
    handles = eg_clickEventDetector(handles,2);
    
    guidata(hObject, handles);
    
    
    
function click_Channel(hObject, ~, handles)
    
    obj = hObject;
    if ~strcmp(obj.Type,'axes')
        obj = obj.Parent;
    end
    if obj==handles.axes_Channel1
        axnum = 1;
    else
        axnum = 2;
    end
    
    
    if strcmp(handles.figure_Main.SelectionType,'open')
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        xd = [0, numSamples/handles.fs numSamples/handles.fs 0 0];
        handles.xlimbox.XData = xd;
    
        for axn = 1:2
            if strcmp(handles.axes_Channel(axn).Visible,'on')
                if strcmp(get(handles.(['menu_AutoLimits' num2str(axn)]),'checked'),'on')
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
        handles = eg_EditTimescale(handles);
    
    elseif strcmp(handles.figure_Main.SelectionType,'normal')
        set(gca,'units','pixels');
        set(get(gca,'parent'),'units','pixels');
        rect = rbbox;
    
        pos = get(gca,'position');
        set(get(gca,'parent'),'units','normalized');
        set(gca,'units','normalized');
        xl = xlim;
        yl = ylim;
    
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
        rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
        rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
    
        xd = handles.xlimbox.XData;
        if rect(3) == 0
            shift = rect(1)-xd(1);
            xd = xd+shift;
        else
            xd([1 4:5]) = rect(1);
            xd(2:3) = rect(1)+rect(3);
            if strcmp(get(handles.(['menu_AllowYZoom' num2str(axnum)]),'checked'),'on')
                ylim([rect(2) rect(4)+rect(2)]);
            end
        end
        handles.xlimbox.XData = xd;
        handles = eg_EditTimescale(handles);
    
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        handles.SelectedEvent = [];
        delete(findobj('LineStyle','-.'));
    
        if handles.EventCurrentIndex(axnum)==0
            return
        end
    
        set(gca,'units','pixels');
        set(get(gca,'parent'),'units','pixels');
        rect = rbbox;
    
        pos = get(gca,'position');
        set(get(gca,'parent'),'units','normalized');
        set(gca,'units','normalized');
        xl = xlim;
        yl = ylim;
    
        rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
        rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
        rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
        rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));
    
        if rect(3) == 0
            pos = get(gca,'currentpoint');
            indx = handles.EventCurrentIndex(axnum);
            if indx > 0
                handles.EventCurrentThresholds(indx) = pos(1,2);
                handles.EventThresholds(indx,getCurrentFileNum(handles)) = pos(1,2);
                for axn = 1:2
                    if strcmp(handles.axes_Channel(axn).Visible,'on') && handles.EventCurrentIndex(axn)==indx
                        handles = EventSetThreshold(handles,axn);
                        if strcmp(get(handles.(['menu_EventAutoDetect' num2str(axn)]),'checked'),'on') && strcmp(get(handles.(['push_Detect' num2str(axn)]),'enable'),'on')
                            handles = DetectEvents(handles,axn);
    
                            if handles.menu_AutoDisplayEvents.Checked
                                handles = UpdateEventBrowser(handles);
                            end
    
                            val = get(handles.popup_Channels(3-axn),'value');
                            str = get(handles.popup_Channels(3-axn),'string');
                            nums = [];
                            for c = 1:length(handles.EventTimes)
                                nums(c) = size(handles.EventTimes{c},1);
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
                    end
                end
            end
    
        else
            obj = findobj('Parent', handles.axes_Channel(axnum), 'LineStyle', '-');
            xs = [];
            for c = 1:length(obj)
                x = obj(c).XData;
                y = obj(c).YData;
                f = x>rect(1) & x<rect(1)+rect(3) & y>rect(2) & y<rect(2)+rect(4);
                xs = [xs, x(f)];
            end
            obj = findobj('Parent', handles.axes_Channel(axnum), 'LineStyle', 'none');
            objin = [];
            ison = [];
            for c = 1:length(obj)
                x = obj(c).XData;
                if ~isempty(find((xs-x>0 & xs-x<handles.SearchBefore(axnum)) | (x-xs>0 & x-xs<handles.SearchAfter(axnum)), 1))
                    objin = [objin obj(c)];
                    if sum(obj(c).MarkerFaceColor==[1 1 1])==3
                        ison = [ison 0];
                    else
                        ison = [ison 1];
                    end
                end
            end
    
            if ~isempty(ison) && mean(ison)>0.5
                objin.MarkerFaceColor = 'w';
            else
                for c = 1:length(objin)
                    set(objin(c),'markerfacecolor',objin(c).MarkerEdgeColor);
                end
            end
    
            indx = handles.EventCurrentIndex(axnum);
            for c = 1:length(handles.EventHandles{axnum})
                for d = 1:length(handles.EventHandles{axnum}{c})
                    if sum(get(handles.EventHandles{axnum}{c}(d),'markerfacecolor')==[1 1 1])==3
                        handles.EventSelected{indx}{c,getCurrentFileNum(handles)}(d) = 0;
                    else
                        handles.EventSelected{indx}{c,getCurrentFileNum(handles)}(d) = 1;
                    end
                end
            end
    
            val = get(handles.popup_Channels(3-axnum),'value');
            str = get(handles.popup_Channels(3-axnum),'string');
            nums = [];
            for c = 1:length(handles.EventTimes)
                nums(c) = size(handles.EventTimes{c},1);
            end
            if val > length(str)-sum(nums)
                indx = val-(length(str)-sum(nums));
                cs = cumsum(nums);
                f = length(find(cs<indx))+1;
                if f == handles.EventCurrentIndex(axnum)
                    handles = eg_LoadChannel(handles,3-axnum);
                end
            end
    
            if strcmp(handles.axes_Channel(3-axnum).Visible', 'on') && handles.EventCurrentIndex(1)==handles.EventCurrentIndex(2)
                handles = DisplayEvents(handles,3-axnum);
            end
    
            if handles.menu_AutoDisplayEvents.Checked
                handles = UpdateEventBrowser(handles);
            end
        end
    end
    
    guidata(handles.axes_Channel(axnum), handles);
    
    
function handles = EventSetThreshold(handles,axnum)
    
    if ~handles.axes_Channel(axnum).Visible
        return
    end
    
    obj = findobj('Parent', handles.axes_Channel(axnum), 'LineStyle', 'none');
    delete(obj);
    obj = findobj('Parent', handles.axes_Channel(axnum), 'LineStyle', ':');
    if handles.EventCurrentIndex(axnum) == 0
        delete(obj);
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventBrowser(handles);
        end
        return
    end
    xl = xlim(handles.axes_Channel(axnum));
    yl = ylim(handles.axes_Channel(axnum));
    indx = handles.EventCurrentIndex(axnum);
    if handles.EventThresholds(indx,getCurrentFileNum(handles)) < inf
        handles.EventCurrentThresholds(indx) = handles.EventThresholds(indx,getCurrentFileNum(handles));
        handles = DisplayEvents(handles,axnum);
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventBrowser(handles);
        end
    else
        handles.EventThresholds(indx,getCurrentFileNum(handles)) = handles.EventCurrentThresholds(indx);
        if strcmp(get(handles.(['menu_EventAutoDetect' num2str(axnum)]),'checked'),'on') && strcmp(get(handles.(['push_Detect' num2str(axnum)]),'enable'),'on')
            handles = DetectEvents(handles,axnum);
            if handles.menu_AutoDisplayEvents.Checked
                handles = UpdateEventBrowser(handles);
            end
        end
    end
    if ~isempty(obj)
        obj.YData = [handles.EventCurrentThresholds(indx), handles.EventCurrentThresholds(indx)];
    else
        hold(handles.axes_Channel(axnum), 'on');
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        plot(handles.axes_Channel(axnum), [0, numSamples/handles.fs], [handles.EventCurrentThresholds(indx), handles.EventCurrentThresholds(indx)], ':', ...
            'Color', handles.ChannelThresholdColor(axnum,:));
        hold(handles.axes_Channel(axnum), 'off');
    end
    xlim(handles.axes_Channel(axnum), xl);
    ylim(handles.axes_Channel(axnum), yl);

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
        handles = eg_clickEventDetector(handles,1);
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
        handles = eg_clickEventDetector(handles,2);
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
    
    
function handles = eg_clickEventDetector(handles,axnum)
    
    v = get(handles.(['popup_EventDetector' num2str(axnum)]),'value');
    ud = get(handles.(['popup_EventDetector' num2str(axnum)]),'userdata');
    if isempty(ud{v}) && v>1
        str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
        dtr = str{v};
        [handles.EventParams{axnum}, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, 'params');
        ud{v} = handles.EventParams{axnum};
        set(handles.(['popup_EventDetector' num2str(axnum)]),'userdata',ud);
    else
        handles.EventParams{axnum} = ud{v};
    end
    
    if strcmp(handles.axes_Channel(axnum).Visible,'off')
        return
    end
    str = handles.popup_Channels(axnum).String;
    src = str{handles.popup_Channels(axnum).Value};
    if get(handles.(['popup_EventDetector' num2str(axnum)]),'value')==1 || contains(src,' - ')
        set(handles.(['menu_Events' num2str(axnum)]),'enable','off');
        set(handles.(['push_Detect' num2str(axnum)]),'enable','off');
        handles.EventCurrentIndex(axnum) = 0;
    else
        set(handles.(['menu_Events' num2str(axnum)]),'enable','on');
        set(handles.(['push_Detect' num2str(axnum)]),'enable','on');
    
        str = handles.popup_Functions(axnum).String;
        fun = str{handles.popup_Functions(axnum).Value};
        str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
        dtr = str{get(handles.(['popup_EventDetector' num2str(axnum)]),'value')};
        mtch = 0;
        for c = 1:length(handles.EventSources)
            cnt = [0 0 0];
            if strcmp(handles.EventSources{c},src)
                cnt(1) = 1;
            end
            if strcmp(handles.EventFunctions{c},fun)
                cnt(2) = 1;
            end
            if strcmp(handles.EventDetectors{c},dtr)
                cnt(3) = 1;
            end
            if sum(cnt) == 3
                mtch = c;
            end
        end
    
        if mtch > 0
            handles.EventCurrentIndex(axnum) = mtch;
        else
            handles.EventCurrentIndex(axnum) = length(handles.EventSources)+1;
            handles.EventSources{end+1} = src;
            handles.EventFunctions{end+1} = fun;
            handles.EventDetectors{end+1} = dtr;
            handles.EventThresholds = [handles.EventThresholds; inf*ones(1,size(handles.EventThresholds,2))];
            handles.EventCurrentThresholds(end+1) = inf;
    
            [~, labels] = eg_runPlugin(handles.plugins.eventDetectors, dtr, [], handles.fs, inf, handles.EventParams{axnum});
    
            str = handles.popup_Channel1.String;
            strv = handles.popup_EventList.String;
            for c = 1:length(labels)
                str{end+1} = [src ' - ' fun ' - ' labels{c}];
                strv{end+1} = [src ' - ' fun ' - ' labels{c}];
    
                handles.EventLims = [handles.EventLims; handles.EventLims(end,:)];
                handles.EventWhichPlot = [handles.EventWhichPlot 0];
            end
            handles.popup_Channel1.String = str;
            handles.popup_Channel2.String = str;
            handles.popup_EventList.String = strv;
    
            handles.EventTimes{end+1} = cell(length(labels),handles.TotalFileNumber);
            handles.EventSelected{end+1} = cell(length(labels),handles.TotalFileNumber);
        end
    
        delete(get(handles.(['menu_EventsDisplay',num2str(axnum)]),'children'));
        handles.menu_EventsDisplayList{axnum} = [];
    
        indx = 0;
        str = handles.popup_Channel1.String;
        while 1
            indx = indx + 1;
            if ~isempty(strfind(str{indx},' - '))
                break
            end
        end
        indx = indx - 1;
        for c = 1:handles.EventCurrentIndex(axnum)-1
            indx = indx + size(handles.EventTimes{c},1);
        end
        for c = 1:size(handles.EventTimes{handles.EventCurrentIndex(axnum)},1)
            lab = str{indx+c};
            f = strfind(lab,' - ');
            lab = lab(f(end)+3:end);
            handles.menu_EventsDisplayList{axnum}(c) = uimenu(handles.(['menu_EventsDisplay',num2str(axnum)]),...
                'label',lab,'callback','electro_gui(''EventsDisplayClick'',gcbo,[],guidata(gcbo))','checked','on');
        end
    end
    
    handles = EventSetThreshold(handles,axnum);
    
    
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
            handles = UpdateEventBrowser(handles);
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
function menu_EventSetThreshold1_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventSetThreshold1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SetManualThreshold(handles,1);
    
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
            handles = UpdateEventBrowser(handles);
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
function menu_EventSetThreshold2_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventSetThreshold2 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = SetManualThreshold(handles,2);
    
    guidata(hObject, handles);
    
    
function handles = SetManualThreshold(handles,axnum)
    
    indx = handles.EventCurrentIndex(axnum);
    answer = inputdlg({'Threshold'},'Threshold',1,{num2str(handles.EventCurrentThresholds(indx))});
    if isempty(answer)
        return
    end
    handles.EventCurrentThresholds(indx) = str2double(answer{1});
    handles.EventThresholds(indx,getCurrentFileNum(handles)) = str2double(answer{1});
    for axn = 1:2
        if strcmp(handles.axes_Channel(axn).Visible,'on') && handles.EventCurrentIndex(axn)==indx
            handles = EventSetThreshold(handles,axn);
            if strcmp(get(handles.(['menu_EventAutoDetect' num2str(axn)]),'checked'),'on') && strcmp(get(handles.(['push_Detect' num2str(axn)]),'enable'),'on')
                handles = DetectEvents(handles,axn);
                if handles.menu_AutoDisplayEvents.Checked
                    handles = UpdateEventBrowser(handles);
                end
    
                val = get(handles.popup_Channels(3-axn),'value');
                str = get(handles.popup_Channels(3-axn),'string');
                nums = [];
                for c = 1:length(handles.EventTimes)
                    nums(c) = size(handles.EventTimes{c},1);
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
        end
    end
    
    
% --- Executes on button press in push_Detect1.
function push_Detect1_Callback(hObject, ~, handles)
    % hObject    handle to push_Detect1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = DetectEvents(handles,1);
    
    if handles.menu_AutoDisplayEvents.Checked
        handles = UpdateEventBrowser(handles);
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
        handles = UpdateEventBrowser(handles);
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
    
    
function handles = DetectEvents(handles,axnum)
    
    handles.SelectedEvent = [];
    delete(findobj('LineStyle','-.'));
    
    val = handles.loadedChannelData{axnum};
    indx = handles.EventCurrentIndex(axnum);
    thres = handles.EventThresholds(indx,getCurrentFileNum(handles));
    
    str = get(handles.(['popup_EventDetector' num2str(axnum)]),'string');
    dtr = str{get(handles.(['popup_EventDetector' num2str(axnum)]),'value')};
    
    if strcmp(dtr,'(None)')
        return
    end
    [events, ~] = eg_runPlugin(handles.plugins.eventDetectors, dtr, val, handles.fs, thres, handles.EventParams{axnum});
    
    for c = 1:length(events)
        handles.EventTimes{indx}{c,getCurrentFileNum(handles)} = events{c};
        handles.EventSelected{indx}{c,getCurrentFileNum(handles)} = ones(1,length(events{c}));
    end
    
    handles = DisplayEvents(handles,axnum);
    
    
function handles = DisplayEvents(handles,axnum)
    
    indx = handles.EventCurrentIndex(axnum);
    if indx == 0
        return
    end
    obj = findobj('Parent', handles.axes_Channel(axnum), 'LineStyle', 'none');
    delete(obj);
    hold(handles.axes_Channel(axnum), 'on');
    ev = {};
    sel = {};
    handles.EventHandles{axnum} = {};
    for c = 1:size(handles.EventTimes{indx},1)
        ev{c} = handles.EventTimes{indx}{c,getCurrentFileNum(handles)};
        sel{c} = handles.EventSelected{indx}{c,getCurrentFileNum(handles)};
    end
    h = handles.menu_EventsDisplayList{axnum};
    chan = handles.loadedChannelData{axnum};
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    xs = linspace(0, numSamples/handles.fs, numSamples);
    for c = 1:length(ev)
        if h(c).Checked
            for i = 1:length(ev{c})
                if sel{c}(i)==1
                    handles.EventHandles{axnum}{c}(i) = plot(handles.axes_Channel(axnum), xs(ev{c}(i)),chan(ev{c}(i)),'o','LineStyle','none','markeredgecolor','k','markerfacecolor','k','markersize',5);
                else
                    handles.EventHandles{axnum}{c}(i) = plot(handles.axes_Channel(axnum), xs(ev{c}(i)),chan(ev{c}(i)),'o','LineStyle','none','markeredgecolor','k','markerfacecolor','w','markersize',5);
                end
            end
        else
            handles.EventHandles{axnum}{c} = [];
        end
    end
    
    for c = 1:length(handles.EventHandles{axnum})
        for i = 1:length(handles.EventHandles{axnum}{c})
            handles.EventHandles{axnum}{c}(i).ButtonDownFcn = 'electro_gui(''ClickEventSymbol'',gcbo,[],guidata(gcbo))';
        end
    end
    
    
function ClickEventSymbol(hObject, ~, handles)
    
    if hObject.Parent==handles.axes_Channel1
        axnum = 1;
    else
        axnum = 2;
    end
    
    if strcmp(handles.figure_Main.SelectionType,'extend')
        handles.SelectedEvent = [];
        delete(findobj('LineStyle','-.'));
    
        if sum(hObject.MarkerFaceColor==[1 1 1])==3
            hObject.MarkerFaceColor = hObject.MarkerEdgeColor;
        else
            hObject.MarkerFaceColor = 'w';
        end
    
        indx = handles.EventCurrentIndex(axnum);
    
        for c = 1:length(handles.EventHandles{axnum})
            for d = 1:length(handles.EventHandles{axnum}{c})
                if sum(get(handles.EventHandles{axnum}{c}(d),'markerfacecolor')==[1 1 1])==3
                    handles.EventSelected{indx}{c,getCurrentFileNum(handles)}(d) = 0;
                else
                    handles.EventSelected{indx}{c,getCurrentFileNum(handles)}(d) = 1;
                end
            end
        end
    
        val = get(handles.popup_Channels(3-axnum),'value');
        str = get(handles.popup_Channels(3-axnum),'string');
        nums = [];
        for c = 1:length(handles.EventTimes)
            nums(c) = size(handles.EventTimes{c},1);
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
            handles = DisplayEvents(handles,3-axnum);
        end
    
        if handles.menu_AutoDisplayEvents.Checked
            handles = UpdateEventBrowser(handles);
        end
    
    
    elseif strcmp(handles.figure_Main.SelectionType,'normal') && sum(hObject.MarkerFaceColor==[1 1 1])~=3
        indx = handles.popup_EventList.Value-1;
        if indx==0
            return
        end
        nums = [];
        for c = 1:length(handles.EventTimes)
            nums(c) = size(handles.EventTimes{c},1);
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
        xclick = hObject.XData;
        [~, j] = min(abs(tm-xclick));
        handles = SelectEvent(handles,j);
    
    end
    
    guidata(hObject, handles);
    
    
    
function EventsDisplayClick(hObject, ~, handles)
    
    if strcmp(hObject.Checked,'on')
        hObject.Checked = 'off';
    else
        hObject.Checked = 'on';
    end
    
    if hObject.Parent==handles.menu_EventsDisplay1
        handles = DisplayEvents(handles,1);
    else
        handles = DisplayEvents(handles,2);
    end
    
    guidata(hObject, handles);
    
    
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
    
    
% --- Executes on selection change in popup_EventList.
function popup_EventList_Callback(hObject, ~, handles)
    % hObject    handle to popup_EventList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: contents = hObject.String returns popup_EventList contents as cell array
    %        contents{hObject.Value} returns selected item from popup_EventList
    
    
    handles.SelectedEvent = [];
    delete(findobj('LineStyle','-.'));
    
    if handles.popup_EventList.Value==1
        cla(handles.axes_Events);
        handles.axes_Events.Visible = 'off';
        handles.push_DisplayEvents.Enable = 'off';
        return
    else
        handles.axes_Events.Visible = 'on';
        handles.push_DisplayEvents.Enable = 'on';
    
        if ~handles.axes_Channel2.Visible
            plt = 1;
        elseif ~handles.axes_Channel1.Visible
            plt = 2;
        else
            if handles.EventWhichPlot(handles.popup_EventList.Value)==0
                nums = [];
                for c = 1:length(handles.EventTimes)
                    nums(c) = size(handles.EventTimes{c},1);
                end
                indx = handles.popup_EventList.Value-1;
                cs = cumsum(nums);
                f = length(find(cs<indx))+1;
                if f == handles.EventCurrentIndex(1)
                    plt = 1;
                elseif f == handles.EventCurrentIndex(2)
                    plt = 2;
                else
                    plt = 1;
                end
                handles.EventWhichPlot(handles.popup_EventList.Value) = plt;
            else
                plt = handles.EventWhichPlot(handles.popup_EventList.Value);
            end
        end
    
        if plt == 1
            handles.menu_AnalyzeTop.Checked = 'on';
            handles.menu_AnalyzeBottom.Checked = 'off';
        else
            handles.menu_AnalyzeTop.Checked = 'off';
            handles.menu_AnalyzeBottom.Checked = 'on';
        end
    
        handles = UpdateEventBrowser(handles);
    end
    
    guidata(hObject, handles);
    
    
function handles = UpdateEventBrowser(handles)
    cla(handles.axes_Events);
    hold(handles.axes_Events, 'on');
    
    delete(findobj('LineStyle', '-.'));
    
    if handles.popup_EventList.Value==1
        handles.push_DisplayEvents.Enable = 'off';
        return
    else
        handles.push_DisplayEvents.Enable = 'on';
    end
    
    if handles.menu_AnalyzeTop.Checked
        if handles.axes_Channel1.Visible
            chan = handles.loadedChannelData{1};
            ystr = (handles.axes_Channel1.ylabel.String);
        else
            chan = [];
        end
    else
        if handles.axes_Channel2.Visible
            chan = handles.loadedChannelData{2};
            ystr = (handles.axes_Channel2.ylabel.String);
        else
            chan = [];
        end
    end
    
    filenum = getCurrentFileNum(handles);
    nums = [];
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    indx = handles.popup_EventList.Value-1;
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    
    tmall = handles.EventTimes{f}(:,filenum);
    tm = handles.EventTimes{f}{g,filenum};
    sel = handles.EventSelected{f}{g,filenum};
    
    if handles.menu_DisplayValues.Checked
        handles.EventWaveHandles = [];
        if ~isempty(chan)
            for c = 1:length(tm)
                mn = max([1 tm(c)-round(handles.EventLims(handles.popup_EventList.Value,1)*handles.fs)]);
                mx = min([length(chan) tm(c)+round(handles.EventLims(handles.popup_EventList.Value,2)*handles.fs)]);
                if sel(c)==1
                    h = plot(handles.axes_Events, ((mn:mx)-tm(c))/handles.fs*1000,chan(mn:mx),'Color','k');
                    handles.EventWaveHandles = [handles.EventWaveHandles h];
                end
            end
            xlabel(handles.axes_Events, 'Time (ms)');
            ylabel(handles.axes_Events, ystr);
            xlim(handles.axes_Events, [-handles.EventLims(handles.popup_EventList.Value,1) handles.EventLims(handles.popup_EventList.Value,2)]*1000);
            axis(handles.axes_Events, 'tight');
            yl = ylim(handles.axes_Events);
            ylim(handles.axes_Events, [mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        else
            ylabel(handles.axes_Events, '');
        end
        handles.EventWaveHandles.ButtonDownFcn = 'electro_gui(''click_eventwave'',gcbo,[],guidata(gcbo))';
    else
        handles.EventWaveHandles = [];
        if ~isempty(chan)
            f = findobj('Parent',handles.menu_XAxis,'checked','on');
            str = f.Label;
            [feature1, name1] = eg_runPlugin(handles.plugins.eventFeatures, ...
                str, chan, handles.fs, tmall, g, ...
                round(handles.EventLims(handles.popup_EventList.Value,:)*handles.fs));
            f = findobj('Parent',handles.menu_YAxis,'checked','on');
            str = f.Label;
            [feature2, name2] = eg_runPlugin(handles.plugins.eventFeatures, ...
                str, chan, handles.fs, tmall, g, ...
                round(handles.EventLims(handles.popup_EventList.Value,:)*handles.fs));
    
            for c = 1:length(feature1)
                if sel(c)==1
                    h = plot(handles.axes_Events, feature1(c),feature2(c),'o','markerfacecolor','k','markeredgecolor','k','markersize',2);
                    handles.EventWaveHandles = [handles.EventWaveHandles h];
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
        set(handles.EventWaveHandles,'ButtonDownFcn','electro_gui(''click_eventwave'',gcbo,[],guidata(gcbo))');
    end
    
    set(handles.axes_Events,'UIContextMenu',handles.context_EventViewer);
    set(handles.axes_Events,'ButtonDownFcn','electro_gui(''click_eventaxes'',gcbo,[],guidata(gcbo))');
    set(get(handles.axes_Events,'children'),'UIContextMenu',get(handles.axes_Events,'UIContextMenu'));
    
    if ~isempty(handles.SelectedEvent)
        i = handles.SelectedEvent;
        handles = SelectEvent(handles,i);
    end
    
    if handles.menu_AutoApplyYLim.Checked
        if handles.menu_DisplayValues.Checked
            if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
                handles.axes_Channel1.YLim = handles.axes_Events.YLim;
            elseif handles.menu_AutoLimits2.Checked
                handles.axes_Channel2.YLim = handles.axes_Events.YLim;
            end
        end
    end
    
    
function click_eventwave(hObject, ~, handles)
    
    i = find(handles.EventWaveHandles==hObject);
    if strcmp(handles.figure_Main.SelectionType,'normal')
        handles = SelectEvent(handles,i);
        guidata(hObject, handles);
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        set(hObject,'xdata',[],'ydata',[]);
        hold on
        handles.EventWaveHandles(i) = plot(mean(xlim),mean(ylim),'w.');
        hold off
        handles = DeleteEvents(handles,i);
        guidata(hObject, handles);
        delete(hObject);
    end
    
function handles = SelectEvent(handles,i)
    
    if isempty(i)
        return
    end
    delete(findobj('Parent',handles.axes_Events,'LineWidth',2));
    delete(findobj('LineStyle','-.'));
    handles.SelectedEvent = i;
    
    if i<=length(handles.EventWaveHandles)
        hold(handles.axes_Events, 'on');
        xl = xlim(handles.axes_Events);
        yl = ylim(handles.axes_Events);
        x = handles.EventWaveHandles(i).XData;
        y = handles.EventWaveHandles(i).YData;
        m = handles.EventWaveHandles(i).Marker;
        if strcmp(m,'none')
            h = plot(handles.axes_Events, x,y,'r','LineWidth',2);
        else
            ms = handles.EventWaveHandles(i).MarkerSize;
            h = plot(handles.axes_Events, x,y,'LineWidth',2,'marker',m,'markersize',ms,'markerfacecolor','r','markeredgecolor','r');
        end
        set(h,'ButtonDownFcn','electro_gui(''unselect_event'',gcbo,[],guidata(gcbo))');
        xlim(handles.axes_Events, xl);
        ylim(handles.axes_Events, yl);
        hold(handles.axes_Events, 'off');
    end
    
    
    handles.EventWaveHandles.ButtonDownFcn = 'electro_gui(''click_eventwave'',gcbo,[],guidata(gcbo))';
    
    filenum = getCurrentFileNum(handles);
    nums = [];
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    indx = handles.popup_EventList.Value-1;
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    tm = handles.EventTimes{f}{g,filenum};
    sel = handles.EventSelected{f}{g,filenum};
    tm = tm(sel==1);
    
    [handles, numSamples] = eg_GetNumSamples(handles);
    
    xs = linspace(0, numSamples/handles.fs, numSamples);
    hold(handles.axes_Sound, 'on');
    plot(handles.axes_Sound, [xs(tm(i)) xs(tm(i))], ylim(handles.axes_Sound),'-.','LineWidth',2,'Color','r');
    hold(handles.axes_Sound, 'off');

    h = [];
    for axnum = 1:2
        if handles.axes_Channel(axnum).Visible
            ys = handles.loadedChannelData{axnum};
            hold(handles.axes_Channel(axnum), 'on');
            h(end+1) = plot(handles.axes_Channel(axnum), xs(tm(i)),ys(tm(i)),'-.o','LineWidth',2,'markersize',5,'markerfacecolor','r','markeredgecolor','r');
            hold(handles.axes_Channel(axnum), 'off');
        end
    end
    [h.ButtonDownFcn] = deal('electro_gui(''unselect_event'',gcbo,[],guidata(gcbo))');
    
function unselect_event(hObject, ~, handles)
    
    handles.SelectedEvent = [];
    guidata(hObject, handles);
    
    delete(findobj('LineStyle','-.'));
    delete(findobj('Parent',handles.axes_Events,'LineWidth',2));
    
    
    
function click_eventaxes(hObject, ~, handles)
    
    if strcmp(handles.figure_Main.SelectionType,'normal')
        handles.axes_Event.Units = 'pixels';
        handles.axes_Event.Parent.Units = 'pixels';
        handles.figure_Main.Units = 'pixels';
        rect = rbbox;
    
        if rect(3)>0
            pos = handles.axes_Event.Position;
            pospan = handles.axes_Event.Parent.Position;
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
        handles.axes_Event.Parent.Units = 'normalized';
        handles.axes_Event.Units = 'normalized';
    
    elseif strcmp(handles.figure_Main.SelectionType,'open')
        axis tight
        yl = ylim;
        ylim([mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
        if handles.menu_DisplayFeatures.Checked
            xl = xlim;
            xlim([mean(xl)+(xl(1)-mean(xl))*1.1 mean(xl)+(xl(2)-mean(xl))*1.1]);
        end
        if handles.menu_AutoApplyYLim.Checked
            if handles.menu_DisplayValues.Checked
                if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
                    handles.axes_Channel1.YLim = handles.axes_Events.YLim;
                elseif handles.menu_AutoLimits2.Checked
                    handles.axes_Channel2.YLim = handles.axes_Events.YLim;
                end
            end
        end
    
    
    elseif strcmp(handles.figure_Main.SelectionType,'extend')
        delete(findobj('Parent',handles.axes_Event,'LineWidth',2));
        handles.SelectedEvent = [];
        delete(findobj('LineStyle','-.'));
    
        handles.axes_Event.Units = 'pixels';
        handles.axes_Event.Parent.Units = 'pixels';
        handles.figure_Main.Units = 'pixels';
        rect = rbbox;
    
        pos = handles.axes_Event.Position;
        pospan = handles.axes_Event.Parent.Position;
        handles.figure_Main.Units = 'normalized';
        handles.axes_Event.Parent.Units = 'normalized';
        handles.axes_Event.Units = 'normalized';
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
    for c = 1:length(handles.EventTimes)
        nums(c) = size(handles.EventTimes{c},1);
    end
    indx = handles.popup_EventList.Value-1;
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    sel = handles.EventSelected{f}{g,filenum};
    alr = find(sel==1);
    
    handles.EventSelected{f}{g,filenum}(alr(todel)) = 0;
    
    if ~isempty(todel) && handles.menu_DisplayValues.Checked
        axis tight
        yl = ylim;
        ylim([mean(yl)+(yl(1)-mean(yl))*1.1 mean(yl)+(yl(2)-mean(yl))*1.1]);
    end
    
    for axn = 1:2
        indx = handles.popup_EventList.Value-1;
        cs = cumsum(nums);
        f = length(find(cs<indx))+1;
        if handles.EventCurrentIndex(axn) == f && strcmp(handles.axes_Channel(axn).Visible,'on')
            handles = DisplayEvents(handles,axn);
        end
    
        val = get(handles.popup_Channels(3-axn),'value');
        str = get(handles.popup_Channels(3-axn),'string');
        nums = [];
        for c = 1:length(handles.EventTimes)
            nums(c) = size(handles.EventTimes{c},1);
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
    
    set(handles.axes_Events,'xlim',xlb,'ylim',ylb);
    
    
% --- Executes during object creation, after setting all properties.
function popup_EventList_CreateFcn(hObject, ~, handles)
    % hObject    handle to popup_EventList (see GCBO)
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
function menu_PlotToAnalyze_Callback(hObject, ~, handles)
    % hObject    handle to menu_PlotToAnalyze (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AnalyzeTop_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnalyzeTop (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.EventWhichPlot(handles.popup_EventList.Value)=1;
    handles.menu_AnalyzeTop.Checked = 'on';
    handles.menu_AnalyzeBottom.Checked = 'off';
    
    handles.SelectedEvent = [];
    
    handles = UpdateEventBrowser(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_ViewerDisplay_Callback(hObject, ~, handles)
    % hObject    handle to menu_ViewerDisplay (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
% --------------------------------------------------------------------
function menu_AnalyzeBottom_Callback(hObject, ~, handles)
    % hObject    handle to menu_AnalyzeBottom (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.EventWhichPlot(handles.popup_EventList.Value)=2;
    handles.menu_AnalyzeTop.Checked = 'off';
    handles.menu_AnalyzeBottom.Checked = 'on';
    
    handles.SelectedEvent = [];
    
    handles = UpdateEventBrowser(handles);
    
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function menu_DisplayValues_Callback(hObject, ~, handles)
    % hObject    handle to menu_DisplayValues (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_DisplayValues.Checked = 'on';
    handles.menu_DisplayFeatures.Checked = 'off';
    
    handles.menu_XAxis.Enable = 'off';
    handles.menu_YAxis.Enable = 'off';
    
    handles = UpdateEventBrowser(handles);
    
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
    
    handles = UpdateEventBrowser(handles);
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in push_DisplayEvents.
function push_DisplayEvents_Callback(hObject, ~, handles)
    % hObject    handle to push_DisplayEvents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles = UpdateEventBrowser(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_AutoDisplayEvents_Callback(hObject, ~, handles)
    % hObject    handle to menu_AutoDisplayEvents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    if handles.menu_AutoDisplayEvents.Checked
        handles.menu_AutoDisplayEvents.Checked = 'off';
    else
        handles.menu_AutoDisplayEvents.Checked = 'on';
        handles = UpdateEventBrowser(handles);
    end
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_EventsAxisLimits_Callback(hObject, ~, handles)
    % hObject    handle to menu_EventsAxisLimits (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    v = handles.popup_EventList.Value;
    answer = inputdlg({'Min (ms)','Max (ms)'},'Set limits',1,{num2str(-handles.EventLims(v,1)*1000),num2str(handles.EventLims(v,2)*1000)});
    if isempty(answer)
        return
    end
    handles.EventLims(v,:) = [-str2double(answer{1})/1000, str2double(answer{2})/1000];
    
    handles = UpdateEventBrowser(handles);
    
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
    
    handles = UpdateEventBrowser(handles);
    
    guidata(hObject, handles);
    
    
function YAxisMenuClick(hObject, ~, handles)
    
    handles.menu_YAxis_List.Checked = 'off';
    hObject.Checked = 'on';
    
    handles = UpdateEventBrowser(handles);
    
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
        set(radiohands(c),'enable',states{1+val(c)});
    end
    for c = 1:length(radiohands)
        if strcmp(radiohands(c).Enable,'off') && radiohands(c).Value==1
            for d = 1:length(radiohands)
                if strcmp(radiohands(d).Enable,'on')
                    set(radiohands(d),'value',1);
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
        'horizontalalignment','center','Color','r','backgroundcolor',[1 1 1],'fontsize',14);
    drawnow
    
    tempFilename = 'eg_temp.wav';
    
    %%%
    
    [handles, sound] = eg_GetSound(handles);
    
    str = handles.popup_Export.String;
    val = handles.popup_Export.Value;
    str = str{val};
    switch str
        case 'Segments'
            path = uigetdir(handles.DefaultRootPath,'Directory for segments');
            if ~ischar(path)
                delete(txtexp)
                return
            end
            handles.DefaultRootPath = path;
    
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
    
            dtm = datenum(handles.text_DateAndTime.String);
            sd = datestr(dtm,'yyyymmdd');
            st = datestr(dtm,'HHMMSS');
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
            set(fig,'visible','off','units','pixels');
            pos = get(fig,'position');
            pos(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(xl(2)-xl(1));
            pos(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
            fig.Position = pos;
            subplot('position',[0 0 1 1]);
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
                    if strcmp(handles.menu_Algorithm(c).Checked,'on')
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
                fig = figure;
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
                    plot(x,y,'Color',col,'LineStyle',ls,'LineWidth',lw,'marker',ma,'markersize',ms,'markerfacecolor',mf,'markeredgecolor',me);
                    hold on
                    if handles.menu_DisplayFeatures.Checked && sum(col==[1 0 0])~=3
                        xs = [xs x];
                        ys = [ys y];
                    end
                end
    
                xl = handles.axes_Events.XLim;
                yl = handles.axes_Events.YLim;
                xlab = handles.axes_Events.xlabel.String;
                ylab = handles.axes_Events.ylabel.String;
                str = {};
                if handles.menu_DisplayFeatures.Checked
                    xs = xs(xs>=xl(1) & xs<=xl(2));
                    ys = ys(ys>=yl(1) & ys<=yl(2));
                    str{1} = ['N = ' num2str(length(xs))];
                    str{2} = ['Mean ' xlab ' = ' num2str(mean(xs))];
                    str{3} = ['Stdev ' xlab ' = ' num2str(std(xs))];
                    str{4} = ['Mean ' ylab ' = ' num2str(mean(ys))];
                    str{5} = ['Stdev ' ylab ' = ' num2str(std(ys))];
                    txt = text(xl(1),yl(2),str);
                    set(txt,'HorizontalAlignment','left','VerticalAlignment','top','FontSize',8);
                end
    
                xlabel(xlab);
                ylabel(ylab);
                xlim(xl);
                ylim(yl);
                box off
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
                    fig = figure('units','inches');
                    ud.Sounds = {};
                    ud.Fs = [];
                    bcg = axes('position',[0 0 1 1],'visible','off');
                    ps = fig.Position;
                    ps(3) = handles.WorksheetWidth;
                    ps(4) = handles.WorksheetHeight;
                    fig.Position = ps;
                    if handles.WorksheetIncludeTitle == 1
                        txt = text(handles.WorksheetMargin/handles.WorksheetWidth,(handles.WorksheetHeight-handles.WorksheetMargin)/handles.WorksheetHeight,handles.WorksheetTitle);
                        set(txt,'HorizontalAlignment','left','VerticalAlignment','top','fontsize',14);
                        txt = text((handles.WorksheetWidth-handles.WorksheetMargin)/handles.WorksheetWidth,(handles.WorksheetHeight-handles.WorksheetMargin)/handles.WorksheetHeight,['Page ' num2str(j) '/' num2str(max(pagenum))]);
                        set(txt,'HorizontalAlignment','right','VerticalAlignment','top','fontsize',14);
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
                            axes('position',[x/handles.WorksheetWidth y/handles.WorksheetHeight wd/handles.WorksheetWidth handles.ExportSonogramHeight/handles.WorksheetHeight]);
                            hold on
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
                                    set(gca,'CLim',handles.WorksheetClim{lst{indx}(d)});
                                    fig.Colormap = handles.WorksheetColormap{lst{indx}(d)};
                                end
                                im = imagesc(handles.WorksheetXs{lst{indx}(d)}{i},handles.WorksheetYs{lst{indx}(d)}{i},p);
                                if handles.ExportSonogramIncludeClip > 0
                                    set(im,'ButtonDownFcn',['ud=get(gcf,''userdata''); sound(ud.Sounds{' num2str(length(ud.Sounds)) '},ud.Fs(' num2str(length(ud.Fs)) '))']);
                                end
                            end
                            xlim(handles.WorksheetXLims{lst{indx}(d)});
                            ylim(handles.WorksheetYLims{lst{indx}(d)});
                            axis off
                            if handles.ExportSonogramIncludeLabel == 1
                                fig.CurrentAxes = bcg;
                                txt = text((x+wd/2)/handles.WorksheetWidth,(y+handles.ExportSonogramHeight)/handles.WorksheetHeight,datestr(handles.WorksheetTimes(lst{indx}(d))));text
                                set(txt,'HorizontalAlignment','center','VerticalAlignment','bottom');
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
        pos = get(fig,'position');
        pos(3) = handles.ExportSonogramWidth*(xl(2)-xl(1));
        pos(4) = handles.ExportSonogramHeight;
        fig.Position = pos;
        set(fig,'PaperPositionMode','manual','Renderer','painters')
    
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
                    txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                    txt.TextFrame.TextRange.Text = handles.text_DateAndTime.String;
                    set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter',...
                        'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0,'WordWrap','msoFalse');
                    txt.TextFrame.TextRange.Font.Size = 8;
                    txt.Height = txt.TextFrame.TextRange.BoundHeight;
                    txt.Width = txt.TextFrame.TextRange.BoundWidth;
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
                    txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                    txt.TextFrame.TextRange.Text = handles.text_DateAndTime.String;
                    set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle','WordWrap','msoFalse',...
                        'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                    txt.TextFrame.TextRange.Font.Size = 8;
                    txt.Height = txt.TextFrame.TextRange.BoundHeight;
                    txt.Width = txt.TextFrame.TextRange.BoundWidth;
                    txt.Left = snd.Left+snd.Width;
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
    
    
                fig = figure('visible','off','units','pixels');
                set(fig,'PaperPositionMode','manual','Renderer','painters');
                subplot('position',[0 0 1 1]);
                axis off;
                for j = 1:max(pagenum)
                    if j > 1
                        slide_count = op.Slides.Count;
                        newslide = invoke(op.Slides,'Add',slide_count+1,'ppLayoutBlank');
                    end
                    if handles.WorksheetIncludeTitle == 1
                        txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                        txt.TextFrame.TextRange.Text = handles.WorksheetTitle;
                        set(txt.TextFrame,'VerticalAnchor','msoAnchorTop','WordWrap','msoFalse',...
                            'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                        txt.TextFrame.TextRange.Font.Size = 14;
                        txt.Height = txt.TextFrame.TextRange.BoundHeight;
                        txt.Width = txt.TextFrame.TextRange.BoundWidth;
                        txt.Left = 72*handles.WorksheetMargin+offx;
                        txt.Top = 72*handles.WorksheetMargin+offy;
    
                        txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                        txt.TextFrame.TextRange.Text = ['Page ' num2str(j) '/' num2str(max(pagenum))];
                        set(txt.TextFrame,'VerticalAnchor','msoAnchorTop','WordWrap','msoFalse',...
                            'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                        txt.TextFrame.TextRange.Font.Size = 14;
                        txt.Height = txt.TextFrame.TextRange.BoundHeight;
                        txt.Width = txt.TextFrame.TextRange.BoundWidth;
                        txt.Left = 72*(handles.WorksheetWidth-handles.WorksheetMargin-txt.Width+offx);
                        txt.Top = 72*handles.WorksheetMargin+offy;
                    end
    
                    f = find(pagenum==j);
                    for c = 1:length(f)
                        indx = f(c);
    
                        for d = 1:length(lst{indx})
                            cla
                            hold on
                            ps = fig.Position;
                            ps(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(handles.WorksheetXLims{lst{indx}(d)}(2)-handles.WorksheetXLims{lst{indx}(d)}(1));
                            ps(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
                            fig.Position = ps;
    
                            x = (handles.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + handles.WorksheetHorizontalInterval*(d-1);
                            wd = widths(lst{indx}(d));
                            y = handles.WorksheetMargin + handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight + handles.WorksheetVerticalInterval*(c-1) + handles.ExportSonogramHeight*(c-1);
    
                            for i = 1:length(handles.WorksheetMs{lst{indx}(d)})
                                p = handles.WorksheetMs{lst{indx}(d)}{i};
                                imagesc(handles.WorksheetXs{lst{indx}(d)}{i},handles.WorksheetYs{lst{indx}(d)}{i},p);
                                set(gca,'CLim',handles.WorksheetClim{lst{indx}(d)});
                                fig.Colormap = handles.WorksheetColormap{lst{indx}(d)};
                            end
                            xlim(handles.WorksheetXLims{lst{indx}(d)});
                            ylim(handles.WorksheetYLims{lst{indx}(d)});
    
                            print('-dmeta',['-f' num2str(fig)]);
                            pic = invoke(newslide.Shapes,'PasteSpecial',2);
                            ug = invoke(pic,'Ungroup');
                            ug.Fill.Visible = 'msoFalse';
                            set(ug,'Height',72*handles.ExportSonogramHeight,'Width',72*handles.ExportSonogramWidth*(handles.WorksheetXLims{lst{indx}(d)}(2)-handles.WorksheetXLims{lst{indx}(d)}(1)));
                            set(ug,'Left',72*x+offx,'Top',72*(y+handles.WorksheetVerticalInterval)+offy);
    
                            if handles.ExportSonogramIncludeLabel == 1
                                txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                                txt.TextFrame.TextRange.Text = datestr(handles.WorksheetTimes(lst{indx}(d)));
                                set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter',...
                                    'WordWrap','msoFalse','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                                txt.TextFrame.TextRange.Font.Size = 10;
                                txt.Height = txt.TextFrame.TextRange.BoundHeight;
                                txt.Width = txt.TextFrame.TextRange.BoundWidth;
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
    
                fig = figure('visible','off','units','pixels');
                set(fig,'PaperPositionMode','manual','Renderer','painters');
                subplot('position',[0 0 1 1]);
    
                xl = handles.axes_Sonogram.XLim;
    
                offx = (op.PageSetup.SlideWidth-72*handles.ExportSonogramWidth*(xl(2)-xl(1)))/2;
                offy = (op.PageSetup.SlideHeight-72*(sum(handles.template.Height)+sum(handles.template.Interval(1:end-1))))/2;
    
                sound_inserted = 0;
    
                ch = handles.menu_ProgressBar.Children;
                progbar = [];
                axs = [handles.axes_Channel2 handles.axes_Channel1 handles.axes_Amplitude handles.axes_Segments handles.axes_Sonogram handles.axes_Sound];
                for c = 1:length(ch)
                    if strcmp(ch(c).Checked,'on') && strcmp(axs(c).Visible,'on')
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
    
                    cla
    
                    include_progbar = 0;
    
                    switch handles.template.Plot{c}
    
                        case 'Sonogram'
                            if ~isempty(find(progbar==5, 1))
                                include_progbar = 1;
                            end
    
                            yl = handles.axes_Sonogram.YLim;
    
                            hold on
                            if handles.ExportReplotSonogram == 0
                                ch = findobj('Parent',handles.axes_Sonogram,'type','image');
                                for j = 1:length(ch)
                                    if ch(j) ~= txtexp
                                        x = ch(j).XData;
                                        y = ch(j).YData;
                                        m = ch(j).CData;
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
    
                                if xlp(2)>numSamples; xlp(2) = numSamples; end
                                for j = 1:length(handles.menu_Algorithm)
                                    if strcmp(handles.menu_Algorithm(j).Checked,'on')
                                        alg = handles.menu_Algorithm(j).Label;
                                    end
                                end
                                eg_runPlugin(handles.plugins.spectrums, ...
                                    alg, gca, sound(xlp(1):xlp(2)), ...
                                    handles.fs, handles.SonogramParams);
                                set(gca,'ydir','normal');
                                handles.NewSlope = handles.DerivativeSlope;
                                handles.DerivativeSlope = 0;
                                handles = SetSonogramColors(handles);
                            end
                            cl = handles.axes_Sonogram.CLim;
                            set(gca,'CLim',cl);
                            col = handles.figure_Main.Colormap;
                            fig.Colormap = col;
                            axis tight;
                            axis off;
    
    
    
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
    
                            hold on
                            [handles, numSamples] = eg_GetNumSamples(handles);
    
                            xs = linspace(0, numSamples/handles.fs, numSamples);
                            for j = f'
                                if sel(j)==1
                                    patch(xs([st(j,1) st(j,2) st(j,2) st(j,1)]),[0 0 1 1],handles.SegmentSelectColor);
                                end
                            end
    
                            ylim([0 1]);
                            axis off
    
    
                        case 'Segment labels'
                            st = handles.SegmentTimes{getCurrentFileNum(handles)};
                            sel = handles.SegmentSelection{getCurrentFileNum(handles)};
                            lab = handles.SegmentTitles{getCurrentFileNum(handles)};
                            f = find(st(:,1)>xl(1)*handles.fs & st(:,1)<xl(2)*handles.fs);
                            g = find(st(:,2)>xl(1)*handles.fs & st(:,2)<xl(2)*handles.fs);
                            h = find(st(:,1)<xl(1)*handles.fs & st(:,2)>xl(2)*handles.fs);
                            f = unique([f; g; h]);
    
                            hold on
                            [handles, numSamples] = eg_GetNumSamples(handles);
    
                            xs = linspace(0, numSamples/handles.fs, numSamples);
                            for j = f'
                                if sel(j)==1
                                    if ~isempty(lab{j})
                                        txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                                        txt.TextFrame.TextRange.Text = lab{j};
                                        set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter',...
                                            'WordWrap','msoFalse','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                                        txt.TextFrame.TextRange.Font.Size = 8;
                                        txt.Height = txt.TextFrame.TextRange.BoundHeight;
                                        txt.Width = txt.TextFrame.TextRange.BoundWidth;
                                        set(txt,'Left',offx+72*handles.ExportSonogramWidth*mean(xs(st(j,:))-xl(1))-txt.Width/2);
                                        txt.Top = offy+72*(sum(handles.template.Interval(1:c-1)+sum(handles.template.Height(1:c-1))));
                                    end
                                end
                            end
    
                            axis off
    
    
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
                            plot(x(f),y(f),'Color',col);
    
                            ylim(handles.axes_Amplitude.YLim);
                            set(gca,'ydir','normal');
                            axis off
    
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
                            hold on
                            for j = 1:length(m)
                                x = m(j).XData;
                                y = m(j).YData;
                                col = m(j).Color;
                                linewidth = m(j).LineWidth;
                                f = find(x>=xl(1) & x<=xl(2));
                                if sum(col==1)==3
                                    col = col-eps;
                                end
                                plot(x(f),y(f),'Color',col);
                            end
    
                            ylim(handles.axes_Channel(axnum).YLim);
                            set(gca,'ydir','normal');
                            axis off
    
                        case 'Sound wave'
                            if ~isempty(find(progbar==6, 1))
                                include_progbar = 1;
                            end
    
                            m = findobj('Parent',handles.axes_Sound,'LineStyle','-');
                            hold on
                            for j = 1:length(m)
                                x = m(j).XData;
                                y = m(j).YData;
                                f = find(x>=xl(1) & x<=xl(2));
                                plot(x(f),y(f),'b');
                            end
                            linewidth = 1;
    
                            ylim(handles.axes_Sound.YLim);
                            set(gca,'ydir','normal');
                            axis off
    
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
                                        txt = handles.axes_Amplitude.ylabel.String;
                                        fnd2 = strfind(txt,')');
                                        if ~isempty(fnd2)
                                            fnd1 = strfind(txt(1:fnd2(end)),'(');
                                            if ~isempty(fnd1)
                                                unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                            end
                                        end
                                    case 'Top plot'
                                        txt = handles.axes_Channel1.ylabel.String;
                                        fnd2 = strfind(txt,')');
                                        if ~isempty(fnd2)
                                            fnd1 = strfind(txt(1:fnd2(end)),'(');
                                            if ~isempty(fnd1)
                                                unit = [' ' txt(fnd1(end)+1:fnd2(end)-1)];
                                            end
                                        end
                                    case 'Bottom plot'
                                        txt = handles.axes_Channel2.ylabel.String;
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
    
                                txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                                txt.TextFrame.TextRange.Text = [num2str(val) unit];
                                set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle','WordWrap','msoFalse',...
                                    'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                                txt.TextFrame.TextRange.Font.Size = 8;
                                txt.Height = txt.TextFrame.TextRange.BoundHeight;
                                txt.Width = txt.TextFrame.TextRange.BoundWidth;
    
                                txt.Top = ug.Top+0.5*ug.Height-0.5*txt.Height;
    
                                if handles.VerticalScalebarPosition <= 0
                                    txt.Left = sb_posx-txt.Width-72*0.05;
                                    txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignRight';
                                else
                                    txt.Left = sb_posx+72*0.05;
                                    txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignLeft';
                                end
    
                            case 2 % axis
                                invoke(newslide.Shapes,'AddLine',offx,ug.Top,offx,ug.Top+ug.Height);
                                fig_yscale = figure('visible','off','units','inches');
                                ps = fig_yscale.Position;
                                ps(4) = handles.template.Height(c);
                                fig_yscale.Position = ps;
                                subplot('position',[0 0 1 1]);
                                ylim([yl(1) yl(2)]);
                                ytick = get(gca,'YTick');
                                delete(fig_yscale);
    
                                switch handles.template.Plot{c}
                                    case 'Sonogram'
                                        str = handles.axes_Sonogram.ylabel.String;
                                    case 'Amplitude'
                                        str = handles.axes_Amplitude.ylabel.String;
                                    case 'Top plot'
                                        str = handles.axes_Channel1.ylabel.String;
                                    case 'Bottom plot'
                                        str = handles.axes_Channel2.ylabel.String;
                                    case 'Sound wave'
                                        str = 'Sound amplitude (ADU)';
                                end
    
                                mn = inf;
                                for j = 1:length(ytick')
                                    tickpos = ug.Top+ug.Height-(ytick(j)-yl(1))/(yl(2)-yl(1))*ug.Height;
                                    invoke(newslide.Shapes,'AddLine',offx,tickpos,offx+72*0.02,tickpos);
    
                                    txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                                    txt.TextFrame.TextRange.Text = num2str(ytick(j));
                                    set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle','WordWrap','msoFalse',...
                                        'MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                                    txt.TextFrame.TextRange.Font.Size = 8;
                                    txt.Height = txt.TextFrame.TextRange.BoundHeight;
                                    txt.Width = txt.TextFrame.TextRange.BoundWidth;
                                    txt.Top = tickpos-0.5*txt.Height;
                                    txt.Left = offx-txt.Width-72*0.02;
                                    mn = min([mn txt.Left]);
                                    txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignRight';
                                end
    
    %                             if strcmp(handles.template.Plot{c},'Sonogram')
    %                                 ytick = ytick/1000;
    %                             end
    
                                txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                                txt.TextFrame.TextRange.Text = str;
                                set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter',...
                                    'WordWrap','msoFalse','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                                txt.TextFrame.TextRange.Font.Size = 10;
                                txt.Height = txt.TextFrame.TextRange.BoundHeight;
                                txt.Width = txt.TextFrame.TextRange.BoundWidth;
                                txt.Rotation = 270;
                                txt.Top = ug.Top+0.5*ug.Height-0.5*txt.Height;
                                txt.Left = mn-0.5*txt.Width-72*0.15;
                                txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignCenter';
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
                                        set(ug.Item(j).Line,'Weight',linewidth);
                                    end
                                end
                            end
                        end
                    end
                end
    
                if handles.ExportSonogramIncludeLabel == 1
                    dt = datevec(handles.text_DateAndTime.String);
                    dt(6) = dt(6)+xl(1);
                    txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                    txt.TextFrame.TextRange.Text = datestr(dt);
                    set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter',...
                        'WordWrap','msoFalse','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                    txt.TextFrame.TextRange.Font.Size = 10;
                    txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignCenter';
                    txt.Height = txt.TextFrame.TextRange.BoundHeight;
                    txt.Width = txt.TextFrame.TextRange.BoundWidth;
                    txt.Left = (op.PageSetup.SlideWidth-txt.Width/2);
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
    
                    animopt = findobj('Parent',handles.menu_Animation,'checked','on');
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
                            set(itm(end).Timing,'TriggerType','msoAnimTriggerWithPrevious');
                            invoke(itm(end),'MoveAfter',itm(end-1));
    
                            itm(end+1) = invoke(newslide.TimeLine.MainSequence,'AddEffect',animline,'msoAnimEffectPathRight');
                            set(itm(end).Timing,'TriggerType','msoAnimTriggerWithPrevious');
                            set(itm(end).Timing,'SmoothStart','msoFalse','SmoothEnd','msoFalse');
                            set(itm(end).Timing,'Duration',length(wav)/fs);
    
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
                            set(itm(end),'Exit','msoTrue');
                            set(itm(end).Timing,'TriggerDelayTime',length(wav)/fs,'Duration',0.01)
                            set(itm(end).Timing,'TriggerType','msoAnimTriggerWithPrevious');
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
                txt = invoke(newslide.Shapes,'AddTextBox',1,0,0,0,0);
                txt.TextFrame.TextRange.Text = handles.ScalebarLabels{j};
                set(txt.TextFrame,'VerticalAnchor','msoAnchorTop','HorizontalAnchor','msoAnchorCenter',...
                    'WordWrap','msoFalse','MarginLeft',0,'MarginRight',0,'MarginTop',0,'MarginBottom',0);
                txt.TextFrame.TextRange.Font.Size = 8;
                txt.TextFrame.TextRange.ParagraphFormat.Alignment = 'ppAlignCenter';
                txt.Height = txt.TextFrame.TextRange.BoundHeight;
                txt.Width = txt.TextFrame.TextRange.BoundWidth;
                txt.Left = (x1+x2/2-txt.Width/2);
                txt.Top = y;
    
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
    
    
% --- Executes on button press in push_WorksheetAppend.
function push_WorksheetAppend_Callback(hObject, ~, handles)
    % hObject    handle to push_WorksheetAppend (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    xl = handles.axes_Sonogram.XLim;
    yl = handles.axes_Sonogram.YLim;
    fig = figure;
    set(fig,'visible','off','units','pixels');
    pos = get(fig,'position');
    pos(3) = handles.ExportSonogramResolution*handles.ExportSonogramWidth*(xl(2)-xl(1));
    pos(4) = handles.ExportSonogramResolution*handles.ExportSonogramHeight;
    fig.Position = pos;
    subplot('position',[0 0 1 1]);
    hold on
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
        xlim(xl);
        ylim(yl);
        xlp = round(xl*handles.fs);
        if xlp(1)<1; xlp(1) = 1; end
        [handles, numSamples] = eg_GetNumSamples(handles);
    
        if xlp(2)>numSamples; xlp(2) = numSamples; end
        for c = 1:length(handles.menu_Algorithm)
            if strcmp(handles.menu_Algorithm(c).Checked,'on')
                alg = handles.menu_Algorithm(c).Label;
            end
        end
    
        [handles, sound] = eg_GetSound(handles);
    
        pow = eg_runPlugin(handles.plugins.spectrums, alg, gca, ...
            sound(xlp(1):xlp(2)), handles.fs, handles.SonogramParams);
        set(gca,'ydir','normal');
        handles.NewSlope = handles.DerivativeSlope;
        handles.DerivativeSlope = 0;
        handles = SetSonogramColors(handles);
        ch = get(gca,'children');
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
    dt = datevec(handles.text_DateAndTime.String);
    xd = handles.axes_Sonogram.XLim;
    dt(6) = dt(6)+xd(1);
    handles.WorksheetTimes(end+1) = datenum(dt);
    
    handles = UpdateWorksheet(handles);
    
    str = handles.panel_Worksheet.Title ;
    f = strfind(str,'/');
    tot = str2double(str(f+1:end));
    handles.WorksheetCurrentPage = tot;
    handles = UpdateWorksheet(handles);
    
    if length(handles.WorksheetHandles)>=length(handles.WorksheetMs)
        if ishandle(handles.WorksheetHandles(length(handles.WorksheetMs)))
            set(handles.WorksheetHandles(length(handles.WorksheetMs)), 'FaceColor', 'r');
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
    handles.WorksheetHandles = [];
    for c = 1:length(f)
        indx = f(c);
        for d = 1:length(lst{indx})
            x = (handles.WorksheetWidth-used(indx))/2 + sum(widths(lst{indx}(1:d-1))) + handles.WorksheetHorizontalInterval*(d-1);
            wd = widths(lst{indx}(d));
            y = handles.WorksheetHeight - handles.WorksheetMargin - handles.WorksheetIncludeTitle*handles.WorksheetTitleHeight - handles.WorksheetVerticalInterval*c - handles.ExportSonogramHeight*c;
            handles.WorksheetHandles(lst{indx}(d)) = patch(handles.axes_Worksheet, [x, x+wd, x+wd, x], [y, y, y+handles.ExportSonogramHeight, y+handles.ExportSonogramHeight], [.5, .5, .5]);
        end
    end
    
    handles.WorksheetHandles.ButtonDownFcn = 'electro_gui(''click_Worksheet'',gcbo,[],guidata(gcbo))';
    handles.WorksheetHandles.UIContextMenu = handles.context_Worksheet;
    
    axis(handles.axes_Worksheet, 'equal');
    axis(handles.axes_Worksheet, 'tight');
    axis(handles.axes_Worksheet, 'off');
    
    handles.panel_Worksheet.Title = ['Worksheet: Page ' num2str(handles.WorksheetCurrentPage) '/' num2str(max([1 max(pagenum)]))];
    
function click_Worksheet(hObject, ~, handles)
    
    ch = handles.axes_Worksheet.Children;
    for c = 1:length(ch)
        if sum(ch(c).FaceColor==[1 1 1])<3
            set(ch(c),'facecolor',[.5 .5 .5]);
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
    
    f = find(handles.WorksheetHandles==findobj('Parent',handles.axes_Worksheet,'facecolor','r'));
    
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
    
    f = find(handles.WorksheetHandles==findobj('Parent',handles.axes_Worksheet,'facecolor','r'));
    
    fig = figure;
    fig.Visible = 'off';
    fig.Units = 'inches';
    pos = fig.Position;
    pos(3) = handles.ExportSonogramWidth*(handles.WorksheetXLims{f}(2)-handles.WorksheetXLims{f}(1));
    pos(4) = handles.ExportSonogramHeight;
    fig.Position = pos;
    subplot('position',[0 0 1 1]);
    hold on
    for c = 1:length(handles.WorksheetMs{f})
        imagesc(handles.WorksheetXs{f}{c},handles.WorksheetYs{f}{c},handles.WorksheetMs{f}{c});
    end
    set(gca,'CLim',handles.WorksheetClim{f});
    fig.Colormap = handles.WorksheetColormap{f};
    axis tight;
    axis off;
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
    
    da = [];
    if handles.menu_OverlayTop.Checked
        da = [da 1];
    end
    if handles.menu_OverlayBottom.Checked
        da = [da 2];
    end
    
    xl = xlim(handles.axes_Sonogram);
    yl = ylim(handles.axes_Sonogram);
    hold(handles.axes_Sonogram, 'on');
    
    delete(findobj('Parent', handles.axes_Sonogram, 'LineStyle', '-'))
    for j = da
        lm = handles.axes_Channel(j).YLim;
        ch = findobj('Parent', handles.axes_Channel(j), 'LineStyle', '-');
        for c = 1:length(ch)
            x = ch(c).XData;
            y = ch(c).YData;
            y = (y-lm(1))/(lm(2)-lm(1));
            y = y*(yl(2)-yl(1))+yl(1);
            col = ch(c).Color;
            lw = ch(c).LineWidth;
            plot(handles.axes_Sonogram, x, y, 'Color', col, 'LineWidth', lw);
        end
    end
    
    for child = handles.axes_Sonogram.Children
        child.UIContextMenu = handles.axes_Sonogram.UIContextMenu;
        child.ButtonDownFcn = handles.axes_Sonogram.ButtonDownFcn;
    end
    
    hold(handles.axes_Sonogram, 'off');
    xlim(handles.axes_Sonogram, xl);
    ylim(handles.axes_Sonogram, yl);
    
    
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
        if strcmp(handles.menu_Algorithm(c).Checked,'on')
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
    
    pr = handles.EventParams{axnum};
    
    if ~isfield(pr,'Names') || isempty(pr.Names)
        errordlg('Current event detector does not require parameters.','Event detector error');
        return
    end
    
    answer = inputdlg(pr.Names,'Event detector parameters',1,pr.Values);
    if isempty(answer)
        return
    end
    pr.Values = answer;
    
    handles.EventParams{axnum} = pr;
    
    v = get(handles.(['popup_EventDetector' num2str(axnum)]),'value');
    ud = get(handles.(['popup_EventDetector' num2str(axnum)]),'userdata');
    ud{v} = handles.EventParams{axnum};
    set(handles.(['popup_EventDetector' num2str(axnum)]),'userdata',ud);
    
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
    set(handles.popup_Functions(axnum),'userdata',ud);
    
    if isempty(findobj('Parent',handles.axes_Sonogram,'type','text'))
        handles = eg_LoadChannel(handles,axnum);
        handles = eg_clickEventDetector(handles,axnum);
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
    set(gca,'units','pixels');
    set(get(gca,'parent'),'units','pixels');
    rect = rbbox;
    pos = get(gca,'position');
    set(get(gca,'parent'),'units','normalized');
    set(gca,'units','normalized');
    xl = xlim;
    yl = ylim;
    rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
    rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
    rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
    
    for c = 1:length(handles.menu_Segmenter)
        if strcmp(handles.menu_Segmenter(c).Checked,'on')
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
    handles = PlotSegments(handles);
    set(gcf,'keypressfcn','electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))');
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceSoundAmplitude_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceSoundAmplitude (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_SourceSoundAmplitude.Checked = 'on';
    handles.menu_SourceTopPlot.Checked = 'off';
    handles.menu_SourceBottomPlot.Checked = 'off';
    
    [handles.amplitude, labels] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
    plt.YData = handles.amplitude;
    ylabel(handles.axes_Amplitude, labels);
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceTopPlot_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceTopPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    handles.menu_SourceSoundAmplitude.Checked = 'off';
    handles.menu_SourceTopPlot.Checked = 'on';
    handles.menu_SourceBottomPlot.Checked = 'off';
    
    [handles.amplitude, labels] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent',handles.axes_Amplitude,'LineStyle','-');
    plt.YData = handles.amplitude;
    ylabel(handles.axes_Amplitude, labels);
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
    
% --------------------------------------------------------------------
function menu_SourceBottomPlot_Callback(hObject, ~, handles)
    % hObject    handle to menu_SourceBottomPlot (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    
    handles.menu_SourceSoundAmplitude.Checked = 'off';
    handles.menu_SourceTopPlot.Checked = 'off';
    handles.menu_SourceBottomPlot.Checked = 'on';
    
    [handles.amplitude, labels] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent', handles.axes_Amplitude, 'LineStyle', '-');
    plt.YData = handles.amplitude;
    ylabel(handles.axes_Amplitude, labels);
    
    handles = SetThreshold(handles);
    
    guidata(hObject, handles);
    
    
function [amp, labels] = eg_CalculateAmplitude(handles)
    
    [handles, sound] = eg_GetSound(handles);
    
    wind = round(handles.SmoothWindow*handles.fs);
    if handles.menu_DontPlot.Checked
        amp = zeros(size(sound));
        labels = '';
    else
        if handles.menu_SourceSoundAmplitude.Checked
            [handles, filtered_sound] = eg_GetSound(handles, true);
            amp = smooth(10*log10(filtered_sound.^2+eps),wind);
            amp = amp-min(amp(wind:length(amp)-wind));
            amp(amp<0)=0;
            labels = 'Loudness (dB)';
        elseif handles.menu_SourceTopPlot.Checked
            if handles.axes_Channel1.Visible
                amp = smooth(handles.loadedChannelData{1},wind);
                labels = handles.axes_Channel1.ylabel.String;
            else
                amp = zeros(size(sound));
                labels = '';
            end
        elseif handles.menu_SourceBottomPlot.Checked
            if handles.axes_Channel2.Visible
                amp = smooth(handles.loadedChannelData{2},wind);
                labels = handles.axes_Channel2.ylabel.String;
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
    
    set(gca,'units','pixels');
    set(get(gca,'parent'),'units','pixels');
    ginput(1);
    rect = rbbox;
    
    pos = get(gca,'position');
    set(get(gca,'parent'),'units','normalized');
    set(gca,'units','normalized');
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
    handles = PlotSegments(handles);
    
    handles = SetActiveSegment(handles, min(f));
    % set(handles.SegmentHandles,'edgecolor',handles.SegmentInactiveColor,'LineWidth',1);
    % set(handles.SegmentHandles(min(f)),'edgecolor',handles.SegmentActiveColor,'LineWidth',2);
    set(gcf,'keypressfcn','electro_gui(''labelsegment'',gcbo,[],guidata(gcbo))');
    
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
        if strcmp(handles.menu_Filter(c).Checked,'on')
            h = handles.menu_Filter(c);
            h.UserData = handles.FilterParams;
        end
    end
    
    handles = eg_FilterSound(handles);
    
    [handles, filtered_sound] = eg_GetSound(handles, true);
    
    xd = handles.xlimbox.XData;
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
    
    yl = handles.axes_Sound.YLim;
    hold(handles.axes_Sound, 'on');
    handles.xlimbox = plot(handles.axes_Sound, [xd(1) xd(2) xd(2) xd(1) xd(1)],[yl(1) yl(1) yl(2) yl(2) yl(1)]*.93,':y','LineWidth',2);
    handles.axes_Sound.XLim = [0, numSamples/handles.fs];
    hold(handles.axes_Sound, 'off');
    box(handles.axes_Sound, 'on');
    
    set(handles.axes_Sonogram,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
    ch = handles.axes_Sonogram.Children;
    [ch.ButtonDownFcn] = deal(handles.axes_Sonogram.ButtonDownFcn);
    
    set(handles.axes_Sound,'ButtonDownFcn','electro_gui(''click_sound'',gcbo,[],guidata(gcbo))');
    ch = handles.axes_Sound.Children;
    [ch.ButtonDownFcn] = deal(handles.axes_Sound.ButtonDownFcn);
        
    [handles.amplitude, ~] = eg_CalculateAmplitude(handles);
    
    plt = findobj('Parent', handles.axes_Amplitude, 'LineStyle', '-');
    plt.YData = handles.amplitude;
    
    handles = SetThreshold(handles);
    
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
    handles.PropertyTextHandles = [];
    if isfield(handles,'PropertyObjectHandles')
        delete(handles.PropertyObjectHandles);
    end
    handles.PropertyObjectHandles = [];
    
    handles.DefaultPropertyValues = {};
    
    lns = linspace(0,1,2*length(handles.PropertyNames)+1);
    lns = lns(2:2:end);
    for c = 1:length(handles.PropertyNames)
        wd = min([0.95*(1/7) 0.95*(1/length(handles.PropertyNames))]);
        x = lns(c)-wd/2;
    
        switch handles.PropertyTypes(c)
            case 1 % string
                handles.PropertyObjectHandles(c) = uicontrol(handles.panel_Properties,'Style','edit',...
                    'units','normalized','string','','position',[x 0.1 wd 0.55],...
                    'FontSize',10,'horizontalalignment','left','backgroundcolor',[1 1 1]);
                handles.DefaultPropertyValues{c} = '';
            case 2 % boolean
                handles.PropertyObjectHandles(c) = uicontrol(handles.panel_Properties,'Style','checkbox',...
                    'units','normalized','string','a','position',[x 0.1 wd/2 0.55],'FontSize',8);
                ext = handles.PropertyObjectHandles(c).Extent;
                set(handles.PropertyObjectHandles(c),'string','','position',[x+wd/2-ext(4)/2 0.1 ext(4) 0.55]);
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
                    'units','normalized','string',str,'position',[x 0.1 wd 0.55],...
                    'FontSize',10,'horizontalalignment','center','backgroundcolor',[1 1 1]);
                handles.DefaultPropertyValues{c} = str{1};
        end
    
        handles.PropertyTextHandles(c) = uicontrol(handles.panel_Properties,'Style','text',...
            'units','normalized','string',handles.PropertyNames{c},'position',[x 0.65 wd 0.3],...
            'FontSize',8,'horizontalalignment','center');
    end
    
    for c = 1:length(bck_def)
        for d = 1:length(handles.PropertyNames)
            if strcmp(bck_nm{c},handles.PropertyNames{d})
                handles.DefaultPropertyValues{d} = bck_def{c};
            end
        end
    end
    
    set(handles.PropertyObjectHandles,'callback','electro_gui(''ChangeProperty'',gcbo,[],guidata(gcbo))');
    set(handles.PropertyTextHandles,'ButtonDownFcn','electro_gui(''ClickPropertyText'',gcbo,[],guidata(gcbo))');
    
    
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
                set(handles.PropertyObjectHandles(f),'value',1,'string',str);
                for c = 1:length(str)
                    if strcmp(str{c},handles.Properties.Values{filenum}{indx})
                        set(handles.PropertyObjectHandles(f),'value',c);
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
            set(handles.PropertyTextHandles(c),'enable','off')
            set(handles.PropertyObjectHandles(c),'visible','off')
        else
            set(handles.PropertyTextHandles(c),'enable','on')
            set(handles.PropertyObjectHandles(c),'visible','on')
            switch handles.PropertyObjectHandles(c).Style
                case 'edit'
                    set(handles.PropertyObjectHandles(c),'string',handles.Properties.Values{filenum}{indx});
                case 'checkbox'
                    set(handles.PropertyObjectHandles(c),'value',handles.Properties.Values{filenum}{indx});
                case 'popupmenu'
                    str = handles.PropertyObjectHandles(c).String;
                    for d = 1:length(str)
                        if strcmp(str{d},handles.Properties.Values{filenum}{indx})
                            set(handles.PropertyObjectHandles(c),'value',d);
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
    
    typestr = {'string','boolean','list'};
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
                'units','normalized','string',str,'position',[0 0 .1 .1],'visible','off',...
                'FontSize',10,'horizontalalignment','center','backgroundcolor',[1 1 1]);
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
    
    answer = inputdlg({['New name to replace "' handles.PropertyNames{indx} '"']},'Rename property',1,{handles.PropertyNames{indx}});
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
    set(handles.PropertyTextHandles(indx),'string',answer{1});
    
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
                set(handles.PropertyObjectHandles(indx),'string',str);
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
                set(handles.PropertyObjectHandles(indx),'string',str);
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
        set(handles.PropertyObjectHandles(f(indx(c))),'string',str);
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
        set(ch(c),'checked','off');
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
                if handles.menu_AnalyzeTop.Checked && handles.menu_AutoLimits1.Checked
                    handles.axes_Channel1.YLim = handles.axes_Events.YLim;
                elseif handles.menu_AutoLimits2.Checked
                    handles.axes_Channel2.YLim = handles.axes_Events.YLim;
                end
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
    
    dbase.EventSources = handles.EventSources;
    dbase.EventFunctions = handles.EventFunctions;
    dbase.EventDetectors = handles.EventDetectors;
    dbase.EventThresholds = handles.EventThresholds;
    dbase.EventTimes = handles.EventTimes;
    dbase.EventIsSelected = handles.EventSelected;
    
    dbase.Properties = handles.Properties;
    
    dbase.AnalysisState.SourceList = handles.popup_Channel1.String;
    dbase.AnalysisState.EventList = handles.popup_EventList.String;
    dbase.AnalysisState.CurrentFile = getCurrentFileNum(handles);
    dbase.AnalysisState.EventWhichPlot = handles.EventWhichPlot;
    dbase.AnalysisState.EventLims = handles.EventLims;
    
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
    menu_EventSetThreshold1_Callback;
    menu_Events2_Callback;
    menu_EventAutoDetect2_Callback;
    menu_EventAutoThreshold2_Callback;
    menu_EventSetThreshold2_Callback;
    push_Detect1_Callback;
    push_Detect2_Callback;
    ClickEventSymbol;
    EventsDisplayClick;
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
    menu_PlotToAnalyze_Callback;
    menu_AnalyzeTop_Callback;
    menu_ViewerDisplay_Callback;
    menu_AnalyzeBottom_Callback;
    menu_DisplayValues_Callback;
    menu_DisplayFeatures_Callback;
    push_DisplayEvents_Callback;
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
    