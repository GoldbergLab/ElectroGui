function [dbase, cancel] = eg_GatherFiles(pathName, fileString, fileLoader, numChannels, options)
    arguments
        pathName char
        fileString
        fileLoader
        numChannels double = []
        options.TitleString char = 'Locate data files'
        options.GUI (1, 1) logical = true
        options.Loaders = []  % Loader plugin struct array (from gatherPlugins). If empty, loaders are discovered from the plugins directory.
    end

    % Initialize the dbase
    dbase = struct();

    if options.GUI
        pathName = uigetdir(pathName, 'Experiment Directory');
        if ~ischar(pathName)
            cancel = true;
            return
        end
    end

    dbase.PathName = pathName;

    % If user did not provide number of channels, attempt to deduce it from
    % the file string or file loader
    if iscell(fileString) && isempty(numChannels)
        % User provided one file string per channel, so we can use this to
        % determine # of channels
        numChannels = length(fileString) - 1;
    elseif iscell(fileLoader) && isempty(numChannels)
        % User provided one file loader per channel, so we can use this to
        % determine # of channels
        numChannels = length(fileLoader) - 1;
    end
    
    % Determine the sound and channel file patterns and loaders
    ChannelPatterns = cell(1, numChannels);
    ChannelLoaders = cell(1, numChannels);
    for chanIdx = 1:numChannels+1
        if iscell(fileString)
            % Defaults file has a different file string for each channel
            file_string_pattern = fileString{chanIdx};
        else
            % Defaults file has only one file string for all channels
            file_string_pattern = fileString;
        end
        file_string = sprintf(file_string_pattern, chanIdx-1);

        if iscell(fileLoader)
            % User provided a different default file loader for each channel
            file_loader = fileLoader{chanIdx-1};
        else
            % User provided a single default file loader for all channels
            file_loader = fileLoader;
        end

        if strcmp(file_string, file_string_pattern) && contains(file_string_pattern, '#')
            % fstr is the same as FileString, so it must not contain a
            % formatting pattern, and it does contain ##, which indicates this
            % is the legacy format.
            if ~legacyWarningGiven
                if options.GUI
                    w = @msgbox;
                else
                    w = @warning;
                end
                w('Legacy FileString specification detected. Please edit your defaults_*.m file to update the ''FileString'' to the new format. FileString should be a string containing a standard string formatting pattern such as %02d or %d', 'Legacy FileString detected!');
                % Only warn once
                legacyWarningGiven = true;
            end
            file_string_pattern = regexprep(file_string_pattern, '\#\#', '%02d');
            file_string = sprintf(file_string_pattern, chanIdx-1);
        end

        if chanIdx == 1
            SoundPattern = file_string;
            SoundLoader = file_loader;
        else
            ChannelPatterns{chanIdx-1} = file_string;
            ChannelLoaders{chanIdx-1} = file_loader;
        end
    end

    cancel = false;

    if options.GUI
        [SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, cancel] = SpecifyFilesGUI(pathName, SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, numChannels, options.TitleString, options.Loaders);
    end

    % Assign fields to dbase
    dbase.SoundFiles = dir(fullfile(dbase.PathName, SoundPattern));
    dbase.SoundLoader = SoundLoader;
    dbase.ChannelFiles = {};
    for chan = 1:numChannels
        dbase.ChannelFiles{chan} = dir(fullfile(dbase.PathName, ChannelPatterns{chan}));
    end
    dbase.ChannelLoader = ChannelLoaders;

function [SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, cancel] = SpecifyFilesGUI(PathName, SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, NumChannels, TitleString, loaders)
    % Create dialog figure
    figure_height = 0.9;
    figure_width = 0.4;

    fig = figure('Name',TitleString,'NumberTitle','off','MenuBar','none', 'Units','normalized');
    fig.Visible = 'on';
    fig.Position = [(figure_width/2), (1-figure_height)/2, figure_width, figure_height];
    fig.CloseRequestFcn = @CloseFig;
    fig.WindowKeyPressFcn = @DialogKeyPress;
    fig.UserData.textlabels = gobjects(1, NumChannels+1);
    fig.UserData.textboxes = gobjects(1, NumChannels+1);
    fig.UserData.popups = gobjects(1, NumChannels+1);
    fig.UserData.cancel = true;
    fig.UserData.PathName = PathName;
    fig.UserData.NumChannels = NumChannels;
    buttonHeight = 0.05;
    margin = 0.05;
    panel2 = uipanel( ...
        fig, ...
        "Parent", fig, ...
        "Units", "normalized", ...
        "BorderType", "none", ...
        "Position", [margin, 0, 1-2*margin, buttonHeight] ...
        );
    panel1 = uipanel( ...
        fig, ...
        "Parent", fig, ...
        "Units", "normalized", ...
        "BorderType", "none", ...
        "Position", [margin, buttonHeight, 1-2*margin, 1-buttonHeight]);

    % Get loader names from the provided loaders struct, or discover them
    if ~isempty(loaders)
        loader_names = {loaders.name};
    else
        sourcePath = fileparts(mfilename("fullpath"));
        loaders = electro_gui.findPlugins(fullfile(sourcePath, 'plugins'), 'egl');
        loader_names = {loaders.name};
    end
    default_loader_indices = ones(1, NumChannels + 1);

    loaders = [{SoundLoader}, ChannelLoaders];
    patterns = [{SoundPattern}, ChannelPatterns];

    % Put objects into figure
    channelSpacing = 1/(NumChannels+1);
    verticalMargin = 0.005;
    horizontalMargin = 0.01;
    for chanIdx = 1:NumChannels+1
        y0 = 1-(chanIdx)*channelSpacing;
        fig.UserData.textlabels(chanIdx) = uicontrol(...
            'Parent', panel1, ...
            'Style', 'edit', ...
            'Enable', 'inactive', ...
            'Units', 'normalized', ...
            'String','',...
            'Position', [0+horizontalMargin, y0+verticalMargin, 0.3-1.5*horizontalMargin, channelSpacing-2*verticalMargin], ...
            'FontSize',8, ...
            'HorizontalAlignment', 'right', ...
            'BackgroundColor',[.8 .8 .8]);
        fig.UserData.textboxes(chanIdx) = uicontrol(...
            'Parent', panel1, ...
            'Style', 'edit', ...
            'Units', 'normalized', ...
            'Position',[0.3+horizontalMargin/2, y0+verticalMargin, 0.3-horizontalMargin, channelSpacing-2*verticalMargin],...
            'String', patterns{chanIdx}, ...
            'FontSize', 8, ...
            'HorizontalAlignment', 'left', ...
            'BackgroundColor', [1 1 1], ...
            'Callback', @ChangeText);
        default_loader_indices(chanIdx) = find(strcmp(loader_names, loaders{chanIdx}));
        fig.UserData.popups(chanIdx) = uicontrol(...
            'Parent', panel1, ...
            'Style', 'popupmenu', ...
            'Units', 'normalized', ...
            'Position', [0.6+horizontalMargin/2, y0+verticalMargin, 0.4-1.5*horizontalMargin, channelSpacing-2*verticalMargin], ...
            'String', loader_names, ...
            'FontSize', 8,...
            'BackgroundColor', [1 1 1], ...
            'Value', default_loader_indices(chanIdx));
    end

    buttonMargin = 0.05;
    uicontrol('Parent', panel2, 'Style','pushbutton','Units','normalized','String','OK',...
        'Position',[0+buttonMargin, 0+buttonMargin, 0.5-2*buttonMargin, 1-2*buttonMargin],'Callback',@PushOK);
    uicontrol('Parent', panel2, 'Style','pushbutton','Units','normalized','String','Cancel',...
        'Position',[0.5+buttonMargin, 0+buttonMargin, 0.5-2*buttonMargin, 1-2*buttonMargin],'Callback',@CloseFig);

    ChangeText(fig, []);

    drawnow();
    uiwait(fig);

    cancel = fig.UserData.cancel;

    % Collect selections from GUI
    SoundPattern = fig.UserData.textboxes(1).String;
    SoundLoader = loader_names{fig.UserData.popups(1).Value};
    ChannelPatterns = {fig.UserData.textboxes(2:end).String};
    ChannelLoaders = loader_names([fig.UserData.popups(2:end).Value]);
    
    delete(fig);

function PushOK(src, ~)
    src = ancestor(src, 'figure');
    src.UserData.cancel = false;
    uiresume(src);

function DialogKeyPress(src, event)
    src = ancestor(src, 'figure');
    if strcmp(event.Key, 'return') % && any(strcmp('shift', event.Modifier))
        PushOK(src);
    elseif strcmp(event.Key, 'escape')
        CloseFig(src);
    end

function CloseFig(src, ~)
    src = ancestor(src, 'figure');
    src.UserData.cancel = true;
    src.CloseRequestFcn = '%';
    uiresume()

function ChangeText(src, ~)
    src = ancestor(src, 'figure');
    root = src.UserData.PathName;
    for chanNum = 1:src.UserData.NumChannels+1
        if chanNum == 1
            titleString = 'Sound - ';
        else
            titleString = sprintf('Channel %d - ', chanNum-1);
        end
        mt = dir(fullfile(root, src.UserData.textboxes(chanNum).String));
        src.UserData.textlabels(chanNum).String = [titleString, num2str(length(mt)), ' files'];
    end
