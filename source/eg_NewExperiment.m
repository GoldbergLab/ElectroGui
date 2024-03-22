function [handles ischanged] = eg_NewExperiment(handles)

if handles.IsUpdating == 0
    if isfield(handles,'DefaultRootPath')
        root_path = handles.DefaultRootPath;
    else
        root_path = pwd();
    end
    path_name = uigetdir(root_path, 'Experiment Directory');
    if ~isstr(path_name)
        ischanged = 0;
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
    fig = figure();
    set(fig,'visible','on');
    set(fig,'Name',titleString,'NumberTitle','off','MenuBar','none','doublebuffer','on','units','pixels','resize','off');
    set(fig,'position',[(screen_size(3)-figure_width)/2 (screen_size(4)-figure_height)/2 figure_width figure_height]);
    set(fig,'closerequestfcn',@CloseFig);
    set(fig, 'KeyPressFcn', @DialogKeyPress);

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

    % Put objects into figure
    for c = 1:num_chan+1
        if iscell(handles.FileString)
            % Defaults file has a different file string for each channel
            file_string_pattern = handles.FileString{c};
        else
            % Defaults file has only one file string for all channels
            file_string_pattern = handles.FileString;
        end
        file_string = sprintf(file_string_pattern, c-1);

        if strcmp(file_string, file_string_pattern) && ~isempty(strfind(file_string_pattern, '#'))
            % fstr is the same as handles.FileString, so it must not contain a
            % formatting pattern, and it does contain ##, which indicates this
            % is the legacy format.
            msgbox('Legacy FileString specification detected. Please edit your defaults_*.m file to update the ''handles.FileString'' to the new format. handles.FileString should be a string containing a standard string formatting pattern such as %02d or %d', 'Legacy FileString detected!');
            file_string_pattern = regexprep(file_string_pattern, '\#\#', '%02d');
            file_string = sprintf(file_string_pattern, c-1);
        end

        textlabel(c) = uicontrol('Style','text','units','normalized','string','',...
            'position',[0.05 (num_chan-c+2+0.5)/(num_chan+2) 0.5 0.3/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[.8 .8 .8]);
        textbox(c) = uicontrol('Style','edit','units','normalized','string',file_string,...
            'position',[0.05 (num_chan-c+2)/(num_chan+2) 0.5 0.4/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[1 1 1],'callback',@ChangeText);
        popup(c) = uicontrol('Style','popupmenu','units','normalized','string',loader_names,...
            'position',[0.6 (num_chan-c+2)/(num_chan+2) 0.35 0.4/(num_chan+2)],'FontSize',10,...
            'backgroundcolor',[1 1 1],'value',default_loader_indices(c));
    end

    uicontrol('Style','pushbutton','units','normalized','string','OK',...
        'position',[.25 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@PushOK);
    uicontrol('Style','pushbutton','units','normalized','string','Cancel',...
        'position',[.55 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@CloseFig);

    ChangeText([], []);

    ischanged = -1;
    drawnow;
    uiwait(fig);

    curr = pwd;
    cd(handles.DefaultRootPath);
    handles.sound_files = dir(get(textbox(1),'string'));
    handles.sound_loader = loader_names{get(popup(1),'value')};
    handles.chan_files = {};
    handles.chan_loader = {};
    for c = 2:num_chan+1
        handles.chan_files{c-1} = dir(get(textbox(c),'string'));
        handles.chan_loader{c-1} = loader_names{get(popup(c),'value')};
    end
    cd(curr);
    delete(fig)
catch ME
    getReport(ME)
    delete(fig)
end

    function PushOK(hObject, eventdata)
        ischanged = 1;
        uiresume()
    end

    function DialogKeyPress(src, event)
        if strcmp(event.Key, 'return') && any(strcmp('shift', event.Modifier))
            PushOK();
        end
    end

    function CloseFig(hObject, eventdata)
        ischanged = 0;
        set(fig,'closerequestfcn','%');
        uiresume()
    end

    function ChangeText(hObject, eventdata)
        curr = pwd;
        cd(handles.DefaultRootPath);
        for c = 1:num_chan+1
            if c == 1
                titleString = 'Sound - ';
            else
                titleString = ['Channel ' num2str(c-1) ' - '];
            end
            mt = dir(get(textbox(c),'string'));
            set(textlabel(c),'string',[titleString num2str(length(mt)) ' files']);
        end
        cd(curr);
    end

end