function settings = defaults_template(settings)
% Default settings

% GENERAL SETTINGS
settings.TooLong = 400000000;            % Number of points for a file to be considered too long for loading automatically
settings.FileString = '*chan%d.nc';      % File search string; must include a string formatting expression to handle an integer channel #, such as %02d for integers zero-padded to 2 digits, or %d for unpadded integers.handles.DefaultFileLoader = 'Intan_Bin'; % Default file loader. Choose from egl_* files.
settings.DefaultFileLoader = 'Intan_Nc'; % Default file loader. Choose from egl_* files.
settings.DefaultChannelNumber = 20;      % Default number of channels
settings.QuoteFile = 'quotes.txt';       % File to get startup quotes from
settings.IncludeDocumentation = true;    % Include field documentation in dbase? This adds a little size to the dbase file.
settings.CurrentFile = 1;                % File number to start at
settings.DefaultChannelFs = NaN;         % Default sampling rate for channels. Must be either a single sampling rate which will apply to all channels, or a 1xC list of sampling rates, one per channel. 
                                         % This will override the sampling rate loaded from files, unless a value is NaN, in which the loaded  sampling rate will be used.

% UNDO/REDO SETTINGS
settings.UndoEnabled = true;             % Enable control-z for undo and control-y or control-shift-z for redo - this adds some overhead to operations.
settings.MaxHistoryLength = 10;          % Maximum number of states to save (for undo/redo purposes). Higher = more memory, more undos
settings.HistoryInterval = 3;            % Minimum time in seconds between saving states - set to zero to save the state on every change regardless of how fast.

% PROPERTIES SETTINGS
settings.DefaultProperties.Names = {};      % {'bSorted', 'bDirected', 'bContainsStim', 'bUnusable'};   % Cell array of default property names to add to a new dbase
settings.DefaultProperties.Values = [];     % [false, false, false, false];  % Corresponding default values for /\

% FILE INFO BROWSER SETTINGS
settings.FileSortMethod = 'File number';    % Default file sorting method - one of {'File number', 'Random', 'Property', 'Read status'}
settings.FileSortPropertyName = '';         % Default property to sort by if FileSortMethod is 'Property'
settings.FileSortReversed = false;
settings.FileReadColor = [1, 1, 1];
settings.FileUnreadColor = [1, 0.8, 0.8];
settings.ShowFileNameColumn = false;        % Display the file name in the file info browser by default? File browser scrolls slightly faster if this is false.
settings.FileSortCustomExpression = '';     % Custom file sorting expression

% FILE CACHING
settings.EnableFileCaching = true;      % Enable file caching - electrogui will load several files in the background around current file to improve loading time. Note that the first time MATLAB will need time to start parallel pool.
settings.BackwardFileCacheSize = 2;     % Number of files to load before the current file in case user goes backwards
settings.ForwardFileCacheSize = 4;      % Number of files to load after the current file in case user goes forwards
settings.ParallelPoolTimeout = 90;      % Number of minutes before parallel pool shuts itself off

% DBASE SETTINGS
settings.IncludeDocumentation = true;                 % Include documentation in saved dbase?
settings.DefaultDbaseFilename = 'analysis.mat';
settings.LegacyOptions.IncludeAnalysisState = false;  % Recent versions of 
    % electro_gui save settings in a separate 'settings' variable in the 
    % dbase mat file. Make this true to save them instead in the subfield
    % "AnalysisSettings".

% SONOGRAM SETTINGS
settings.Colormap = 'parula';               % Default coloramp
settings.SonogramAutoCalculate = 1;         % Automatically calculate and plot the sonogram when a file is loaded or axes changed?
settings.FreqLim = [500 7500];              % Frequency axis limits (Hz)
settings.AllowFrequencyZoom = 0;            % Allow user to zoom along the frequency axis by dragging a box over the sonogram?
settings.SonogramClim = [12.5 28];          % Minimum and maximum color saturation values for power spectra
settings.DerivativeSlope = 0;               % Brighness of spectral derivatives - values are divided by 10^slope
settings.DerivativeOffset = 13.5;           % Minimum saturation value for spectral derivatives
settings.BackgroundColors = [0 0 0; 0.5 0.5 0.5]; % Background colors for sonograms. 1st row - for power spectra; 2nd row - for spectral derivatives
settings.DefaultSonogramPlotter = 'AAquick_sonogram'; % Algorithm to use for plotting sonograms. Choose from egs_* files.
settings.OverlayTop = 0;                    % Overlay the top plot over the sonogram?
settings.OverlayBottom = 0;                 % Overlay the bottom plot over the sonogram?
settings.SoundChannel = 0;                  % Channel number to use as sound
settings.SoundExpression = '';              % An expression to use to create a derived sound channel

% AMPLITUDE SETTINGS
settings.DefaultFilter = 'BandPass860to8600'; % Filter to use for calculating sound amplitudes. Choose from egf_* files.
settings.AmplitudeLims = [0 50];            % Y-axis limits for the amplitude plot
settings.SmoothWindow = 0.0025;             % Smoothing window (sec) for calculating amplitude
settings.AmplitudeColor = [0 0 0];          % Color of the amplitude plot
settings.AmplitudeThresholdColor = [1 0 0]; % Color of the threshold line on the amplitude plot
settings.AmplitudeDontPlot = 0;             % Should the amplitude plot and segmentation be omitted?

% SEGMENTATION SETTINGS
settings.AmplitudeSource = 0;               % What should be used as the curve for segmentation? 0 - sound amplitude; 1 - top plot; 2 - bottom plot
settings.AmplitudeAutoThreshold = 1;        % Should the threshold for segmentation be chosen automatically, or carry over the current threshold?
settings.DefaultSegmenter = 'fast_DA_segmenter'; % Algorithm to use for segmentation. Choose from egg_* files.
settings.AutoSegment = 1;                   % Automatically segment when a new file is loaded or a different threshold is chosen?
settings.ValidSegmentCharacters = num2cell('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%&*(){}[]_');  % Allowed characters for segment titles
settings.SegmentSelectColor = 'r';
settings.SegmentUnSelectColor = [0.7, 0.5, 0.5];
settings.MarkerSelectColor = 'b';
settings.MarkerUnSelectColor = [0.5, 0.5, 0.7];
settings.SegmentActiveColor = 'y';
settings.MarkerActiveColor = 'g';
settings.SegmentInactiveColor = 'k';
settings.MarkerInactiveColor = 'k';
settings.CurrentThreshold = inf;
settings.ActiveSegmentNum = [];
settings.ActiveMarkerNum = [];

% CHANNEL PLOT SETTINGS
% Settings with two numbers or rows refer to the top and bottom plot respectively
settings.PeakDetect = [0 0]; % Use peak detection for plotting?
settings.AutoYZoom = [1 1]; % Allow user to zoom vertically by dragging a box over the plot?
settings.AutoYLimits = [1 1]; % Choose y-limits automatically for each file, or carry over the current limits?
settings.ChanLimits = [-1 1; -1 1]; % Initial y-limits for the channel plots, if AutoYLimits is off
settings.ChannelColor = [0 0 1; 0 0 1]; % Colors of the channel plots
settings.ChannelThresholdColor = [1 0 0; 1 0 0]; % Colors of the threshold lines on the channel plots
settings.ChannelLineWidth = [1 1]; % Line widths of the channel plots
settings.DefaultChannelFunction = 'FIRBandPass';

% EVENT SETTINGS
% Settings with two numbers or rows refer to the top and bottom plot respectively
settings.EventsAutoDetect = [1 1]; % Should events be detected automatically when a file is loaded?
settings.EventsDisplayMode = 1; % What should be displayed in the event browser? 1 - function values around each event; 2 - scatterplot of event features
settings.EventsAutoDisplay = 1; % Should events be updated automatically in the event browser each time they are changed?
settings.SearchBefore = [0.001 0.001]; % When selecting events by dragging a box over a channel plot, tolerance in the negative time direction (sec)
settings.SearchAfter = [0.001 0.001];% When selecting events by dragging a box over a channel plot, tolerance in the positive time direction (sec)
settings.DefaultEventXLims = [0.001 0.003]; % Time axes limits for the event browser
settings.DefaultEventFeatureX = 'AP_amplitude'; % Event feature to plot allong the x-axis of the event browser in the Features mode.
settings.DefaultEventFeatureY = 'AP_width'; % Event feature to plot allong the y-axis of the event browser in the Features mode.
settings.EventThresholdDefaults = [];  % Array of default thresholds for this event source
settings.EventXLims = [];        % Array of event source x limits
settings.ActiveEventNum = [];        % Index of the currently active event
settings.ActiveEventPartNum = [];    % Event part of the currently active event
settings.ActiveEventSourceIdx = [];  % Event source index of the currently active event

% SOUND SETTINGS
settings.SoundWeights = [2 1 1]; % Relative weights of the sound, the top plot, and the bottom plot, respectively
settings.SoundClippers = [.25 .25]; % The absolute level below which sounds are clipped (i.e., assigned zero value)
settings.SoundSpeed = 1; % Speed of sound playback (1 = normal speed)
settings.DefaultMix = [0 0 0]; % Include in the sound mix? Sound, top plot, and bottom plot, respectively
settings.FilterSound = 1; % Play filtered sound or raw sound?
settings.PlayReverse = 0; % Play sound in reverse?

% Plugin parameters
blankParams = struct('Names', {{}}, 'Values', {{}});
settings.ChannelAxesEventParams = {blankParams, blankParams};
settings.ChannelAxesFunctionParams = {blankParams, blankParams};
settings.ChannelAxesEventParams = {blankParams, blankParams};
settings.FilterParams = blankParams;
settings.SegmenterParams = blankParams;
settings.SonogramParams = blankParams;

% ANIMATION SETTINGS
settings.AnimationPlots = [0 0 0 0 0 0]; % Plot animation over sound wave, sonogram, segments, amplitude, top plot, and bottom plot, respectively
settings.ProgressBarColor = [0 1 0];
settings.SonogramFollowerPower = 10;

% EXPORT SETTINGS
settings.Export.TimeRangeMode = 'TimeRangeActiveAnnotation';
settings.Export.IncludeSpectrogram = 1;
settings.Export.IncludeAmplitude = 1;
settings.Export.IncludeSyllables = 1;
settings.Export.IncludeMarkers = 1;
settings.Export.IncludeTopChannelAxes = 1;
settings.Export.IncludeBotChannelAxes = 1;
settings.Export.IncludeEvents = 1;
settings.Export.IncludeTimestamp = 0;
settings.Export.IncludeFilenum = 1;
settings.Export.IncludeFilename = 0;
settings.Export.IncludeDirectory = 0;
settings.Export.IncludeNotes = 1;
settings.Export.LayoutTabMode = 'LayoutTabCurrent';
settings.Export.LayoutSortMode = 'LayoutSortChronological';
settings.Export.LayoutLineMode = 'LayoutLineFree';
settings.Export.LayoutScaleMode = 'LayoutScaleByTime';
settings.Export.LayoutScaleWidth = 6;
settings.Export.LayoutScaleHeight = 0.7500;
settings.Export.LayoutXSpacing = 0.1000;
settings.Export.LayoutYSpacing = 0.1000;
settings.Export.DefaultTabName = 'Export_1';