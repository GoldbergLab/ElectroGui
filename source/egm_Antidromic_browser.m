function varargout = egm_Antidromic_browser(varargin)
% EGM_ANTIDROMIC_BROWSER M-file for egm_Antidromic_browser.fig
%      EGM_ANTIDROMIC_BROWSER, by itself, creates a new EGM_ANTIDROMIC_BROWSER or raises the existing
%      singleton*.
%
%      H = EGM_ANTIDROMIC_BROWSER returns the handle to a new EGM_ANTIDROMIC_BROWSER or the handle to
%      the existing singleton*.
%
%      EGM_ANTIDROMIC_BROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EGM_ANTIDROMIC_BROWSER.M with the given input arguments.
%
%      EGM_ANTIDROMIC_BROWSER('Property','Value',...) creates a new EGM_ANTIDROMIC_BROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before egm_Antidromic_browser_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to egm_Antidromic_browser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help egm_Antidromic_browser

% Last Modified by GUIDE v2.5 10-Mar-2008 16:31:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @egm_Antidromic_browser_OpeningFcn, ...
                   'gui_OutputFcn',  @egm_Antidromic_browser_OutputFcn, ...
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


% --- Executes just before egm_Antidromic_browser is made visible.
function egm_Antidromic_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to egm_Antidromic_browser (see VARARGIN)

handles.egh = varargin{1};

handles.fs = handles.egh.fs;

% Set defaults
handles.ylim = [-1 1];

% Get events list
str = get(handles.egh.popup_EventList,'string');
if ~iscell(str) | length(str)<2
    errordlg('Must have at least 1 event type!','Error');
else
    % Ask user for indices of events
    str = str(2:end);
    mn = [];
    for c = 1:length(str)
        mn = [mn ',''' str{c} ''''];
    end
    indx_stim = eval(['menu(''Choose STIM events''' mn ')']);
    
    lst = [1:indx_stim-1 indx_stim+1:length(str)];
    mn = [];
    for c = 1:length(lst)
        mn = [mn ',''' str{lst(c)} ''''];
    end
    mn = [mn ',''None'''];
    indx_spk = eval(['menu(''Choose SPIKE events''' mn ')']);
    if indx_spk > length(lst)
        indx_spk = 0;
    else
        indx_spk = lst(indx_spk);
    end
    
    % Load events
    nums = [];
    for c = 1:length(handles.egh.EventTimes);
        nums(c) = size(handles.egh.EventTimes{c},1);
    end
    cs = cumsum(nums);
    
    f = length(find(cs<indx_stim))+1;
    if f>1
        g = indx_stim-cs(f-1);
    else
        g = indx_stim;
    end
    
    evtimes = {};
    for c = 1:handles.egh.TotalFileNumber
        ev = handles.egh.EventTimes{f}{g,c};
        isin = handles.egh.EventSelected{f}{g,c};
        evtimes{c} = ev(find(isin==1));
    end

    if indx_spk > 0
        f = length(find(cs<indx_spk))+1;
        if f>1
            g = indx_spk-cs(f-1);
        else
            g = indx_spk;
        end

        spks = {};
        for c = 1:handles.egh.TotalFileNumber
            ev = handles.egh.EventTimes{f}{g,c};
            isin = handles.egh.EventSelected{f}{g,c};
            spks{c} = ev(find(isin==1));
        end
        str = str{indx_spk};
    else
        spks = cell(1,handles.egh.TotalFileNumber);
        str = str{indx_stim};
    end

    
    if strcmp(str(1:5),'Sound')
        filelist = handles.egh.sound_files;
        loader = handles.egh.sound_loader;
    else
        f = findstr(str,'-');
        f = f(1);
        num = str2num(str(9:f-2));
        filelist = handles.egh.chan_files{num};
        loader = handles.egh.chan_loader{num};
    end

    handles.trials = [];
    handles.PrevSpike = [];
    handles.Filenum = [];
    handles.InFile = [];
    answer = inputdlg({'Min (ms)','Max (ms)'},'Time limits',1,{'-10','10'});
    handles.EventLims = [-str2num(answer{1}) str2num(answer{2})]/1000;
    handles.xlim = handles.EventLims;
    lms = round(handles.EventLims*handles.fs);
    for c = 1:handles.egh.TotalFileNumber
        if ~isempty(evtimes{c})
            [data, fs, dt, label, props] = eg_runPlugin(handles.egh.plugins.loaders, loader, fullfile(handles.egh.DefaultRootPath, filelist(c).name), true);
            if size(data,1) > size(data,2)
                data = data';
            end
            for d = 1:length(evtimes{c})
                if evtimes{c}(d)-lms(1)>0 & evtimes{c}(d)+lms(2)<=length(data)
                    handles.trials(end+1,:) = data(evtimes{c}(d)-lms(1):evtimes{c}(d)+lms(2));
                    f = find(spks{c}<evtimes{c}(d));
                    if isempty(f)
                        handles.PrevSpike(end+1) = inf;
                    else
                        handles.PrevSpike(end+1) = evtimes{c}(d)-spks{c}(f(end));
                    end
                    handles.Filenum(end+1) = c;
                    handles.InFile(end+1) = d;
                end
            end
            handles.Label = label;
        end
    end

    figure(handles.MainFigure)
       
    set(handles.text_TotalNumber,'string',['of ' num2str(size(handles.trials,1))]);
    set(handles.edit_TrialNumber,'string','1');
    
    handles.Selected = zeros(1,size(handles.trials,1));
    handles.Deleted = zeros(1,size(handles.trials,1));
    handles.Order = 1:size(handles.trials,1);
    handles.Response = inf*ones(1,size(handles.trials,1));
    handles.Group = ones(1,size(handles.trials,1));
    
    handles.TrialsPerWindow = size(handles.trials,1);
    handles.CurrentTopTrial = 1;

    handles = PlotTrial(handles);
    
end

% Choose default command line output for egm_Antidromic_browser
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes egm_Antidromic_browser wait for user response (see UIRESUME)
% uiwait(handles.MainFigure);


function handles = PlotTrial(handles)

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
if trialnum < 1
    trialnum = size(handles.trials,1);
end
if trialnum > size(handles.trials,1)
    trialnum = 1;
end
set(handles.edit_TrialNumber,'string',num2str(trialnum))

set(handles.popup_CurrentColor,'value',handles.Group(trialnum));

subplot(handles.axes_Trial);
hold off
xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
plot(xs,handles.trials(trialnum,:));
ylabel(handles.Label);
xlabel('Time from stim (ms)');
title(['File ' num2str(handles.Filenum(trialnum)) '. Stim ' num2str(handles.InFile(trialnum)) '.']);
ylim(handles.ylim);
hold on
plot([-handles.PrevSpike(trialnum) -handles.PrevSpike(trialnum)]/handles.fs*1000,ylim,':r');

if handles.Response(trialnum) < inf
    plot(xs(handles.Response(trialnum)),handles.trials(trialnum,handles.Response(trialnum)),'ro','markersize',4,'markerfacecolor','r')
end

xlim([-handles.xlim(1),handles.xlim(2)]*1000);

set(gca,'buttondownfcn','egm_Antidromic_browser(''click_Trial'',gcbo,[],guidata(gcbo))');
ch = get(gca,'children');
for c = 1:length(ch)
    set(ch(c),'buttondownfcn',get(gca,'buttondownfcn'));
end

set(handles.check_Deleted,'value',handles.Deleted(trialnum));
handles.Selected(find(handles.Deleted==1)) = 0;
set(handles.check_Selected,'value',handles.Selected(trialnum));
if handles.Deleted(trialnum) == 1
    set(handles.check_Selected,'enable','off');
else
    set(handles.check_Selected,'enable','on');
end

subplot(handles.axes_ColorPlot)
cla
imagesc(xs,1:size(handles.trials,1),handles.trials)
hold on
if get(handles.check_ShowSpikes,'value')==1
    plot(-handles.PrevSpike/handles.fs*1000,1:size(handles.trials,1),'ko','markersize',4,'markerfacecolor','w');
end
if get(handles.check_ShowResponses,'value')==1
    f = find(handles.Response<inf);
    plot(xs(handles.Response(f)),f,'ko','markersize',4,'markerfacecolor','w');
end
for c = find(handles.Deleted==1)
    xl = xlim;
    h = patch([xl(1) xl(2) xl(2) xl(1) xl(1)],[c-.5 c-.5 c+.5 c+.5 c-.5],'w');
    set(h,'edgecolor','none');
end
for c = find(handles.Selected==1)
    xl = xlim;
    h = patch([xl(1) xl(2) xl(2) xl(1) xl(1)],[c-.5 c-.5 c+.5 c+.5 c-.5],'w');
    set(h,'edgecolor','none');
    set(h,'facealpha',.6);
end

xlim([-handles.xlim(1),handles.xlim(2)]*1000);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
box on

plot(xlim,[trialnum trialnum],'-m','linewidth',2);

set(gca,'ytick',[]);
xlabel('Time from stim (ms)');
set(gca,'clim',handles.ylim);

set(gca,'buttondownfcn','egm_Antidromic_browser(''click_ColorPlot'',gcbo,[],guidata(gcbo))');
ch = get(gca,'children');
for c = 1:length(ch)
    set(ch(c),'buttondownfcn',get(gca,'buttondownfcn'));
end

subplot(handles.axes_Colors)
cla
cols = 'krygcbm';
for c = 1:length(handles.Group)
    plot(0,c,'o','color',cols(handles.Group(c)),'markerfacecolor',cols(handles.Group(c)));
    hold on
end
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
set(gca,'ydir','reverse');
axis off

% Statistics
if get(handles.check_StatisticsSelection,'value')==1
    f = find(handles.Selected==1);
else
    f = find(handles.Deleted==0);
end
set(handles.text_N,'string',num2str(length(f)));
if ~isempty(f)
    g = find(handles.Response(f) < inf);
    
    reliability = length(g)/length(f)*100; 
    set(handles.text_Reliability,'string',num2str(reliability,4));

    if ~isempty(g)
        latency = (mean(handles.Response(f(g)))/handles.fs - handles.EventLims(1))*10^3;
        set(handles.text_Latency,'string',num2str(latency,4));
    else
        set(handles.text_Latency,'string','N/A');
    end
    
    if length(g) > 1
        jitter = std(handles.Response(f(g))/handles.fs)*10^6;
        set(handles.text_Jitter,'string',num2str(jitter,4));
    else
        set(handles.text_Jitter,'string','N/A');
    end
else
    set(handles.text_Reliability,'string','N/A');
    set(handles.text_Latency,'string','N/A');
    set(handles.text_Jitter,'string','N/A');
end

obj = findobj('parent',handles.panel_Statistics,'style','text');
set(obj,'ButtonDownFcn','egm_Antidromic_browser(''CopyStatistics'',gcbo,[],guidata(gcbo))');


% --- Outputs from this function are returned to the command line.
function varargout = egm_Antidromic_browser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.egh;


% --- Executes on button press in push_Prev.
function push_Prev_Callback(hObject, eventdata, handles)
% hObject    handle to push_Prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
trialnum = trialnum - 1;
set(handles.edit_TrialNumber,'string',num2str(trialnum));

handles = PlotTrial(handles);

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
mx = size(handles.trials,1)-handles.TrialsPerWindow+1;
if trialnum < handles.CurrentTopTrial
    handles.CurrentTopTrial = trialnum;
end
if trialnum > handles.CurrentTopTrial + handles.TrialsPerWindow - 1
    handles.CurrentTopTrial = trialnum - handles.TrialsPerWindow + 1;
    if handles.CurrentTopTrial > mx
        handles.CurrentTopTrial = mx;
    end
end
set(handles.slide_Trial,'value',mx-handles.CurrentTopTrial+1);
subplot(handles.axes_ColorPlot);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
subplot(handles.axes_Colors);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);

guidata(hObject, handles);


% --- Executes on button press in push_Next.
function push_Next_Callback(hObject, eventdata, handles)
% hObject    handle to push_Next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
trialnum = trialnum + 1;
set(handles.edit_TrialNumber,'string',num2str(trialnum));

handles = PlotTrial(handles);

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
mx = size(handles.trials,1)-handles.TrialsPerWindow+1;
if trialnum < handles.CurrentTopTrial
    handles.CurrentTopTrial = trialnum;
end
if trialnum > handles.CurrentTopTrial + handles.TrialsPerWindow - 1
    handles.CurrentTopTrial = trialnum - handles.TrialsPerWindow + 1;
    if handles.CurrentTopTrial > mx
        handles.CurrentTopTrial = mx;
    end
end
set(handles.slide_Trial,'value',mx-handles.CurrentTopTrial+1);
subplot(handles.axes_ColorPlot);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
subplot(handles.axes_Colors);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);

guidata(hObject, handles);


function click_ColorPlot(hObject, eventdata, handles)

set(gca,'units','pixels');
rect = rbbox;

pos = get(gca,'position');
xl = xlim;
yl = ylim;

rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
rect(2) = yl(2)-(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

if strcmp(get(gcf,'selectiontype'),'normal')
    if rect(4) < 1
        trialnum = round(rect(2));
        set(handles.edit_TrialNumber,'string',num2str(trialnum));
    else
        mx = round(rect(2));
        mn = round(rect(2)-rect(4));
        mx = min([mx size(handles.trials,1)]);
        mn = max([mn 1]);
        x1 = round((rect(1)/1000+handles.EventLims(1))*handles.fs);
        x1 = min([x1 size(handles.trials,2)]);
        x1 = max([x1 1]);
        x2 = round(((rect(1)+rect(3))/1000+handles.EventLims(1))*handles.fs);
        x2 = min([x2 size(handles.trials,2)]);
        x2 = max([x2 1]);
        if get(handles.radio_Positive,'value')==1
            [dummy v] = max(handles.trials(mn:mx,x1:x2),[],2);
        else
            [dummy v] = min(handles.trials(mn:mx,x1:x2),[],2);
        end
        v = v+x1-1;
        
        lst = mn:mx;
        lst = lst(find(handles.Deleted(lst)==0));
        v = v(find(handles.Deleted(lst)==0))';
        
        fig = figure('Name','New events','Numbertitle','off');
        for c = 1:length(v)
            plot((v(c)/handles.fs-handles.EventLims(1))*1000,handles.trials(lst(c),v(c)),'bo','markersize',4,'markerfacecolor','b');
            hold on
        end
        xlabel('Time to from (ms)');
        ylabel(handles.Label);
        ps = get(fig,'position');
        ps(3) = ps(3)/2;
        ps(4) = ps(4)*.7;
        set(fig,'position',ps);
        title('Click threshold; right-click to delete all')
        try
            [x y b] = ginput(1);                
        catch
            return
        end

        if b == 1
            for c = 1:length(v)
                if get(handles.radio_Positive,'value')==1
                    if handles.trials(lst(c),v(c)) < y
                        v(c) = inf;
                    end
                else
                    if handles.trials(lst(c),v(c)) > y
                        v(c) = inf;
                    end
                end
            end
        else
            v(1:end) = inf;
        end
        
        delete(fig);
        figure(handles.MainFigure);
        handles.Response(lst) = v;
    end
elseif strcmp(get(gcf,'selectiontype'),'extend')
    if rect(4) < 1
        trialnum = round(rect(2));
        if handles.Deleted(trialnum) == 1
            handles.Deleted(trialnum) = 0;
        else
            handles.Selected(trialnum) = 1-handles.Selected(trialnum);
        end
    else
        mx = round(rect(2));
        mn = round(rect(2)-rect(4));
        mx = min([mx size(handles.trials,1)]);
        mn = max([mn 1]);
        currstate = round(mean(handles.Selected(mn:mx)));
        if mean(handles.Deleted(mn:mx)) == 1
            handles.Deleted(mn:mx) = 0;
        else
            handles.Selected(mn:mx) = 1-currstate;
        end
    end
end

handles = PlotTrial(handles);

guidata(gca, handles);


function click_Trial(hObject, eventdata, handles)

set(gca,'units','pixels');
rect = rbbox;

pos = get(gca,'position');
xl = xlim;
yl = ylim;

rect(1) = xl(1)+(rect(1)-pos(1))/pos(3)*(xl(2)-xl(1));
rect(3) = rect(3)/pos(3)*(xl(2)-xl(1));
rect(2) = yl(1)+(rect(2)-pos(2))/pos(4)*(yl(2)-yl(1));
rect(4) = rect(4)/pos(4)*(yl(2)-yl(1));

pos = get(gca,'CurrentPoint');

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
if get(handles.radio_Positive,'value')==1
    f = find(handles.trials(trialnum,2:end-1)>handles.trials(trialnum,1:end-2) & handles.trials(trialnum,2:end-1)>=handles.trials(trialnum,3:end))+1;
else
    f = find(handles.trials(trialnum,2:end-1)<handles.trials(trialnum,1:end-2) & handles.trials(trialnum,2:end-1)<=handles.trials(trialnum,3:end))+1;
end
x = (pos(1,1)/1000+handles.EventLims(1))*handles.fs;
y = pos(1,2);
dst = sqrt(((f-x)/range(xlim/1000*handles.fs)).^2 + ((handles.trials(trialnum,f)-y)/range(ylim)).^2);

[mn g] = min(dst);
f = f(g(1));

if handles.Response(trialnum) == f
    handles.Response(trialnum) = inf;
else
    handles.Response(trialnum) = f;
end

handles = PlotTrial(handles);

guidata(gca, handles);


function edit_TrialNumber_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TrialNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TrialNumber as text
%        str2double(get(hObject,'String')) returns contents of edit_TrialNumber as a double

handles = PlotTrial(handles);

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
mx = size(handles.trials,1)-handles.TrialsPerWindow+1;
if trialnum < handles.CurrentTopTrial
    handles.CurrentTopTrial = trialnum;
end
if trialnum > handles.CurrentTopTrial + handles.TrialsPerWindow - 1
    handles.CurrentTopTrial = trialnum - handles.TrialsPerWindow + 1;
    if handles.CurrentTopTrial > mx
        handles.CurrentTopTrial = mx;
    end
end
set(handles.slide_Trial,'value',mx-handles.CurrentTopTrial+1);
subplot(handles.axes_ColorPlot);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
subplot(handles.axes_Colors);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);

guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function edit_TrialNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TrialNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in check_Selected.
function check_Selected_Callback(hObject, eventdata, handles)
% hObject    handle to check_Selected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_Selected

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
handles.Selected(trialnum) = get(handles.check_Selected,'value');

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes on button press in check_Deleted.
function check_Deleted_Callback(hObject, eventdata, handles)
% hObject    handle to check_Deleted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_Deleted

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
handles.Deleted(trialnum) = get(handles.check_Deleted,'value');

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes on selection change in popup_StatusAction.
function popup_StatusAction_Callback(hObject, eventdata, handles)
% hObject    handle to popup_StatusAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_StatusAction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_StatusAction

str = get(handles.popup_StatusAction,'string');
val = get(handles.popup_StatusAction,'value');

switch str{val}
    case 'Delete selection'
        handles.Deleted(find(handles.Selected==1)) = 1;
    case 'Undelete all'
        handles.Deleted(1:end) = 0;
    case 'Purge deleted...'
        button = questdlg('Permanently remove deleted trials?','Question','Yes','No','No');
        if ~strcmp(button,'Yes')
            return
        end
        
        f = find(handles.Deleted==0);
        
        handles.trials = handles.trials(f,:);
        handles.Selected = handles.Selected(f);
        handles.Deleted = handles.Deleted(f);
        handles.PrevSpike = handles.PrevSpike(f);
        handles.Response = handles.Response(f);
        handles.Order = handles.Order(f);
        handles.Group = handles.Group(f);
        handles.Filenum = handles.Filenum(f);
        handles.InFile = handles.InFile(f);
        
        handles.CurrentTopTrial = 1;
        handles.TrialsPerWindow = length(f);
        
    case 'Select all'
        handles.Selected(1:end) = 1;
    case 'Unselect all'
        handles.Selected(1:end) = 0;
    case 'Invert selection'
        handles.Selected = 1-handles.Selected;
    case 'Select trial numbers...'
        answer = inputdlg({'Array'},'Select by trial number',1,{['1:' num2str(size(handles.trials,1))]});
        if isempty(answer)
            return
        end
        arr = eval(answer{1});
        handles.Selected(1:end)=0;
        handles.Selected(arr) = 1;
    case 'Select file numbers...'
        answer = inputdlg({'Array'},'Select by file number',1,{[num2str(min(handles.Filenum)) ':' num2str(max(handles.Filenum))]});
        if isempty(answer)
            return
        end
        arr = eval(answer{1});
        handles.Selected(1:end)=0;
        for c = 1:length(arr)
            handles.Selected(find(handles.Filenum==arr(c))) = 1;
        end
    case 'Select by spike time...'
        answer = inputdlg({'From (ms)','To (ms)'},'Select by trial number',1,{num2str(-handles.xlim(1)*1000),'0'});
        if isempty(answer)
            return
        end
        mn = -str2num(answer{2})/1000*handles.fs;
        mx = -str2num(answer{1})/1000*handles.fs;
        arr = find(handles.PrevSpike>=mn & handles.PrevSpike<=mx);
        handles.Selected(1:end)=0;
        handles.Selected(arr) = 1;
    case 'Select by response time...'
        answer = inputdlg({'From (ms)','To (ms)'},'Select by trial number',1,{'0',num2str(handles.xlim(2)*1000),});
        if isempty(answer)
            return
        end
        mn = (str2num(answer{1})/1000+handles.EventLims(1))*handles.fs;
        mx = (str2num(answer{2})/1000+handles.EventLims(1))*handles.fs;
        arr = find(handles.Response>=mn & handles.Response<=mx);
        handles.Selected(1:end)=0;
        handles.Selected(arr) = 1;
    case 'Select by color...'
        val = menu('Choose color to select','Black','Red','Yellow','Green','Cyan','Blue','Magenta');
        if val == 0
            return
        end
        handles.Selected(1:end)=0;
        handles.Selected(find(handles.Group==val))=1;
    case '---'
        return
end

set(handles.popup_StatusAction,'value',1);

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function popup_StatusAction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_StatusAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_Time.
function push_Time_Callback(hObject, eventdata, handles)
% hObject    handle to push_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Min (ms)','Max (ms)'},'Time limits',1,{num2str(-handles.xlim(1)*1000),num2str(handles.xlim(2)*1000)});
if isempty(answer)
    return
end
handles.xlim = [-str2num(answer{1}) str2num(answer{2})]/1000;

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes on button press in push_Values.
function push_Values_Callback(hObject, eventdata, handles)
% hObject    handle to push_Values (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


answer = inputdlg({'Min','Max'},'Value limits',1,{num2str(handles.ylim(1)),num2str(handles.ylim(2))});
if isempty(answer)
    return
end
handles.ylim = [str2num(answer{1}) str2num(answer{2})];

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes on button press in check_Reverse.
function check_Reverse_Callback(hObject, eventdata, handles)
% hObject    handle to check_Reverse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_Reverse


% --- Executes on selection change in popup_Sort.
function popup_Sort_Callback(hObject, eventdata, handles)
% hObject    handle to popup_Sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Sort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Sort

str = get(handles.popup_Sort,'string');
val = get(handles.popup_Sort,'value');

switch str{val}
    case 'Chronologically'
        [srt ord] = sort(handles.Order);
    case 'Spike time'
        [srt ord] = sort(handles.PrevSpike);
    case 'Response time'
        [srt ord] = sort(handles.Response);
    case 'Color'
        [srt ord] = sort(handles.Group);
    case 'File number'
        [srt ord] = sort(handles.Filenum);
end
if get(handles.check_Reverse,'value')==1
    ord = ord(end:-1:1);
end

handles.trials = handles.trials(ord,:);
handles.Selected = handles.Selected(ord);
handles.Deleted = handles.Deleted(ord);
handles.PrevSpike = handles.PrevSpike(ord);
handles.Response = handles.Response(ord);
handles.Order = handles.Order(ord);
handles.Group = handles.Group(ord);
handles.Filenum = handles.Filenum(ord);
handles.InFile = handles.InFile(ord);

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
trialnum = find(ord==trialnum);
set(handles.edit_TrialNumber,'string',num2str(trialnum));

handles = PlotTrial(handles);

guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function popup_Sort_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_Sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_Negative.
function radio_Negative_Callback(hObject, eventdata, handles)
% hObject    handle to radio_Negative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_Negative

set(handles.radio_Positive,'value',1-get(handles.radio_Negative,'value'));
guidata(gca, handles);

% --- Executes on button press in radio_Positive.
function radio_Positive_Callback(hObject, eventdata, handles)
% hObject    handle to radio_Positive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_Positive

set(handles.radio_Negative,'value',1-get(handles.radio_Positive,'value'));
guidata(gca, handles);


% --- Executes on button press in check_ShowResponses.
function check_ShowResponses_Callback(hObject, eventdata, handles)
% hObject    handle to check_ShowResponses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ShowResponses

handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes on button press in check_ShowSpikes.
function check_ShowSpikes_Callback(hObject, eventdata, handles)
% hObject    handle to check_ShowSpikes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ShowSpikes

handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes on selection change in popup_Export.
function popup_Export_Callback(hObject, eventdata, handles)
% hObject    handle to popup_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Export contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Export

str = get(handles.popup_Export,'string');
val = get(handles.popup_Export,'value');

cols = 'krygcbm';
switch str{val}
    case 'Current trial'
        trialnum = str2num(get(handles.edit_TrialNumber,'string'));
        fig = figure;
        xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
        plot(xs,handles.trials(trialnum,:),'color',cols(handles.Group(trialnum)));
        ylabel(handles.Label);
        xlabel('Time from stim (ms)');
        ylim(handles.ylim);
        xlim([-handles.xlim(1),handles.xlim(2)]*1000);
    case 'All trials'
        answer = inputdlg({'Vertical spacing (%)'},'All trials',1,{['5']});
        if isempty(answer)
            return
        end
        sp = eval(answer{1});
        fig = figure;
        xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
        if get(handles.check_SelectionOnly,'value')==1
            lst = find(handles.Selected==1);
        else
            lst = find(handles.Deleted==0);
        end
        hg = range(handles.ylim);
        sp = hg*sp/100;
        for c = 1:length(lst)
            offs = (length(lst)-c)*(hg + sp);
            f = find(handles.trials(lst(c),:)<handles.ylim(1) | handles.trials(lst(c),:)>handles.ylim(2));
            tadd = zeros(size(xs));
            tadd(f)=inf;
            plot(xs,handles.trials(lst(c),:)-handles.ylim(1)+offs+tadd,'color',cols(handles.Group(lst(c))));
            hold on
        end
        set(gca,'ytick',[]);
        ylim([0 length(lst)*(hg+sp)-sp]);
        xlabel('Time from stim (ms)');
        box off
        xlim([-handles.xlim(1),handles.xlim(2)]*1000);
        
    case 'Overlapped trials'
        fig = figure;
        xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
        if get(handles.check_SelectionOnly,'value')==1
            lst = find(handles.Selected==1);
        else
            lst = find(handles.Deleted==0);
        end
        for c = 1:length(lst)
            plot(xs,handles.trials(lst(c),:),'color',cols(handles.Group(lst(c))));
            hold on
        end
        ylabel(handles.Label);
        xlabel('Time from stim (ms)');
        ylim(handles.ylim);
        xlim([-handles.xlim(1),handles.xlim(2)]*1000);
    case 'Trial average'
        fig = figure;
        xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
        if get(handles.check_SelectionOnly,'value')==1
            lst = find(handles.Selected==1);
        else
            lst = find(handles.Deleted==0);
        end
        plot(xs,mean(handles.trials(lst,:),1));
        ylabel(handles.Label);
        xlabel('Time from stim (ms)');
        ylim(handles.ylim);
        xlim([-handles.xlim(1),handles.xlim(2)]*1000);
    case 'Color plot'
        fig = figure;
        xs = linspace(-handles.EventLims(1),handles.EventLims(2),size(handles.trials,2))*1000;
        f = find(handles.Deleted==0);
        imagesc(xs,1:length(f),handles.trials(f,:))
        hold on
        if get(handles.check_ShowSpikes,'value')==1
            plot(-handles.PrevSpike(f)/handles.fs*1000,1:length(f),'ko','markersize',4,'markerfacecolor','w');
        end
        if get(handles.check_ShowResponses,'value')==1
            g = find(handles.Response(f)<inf);
            plot(xs(handles.Response(f(g))),f(g),'ko','markersize',4,'markerfacecolor','w');
        end

        xlim([-handles.xlim(1),handles.xlim(2)]*1000);
        box on
        xlabel('Time from stim (ms)');
        ylabel('Trial number');
        set(gca,'clim',handles.ylim);
        ylabel(handles.Label);
        set(gca,'clim',handles.ylim);
end

set(handles.popup_Export,'value',1);
guidata(gca, handles);



% --- Executes during object creation, after setting all properties.
function popup_Export_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_SelectionOnly.
function check_SelectionOnly_Callback(hObject, eventdata, handles)
% hObject    handle to check_SelectionOnly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_SelectionOnly




% --- Executes on slider movement.
function slide_Trial_Callback(hObject, eventdata, handles)
% hObject    handle to slide_Trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

mx = size(handles.trials,1)-handles.TrialsPerWindow+1;
handles.CurrentTopTrial = round(mx-get(handles.slide_Trial,'value')+1);
if handles.CurrentTopTrial < 1
    handles.CurrentTopTrial = 1;
end
if handles.CurrentTopTrial > mx
    handles.CurrentTopTrial = mx;
end

subplot(handles.axes_ColorPlot);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
subplot(handles.axes_Colors);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);

guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function slide_Trial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slide_Trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in push_Trials.
function push_Trials_Callback(hObject, eventdata, handles)
% hObject    handle to push_Trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Number of trials per window'},'Trials',1,{[num2str(handles.TrialsPerWindow)]});
if isempty(answer)
    return
end
handles.TrialsPerWindow = eval(answer{1});

handles = EditTrialNumber(handles);

guidata(gca, handles);


% --- Executes on button press in push_MinUp.
function push_MinUp_Callback(hObject, eventdata, handles)
% hObject    handle to push_MinUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ylim(1) = handles.ylim(1) + .05;
if handles.ylim(1) >= handles.ylim(2)
    return
end
handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes on button press in push_MinDown.
function push_MinDown_Callback(hObject, eventdata, handles)
% hObject    handle to push_MinDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ylim(1) = handles.ylim(1) - .05;
handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes on button press in push_MaxUp.
function push_MaxUp_Callback(hObject, eventdata, handles)
% hObject    handle to push_MaxUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ylim(2) = handles.ylim(2) + .05;
handles = PlotTrial(handles);
guidata(gca, handles);

% --- Executes on button press in push_MaxDown.
function push_MaxDown_Callback(hObject, eventdata, handles)
% hObject    handle to push_MaxDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.ylim(2) = handles.ylim(2) - .05;
if handles.ylim(1) >= handles.ylim(2)
    return
end
handles = PlotTrial(handles);
guidata(gca, handles);

% --- Executes on button press in push_TrialsUp.
function push_TrialsUp_Callback(hObject, eventdata, handles)
% hObject    handle to push_TrialsUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.TrialsPerWindow = handles.TrialsPerWindow + 1;

handles = EditTrialNumber(handles);

guidata(gca, handles);


% --- Executes on button press in push_TrialsDown.
function push_TrialsDown_Callback(hObject, eventdata, handles)
% hObject    handle to push_TrialsDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.TrialsPerWindow = handles.TrialsPerWindow - 1;

handles = EditTrialNumber(handles);

guidata(gca, handles);


function handles = EditTrialNumber(handles)

if handles.TrialsPerWindow < 1
    handles.TrialsPerWindow = 1;
end
if handles.TrialsPerWindow > size(handles.trials,1)
    handles.TrialsPerWindow = size(handles.trials,1);
end
if handles.TrialsPerWindow < size(handles.trials,1)
    set(handles.slide_Trial,'visible','on');
    mx = size(handles.trials,1)-handles.TrialsPerWindow+1;
    trialnum = str2num(get(handles.edit_TrialNumber,'string'));
    handles.CurrentTopTrial = round(trialnum-handles.TrialsPerWindow/2);
    if handles.CurrentTopTrial < 1
        handles.CurrentTopTrial = 1;
    end
    if handles.CurrentTopTrial > mx
        handles.CurrentTopTrial = mx;
    end
    set(handles.slide_Trial,'visible','on','value',1);
    set(handles.slide_Trial,'min',1,'max',mx,'sliderstep',[1/(mx-1) 5/(mx-1)]);
    set(handles.slide_Trial,'value',mx-handles.CurrentTopTrial+1);
else
    handles.CurrentTopTrial = 1;
    set(handles.slide_Trial,'visible','off');
end
    
subplot(handles.axes_ColorPlot);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);
subplot(handles.axes_Colors);
ylim([handles.CurrentTopTrial-.5 handles.CurrentTopTrial+handles.TrialsPerWindow-.5]);


% --- Executes on button press in push_Save.
function push_Save_Callback(hObject, eventdata, handles)
% hObject    handle to push_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[pathstr,name,ext,versn] = fileparts(handles.egh.DefaultFile);
[file, path] = uiputfile([pathstr name '_anti.mat'],'Save antidromic data');
if ~isstr(file)
    return
end

f = find(handles.Deleted==0);

anti.Trials = handles.trials(f,:);
anti.Fs = handles.fs;
anti.TimeLimits = [-handles.EventLims(1) handles.EventLims(2)];
anti.ChronologicalOrder = handles.Order(f);
anti.FileNumber = handles.Filenum(f);
anti.NumberWithinFile = handles.InFile(f);
anto.PreviousSpikeTime = -handles.PrevSpike(f)/handles.fs*1000;
anti.ResponseTime = (handles.Response(f)/handles.fs - handles.EventLims(1))*1000;
anti.ColorGroup = handles.Group(f);

save([path file],'anti');



% --- Executes on selection change in popup_CurrentColor.
function popup_CurrentColor_Callback(hObject, eventdata, handles)
% hObject    handle to popup_CurrentColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_CurrentColor contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_CurrentColor

trialnum = str2num(get(handles.edit_TrialNumber,'string'));
handles.Group(trialnum) = get(handles.popup_CurrentColor,'value');

handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes during object creation, after setting all properties.
function popup_CurrentColor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_CurrentColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in push_SelectionColor.
function push_SelectionColor_Callback(hObject, eventdata, handles)
% hObject    handle to push_SelectionColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_SelectionColor,'uicontextmenu',handles.context_Colors);

% Trigger a right-click event
try
    import java.awt.*;
    import java.awt.event.*;
    rob = Robot;
    rob.mousePress(InputEvent.BUTTON3_MASK);
    pause(0.01);
    rob.mouseRelease(InputEvent.BUTTON3_MASK);
catch
    errordlg('Java is not working properly. You must right-click the button.','Java error');
end



% --- Executes on button press in push_Order.
function push_Order_Callback(hObject, eventdata, handles)
% hObject    handle to push_Order (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function context_Colors_Callback(hObject, eventdata, handles)
% hObject    handle to context_Colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_color1_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,1);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color2_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,2);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color3_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,3);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color4_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,4);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color5_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,5);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color6_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,6);
guidata(gca, handles);

% --------------------------------------------------------------------
function menu_color7_Callback(hObject, eventdata, handles)
% hObject    handle to menu_color7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = clickcolor(handles,7);
guidata(gca, handles);

function handles = clickcolor(handles,num)

handles.Group(find(handles.Selected==1)) = num;
handles = PlotTrial(handles);
guidata(gca, handles);


% --- Executes on button press in check_StatisticsSelection.
function check_StatisticsSelection_Callback(hObject, eventdata, handles)
% hObject    handle to check_StatisticsSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_StatisticsSelection

handles = PlotTrial(handles);
guidata(gca, handles);


function CopyStatistics(hObject, eventdata, handles)

bck = get(handles.text_N,'BackgroundColor');

set(handles.text_N,'BackgroundColor',[1 1 0]);
set(handles.text_Reliability,'BackgroundColor',[1 1 0]);
set(handles.text_Latency,'BackgroundColor',[1 1 0]);
set(handles.text_Jitter,'BackgroundColor',[1 1 0]);

str = [get(handles.text_N,'string') char(9)];
str = [str get(handles.text_Reliability,'string') char(9)];
str = [str get(handles.text_Latency,'string') char(9)];
str = [str get(handles.text_Jitter,'string')];
clipboard('copy',str);

pause(0.1);

set(handles.text_N,'BackgroundColor',bck);
set(handles.text_Reliability,'BackgroundColor',bck);
set(handles.text_Latency,'BackgroundColor',bck);
set(handles.text_Jitter,'BackgroundColor',bck);