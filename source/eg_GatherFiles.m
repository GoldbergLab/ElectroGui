function [dbase, cancel] = eg_GatherFiles(PathName, FileString, FileLoader, NumChannels, options)
    arguments
        PathName char
        FileString
        FileLoader
        NumChannels double = []
        options.TitleString char = 'Locate data files'
        options.DefaultPathName char = '.'
        options.GUI (1, 1) logical = true
    end

    % Initialize the dbase
    dbase = struct();

    if options.GUI && isempty(PathName)
        PathName = uigetdir(options.DefaultPathName, 'Experiment Directory');
        if ~ischar(PathName)
            cancel = true;
            return
        end
    end

    dbase.PathName = PathName;

    % If user did not provide number of channels, attempt to deduce it from
    % the file string or file loader
    if iscell(FileString) && isempty(NumChannels)
        % User provided one file string per channel, so we can use this to
        % determine # of channels
        NumChannels = length(FileString) - 1;
    elseif iscell(FileLoader) && isempty(NumChannels)
        % User provided one file loader per channel, so we can use this to
        % determine # of channels
        NumChannels = length(FileLoader) - 1;
    end

    cancel = false;

    if options.GUI
        [SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, cancel] = SpecifyFilesGUI(PathName, FileString, FileLoader, NumChannels, options.TitleString);
    end

    % Assign fields to dbase
    dbase.SoundFiles = dir(fullfile(dbase.PathName, SoundPattern));
    dbase.SoundLoader = SoundLoader;
    dbase.ChannelFiles = {};
    for chan = 1:NumChannels
        dbase.ChannelFiles{chan} = dir(fullfile(dbase.PathName, ChannelPatterns{chan}));
    end
    dbase.ChannelLoader{chan} = ChannelLoaders;

function [SoundPattern, SoundLoader, ChannelPatterns, ChannelLoaders, cancel] = SpecifyFilesGUI(PathName, FileString, FileLoader, NumChannels, TitleString)
    % Create dialog figure
    screen_size = get(0,'screensize');
    figure_height = screen_size(4)*(0.035*(NumChannels+2));
    figure_width = screen_size(3)*.3;

    fig = figure('Name',TitleString,'NumberTitle','off','MenuBar','none','doublebuffer','on','units','pixels','resize','off');
    fig.Visible = 'on';
    fig.Position = [(screen_size(3)-figure_width)/2 (screen_size(4)-figure_height)/2 figure_width figure_height];
    fig.CloseRequestFcn = @CloseFig;
    fig.KeyPressFcn = @DialogKeyPress;
    fig.UserData.textlabels = gobjects(1, NumChannels+1);
    fig.UserData.textboxes = gobjects(1, NumChannels+1);
    fig.UserData.popups = gobjects(1, NumChannels+1);
    fig.UserData.cancel = true;
    fig.UserData.PathName = PathName;
    fig.UserData.NumChannels = NumChannels;

    sourcePath = fileparts(mfilename("fullpath"));

    % Find all loader plugins
    loader_files = dir(fullfile(sourcePath, 'egl_*.m'));
    loader_names = cell(1, length(loader_files));
    default_loader_indices = ones(NumChannels + 1);
    for loader_idx = 1:length(loader_files)
        [~, loader_full_name, ~] = fileparts(loader_files(loader_idx).name);
        loader_names{loader_idx} = regexprep(loader_full_name, '^egl_', '');
    end

    if iscell(FileLoader)
        % User provided a different default file loader for each channel
        for chan = 1:NumChannels+1
            default_loader_indices(chan) = find(strcmp(loader_names, FileLoader{chan}));
        end
    else
        % User provided a single default file loader for all channels
        default_loader_indices(1:NumChannels+1) = find(strcmp(loader_names, FileLoader));
    end

    legacyWarningGiven = false;

    % Put objects into figure
    for chanIdx = 1:NumChannels+1
        if iscell(FileString)
            % Defaults file has a different file string for each channel
            file_string_pattern = FileString{chanIdx};
        else
            % Defaults file has only one file string for all channels
            file_string_pattern = FileString;
        end
        file_string = sprintf(file_string_pattern, chanIdx-1);

        if strcmp(file_string, file_string_pattern) && contains(file_string_pattern, '#')
            % fstr is the same as FileString, so it must not contain a
            % formatting pattern, and it does contain ##, which indicates this
            % is the legacy format.
            if ~legacyWarningGiven
                msgbox('Legacy FileString specification detected. Please edit your defaults_*.m file to update the ''FileString'' to the new format. FileString should be a string containing a standard string formatting pattern such as %02d or %d', 'Legacy FileString detected!');
                % Only warn once
                legacyWarningGiven = true;
            end
            file_string_pattern = regexprep(file_string_pattern, '\#\#', '%02d');
            file_string = sprintf(file_string_pattern, chanIdx-1);
        end

        fig.UserData.textlabels(chanIdx) = uicontrol('Style','text','Units','normalized','String','',...
            'position',[0.05 (NumChannels-chanIdx+2+0.5)/(NumChannels+2) 0.5 0.3/(NumChannels+2)],'FontSize',10,...
            'HorizontalAlignment','left','BackgroundColor',[.8 .8 .8]);
        fig.UserData.textboxes(chanIdx) = uicontrol('Style','edit','Units','normalized','String',file_string,...
            'Position',[0.05 (NumChannels-chanIdx+2)/(NumChannels+2) 0.5 0.4/(NumChannels+2)],'FontSize',10,...
            'HorizontalAlignment','left','BackgroundColor',[1 1 1],'callback',@ChangeText);
        fig.UserData.popups(chanIdx) = uicontrol('Style','popupmenu','Units','normalized','String',loader_names,...
            'Position',[0.6 (NumChannels-chanIdx+2)/(NumChannels+2) 0.35 0.4/(NumChannels+2)],'FontSize',10,...
            'BackgroundColor',[1 1 1],'Value',default_loader_indices(chanIdx));
    end

    uicontrol('Style','pushbutton','Units','normalized','String','OK',...
        'Position',[.25 .13/(NumChannels+3) 0.2 0.7/(NumChannels+3)],'Callback',@PushOK);
    uicontrol('Style','pushbutton','Units','normalized','String','Cancel',...
        'Position',[.55 .13/(NumChannels+3) 0.2 0.7/(NumChannels+3)],'Callback',@CloseFig);

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
    if strcmp(event.Key, 'return') && any(strcmp('shift', event.Modifier))
        PushOK(src);
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
