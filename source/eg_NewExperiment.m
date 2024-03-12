function [handles, ischanged] = eg_NewExperiment(handles)

if handles.IsUpdating == 0
    if isfield(handles,'DefaultRootPath')
        root_path = handles.DefaultRootPath;
    else
        root_path = pwd();
    end
    path_name = uigetdir(root_path, 'Experiment Directory');
    if ~ischar(path_name)
        ischanged = false;
        return
    end

    handles.DefaultRootPath = path_name;

    if iscell(handles.FileString)
        num_chan = length(handles.FileString) - 1;
    else
        num_chan = handles.DefaultChannelNumber;
    end
    
    titleString = 'New experiment';
else
    num_chan = length(handles.chan_files);
    titleString = 'Update file list';
end

% Create dialog figure
screen_size = get(0,'screensize');
figure_height = screen_size(4)*(0.035*(num_chan+2));
figure_width = screen_size(3)*.3;

try
    fig = figure('Name',titleString,'NumberTitle','off','MenuBar','none','doublebuffer','on','units','pixels','resize','off');
    fig.Visible = 'on';
    fig.Position = [(screen_size(3)-figure_width)/2 (screen_size(4)-figure_height)/2 figure_width figure_height];
    fig.CloseRequestFcn = @CloseFig;
    fig.KeyPressFcn = @DialogKeyPress;
    fig.UserData.textlabels = gobjects(1, num_chan+1);
    fig.UserData.textboxes = gobjects(1, num_chan+1);
    fig.UserData.popups = gobjects(1, num_chan+1);
    fig.UserData.ischanged = false;
    fig.UserData.DefaultRootPath = handles.DefaultRootPath;
    fig.UserData.NumChannels = num_chan;

    % Find all loader files
    loader_files = dir('egl_*.m');
    loader_names = cell(1, length(loader_files));
    default_loader_indices = ones(num_chan + 1);
    for loader_idx = 1:length(loader_files)
        [~, loader_full_name, ~] = fileparts(loader_files(loader_idx).name);
        loader_names{loader_idx} = regexprep(loader_full_name, '^egl_', '');
    end

    if iscell(handles.DefaultFileLoader)
        % User provided a different default file loader for each channel
        for chan = 1:num_chan+1
            default_loader_indices(chan) = find(strcmp(loader_names, handles.DefaultFileLoader{chan}));
        end
    else
        % User provided a single default file loader for all channels
        default_loader_indices(1:num_chan+1) = find(strcmp(loader_names, handles.DefaultFileLoader));
    end

    legacyWarningGiven = false;

    % Put objects into figure
    for chanNum = 1:num_chan+1
        if iscell(handles.FileString)
            % Defaults file has a different file string for each channel
            file_string_pattern = handles.FileString{chanNum};
        else
            % Defaults file has only one file string for all channels
            file_string_pattern = handles.FileString;
        end
        file_string = sprintf(file_string_pattern, chanNum-1);

        if strcmp(file_string, file_string_pattern) && contains(file_string_pattern, '#')
            % fstr is the same as handles.FileString, so it must not contain a
            % formatting pattern, and it does contain ##, which indicates this
            % is the legacy format.
            if ~legacyWarningGiven
                msgbox('Legacy FileString specification detected. Please edit your defaults_*.m file to update the ''handles.FileString'' to the new format. handles.FileString should be a string containing a standard string formatting pattern such as %02d or %d', 'Legacy FileString detected!');
                % Only warn once
                legacyWarningGiven = true;
            end
            file_string_pattern = regexprep(file_string_pattern, '\#\#', '%02d');
            file_string = sprintf(file_string_pattern, chanNum-1);
        end

        fig.UserData.textlabels(chanNum) = uicontrol('Style','text','units','normalized','string','',...
            'position',[0.05 (num_chan-chanNum+2+0.5)/(num_chan+2) 0.5 0.3/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[.8 .8 .8]);
        fig.UserData.textboxes(chanNum) = uicontrol('Style','edit','units','normalized','string',file_string,...
            'position',[0.05 (num_chan-chanNum+2)/(num_chan+2) 0.5 0.4/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[1 1 1],'callback',@ChangeText);
        fig.UserData.popups(chanNum) = uicontrol('Style','popupmenu','units','normalized','string',loader_names,...
            'position',[0.6 (num_chan-chanNum+2)/(num_chan+2) 0.35 0.4/(num_chan+2)],'FontSize',10,...
            'backgroundcolor',[1 1 1],'value',default_loader_indices(chanNum));
    end

    uicontrol('Style','pushbutton','units','normalized','string','OK',...
        'position',[.25 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@PushOK);
    uicontrol('Style','pushbutton','units','normalized','string','Cancel',...
        'position',[.55 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@CloseFig);

    ChangeText(fig, []);

    drawnow();
    uiwait(fig);

    ischanged = fig.UserData.ischanged;

    handles.sound_files = dir(fullfile(handles.DefaultRootPath, fig.UserData.textboxes(1).String));
    handles.sound_loader = loader_names{fig.UserData.popups(1).Value};
    handles.chan_files = {};
    handles.chan_loader = {};
    for chanNum = 2:num_chan+1
        handles.chan_files{chanNum-1} = dir(fullfile(handles.DefaultRootPath, fig.UserData.textboxes(chanNum).String));
        handles.chan_loader{chanNum-1} = loader_names{fig.UserData.popups(chanNum).Value'};
    end
    delete(fig)
catch ME
    getReport(ME)
    delete(fig)
end

function PushOK(src, ~)
    src = ancestor(src, 'figure');
    src.UserData.ischanged = true;
    uiresume()

function DialogKeyPress(src, event)
    src = ancestor(src, 'figure');
    if strcmp(event.Key, 'return') && any(strcmp('shift', event.Modifier))
        PushOK(src);
    end

function CloseFig(src, ~)
    src = ancestor(src, 'figure');
    src.UserData.ischanged = false;
    src.CloseRequestFcn = '%';
    uiresume()

function ChangeText(src, ~)
    src = ancestor(src, 'figure');
    root = src.UserData.DefaultRootPath;
    for chanNum = 1:src.UserData.NumChannels+1
        if chanNum == 1
            titleString = 'Sound - ';
        else
            titleString = sprintf('Channel %d - ', chanNum-1);
        end
        mt = dir(fullfile(root, src.UserData.textboxes(chanNum).String));
        src.UserData.textlabels(chanNum).String = [titleString, num2str(length(mt)), ' files'];
    end
