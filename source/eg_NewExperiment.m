function [handles ischanged] = eg_NewExperiment(handles)

if handles.IsUpdating == 0
    if isfield(handles,'DefaultRootPath')
        dataDir = handles.DefaultRootPath;
    else
        dataDir = pwd();
    end
    path_name = uigetdir(dataDir,'Experiment Directory');
    if ~ischar(path_name)
        ischanged = 0;
        return
    end


    handles.DefaultRootPath = path_name;

    num_chan = handles.DefaultChannelNumber;
    title = 'New experiment';
else
    num_chan = length(handles.chan_files);
    title = 'Update file list';
end

% Create dialog figure
screen_size = get(0,'screensize');
fig_h = screen_size(4)*(0.035*(num_chan+2));
fig_w = screen_size(3)*.3;

try
    fig = figure();
    set(fig,'visible','on');
    set(fig,'Name',title,'NumberTitle','off','MenuBar','none','doublebuffer','on','units','pixels','resize','off');
    set(fig,'position',[(screen_size(3)-fig_w)/2 (screen_size(4)-fig_h)/2 fig_w fig_h]);
    set(fig,'closerequestfcn',@CloseFig);
    set(fig, 'KeyPressFcn', @DialogKeyPress);

    % Find all loader files
    loaderIndex = 1;
    for loaderNum = 1:length(handles.plugins.loaders)
        if strcmp(handles.plugins.loaders(loaderNum).name, handles.DefaultFileLoader)
            loaderIndex = loaderNum;
        end
    end

    % Put objects into figure

    alreadyWarned = false;
    
    for c = 1:num_chan+1
        fstr = sprintf(handles.FileString, c-1);
        if ~alreadyWarned && strcmp(fstr, handles.FileString) && ~isempty(strfind(handles.FileString, '#'))
            % fstr is the same as handles.FileString, so it must not contain a
            % formatting pattern, and it does contain ##, which indicates this
            % is the legacy format.
            msgbox('Legacy FileString specification detected. Please edit your defaults_*.m file to update the ''handles.FileString'' to the new format. handles.FileString should be a string containing a standard string formatting pattern such as %02d or %d', 'Legacy FileString detected!');
            fstr = regexprep(handles.FileString, '\#\#', '%02d');
            fstr = sprintf(fstr, c-1);
            alreadyWarned = true;
        end

    %     f = findstr(fstr,'##');
    %     fstr(f:f+1) = num2str(c-1,'%02u');     %makes it a double digit number when more than 10 channels are being called (RC/AD)
    %     fstr = handles.FileString;
    %     f = findstr(fstr,'##');
    %     fstr(f:f+1) = num2str(c-1,'%02u');     %makes it a double digit number when more than 10 channels are being called (RC/AD)

        % 
        textlabel(c) = uicontrol(fig, 'Style','text','units','normalized','string','',...
            'position',[0.05 (num_chan-c+2+0.5)/(num_chan+2) 0.5 0.3/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[.8 .8 .8]);
        textbox(c) = uicontrol(fig, 'Style','edit','units','normalized','string',fstr,...
            'position',[0.05 (num_chan-c+2)/(num_chan+2) 0.5 0.4/(num_chan+2)],'FontSize',10,...
            'horizontalalignment','left','backgroundcolor',[1 1 1],'callback',@ChangeText);
        loader_popup(c) = uicontrol(fig, 'Style','popupmenu','units','normalized','string',{handles.plugins.loaders.name},...
            'position',[0.6 (num_chan-c+2)/(num_chan+2) 0.35 0.4/(num_chan+2)],'FontSize',10,...
            'backgroundcolor',[1 1 1],'value',loaderIndex);
    end

    uicontrol(fig, 'Style','pushbutton','units','normalized','string','OK',...
        'position',[.25 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@PushOK);
    uicontrol(fig, 'Style','pushbutton','units','normalized','string','Cancel',...
        'position',[.55 .13/(num_chan+3) 0.2 0.7/(num_chan+3)],'callback',@CloseFig);

    ChangeText([], []);

    ischanged = -1;
    drawnow;
    uiwait(fig);

    curr = pwd();
    cd(handles.DefaultRootPath);
    handles.sound_files = dir(get(textbox(1),'string'));
    handles.sound_loader = handles.plugins.loaders(get(loader_popup(1),'value')).name;
    handles.chan_files = {};
    handles.chan_loader = {};
    for c = 2:num_chan+1
        handles.chan_files{c-1} = dir(get(textbox(c),'string'));
        handles.chan_loader{c-1} = handles.plugins.loaders(get(loader_popup(c),'value')).name;
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
        curr = pwd();
        cd(handles.DefaultRootPath);
        for c = 1:num_chan+1
            if c == 1
                str = 'Sound - ';
            else
                str = ['Channel ' num2str(c-1) ' - '];
            end
            mt = dir(get(textbox(c),'string'));
            set(textlabel(c),'string',[str num2str(length(mt)) ' files']);
        end
        cd(curr);
    end

end