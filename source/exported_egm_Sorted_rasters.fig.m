function varargout = egm_Sorted_rasters_export(varargin)
% EGM_SORTED_RASTERS_EXPORT M-file for egm_Sorted_rasters_export.fig
%      EGM_SORTED_RASTERS_EXPORT, by itself, creates a new EGM_SORTED_RASTERS_EXPORT or raises the existing
%      singleton*.
%
%      H = EGM_SORTED_RASTERS_EXPORT returns the handle to a new EGM_SORTED_RASTERS_EXPORT or the handle to
%      the existing singleton*.
%
%      EGM_SORTED_RASTERS_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EGM_SORTED_RASTERS_EXPORT.M with the given input arguments.
%
%      EGM_SORTED_RASTERS_EXPORT('Property','Value',...) creates a new EGM_SORTED_RASTERS_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before egm_Sorted_rasters_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to egm_Sorted_rasters_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help egm_Sorted_rasters_export

% Last Modified by GUIDE v2.5 25-Mar-2026 14:58:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @egm_Sorted_rasters_export_OpeningFcn, ...
                   'gui_OutputFcn',  @egm_Sorted_rasters_export_OutputFcn, ...
                   'gui_LayoutFcn',  @egm_Sorted_rasters_export_LayoutFcn, ...
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


% --- Executes just before egm_Sorted_rasters_export is made visible.
function egm_Sorted_rasters_export_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to egm_Sorted_rasters_export (see VARARGIN)

set(handles.fig_Main,'position',[.025 .05 .95 .9]);

set(handles.popup_HistUnits,'position',get(handles.popup_PSTHUnits,'position'));
set(handles.popup_HistCount,'position',get(handles.popup_PSTHCount,'position'));
    
handles.BackupHandles = [];

handles.preset_prefix = 'egsr_preset_';
handles.no_presets_found = '<No presets found>';
handles = loadPresets(handles);

if length(varargin)==1
    % Copy ElectroGui handles
    handles.egh = varargin{1};
    handles.BackupHandles = handles.egh;

    handles.egh.overlaptolerance = 0.0001;
    handles.egh = Fix_Overlap(handles.egh);
    
    
    handles.FileRange = 1:handles.egh.TotalFileNumber;
    
    set(handles.push_GenerateRaster,'enable','on');
    set(handles.push_FileRange,'enable','on');

    % Get event list
    str = {'Sound'};
    for c = 1:length(handles.egh.EventSources)
        str{end+1} = [handles.egh.EventDetectors{c} ' - ' handles.egh.EventSources{c} ' - ' handles.egh.EventFunctions{c}];
    end
    set(handles.popup_TriggerSource,'string',str);
    
    str_corr = {'(None)'};
    
    if get(handles.egh.popup_Channel1,'value')>1
        lst = get(handles.egh.popup_Channel1,'string');
        strs = lst{get(handles.egh.popup_Channel1,'value')};
        lst = get(handles.egh.popup_Function1,'string');
        strf = lst{get(handles.egh.popup_Function1,'value')};
        str{end+1} = [strf ' - ' strs];
        str_corr{end+1} = [strf ' - ' strs];
    end
    if get(handles.egh.popup_Channel2,'value')>1
        lst = get(handles.egh.popup_Channel2,'string');
        strs = lst{get(handles.egh.popup_Channel2,'value')};
        lst = get(handles.egh.popup_Function2,'string');
        strf = lst{get(handles.egh.popup_Function2,'value')};
        str{end+1} = [strf ' - ' strs];
        str_corr{end+1} = [strf ' - ' strs];
    end
    
    set(handles.popup_EventSource,'string',str);
    
    set(handles.popup_Correlation,'string',str_corr);
    
    % Get file list
    str = get(handles.egh.list_Files,'string');
    for c = 1:length(str)
        str{c} = str{c}(26:end-14);
    end
    handles.FileNames = str;

    set(handles.popup_Files,'string',{'All files in range','Only selected by search','Only unselected'});
else
    handles.egh = [];
    set(handles.popup_TriggerSource,'string',{'Sound'});
    set(handles.popup_EventSource,'string',{'Sound'});
    set(handles.popup_Correlation,'string',{'(None)'});
end

set(handles.list_WarpPoints,'string',{'(None)'});
handles.WarpPoints = {};

set(handles.popup_EventList,'string',{'(None)'});

colmaps = {'Default','HSV','Hot','Cool','Spring','Summer','Autumn','Winter','Gray','Bone','Copper','Pink','Lines'};
for c = 1:length(colmaps)
    uimenu(handles.menu_Colormap,'label',colmaps{c},'callback',['colormap ' colmaps{c}]);
end

handles.SkippingSort = 0;

% Axis position
handles.AxisPosRaster = get(handles.axes_Raster,'position');
handles.AxisPosPSTH = get(handles.axes_PSTH,'position');
handles.AxisPosHist = get(handles.axes_Hist,'position');

handles.HistShow = [1 1];

% Events
handles.AllEventOnsets = {};
handles.AllEventOffsets = {};
handles.AllEventLabels = {};
handles.AllSelections = {};
handles.AllEventOptions = {};
handles.AllEventPlots = zeros(0,5);

% DEFAULT VALUES - feel free to edit

handles.P.trig.includeSyllList = '';
handles.P.trig.ignoreSyllList = '';
handles.P.trig.motifSequences = {};
handles.P.trig.motifInterval = 0.2;
handles.P.trig.boutInterval = 0.5;
handles.P.trig.boutMinDuration = 0.2;
handles.P.trig.boutMinSyllables = 2;
handles.P.trig.burstFrequency = 100;
handles.P.trig.burstMinSpikes = 2;
handles.P.trig.pauseMinDuration = 0.05; 
handles.P.trig.contSmooth = 1;
handles.P.trig.contSubsample = 0.001;

handles.P.event = handles.P.trig; % duplicate options

handles.P.preStartRef = .4;
handles.P.postStopRef = .4;

handles.P.filter = repmat([-inf inf],length(get(handles.list_Filter,'string')),1);

handles.PlotHandles = cell(1,30);
for c = 10:12
    handles.PlotHandles{c} = {[]};
end
handles.PlotInclude = [0 0 0 1 1 0 0 0 0 1 0 0 0 1 1 0 1 0 1 1 0 0 0 0 0 0 0 0 0 0];
handles.PlotContinuous = [1 1 -1 1 1 -1 1 1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 1 -1 -1 1 1 -1 1 1 -1 -1 -1 -1];
handles.PlotColor = [1 0 0; 1 0 0; 1 1/2 1/8; 1 0 0; 1 0 0; 1 1/2 1/8; 1 0 0; 1 0 0; 1 1/2 1/8; ...
    0 0 0; 0 0 0; 230/255 230/255 128/255; ...
    0 0 0; 128/255 128/255 128/255; 1 0 0; 0 0 0; 128/255 128/255 128/255; 1 1 1; ...
    0 1 0; 0 1 0; 1 1 1; ...
    .75 0 .75; .75 0 .75; 1 .85 .85; ...
    0 0 1; 0 0 1; .8 .8 1; 0 0 1; 0 0 1; .8 .8 1;];
handles.PlotLineWidth = ones(1,30);
handles.PlotAlpha = ones(1,30);
handles.PlotAlpha(27) = 0.5;
handles.PlotAlpha(30) = 0.5;

handles.PlotAutoColors = [];

handles.PlotXLim = [-0.15 0.15];
handles.PlotTickSize = [1 0.25 0.01 0.5];
handles.PlotOverlap = 50;
handles.PlotInPerSec = 0.04;

handles.BackgroundColor = [1 1 1];

handles.PSTHBinSize = 0.01;
handles.PSTHSmoothingWindow = 1;
handles.PSTHYLim = [0 50; 0 100; 0 0.05; 0 1; 0 1];

handles.HistBinSize = [20 5];
handles.HistSmoothingWindow = 1;
handles.HistYLim = [0 50; 0 100; 0 20; 0 1; 0 1];
handles.ROILim = [-inf inf];

handles.ExportResolution = 300;
handles.ExportWidth = [6 20];
handles.ExportHeight = [4 0.01 0.04];
handles.ExportPSTHHeight = 2;
handles.ExportHistHeight = 2;
handles.ExportInterval = 0.25;

handles.corrMax = 0.1;

handles.WarpIntervalLim = [-1 1]; % Range of intervals whose durations have been specified. Intervals outside this range are assigned mean duration.
handles.WarpIntervalType = [1 1];
handles.WarpIntervalDuration = [.1 .1]; % Only meaningful for custom interval type
handles.WarpNumBefore = 1;
handles.WarpNumAfter = 1;


% Choose default command line output for egm_Sorted_rasters_export
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes egm_Sorted_rasters_export wait for user response (see UIRESUME)
% uiwait(handles.fig_Main);


% --- Outputs from this function are returned to the command line.
function varargout = egm_Sorted_rasters_export_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.BackupHandles;


% --- Executes on selection change in popup_TriggerSource.
function popup_TriggerSource_Callback(hObject, ~, handles)
% hObject    handle to popup_TriggerSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerSource

set(handles.popup_TriggerType,'value',1);
if get(handles.popup_TriggerSource,'value') == 1
    set(handles.popup_TriggerType,'string',{'Syllables', 'Markers', 'Motifs', 'Bouts'});
else
    set(handles.popup_TriggerType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popup_TriggerSource_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_TriggerSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_TriggerType.
function popup_TriggerType_Callback(~, ~, ~)
% hObject    handle to popup_TriggerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerType


% --- Executes during object creation, after setting all properties.
function popup_TriggerType_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_TriggerType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_TriggerOptions.
function push_TriggerOptions_Callback(hObject, ~, handles)
% hObject    handle to push_TriggerOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.P.trig = edit_Options(handles.P.trig,handles.popup_TriggerType);

if get(handles.check_CopyTrigger,'value') == 1
    handles.P.event = handles.P.trig;
end

guidata(hObject, handles);


function handles = respondToEventSourceChange(handles)
set(handles.popup_EventType,'value',1);
set(handles.popup_PSTHUnits,'value',1);
if get(handles.popup_EventSource,'value') == 1
    set(handles.popup_EventType,'string',{'Syllables','Markers','Motifs','Bouts'});
    set(handles.popup_EventType,'enable','on');
    set(handles.popup_PSTHUnits,'string',{'Rate (Hz)','Count per trial','Total count'});
    set(handles.popup_HistUnits,'string',{'Rate (Hz)','Count per trial','Total count','Fraction of time','Time per trial (sec)','Total time (sec)'});
    set(handles.popup_PSTHCount,'string',{'Onsets','Offsets','Full duration'});
    set(handles.popup_HistCount,'string',{'Onsets','Offsets','Events, including partial','Events, excluding partial'});
elseif get(handles.popup_EventSource,'value')-1 <= length(handles.egh.EventTimes)
    set(handles.popup_EventType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
    set(handles.popup_EventType,'enable','on');
    set(handles.popup_PSTHUnits,'string',{'Rate (Hz)','Count per trial','Total count'});
    set(handles.popup_HistUnits,'string',{'Rate (Hz)','Count per trial','Total count','Fraction of time','Time per trial (sec)','Total time (sec)'});
    set(handles.popup_PSTHCount,'string',{'Onsets','Offsets','Full duration'});
    set(handles.popup_HistCount,'string',{'Onsets','Offsets','Events, including partial','Events, excluding partial'});    
else
    set(handles.popup_EventType,'string',{'Continuous function'});
    set(handles.popup_EventType,'enable','off');
    set(handles.popup_PSTHUnits,'string',{'Average'});
    set(handles.popup_HistUnits,'string',{'Average'});
    set(handles.popup_PSTHCount,'string',{'All time points'});
    set(handles.popup_HistCount,'string',{'All time points'});
end

% --- Executes on selection change in popup_EventSource.
function popup_EventSource_Callback(hObject, ~, handles)
% hObject    handle to popup_EventSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventSource contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventSource

handles = respondToEventSourceChange(handles);
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popup_EventSource_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_EventSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_EventType.
function popup_EventType_Callback(~, ~, ~)
% hObject    handle to popup_EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventType


% --- Executes during object creation, after setting all properties.
function popup_EventType_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_EventOptions.
function push_EventOptions_Callback(hObject, ~, handles)
% hObject    handle to push_EventOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.P.event = edit_Options(handles.P.event,handles.popup_EventType);

if get(handles.check_CopyEvents,'value') == 1
    handles.P.trig = handles.P.event;
end

guidata(hObject, handles);


% --- Executes on selection change in popup_StartReference.
function popup_StartReference_Callback(~, ~, ~)
% hObject    handle to popup_StartReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_StartReference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_StartReference


% --- Executes during object creation, after setting all properties.
function popup_StartReference_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_StartReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_StopReference.
function popup_StopReference_Callback(~, ~, ~)
% hObject    handle to popup_StopReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_StopReference contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_StopReference


% --- Executes during object creation, after setting all properties.
function popup_StopReference_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_StopReference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in push_WindowLimits.
function push_WindowLimits_Callback(hObject, ~, handles)
% hObject    handle to push_WindowLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Start prior to reference (sec)','Stop after reference (sec)'},'Window limits',1,{num2str(handles.P.preStartRef),num2str(handles.P.postStopRef)});
if isempty(answer)
    return
end
bckPre = handles.P.preStartRef;
bckPost = handles.P.postStopRef;
handles.P.preStartRef = str2double(answer{1});
handles.P.postStopRef = str2double(answer{2});

guidata(hObject, handles);


% --- Executes on button press in push_FileRange.
function push_FileRange_Callback(hObject, ~, handles)
% hObject    handle to push_FileRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = handles.FileNames;
for c = 1:length(str)
    str{c} = [num2str(c) '. ' str{c}];
end
[indx,ok] = listdlg('ListString',str,'InitialValue',handles.FileRange,'ListSize',[300 450],'Name','Select files','PromptString','Select file range');
if ok == 0
    return
end

handles.FileRange = indx;

guidata(hObject, handles);


% --- Executes on selection change in popup_PrimarySort.
function popup_PrimarySort_Callback(hObject, ~, handles)
% hObject    handle to popup_PrimarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PrimarySort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PrimarySort

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popup_PrimarySort_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_PrimarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_SecondarySort.
function popup_SecondarySort_Callback(hObject, ~, handles)
% hObject    handle to popup_SecondarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_SecondarySort contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_SecondarySort

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popup_SecondarySort_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_SecondarySort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_PrimaryDescending.
function check_PrimaryDescending_Callback(~, ~, ~)
% hObject    handle to check_PrimaryDescending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PrimaryDescending


% --- Executes on button press in check_SecondaryDescending.
function check_SecondaryDescending_Callback(~, ~, ~)
% hObject    handle to check_SecondaryDescending (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_SecondaryDescending


% --- Executes on button press in check_CopyEvents.
function check_CopyEvents_Callback(hObject, ~, handles)
% hObject    handle to check_CopyEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyEvents

if get(handles.check_CopyEvents,'value') == 1
    handles.P.trig = handles.P.event;
end

guidata(hObject, handles);

% --- Executes on button press in check_CopyTrigger.
function check_CopyTrigger_Callback(hObject, ~, handles)
% hObject    handle to check_CopyTrigger (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyTrigger


if get(handles.check_CopyTrigger,'value') == 1
    handles.P.event = handles.P.trig;
end

guidata(hObject, handles);

function opt = edit_Options(opt,obj)
% Edit trigger or event options

switch get(obj,'tag')
    case 'popup_TriggerType'
        label = 'Trigger options';
    case 'popup_EventType'
        label = 'Event options';
end

str = get(obj,'string');
val = get(obj,'value');

switch str{val}
    case 'Syllables'
        indx = 1:2;
    case 'Markers'
        indx = 1:2;
    case 'Motifs'
        indx = 3:4;
    case 'Bouts'
        indx = [1:2 5:7];
    case 'Events'
        errordlg('Events do not require options!','Error');
        return
    case {'Bursts','Burst events','Single events'}
        indx = 8:9;
    case 'Pauses'
        indx = 10;
    case 'Continuous function'
        indx = 11:12;
end

query = { ...
    'List of included syllables/markers ('''' for unlabeled). Leave empty to include all.', ...
    'List of excluded syllables/markers',...
    'Sequences of syllable labels to consider motifs', ...
    'Maximum syllable separation (sec)', ...
    'Maximum bout interval (sec)',...
    'Minimum bout duration (sec)', ...
    'Minimum number of syllables in a bout', ...
    'Minimum burst frequency (Hz)',...
    'Minimum number of events in a burst', ...
    'Minimum pause duration (sec)', ...
    'Smooth window (# points)', ...
    'Subsample (sec)'};
motseq = '{';
for c = 1:length(opt.motifSequences)
    if c > 1
        motseq = [motseq ', ']; %#ok<*AGROW> 
    end
    motseq = [motseq '''' opt.motifSequences{c} ''''];
end
motseq = [motseq '}'];
def = { ...
    opt.includeSyllList, ...
    opt.ignoreSyllList, ...
    motseq, ...
    num2str(opt.motifInterval), ...
    num2str(opt.boutInterval), ...
    num2str(opt.boutMinDuration), ...
    num2str(opt.boutMinSyllables), ...
    num2str(opt.burstFrequency), ...
    num2str(opt.burstMinSpikes), ...
    num2str(opt.pauseMinDuration), ...
    num2str(opt.contSmooth), ...
    num2str(opt.contSubsample)};

answer = inputdlg(query(indx),label,1,def(indx));
if isempty(answer)
    return
end

switch str{val}
    case 'Syllables'
        opt.includeSyllList = answer{1};
        opt.ignoreSyllList = answer{2};
    case 'Markers'
        opt.includeSyllList = answer{1};
        opt.ignoreSyllList = answer{2};
    case 'Motifs'
        opt.motifSequences = eval(answer{1});
        opt.motifInterval = str2double(answer{2});
    case 'Bouts'
        opt.includeSyllList = answer{1};
        opt.ignoreSyllList = answer{2};
        opt.boutInterval = str2double(answer{3});
        opt.boutMinDuration = str2double(answer{4});
        opt.boutMinSyllables = str2double(answer{5});
    case 'Events'
        errordlg('Events do not require options!','Error');
        return
    case {'Bursts','Burst events','Single events'}
        opt.burstFrequency= str2double(answer{1});
        opt.burstMinSpikes = str2double(answer{2});
    case 'Pauses'
        opt.pauseMinDuration  = str2double(answer{1});
    case 'Continuous function'
        opt.contSmooth = str2double(answer{1});
        opt.contSubsample = str2double(answer{2});
end


% --- Executes on selection change in popup_Files.
function popup_Files_Callback(~, ~, ~)
% hObject    handle to popup_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Files


% --- Executes during object creation, after setting all properties.
function popup_Files_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_Files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_GenerateRaster.
function push_GenerateRaster_Callback(hObject, ~, handles)
% hObject    handle to push_GenerateRaster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_GenerateRaster,'foregroundcolor','r');
drawnow;

% Get trigger times
str = get(handles.popup_TriggerType,'string');
val = get(handles.popup_TriggerType,'value');
indx = get(handles.popup_TriggerSource,'value')-1;
[trig.on, trig.off, trig.info, handles.FileList] = GetEventStructure(handles,indx,str{val},handles.P.trig);

% Get event times
str = get(handles.popup_EventType,'string');
val = get(handles.popup_EventType,'value');
indx = get(handles.popup_EventSource,'value')-1;
[event.on, event.off, event.info, handles.FileList] = GetEventStructure(handles,indx,str{val},handles.P.event);

% Get warp point times
warp_points = cell(1,length(trig.on));
for c = 1:length(handles.WarpPoints)
    [ons, offs, info, handles.FileList] = GetEventStructure(handles,handles.WarpPoints{c}.source,handles.WarpPoints{c}.type,handles.WarpPoints{c}.P);
    for d = 1:length(ons)
        switch handles.WarpPoints{c}.alignment
            case 'Onset'
                warp_points{d} = [warp_points{d}; ons{d}];
            case 'Offset'
                warp_points{d} = [warp_points{d}; offs{d}];
            case 'Midpoint'
                warp_points{d} = [warp_points{d}; (ons{d}+offs{d})/2];
        end
    end
end
for c = 1:length(warp_points)
    warp_points{c} = unique(handles.egh.DatesAndTimes(trig.info.filenum(c)) + warp_points{c}/(handles.egh.fs*24*60*60));
end

% Align events to triggers
if get(handles.check_HoldOn,'value')==0
    handles.EventFilters = [];
    str = get(handles.popup_EventType,'string');
    ev_str = str{get(handles.popup_EventType,'value')};
    str = get(handles.popup_EventSource,'string');
    ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
    handles.filteredEvents.name = ev_str;
    handles.filteredEvents.options = handles.P.event;
end
[triggerInfo, handles.EventFilters] = GetTriggerAlignedEvents(handles,trig,event,warp_points,handles.EventFilters);

% Error if there are no triggers
if isempty(triggerInfo)
    errordlg('No triggers found!','Error');
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    return
end

% Align warp points to triggers
keepi = 1:length(triggerInfo.absTime);
warpTimes = zeros(length(triggerInfo.absTime),handles.WarpNumBefore+handles.WarpNumAfter+1);
if ~isempty(handles.WarpPoints)
    for c = 1:length(triggerInfo.absTime)
        filenum = triggerInfo.fileNum(c);
        f = find(warp_points{filenum}<triggerInfo.absTime(c));
        g = find(warp_points{filenum}>triggerInfo.absTime(c));
        if length(f) >= handles.WarpNumBefore && length(g) >= handles.WarpNumAfter
            warpTimes(c,:) = [warp_points{filenum}(f(end-handles.WarpNumBefore+1:end))' triggerInfo.absTime(c) warp_points{filenum}(g(1:handles.WarpNumAfter))'];
            warpTimes(c,:) = (warpTimes(c,:) - triggerInfo.absTime(c))*(24*60*60);
        else
            keepi(keepi==c) = [];
        end
    end
    warpTimes = warpTimes(keepi,:);
end

% Keep only triggers with enough warp points
fields = fieldnames(triggerInfo);
for c = 1:length(fields)
    if ~strcmp(fields{c},'contLabel')
        fld = triggerInfo.(fields{c});
        fld = fld(keepi);
        triggerInfo.(fields{c}) = fld;
    end
end

% Error if there are no triggers
if isempty(triggerInfo.absTime)
    errordlg('No triggers with requested parameters found!','Error');
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    return
end


if get(handles.check_SkipSorting,'value')==1
    set(handles.push_GenerateRaster,'foregroundcolor','k');
    handles.SkippingSort = 1;
    cla(handles.axes_Raster);
    cla(handles.axes_PSTH);
    cla(handles.axes_Hist);
    subplot(handles.axes_Raster);
    tx = text(0,0,'Triggers extracted and filtered. Hold on to add events, sort, and plot.');
    set(tx,'HorizontalAlignment','Center','Color','r','Fontweight','bold');
    xlim([-1 1]);
    ylim([-1 1]);
    guidata(hObject, handles);
    return
end


% Sort triggers
if get(handles.check_HoldOn,'value')==0 || handles.SkippingSort == 1
    str = get(handles.popup_EventType,'string');
    ev_str = str{get(handles.popup_EventType,'value')};
    str = get(handles.popup_EventSource,'string');
    ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
    handles.sortedEvents.name = ev_str;
    handles.sortedEvents.options = handles.P.event;
    
    handles.Order = 1:size(warpTimes,1);
    if get(handles.radio_YTrial,'value')==1
        str = get(handles.popup_SecondarySort,'string');
        [triggerInfo, ord] = SortTriggers(triggerInfo,str{get(handles.popup_SecondarySort,'value')},get(handles.check_SecondaryDescending,'value'),handles.P.event.includeSyllList,0);
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
        str = get(handles.popup_PrimarySort,'string');
        [triggerInfo, ord] = SortTriggers(triggerInfo,str{get(handles.popup_PrimarySort,'value')},get(handles.check_PrimaryDescending,'value'),handles.P.event.includeSyllList,get(handles.check_GroupLabels,'value'));
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
    else
        [triggerInfo, ord] = SortTriggers(triggerInfo,'Absolute time',0,handles.P.event.includeSyllList,0);
        warpTimes = warpTimes(ord,:);
        handles.Order = handles.Order(ord);
    end
else
    ord = handles.Order;
    fields = fieldnames(triggerInfo);
    for c = 1:length(fields)
        if ~strcmp(fields{c},'contLabel')
            fld = triggerInfo.(fields{c});
            fld = fld(ord);
            triggerInfo.(fields{c}) = fld;
        end
    end
    warpTimes = warpTimes(ord,:);
end

% Warp
if ~isempty(handles.WarpPoints)
    newwarp = zeros(1,size(warpTimes,2));
    cnt = handles.WarpNumBefore+1;
    for c = 1:handles.WarpNumBefore
        if -c < handles.WarpIntervalLim(1)
            tp = 1;
            dur = 0.1;
        else
            tp = handles.WarpIntervalType(-c-handles.WarpIntervalLim(1)+1);
            dur = handles.WarpIntervalDuration(-c-handles.WarpIntervalLim(1)+1);
        end
        switch tp
            case 1
                dur = mean(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 2
                dur = median(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 3
                dur = max(warpTimes(:,cnt-c+1)-warpTimes(:,cnt-c));
            case 4
                % dur = dur
        end
        newwarp(cnt-c) = newwarp(cnt-c+1)-dur;
    end
    for c = 1:handles.WarpNumAfter
        if c > handles.WarpIntervalLim(2)
            tp = 1;
            dur = 0.1;
        else
            tp = handles.WarpIntervalType(c-handles.WarpIntervalLim(1));
            dur = handles.WarpIntervalDuration(c-handles.WarpIntervalLim(1));
        end
        switch tp
            case 1
                dur = mean(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 2
                dur = median(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 3
                dur = max(warpTimes(:,cnt+c)-warpTimes(:,cnt+c-1));
            case 4
                % dur = dur
        end
        newwarp(cnt+c) = newwarp(cnt+c-1)+dur;
    end
        

    str = get(handles.popup_WarpingAlgorithm,'string');
    val = get(handles.popup_WarpingAlgorithm,'value');
    
    towarp = {'prevTrigOnset','prevTrigOffset','currTrigOnset','currTrigOffset','nextTrigOnset','nextTrigOffset','eventOnsets','eventOffsets','dataStart','dataStop'};
    stretch = zeros(size(warpTimes,1),size(warpTimes,2)-1);
    for w = 1:length(towarp)
        fld = triggerInfo.(towarp{w});
        for c = 1:size(warpTimes,1)
            if iscell(fld)
                [fld{c}, strt] = WarpTrial(fld{c},warpTimes(c,:),newwarp,str{val},handles.egh.fs,towarp{w});
            else
                [fld(c), strt] = WarpTrial(fld(c),warpTimes(c,:),newwarp,str{val},handles.egh.fs,towarp{w});
            end
            stretch(c,:) = strt;
        end
        triggerInfo.(towarp{w}) = fld;
    end
end

% if limits copy window, fix limits to the warp points or reference
if get(handles.check_CopyWindow,'value')==1
    if get(handles.popup_StartReference,'value')==6
        handles.PlotXLim(1) = newwarp(1)-handles.P.preStartRef;
    else
        handles.PlotXLim(1) = -handles.P.preStartRef;
    end
    if get(handles.popup_StopReference,'value')==6
        handles.PlotXLim(2) = newwarp(end)+handles.P.postStopRef;
    else
        handles.PlotXLim(2) = handles.P.postStopRef;
    end
end

  
if get(handles.check_HoldOn,'value')==0 || handles.SkippingSort == 1
    handles.TriggerSelection = ones(1,length(triggerInfo.absTime));
    handles.Selection(1,:) = [1 length(triggerInfo.absTime)];
    handles.Selection(2,:) = [min(triggerInfo.absTime) max(triggerInfo.absTime)];
    handles.Selection(3,:) = [min(triggerInfo.currTrigOffset-triggerInfo.currTrigOnset) max(triggerInfo.currTrigOffset-triggerInfo.currTrigOnset)];
    handles.Selection(4,:) = [min(triggerInfo.prevTrigOnset) max(triggerInfo.prevTrigOnset)];
    handles.Selection(5,:) = [min(triggerInfo.prevTrigOffset) max(triggerInfo.prevTrigOffset)];
    handles.Selection(6,:) = [min(triggerInfo.nextTrigOnset) max(triggerInfo.nextTrigOnset)];
    handles.Selection(7,:) = [min(triggerInfo.nextTrigOffset) max(triggerInfo.nextTrigOffset)];
    handles.Selection(8,:) = handles.FileRange([min(triggerInfo.fileNum) max(triggerInfo.fileNum)]);

    val = -inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOnsets{c}<0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOnsets{c}(f(end));
        end
    end
    handles.Selection(9,:) = [min(val) max(val)];

    val = -inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOffsets{c}<0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOffsets{c}(f(end));
        end
    end
    handles.Selection(10,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOnsets{c}>0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOnsets{c}(f(1));
        end
    end
    handles.Selection(11,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        f = find(triggerInfo.eventOffsets{c}>0);
        if ~isempty(f)
            val(c) = triggerInfo.eventOffsets{c}(f(1));
        end
    end
    handles.Selection(12,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOnsets{c});
            val(c) = min(triggerInfo.eventOnsets{c});
        end
    end
    handles.Selection(13,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOffsets{c});
            val(c) = min(triggerInfo.eventOffsets{c});
        end
    end
    handles.Selection(14,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOnsets{c});
            val(c) = max(triggerInfo.eventOnsets{c});
        end
    end
    handles.Selection(15,:) = [min(val) max(val)];

    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        if ~isempty(triggerInfo.eventOffsets{c});
            val(c) = max(triggerInfo.eventOffsets{c});
        end
    end
    handles.Selection(16,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        val(c) = length(triggerInfo.eventOnsets{c});
    end
    handles.Selection(17,:) = [min(val) max(val)];
    
    val = inf*ones(size(triggerInfo.absTime));
    for c = 1:length(val)
        val(c) = (length(find(triggerInfo.eventOnsets{c}<=0)) > length(find(triggerInfo.eventOffsets{c}<0)));
    end
    handles.Selection(18,:) = [min(val) max(val)];

    handles.LabelSelectionInc = '';
    handles.LabelSelectionExc = '';
    if min(triggerInfo.label) >= 1000
        handles.LabelRange = [min(triggerInfo.label) max(triggerInfo.label)]-1000;
    else
        handles.LabelRange = [];
    end

    set(handles.text_NumTriggers,'string',[num2str(length(triggerInfo.absTime)) ' triggers']);
else
    f = find(handles.TriggerSelection==0);
    triggerInfo.eventOnsets(f) = cell(1,length(f));
    triggerInfo.eventOffsets(f) = cell(1,length(f));
end

if ~isempty(handles.WarpPoints)
    triggerInfo.warpTimes = newwarp;
    triggerInfo.warpStretch = stretch;
else
    triggerInfo.warpTimes = 0;
    triggerInfo.warpStretch = [];
end


% ======================
% PLOT
warning off
set(gcf,'renderer','opengl');

subplot(handles.axes_Raster);
hold on;

if get(handles.check_HoldOn,'value') == 0 || handles.SkippingSort == 1
    cla;
    handles.PlotHandles = cell(1,30);
    for c = 10:12
        handles.PlotHandles{c} = {[]};
    end
    event_indx = 1;
    handles.AllEventOnsets = {triggerInfo.eventOnsets};
    handles.AllEventOffsets = {triggerInfo.eventOffsets};
    handles.AllEventLabels = {triggerInfo.eventLabels};
    handles.AllEventSelections = {handles.TriggerSelection};
    handles.AllEventOptions = {handles.P.event};
    handles.AllEventPlots = [handles.PlotInclude(10:12) max(handles.PlotInclude(13:14)) max(handles.PlotInclude(16:18))];
    set(handles.popup_EventList,'value',1);
    set(handles.popup_EventList,'string',{'(None)'});
else
    for c = 10:12
        handles.PlotHandles{c}{end+1} = [];
    end
    handles.PlotHandles(13:18) = cell(1,6);
    handles.AllEventOnsets{end+1} = triggerInfo.eventOnsets;
    handles.AllEventOffsets{end+1} = triggerInfo.eventOffsets;
    handles.AllEventLabels{end+1} = triggerInfo.eventLabels;
    handles.AllEventSelections{end+1} = handles.TriggerSelection;
    handles.AllEventOptions{end+1} = handles.P.event;
    handles.AllEventPlots(end+1,:) = [handles.PlotInclude(10:12) max(handles.PlotInclude(13:14)) max(handles.PlotInclude(16:18))];
end
if handles.AllEventPlots(end,4)==1
    handles.AllEventPlots(1:end-1,4) = 0;
end
if handles.AllEventPlots(end,5)==1
    handles.AllEventPlots(1:end-1,5) = 0;
end
if handles.HistShow(1)==0
    handles.AllEventPlots(:,4) = 0;
end
if handles.HistShow(2)==0
    handles.AllEventPlots(:,5) = 0;
end
hold on;

str = get(handles.popup_EventType,'string');
ev_str = str{get(handles.popup_EventType,'value')};
str = get(handles.popup_EventSource,'string');
ev_str = ['[' ev_str '] ' str{get(handles.popup_EventSource,'value')}];
if ~isempty(strfind(ev_str,'Syllables')) || ~isempty(strfind(ev_str,'Markers')) 
    if ~isempty(handles.P.event.includeSyllList)
        ev_str = [ev_str ' - Include ' handles.P.event.includeSyllList];
    end
    if ~isempty(handles.P.event.ignoreSyllList)
        ev_str = [ev_str ' - Ignore ' handles.P.event.ignoreSyllList];
    end
end
ev_str = [ev_str ' -'];
str = get(handles.popup_EventList,'string');
str{length(handles.AllEventOnsets)} = ev_str;

plt = {'On','Off','Box','PSTH','Vert'};
for c = 1:length(str)
    f = strfind(str{c},'-');
    str{c} = str{c}(1:f(end)-2);
    if sum(handles.AllEventPlots(c,:)) == 0
        str{c} = [str{c} ' - No plots'];
    else
        tas = ' - ';
        for d = find(handles.AllEventPlots(c,:)==1)
            tas = [tas plt{d} '+'];
        end
        str{c} = [str{c} tas(1:end-1)];
    end
end
    

set(handles.popup_EventList,'string',str);
set(handles.popup_EventList,'value',length(str));

if get(handles.radio_YTrial,'value')==1
    y1 = (1:length(triggerInfo.absTime));
else
    y1 = (triggerInfo.absTime-min(triggerInfo.absTime))*(24*60*60);
end
if length(y1)==1
    df = 1;
else
    df = mean(diff(y1));
end

if get(handles.radio_TickTrials,'value')==1
    y2 = [y1(handles.PlotTickSize(1)+1:end) y1(end)+(1:handles.PlotTickSize(1)).*repmat(df,1,handles.PlotTickSize(1))];
elseif get(handles.radio_TickSeconds,'value')==1
    y2 = y1 + handles.PlotTickSize(2);
elseif get(handles.radio_TickInches,'value')==1
    if get(handles.radio_YTrial,'value')==1
        y2 = y1 + 100/(100-handles.PlotOverlap);
    else
        y2 = y1 + handles.PlotTickSize(3)/handles.PlotInPerSec;
    end
elseif get(handles.radio_TickPercent,'value')==1
    p = handles.PlotTickSize(4)/100;
    y2 = y1 + p/(1-p)*(max(y1)-min(y1));
end

if strcmp(get(handles.popup_EventType,'enable'),'on')
    evx1 = cat(1,triggerInfo.eventOnsets{:});
    evx2 = cat(1,triggerInfo.eventOffsets{:});
    evy1 = zeros(size(evx1));
    evy2 = zeros(size(evx1)); % makes y's same length as onset x's
    indx2 = cumsum(cellfun('length',triggerInfo.eventOnsets));
    indx1 = [1 indx2(1:end-1)+1];
    for tNum = 1:length(indx1)
        evy1(indx1(tNum):indx2(tNum)) = y1(tNum);
        evy2(indx1(tNum):indx2(tNum)) = y2(tNum);
    end
end

ys = reshape(repmat((y1(2:end)+y2(1:end-1))/2,2,1),1,2*length(y1)-2);
ys = [y1(1) ys y2(end)];

handles.TrialYs = y1;

bck_inc = handles.PlotInclude;
if get(handles.check_HoldOn,'value')==1 && handles.SkippingSort==0
    handles.PlotInclude([1:9 19 21:end]) = 0;
end


% Trial boxes
if handles.PlotInclude(21)==1
    xcorr = [handles.PlotXLim(1) handles.PlotXLim(2) handles.PlotXLim(2) handles.PlotXLim(1)]';
    handles.PlotHandles{21} = patch(repmat(xcorr,1,length(y1)),[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Window boxes
if handles.PlotInclude(24)==1
    d1 = [];
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{24} = patch([d1; d2; d2; d1],[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Continuous function
if max(handles.PlotInclude(10:12))==1 && strcmp(get(handles.popup_EventType,'enable'),'off')
    for c = 1:length(triggerInfo.eventOnsets)
        for d = 1:length(triggerInfo.dataStart{c})
            f = find(triggerInfo.eventOnsets{c}>=triggerInfo.dataStart{c}(d) & triggerInfo.eventOnsets{c}<=triggerInfo.dataStop{c}(d));
            if length(f)>1
                xt = linspace(triggerInfo.dataStart{c}(d),triggerInfo.dataStop{c}(d),2*length(f)+1);
                if strcmp(get(handles.menu_LogScale,'checked'),'off')
                    imagesc(xt(2:2:end-1),[y1(c)+(y2(c)-y1(c))/3 y2(c)-(y2(c)-y1(c))/3],triggerInfo.eventLabels{c}(f));
                else
                    imagesc(xt(2:2:end-1),[y1(c)+(y2(c)-y1(c))/3 y2(c)-(y2(c)-y1(c))/3],log10(triggerInfo.eventLabels{c}(f)));
                end
            end
        end
    end
    if ~isfield(handles,'CLim')
        handles.CLim = get(handles.axes_Raster,'clim');
    end
    set(handles.axes_Raster,'clim',handles.CLim);
end

% Trigger boxes
if handles.PlotInclude(3)==1
    x1 = triggerInfo.prevTrigOnset;
    x2 = triggerInfo.prevTrigOffset;
    handles.PlotHandles{3} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end
if handles.PlotInclude(6)==1
    x1 = triggerInfo.currTrigOnset;
    x2 = triggerInfo.currTrigOffset;
    handles.PlotHandles{6} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end
if handles.PlotInclude(9)==1
    x1 = triggerInfo.nextTrigOnset;
    x2 = triggerInfo.nextTrigOffset;
    handles.PlotHandles{9} = patch([x1; x2; x2; x1],[y1; y1; y2; y2],ones(1,length(x1),3));
end

% Event boxes
if handles.PlotInclude(12)==1 && strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{12}{end} = patch([evx1 evx2 evx2 evx1]',[evy1 evy1 evy2 evy2]',ones(1,length(evx1),3));
end

% ROI boxes
if handles.PlotInclude(27)==1
    xcorr = [handles.PlotXLim(1) handles.PlotXLim(2) handles.PlotXLim(2) handles.PlotXLim(1)]';
    handles.PlotHandles{27} = patch(repmat(xcorr,1,length(y1)),[ys(1:2:end); ys(1:2:end); ys(2:2:end); ys(2:2:end)],ones(1,length(y1),3));
end

% Warp line ticks
if handles.PlotInclude(19)==1 && handles.PlotContinuous(19)<1 && ~isempty(handles.WarpPoints)
    for w = 1:size(warpTimes,2)
        handles.PlotHandles{19} = [handles.PlotHandles{19}; line(repmat(newwarp(w),2,length(y1)),[y1; y2])'];
    end
end

% Window start and stop ticks
if handles.PlotInclude(22)==1 && handles.PlotContinuous(22)<1
    d1 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
    end
    handles.PlotHandles{22} = line([d1; d1],[y1; y2])';
end
if handles.PlotInclude(23)==1 && handles.PlotContinuous(23)<1
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{23} = line([d2; d2],[y1; y2])';
end

% Trigger ticks
if handles.PlotInclude(1)==1 && handles.PlotContinuous(1)<1
    handles.PlotHandles{1} = line([triggerInfo.prevTrigOnset; triggerInfo.prevTrigOnset],[y1; y2])';
end
if handles.PlotInclude(2)==1 && handles.PlotContinuous(2)<1
    handles.PlotHandles{2} = line([triggerInfo.prevTrigOffset; triggerInfo.prevTrigOffset],[y1; y2])';
end
if handles.PlotInclude(4)==1 && handles.PlotContinuous(4)<1
    handles.PlotHandles{4} = line([triggerInfo.currTrigOnset; triggerInfo.currTrigOnset],[y1; y2])';
end
if handles.PlotInclude(5)==1 && handles.PlotContinuous(5)<1
    handles.PlotHandles{5} = line([triggerInfo.currTrigOffset; triggerInfo.currTrigOffset],[y1; y2])';
end
if handles.PlotInclude(7)==1 && handles.PlotContinuous(7)<1
    handles.PlotHandles{7} = line([triggerInfo.nextTrigOnset; triggerInfo.nextTrigOnset],[y1; y2])';
end
if handles.PlotInclude(8)==1 && handles.PlotContinuous(8)<1
    handles.PlotHandles{8} = line([triggerInfo.nextTrigOffset; triggerInfo.nextTrigOffset],[y1; y2])';
end

% ROI ticks
if handles.PlotInclude(25)==1 && handles.PlotContinuous(25)<1
    handles.PlotHandles{25} = line(repmat(handles.ROILim(1),2,length(y1)),[y1; y2])';
end
if handles.PlotInclude(26)==1 && handles.PlotContinuous(26)<1
    handles.PlotHandles{26} = line(repmat(handles.ROILim(2),2,length(y1)),[y1; y2])';
end

% Plot all event ticks
if handles.PlotInclude(10)==1 && strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{10}{end} = line([evx1 evx1]',[evy1 evy2]');
end
if handles.PlotInclude(11)==1 && strcmp(get(handles.popup_EventType,'enable'),'on')
    handles.PlotHandles{11}{end} = line([evx2 evx2]',[evy1 evy2]')';
end

% Continuous window limits
if handles.PlotInclude(22)==1 && handles.PlotContinuous(22)==1
    d1 = [];
    for c = 1:length(triggerInfo.dataStart)
        d1(c) = min(triggerInfo.dataStart{c});
    end
    handles.PlotHandles{22} = plot(reshape(repmat(d1,2,1),1,2*length(d1)),ys);
end
if handles.PlotInclude(23)==1 && handles.PlotContinuous(23)==1
    d2 = [];
    for c = 1:length(triggerInfo.dataStart)
        d2(c) = max(triggerInfo.dataStop{c});
    end
    handles.PlotHandles{23} = plot(reshape(repmat(d2,2,1),1,2*length(d2)),ys);
end

% Continuous warp lines
if handles.PlotInclude(19)==1 && handles.PlotContinuous(19)==1 && ~isempty(handles.WarpPoints)
    for w = 1:size(warpTimes,2)
        px = repmat(newwarp(w),1,length(y1));
        handles.PlotHandles{19} = [handles.PlotHandles{19}; plot(reshape(repmat(px,2,1),1,2*length(px)),ys)];
    end
end

% Plot continuous trigger lines
if handles.PlotInclude(1)==1 && handles.PlotContinuous(1)==1
    px = triggerInfo.prevTrigOnset;
    handles.PlotHandles{1} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(2)==1 && handles.PlotContinuous(2)==1
    px = triggerInfo.prevTrigOffset;
    handles.PlotHandles{2} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(4)==1 && handles.PlotContinuous(4)==1
    px = triggerInfo.currTrigOnset;
    handles.PlotHandles{4} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(5)==1 && handles.PlotContinuous(5)==1
    px = triggerInfo.currTrigOffset;
    handles.PlotHandles{5} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(7)==1 && handles.PlotContinuous(7)==1
    px = triggerInfo.nextTrigOnset;
    handles.PlotHandles{7} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(8)==1 && handles.PlotContinuous(8)==1
    px = triggerInfo.nextTrigOffset;
    handles.PlotHandles{8} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end


% Plot continuous ROI lines
if handles.PlotInclude(25)==1 && handles.PlotContinuous(25)==1
    px = repmat(handles.ROILim(1),1,length(y1));
    handles.PlotHandles{25} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end
if handles.PlotInclude(26)==1 && handles.PlotContinuous(26)==1
    px = repmat(handles.ROILim(2),1,length(y1));
    handles.PlotHandles{26} = plot(reshape(repmat(px,2,1),1,2*length(px)),ys);
end


if get(handles.check_HoldOn,'value')==0 || handles.SkippingSort == 1
    ylim([min([y1(1) y2(1)]) max([y1(end) y2(end)])]);
    yl = ylim;

    if handles.HistShow(1) == 1
        h = handles.AxisPosRaster(4);
    else
        h = handles.AxisPosPSTH(4) + handles.AxisPosPSTH(2) - handles.AxisPosRaster(2);
    end
    if handles.HistShow(2) == 1
        w = handles.AxisPosRaster(3);
    else
        w = handles.AxisPosHist(3) + handles.AxisPosHist(1) - handles.AxisPosRaster(1);
    end
    pos = get(handles.axes_Raster,'position');
    pos(3) = w;
    pos(4) = h;
    set(handles.axes_Raster,'position',pos);

    if get(handles.radio_TickInches,'value')==1
        bck = get(handles.axes_Raster,'units');
        set(handles.axes_Raster,'units','inches');
        pos = get(handles.axes_Raster,'position');
        if get(handles.radio_YTrial,'value')==1
            hg = (100-handles.PlotOverlap)/100*handles.PlotTickSize(3)*range(yl);
        else
            hg = handles.PlotInPerSec*range(yl);
        end
        pos(4) = hg;
        set(handles.axes_Raster,'position',pos);
        set(handles.axes_Raster,'units',bck);
    end

    pos = get(handles.axes_Raster,'position');
    h = pos(4);
    pos = get(handles.axes_Hist,'position');
    pos(4) = h;
    set(handles.axes_Hist,'position',pos);


    if get(handles.check_CopyWindow,'value')==1 && get(handles.check_LockLimits,'value')==0
        yl_back = ylim;
        axis tight
        handles.PlotXLim = xlim;
        if get(handles.popup_StartReference,'value') == get(handles.popup_TriggerAlignment,'value')+2 || (~isempty(handles.WarpPoints) && get(handles.popup_StartReference,'value')==6)
            if get(handles.popup_StartReference,'value')==6
                handles.PlotXLim(1) = newwarp(1)-handles.P.preStartRef;
            else
                handles.PlotXLim(1) = -handles.P.preStartRef;
            end
        end
        if get(handles.popup_StopReference,'value') == get(handles.popup_TriggerAlignment,'value') || (~isempty(handles.WarpPoints) && get(handles.popup_StopReference,'value')==6)
            if get(handles.popup_StopReference,'value')==6
                handles.PlotXLim(2) = newwarp(end)+handles.P.postStopRef;
            else
                handles.PlotXLim(2) = handles.P.postStopRef;
            end
        end
        ylim(yl_back);
    end

if handles.PlotXLim(2) <= handles.PlotXLim(1)
    handles.PlotXLim = [-0.1 0.1];
    warndlg('Invalid time axis limits. Limits automatically set to [-0.1 0.1].','Warning');
end
    xlim([handles.PlotXLim(1)-eps handles.PlotXLim(2)]);
    box on;
    
    if handles.PlotInclude(21)==1
        xl = xlim;
        xcorr = [xl(1) xl(2) xl(2) xl(1)]';
        set(handles.PlotHandles{21},'xdata',repmat(xcorr,1,length(y1)));
    end
    
    if handles.PlotInclude(27)==1
        xl = xlim;
        xl(1) = max([handles.ROILim(1) xl(1)]);
        xl(2) = min([handles.ROILim(2) xl(2)]);
        xcorr = [xl(1) xl(2) xl(2) xl(1)]';
        set(handles.PlotHandles{27},'xdata',repmat(xcorr,1,length(y1)));
    end

    str = get(handles.popup_TriggerType,'string');
    str = str{get(handles.popup_TriggerType,'value')};
    if get(handles.radio_YTrial,'value')==1
        ylabel([str(1:end-1) ' number']);
    else
        ylabel([str(1:end-1) ' time (sec)']);
    end

    str2 = get(handles.popup_TriggerAlignment,'string');
    str2 = str2{get(handles.popup_TriggerAlignment,'value')};
    xlabel(['Time relative to ' lower(str(1:end-1)) ' ' lower(str2) ' (sec)']);
end


% Plot PSTH
subplot(handles.axes_PSTH);
if get(handles.check_HoldOn,'value')==0 || handles.SkippingSort == 1
    cla;
end

if handles.HistShow(1)==1
    binsize = range(handles.PlotXLim)/ceil(range(handles.PlotXLim)/handles.PSTHBinSize);
    if handles.PlotInclude(13)==1 || handles.PlotInclude(14)==1
        cla;
        hold on;
        str = get(handles.popup_PSTHCount,'string');
        xs = handles.PlotXLim(1):binsize:handles.PlotXLim(2);

        str_unit = get(handles.popup_PSTHUnits,'string');
        str_unit = str_unit{get(handles.popup_PSTHUnits,'value')};

        counts = zeros(length(xs)-1,1);

        if strcmp(get(handles.popup_EventType,'enable'),'on')
            if isempty(handles.WarpPoints) || ~strcmp(str_unit,'Rate (Hz)')
                nindx1 = 1;
                nindx2 = length(evx1);
            else
                nindx1 = indx1;
                nindx2 = indx2;
            end
            cnt = zeros(length(xs)-1,1);
            for tNum = 1:length(nindx1)
                if nindx2(tNum)>=nindx1(tNum)
                    switch str{get(handles.popup_PSTHCount,'value')}
                        case 'Onsets'
                            cnt = histc(evx1(nindx1(tNum):nindx2(tNum)),xs);
                            cnt = cnt(1:end-1);
                        case 'Offsets'
                            cnt = histc(evx2(nindx1(tNum):nindx2(tNum)),xs);
                            cnt = cnt(1:end-1);
                        case 'Full duration'
                            for j = 1:length(xs)-1
                                cnt(j,1) = length(find(evx1(nindx1(tNum):nindx2(tNum))<xs(j+1) & evx2(nindx1(tNum):nindx2(tNum))>xs(j)));
                            end
                    end
                    if ~isempty(handles.WarpPoints) && strcmp(str_unit,'Rate (Hz)')
                        for j = 1:length(newwarp)-1
                            f = find((xs(1:end-1)+xs(2:end))/2>=newwarp(j) & (xs(1:end-1)+xs(2:end))/2<newwarp(j+1));
                            cnt(f) = cnt(f)*stretch(tNum,j);
                        end
                    end
                    if size(cnt,1)==size(counts,2)
                        cnt = cnt';
                    end
                    counts = counts + cnt;
                end
            end
        else
            for tNum = 1:length(triggerInfo.eventOnsets)
                for j = 1:length(xs)-1
                    f = find(triggerInfo.eventOnsets{tNum}<xs(j+1) & triggerInfo.eventOnsets{tNum}>xs(j));
                    if strcmp(get(handles.menu_LogScale,'checked'),'on')
                        counts(j) = counts(j) + log10(sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps)+eps);
                    else
                        counts(j) = counts(j) + sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps);
                    end
                end
            end
        end

        counts = smooth(counts,handles.PSTHSmoothingWindow);

        numtrials = zeros(length(xs)-1,1);
        for c = find(handles.TriggerSelection==1)
            for d = 1:length(triggerInfo.dataStart{c})
                numtrials = numtrials + (xs(2:end)>triggerInfo.dataStart{c}(d) & xs(1:end-1)<triggerInfo.dataStop{c}(d))';
            end
        end
        numtrials(numtrials==0) = inf;

        switch str_unit
            case 'Rate (Hz)'
                counts = counts ./ numtrials / binsize;
            case 'Total count'
                % Do nothing
            case {'Count per trial','Average'}
                counts = counts ./ numtrials;
        end

        xs = handles.PlotXLim(1):binsize:handles.PlotXLim(2);
        if handles.PlotInclude(14)==1
            bx = [xs; xs];
            bx = reshape(bx,1,numel(bx));
            bc = [counts'; counts'];
            bc = reshape(bc,1,numel(bc));
            bc = [0 bc 0];
            handles.PlotHandles{14} = patch(bx,bc,'w');
        end
        if handles.PlotInclude(13)==1
            cnts = reshape(repmat(counts',2,1),2*length(counts),1);
            xcorr = reshape(repmat(xs,2,1),2*length(xs),1);
            xcorr = xcorr(2:end-1);
            handles.PlotHandles{13} = plot(xcorr,cnts);
        end

        if get(handles.radio_PSTHAuto,'value')==1
            axis tight
            yl = ylim;
            ylim([yl(1) yl(1)+(yl(2)-yl(1))*1.05]);
        else
            if strcmp(get(handles.popup_EventType,'enable'),'on')
                ylim(handles.PSTHYLim(get(handles.popup_PSTHUnits,'value'),:));
            else
                ylim(handles.PSTHYLim(get(handles.popup_PSTHUnits,'value')+3,:));
            end
        end

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            if strcmp(get(handles.menu_LogScale,'checked'),'on')
                if length(triggerInfo.contLabel) > 1
                    triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
                end
                str_unit = [str_unit ' log'];
            end
            if length(triggerInfo.contLabel) > 1
                triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
            end
            str_unit = [str_unit ' ' triggerInfo.contLabel];
        end
        ylabel(str_unit);
    end

    if handles.PlotInclude(20)==1
        delete(handles.PlotHandles{20}(ishandle(handles.PlotHandles{20})));
        hold on
        if ~isempty(handles.WarpPoints)
            handles.PlotHandles{20} = line(repmat(newwarp,2,1),repmat(ylim',1,length(newwarp)));
        end
    end

    if handles.PlotInclude(15)==1
        delete(handles.PlotHandles{15}(ishandle(handles.PlotHandles{15})));
        hold on
        handles.PlotHandles{15} = plot([0 0],ylim);
    end
    
    if handles.PlotInclude(28)==1
        delete(handles.PlotHandles{28}(ishandle(handles.PlotHandles{28})));
        hold on
        handles.PlotHandles{28} = plot([handles.ROILim(1) handles.ROILim(1)],ylim);
    end
    if handles.PlotInclude(29)==1
        delete(handles.PlotHandles{29}(ishandle(handles.PlotHandles{29})));
        hold on
        handles.PlotHandles{29} = plot([handles.ROILim(2) handles.ROILim(2)],ylim);
    end
    if handles.PlotInclude(30)==1
        delete(handles.PlotHandles{30}(ishandle(handles.PlotHandles{30})));
        hold on
        xl = get(handles.axes_Raster,'xlim');
        xl(1) = max([handles.ROILim(1) xl(1)]);
        xl(2) = min([handles.ROILim(2) xl(2)]);
        handles.PlotHandles{30} = patch([xl(1) xl(2) xl(2) xl(1)],reshape([ylim; ylim],1,4),'w');
    end
    

    xlim([handles.PlotXLim(1)-eps handles.PlotXLim(2)]);
    set(gca,'xtick',[]);
end


% Plot vertical histogram
subplot(handles.axes_Hist);
if get(handles.check_HoldOn,'value')==0 || handles.SkippingSort == 1
    cla;
end
if handles.HistShow(2)==1
    if handles.PlotInclude(16)==1 || handles.PlotInclude(17)==1 || handles.PlotInclude(18)==1
        cla;
        hold on;
    end
    if get(handles.radio_YTrial,'value')==1
        binsize = range([y1 y2])/ceil(range([y1 y2])/handles.HistBinSize(1));
    else
        binsize = range([y1 y2])/ceil(range([y1 y2])/handles.HistBinSize(2));
    end
    
    if handles.PlotInclude(18)==1
        bx = ys([1 2:2:end]);
        xl = xlim;
        handles.PlotHandles{18} = patch(repmat([xl(1) xl(2) xl(2) xl(1)]',1,length(bx)-1),[bx(1:end-1); bx(1:end-1); bx(2:end); bx(2:end)],ones(1,length(bx)-1,3));
    end
    
    if handles.PlotInclude(16)==1 || handles.PlotInclude(17)==1
        str = get(handles.popup_HistCount,'string');
        xs = min([y1 y2]):binsize:max([y1 y2]);

        str_unit = get(handles.popup_HistUnits,'string');
        str_unit = str_unit{get(handles.popup_HistUnits,'value')};

        counts = zeros(length(xs)-1,1);

        if strcmp(get(handles.popup_EventType,'enable'),'on')
            cnt = zeros(1,length(y1));
            for tNum = 1:length(cnt)
                f = indx1(tNum):indx2(tNum);
                switch str_unit
                    case {'Fraction of time','Time per trial (sec)','Total time (sec)'}
                        cnt(tNum) = 0;
                        if strcmp(str{get(handles.popup_HistCount,'value')},'Onsets') || strcmp(str{get(handles.popup_HistCount,'value')},'Offsets')
                            % do nothing
                        else
                            for j = 1:length(triggerInfo.dataStart{tNum})
                                g = find(evx1(f)>=triggerInfo.dataStart{tNum}(j) & evx1(f)<=triggerInfo.dataStop{tNum}(j));
                                g = intersect(g,find(evx2(f)>=triggerInfo.dataStart{tNum}(j) & evx2(f)<=triggerInfo.dataStop{tNum}(j)));
                                st = evx1(f(g));
                                en = evx2(f(g));
                                h1 = find(st<handles.ROILim(1));
                                st(h1) = handles.ROILim(1);
                                h2 = find(en>handles.ROILim(2));
                                en(h2) = handles.ROILim(2);
                                if strcmp(str{get(handles.popup_HistCount,'value')},'Events, excluding partial')
                                    st(intersect(h1,h2)) = [];
                                    en(intersect(h1,h2)) = [];
                                end
                                st(st<triggerInfo.dataStart{tNum}(j)) = triggerInfo.dataStart{tNum}(j);
                                en(st>triggerInfo.dataStop{tNum}(j)) = triggerInfo.dataStop{tNum}(j);
                                g = find(en>st);
                                st = st(g);
                                en = en(g);
                                toadd = sum(en-st);
                                if ~isempty(handles.WarpPoints)
                                    g = find((st+en)/2 >= newwarp(1:end-1) & (st+en)/2 <= newwarp(2:end));
                                    if ~isempty(g)
                                        toadd = toadd/stretch(tNum,g);
                                    end
                                end
                                cnt(tNum) = cnt(tNum) + toadd;
                            end
                        end
                    otherwise
                        switch str{get(handles.popup_HistCount,'value')}
                            case 'Onsets'
                                cnt(tNum) = length(find(evx1(f)>=handles.ROILim(1) & evx1(f)<=handles.ROILim(2)));
                            case 'Offsets'
                                cnt(tNum) = length(find(evx2(f)>=handles.ROILim(1) & evx2(f)<=handles.ROILim(2)));
                            case 'Events, including partial'
                                cnt(tNum) = length(f) - length(find((evx1(f)<handles.ROILim(1) & evx2(f)<handles.ROILim(1)) | (evx1(f)>handles.ROILim(2) & evx2(f)>handles.ROILim(2))));
                            case 'Events, excluding partial'
                                cnt(tNum) = length(find(evx1(f)>=handles.ROILim(1) & evx1(f)<=handles.ROILim(2) & evx2(f)>=handles.ROILim(1) & evx2(f)<=handles.ROILim(2)));
                        end
                end
            end
        else
            cnt = zeros(1,length(y1));
            for tNum = 1:length(cnt)
                f = find(triggerInfo.eventOnsets{tNum}>=handles.ROILim(1) & triggerInfo.eventOnsets{tNum}<=handles.ROILim(2));
                if strcmp(get(handles.menu_LogScale,'checked'),'on')
                    cnt(tNum) = cnt(tNum) + log10(sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps)+eps);
                else
                    cnt(tNum) = cnt(tNum) + sum(triggerInfo.eventLabels{tNum}(f))/(length(f)+eps);
                end
            end
        end
        
        switch str_unit
            case {'Rate (Hz)','Fraction of time'}
                totdur = zeros(size(cnt));
                for tNum = 1:length(cnt)
                    for j = 1:length(triggerInfo.dataStart{tNum})
                        st = max([triggerInfo.dataStart{tNum}(j) handles.ROILim(1)]);
                        en = min([triggerInfo.dataStop{tNum}(j) handles.ROILim(2)]);
                        toadd = max([0 en-st]);
                        if ~isempty(handles.WarpPoints)
                            f = find((st+en)/2 >= newwarp(1:end-1) & (st+en)/2 <= newwarp(2:end));
                            if ~isempty(f)
                                toadd = toadd/stretch(tNum,f(1));
                            end
                        end
                        totdur(tNum) = totdur(tNum) + toadd;
                    end
                end
                cnt = cnt ./ (totdur+eps);
            case {'Total count','Count per trial','Time per trial (sec)','Total time (sec)','Average'}
                % Do nothing
        end
        
        numtrials = zeros(size(counts));
        for bn = 1:length(counts)
            f = find(y1>=xs(bn) & y1<xs(bn+1));
            counts(bn) = sum(cnt(f));
            numtrials(bn) = length(f);
        end

        counts = smooth(counts,handles.HistSmoothingWindow);
        
        
        switch str_unit
            case {'Rate (Hz)','Count per trial','Fraction of time','Time per trial (sec)','Average'}
                counts(numtrials==0)=0;
                numtrials(numtrials==0)=eps;
                counts = counts ./ numtrials;
            case {'Total count','Total time (sec)'}
                % Do nothing
        end
        
        bx = ys([1 2:2:end]);
        bc = zeros(1,length(y1));
        for bn = 1:length(counts)
            f = find(y1>=xs(bn) & y1<xs(bn+1));
            bc(f) = counts(bn);
        end

        
        if handles.PlotInclude(17)==1
            handles.PlotHandles{17} = patch([zeros(size(bc)); bc; bc; zeros(size(bc))],[bx(1:end-1); bx(1:end-1); bx(2:end); bx(2:end)],ones(1,length(bc),3));
        end
        if handles.PlotInclude(16)==1
            handles.PlotHandles{16} = plot(reshape(repmat(bc,2,1),1,length(bc)*2),ys);
        end

        if get(handles.radio_PSTHAuto,'value')==1
            axis tight
            xl = xlim;
            xlim([xl(1) xl(1)+(xl(2)-xl(1))*1.05]);
        else
            if strcmp(get(handles.popup_EventType,'enable'),'on')
                xlim(handles.HistYLim(get(handles.popup_HistUnits,'value'),:));
            else
                xlim(handles.HistYLim(get(handles.popup_HistUnits,'value')+3,:));
            end
        end
        
        xl = xlim;
        if ~isempty(handles.PlotHandles{18})
            xd = get(handles.PlotHandles{18},'xdata');
            xd = repmat([xl(1) xl(2) xl(2) xl(1)]',1,size(xd,2));
            set(handles.PlotHandles{18},'xdata',xd);
        end

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            if strcmp(get(handles.menu_LogScale,'checked'),'on')
                if length(triggerInfo.contLabel) > 1
                    triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
                end
                str_unit = [str_unit ' log'];
            end
            if length(triggerInfo.contLabel) > 1
                triggerInfo.contLabel(1) = lower(triggerInfo.contLabel(1));
            end
            str_unit = [str_unit ' ' triggerInfo.contLabel];
        end
        xlabel(str_unit);
        ylim(get(handles.axes_Raster,'ylim'));
    end
end



% Format events
for c = [1 2 4 5 7 8 10 11 13 15 16 19 20 22 23 25 26 28 29] % line plots
    if iscell(handles.PlotHandles{c})
        set(handles.PlotHandles{c}{end},'color',handles.PlotColor(c,:));
        set(handles.PlotHandles{c}{end},'linewidth',handles.PlotLineWidth(c));
    else
        set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
        set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
    end
end
for c = [14 30] % Single patch
    drawnow
    set(handles.PlotHandles{c},'facecolor',handles.PlotColor(c,:),'edgecolor','none');
    set(handles.PlotHandles{c},'facealpha',handles.PlotAlpha(c));
end

for c = [3 6 9 12 17 18 21 24 27] % sets of patches
    if iscell(handles.PlotHandles{c})
        h = handles.PlotHandles{c}{end};
    else
        h = handles.PlotHandles{c};
    end
    if ~isempty(h)
        drawnow;
        sz = get(h,'cdata');
        if ~isempty(sz)
            sz = size(sz);
            sz = sz(1:2);
            set(h,'cdata',cat(3,handles.PlotColor(c,1)*ones(sz),handles.PlotColor(c,2)*ones(sz),handles.PlotColor(c,3)*ones(sz)));
        else
            set(h,'facecolor',handles.PlotColor(c,:));
        end
        set(h,'edgecolor','none');
        if handles.PlotAlpha(c)<1
            set(h,'facealpha',handles.PlotAlpha(c));
        end
    end
end

set(handles.text_Info,'string','');

set(handles.axes_PSTH,'color',handles.BackgroundColor);
set(handles.axes_Hist,'color',handles.BackgroundColor);
set(handles.axes_Raster,'color',handles.BackgroundColor);


drawnow;
set(handles.push_GenerateRaster,'foregroundcolor','k');

handles.triggerInfo = triggerInfo;
handles.PlotInclude = bck_inc;

handles.BackupXLimRaster = get(handles.axes_Raster,'xlim');
handles.BackupYLimRaster = get(handles.axes_Raster,'ylim');
handles.BackupYLimPSTH = get(handles.axes_PSTH,'ylim');
handles.BackupXLimHist = get(handles.axes_Hist,'xlim');

set(handles.axes_Raster,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))');
ch = get(handles.axes_Raster,'children');
for c = 1:length(handles.PlotHandles)
    if handles.PlotContinuous(c) < 1
        if iscell(handles.PlotHandles{c})
            for d = 1:length(handles.PlotHandles{c})
                h = intersect(ch,handles.PlotHandles{c}{d});
                set(h,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))')
            end
        else
            h = intersect(ch,handles.PlotHandles{c});
            set(h,'buttondownfcn','egm_Sorted_rasters(''click_Raster'',gcbo,[],guidata(gcbo))')
        end
    end
end

set(handles.axes_PSTH,'buttondownfcn','egm_Sorted_rasters(''click_PSTH'',gcbo,[],guidata(gcbo))');
set(get(handles.axes_PSTH,'children'),'buttondownfcn','egm_Sorted_rasters(''click_PSTH'',gcbo,[],guidata(gcbo))');
set(handles.axes_Hist,'buttondownfcn','egm_Sorted_rasters(''click_Hist'',gcbo,[],guidata(gcbo))');
set(get(handles.axes_Hist,'children'),'buttondownfcn','egm_Sorted_rasters(''click_Hist'',gcbo,[],guidata(gcbo))');

handles.SkippingSort = 0;
warning on
guidata(hObject, handles);


function [triggerInfo, EventFilters] = GetTriggerAlignedEvents(handles,trig,event,warp_points,EventFilters)
% Aligns events to triggers

count = 0;
triggerInfo = [];
for c = 1:length(trig.on)
    if ~isempty(trig.on{c}) && strcmp(get(handles.popup_EventType,'enable'),'off')
        val = get(handles.popup_EventSource,'value')-1;
        axnum = val - length(handles.egh.EventTimes);
        if get(handles.egh.popup_Channel1,'value')==1
            axnum = 2;
        end
        [funct, triggerInfo.contLabel, fxs] = getContinuousFunction(handles,trig.info.filenum(c),axnum,1);
    end
    
    corr_ax = get(handles.popup_Correlation,'value')-1;
    if corr_ax > 0
        if get(handles.egh.popup_Channel1,'value')==1
            corr_ax = 2;
        end
        [cfunct, lab, cxs] = getContinuousFunction(handles,trig.info.filenum(c),corr_ax,0);
        if ~isempty(cfunct)
            cfunct = cfunct-mean(cfunct);
            cfunct = cfunct/norm(cfunct);
        end
    end
        
        
    
    for d = 1:length(trig.on{c})
        str = get(handles.popup_TriggerAlignment,'string');
        switch str{get(handles.popup_TriggerAlignment,'value')} % Determine trigger position
            case 'Onset'
                algn = trig.on{c}(d);
            case 'Midpoint'
                algn = round((trig.on{c}(d)+trig.off{c}(d))/2);
            case 'Offset'
                algn = trig.off{c}(d);
        end
        absTime = handles.egh.DatesAndTimes(trig.info.filenum(c)) + algn/(handles.egh.fs*24*60*60);
        
        str = get(handles.popup_StartReference,'string');
        switch str{get(handles.popup_StartReference,'value')} % Determine window start
            case 'Previous onset'
                if d==1
                    bef = -inf;
                else
                    bef = trig.on{c}(d-1);
                end
            case 'Previous offset'
                if d==1
                    bef = -inf;
                else
                    bef = trig.off{c}(d-1);
                end
            case 'Current onset'
                bef = trig.on{c}(d);
            case 'Current midpoint'
                bef = (trig.on{c}(d)+trig.off{c}(d))/2;
            case 'Current offset'
                bef = trig.off{c}(d);
            case 'First warp point'
                f = find(warp_points{c}<absTime);
                if length(f) < handles.WarpNumBefore
                    bef = -inf;
                else
                    if handles.WarpNumBefore > 0
                        tm = warp_points{c}(f(end-handles.WarpNumBefore+1));
                        bef = (tm - handles.egh.DatesAndTimes(trig.info.filenum(c))) * (handles.egh.fs*24*60*60);
                    else
                        bef = algn;
                    end
                end
        end

        str = get(handles.popup_StopReference,'string');
        switch str{get(handles.popup_StopReference,'value')} % Determine window end
            case 'Current onset'
                aft = trig.on{c}(d);
            case 'Current midpoint'
                aft = (trig.on{c}(d)+trig.off{c}(d))/2;
            case 'Current offset'
                aft = trig.off{c}(d);
            case 'Next onset'
                if d==length(trig.on{c})
                    aft = inf;
                else
                    aft = trig.on{c}(d+1);
                end
            case 'Next offset'
                if d==length(trig.on{c})
                    aft = inf;
                else
                    aft = trig.off{c}(d+1);
                end
            case 'Last warp point'
                f = find(warp_points{c}>absTime);
                if length(f) < handles.WarpNumAfter
                    aft = inf;
                else
                    if handles.WarpNumAfter > 0
                        tm = warp_points{c}(f(handles.WarpNumAfter));
                        aft = (tm - handles.egh.DatesAndTimes(trig.info.filenum(c))) * (handles.egh.fs*24*60*60);
                    else
                        aft = algn;
                    end
                end
        end

        bef = round(bef - handles.P.preStartRef*handles.egh.fs);
        aft = round(aft + handles.P.postStopRef*handles.egh.fs);

        if bef < 1 || aft > handles.egh.FileLength(trig.info.filenum(c))
            if get(handles.check_ExcludeIncomplete,'value') == 1
                continue % Skip incomplete trigger
            end
            comp = 0;
        else
            comp = 1;
        end

        bef = max([bef 1]);
        aft = min([aft handles.egh.FileLength(trig.info.filenum(c))]);

        count = count + 1;

        if corr_ax > 0
            indx = find(cxs>=bef & cxs<=aft);
            if isempty(indx)
                triggerInfo.corrShift(count) = 0;
            else
                ons = (cxs(indx(1))-algn)'/handles.egh.fs;
                cval = cfunct(indx);
                if exist('ref_ons','var')
                    [cx, lags] = xcorr(cval,ref_cval);
                    f = find(abs(lags/handles.egh.fs)<handles.corrMax);
                    cx = cx(f);
                    lags = lags(f);
                    [mx, f] = max(cx);
                    triggerInfo.corrShift(count) = lags(f)/handles.egh.fs + (ons-ref_ons);
                else
                    triggerInfo.corrShift(count) = 0;
                    ref_ons = ons;
                    ref_cval = cval;
                end
            end
        else
            triggerInfo.corrShift(count) = 0;
        end

        algn = algn + triggerInfo.corrShift(count)*handles.egh.fs;

        triggerInfo.fileNum(count) = c;
        triggerInfo.isComplete(count) = comp;
        triggerInfo.absTime(count) = absTime;
        triggerInfo.label(count) = trig.info.label{c}(d);
        triggerInfo.dataStart{count} = (bef-algn)/handles.egh.fs+eps;
        triggerInfo.dataStop{count} = (aft-algn)/handles.egh.fs-eps;
        if d==1
            triggerInfo.prevTrigOnset(count) = -inf;
            triggerInfo.prevTrigOffset(count) = -inf;
        else
            triggerInfo.prevTrigOnset(count) = (trig.on{c}(d-1)-algn)/handles.egh.fs;
            triggerInfo.prevTrigOffset(count) = (trig.off{c}(d-1)-algn)/handles.egh.fs;
        end
        triggerInfo.currTrigOnset(count) = (trig.on{c}(d)-algn)/handles.egh.fs;
        triggerInfo.currTrigOffset(count) = (trig.off{c}(d)-algn)/handles.egh.fs;
        if d==length(trig.on{c})
            triggerInfo.nextTrigOnset(count) = inf;
            triggerInfo.nextTrigOffset(count) = inf;
        else
            triggerInfo.nextTrigOnset(count) = (trig.on{c}(d+1)-algn)/handles.egh.fs;
            triggerInfo.nextTrigOffset(count) = (trig.off{c}(d+1)-algn)/handles.egh.fs;
        end
        
        
        % Filter triggers
        ff = [];
        ff(1) = (triggerInfo.currTrigOffset(count)-triggerInfo.currTrigOnset(count)>=handles.P.filter(1,1) & triggerInfo.currTrigOffset(count)-triggerInfo.currTrigOnset(count)<=handles.P.filter(1,2));
        ff(2) = (triggerInfo.prevTrigOnset(count)>=handles.P.filter(2,1) & triggerInfo.prevTrigOnset(count)<=handles.P.filter(2,2));
        ff(3) = (triggerInfo.prevTrigOffset(count)>=handles.P.filter(3,1) & triggerInfo.prevTrigOffset(count)<=handles.P.filter(3,2));
        ff(4) = (triggerInfo.nextTrigOnset(count)>=handles.P.filter(4,1) & triggerInfo.nextTrigOnset(count)<=handles.P.filter(4,2));
        ff(5) = (triggerInfo.nextTrigOffset(count)>=handles.P.filter(5,1) & triggerInfo.nextTrigOffset(count)<=handles.P.filter(5,2));     
        
        f = prod(ff);
        if f == 0
            fields = fieldnames(triggerInfo);
            for j = 1:length(fields)
                fld = triggerInfo.(fields{j});
                if ~strcmp(fields{j},'contLabel') && length(fld)==count
                    fld = triggerInfo.(fields{j});
                    fld(count) = [];
                    triggerInfo.(fields{j}) = fld;
                end
            end
            count = count - 1;
            continue
        end
       
        
        if strcmp(get(handles.popup_EventType,'enable'),'on')
            if get(handles.check_ExcludePartialEvents,'value') == 1
                f = find(event.on{c}>bef & event.off{c}<aft);
            else
                f1 = find(event.on{c}>bef & event.on{c}<aft);
                f2 = find(event.off{c}>bef & event.off{c}<aft);
                f3 = find(event.on{c}<bef & event.off{c}>aft);
                f = union(f1,f2);
                f = union(f,f3);
            end
            triggerInfo.eventOnsets{count} = (event.on{c}(f)-algn)/handles.egh.fs;
            triggerInfo.eventOffsets{count} = (event.off{c}(f)-algn)/handles.egh.fs;
            triggerInfo.eventLabels{count} = (event.info.label{c}(f))/handles.egh.fs;
        else
            indx = find(fxs>=bef & fxs<=aft);
            triggerInfo.eventOnsets{count} = (fxs(indx)-algn)'/handles.egh.fs;
            triggerInfo.eventOffsets{count} = [];
            triggerInfo.eventLabels{count} = funct(indx);
        end
        
        % Filter triggers based on events
        ff = [];
        
        fval = -inf;
        f = find(triggerInfo.eventOnsets{count}<0);
        if ~isempty(f)
            fval = triggerInfo.eventOnsets{count}(f(end));
        end
        ff(1) = (fval>=handles.P.filter(6,1) & fval<=handles.P.filter(6,2));

        fval = -inf;
        f = find(triggerInfo.eventOffsets{count}<0);
        if ~isempty(f)
            fval = triggerInfo.eventOffsets{count}(f(end));
        end
        ff(2) = (fval>=handles.P.filter(7,1) & fval<=handles.P.filter(7,2));

        fval = inf;
        f = find(triggerInfo.eventOnsets{count}>0);
        if ~isempty(f)
            fval = triggerInfo.eventOnsets{count}(f(1));
        end
        ff(3) = (fval>=handles.P.filter(8,1) & fval<=handles.P.filter(8,2));

        fval = inf;
        f = find(triggerInfo.eventOffsets{count}>0);
        if ~isempty(f)
            fval = triggerInfo.eventOffsets{count}(f(1));
        end
        ff(4) = (fval>=handles.P.filter(9,1) & fval<=handles.P.filter(9,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOnsets{count});
            fval = min(triggerInfo.eventOnsets{count});
        end
        ff(5) = (fval>=handles.P.filter(10,1) & fval<=handles.P.filter(10,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOffsets{count});
            fval = min(triggerInfo.eventOffsets{count});
        end
        ff(6) = (fval>=handles.P.filter(11,1) & fval<=handles.P.filter(11,2));
        
        fval = inf;
        if ~isempty(triggerInfo.eventOnsets{count});
            fval = max(triggerInfo.eventOnsets{count});
        end
        ff(7) = (fval>=handles.P.filter(12,1) & fval<=handles.P.filter(12,2));

        fval = inf;
        if ~isempty(triggerInfo.eventOffsets{count});
            fval = max(triggerInfo.eventOffsets{count});
        end
        ff(8) = (fval>=handles.P.filter(13,1) & fval<=handles.P.filter(13,2));
        
        fval = length(triggerInfo.eventOnsets{count});
        ff(9) = (fval>=handles.P.filter(14,1) & fval<=handles.P.filter(14,2));
        
        fval = (length(find(triggerInfo.eventOnsets{count}<=0)) > length(find(triggerInfo.eventOffsets{count}<0)));
        ff(10) = (fval>=handles.P.filter(15,1) & fval<=handles.P.filter(15,2));
        
        if get(handles.check_HoldOn,'value')==0
            f = prod(ff);
            EventFilters{c}(d) = f;
        else
            f = EventFilters{c}(d);
        end
        if f == 0
            fields = fieldnames(triggerInfo);
            for j = 1:length(fields)
                fld = triggerInfo.(fields{j});
                if ~strcmp(fields{j},'contLabel') && length(fld)==count
                    fld = triggerInfo.(fields{j});
                    fld(count) = [];
                    triggerInfo.(fields{j}) = fld;
                end
            end
            count = count - 1;
            continue
        end
    end
end



function [triggerInfo, ord] = SortTriggers(triggerInfo,type,descend,inc,group_labels)
% Sorts triggers according to the specifications

switch type
    case 'Absolute time'
        srt = triggerInfo.absTime;
    case 'Trigger duration'
        srt = triggerInfo.currTrigOffset-triggerInfo.currTrigOnset;
    case 'Previous trigger onset'
        srt = -triggerInfo.prevTrigOnset;
    case 'Previous trigger offset'
        srt = -triggerInfo.prevTrigOffset;
    case 'Next trigger onset'
        srt = triggerInfo.nextTrigOnset;
    case 'Next trigger offset'
        srt = triggerInfo.nextTrigOffset;
    case 'Trigger label'
        srt = triggerInfo.label;
        if max(srt) && ~isempty(inc)
            f = strfind(inc,'''''');
            inc = double(inc);
            if ~isempty(f)
                inc(f+1) = [];
                inc(f) = 0;
            end
           [dummy ord] = sort(inc);
           for c = 1:length(inc)
               srt(srt==inc(c)) = 1000+c;
           end
        end                
    case 'Preceding event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOnsets{c}<0);
            if ~isempty(f)
                srt(c) = -triggerInfo.eventOnsets{c}(f(end));
            end
        end
    case 'Preceding event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOffsets{c}<0);
            if ~isempty(f)
                srt(c) = -triggerInfo.eventOffsets{c}(f(end));
            end
        end
    case 'Following event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOnsets{c}>0);
            if ~isempty(f)
                srt(c) = triggerInfo.eventOnsets{c}(f(1));
            end
        end
    case 'Following event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            f = find(triggerInfo.eventOffsets{c}>0);
            if ~isempty(f)
                srt(c) = triggerInfo.eventOffsets{c}(f(1));
            end
        end
    case 'First event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOnsets{c});
                srt(c) = min(triggerInfo.eventOnsets{c});
            end
        end
    case 'First event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOffsets{c});
                srt(c) = min(triggerInfo.eventOffsets{c});
            end
        end
    case 'Last event onset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOnsets{c});
                srt(c) = max(triggerInfo.eventOnsets{c});
            end
        end
    case 'Last event offset'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            if ~isempty(triggerInfo.eventOffsets{c});
                srt(c) = max(triggerInfo.eventOffsets{c});
            end
        end
    case 'Number of events'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            srt(c) = length(triggerInfo.eventOnsets{c});
        end
    case 'Is in event'
        srt = inf*ones(size(triggerInfo.absTime));
        for c = 1:length(srt)
            srt(c) = (length(find(triggerInfo.eventOnsets{c}<=0)) > length(find(triggerInfo.eventOffsets{c}<0)));
        end
end

[srt, ord] = sort(srt);
if descend == 1
    ord = ord(end:-1:1);
end

if group_labels == 1
    labs = unique(triggerInfo.label);
    srt = zeros(size(triggerInfo.label));
    for c = 1:length(labs)
        srt(triggerInfo.label==labs(c)) = mean(find(triggerInfo.label(ord)==labs(c)));
    end
    [srt, ord] = sort(srt);
end

fields = fieldnames(triggerInfo);
for c = 1:length(fields)
    if ~strcmp(fields{c},'contLabel')
        fld = triggerInfo.(fields{c});
        fld = fld(ord);
        triggerInfo.(fields{c}) = fld;
    end
end



function [ons, offs, inform, lst] = GetEventStructure(handles,indx,str,P)
% Generates a structure with the list of all events

lst = handles.FileRange;
if get(handles.popup_Files,'value')>1 % all files
    fls = get(handles.egh.list_Files,'string');
    found = [];
    for c = 1:handles.egh.TotalFileNumber
        if strcmp(fls{c}(19),'F')
            found = [found c];
        end
    end
    if get(handles.popup_Files,'value')==2 % Selected files
        lst = intersect(lst,found);
    else
        lst = setdiff(lst,found);
    end
end


ons = cell(1,length(lst));
offs = cell(1,length(lst));
inform.label = cell(1,length(lst));
inform.filenum = zeros(1,length(lst));
for c = 1:length(lst)
    switch str
        case 'Events'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ons{c} = min(ev,[],2);
            offs{c} = max(ev,[],2);
            inform.label{c} = zeros(size(ev,1),1);
        case 'Bursts'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ev = min(ev,[],2);
            bon = find(handles.egh.fs./(ev(1:end-1)-[-inf; ev(1:end-2)]) <= P.burstFrequency & handles.egh.fs./(ev(2:end)-ev(1:end-1)) > (P.burstFrequency+eps));
            boff = find(handles.egh.fs./(ev(2:end)-ev(1:end-1)) > P.burstFrequency & handles.egh.fs./([ev(3:end); inf]-ev(2:end)) <= P.burstFrequency)+1;
            g = find(boff-bon>=P.burstMinSpikes-1);
            ons{c} = ev(bon(g));
            offs{c} = ev(boff(g));
            inform.label{c} = 1000+boff(g)-bon(g)+1;
        case {'Burst events','Single events'}
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            ev = min(ev,[],2);
            evoff = max(ev,[],2);
            bon = find(handles.egh.fs./(ev(1:end-1)-[-inf; ev(1:end-2)]) <= P.burstFrequency & handles.egh.fs./(ev(2:end)-ev(1:end-1)) > (P.burstFrequency+eps));
            boff = find(handles.egh.fs./(ev(2:end)-ev(1:end-1)) > P.burstFrequency & handles.egh.fs./([ev(3:end); inf]-ev(2:end)) <= P.burstFrequency)+1;
            g = find(boff-bon>=P.burstMinSpikes-1);
            
            burst_spikes = [];
            for bnum = 1:length(g)
                burst_spikes = [burst_spikes bon(g(bnum)):boff(g(bnum))];
            end

            if strcmp(str,'Burst events')
                ons{c} = ev(burst_spikes);
                offs{c} = evoff(burst_spikes);
                inform.label{c} = zeros(size(ev,1),1);
            elseif strcmp(str,'Single events')
                ons{c} = ev(setdiff(1:length(ev),burst_spikes));
                offs{c} = evoff(setdiff(1:length(ev),burst_spikes));
                inform.label{c} = zeros(size(ev,1),1);
            end           
        case 'Pauses'
            f = find(handles.egh.EventSelected{indx}{1,lst(c)}==1);
            for j = 2:size(handles.egh.EventSelected{indx},1)
                f = intersect(f,find(handles.egh.EventSelected{indx}{j,lst(c)}==1));
            end
            ev = handles.egh.EventTimes{indx}{1,lst(c)}(f);
            for d = 2:size(handles.egh.EventTimes{indx},1) % for multi-channel events
                ev = [ev handles.egh.EventTimes{indx}{d,lst(c)}(f)];
            end
            eon = [min(ev,[],2); handles.egh.FileLength(lst(c))+handles.egh.fs*P.pauseMinDuration];
            eoff = [-handles.egh.fs*P.pauseMinDuration; max(ev,[],2)];
            f = find(eon-eoff>handles.egh.fs*P.pauseMinDuration);
            ons{c} = eoff(f);
            offs{c} = eon(f);
            inform.label{c} = zeros(length(f),1);            
        case {'Syllables', 'Markers'}
            switch str
                case 'Syllables'
                    times = handles.egh.SegmentTimes{lst(c)};
                    selection = handles.egh.SegmentSelection{lst(c)};
                    titles = handles.egh.SegmentTitles{lst(c)};
                case 'Markers'
                    times = handles.egh.MarkerTimes{lst(c)};
                    selection = handles.egh.MarkerSelection{lst(c)};
                    titles = handles.egh.MarkerTitles{lst(c)};
            end
            if ~isempty(times)
                f = find(selection==1);
                ons{c} = times(f,1);
                offs{c} = times(f,2);
                lab = zeros(size(ons{c}));
                for d = 1:length(lab)
                    if ~isempty(titles{f(d)})
                        lab(d) = double(titles{f(d)});
                    end
                end
                inform.label{c} = lab;
                
                inc = P.includeSyllList;
                f = strfind(inc,'''''');
                inc([f f+1]) = [];
                inc = double(inc);
                if ~isempty(f)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    f = [];
                    for lb = 1:length(inc)
                        f = union(f,find(lab==inc(lb)));
                    end
                    ons{c} = ons{c}(f);
                    offs{c} = offs{c}(f);
                    inform.label{c} = inform.label{c}(f);
                end
                
                inc = P.ignoreSyllList;
                f = strfind(inc,'''''');
                inc([f f+1]) = [];
                inc = double(inc);
                if ~isempty(f)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    lab = inform.label{c};
                    f = [];
                    for lb = 1:length(inc)
                        f = union(f,find(lab==inc(lb)));
                    end
                    ons{c}(f) = [];
                    offs{c}(f) = [];
                    inform.label{c}(f) = [];
                end
            end
        case 'Motifs'
            if ~isempty(handles.egh.SegmentTimes{lst(c)})
                f = find(handles.egh.SegmentSelection{lst(c)}==1);
                son = handles.egh.SegmentTimes{lst(c)}(f,1);
                soff = handles.egh.SegmentTimes{lst(c)}(f,2);
                titl = handles.egh.SegmentTitles{lst(c)}(f);
                stitl = '';
                for j = 1:length(titl)
                    if strcmp(titl{j},'') || isempty(titl{j});
                        stitl = [stitl char(1)];
                    else
                        stitl = [stitl titl{j}];
                    end
                end
                ons{c} = [];
                offs{c} = [];
                inform.label{c} = [];
                for mot = 1:length(P.motifSequences)
                    [st en] = regexp(stitl,P.motifSequences{mot},'start','end');
                    for j = length(st):-1:1
                        if max(son(st(j)+1:en(j))-soff(st(j):en(j)-1)) > handles.egh.fs*P.motifInterval
                            st(j) = [];
                            en(j) = [];
                        end
                    end
                    ons{c} = [ons{c}; son(st)];
                    offs{c} = [offs{c}; soff(en)];
                    inform.label{c} = [inform.label{c}; mot*ones(length(st),1)];
                end                
                inform.label{c} = 1000+inform.label{c};
            end
        case 'Bouts'
            if ~isempty(handles.egh.SegmentTimes{lst(c)})             
                f = find(handles.egh.SegmentSelection{lst(c)}==1);
                
                lab = zeros(1,length(f));
                for d = 1:length(lab)
                    if ~isempty(handles.egh.SegmentTitles{lst(c)}{f(d)})
                        lab(d) = double(handles.egh.SegmentTitles{lst(c)}{f(d)});
                    end
                end
                
                inc = P.includeSyllList;
                g = strfind(inc,'''''');
                inc([g g+1]) = [];
                inc = double(inc);
                if ~isempty(g)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    g = [];
                    for lb = 1:length(inc)
                        g = union(g,find(lab==inc(lb)));
                    end
                end
                if ~isempty(inc)
                    f = f(g);
                end
                
                inc = P.ignoreSyllList;
                g = strfind(inc,'''''');
                inc([g g+1]) = [];
                inc = double(inc);
                if ~isempty(g)
                    inc = [inc 0];
                end
                if ~isempty(inc)
                    g = [];
                    for lb = 1:length(inc)
                        g = union(g,find(lab==inc(lb)));
                    end
                end
                if ~isempty(inc)
                    f(g) = [];
                end
                
                son = [handles.egh.SegmentTimes{lst(c)}(f,1); inf];
                soff = [-inf; handles.egh.SegmentTimes{lst(c)}(f,2)];
                f = find(son-soff>handles.egh.fs*P.boutInterval);
                bon = f(1:end-1);
                boff = f(2:end)-1;
                f = find(soff(boff+1)-son(bon)>handles.egh.fs*P.boutMinDuration);
                g = find(boff-bon>=P.boutMinSyllables-1);
                bon = bon(intersect(f,g));
                boff = boff(intersect(f,g));
                ons{c} = son(bon);
                offs{c} = soff(boff+1);
                inform.label{c} = 1000+boff-bon+1;
            end
        case 'Continuous function'
            ons{c} = [];
            offs{c} = [];
            inform.label{c} = [];
    end
    inform.filenum(c) = lst(c);
    if size(ons{c},2)==0
        ons{c} = [];
        offs{c} = [];
        inform.label{c} = [];
    end
end


% --- Executes on button press in check_ExcludeIncomplete.
function check_ExcludeIncomplete_Callback(~, ~, ~)
% hObject    handle to check_ExcludeIncomplete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ExcludeIncomplete


% --- Executes on selection change in popup_TriggerAlignment.
function popup_TriggerAlignment_Callback(hObject, ~, handles)
% hObject    handle to popup_TriggerAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_TriggerAlignment contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_TriggerAlignment

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end

handles = AutoInclude(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popup_TriggerAlignment_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_TriggerAlignment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_ExcludePartialEvents.
function check_ExcludePartialEvents_Callback(~, ~, ~)
% hObject    handle to check_ExcludePartialEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_ExcludePartialEvents


% --- Executes on selection change in list_Filter.
function list_Filter_Callback(hObject, ~, handles)
% hObject    handle to list_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_Filter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_Filter


val = get(handles.list_Filter,'value');
set(handles.edit_FilterFrom,'string',num2str(handles.P.filter(val,1)));
set(handles.edit_FilterTo,'string',num2str(handles.P.filter(val,2)));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function list_Filter_CreateFcn(hObject, ~, ~)
% hObject    handle to list_Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FilterFrom_Callback(hObject, ~, handles)
% hObject    handle to edit_FilterFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FilterFrom as text
%        str2double(get(hObject,'String')) returns contents of edit_FilterFrom as a double

val = get(handles.list_Filter,'value');
handles.P.filter(val,1) = str2double(get(handles.edit_FilterFrom,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_FilterFrom_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_FilterFrom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FilterTo_Callback(hObject, ~, handles)
% hObject    handle to edit_FilterTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FilterTo as text
%        str2double(get(hObject,'String')) returns contents of edit_FilterTo as a double


val = get(handles.list_Filter,'value');
handles.P.filter(val,2) = str2double(get(handles.edit_FilterTo,'string'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_FilterTo_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_FilterTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in list_Plot.
function list_Plot_Callback(hObject, ~, handles)
% hObject    handle to list_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_Plot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_Plot

val = get(handles.list_Plot,'value');

if strcmp(get(gcf,'selectiontype'),'open')
    if get(handles.check_HoldOn,'value')==0 || (val > 9 && val < 19) || val==20
        handles.PlotInclude(val) = 1-handles.PlotInclude(val);
    end
end

patch_obj = [3 6 9 12 14 17 18 21 24 27 30];
if ~isempty(find(patch_obj==val,1))
    set(handles.push_PlotWidth,'String','Transparency');
else
    set(handles.push_PlotWidth,'String','Width');
end

handles = updatePlotIncludeColors(handles);

set(handles.check_PlotInclude,'value',handles.PlotInclude(val));
if handles.PlotContinuous(val) == -1
    set(handles.check_PlotContinuous,'value',0,'enable','off');
else
    set(handles.check_PlotContinuous,'value',handles.PlotContinuous(val),'enable','on');
end

set(handles.check_PlotInclude,'enable','on');
if get(handles.check_HoldOn,'value')==1 && (val < 10 || val == 19 || val > 20)
    set(handles.check_PlotInclude,'enable','off');
    set(handles.check_PlotContinuous,'enable','off');
end

guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function list_Plot_CreateFcn(hObject, ~, ~)
% hObject    handle to list_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_PlotInclude.
function check_PlotInclude_Callback(hObject, ~, handles)
% hObject    handle to check_PlotInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PlotInclude

plotNum = get(handles.list_Plot,'value');
include = get(handles.check_PlotInclude,'value');

handles = setPlotInclude(handles, plotNum, include);

guidata(hObject, handles);

function handles = setPlotInclude(handles, plotNum, include)
% Set one plot include value
handles.PlotInclude(plotNum) = include;
handles = updatePlotIncludeColors(handles);

function handles = setPlotIncludes(handles, includes)
% Set all plot include values
if length(includes) ~= length(get(handles.list_Plot, 'String'))
    error('Cannot set plot include values because provided array size does not match the number of plots.');
end
handles.PlotInclude = includes;
handles = updatePlotIncludeColors(handles);

% --- Executes on button press in check_PlotContinuous.
function check_PlotContinuous_Callback(hObject, ~, handles)
% hObject    handle to check_PlotContinuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_PlotContinuous

plotNum = get(handles.list_Plot,'value');
plotContinuousVal = get(handles.check_PlotContinuous,'value');

handles = setPlotContinuous(handles, plotNum, plotContinuousVal);

guidata(hObject, handles);

function handles = setPlotContinuous(handles, plotNum, plotContinuous)
% Set the plotContinuous property for one plot
handles.PlotContinuous(plotNum) = plotContinuous;
handles = updatePlotIncludeColors(handles);

function handles = setAllPlotContinuous(handles, plotContinuous)
% Set all values for plotContinuous
if length(plotContinuous) ~= length(get(handles.list_Plot, 'String'));
    error('Cannot set plotContinuous property, because provided array size does not match the number of plots.');
end
handles.PlotContinuous = plotContinuous;
handles = updatePlotIncludeColors(handles);

function plotContinuous = getPlotContinuous(handles)
plotContinuous = handles.PlotContinuous;

function handles = updatePlotIncludeColors(handles)
% Update the plot list box text color to be red, black, or white depending on whether
% it's included or not, and whether it's currently highlighted or not.
selectedPlotNum = get(handles.list_Plot,'value');
plotNames = get(handles.list_Plot,'string');
for c = 1:length(plotNames)
    if handles.PlotInclude(c)==1
        plotNames{c}(19:24) = 'FF0000';
    else
        if c==selectedPlotNum
            plotNames{selectedPlotNum}(19:24) = 'FFFFFF';
        else
            plotNames{c}(19:24) = '000000';
        end
    end
end
set(handles.list_Plot,'string',plotNames);


% --- Executes on button press in push_PlotColor.
function push_PlotColor_Callback(hObject, ~, handles)
% hObject    handle to push_PlotColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.list_Plot,'string');
val = get(handles.list_Plot,'value');
query = [str{val}(26:end-14) ' color'];
c = uisetcolor(handles.PlotColor(val,:),query);
if length(c)<3
    return
end

handles = setPlotColor(handles, val, c);

guidata(hObject, handles);

function plotColors = getPlotColors(handles)
plotColors = handles.PlotColor;

function handles = setPlotColors(handles, plotColors)
[numPlots, ~] = size(plotColors);
if numPlots ~= length(get(handles.list_Plot, 'String'))
    error('Cannot set plot colors, because plot color array does not match the number of plots.');
end
for plotNumber = 1:numPlots
    handles = setPlotColor(handles, plotNumber, plotColors(plotNumber, :));
end

function handles = setPlotColor(handles, plotNumber, plotColor)
handles.PlotColor(plotNumber, :) = plotColor;
if ~isempty(handles.PlotHandles{plotNumber})
    handles = updatePlotColors(handles, plotNumber);
end

function handles = updatePlotColors(handles, plotToUpdate)
event_indx = get(handles.popup_EventList,'value');

if isfield(handles,'TriggerSelection')
    if plotToUpdate == 10 || plotToUpdate == 11 || plotToUpdate ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(handles.TriggerSelection==1)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(handles.TriggerSelection==1);
    end
else
    indx = [];
end

for c = intersect([1 2 4 5 7 8 19 22 23 25 26],plotToUpdate)
    if handles.PlotContinuous(plotToUpdate)==1
        if sum(handles.TriggerSelection)<length(handles.triggerInfo.absTime)
            warndlg('Could not selectively change color for a subset of triggers because object''s ''continuous'' option is on.','Warning');
        end
        set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
    else
        set(handles.PlotHandles{c}(:,indx),'color',handles.PlotColor(c,:));
    end
end
for c = intersect([13 15 16 20 28 29],plotToUpdate)
    set(handles.PlotHandles{c},'color',handles.PlotColor(c,:));
end
for c = intersect([10 11],plotToUpdate)
    if ~isempty(handles.PlotHandles{c}{event_indx})
        set(handles.PlotHandles{c}{event_indx}(indx),'color',handles.PlotColor(c,:));
    end
end
for c = intersect([14 30],plotToUpdate)
    set(handles.PlotHandles{c},'facecolor',handles.PlotColor(c,:),'edgecolor',handles.PlotColor(c,:));
end
for c = intersect([3 6 9 12 17 18 21 24 27],plotToUpdate)
    if iscell(handles.PlotHandles{c})
        h = handles.PlotHandles{c}{event_indx};
    else
        h = handles.PlotHandles{c};
    end
    if ~isempty(h)
        cdt = get(h,'cdata');
        if length(size(cdt))==3
            sz = [length(indx) 1];
            cdt(indx,1,:) = cat(3,handles.PlotColor(c,1)*ones(sz),handles.PlotColor(c,2)*ones(sz),handles.PlotColor(c,3)*ones(sz));
            set(h,'cdata',cdt);
        else
            set(h,'facecolor',handles.PlotColor(c,:));
        end
    end
end


% --- Executes on button press in push_PlotWidth.
function push_PlotWidth_Callback(hObject, ~, handles)
% hObject    handle to push_PlotWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.list_Plot,'string');
val = get(handles.list_Plot,'value');

if strcmp(get(handles.push_PlotWidth,'string'),'Width')
    query = [str{val}(26:end-14) ' line width'];
    answer = inputdlg(query,'Line width',1,{num2str(handles.PlotLineWidth(val))});
    if isempty(answer)
        return
    end

    handles.PlotLineWidth(val) = str2double(answer{1});
else
    query = [str{val}(26:end-14) ' transparency'];
    answer = inputdlg(query,'Transparency',1,{num2str(handles.PlotAlpha(val))});
    if isempty(answer)
        return
    end

    handles.PlotAlpha(val) = str2double(answer{1});
end

if isempty(handles.PlotHandles{val})
    guidata(hObject, handles);
    return
end

event_indx = get(handles.popup_EventList,'value');

if isfield(handles,'TriggerSelection')
    if val == 10 || val == 11 || val ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(handles.TriggerSelection)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(handles.TriggerSelection==1);
    end
else
    indx = [];
end

for c = intersect([1 2 4 5 7 8 19 22 23 25 26],val)
    if handles.PlotContinuous(val)==1
        if sum(handles.TriggerSelection)<length(handles.triggerInfo.absTime)
            warndlg('Could not selectively change width for a subset of triggers because object''s ''continuous'' option is on.','Warning');
        end
        set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
    else
        set(handles.PlotHandles{c}(:,indx),'linewidth',handles.PlotLineWidth(c));
    end
end
for c = intersect([13 15 16 20 28 29],val)
    set(handles.PlotHandles{c},'linewidth',handles.PlotLineWidth(c));
end
for c = intersect([10 11],val)
    if ~isempty(handles.PlotHandles{c})
        set(handles.PlotHandles{c}{event_indx}(indx),'linewidth',handles.PlotLineWidth(c));
    end
end

if strcmp(get(handles.push_PlotWidth,'string'),'Transparency')
    if iscell(handles.PlotHandles{val})
        set(handles.PlotHandles{event_indx},'facealpha',handles.PlotAlpha(val));
    else
        set(handles.PlotHandles{val},'facealpha',handles.PlotAlpha(val));
    end
end

guidata(hObject, handles);


% --- Executes on button press in check_LockLimits.
function check_LockLimits_Callback(hObject, ~, handles)
% hObject    handle to check_LockLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_LockLimits


if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'enable','off');
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'enable','off');
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
else
    set(handles.popup_StartReference,'enable','on');
    set(handles.popup_StopReference,'enable','on');
end

guidata(hObject, handles);


% --- Executes on button press in push_TimeLimits.
function push_TimeLimits_Callback(hObject, ~, handles)
% hObject    handle to push_TimeLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = setTimeLimits(handles);
guidata(hObject, handles);

function [timeLimitMin, timeLimitMax] = getTimeLimits(handles)
timeLimitMin = handles.PlotXLim(1);
timeLimitMax = handles.PlotXLim(2);

function handles = setTimeLimits(handles, timeLimitMin, timeLimitMax)
if ~exist('timeLimitMin', 'var') || ~exist('timeLimitMax', 'var')
    [oldMin, oldMax] = getTimeLimits(handles);
    % Min/max not provided as arguments. Get them from user.
    answer = inputdlg({'Min (sec)','Max (sec)'},'Time limits',1,{num2str(oldMin),num2str(oldMax)});
    if isempty(answer)
        return
    end
    timeLimitMin = str2double(answer{1});
    timeLimitMax = str2double(answer{2});
end
handles.PlotXLim(1) = timeLimitMin;
handles.PlotXLim(2) = timeLimitMax;

set(handles.axes_Raster,'xlim',handles.PlotXLim);
set(handles.axes_PSTH,'xlim',handles.PlotXLim);

set(handles.check_CopyWindow,'value',0);

handles.BackupXLim = handles.PlotXLim;


% --- Executes on button press in push_TickHeight.
function push_TickHeight_Callback(hObject, ~, handles)
% hObject    handle to push_TickHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f = findobj('parent',handles.panel_TickUnits,'style','radiobutton','value',1);
ch = get(handles.panel_TickUnits,'children');
f = 6-find(ch==f);

str = {'number of trials','seconds','inches','percent of the plot'};

if f == 3
    if get(handles.radio_YTrial,'value')==1
        answer = inputdlg({['Tick height (' str{f} ')'],'Overlap (percent)'},'Tick height',1,{num2str(handles.PlotTickSize(f)),num2str(handles.PlotOverlap)});
        if isempty(answer)
            return
        end
        handles.PlotTickSize(f) = str2double(answer{1});
        handles.PlotOverlap = str2double(answer{2});
    else
        answer = inputdlg({['Tick height (' str{f} ')'],'Inches per second'},'Tick height',1,{num2str(handles.PlotTickSize(f)),num2str(handles.PlotInPerSec)});
        if isempty(answer)
            return
        end
        handles.PlotTickSize(f) = str2double(answer{1});
        handles.PlotInPerSec = str2double(answer{2});
    end
else
    answer = inputdlg(['Tick height (' str{f} ')'],'Tick height',1,{num2str(handles.PlotTickSize(f))});
    if isempty(answer)
        return
    end
    handles.PlotTickSize(f) = str2double(answer{1});
end

guidata(hObject, handles);


function RadioYAxis_Callback(hObject, ~, handles)

if get(handles.radio_YTrial,'value')==1
    set(get(handles.panel_Sorting,'children'),'enable','on');
    set(handles.radio_TickSeconds,'enable','off');
    if get(handles.radio_TickSeconds,'value')==1
        set(handles.radio_TickTrials,'value',1);
    end
else
    set(handles.radio_TickSeconds,'enable','on');
    set(get(handles.panel_Sorting,'children'),'enable','off');
end

if get(handles.radio_TickInches,'value')==1
    set(get(handles.panel_ExportHeight,'children'),'enable','off');
else
    set(get(handles.panel_ExportHeight,'children'),'enable','on');
end

guidata(hObject, handles);


% --- Executes on button press in check_CopyWindow.
function check_CopyWindow_Callback(~, ~, ~)
% hObject    handle to check_CopyWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_CopyWindow



% --- Executes on button press in push_Export.
function push_Export_Callback(hObject, ~, handles)
% hObject    handle to push_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

switch iw
    case 1
        imwidth = handles.ExportWidth(1);
    case 2
        imwidth = handles.ExportWidth(2)*range(get(handles.axes_Raster,'xlim'));
end

switch ih
    case 1
        imheight = handles.ExportHeight(1);
    case 2
        imheight = handles.ExportHeight(2)*length(handles.triggerInfo.absTime);
    case 3
        imheight = handles.ExportHeight(3)*(max(handles.triggerInfo.absTime)-min(handles.triggerInfo.absTime))*(24*60*60);
end

if get(handles.radio_TickInches,'value')==1
    yl = get(handles.axes_Raster,'ylim');
    if get(handles.radio_YTrial,'value')==1
        imheight = (100-handles.PlotOverlap)/100*handles.PlotTickSize(3)*range(yl);
    else
        imheight = handles.PlotInPerSec*range(yl);
    end
end


subplot(handles.axes_Raster);
bck = get(gca,'units');
set(gca,'units','normalized');
ps = get(gca,'position');
set(gca,'position',[0 0 1 1]);
axis off

bckf = get(handles.fig_Main,'units');
figpos = get(handles.fig_Main,'position');
set(handles.fig_Main,'units','inches','visible','off');
rendback = get(handles.fig_Main,'renderer');
warning off;
set(handles.fig_Main,'PaperPositionMode','auto','Inverthardcopy','off')
obj = findobj('parent',handles.fig_Main,'type','uipanel');
set(obj,'visible','off');
set(handles.axes_PSTH,'visible','off')
set(get(handles.axes_PSTH,'children'),'visible','off')
set(handles.axes_Hist,'visible','off')
set(get(handles.axes_Hist,'children'),'visible','off')
col = get(handles.fig_Main,'color');
set(handles.fig_Main,'color',handles.BackgroundColor);
set(handles.fig_Main,'position',[0 0 imwidth imheight]);

fcont = find(handles.PlotContinuous==1);
for c = 1:length(fcont)
    set(handles.PlotHandles{fcont(c)},'visible','off');
end
set(findobj(handles.axes_Raster,'type','text'),'visible','off');

print('-dtiff','raster.tif',['-r' num2str(handles.ExportResolution)],'-noui');
set(handles.fig_Main,'Renderer','painters');
[newslide, pic_top, pic_left] = PowerPointExport(handles,imheight,imwidth);
delete('raster.tif');

set(get(handles.axes_Raster,'children'),'visible','off');

for c = 1:length(fcont)
    set(handles.PlotHandles{fcont(c)},'visible','on');
end
set(findobj(handles.axes_Raster,'type','text'),'visible','on');

set(handles.fig_Main,'color',col);
set(handles.fig_Main,'position',[0 0 imwidth*1.25 imheight*1.25]);
set(handles.axes_Raster,'position',[.1 .1 .8 .8]);
subplot(handles.axes_Raster);
set(gca,'visible','on');
axis on
print('-dmeta',['-r' num2str(handles.ExportResolution)],'-noui');
set(handles.fig_Main,'renderer',rendback);
warning on
pic = invoke(newslide.Shapes,'Paste');
ug = invoke(pic,'Ungroup');
set(ug,'Height',72*imheight*1.25,'Width',72*imwidth*1.25);
set(ug,'Top',pic_top-0.1*get(ug,'Height'),'Left',pic_left-0.1*get(ug,'Width'));
set(ug.Fill,'Visible','msoFalse');
tp = get(ug,'Top')+0.9*get(ug,'Height');
lf = get(ug,'Left')+0.1*get(ug,'Width');
ug = invoke(ug,'Ungroup');
for c = 1:get(ug,'Count')
    txt = invoke(ug,'Item',c);
    if strcmp(get(txt,'HasTextFrame'),'msoTrue')
        if get(txt,'Top') > tp
            set(txt.TextFrame,'VerticalAnchor','msoAnchorTop','HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        elseif get(txt,'Top') < tp && get(txt,'Left') < lf && get(txt,'Rotation') == 0
            set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
        elseif get(txt,'Top') < tp && get(txt,'Left') < lf && get(txt,'Rotation') ~= 0
            set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        else
            set(txt.TextFrame,'VerticalAnchor','msoAnchorTop');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
        end
    end
end
invoke(invoke(ug,'Item',2),'Delete');
invoke(invoke(ug,'Item',1),'Delete');

set(get(handles.axes_Raster,'children'),'visible','on');

set(obj,'visible','on');
if handles.HistShow(1)==1
    set(get(handles.axes_PSTH,'children'),'visible','on')
    set(handles.axes_PSTH,'visible','on')
end

set(get(handles.axes_Hist,'children'),'visible','on')
set(handles.axes_Hist,'visible','on')
if handles.HistShow(2)==0
    set(get(handles.axes_Hist,'children'),'visible','off')
    set(handles.axes_Hist,'visible','off')
end
set(handles.fig_Main,'units',bckf);
set(handles.fig_Main,'position',figpos,'visible','on');
subplot(handles.axes_Raster);
set(gca,'position',ps);
set(gca,'units',bck);

guidata(hObject, handles);

% --- Executes on button press in push_Dimensions.
function push_Dimensions_Callback(hObject, ~, handles)
% hObject    handle to push_Dimensions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = setDimensions(handles);

guidata(hObject, handles);

function [ExportPSTHHeight, ExportHistHeight, ExportInterval, ExportResolution, ExportWidth, ExportHeight] = getDimensons(handles)
ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

ExportPSTHHeight = handles.ExportPSTHHeight;
ExportHistHeight = handles.ExportHistHeight;
ExportInterval = handles.ExportInterval;
ExportResolution = handles.ExportResolution;
ExportWidth = handles.ExportWidth(iw);
if strcmp(get(ch(1),'enable'),'on')
    ExportHeight = handles.ExportHeight(ih);
else
    ExportHeight = NaN;
end

function handles = setDimensions(handles, ExportPSTHHeight, ExportHistHeight, ExportInterval, ExportResolution, ExportWidth, ExportHeight)
ch = get(handles.panel_ExportWidth,'children');
iw = findobj('parent',handles.panel_ExportWidth,'value',1);
iw = 3-find(ch==iw);

ch = get(handles.panel_ExportHeight,'children');
ih = findobj('parent',handles.panel_ExportHeight,'value',1);
ih = 4-find(ch==ih);

if nargin == 1
    % No values supplied. Query user for values.
    query{1} = 'PSTH height (in)';
    query{2} = 'Vertical histogram width (in)';
    query{3} = 'Interval between subplots (in)';
    query{4} = 'Raster resolution (dpi)';
    str = {'Raster width (in)','Raster width (in/sec)'};
    query{5} = str{iw};
    if strcmp(get(ch(1),'enable'),'on')
        str = {'Raster height (in)','Raster height (in/trial)','Raster height (in/sec)'};
        query{6} = str{ih};
    end

    def{1} = num2str(handles.ExportPSTHHeight);
    def{2} = num2str(handles.ExportHistHeight);
    def{3} = num2str(handles.ExportInterval);
    def{4} = num2str(handles.ExportResolution);
    def{5} = num2str(handles.ExportWidth(iw));
    if strcmp(get(ch(1),'enable'),'on')
        def{6} = num2str(handles.ExportHeight(ih));
    end

    answer = inputdlg(query,'Image dimensions',1,def);
    if isempty(answer)
        return
    end
    ExportPSTHHeight = answer{1};
    ExportHistHeight = answer{2};
    ExportInterval = answer{3};
    ExportResolution = answer{4};
    ExportWidth = answer{5};
    ExportHeight = answer{6};
end

handles.ExportPSTHHeight = ExportPSTHHeight;
handles.ExportHistHeight = ExportHistHeight;
handles.ExportInterval = ExportInterval;
handles.ExportResolution = ExportResolution;
handles.ExportWidth(iw) = ExportWidth;
if strcmp(get(ch(1),'enable'),'on')
    handles.ExportHeight(ih) = ExportHeight;
end

function [newslide, pic_top, pic_left] = PowerPointExport(handles,imheight,imwidth)

% Start presentation
ppt = actxserver('PowerPoint.Application');
op = get(ppt,'ActivePresentation');
slide_count = get(op.Slides,'Count');
slide_count = int32(double(slide_count)+1);
%newslide = invoke(op.Slides,'Add',slide_count,'ppLayoutBlank'); %OLD yoyo
newslide = invoke(op.Slides,'Add',slide_count,2);

% Add picture
pic = invoke(newslide.Shapes,'AddPicture',[pwd '\raster.tif'],'msoFalse','msoTrue',0,0,imwidth*72,imheight*72);
totheight = get(pic,'Height');
if get(handles.check_IncludePSTH,'value')==1 && handles.HistShow(1)==1
    totheight = totheight + 72*handles.ExportPSTHHeight + 72*handles.ExportInterval;
end
totwidth = get(pic,'Width');
if get(handles.check_IncludePSTH,'value')==1 && handles.HistShow(2)==1
    totwidth = totwidth + 72*handles.ExportHistHeight + 72*handles.ExportInterval;
end
set(pic,'top',get(op.PageSetup,'SlideHeight')/2+totheight/2-get(pic,'Height'));
set(pic,'left',get(op.PageSetup,'SlideWidth')/2-totwidth/2);

pic_top = get(pic,'top');
pic_left = get(pic,'left');


% Add PSTH

if get(handles.check_IncludePSTH,'value')==1 && handles.HistShow(1)==1

    yoff = get(pic,'Top') - 72*handles.ExportInterval;

    if ~isempty(handles.PlotHandles{14})
        x = get(handles.PlotHandles{14},'xdata');
        y = get(handles.PlotHandles{14},'ydata');
        x = x(2:2:end-2);
        y = y(2:2:end-2);
        xl = get(handles.axes_PSTH,'xlim');
        yl = get(handles.axes_PSTH,'ylim');
        f = find(x>=xl(1) & x<=xl(2));
        x = x(f);
        y = y(f);

        num = ceil(handles.ExportResolution*imwidth/length(y));
        y = repmat(y',num,1);
        y = reshape(y,numel(y),1);
        x = repmat(x',num,1);
        x = reshape(x,numel(x),1);
        
        img = repmat(linspace(yl(1),yl(2),round(handles.ExportResolution*handles.ExportPSTHHeight))',1,length(y));
        img = img - repmat(y',size(img,1),1);
        img = (img>0);
        imwrite(flipud(img),[handles.PlotColor(14,:); handles.BackgroundColor],'psth.gif');
        clear img;

        psth = invoke(newslide.Shapes,'AddPicture',[pwd '\psth.gif'],'msoFalse','msoTrue',0,0,imwidth*72,handles.ExportPSTHHeight*72);
        set(psth,'Top',yoff-get(psth,'Height'));
        set(psth,'Left',get(pic,'Left'));
        delete([pwd '\psth.gif']);
    end
    
    if ~isempty(handles.PlotHandles{20})
        for c = 1:length(handles.PlotHandles{20})
            xp = get(handles.PlotHandles{20}(c),'xdata');
            xp = xp(1);
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(20,1) + 256*255*handles.PlotColor(20,2) + 256^2*255*handles.PlotColor(20,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(20));
        end
    end

    if ~isempty(handles.PlotHandles{15})
        xpos = (0-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos = xpos*get(pic,'Width')+get(pic,'Left');
        ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
        col = 255*handles.PlotColor(15,1) + 256*255*handles.PlotColor(15,2) + 256^2*255*handles.PlotColor(15,3);
        set(ln.Line.ForeColor,'RGB',col);
        set(ln.Line,'Weight',handles.PlotLineWidth(15));
    end
    
    if ~isempty(handles.PlotHandles{30})
        xp = get(handles.PlotHandles{30},'xdata');
        xpos = (xp(1)-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos1 = xpos*get(pic,'Width')+get(pic,'Left');
        xpos = (xp(2)-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
        xpos2 = xpos*get(pic,'Width')+get(pic,'Left');
        rc = invoke(newslide.Shapes,'AddShape','msoShapeRectangle',xpos1,yoff-72*handles.ExportPSTHHeight,xpos2-xpos1,72*handles.ExportPSTHHeight);
        set(rc.Line,'Visible','msoFalse');
        col = 255*handles.PlotColor(30,1) + 256*255*handles.PlotColor(30,2) + 256^2*255*handles.PlotColor(30,3);
        set(rc.Fill.ForeColor,'RGB',col);
        set(rc.Fill,'Transparency',handles.PlotAlpha(30));
    end
    xl = get(handles.axes_PSTH,'xlim');
    if ~isempty(handles.PlotHandles{28})
        xp = get(handles.PlotHandles{28},'xdata');
        xp = xp(1);
        if xp>=xl(1) && xp<=xl(2)
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(28,1) + 256*255*handles.PlotColor(28,2) + 256^2*255*handles.PlotColor(28,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(28));
        end
    end
    if ~isempty(handles.PlotHandles{29})
        xp = get(handles.PlotHandles{29},'xdata');
        xp = xp(1);
        if xp>=xl(1) && xp<=xl(2)
            xpos = (xp-min(get(handles.axes_PSTH,'xlim')))/(max(get(handles.axes_PSTH,'xlim'))-min(get(handles.axes_PSTH,'xlim')));
            xpos = xpos*get(pic,'Width')+get(pic,'Left');
            ln = invoke(newslide.Shapes,'AddLine',xpos,yoff,xpos,yoff-72*handles.ExportPSTHHeight);
            col = 255*handles.PlotColor(29,1) + 256*255*handles.PlotColor(29,2) + 256^2*255*handles.PlotColor(29,3);
            set(ln.Line.ForeColor,'RGB',col);
            set(ln.Line,'Weight',handles.PlotLineWidth(29));
        end
    end

    fig = figure('visible','off','units','inches','position',[0 0 imwidth*1.25 handles.ExportPSTHHeight*1.25]);
    subplot('position',[.1 .1 .8 .8]);
    if ~isempty(handles.PlotHandles{13})
        h = handles.PlotHandles{13};
        x = get(h,'xdata');
        y = get(h,'ydata');
        xl = get(handles.axes_PSTH,'xlim');
        yl = get(handles.axes_PSTH,'ylim');
        pl = plot(x,y);
        set(pl,'color',handles.PlotColor(13,:));
        set(pl,'linewidth',handles.PlotLineWidth(13));
    end
    xlim(get(handles.axes_PSTH,'xlim'));
    ylim(get(handles.axes_PSTH,'ylim'));
    set(gca,'xtick',[]);
    ylabel(get(get(handles.axes_PSTH,'ylabel'),'string'));
    print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportResolution)]);
    delete(fig);
    ug = invoke(newslide.Shapes,'Paste');
    ug = invoke(ug,'Ungroup');
    set(ug.Fill,'Visible','msoFalse');
    ug = invoke(ug,'Ungroup');
    for c = 1:get(ug,'Count')
        txt = invoke(ug,'Item',c);
        if strcmp(get(txt,'HasTextFrame'),'msoTrue')
            if get(txt,'Rotation') == 0
                set(txt.TextFrame,'VerticalAnchor','msoAnchorMiddle');
                set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignRight');
            else
                set(txt.TextFrame,'VerticalAnchor','msoAnchorBottom','HorizontalAnchor','msoAnchorCenter');
                set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
            end
        end
    end
    ug = invoke(ug,'Group');
    set(ug,'Height',72*handles.ExportPSTHHeight*1.25,'Width',72*imwidth*1.25);
    set(ug,'Top',yoff-get(ug,'Height')+0.1*get(ug,'Height'));
    set(ug,'Left',get(pic,'Left')-0.1*get(ug,'Width'));
    ug = invoke(ug,'Ungroup');
    for c = 4:-1:1
        invoke(invoke(ug,'Item',c),'Delete');
    end

end


% Add vertical histogram

if get(handles.check_IncludePSTH,'value')==1 && handles.HistShow(2)==1

    xoff = get(pic,'Left') + get(pic,'Width') + 72*handles.ExportInterval;
    
    if ~isempty(handles.PlotHandles{17})
        x = get(handles.PlotHandles{17},'xdata');
        y = get(handles.PlotHandles{17},'ydata');
        cd = get(handles.PlotHandles{17},'cdata');
        if length(size(cd))==2
            cd = get(handles.PlotHandles{17},'facecolor');
            cd = permute(cd,[3 1 2]);
        end
        if ~isempty(handles.PlotHandles{18})
            cdb = get(handles.PlotHandles{18},'cdata');
            if length(size(cdb))==2
                cdb = get(handles.PlotHandles{18},'facecolor');
                cdb = permute(cdb,[3 1 2]);
            end
        end
        
        resy = round(handles.ExportResolution*imheight);
        resx = round(handles.ExportResolution*handles.ExportHistHeight);
        xl = get(handles.axes_Hist,'xlim');
        yl = get(handles.axes_Hist,'ylim');
        xs = linspace(xl(1),xl(2),resx);
        ys = linspace(yl(1),yl(2),resy);
        
        img = repmat(permute(handles.BackgroundColor,[3 1 2]),resy,resx);
        for c = 1:size(cd,1)
            indxx = find(xs<=x(2,c));
            indxy = find(ys>=y(1,c) & ys<=y(3,c));
            img(indxy,indxx,:) = repmat(cd(c,1,:),length(indxy),length(indxx));
            if ~isempty(handles.PlotHandles{18})
                indxx = find(xs>x(2,c));
                img(indxy,indxx,:) = repmat(cdb(c,1,:),length(indxy),length(indxx));
            end
        end
        for c = 1:3
            img(:,:,c) = flipud(img(:,:,c));
        end
        
        imwrite(img,'hist.tif');
        clear img;
        
        psth = invoke(newslide.Shapes,'AddPicture',[pwd '\hist.tif'],'msoFalse','msoTrue',0,0,handles.ExportHistHeight*72,imheight*72);
        set(psth,'Top',get(pic,'top')+get(pic,'height')-get(psth,'height'));
        set(psth,'Left',xoff);
        delete([pwd '\hist.tif']);
    end

    fig = figure('visible','off','units','inches','position',[0 0 handles.ExportHistHeight*1.25 imheight*1.25]);
    subplot('position',[.1 .1 .8 .8]);
    if ~isempty(handles.PlotHandles{16})
        h = handles.PlotHandles{16};
        x = get(h,'xdata');
        y = get(h,'ydata');
        pl = plot(x,y);
        set(pl,'color',handles.PlotColor(16,:));
        set(pl,'linewidth',handles.PlotLineWidth(16));
    end
    xlim(get(handles.axes_Hist,'xlim'));
    ylim(get(handles.axes_Hist,'ylim'));
    set(gca,'ytick',[]);
    box off
    xlabel(get(get(handles.axes_Hist,'xlabel'),'string'));
    print('-dmeta',['-f' num2str(fig)],['-r' num2str(handles.ExportResolution)]);
    delete(fig);
    ug = invoke(newslide.Shapes,'Paste');
    ug = invoke(ug,'Ungroup');
    set(ug.Fill,'Visible','msoFalse');
    ug = invoke(ug,'Ungroup');
    for c = 1:get(ug,'Count')
        txt = invoke(ug,'Item',c);
        if strcmp(get(txt,'HasTextFrame'),'msoTrue')
            set(txt.TextFrame,'HorizontalAnchor','msoAnchorCenter');
            set(txt.TextFrame.TextRange.ParagraphFormat,'Alignment','ppAlignCenter');
        end
    end
    ug = invoke(ug,'Group');
    set(ug,'Height',72*imheight*1.25,'Width',72*handles.ExportHistHeight*1.25);
    set(ug,'Top',get(pic,'Top')-0.1*get(ug,'Height'));
    set(ug,'Left',xoff-0.1*get(ug,'Width'));
    ug = invoke(ug,'Ungroup');
    for c = 4:-1:1
        invoke(invoke(ug,'Item',c),'Delete');
    end
end



% --- Executes on button press in push_Open.
function push_Open_Callback(hObject, ~, handles)
% hObject    handle to push_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file, path] = uigetfile('*.mat','Load analysis');
if ~ischar(file)
    return
end
cd(path)

load([path file],'dbase');

set(handles.popup_Files,'value',1);
set(handles.popup_Files,'string',{'All files in range'});

handles.egh.fs = dbase.Fs;
handles.egh.DatesAndTimes = dbase.Times;
handles.egh.FileLength = dbase.FileLength;
handles.egh.sound_files = dbase.SoundFiles;
handles.egh.chan_files = dbase.ChannelFiles;
handles.egh.sound_loader = dbase.SoundLoader;
handles.egh.chan_loader = dbase.ChannelLoader;
handles.egh.SoundThresholds = dbase.SegmentThresholds;
handles.egh.SegmentTimes = dbase.SegmentTimes;
handles.egh.SegmentTitles = dbase.SegmentTitles;
handles.egh.SegmentSelection = dbase.SegmentIsSelected;
handles.egh.EventSources = dbase.EventSources;
handles.egh.EventFunctions = dbase.EventFunctions;
handles.egh.EventDetectors = dbase.EventDetectors;
handles.egh.EventThresholds = dbase.EventThresholds;
handles.egh.EventTimes = dbase.EventTimes;
handles.egh.EventSelected = dbase.EventIsSelected;
handles.egh.Properties = dbase.Properties;
handles.egh.TotalFileNumber = length(handles.egh.sound_files);

if isfield(dbase, 'MarkerTimes')
    handles.egh.MarkerTimes = dbase.MarkerTimes;
else
    % This must be an older type of dbase - add blank marker field
    handles.egh.MarkerTimes = cell(1,handles.egh.TotalFileNumber);
end
if isfield(dbase, 'MarkerTitles')
    handles.egh.MarkerTitles = dbase.MarkerTitles;
else
    % This must be an older type of dbase - add blank marker field
    handles.egh.MarkerTitles = cell(1,handles.egh.TotalFileNumber);
end
if isfield(dbase, 'MarkerIsSelected')
    handles.egh.MarkerSelection = dbase.MarkerIsSelected;
else
    % This must be an older type of dbase - add blank marker field
    handles.egh.MarkerSelection = cell(1,handles.egh.TotalFileNumber);
end

handles.egh.overlaptolerance = 0.0001;
handles.egh = Fix_Overlap(handles.egh);

handles.FileRange = 1:handles.egh.TotalFileNumber;
handles.FileNames = {};
for c = 1:length(dbase.SoundFiles)
    handles.FileNames{c} = dbase.SoundFiles(c).name;
end


% Get event list
str = {'Sound'};
for c = 1:length(handles.egh.EventSources)
    str{end+1} = [handles.egh.EventDetectors{c} ' - ' handles.egh.EventSources{c} ' - ' handles.egh.EventFunctions{c}];
end

if get(handles.popup_TriggerSource,'value') > length(str)
    set(handles.popup_TriggerSource,'value',1);
end
set(handles.popup_TriggerSource,'string',str);

if get(handles.popup_EventSource,'value') > length(str)
    if length(str)==1
        set(handles.popup_EventSource,'value',1);
    else
        set(handles.popup_EventSource,'value',2);
    end
end
set(handles.popup_EventSource,'string',str);

if get(handles.popup_TriggerSource,'value') == 1
    set(handles.popup_TriggerType,'string',{'Syllables','Markers','Motifs','Bouts'});
else
    set(handles.popup_TriggerType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

if get(handles.popup_EventSource,'value') == 1
    set(handles.popup_EventType,'string',{'Syllables','Markers','Motifs','Bouts'});
else
    set(handles.popup_EventType,'string',{'Events','Bursts','Burst events','Single events','Pauses'});
end

set(handles.popup_EventType,'enable','on');
set(handles.popup_Correlation,'value',1);
set(handles.popup_Correlation,'string',{'(None)'});

cla(handles.axes_PSTH);
cla(handles.axes_Hist);
cla(handles.axes_Raster);

str = get(handles.list_WarpPoints,'string');
for c = length(handles.WarpPoints):-1:1
    if handles.WarpPoints{c}.source > 0
        handles.WarpPoints(c) = [];
        str(c) = [];
    end
end
if isempty(str)
    str = {'(None)'};
end
set(handles.list_WarpPoints,'value',1);
set(handles.list_WarpPoints,'string',str);

if get(handles.check_CopyWindow,'value')==1
    if get(handles.check_LockLimits,'value')==1
        set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
        set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
        if ~isempty(handles.WarpPoints)
            set(handles.popup_StartReference,'value',6);
            set(handles.popup_StopReference,'value',6);
        end
    end
end

set(handles.push_GenerateRaster,'enable','on');
set(handles.push_FileRange,'enable','on');

guidata(hObject, handles);


% --- Executes on selection change in popup_PSTHUnits.
function popup_PSTHUnits_Callback(~, ~, ~)
% hObject    handle to popup_PSTHUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PSTHUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PSTHUnits


% --- Executes during object creation, after setting all properties.
function popup_PSTHUnits_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_PSTHUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_PSTHBinSize.
function push_PSTHBinSize_Callback(hObject, ~, handles)
% hObject    handle to push_PSTHBinSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch getHistogramDirection(handles)
    case 'horizontal'
        str = get(handles.popup_PSTHUnits,'string');
        val = get(handles.popup_PSTHUnits,'value');
        str = str{val};
        str(1) = lower(str(1));

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            val = val + 3;
        end

        answer = inputdlg({'PSTH bin size (sec)','Smoothing window (# of bins)',['Min ' str],['Max ' str]},'Options',1,{num2str(handles.PSTHBinSize),num2str(handles.PSTHSmoothingWindow),num2str(handles.PSTHYLim(val,1)),num2str(handles.PSTHYLim(val,2))});
        if isempty(answer)
            return
        end

        handles.PSTHBinSize = str2double(answer{1});
        handles.PSTHSmoothingWindow = str2double(answer{2});
        handles.PSTHYLim(val,1) = str2double(answer{3});
        handles.PSTHYLim(val,2) = str2double(answer{4});

        if get(handles.radio_PSTHManual,'value')==1
            set(handles.axes_PSTH,'ylim',handles.PSTHYLim(val,:));
        end
    case 'vertical'
        str = get(handles.popup_HistUnits,'string');
        valm = get(handles.popup_HistUnits,'value');
        strm = str{valm};
        strm(1) = lower(strm(1));

        if strcmp(get(handles.popup_EventType,'enable'),'off')
            valm = valm + 3;
        end

        if get(handles.radio_YTrial,'value')==1
            val = 1;
        else
            val = 2;
        end
        str = {'trials','sec'};
        answer = inputdlg({['Histogram bin size (' str{val} ')'],'Smoothing window (# of bins)','ROI start (sec)','ROI stop (sec)',['Min ' strm],['Max ' strm]},'Options',1,{num2str(handles.HistBinSize(val)),num2str(handles.HistSmoothingWindow),num2str(handles.ROILim(1)),num2str(handles.ROILim(2)),num2str(handles.HistYLim(val,1)),num2str(handles.HistYLim(val,2))});
        if isempty(answer)
            return
        end

        handles.HistBinSize(val) = str2double(answer{1});
        handles.HistSmoothingWindow = str2double(answer{2});
        handles.ROILim(1) = str2double(answer{3});
        handles.ROILim(2) = str2double(answer{4});
        handles.HistYLim(val,1) = str2double(answer{5});
        handles.HistYLim(val,2) = str2double(answer{6});

        if get(handles.radio_PSTHManual,'value')==1
            set(handles.axes_Hist,'xlim',handles.HistYLim(val,:));
        end
end

guidata(hObject, handles);


% --- Executes on selection change in popup_PSTHCount.
function popup_PSTHCount_Callback(~, ~, ~)
% hObject    handle to popup_PSTHCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_PSTHCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_PSTHCount


% --- Executes during object creation, after setting all properties.
function popup_PSTHCount_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_PSTHCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_IncludePSTH.
function check_IncludePSTH_Callback(~, ~, ~)
% hObject    handle to check_IncludePSTH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_IncludePSTH


% --- Executes on button press in check_HoldOn.
function check_HoldOn_Callback(hObject, ~, handles)
% hObject    handle to check_HoldOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_HoldOn

if get(handles.check_HoldOn,'value')==1
    set(get(handles.panel_Files,'children'),'enable','off');
    set(get(handles.panel_Trigger,'children'),'enable','off');
    set(get(handles.panel_Window,'children'),'enable','off');
    set(get(handles.panel_Filtering,'children'),'enable','off');
    set(setdiff(get(handles.panel_Warping,'children'),handles.panel_WarpedDurations),'enable','off');
    set(get(handles.panel_WarpedDurations,'children'),'enable','off');
    set(get(handles.panel_TickUnits,'children'),'enable','off');
    set(get(handles.panel_TimeAxis,'children'),'enable','off');
    set(get(handles.panel_YAxis,'children'),'enable','off');
    set(handles.check_CopyEvents,'userdata',get(handles.check_CopyEvents,'value'));
    set(handles.check_CopyEvents,'value',0);
    set(get(handles.panel_Sorting,'children'),'enable','off');
    set(handles.check_SkipSorting,'userdata',get(handles.check_SkipSorting,'value'));
    set(handles.check_SkipSorting,'value',0);
    set(handles.check_SkipSorting,'enable','off');
else
    set(get(handles.panel_Files,'children'),'enable','on');
    set(get(handles.panel_Trigger,'children'),'enable','on');
    set(get(handles.panel_Window,'children'),'enable','on');
    set(get(handles.panel_Filtering,'children'),'enable','on');
    set(setdiff(get(handles.panel_Warping,'children'),handles.panel_WarpedDurations),'enable','on');
    set(get(handles.panel_WarpedDurations,'children'),'enable','on');
    set(get(handles.panel_TickUnits,'children'),'enable','on');
    set(get(handles.panel_TimeAxis,'children'),'enable','on');
    set(get(handles.panel_YAxis,'children'),'enable','on');
    set(handles.check_CopyEvents,'value',get(handles.check_CopyEvents,'userdata'));
    set(handles.check_SkipSorting,'value',get(handles.check_SkipSorting,'userdata'));
    set(handles.check_SkipSorting,'enable','on');
    if get(handles.radio_YTrial,'value')==1
        set(get(handles.panel_Sorting,'children'),'enable','on');
        set(handles.radio_TickSeconds,'enable','off');
    end
    if get(handles.check_LockLimits,'value')==1
        set(handles.popup_StartReference,'enable','off');
        set(handles.popup_StopReference,'enable','off');
    end
end

obj = handles.list_Plot;
egm_Sorted_rasters('list_Plot_Callback',obj,[],guidata(obj));

guidata(hObject, handles);


% --- Executes on selection change in list_WarpPoints.
function list_WarpPoints_Callback(~, ~, ~)
% hObject    handle to list_WarpPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_WarpPoints contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_WarpPoints


% --- Executes during object creation, after setting all properties.
function list_WarpPoints_CreateFcn(hObject, ~, ~)
% hObject    handle to list_WarpPoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_AddPoint.
function push_AddPoint_Callback(hObject, ~, handles)
% hObject    handle to push_AddPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val_s = get(handles.popup_TriggerSource,'value');
str = get(handles.popup_TriggerSource,'string');
str_s = str{val_s};

val = get(handles.popup_TriggerType,'value');
str = get(handles.popup_TriggerType,'string');
str_t = str{val};

val = get(handles.popup_TriggerAlignment,'value');
str = get(handles.popup_TriggerAlignment,'string');
str_a = str{val};

w.P = handles.P.trig;
w.source = val_s - 1;
w.type = str_t;
w.alignment = str_a;

str = [str_t(1:end-1) ' ' lower(str_a) 's - ' str_s];

lst = get(handles.list_WarpPoints,'string');
if length(lst) == 1 && strcmp(lst{1},'(None)')
    lst = {str};
else
    lst{end+1} = str;
end

handles.WarpPoints{end+1} = w;

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',6);
    set(handles.popup_StopReference,'value',6);
end

set(handles.list_WarpPoints,'string',lst);
set(handles.list_WarpPoints,'value',length(lst));

guidata(hObject, handles);


% --- Executes on button press in push_DeletePoint.
function push_DeletePoint_Callback(hObject, ~, handles)
% hObject    handle to push_DeletePoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = get(handles.list_WarpPoints,'value');
str = get(handles.list_WarpPoints,'string');
if length(str) == 1 && strcmp(str{1},'(None)')
    return
end

str(val) = [];
handles.WarpPoints(val) = [];

if isempty(str)
    str = {'(None)'};
end

if val > length(str)
    val = length(str);
end
set(handles.list_WarpPoints,'value',val);

set(handles.list_WarpPoints,'string',str);

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end


guidata(hObject, handles);


% --- Executes on selection change in popup_WarpingAlgorithm.
function popup_WarpingAlgorithm_Callback(~, ~, ~)
% hObject    handle to popup_WarpingAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_WarpingAlgorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_WarpingAlgorithm


% --- Executes during object creation, after setting all properties.
function popup_WarpingAlgorithm_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_WarpingAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_WarpOptions.
function push_WarpOptions_Callback(hObject, ~, handles)
% hObject    handle to push_WarpOptions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = setWarpOptions(handles);
guidata(hObject, handles);

function [corrMax, WarpNumBefore, WarpNumAfter] = getWarpOptions(handles)
corrMax = handles.corrMax;
WarpNumBefore = handles.WarpNumBefore;
WarpNumAfter = handles.WarpNumAfter;

function handles = setWarpOptions(handles, corrMax, WarpNumBefore, WarpNumAfter)
if ~exist('corrMax', 'var') || ~exist('WarpNumBefore', 'var') || ~exist('WarpNumAfter', 'var')
    % No values provided, query user for values.
    queries = {'Maximum allowed correlation shift (sec)','Number of warp intervals prior to trigger','Number of warp intervals after trigger'};
    [oldCorrMax, oldWarpNumBefore, oldWarpNumAfter] = getWarpOptions(handles);
    defaults = {num2str(oldCorrMax),num2str(oldWarpNumBefore),num2str(oldWarpNumAfter)};
    answer = inputdlg(queries,'Warp options',1,defaults);
    if isempty(answer)
        return
    end
    corrMax = str2double(answer{1});
    WarpNumBefore = str2double(answer{2});
    WarpNumAfter = str2double(answer{3});
end
handles.corrMax = corrMax;
handles.WarpNumBefore = WarpNumBefore;
handles.WarpNumAfter = WarpNumAfter;

function [intervalDurations, intervalTypes, warpIntervalLim, warpNumBefore, warpNumAfter] = getWarpIntervalInfo(handles)
intervalDurations = handles.WarpIntervalDuration;
intervalTypes = handles.WarpIntervalType;
warpIntervalLim = handles.WarpIntervalLim;
warpNumBefore = handles.WarpNumBefore;
warpNumAfter = handles.WarpNumAfter;

function handles = setWarpIntervalInfo(handles, intervalDurations, intervalTypes, warpIntervalLim, warpNumBefore, warpNumAfter)
handles.WarpIntervalDuration = intervalDurations;
handles.WarpIntervalType = intervalTypes;
handles.WarpIntervalLim = warpIntervalLim;
handles.WarpNumBefore = warpNumBefore;
handles.WarpNumAfter = warpNumAfter;

intervalName = get(handles.text_Interval,'string');
intervalNum = str2double(intervalName);
intervalIndex = warpIntervalNumToIndex(handles, intervalNum);

warpTypeRadioButtons = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton');
set(warpTypeRadioButtons(handles.WarpIntervalType(intervalIndex)),'value',1);

function intervalIndex = warpIntervalNumToIndex(handles, intervalNum)
intervalIndex = intervalNum - handles.WarpIntervalLim(1) + 1;
if intervalNum > 0
    intervalIndex = intervalIndex - 1;
end

function intervalNum = warpIntervalIndexToNum(handles, intervalIndex)
intervalNum = intervalIndex + handles.WarpIntervalLim(1) - 1;
if intervalNum >= 0
    intervalNum = intervalNum + 1;
end

% --- Executes on button press in push_IntervalDuration.
function push_IntervalDuration_Callback(hObject, ~, handles)
% hObject    handle to push_IntervalDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

intervalName = get(handles.text_Interval,'string');
intervalNum = str2double(intervalName);
intervalIndex = warpIntervalNumToIndex(handles, intervalNum);

answer = inputdlg({['Custom duration for interval ' intervalName]},'Duration',1,{num2str(handles.WarpIntervalDuration(intervalIndex))});
if isempty(answer)
    return
end
handles.WarpIntervalDuration(intervalIndex) = str2double(answer{1});
handles.WarpIntervalType(intervalIndex) = 4;
set(handles.radio_WarpCustom,'value',1);

guidata(hObject, handles);


% --- Executes on button press in push_IntervalLeft.
function push_IntervalLeft_Callback(hObject, ~, handles)
% hObject    handle to push_IntervalLeft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2double(get(handles.text_Interval,'string'));
num = num - 1;
if num == 0
    num = -1;
end
handles = UpdateInterval(handles,num);

guidata(hObject, handles);

% --- Executes on button press in push_IntervalRight.
function push_IntervalRight_Callback(hObject, ~, handles)
% hObject    handle to push_IntervalRight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num = str2double(get(handles.text_Interval,'string'));
num = num + 1;
if num == 0
    num = 1;
end
handles = UpdateInterval(handles,num);

guidata(hObject, handles);


function handles = UpdateInterval(handles,num)

str = num2str(num);
if num > 0
    str = ['+' str];
end

set(handles.text_Interval,'string',str);

if num < handles.WarpIntervalLim(1)
    handles.WarpIntervalLim(1) = handles.WarpIntervalLim(1) - 1;
    handles.WarpIntervalType = [1 handles.WarpIntervalType];
    handles.WarpIntervalDuration = [.1 handles.WarpIntervalDuration];
end

if num > handles.WarpIntervalLim(2)
    handles.WarpIntervalLim(2) = handles.WarpIntervalLim(2) + 1;
    handles.WarpIntervalType = [handles.WarpIntervalType 1];
    handles.WarpIntervalDuration = [handles.WarpIntervalDuration .1];
end

indx = num - handles.WarpIntervalLim(1) + 1;
if num > 0
    indx = indx - 1;
end
ch = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton');
set(ch(handles.WarpIntervalType(indx)),'value',1);


function RadioWarpedDurations(hObject, ~, handles)

num = str2double(get(handles.text_Interval,'string'));
indx = num - handles.WarpIntervalLim(1) + 1;
if num > 0
    indx = indx - 1;
end

ch = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton');
sel = findobj('parent',handles.panel_WarpedDurations,'style','radiobutton','value',1);
handles.WarpIntervalType(indx) = find(ch==sel);

guidata(hObject, handles);


function click_Raster(hObject, ~, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
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

    if rect(3) == 0 || rect(4) == 0
        if ~strcmp(get(hObject,'type'),'axes') && ~strcmp(get(hObject,'type'),'text')
            [mn indx] = min(abs(rect(2)-handles.TrialYs));
            
            x = get(hObject,'xdata');
            y = get(hObject,'ydata');
            if strcmp(get(hObject,'type'),'patch')
                f = find(x(1,:)<rect(1) && x(2,:)>rect(1) && y(2,:)<rect(2) && y(3,:)>rect(2));
                if ~isempty(f)
                    x = x(1:2,f(1));
                else
                    return
                end
            else
                x = x(1);
            end
            
            tm = (handles.triggerInfo.absTime(indx)-min(handles.triggerInfo.absTime))*(24*60*60);
            f = find(handles.triggerInfo.fileNum==handles.triggerInfo.fileNum(indx));
            trig = find(f==indx);
            if handles.triggerInfo.label(indx) == 0
                lab = 'N/A';
            elseif handles.triggerInfo.label(indx) >= 1000
                lab = num2str(handles.triggerInfo.label(indx)-1000);
            else
                lab = char(handles.triggerInfo.label(indx));
            end
            ftm = (handles.triggerInfo.absTime(indx)-handles.egh.DatesAndTimes(handles.FileList(handles.triggerInfo.fileNum(indx))))*(24*60*60);
            
            spc = repmat(' ',1,5);
            if length(x)==1
                set(handles.text_Info,'string',['Trial #: ' num2str(indx) spc 'Trial time: ' num2str(tm,4) spc 'File #: ' num2str(handles.FileList(handles.triggerInfo.fileNum(indx))) spc 'Trig #: ' num2str(trig) spc 'Trig time: ' num2str(ftm,4) spc 'Trig label: ' lab spc 'Event time: ' num2str(ftm+x,4) spc 'Event rel time: ' num2str(x,4)]);
            else
                set(handles.text_Info,'string',['Trial #: ' num2str(indx) spc 'Trial time: ' num2str(tm,4) spc 'File #: ' num2str(handles.FileList(handles.triggerInfo.fileNum(indx))) spc 'Trig #: ' num2str(trig) spc 'Trig time: ' num2str(ftm,4) spc 'Trig label: ' lab spc 'Event time: ' num2str(ftm+x(1),4) ' - ' num2str(ftm+x(2),4) spc 'Event rel time: ' num2str(x(1),4) ' - ' num2str(x(2),4)]);
            end
        end
        return
    end

    set(handles.axes_Raster,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
    set(handles.axes_PSTH,'xlim',[rect(1) rect(1)+rect(3)]);
    set(handles.axes_Hist,'ylim',[rect(2) rect(2)+rect(4)]);
elseif strcmp(get(gcf,'selectiontype'),'open')
    set(handles.axes_Raster,'xlim',handles.BackupXLimRaster,'ylim',handles.BackupYLimRaster);
    set(handles.axes_PSTH,'xlim',handles.BackupXLimRaster);
    set(handles.axes_Hist,'ylim',handles.BackupYLimRaster);
elseif strcmp(get(gcf,'selectiontype'),'extend')
    if strcmp(get(hObject,'type'),'text')
        delete(hObject);
    end
end

function click_PSTH(~, ~, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
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

    if rect(3) == 0 || rect(4) == 0
        return
    end

    set(handles.axes_Raster,'xlim',[rect(1) rect(1)+rect(3)]);
    set(handles.axes_PSTH,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
else
    set(handles.axes_Raster,'xlim',handles.BackupXLimRaster);
    set(handles.axes_PSTH,'xlim',handles.BackupXLimRaster,'ylim',handles.BackupYLimPSTH);
end


function click_Hist(~, ~, handles)

if strcmp(get(gcf,'selectiontype'),'normal')
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

    if rect(3) == 0 || rect(4) == 0
        return
    end

    set(handles.axes_Raster,'ylim',[rect(2) rect(2)+rect(4)]);
    set(handles.axes_Hist,'xlim',[rect(1) rect(1)+rect(3)],'ylim',[rect(2) rect(2)+rect(4)]);
else
    set(handles.axes_Raster,'ylim',handles.BackupYLimRaster);
    set(handles.axes_Hist,'xlim',handles.BackupXLimHist,'ylim',handles.BackupYLimRaster);
end


function [fld_new, stretch] = WarpTrial(fld,oldwarp,newwarp,method,fs,warpstr)
% warping algorithms

tol = 1/fs;

fld_new = fld;

% Events before first warp point are mapped to real time
f = find(fld < oldwarp(1)+tol);
fld_new(f) = fld(f)-oldwarp(1)+newwarp(1);

% Events after the last warp point are mapped to real time
f = find(fld >= oldwarp(end)-tol);
fld_new(f) = fld(f)-oldwarp(end)+newwarp(end);

% Events right at warp points get mapped to new warp points
for c = 1:length(oldwarp)
    f = find(fld >= oldwarp(c)-tol & fld < oldwarp(c)+tol);
    fld_new(f) = newwarp(c);
end

switch method
    case 'Linear stretch'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c) + (newwarp(c+1)-newwarp(c)) * (fld(f)-oldwarp(c))/(oldwarp(c+1)-oldwarp(c));
            if strcmp(warpstr,'dataStart')
                fld_new(end+1) = newwarp(c);
            end
            if strcmp(warpstr,'dataStop')
                fld_new(end+1) = newwarp(c+1);
            end
        end
        if strcmp(warpstr,'dataStart')
            fld_new(end+1) = newwarp(end);
        end
        if strcmp(warpstr,'dataStop')
            fld_new(end+1) = newwarp(1);
        end
        stretch = (newwarp(2:end)-newwarp(1:end-1))./(oldwarp(2:end)-oldwarp(1:end-1));
    case 'Align left'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c) + (fld(f)-oldwarp(c));
            g = find(fld_new(f)>newwarp(c+1));
            fld_new(f(g)) = inf;
            
            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = newwarp(c+1)-tol;
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = newwarp(c) + (oldwarp(c+1)-oldwarp(c));
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
    case 'Align right'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = newwarp(c+1) - (oldwarp(c+1)-fld(f));
            g = find(fld_new(f)<newwarp(c));
            fld_new(f(g)) = inf;

            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = newwarp(c+1)-(oldwarp(c+1)-oldwarp(c));
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = newwarp(c) + tol;
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
    case 'Align center'
        for c = 1:length(oldwarp)-1
            f = find(fld >= oldwarp(c)+tol & fld < oldwarp(c+1)-tol);
            fld_new(f) = (newwarp(c)+newwarp(c+1))/2 - (oldwarp(c+1)-oldwarp(c))/2 + (fld(f)-oldwarp(c));
            g = find(fld_new(f)<newwarp(c) | fld_new(f)>newwarp(c+1));
            fld_new(f(g)) = inf;

            if newwarp(c+1)-newwarp(c) > oldwarp(c+1)-oldwarp(c)
                if strcmp(warpstr,'dataStart')
                    fld_new(end+1) = (newwarp(c)+newwarp(c+1))/2 - (oldwarp(c+1)-oldwarp(c))/2;
                    fld_new(end+1) = newwarp(c+1)-tol;
                end
                if strcmp(warpstr,'dataStop')
                    fld_new(end+1) = (newwarp(c)+newwarp(c+1))/2 + (oldwarp(c+1)-oldwarp(c))/2;
                    fld_new(end+1) = newwarp(c) + tol;
                end
            end

        end
        stretch = ones(size(newwarp(2:end)));
end

if strcmp(warpstr,'dataStart') || strcmp(warpstr,'dataStop')
    fld_new = sort(fld_new);
end


% --- Executes on button press in push_Colors.
function push_Colors_Callback(~, ~, handles)
% hObject    handle to push_Colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Colors,'uicontextmenu',handles.context_Color);

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



function [funct, lab, indx] = getContinuousFunction(handles,filenum,axnum,doSubsample)
val = get(handles.egh.popup_Channels(axnum),'value');
str = get(handles.egh.popup_Channels(axnum),'string');
nums = [];
for c = 1:length(handles.egh.EventTimes);
    nums(c) = size(handles.egh.EventTimes{c},1);
end

if val <= length(str)-sum(nums)
    fm = find(handles.egh.Overlaps==filenum);
    if isempty(fm)
        funct = [];
    else
        true_len = [round(diff(handles.egh.DatesAndTimes(fm))*(24*60*60)*handles.egh.fs) handles.egh.FileLength(fm(end))];
        pos = [0 cumsum(true_len)];
        funct = [];
        for ovr = 1:length(fm);
            chan = str2double(str{val}(9:end));
            if length(str{val})>4 && strcmp(str{val}(1:5),'Sound')
                [funct1, fs, dt, lab, props] = eg_runPlugin(handles.egh.plugins.loaders, handles.egh.sound_loader, fullfile(handles.egh.DefaultRootPath, handles.egh.sound_files(fm(ovr)).name), true);
            else
                [funct1, fs, dt, lab, props] = eg_runPlugin(handles.egh.plugins.loaders, handles.egh.chan_loader{chan}, fullfile(handles.egh.DefaultRootPath, handles.egh.chan_files{chan}(fm(ovr)).name), true);
            end
            funct(pos(ovr)+1:pos(ovr)+length(funct1)) = funct1;
        end
    end
else
    ev = zeros(1,handles.egh.FileLength(filenum));
    indx = val-(length(str)-sum(nums));
    cs = cumsum(nums);
    f = length(find(cs<indx))+1;
    if f>1
        g = indx-cs(f-1);
    else
        g = indx;
    end
    tm = handles.egh.EventTimes{f}{g,filenum};
    issel = handles.egh.EventSelected{f}{g,filenum};
    ev(tm(issel==1)) = 1;
    funct = ev;
end

if get(handles.egh.popup_Functions(axnum),'value') > 1
    str = get(handles.egh.popup_Functions(axnum),'string');
    str = str{get(handles.egh.popup_Functions(axnum),'value')};
    f = strfind(str,' - ');
    if isempty(f)
        [funct, lab] = eg_runPlugin(handles.egh.plugins.filters, str, funct,handles.egh.fs,handles.egh.FunctionParams{axnum});
    else
        strall = get(handles.popup_Functions(axnum),'string');
        count = 0;
        for c = 1:get(handles.popup_Functions(axnum),'value')
            count = count + strcmp(strall{c}(1:min([f-1 length(strall{c})])),str(1:f-1));
        end
        [funct, lab] = eg_runPlugin(handles.egh.plugins.filters, str(1:f-1), funct,handles.egh.fs,handles.egh.FunctionParams{axnum});
        funct = funct{count};
        lab = lab{count};
    end
end

if isempty(funct)
    indx = [];
    return
end

if length(funct) < handles.egh.FileLength(filenum)
    indx = round(linspace(1,length(funct),handles.egh.FileLength(filenum)));
    funct = funct(indx);
end


if doSubsample == 1
    num_edges = ceil(length(funct)/0.5e6)+1;
    edges = round(linspace(0,length(funct),num_edges));
    if handles.P.event.contSmooth > 1
        for j = 1:length(edges)-1
            funct(edges(j)+1:edges(j+1)) = smooth(funct(edges(j)+1:edges(j+1)),handles.P.event.contSmooth);
        end
    end
    npt = round(handles.P.event.contSubsample*handles.egh.fs);
else
    npt = 1;
end

indx = 1:npt:length(funct);
indx = indx+round((length(funct)-indx(end))/2);
funct = funct(indx);

if size(funct,1)>size(funct,2)
    funct = funct';
end


% --------------------------------------------------------------------
function context_Color_Callback(~, ~, ~)
% hObject    handle to context_Color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Background_Callback(hObject, ~, handles)
% hObject    handle to menu_Background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

c = uisetcolor(handles.BackgroundColor,'Background color');
if length(c)<3
    return
end

handles.BackgroundColor = c;

set(handles.axes_PSTH,'color',handles.BackgroundColor);
set(handles.axes_Hist,'color',handles.BackgroundColor);
set(handles.axes_Raster,'color',handles.BackgroundColor);

guidata(hObject, handles);


function [handles, clim] = getCLim(handles)
if ~isfield(handles,'CLim')
    % CLim hasn't been defined yet. Define it first.
    handles.CLim = get(handles.axes_Raster,'clim');
end
clim = handles.CLim;

% --------------------------------------------------------------------
function menu_CLimits_Callback(hObject, ~, handles)
% hObject    handle to menu_CLimits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = getCLim(handles);
answer = inputdlg({'Min','Max'},'C-limits',1,{num2str(handles.CLim(1)),num2str(handles.CLim(2))});
if isempty(answer)
    return
end
handles.CLim(1) = str2double(answer{1});
handles.CLim(2) = str2double(answer{2});
set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Colormap_Callback(~, ~, ~)
% hObject    handle to menu_Colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_SetAutoCLim_Callback(hObject, ~, handles)
% hObject    handle to menu_SetAutoCLim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.axes_Raster,'CLimMode','auto');
handles.CLim = get(handles.axes_Raster,'clim');

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_EditColormap_Callback(~, ~, ~)
% hObject    handle to menu_EditColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

colormapeditor;


% --------------------------------------------------------------------
function menu_InvertColormap_Callback(~, ~, ~)
% hObject    handle to menu_InvertColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

col = colormap;
col = flipud(col);
colormap(col);


% --- Executes on button press in push_MinDown.
function push_MinDown_Callback(hObject, ~, handles)
% hObject    handle to push_MinDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(1) = handles.CLim(2) - df*1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MinUp.
function push_MinUp_Callback(hObject, ~, handles)
% hObject    handle to push_MinUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(1) = handles.CLim(2) - df/1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MaxDown.
function push_MaxDown_Callback(hObject, ~, handles)
% hObject    handle to push_MaxDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(2) = handles.CLim(1) + df/1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);

% --- Executes on button press in push_MaxUp.
function push_MaxUp_Callback(hObject, ~, handles)
% hObject    handle to push_MaxUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'CLim')
    handles.CLim = get(handles.axes_Raster,'clim');
end

df = range(handles.CLim);
handles.CLim(2) = handles.CLim(1) + df*1.1;

set(handles.axes_Raster,'clim',handles.CLim);

guidata(hObject, handles);


% --- Executes on selection change in popup_Correlation.
function popup_Correlation_Callback(~, ~, ~)
% hObject    handle to popup_Correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_Correlation contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Correlation


% --- Executes during object creation, after setting all properties.
function popup_Correlation_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_Correlation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_LogScale_Callback(~, ~, handles)
% hObject    handle to menu_LogScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(handles.menu_LogScale,'checked'),'on')
    set(handles.menu_LogScale,'checked','off');
else
    set(handles.menu_LogScale,'checked','on');
end


% --- Executes on button press in push_Select.
function push_Select_Callback(~, ~, handles)
% hObject    handle to push_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Select,'uicontextmenu',handles.context_Select);

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


% --------------------------------------------------------------------
function context_Select_Callback(~, ~, ~)
% hObject    handle to context_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_Select1_Callback(hObject, ~, handles)
% hObject    handle to menu_Select1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,1);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select2_Callback(hObject, ~, handles)
% hObject    handle to menu_Select2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,2);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select3_Callback(hObject, ~, handles)
% hObject    handle to menu_Select3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,3);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select4_Callback(hObject, ~, handles)
% hObject    handle to menu_Select4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,4);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select5_Callback(hObject, ~, handles)
% hObject    handle to menu_Select5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,5);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select6_Callback(hObject, ~, handles)
% hObject    handle to menu_Select6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,6);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select7_Callback(hObject, ~, handles)
% hObject    handle to menu_Select7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,7);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select8_Callback(hObject, ~, handles)
% hObject    handle to menu_Select8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,8);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select9_Callback(hObject, ~, handles)
% hObject    handle to menu_Select9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,9);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select10_Callback(hObject, ~, handles)
% hObject    handle to menu_Select11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,10);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select11_Callback(hObject, ~, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,11);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select12_Callback(hObject, ~, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,12);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select13_Callback(hObject, ~, handles)
% hObject    handle to menu_Select13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,13);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select14_Callback(hObject, ~, handles)
% hObject    handle to menu_Select14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,14);
guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_Select15_Callback(hObject, ~, handles)
% hObject    handle to menu_Select15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,15);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select16_Callback(hObject, ~, handles)
% hObject    handle to menu_Select16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,16);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select17_Callback(hObject, ~, handles)
% hObject    handle to menu_Select17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,17);
guidata(hObject, handles);

% --------------------------------------------------------------------
function menu_Select18_Callback(hObject, ~, handles)
% hObject    handle to menu_Select18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = menuSelectClick(handles,18);
guidata(hObject, handles);

function handles = menuSelectClick(handles,num);

if num == 2
    str1 = datestr(handles.Selection(num,1));
    str2 = datestr(handles.Selection(num,2));
else
    str1 = num2str(handles.Selection(num,1));
    str2 = num2str(handles.Selection(num,2));
end

mstr = get(handles.(['menu_Select' num2str(num)]),'Label');
answer = inputdlg({'From','To'},mstr,1,{str1,str2});
if isempty(answer)
    return
end

if num == 2
    handles.Selection(num,1) = datenum(answer{1});
    handles.Selection(num,2) = datenum(answer{2});
else
    handles.Selection(num,1) = str2double(answer{1});
    handles.Selection(num,2) = str2double(answer{2});
end


switch num
    case 1
        val = 1:length(handles.triggerInfo.absTime);
    case 2
        val = handles.triggerInfo.absTime;
    case 3
        val = handles.triggerInfo.currTrigOffset-handles.triggerInfo.currTrigOnset;
    case 4
        val = handles.triggerInfo.prevTrigOnset;
    case 5
        val = handles.triggerInfo.prevTrigOffset;
    case 6
        val = handles.triggerInfo.nextTrigOnset;
    case 7
        val = handles.triggerInfo.nextTrigOffset;
    case 8
        val = handles.FileRange(handles.triggerInfo.fileNum);
    case 9
        val = -inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOnsets{c}<0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOnsets{c}(f(end));
            end
        end
    case 10
        val = -inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOffsets{c}<0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOffsets{c}(f(end));
            end
        end
    case 11
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOnsets{c}>0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOnsets{c}(f(1));
            end
        end
    case 12
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            f = find(handles.triggerInfo.eventOffsets{c}>0);
            if ~isempty(f)
                val(c) = handles.triggerInfo.eventOffsets{c}(f(1));
            end
        end
    case 13
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOnsets{c});
                val(c) = min(handles.triggerInfo.eventOnsets{c});
            end
        end
    case 14
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOffsets{c});
                val(c) = min(handles.triggerInfo.eventOffsets{c});
            end
        end
    case 15
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOnsets{c});
                val(c) = max(handles.triggerInfo.eventOnsets{c});
            end
        end
    case 16
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            if ~isempty(handles.triggerInfo.eventOffsets{c});
                val(c) = max(handles.triggerInfo.eventOffsets{c});
            end
        end
    case 17
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            val(c) = length(handles.triggerInfo.eventOnsets{c});
        end
    case 18
        val = inf*ones(size(handles.triggerInfo.absTime));
        for c = 1:length(val)
            val(c) = (length(find(handles.triggerInfo.eventOnsets{c}<=0)) > length(find(handles.triggerInfo.eventOffsets{c}<0)));
        end
end

f = (val>=handles.Selection(num,1)-1e-5 & val<=handles.Selection(num,2)+1e-5);
handles.TriggerSelection = f.*handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);


% --------------------------------------------------------------------
function menu_SelectLabel_Callback(hObject, ~, handles)
% hObject    handle to menu_SelectLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.LabelRange)
    answer = inputdlg({'List of included labels ('''' for unlabeled). Leave empty to include all.','List of excluded labels'},'Trigger label',1,{handles.LabelSelectionInc,handles.LabelSelectionExc});
    if isempty(answer)
        return
    end

    handles.LabelSelectionInc = answer{1};
    handles.LabelSelectionExc = answer{2};

    f = strfind(handles.LabelSelectionInc,'''''');
    inc = handles.LabelSelectionInc;
    inc([f f+1]) = [];
    inc = double(inc);
    if ~isempty(f)
        inc = [inc 0];
    end

    f = strfind(handles.LabelSelectionExc,'''''');
    exc = handles.LabelSelectionExc;
    exc([f f+1]) = [];
    exc = double(exc);
    if ~isempty(f)
        exc = [exc 0];
    end

    f = zeros(1,length(handles.triggerInfo.absTime));
    for c = 1:length(handles.triggerInfo.absTime)
        if ~isempty(find(inc==handles.triggerInfo.label(c), 1)) || isempty(inc)
            f(c) = 1;
        end
        if ~isempty(find(exc==handles.triggerInfo.label(c), 1))
            f(c) = 0;
        end
    end
else
    answer = inputdlg({'From','To'},'Trigger label',1,{num2str(handles.LabelRange(1)),num2str(handles.LabelRange(2))});
    if isempty(answer)
        return
    end
    handles.LabelRange(1) = str2double(answer{1});
    handles.LabelRange(2) = str2double(answer{2});
    
    f = (handles.triggerInfo.label>=handles.LabelRange(1)+1000 & handles.triggerInfo.label<=handles.LabelRange(2)+1000);
end

handles.TriggerSelection = f.*handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_SelectAll_Callback(hObject, ~, handles)
% hObject    handle to menu_SelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.TriggerSelection = ones(size(handles.TriggerSelection));

set(handles.text_NumTriggers,'string',[num2str(length(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);


% --------------------------------------------------------------------
function menu_InvertSelection_Callback(hObject, ~, handles)
% hObject    handle to menu_InvertSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.TriggerSelection = 1-handles.TriggerSelection;

set(handles.text_NumTriggers,'string',[num2str(sum(handles.TriggerSelection)) ' triggers']);

guidata(hObject, handles);

function direction = getHistogramDirection(handles)
if strcmp(get(handles.push_HistHoriz, 'fontweight'), 'bold')
    direction = 'horizontal';
elseif strcmp(get(handles.push_HistVert,'fontweight'), 'bold')
    direction = 'vertical';
else
    direction = 'error';
end

function handles = setHistogramDirection(handles, direction)
switch direction
    case 'horizontal'
        set(handles.push_HistHoriz,'fontweight','bold');
        set(handles.push_HistVert,'fontweight','normal');
        set(handles.check_HistShow,'value',handles.HistShow(1));

        set(handles.popup_PSTHUnits,'visible','on');
        set(handles.popup_PSTHCount,'visible','on');
        set(handles.popup_HistUnits,'visible','off');
        set(handles.popup_HistCount,'visible','off');
    case 'vertical'
        set(handles.push_HistHoriz,'fontweight','normal');
        set(handles.push_HistVert,'fontweight','bold');
        set(handles.check_HistShow,'value',handles.HistShow(2));

        set(handles.popup_PSTHUnits,'visible','off');
        set(handles.popup_PSTHCount,'visible','off');
        set(handles.popup_HistUnits,'visible','on');
        set(handles.popup_HistCount,'visible','on');
end


% --- Executes on button press in push_HistHoriz.
function push_HistHoriz_Callback(hObject, ~, ~)
% hObject    handle to push_HistHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
handles = setHistogramDirection(handles, 'horizontal');
guidata(hObject, handles);

% --- Executes on button press in push_HistVert.
function push_HistVert_Callback(hObject, ~, ~)
% hObject    handle to push_HistVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
handles = setHistogramDirection(handles, 'vertical');
guidata(hObject, handles);

% --- Executes on button press in check_HistShow.
function check_HistShow_Callback(hObject, ~, handles)
% hObject    handle to check_HistShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_HistShow

handles = updateHistogramVisibility(handles);

guidata(hObject, handles);

function handles = updateHistogramVisibility(handles)

switch getHistogramDirection(handles)
    case 'horizontal'
        handles.HistShow(1) = get(handles.check_HistShow,'value');
    case 'vertical'
        handles.HistShow(2) = get(handles.check_HistShow,'value');
end

st = {'off','on'};
set(handles.axes_PSTH,'visible',st{handles.HistShow(1)+1});
set(get(handles.axes_PSTH,'children'),'visible',st{handles.HistShow(1)+1});
set(handles.axes_Hist,'visible',st{handles.HistShow(2)+1});
set(get(handles.axes_Hist,'children'),'visible',st{handles.HistShow(2)+1});

if handles.HistShow(1) == 1
    h = handles.AxisPosRaster(4);
else
    h = handles.AxisPosPSTH(4) + handles.AxisPosPSTH(2) - handles.AxisPosRaster(2);
end
if handles.HistShow(2) == 1
    w = handles.AxisPosRaster(3);
else
    w = handles.AxisPosHist(3) + handles.AxisPosHist(1) - handles.AxisPosRaster(1);
end

pos = get(handles.axes_Raster,'position');
pos(3) = w;
pos(4) = h;
set(handles.axes_Raster,'position',pos);

pos = get(handles.axes_PSTH,'position');
pos(3) = w;
set(handles.axes_PSTH,'position',pos);

pos = get(handles.axes_Hist,'position');
pos(4) = h;
drawnow
set(handles.axes_Hist,'position',pos);

% --- Executes on selection change in popup_HistUnits.
function popup_HistUnits_Callback(~, ~, ~)
% hObject    handle to popup_HistUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_HistUnits contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_HistUnits


% --- Executes during object creation, after setting all properties.
function popup_HistUnits_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_HistUnits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_HistCount.
function popup_HistCount_Callback(~, ~, ~)
% hObject    handle to popup_HistCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_HistCount contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_HistCount


% --- Executes during object creation, after setting all properties.
function popup_HistCount_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_HistCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in push_DeleteEvents.
function push_DeleteEvents_Callback(hObject, ~, handles)
% hObject    handle to push_DeleteEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

event_indx = get(handles.popup_EventList,'value');

for c = 10:12
    delete(handles.PlotHandles{c}{event_indx});
    handles.PlotHandles{c}(event_indx) = [];
end

if isempty(handles.AllEventOnsets)
    return
end

handles.AllEventOnsets(event_indx) = [];
handles.AllEventOffsets(event_indx) = [];
handles.AllEventLabels(event_indx) = [];
handles.AllEventSelections(event_indx) = [];
handles.AllEventOptions(event_indx) = [];
handles.AllEventPlots(event_indx,:) = [];

str = get(handles.popup_EventList,'string');
str(event_indx) = [];
if isempty(str)
    str = {'(None)'};
end
if get(handles.popup_EventList,'value') > length(str)
    set(handles.popup_EventList,'value',length(str));
end
set(handles.popup_EventList,'string',str);

guidata(hObject, handles);


% --- Executes on selection change in popup_EventList.
function popup_EventList_Callback(~, ~, ~)
% hObject    handle to popup_EventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_EventList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EventList


% --- Executes during object creation, after setting all properties.
function popup_EventList_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_EventList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_WarpingOn.
function check_WarpingOn_Callback(hObject, ~, handles)
% hObject    handle to check_WarpingOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_WarpingOn


if get(handles.check_WarpingOn,'value')==1
    handles.WarpPoints = handles.BackupWarp;
    set(handles.list_WarpPoints,'value',1);
    set(handles.list_WarpPoints,'string',handles.BackupWarpString);
else
    handles.BackupWarp = handles.WarpPoints;
    handles.BackupWarpString = get(handles.list_WarpPoints,'string');
    set(handles.list_WarpPoints,'value',1);
    set(handles.list_WarpPoints,'string',{'(None)'});
    handles.WarpPoints = {};
end

if get(handles.check_LockLimits,'value')==1
    set(handles.popup_StartReference,'value',get(handles.popup_TriggerAlignment,'value')+2);
    set(handles.popup_StopReference,'value',get(handles.popup_TriggerAlignment,'value'));
    if ~isempty(handles.WarpPoints)
        set(handles.popup_StartReference,'value',6);
        set(handles.popup_StopReference,'value',6);
    end
end

guidata(hObject, handles);



% --------------------------------------------------------------------
function context_MatlabExport_Callback(~, ~, ~)
% hObject    handle to context_MatlabExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(~, ~, ~)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_8_Callback(~, ~, ~)
% hObject    handle to Untitled_8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_11_Callback(~, ~, ~)
% hObject    handle to Untitled_11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in push_AutoColor.
function push_AutoColor_Callback(hObject, ~, handles)
% hObject    handle to push_AutoColor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

str = get(handles.popup_TriggerType,'string');
is_syllable = strcmp(str{get(handles.popup_TriggerType,'value')},'Syllables');
is_marker = strcmp(str{get(handles.popup_TriggerType,'value')},'Markers');

if ~isempty(handles.P.trig.includeSyllList) && (is_syllable || is_marker)
    inc = handles.P.trig.includeSyllList;
    inc = double(inc);
    f = strfind(inc,'''''');
    if ~isempty(f)
        inc(f+1) = [];
        inc(f) = 0;
    end
else
    inc = unique(handles.triggerInfo.label);
end

if ~isempty(handles.P.trig.ignoreSyllList) && (is_syllable || is_marker)
    exc = handles.P.trig.ignoreSyllList;
    exc = double(exc);
    f = strfind(exc,'''''');
    if ~isempty(f)
        exc(f+1) = [];
        exc(f) = 0;
    end
    for c = 1:length(exc)
        inc(inc==exc(c)) = [];
    end
end

if isempty(handles.PlotAutoColors)
    handles.PlotAutoColors = hsv(length(inc));
end

answ = 0;
val = get(handles.list_Plot,'value');
if handles.PlotContinuous(val)==1
    errordlg('Auto colors cannot be set for continuous objects!','Error');
    return
end

islast = 0;
while islast == 0
    str = {};
    for c = 1:size(handles.PlotAutoColors,1)
        hx = dec2hex(round(255*handles.PlotAutoColors(c,3)) + round(256*255*handles.PlotAutoColors(c,2)) + round(256^2*255*handles.PlotAutoColors(c,1)));
        if length(hx)< 6
            hx = [repmat('0',1,6-length(hx)) hx];
        end
        str{c} = ['<HTML>Change <FONT COLOR=' hx '>color #' num2str(c) '</FONT></HTML>'];
    end
    str{end+1} = ' ';
    str{end+1} = 'Set default colors';
    str{end+1} = 'Set number of colors';
    str{end+1} = ' ';
    str{end+1} = 'Remove first color';
    str{end+1} = 'Remove last color';
    str{end+1} = 'Add one color';
    str{end+1} = ' ';
    str{end+1} = 'Auto sort colors';
    str{end+1} = 'Permute up';
    str{end+1} = 'Permute down';
    str{end+1} = 'Flip color list';
    str{end+1} = ' ';
    str{end+1} = 'Apply current colors';
    
    [answ,ok] = listdlg('ListString',str,'Name','Auto color','PromptString','Select one of the options','SelectionMode','single','InitialValue',length(str));
    if ok==0
        return
    end
    
   indx = answ - size(handles.PlotAutoColors,1);
   switch indx
       case 1
           
       case 2
           handles.PlotAutoColors = hsv(length(inc));
       case 3
           answer = inputdlg({'Number of colors'},'Auto colors',1,{num2str(size(handles.PlotAutoColors,1))});
           if ~isempty(answer)
               handles.PlotAutoColors = hsv(str2double(answer{1}));
           end
       case 4
           
       case 5
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors(1,:) = [];
           end
       case 6
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors(end,:) = [];
           end
       case 7
           handles.PlotAutoColors(end+1,:) = handles.PlotColor(val,:);
       case 8
           
       case 9
           srt = zeros(size(inc));
           for c = 1:length(inc)
               srt(c) = mean(find(handles.triggerInfo.label==inc(c)));
           end
           [srt, ord] = sort(srt);
           [srt, ord] = sort(ord);
           if size(handles.PlotAutoColors,1)>=length(ord)
               handles.PlotAutoColors(1:length(ord),:) = handles.PlotAutoColors(ord,:);
           else
               num = ceil(length(ord)/size(handles.PlotAutoColors,1));
               handles.PlotAutoColors = repmat(handles.PlotAutoColors,num,1);
               handles.PlotAutoColors(length(ord)+1:end,:) = [];
               handles.PlotAutoColors = handles.PlotAutoColors(ord,:);
           end
       case 10
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors = handles.PlotAutoColors([2:end 1],:);
           end
       case 11
           if ~isempty(handles.PlotAutoColors)
               handles.PlotAutoColors = handles.PlotAutoColors([end 1:end-1],:);
           end
       case 12
           handles.PlotAutoColors = flipud(handles.PlotAutoColors);
       case 13
           
       case 14
           % apply current colors
       otherwise
           c = uisetcolor(handles.PlotAutoColors(answ,:),['Color #' num2str(answ)]);
           if length(c)==3
               handles.PlotAutoColors(answ,:) = c;
           end
   end
   
   islast = (answ == length(str));
end

lab = inf*ones(1,length(handles.triggerInfo.label));
for c = 1:length(handles.triggerInfo.label)
    f = find(inc == handles.triggerInfo.label(c));
    if ~isempty(f)
        lab(c) = f;
    end
end
md = mod(lab,size(handles.PlotAutoColors,1));
md(md==0) = size(handles.PlotAutoColors,1);

legend_str = '';
for c = 1:length(inc)
    colindx = mod(c,size(handles.PlotAutoColors,1));
    if colindx == 0
        colindx = size(handles.PlotAutoColors,1);
    end
    if inc(c) == 0
        lb = ' Unlabeled ';
    elseif is_syllable || is_marker
        lb = [' ' char(inc(c)) ' '];
    else
        lb = [' ' num2str(inc(c)-1000) ' '];
    end
    legend_str =  [legend_str '\color[rgb]{' num2str(handles.PlotAutoColors(colindx,:)) '}' lb];
end
subplot(handles.axes_Raster);
delete(findobj(gca,'type','text'));
xl = xlim;
yl = ylim;
tx = text(xl(2),yl(2),legend_str,'HorizontalAlignment','Right','VerticalAlignment','Top');
set(tx,'fontsize',10,'fontweight','bold','units','normalized');
set(tx,'backgroundcolor',handles.BackgroundColor);
set(tx,'buttondownfcn',get(handles.axes_Raster,'buttondownfcn'));


for m = 1:size(handles.PlotAutoColors,1)
    selection = (md==m);
    event_indx = get(handles.popup_EventList,'value');

    if val == 10 || val == 11 || val ==12
        indx2 = cumsum(cellfun('length',handles.AllEventOnsets{event_indx}));
        indx1 = [1 indx2(1:end-1)+1];
        indx = [];
        for c = find(selection==1)
            indx = [indx indx1(c):indx2(c)];
        end
    else
        indx = find(selection==1);
    end

    for c = intersect([1 2 4 5 7 8 13 15 16 19 20 22 23 25 26 28 29],val)
        set(handles.PlotHandles{c}(:,indx),'color',handles.PlotAutoColors(m,:));
    end
    for c = intersect([10 11],val)
        if ~isempty(handles.PlotHandles{c}{event_indx})
            set(handles.PlotHandles{c}{event_indx}(indx),'color',handles.PlotAutoColors(m,:));
        end
    end
    for c = intersect([14 30],val)
        set(handles.PlotHandles{c},'facecolor',handles.PlotAutoColors(m,:),'edgecolor',handles.PlotAutoColors(m,:));
    end
    for c = intersect([3 6 9 12 17 18 21 24 27],val)
        if iscell(handles.PlotHandles{c})
            h = handles.PlotHandles{c}{event_indx};
        else
            h = handles.PlotHandles{c};
        end
        if ~isempty(h)
            cdt = get(h,'cdata');
            if length(size(cdt))==3
                sz = [length(indx) 1];
                cdt(indx,1,:) = cat(3,handles.PlotAutoColors(m,1)*ones(sz),handles.PlotAutoColors(m,2)*ones(sz),handles.PlotAutoColors(m,3)*ones(sz));
                set(h,'cdata',cdt);
            else
                set(h,'facecolor',handles.PlotAutoColors(m,:));
            end
        end
    end
end

guidata(hObject, handles);


% --- Executes on button press in check_GroupLabels.
function check_GroupLabels_Callback(hObject, ~, handles)
% hObject    handle to check_GroupLabels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_GroupLabels

handles = AutoInclude(handles);
guidata(hObject, handles);

% --- Executes on button press in push_MatlabExport.
function push_MatlabExport_Callback(~, ~, handles)
% hObject    handle to push_MatlabExport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.push_Colors,'uicontextmenu',handles.context_MatlabExport);

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



% --- Executes on button press in check_AutoInclude.
function check_AutoInclude_Callback(hObject, ~, handles)
% hObject    handle to check_AutoInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_AutoInclude


handles = AutoInclude(handles);
guidata(hObject, handles);


function handles = AutoInclude(handles)

if get(handles.check_AutoInclude,'value')==0
    return
end

str = get(handles.popup_PrimarySort,'string');
str1 = str{get(handles.popup_PrimarySort,'value')};
str = get(handles.popup_SecondarySort,'string');
str2 = str{get(handles.popup_SecondarySort,'value')};

if get(handles.check_GroupLabels,'value')==1 || ~strcmp(str2,'Absolute time')
    str = str2;
else
    str = str1;
end

str_obj = get(handles.list_Plot,'string');
for c = [1 2 4 5 7 8]
    str_curr = str_obj{c};
    if strcmp(str_obj{c}(26:end-14),str)
        handles.PlotInclude(c) = 1;
    else
        handles.PlotInclude(c) = 0;
    end
end
if strcmp(str,'Trigger duration')
    for c = [4 5]
        handles.PlotInclude(c) = 1;
    end
end
str = get(handles.popup_TriggerAlignment,'string');
str = str{get(handles.popup_TriggerAlignment,'value')};
if strcmp(str,'Onset')
    handles.PlotInclude(4) = 1;
end
if strcmp(str,'Offset')
    handles.PlotInclude(5) = 1;
end

handles = updatePlotIncludeColors(handles);

set(handles.check_PlotInclude,'value',handles.PlotInclude(get(handles.list_Plot,'value')));


% --- Executes on button press in check_SkipSorting.
function check_SkipSorting_Callback(~, ~, ~)
% hObject    handle to check_SkipSorting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_SkipSorting


function handles = Fix_Overlap(handles)
% Note that this is normally called like so:
% handles.egh = Fix_Overlap(handles.egh)
% So the 'handles' struct is really the electro_gui handles struct.

handles.Overlaps = 1:length(handles.DatesAndTimes);

answer = inputdlg({'File overlap tolerance (sec). Press cancel to omit fixing overlaps.'},'File overlaps',1,{num2str(handles.overlaptolerance)});
if isempty(answer)
    return
end

handles.overlaptolerance = str2double(answer{1});
tol = handles.overlaptolerance*handles.fs;

for c = length(handles.DatesAndTimes)-1:-1:1
    if handles.FileLength(c)==0 || handles.FileLength(c+1)==0
        continue
    end
    
    if handles.DatesAndTimes(c) + (handles.FileLength(c) + tol)/(24*60*60)/handles.fs > handles.DatesAndTimes(c+1)
        handles.SegmentTimes{c} = [handles.SegmentTimes{c}; handles.SegmentTimes{c+1}+round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs)];
        handles.SegmentTimes{c+1} = zeros(0,2);
        handles.SegmentTitles{c} = [handles.SegmentTitles{c} handles.SegmentTitles{c+1}];
        handles.SegmentTitles{c+1} = {};
        handles.SegmentSelection{c} = [handles.SegmentSelection{c} handles.SegmentSelection{c+1}];
        handles.SegmentSelection{c+1} = [];

        handles.MarkerTimes{c} = [handles.MarkerTimes{c}; handles.MarkerTimes{c+1}+round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs)];
        handles.MarkerTimes{c+1} = zeros(0,2);
        handles.MarkerTitles{c} = [handles.MarkerTitles{c} handles.MarkerTitles{c+1}];
        handles.MarkerTitles{c+1} = {};
        handles.MarkerSelection{c} = [handles.MarkerSelection{c} handles.MarkerSelection{c+1}];
        handles.MarkerSelection{c+1} = [];
        
        for d = 1:length(handles.EventTimes)
            for e = 1:size(handles.EventTimes{d},1)
                handles.EventTimes{d}{e,c} = [handles.EventTimes{d}{e,c}; handles.EventTimes{d}{e,c+1}+round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs)];
                handles.EventTimes{d}{e,c+1} = [];
                handles.EventSelected{d}{e,c} = [handles.EventSelected{d}{e,c} handles.EventSelected{d}{e,c+1}];
                handles.EventSelected{d}{e,c+1} = [];
            end
        end
        handles.FileLength(c) = round((handles.DatesAndTimes(c+1)-handles.DatesAndTimes(c))*(24*60*60)*handles.fs + handles.FileLength(c+1));
        
        handles.Overlaps(handles.Overlaps==c+1) = c;
    end
    
end

for c = 1:length(handles.DatesAndTimes)
    [~, ord] = sortrows(handles.SegmentTimes{c});
    handles.SegmentTimes{c} = handles.SegmentTimes{c}(ord,:);
    handles.SegmentTitles{c} = handles.SegmentTitles{c}(ord);
    handles.SegmentSelection{c} = handles.SegmentSelection{c}(ord);

    [~, ord] = sortrows(handles.MarkerTimes{c});
    handles.MarkerTimes{c} = handles.MarkerTimes{c}(ord,:);
    handles.MarkerTitles{c} = handles.MarkerTitles{c}(ord);
    handles.MarkerSelection{c} = handles.MarkerSelection{c}(ord);

    for d = 1:length(handles.EventTimes)
        [~, ord] = sort(handles.EventTimes{d}{1,c});
        for e = 1:size(handles.EventTimes{d},1)
            handles.EventTimes{d}{e,c} = handles.EventTimes{d}{e,c}(ord);
            handles.EventSelected{d}{e,c} = handles.EventSelected{d}{e,c}(ord);
        end
    end
    
    % Syllable overlaps
    for d = size(handles.SegmentTimes{c},1)-1:-1:1
        f = find((1:size(handles.SegmentTimes{c},1))' > d & handles.SegmentTimes{c}(d,2) > handles.SegmentTimes{c}(:,1));
        if ~isempty(f)
            handles.SegmentTimes{c}(d,1) = min(handles.SegmentTimes{c}(d:max(f),1));
            handles.SegmentTimes{c}(d,2) = max(handles.SegmentTimes{c}(d:max(f),2));
            handles.SegmentTimes{c}(d+1:max(f),:) = [];
            handles.SegmentTitles{c}(d+1:max(f)) = [];
            handles.SegmentSelection{c}(d+1:max(f)) = [];
        end
    end
    
    % Marker overlaps
    for d = size(handles.MarkerTimes{c},1)-1:-1:1
        f = find((1:size(handles.MarkerTimes{c},1))' > d & handles.MarkerTimes{c}(d,2) > handles.MarkerTimes{c}(:,1));
        if ~isempty(f)
            handles.MarkerTimes{c}(d,1) = min(handles.MarkerTimes{c}(d:max(f),1));
            handles.MarkerTimes{c}(d,2) = max(handles.MarkerTimes{c}(d:max(f),2));
            handles.MarkerTimes{c}(d+1:max(f),:) = [];
            handles.MarkerTitles{c}(d+1:max(f)) = [];
            handles.MarkerSelection{c}(d+1:max(f)) = [];
        end
    end
    
    % Event overlaps
    for d = 1:length(handles.EventTimes)
        for e = length(handles.EventTimes{d}{1,c})-1:-1:1
            if handles.EventTimes{d}{1,c}(e+1)-handles.EventTimes{d}{1,c}(e) < tol
                for i = 1:size(handles.EventTimes{d},1)
                    handles.EventTimes{d}{i,c}(e+1) = [];
                    handles.EventSelected{d}{i,c}(e+1) = [];
                end
            end
        end
    end
end


% --------------------------------------------------------------------
function menu_ExportData_Callback(~, ~, handles)
% hObject    handle to menu_ExportData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[file, path] = uiputfile('raster.mat','Save trigger info');
if ~ischar(file)
    return
end

triggerInfo = handles.triggerInfo;

triggerInfo.eventOnsets = handles.AllEventOnsets;
triggerInfo.eventOffsets = handles.AllEventOffsets;
triggerInfo.eventLabels = handles.AllEventLabels;
triggerInfo.eventNames = get(handles.popup_EventList,'string')';
for warpInterval = 1:length(triggerInfo.eventNames)
    f = strfind(triggerInfo.eventNames{warpInterval},'Syllables');
    if ~isempty(f)
        triggerInfo.eventNames{warpInterval} = '[Syllables] Sound';
    else
        f = strfind(triggerInfo.eventNames{warpInterval},'-');
        triggerInfo.eventNames{warpInterval} = triggerInfo.eventNames{warpInterval}(1:f(end)-2);
    end
end

triggerInfo.eventOptions = handles.AllEventOptions;

triggerInfo.filterNames = get(handles.list_Filter,'string');
f = find(handles.P.filter(:,1)>-inf | handles.P.filter(:,2)<inf);
triggerInfo.filterNames = triggerInfo.filterNames(f);
triggerInfo.filterLimits = handles.P.filter(f,:);

str = get(handles.popup_TriggerType,'string');
tr_str = str{get(handles.popup_TriggerType,'value')};
str = get(handles.popup_TriggerSource,'string');
tr_str = ['[' tr_str '] ' str{get(handles.popup_TriggerSource,'value')}];
triggerInfo.trigName = tr_str;
triggerInfo.trigOptions = handles.P.trig;
str = get(handles.popup_TriggerAlignment,'string');
triggerInfo.trigAlignment = str{get(handles.popup_TriggerAlignment,'value')};
triggerInfo.trigSelection = handles.AllEventSelections;

W = {};
str = get(handles.popup_WarpingAlgorithm,'string');
W.algorithm = str{get(handles.popup_WarpingAlgorithm,'value')};
W.maxCorrShift = handles.corrMax;
warpIntervals = [handles.WarpIntervalLim(1):-1 1:handles.WarpIntervalLim(2)];
str = {'Mean','Median','Maximum','Custom'};
W.intervals.numBefore = handles.WarpNumBefore;
W.intervals.numAfter = handles.WarpNumAfter;
W.intervals.types = str(handles.WarpIntervalType);
W.intervals.customDurations = handles.WarpIntervalDuration;
W.intervals.customDurations(handles.WarpIntervalType<4) = NaN;

f = find(warpIntervals<-handles.WarpNumBefore | warpIntervals>handles.WarpNumAfter);
W.intervals.types(f) = [];
W.intervals.customDurations(f) = [];
warpIntervals(f) = [];

for warpInterval = -1:-1:-handles.WarpNumBefore
    if isempty(find(warpIntervals==warpInterval, 1))
        W.intervals.types = ['Mean' W.intervals.types];
        W.intervals.customDurations = [NaN W.intervals.customDurations];
    end
end
for warpInterval = 1:handles.WarpNumAfter
    if isempty(find(warpIntervals==warpInterval, 1))
        W.intervals.types = [W.intervals.types 'Mean'];
        W.intervals.customDurations = [W.intervals.customDurations NaN];
    end
end

W.points = {};
for warpIdx = 1:length(handles.WarpPoints);
    str = get(handles.popup_TriggerSource,'string');
    W.points{warpIdx}.name = ['[' handles.WarpPoints{warpIdx}.type '] ' str{handles.WarpPoints{warpInwarpIdxterval}.source+1}];
    W.points{warpIdx}.alignment = handles.WarpPoints{warpIdx}.alignment;
    W.points{warpIdx}.options = handles.WarpPoints{warpIdx}.P;
end
triggerInfo.warpOptions = W;

str = get(handles.popup_PrimarySort,'string');
triggerInfo.sortOptions.primary.name = str{get(handles.popup_PrimarySort,'value')};
triggerInfo.sortOptions.primary.isDescending = get(handles.check_PrimaryDescending,'value');
triggerInfo.sortOptions.primary.groupLabels = get(handles.check_GroupLabels,'value');
str = get(handles.popup_SecondarySort,'string');
triggerInfo.sortOptions.secondary.name = str{get(handles.popup_SecondarySort,'value')};
triggerInfo.sortOptions.secondary.isDescending = get(handles.check_SecondaryDescending,'value');

str = get(handles.popup_StartReference,'string');
triggerInfo.windowOptions.startRef = str{get(handles.popup_StartReference,'value')};
triggerInfo.windowOptions.preStartRef = handles.P.preStartRef;
str = get(handles.popup_StopReference,'string');
triggerInfo.windowOptions.stopRef = str{get(handles.popup_StopReference,'value')};
triggerInfo.windowOptions.postStopRef = handles.P.postStopRef;

triggerInfo.windowOptions.excludePartialWindows = get(handles.check_ExcludeIncomplete,'value');
triggerInfo.windowOptions.excludeParialEvents = get(handles.check_ExcludePartialEvents,'value');

str = get(handles.popup_Correlation,'string');
triggerInfo.corrAlignment = str{get(handles.popup_Correlation,'value')};

if isfield(triggerInfo,'contLabel')
    triggerInfo = rmfield(triggerInfo,'contLabel');
end

triggerInfo.filteredEvents = handles.filteredEvents;
triggerInfo.sortedEvents = handles.sortedEvents;

trigInfo = orderfields(triggerInfo,[23:25 21:22 31 2 4:5 29 3 6:7 8:13 26 19:20 14:16 30 1 17:18 27:28 32]);

save([path file],'trigInfo');



% --------------------------------------------------------------------
function menu_ExportFigure_Callback(~, ~, handles)
% hObject    handle to menu_ExportFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fig = figure;

ax = copyobj(handles.axes_Raster,fig);
if handles.HistShow(1) == 1
    h = .6;
else
    h = .85;
end
if handles.HistShow(2) == 1
    w = .6;
else
    w = .85;
end
set(ax,'position',[.1 .1 w h]);
set(ax,'buttondownfcn','');
set(get(ax,'children'),'buttondownfcn','');

if handles.HistShow(1) == 1
    ax = copyobj(handles.axes_PSTH,fig);
    set(ax,'position',[.1 .75 w .2]);
    set(ax,'buttondownfcn','');
    set(get(ax,'children'),'buttondownfcn','');
end

if handles.HistShow(2) == 1
    ax = copyobj(handles.axes_Hist,fig);
    set(ax,'position',[.75 .1 .2 h]);
    set(ax,'buttondownfcn','');
    set(get(ax,'children'),'buttondownfcn','');
end


% --- Executes on selection change in popup_Presets.
function popup_Presets_Callback(~, ~, ~)
% hObject    handle to popup_Presets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_Presets contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_Presets


% --- Executes during object creation, after setting all properties.
function popup_Presets_CreateFcn(hObject, ~, ~)
% hObject    handle to popup_Presets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function handles = loadPresets(handles)
presets = findPresets(handles.preset_prefix);
if isempty(presets)
    set(handles.popup_Presets, 'Value', 1); % If you reduce the # of elements in the popup such that it is greater than the current selection index ('Value') the popup just...disappears.
    set(handles.popup_Presets, 'String', handles.no_presets_found);
    set(handles.popup_Presets, 'enable', 'off');
    set(handles.push_LoadPreset, 'enable', 'off');
    set(handles.push_DeletePreset, 'enable', 'off');
else
    if get(handles.popup_Presets, 'Value') > length(presets)
        % If you reduce the # of elements in the popup such that it is 
        %   greater than the current selection index ('Value') the popup 
        %   just...disappears. It's a MATLAB bug. 
        set(handles.popup_Presets, 'Value', length(presets));
    end
    set(handles.popup_Presets, 'String', presets);
    set(handles.popup_Presets, 'enable', 'on');
    set(handles.push_LoadPreset, 'enable', 'on');
    set(handles.push_DeletePreset, 'enable', 'on');
end


function [ok, badChars, allowedChars] = isNameOk(name)
% Check that name does not contain any disallowed characters
allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
okChars = ismember(name, allowedChars);
if any(~okChars)
    % Name contains disallowed characters
    badChars = sort(unique(name(~okChars)));
    ok = false;
else
    badChars = '';
    ok = true;
end

function names = findPresets(prefix)
% Create a struct array containing the name and path to all raster preset files'
f = dir([prefix, '*.mat']);
names = {};
for k = 1:length(f)
    [~, fileName, ~] = fileparts(f(k).name);
    name = regexp(fileName, [prefix, '(.*)'], 'tokens', 'once');
    name = name{1};
    [ok, disallowedChars, allowedChars] = isNameOk(name);
    if ~ok
        warning('Name of plugin ''%s'' contains disallowed characters: ''%s''\nPlease change plugin name so it only includes the characters: \n%s', name, disallowedChars, allowedChars);
        continue;
    end
    names{k} = name;
end
% disp('Presets found:')
% disp(names)

% --- Executes on button press in push_LoadPreset.
function push_LoadPreset_Callback(hObject, ~, handles)
% hObject    handle to push_LoadPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

presetNames = get(handles.popup_Presets, 'String');
selectedPresetIdx = get(handles.popup_Presets, 'Value');
selectedPresetName = presetNames{selectedPresetIdx};
if strcmp(selectedPresetName, handles.no_presets_found)
    % No presets exist, this shouldn't even be able to run.
    return;
end
presetFileName = [handles.preset_prefix, selectedPresetName];
s = load(presetFileName);
preset = s.preset;

fprintf('Loading preset %s...\n', presetFileName);

% Trigger options
set(handles.popup_Files, 'Value', preset.popup_Files);
set(handles.popup_TriggerSource, 'Value', preset.popup_TriggerSource);
set(handles.popup_TriggerType, 'Value', preset.popup_TriggerType);
set(handles.check_CopyEvents, 'Value', preset.check_CopyEvents);
set(handles.popup_TriggerAlignment, 'Value', preset.popup_TriggerAlignment);

% Trigger/Event options
set(handles.popup_EventSource, 'Value', preset.popup_EventSource);
set(handles.popup_EventType, 'Value', preset.popup_EventType);
handles.P = preset.P;
handles = respondToEventSourceChange(handles);

set(handles.check_WarpingOn, 'Value', preset.check_WarpingOn);

% Time warping options
set(handles.popup_Correlation, 'Value', preset.popup_Correlation);
set(handles.list_WarpPoints, 'Value', preset.list_WarpPoints);
set(handles.popup_WarpingAlgorithm, 'Value', preset.popup_WarpingAlgorithm);
handles = setWarpOptions(handles, preset.corrMax, preset.WarpNumBefore, preset.WarpNumAfter);
handles = setWarpIntervalInfo(handles, preset.warpIntervalDurations, preset.warpIntervalTypes, preset.warpIntervalLim, preset.warpNumBefore, preset.warpNumAfter);

% Filtering options
set(handles.list_Filter, 'Value', preset.list_Filter);
set(handles.edit_FilterFrom, 'String', preset.edit_FilterFrom);
set(handles.edit_FilterTo, 'String', preset.edit_FilterTo);

% Window options
set(handles.check_LockLimits, 'Value', preset.check_LockLimits);
set(handles.check_ExcludeIncomplete, 'Value', preset.check_ExcludeIncomplete);
set(handles.check_ExcludePartialEvents, 'Value', preset.check_ExcludePartialEvents);
set(handles.popup_StartReference, 'Value', preset.popup_StartReference);
set(handles.popup_StopReference, 'Value', preset.popup_StopReference);

% Raster color options
handles.BackgroundColor = preset.BackgroundColor;
handles.CLim = preset.CLim;
colormap(preset.colormap);
set(handles.menu_LogScale, 'Checked', preset.logScale);

% Event selection options
set(handles.popup_EventList, 'Value', preset.popup_EventList);
set(handles.check_HoldOn, 'Value', preset.check_HoldOn);
set(handles.check_SkipSorting, 'Value', preset.check_SkipSorting);

% Exporting options
set(handles.radio_HeightAbsolute, 'Value', preset.radio_HeightAbsolute);
set(handles.radio_HeightPerTrial, 'Value', preset.radio_HeightPerTrial);
set(handles.radio_HeightPerTime, 'Value', preset.radio_HeightPerTime);
set(handles.radio_WidthAbsolute, 'Value', preset.radio_WidthAbsolute);
set(handles.radio_WidthPerTime, 'Value', preset.radio_WidthPerTime);
set(handles.check_IncludePSTH, 'Value', preset.check_IncludePSTH);
handles = setDimensions(handles, preset.ExportPSTHHeight, preset.ExportHistHeight, preset.ExportInterval, preset.ExportResolution, preset.ExportWidth, preset.ExportHeight);

% Histogram options
set(handles.check_HistShow, 'Value', preset.check_HistShow);
handles = updateHistogramVisibility(handles);

set(handles.radio_PSTHAuto, 'Value', preset.radio_PSTHAuto);
set(handles.radio_PSTHManual, 'Value', preset.radio_PSTHManual);
handles = setHistogramDirection(handles, preset.histogram_direction);
set(handles.popup_HistUnits, 'Value', preset.popup_HistUnits);
set(handles.popup_PSTHUnits, 'Value', preset.popup_PSTHUnits);
set(handles.popup_HistCount, 'Value', preset.popup_HistCount);
set(handles.popup_PSTHCount, 'Value', preset.popup_PSTHCount);
handles.PSTHBinSize = preset.PSTHBinSize;
handles.PSTHSmoothingWindow = preset.PSTHSmoothingWindow;
handles.PSTHYLim = preset.PSTHYLim;
handles.PSTHYLim = preset.PSTHYLim;
handles.HistBinSize = preset.HistBinSize;
handles.HistSmoothingWindow = preset.HistSmoothingWindow;
handles.ROILim = preset.ROILim;
handles.ROILim = preset.ROILim;
handles.HistYLim = preset.HistYLim;
handles.HistYLim = preset.HistYLim;

val = preset.popup_PSTHUnits;
if strcmp(get(handles.popup_EventType,'enable'),'off')
    val = val + 3;
end
if preset.radio_PSTHManual == 1
    set(handles.axes_PSTH,'ylim',handles.PSTHYLim(val,:));
end
if preset.radio_YTrial == 1
    val = 1;
else
    val = 2;
end
if preset.radio_PSTHManual==1
    set(handles.axes_Hist,'xlim',handles.HistYLim(val,:));
end

% Raster options
set(handles.list_Plot, 'Value', preset.list_Plot);
set(handles.check_AutoInclude, 'Value', preset.check_AutoInclude);
set(handles.check_PlotInclude, 'Value', preset.check_PlotInclude);
set(handles.check_PlotContinuous, 'Value', preset.check_PlotContinuous);
handles = setPlotColors(handles, preset.plotColor);
handles.PlotInclude = preset.plotInclude;

handles.PlotLineWidth = preset.PlotLineWidth;
handles.PlotAlpha = preset.PlotAlpha;
set(handles.radio_TickTrials, 'Value', preset.radio_TickTrials);
set(handles.radio_TickSeconds, 'Value', preset.radio_TickSeconds);
set(handles.radio_TickInches, 'Value', preset.radio_TickInches);
set(handles.radio_TickPercent, 'Value', preset.radio_TickPercent);
handles.PlotTickSize = preset.PlotTickSize;
handles.PlotInPerSec = preset.PlotInPerSec;
handles.PlotOverlap = preset.PlotOverlap;
set(handles.check_CopyWindow, 'Value', preset.check_CopyWindow);
set(handles.radio_YTrial, 'Value', preset.radio_YTrial);
set(handles.radio_YTime, 'Value', preset.radio_YTime);
handles = setTimeLimits(handles, preset.push_TimeLimits_min, preset.push_TimeLimits_max);

% Sorting options
set(handles.popup_PrimarySort, 'Value', preset.popup_PrimarySort);
set(handles.check_PrimaryDescending, 'Value', preset.check_PrimaryDescending);
set(handles.check_GroupLabels, 'Value', preset.check_GroupLabels);
set(handles.popup_SecondarySort, 'Value', preset.popup_SecondarySort);
set(handles.check_SecondaryDescending, 'Value', preset.check_SecondaryDescending);

guidata(hObject, handles);
fprintf('...done loading preset\n');

% --- Executes on button press in push_SavePreset.
function push_SavePreset_Callback(hObject, ~, handles)
% hObject    handle to push_SavePreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gather all relevant settings and save them as a preset structure in a mat
% file.
allowedChars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
answer = inputdlg({['Please enter a name for this new preset, using only the characters ', allowedChars]}, 'Save new preset', 1, {'NewPreset'});
if isempty(answer)
    disp('Save preset cancelled');
    return;
end
newPresetName = answer{1};
newPresetFilename = [handles.preset_prefix, newPresetName, '.mat'];
if exist(newPresetFilename, 'file')
    overwrite = questdlg(sprintf('A preset by the name %s already exists. Overwrite?', newPresetName));
    if ~strcmp(overwrite, 'Yes')
        disp('Save preset cancelled');
        return
    end
end

% Trigger options
preset.popup_Files = get(handles.popup_Files, 'Value');
preset.popup_TriggerSource = get(handles.popup_TriggerSource, 'Value');
preset.popup_TriggerType = get(handles.popup_TriggerType, 'Value');
preset.check_CopyEvents = get(handles.check_CopyEvents, 'Value');
preset.popup_TriggerAlignment = get(handles.popup_TriggerAlignment, 'Value');

% Trigger/Event options
preset.popup_EventSource = get(handles.popup_EventSource, 'Value');
preset.popup_EventType = get(handles.popup_EventType, 'Value');
preset.P = handles.P;

preset.check_WarpingOn = get(handles.check_WarpingOn, 'Value');

% Time warping options
preset.popup_Correlation = get(handles.popup_Correlation, 'Value');
preset.list_WarpPoints = get(handles.list_WarpPoints, 'Value');
preset.popup_WarpingAlgorithm = get(handles.popup_WarpingAlgorithm, 'Value');
[preset.corrMax, preset.WarpNumBefore, preset.WarpNumAfter] = getWarpOptions(handles);

[preset.warpIntervalDurations, preset.warpIntervalTypes, preset.warpIntervalLim, preset.warpNumBefore, preset.warpNumAfter] = getWarpIntervalInfo(handles);

% Filtering options
preset.list_Filter = get(handles.list_Filter, 'Value');
preset.edit_FilterFrom = get(handles.edit_FilterFrom, 'String');
preset.edit_FilterTo = get(handles.edit_FilterTo, 'String');

% Window options
preset.check_LockLimits = get(handles.check_LockLimits, 'Value');
preset.check_ExcludeIncomplete = get(handles.check_ExcludeIncomplete, 'Value');
preset.check_ExcludePartialEvents = get(handles.check_ExcludePartialEvents, 'Value');
preset.popup_StartReference = get(handles.popup_StartReference, 'Value');
preset.popup_StopReference = get(handles.popup_StopReference, 'Value');

% Raster color options
preset.BackgroundColor = handles.BackgroundColor;
[handles, preset.CLim] = getCLim(handles);
preset.colormap = colormap;
preset.logScale = get(handles.menu_LogScale, 'Checked');

% Event selection options
preset.popup_EventList = get(handles.popup_EventList, 'Value');
preset.check_HoldOn = get(handles.check_HoldOn, 'Value');
preset.check_SkipSorting = get(handles.check_SkipSorting, 'Value');

% Exporting options
preset.radio_HeightAbsolute = get(handles.radio_HeightAbsolute, 'Value');
preset.radio_HeightPerTrial = get(handles.radio_HeightPerTrial, 'Value');
preset.radio_HeightPerTime = get(handles.radio_HeightPerTime, 'Value');
preset.radio_WidthAbsolute = get(handles.radio_WidthAbsolute, 'Value');
preset.radio_WidthPerTime = get(handles.radio_WidthPerTime, 'Value');
preset.check_IncludePSTH = get(handles.check_IncludePSTH, 'Value');
[preset.ExportPSTHHeight, preset.ExportHistHeight, preset.ExportInterval, preset.ExportResolution, preset.ExportWidth, preset.ExportHeight] = getDimensons(handles);

% Histogram options
preset.check_HistShow = get(handles.check_HistShow, 'Value');
preset.radio_PSTHAuto = get(handles.radio_PSTHAuto, 'Value');
preset.radio_PSTHManual = get(handles.radio_PSTHManual, 'Value');
preset.histogram_direction = getHistogramDirection(handles);
preset.popup_HistUnits = get(handles.popup_HistUnits, 'Value');
preset.popup_PSTHUnits = get(handles.popup_PSTHUnits, 'Value');
preset.popup_HistCount = get(handles.popup_HistCount, 'Value');
preset.popup_PSTHCount = get(handles.popup_PSTHCount, 'Value');
preset.PSTHBinSize = handles.PSTHBinSize;
preset.PSTHSmoothingWindow = handles.PSTHSmoothingWindow;
preset.PSTHYLim = handles.PSTHYLim;
preset.PSTHYLim = handles.PSTHYLim;
preset.HistBinSize = handles.HistBinSize;
preset.HistSmoothingWindow = handles.HistSmoothingWindow;
preset.ROILim = handles.ROILim;
preset.ROILim = handles.ROILim;
preset.HistYLim = handles.HistYLim;
preset.HistYLim = handles.HistYLim;

% Raster options
preset.list_Plot = get(handles.list_Plot, 'Value');
preset.check_AutoInclude = get(handles.check_AutoInclude, 'Value');
preset.check_PlotInclude = get(handles.check_PlotInclude, 'Value');
preset.check_PlotContinuous = get(handles.check_PlotContinuous, 'Value');

preset.plotColor = getPlotColors(handles);
preset.plotInclude = handles.PlotInclude;

preset.PlotLineWidth = handles.PlotLineWidth;
preset.PlotAlpha = handles.PlotAlpha;
preset.radio_TickTrials = get(handles.radio_TickTrials, 'Value');
preset.radio_TickSeconds = get(handles.radio_TickSeconds, 'Value');
preset.radio_TickInches = get(handles.radio_TickInches, 'Value');
preset.radio_TickPercent = get(handles.radio_TickPercent, 'Value');
preset.PlotTickSize = handles.PlotTickSize;
preset.PlotInPerSec = handles.PlotInPerSec;
preset.PlotOverlap = handles.PlotOverlap;
preset.check_CopyWindow = get(handles.check_CopyWindow, 'Value');
preset.radio_YTrial = get(handles.radio_YTrial, 'Value');
preset.radio_YTime = get(handles.radio_YTime, 'Value');
[preset.push_TimeLimits_min, preset.push_TimeLimits_max] = getTimeLimits(handles);

% Sorting options
preset.popup_PrimarySort = get(handles.popup_PrimarySort, 'Value');
preset.check_PrimaryDescending = get(handles.check_PrimaryDescending, 'Value');
preset.check_GroupLabels = get(handles.check_GroupLabels, 'Value');
preset.popup_SecondarySort = get(handles.popup_SecondarySort, 'Value');
preset.check_SecondaryDescending = get(handles.check_SecondaryDescending, 'Value');

save(newPresetFilename, 'preset');
fprintf('Saved new preset: %s\n', newPresetFilename);
handles = loadPresets(handles);
guidata(hObject, handles);

% --- Executes on button press in push_ReloadPreset.
function push_ReloadPreset_Callback(hObject, ~, handles)
% hObject    handle to push_ReloadPreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = loadPresets(handles);
guidata(hObject, handles);


% --- Executes on button press in push_DeletePreset.
function push_DeletePreset_Callback(hObject, ~, handles)
% hObject    handle to push_DeletePreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

presetNames = get(handles.popup_Presets, 'String');
selectedPresetIdx = get(handles.popup_Presets, 'Value');
selectedPresetName = presetNames{selectedPresetIdx};
if strcmp(selectedPresetName, handles.no_presets_found)
    % No presets exist, this shouldn't even be able to run.
    return;
end

fprintf('Deleting preset %s...\n', selectedPresetName);

% Check if user really wants to delete the preset
reallyDelete = questdlg(sprintf('Are you sure you want to delete the preset called %s?', selectedPresetName));

if ~strcmp(reallyDelete, 'Yes')
    % User did not in fact want to delete the preset
    disp('Delete preset cancelled');
    return
end

% User confirmed preset delete
selectedPresetFilename = [handles.preset_prefix, selectedPresetName, '.mat'];

% Delete preset
delete(selectedPresetFilename);

disp('Deleted preset.');

handles = loadPresets(handles);
guidata(hObject, handles);

function disable_silly_warnings()
disable_silly_warnings;
egm_Sorted_rasters_export_OpeningFcn;
popup_TriggerSource_Callback;
popup_TriggerSource_CreateFcn;
popup_TriggerType_Callback;
popup_TriggerType_CreateFcn;
push_TriggerOptions_Callback;
popup_EventSource_Callback;
popup_EventSource_CreateFcn;
popup_EventType_Callback;
popup_EventType_CreateFcn;
push_EventOptions_Callback;
popup_StartReference_Callback;
popup_StartReference_CreateFcn;
popup_StopReference_Callback;
popup_StopReference_CreateFcn;
push_WindowLimits_Callback;
push_FileRange_Callback;
popup_PrimarySort_Callback;
popup_PrimarySort_CreateFcn;
popup_SecondarySort_Callback;
popup_SecondarySort_CreateFcn;
check_PrimaryDescending_Callback;
check_SecondaryDescending_Callback;
check_CopyEvents_Callback;
check_CopyTrigger_Callback;
popup_Files_Callback;
popup_Files_CreateFcn;
push_GenerateRaster_Callback;
check_ExcludeIncomplete_Callback;
popup_TriggerAlignment_Callback;
popup_TriggerAlignment_CreateFcn;
check_ExcludePartialEvents_Callback;
list_Filter_Callback;
list_Filter_CreateFcn;
edit_FilterFrom_Callback;
edit_FilterFrom_CreateFcn;
edit_FilterTo_Callback;
edit_FilterTo_CreateFcn;
list_Plot_Callback;
list_Plot_CreateFcn;
check_PlotInclude_Callback;
check_PlotContinuous_Callback;
push_PlotColor_Callback;
push_PlotWidth_Callback;
check_LockLimits_Callback;
push_TimeLimits_Callback;
push_TickHeight_Callback;
RadioYAxis_Callback;
check_CopyWindow_Callback;
push_Export_Callback;
push_Dimensions_Callback;
push_Open_Callback;
popup_PSTHUnits_Callback;
popup_PSTHUnits_CreateFcn;
push_PSTHBinSize_Callback;
popup_PSTHCount_Callback;
popup_PSTHCount_CreateFcn;
check_IncludePSTH_Callback;
check_HoldOn_Callback;
list_WarpPoints_Callback;
list_WarpPoints_CreateFcn;
push_AddPoint_Callback;
push_DeletePoint_Callback;
popup_WarpingAlgorithm_Callback;
popup_WarpingAlgorithm_CreateFcn;
push_WarpOptions_Callback;
push_IntervalDuration_Callback;
push_IntervalLeft_Callback;
push_IntervalRight_Callback;
RadioWarpedDurations;
click_Raster;
click_PSTH;
click_Hist;
push_Colors_Callback;
context_Color_Callback;
menu_Background_Callback;
menu_CLimits_Callback;
menu_Colormap_Callback;
menu_SetAutoCLim_Callback;
menu_EditColormap_Callback;
menu_InvertColormap_Callback;
push_MinDown_Callback;
push_MinUp_Callback;
push_MaxDown_Callback;
push_MaxUp_Callback;
popup_Correlation_Callback;
popup_Correlation_CreateFcn;
menu_LogScale_Callback;
push_Select_Callback;
context_Select_Callback;
menu_Select1_Callback;
menu_Select2_Callback;
menu_Select3_Callback;
menu_Select4_Callback;
menu_Select5_Callback;
menu_Select6_Callback;
menu_Select7_Callback;
menu_Select8_Callback;
menu_Select9_Callback;
menu_Select10_Callback;
menu_Select11_Callback;
menu_Select12_Callback;
menu_Select13_Callback;
menu_Select14_Callback;
menu_Select15_Callback;
menu_Select16_Callback;
menu_Select17_Callback;
menu_Select18_Callback;
menu_SelectLabel_Callback;
menu_SelectAll_Callback;
menu_InvertSelection_Callback;
push_HistHoriz_Callback;
push_HistVert_Callback;
check_HistShow_Callback;
popup_HistUnits_Callback;
popup_HistUnits_CreateFcn;
popup_HistCount_Callback;
popup_HistCount_CreateFcn;
push_DeleteEvents_Callback;
popup_EventList_Callback;
popup_EventList_CreateFcn;
check_WarpingOn_Callback;
context_MatlabExport_Callback;
Untitled_5_Callback;
Untitled_8_Callback;
Untitled_11_Callback;
push_AutoColor_Callback;
check_GroupLabels_Callback;
push_MatlabExport_Callback;
check_AutoInclude_Callback;
check_SkipSorting_Callback;
menu_ExportData_Callback;
menu_ExportFigure_Callback;
popup_Presets_Callback;
popup_Presets_CreateFcn;
push_LoadPreset_Callback;
push_SavePreset_Callback;
push_ReloadPreset_Callback;
push_DeletePreset_Callback;

% --- Creates and returns a handle to the GUI figure. 
function h1 = egm_Sorted_rasters_export_LayoutFcn(policy)
% policy - create a new figure or use a singleton. 'new' or 'reuse'.

persistent hsingleton;
if strcmpi(policy, 'reuse') & ishandle(hsingleton)
    h1 = hsingleton;
    return;
end
load egm_Sorted_rasters_export.mat


appdata = [];
appdata.GUIDEOptions = struct(...
    'active_h', [], ...
    'taginfo', struct(...
    'figure', 2, ...
    'uipanel', 35, ...
    'text', 80, ...
    'popupmenu', 42, ...
    'pushbutton', 52, ...
    'radiobutton', 35, ...
    'checkbox', 47, ...
    'axes', 4, ...
    'listbox', 7, ...
    'edit', 7), ...
    'override', 0, ...
    'release', 13, ...
    'resize', 'none', ...
    'accessibility', 'callback', ...
    'mfile', 1, ...
    'callbacks', 1, ...
    'singleton', 1, ...
    'syscolorfig', 1, ...
    'blocking', 0, ...
    'lastSavedFile', 'D:\Dropbox\Documents\Work\Cornell Lab Tech\Projects\Zebrafinch\ElectroGui\source\egm_Sorted_rasters_export.m', ...
    'lastFilename', 'C:\Users\Brian Kardon\Dropbox\Documents\Work\Cornell Lab Tech\Projects\Zebrafinch\ElectroGui\source\egm_Sorted_rasters.fig');
appdata.lastValidTag = 'fig_Main';
appdata.GUIDELayoutEditor = mat{1};

h1 = figure(...
'PaperUnits','normalized',...
'Units','normalized',...
'Position',[0.0348958333333333 0.0383333333333333 0.941145833333333 0.885],...
'Visible',get(0,'defaultfigureVisible'),...
'Color',[0.941176470588235 0.941176470588235 0.941176470588235],...
'IntegerHandle','off',...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'MenuBar','none',...
'Name','Sorted raster plots',...
'NumberTitle','off',...
'HandleVisibility','callback',...
'Tag','fig_Main',...
'UserData',[],...
'PaperPosition',[0.0294117647058824 0.227272727272727 0.941176470588235 0.545454545454545],...
'PaperSize',[1 1],...
'InvertHardcopy',get(0,'defaultfigureInvertHardcopy'),...
'ScreenPixelsPerInchMode','manual',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'axes_Raster';

h2 = axes(...
'Parent',h1,...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'CameraTarget',[0.5 0.5 0.5],...
'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
'CameraViewAngle',6.60861036031192,...
'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
'PlotBoxAspectRatio',[1 0.668928086838535 0.668928086838535],...
'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
'XTickMode',get(0,'defaultaxesXTickMode'),...
'XTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
'YTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
'YTickMode',get(0,'defaultaxesYTickMode'),...
'YTickLabel',{  '0'; '0.1'; '0.2'; '0.3'; '0.4'; '0.5'; '0.6'; '0.7'; '0.8'; '0.9'; '1' },...
'YTickLabelMode',get(0,'defaultaxesYTickLabelMode'),...
'Color',get(0,'defaultaxesColor'),...
'CameraMode',get(0,'defaultaxesCameraMode'),...
'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
'TitleMode',get(0,'defaultaxesTitleMode'),...
'Subtitle',[],...
'SubtitleMode',get(0,'defaultaxesSubtitleMode'),...
'BoxFrame',[],...
'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
'XRulerMode',get(0,'defaultaxesXRulerMode'),...
'YRulerMode',get(0,'defaultaxesYRulerMode'),...
'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
'Position',[0.231727574750831 0.303197353914002 0.4078073089701 0.464167585446527],...
'InnerPosition',[0.231727574750831 0.303197353914002 0.4078073089701 0.464167585446527],...
'ActivePositionProperty','position',...
'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
'PositionConstraint','innerposition',...
'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
'LooseInset',[0.165559796437659 0.141402027027027 0.120986005089059 0.096410472972973],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'ColormapMode',get(0,'defaultaxesColormapMode'),...
'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'SortMethod','childorder',...
'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
'Tag','axes_Raster',...
'Title',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h3 = get(h2,'title');

set(h3,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500001020315059 1.00507099391481 0.5],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','Axes Title',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h4 = get(h2,'xlabel');

set(h4,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500000476837158 -0.0594996629493153 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h5 = get(h2,'ylabel');

set(h5,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[-0.0483943924543708 0.500000476837158 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h6 = get(h2,'zlabel');

set(h6,...
'Parent',h2,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
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
'HorizontalAlignment','right',...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','off',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

appdata = [];
appdata.lastValidTag = 'axes_PSTH';

h7 = axes(...
'Parent',h1,...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'CameraTarget',[0.5 0.5 0.5],...
'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
'CameraViewAngle',6.60861036031192,...
'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
'PlotBoxAspectRatio',[1 0.248303934871099 0.248303934871099],...
'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
'XTick',[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1],...
'XTickLabel',blanks(0),...
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
'TitleMode',get(0,'defaultaxesTitleMode'),...
'Subtitle',[],...
'SubtitleMode',get(0,'defaultaxesSubtitleMode'),...
'BoxFrame',[],...
'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
'XRulerMode',get(0,'defaultaxesXRulerMode'),...
'YRulerMode',get(0,'defaultaxesYRulerMode'),...
'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
'Position',[0.231727574750831 0.788313120176405 0.4078073089701 0.17199558985667],...
'InnerPosition',[0.231727574750831 0.788313120176405 0.4078073089701 0.17199558985667],...
'ActivePositionProperty','position',...
'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
'PositionConstraint','innerposition',...
'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
'LooseInset',[0.165559796437659 0.259131652661065 0.120986005089059 0.176680672268908],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'ColormapMode',get(0,'defaultaxesColormapMode'),...
'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'SortMethod','childorder',...
'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
'Tag','axes_PSTH',...
'Title',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h8 = get(h7,'title');

set(h8,...
'Parent',h7,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500001020315059 1.01366120218579 0.5],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','Axes Title',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h9 = get(h7,'xlabel');

set(h9,...
'Parent',h7,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500000476837158 -0.0255009107468114 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h10 = get(h7,'ylabel');

set(h10,...
'Parent',h7,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[-0.0393487116698494 0.500000476837159 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h11 = get(h7,'zlabel');

set(h11,...
'Parent',h7,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
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
'HorizontalAlignment','right',...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','off',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

appdata = [];
appdata.lastValidTag = 'axes_Hist';

h12 = axes(...
'Parent',h1,...
'CameraPosition',[0.5 0.5 9.16025403784439],...
'CameraPositionMode',get(0,'defaultaxesCameraPositionMode'),...
'CameraTarget',[0.5 0.5 0.5],...
'CameraTargetMode',get(0,'defaultaxesCameraTargetMode'),...
'CameraViewAngle',6.60861036031192,...
'CameraViewAngleMode',get(0,'defaultaxesCameraViewAngleMode'),...
'PlotBoxAspectRatio',[0.582150101419878 1 0.582150101419878],...
'PlotBoxAspectRatioMode',get(0,'defaultaxesPlotBoxAspectRatioMode'),...
'XTick',[0 0.2 0.4 0.6 0.8 1],...
'XTickMode',get(0,'defaultaxesXTickMode'),...
'XTickLabel',{  '0'; '0.2'; '0.4'; '0.6'; '0.8'; '1' },...
'XTickLabelMode',get(0,'defaultaxesXTickLabelMode'),...
'YTick',[],...
'YTickLabel',blanks(0),...
'Color',get(0,'defaultaxesColor'),...
'CameraMode',get(0,'defaultaxesCameraMode'),...
'DataSpaceMode',get(0,'defaultaxesDataSpaceMode'),...
'ColorSpaceMode',get(0,'defaultaxesColorSpaceMode'),...
'DecorationContainerMode',get(0,'defaultaxesDecorationContainerMode'),...
'ChildContainerMode',get(0,'defaultaxesChildContainerMode'),...
'TitleMode',get(0,'defaultaxesTitleMode'),...
'Subtitle',[],...
'SubtitleMode',get(0,'defaultaxesSubtitleMode'),...
'BoxFrame',[],...
'BoxFrameMode',get(0,'defaultaxesBoxFrameMode'),...
'XRulerMode',get(0,'defaultaxesXRulerMode'),...
'YRulerMode',get(0,'defaultaxesYRulerMode'),...
'ZRulerMode',get(0,'defaultaxesZRulerMode'),...
'AmbientLightSourceMode',get(0,'defaultaxesAmbientLightSourceMode'),...
'Position',[0.65531561461794 0.303197353914002 0.158637873754153 0.464167585446527],...
'InnerPosition',[0.65531561461794 0.303197353914002 0.158637873754153 0.464167585446527],...
'ActivePositionProperty','position',...
'ActivePositionPropertyMode',get(0,'defaultaxesActivePositionPropertyMode'),...
'PositionConstraint','innerposition',...
'PositionConstraintMode',get(0,'defaultaxesPositionConstraintMode'),...
'LooseInset',[0.339522776572668 0.166560934891486 0.248112798264642 0.113564273789649],...
'Colormap',[0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.0625 1;0 0.125 1;0 0.1875 1;0 0.25 1;0 0.3125 1;0 0.375 1;0 0.4375 1;0 0.5 1;0 0.5625 1;0 0.625 1;0 0.6875 1;0 0.75 1;0 0.8125 1;0 0.875 1;0 0.9375 1;0 1 1;0.0625 1 1;0.125 1 0.9375;0.1875 1 0.875;0.25 1 0.8125;0.3125 1 0.75;0.375 1 0.6875;0.4375 1 0.625;0.5 1 0.5625;0.5625 1 0.5;0.625 1 0.4375;0.6875 1 0.375;0.75 1 0.3125;0.8125 1 0.25;0.875 1 0.1875;0.9375 1 0.125;1 1 0.0625;1 1 0;1 0.9375 0;1 0.875 0;1 0.8125 0;1 0.75 0;1 0.6875 0;1 0.625 0;1 0.5625 0;1 0.5 0;1 0.4375 0;1 0.375 0;1 0.3125 0;1 0.25 0;1 0.1875 0;1 0.125 0;1 0.0625 0;1 0 0;0.9375 0 0;0.875 0 0;0.8125 0 0;0.75 0 0;0.6875 0 0;0.625 0 0;0.5625 0 0],...
'ColormapMode',get(0,'defaultaxesColormapMode'),...
'Alphamap',[0 0.0159 0.0317 0.0476 0.0635 0.0794 0.0952 0.1111 0.127 0.1429 0.1587 0.1746 0.1905 0.2063 0.2222 0.2381 0.254 0.2698 0.2857 0.3016 0.3175 0.3333 0.3492 0.3651 0.381 0.3968 0.4127 0.4286 0.4444 0.4603 0.4762 0.4921 0.5079 0.5238 0.5397 0.5556 0.5714 0.5873 0.6032 0.619 0.6349 0.6508 0.6667 0.6825 0.6984 0.7143 0.7302 0.746 0.7619 0.7778 0.7937 0.8095 0.8254 0.8413 0.8571 0.873 0.8889 0.9048 0.9206 0.9365 0.9524 0.9683 0.9841 1],...
'AlphamapMode',get(0,'defaultaxesAlphamapMode'),...
'ColorOrder',get(0,'defaultaxesColorOrder'),...
'SortMethod','childorder',...
'SortMethodMode',get(0,'defaultaxesSortMethodMode'),...
'Tag','axes_Hist',...
'Title',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

h13 = get(h12,'title');

set(h13,...
'Parent',h12,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500004414481984 1.00507099391481 0.5],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','Axes Title',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h14 = get(h12,'xlabel');

set(h14,...
'Parent',h12,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[0.500000476837158 -0.0545977021166407 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h15 = get(h12,'ylabel');

set(h15,...
'Parent',h12,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
'ColorMode','auto',...
'Position',[-0.0197444831591174 0.500000476837158 0],...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','on',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

h16 = get(h12,'zlabel');

set(h16,...
'Parent',h12,...
'Units','data',...
'FontUnits','points',...
'DecorationContainer',[],...
'DecorationContainerMode','auto',...
'Color',[0 0 0],...
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
'HorizontalAlignment','right',...
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
'XLimInclude','off',...
'XLimIncludeMode','auto',...
'YLimInclude','off',...
'YLimIncludeMode','auto',...
'ZLimInclude','off',...
'ZLimIncludeMode','auto',...
'CLimInclude','on',...
'ALimInclude','on',...
'Description','AxisRulerBase Label',...
'DescriptionMode','auto',...
'Visible','off',...
'Serializable','on',...
'HandleVisibility','off',...
'HelpTopicKey',blanks(0),...
'ButtonDownFcn',blanks(0),...
'BusyAction','queue',...
'Interruptible','on',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} ,...
'DeleteFcn',blanks(0),...
'Tag',blanks(0),...
'HitTest','on',...
'PickableParts','visible',...
'PickablePartsMode','auto',...
'SeriesIndex','none',...
'SeriesIndexMode','auto');

appdata = [];
appdata.lastValidTag = 'panel_Trigger';

h17 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Trigger',...
'Tag','panel_Trigger',...
'UserData',[],...
'Clipping','off',...
'Position',[0.0179856115107914 0.665413533834587 0.155 0.205513784461153],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text1';

h18 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Source',...
'Style','text',...
'Position',[0.0481283422459893 0.918144266073631 0.914438502673797 0.0903077582933723],...
'Children',[],...
'Tag','text1',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_TriggerSource';

h19 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Sound',...
'Style','popupmenu',...
'Value',1,...
'Position',[0.101604278074866 0.797733921682468 0.807486631016043 0.126430861610721],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerSource_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Source of triggers - a list of time points or ''Sound'' for syllable-related triggers',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Source of triggers - a list of time points or ''Sound'' for syllable-related triggers',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerSource_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_TriggerSource',...
'UserData',[]);

appdata = [];
appdata.lastValidTag = 'text2';

h20 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Type',...
'Style','text',...
'Position',[0.0481283422459893 0.665282542852189 0.914438502673797 0.102348792732489],...
'Children',[],...
'Tag','text2',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_TriggerType';

h21 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String',{  'Syllables'; 'Markers'; 'Motifs'; 'Bouts' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.101604278074866 0.556913232900141 0.807486631016043 0.126430861610721],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerType_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Method for detecting trigger times from the current source',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Method for detecting trigger times from the current source',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerType_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_TriggerType',...
'UserData',[]);

appdata = [];
appdata.lastValidTag = 'push_TriggerOptions';

h22 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Options',...
'Position',[0.101604278074866 0.32283552340372 0.320855614973262 0.186636033806303],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_TriggerOptions_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify options related to the current trigger detection method',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify options related to the current trigger detection method',...
'Tag','push_TriggerOptions',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_CopyEvents';

h23 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Copy events',...
'Style','checkbox',...
'Value',1,...
'Position',[0.475935828877005 0.346917592281953 0.486631016042781 0.126430861610721],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_CopyEvents_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Apply the same options as those chosen for events to triggers',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Apply the same options as those chosen for events to triggers',...
'Tag','check_CopyEvents',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text24';

h24 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String','Alignment',...
'Style','text',...
'Position',[0.0481283422459893 0.199776151435952 0.914438502673797 0.0903077582933723],...
'Children',[],...
'Tag','text24',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_TriggerAlignment';

h25 = uicontrol(...
'Parent',h17,...
'Units','normalized',...
'String',{  'Onset'; 'Midpoint'; 'Offset' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.101604278074866 0.0793658070447883 0.807486631016043 0.126430861610721],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerAlignment_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Align raster to this part of the trigger',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Align raster to this part of the trigger',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_TriggerAlignment_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_TriggerAlignment',...
'UserData',[]);

appdata = [];
appdata.lastValidTag = 'panel_Events';

h26 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Events',...
'Tag','panel_Events',...
'Clipping','off',...
'Position',[0.0179856115107914 0.506265664160401 0.155 0.155388471177945],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text3';

h27 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String','Source',...
'Style','text',...
'Position',[0.0470588235294118 0.889830508474576 0.911764705882353 0.127118644067797],...
'Children',[],...
'Tag','text3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_EventSource';

h28 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String','Sound',...
'Style','popupmenu',...
'Value',1,...
'Position',[0.1 0.720338983050847 0.805882352941176 0.177966101694915],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_EventSource_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Source of events - a list of time points or ''Sound'' for syllable-related events',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Source of events - a list of time points or ''Sound'' for syllable-related events',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_EventSource_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_EventSource');

appdata = [];
appdata.lastValidTag = 'text4';

h29 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String','Type',...
'Style','text',...
'Position',[0.0470588235294118 0.542372881355932 0.911764705882353 0.144067796610169],...
'Children',[],...
'Tag','text4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_EventType';

h30 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String',{  'Syllables'; 'Markers'; 'Motifs'; 'Bouts' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.1 0.389830508474576 0.805882352941176 0.177966101694915],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_EventType_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Method for detecting event times from the current source',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Method for detecting event times from the current source',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_EventType_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_EventType');

appdata = [];
appdata.lastValidTag = 'push_EventOptions';

h31 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String','Options',...
'Position',[0.1 0.0677966101694915 0.323529411764706 0.254237288135593],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_EventOptions_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify options related to the current event detection method',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify options related to the current event detection method',...
'Tag','push_EventOptions',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_CopyTrigger';

h32 = uicontrol(...
'Parent',h26,...
'Units','normalized',...
'String','Copy trigger',...
'Style','checkbox',...
'Value',1,...
'Position',[0.476470588235294 0.101694915254237 0.488235294117647 0.177966101694915],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_CopyTrigger_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Apply the same options as those chosen for triggers to events',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Apply the same options as those chosen for triggers to events',...
'Tag','check_CopyTrigger',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Window';

h33 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Window',...
'Tag','panel_Window',...
'Clipping','off',...
'Position',[0.195847750865052 0.0104575163398693 0.219377162629758 0.139869281045752],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text7';

h34 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Start reference',...
'Style','text',...
'Position',[0.516129032258064 0.880952380952381 0.436559139784946 0.142857142857143],...
'Children',[],...
'Tag','text7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_StartReference';

h35 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String',{  'Previous onset'; 'Previous offset'; 'Current onset'; 'Current midpoint'; 'Current offset'; 'First warp point' },...
'Style','popupmenu',...
'Value',3,...
'Position',[0.516129032258064 0.69047619047619 0.436559139784946 0.19047619047619],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_StartReference_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Define window onset relative to this time point',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'Enable','off',...
'TooltipString','Define window onset relative to this time point',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_StartReference_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_StartReference');

appdata = [];
appdata.lastValidTag = 'text8';

h36 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Stop reference',...
'Style','text',...
'Position',[0.516129032258064 0.511904761904762 0.436559139784946 0.142857142857143],...
'Children',[],...
'Tag','text8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_StopReference';

h37 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String',{  'Current onset'; 'Current midpoint'; 'Current offset'; 'Next onset'; 'Next offset'; 'Last warp point' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.516129032258064 0.321428571428571 0.436559139784946 0.190476190476191],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_StopReference_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Define window offset relative to this time point',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'Enable','off',...
'TooltipString','Define window offset relative to this time point',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_StopReference_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_StopReference');

appdata = [];
appdata.lastValidTag = 'push_WindowLimits';

h38 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Window limits',...
'Position',[0.111827956989247 0.547619047619047 0.270967741935484 0.285714285714286],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_WindowLimits_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify window over which to include events',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify window over which to include events',...
'Tag','push_WindowLimits',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_ExcludeIncomplete';

h39 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Exclude partial windows',...
'Style','checkbox',...
'Value',1,...
'Position',[0.0301075268817204 0.333333333333333 0.436559139784946 0.142857142857143],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_ExcludeIncomplete_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Exclude windows that extend outside of file boundaries',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Exclude windows that extend outside of file boundaries',...
'Tag','check_ExcludeIncomplete',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_ExcludePartialEvents';

h40 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Exclude partial events',...
'Style','checkbox',...
'Position',[0.0301075268817204 0.142857142857143 0.436559139784946 0.142857142857143],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_ExcludePartialEvents_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Exclude events that extend outside of window boundaries',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Exclude events that extend outside of window boundaries',...
'Tag','check_ExcludePartialEvents',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_LockLimits';

h41 = uicontrol(...
'Parent',h33,...
'Units','normalized',...
'String','Lock limits to trigger',...
'Style','checkbox',...
'Value',1,...
'Position',[0.0258064516129032 0.857142857142857 0.406451612903226 0.142857142857143],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_LockLimits_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Automatically align window limits to the current trigger',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Automatically align window limits to the current trigger',...
'Tag','check_LockLimits',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Files';

h42 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Files',...
'Tag','panel_Files',...
'UserData',[],...
'Clipping','off',...
'Position',[0.0182724252491694 0.874310915104741 0.155 0.112458654906284],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text15';

h43 = uicontrol(...
'Parent',h42,...
'Units','normalized',...
'String','Include',...
'Style','text',...
'Position',[0.0482794516407962 0.84497092459779 0.917309581175127 0.185719131614654],...
'Children',[],...
'Tag','text15',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_Files';

h44 = uicontrol(...
'Parent',h42,...
'Units','normalized',...
'String','All files in range',...
'Style','popupmenu',...
'Value',1,...
'Position',[0.101923286797236 0.597345415778251 0.810021910862246 0.260006784260516],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_Files_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','File selection based on an ElectroGui property search (macro mode only)',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','File selection based on an ElectroGui property search (macro mode only)',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_Files_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_Files');

appdata = [];
appdata.lastValidTag = 'push_FileRange';

h45 = uicontrol(...
'Parent',h42,...
'Units','normalized',...
'String','File range',...
'Position',[0.101923286797236 0.117358984299282 0.380871229610726 0.383819538670285],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_FileRange_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify which files should be included in the analysis',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'Enable','off',...
'TooltipString','Specify which files should be included in the analysis',...
'Tag','push_FileRange',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_Open';

h46 = uicontrol(...
'Parent',h42,...
'Units','normalized',...
'String','Open',...
'Position',[0.531073968048758 0.117358984299282 0.380871229610726 0.383819538670285],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_Open_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Open a file containing ''dbase'' with syllable and event information',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Open a file containing ''dbase'' with syllable and event information',...
'Tag','push_Open',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Sorting';

h47 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Sorting',...
'Tag','panel_Sorting',...
'Clipping','off',...
'Position',[0.82641196013289 0.832414553472987 0.153654485049834 0.155457552370452],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text17';

h48 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String','Primary sort',...
'Style','text',...
'Position',[0.0486601471326853 0.893273305084746 0.924542795521021 0.123146186440678],...
'Children',[],...
'Tag','text17',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_PrimarySort';

h49 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String',{  'Absolute time'; 'Trigger duration'; 'Previous trigger onset'; 'Previous trigger offset'; 'Next trigger onset'; 'Next trigger offset'; 'Trigger label'; 'Preceding event onset'; 'Preceding event offset'; 'Following event onset'; 'Following event offset'; 'First event onset'; 'First event offset'; 'Last event onset'; 'Last event offset'; 'Number of events'; 'Is in event' },...
'Style','popupmenu',...
'Value',2,...
'Position',[0.102726977280113 0.729078389830509 0.816409135226165 0.172404661016949],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_PrimarySort_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Sort triggers according to a specified parameter',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Sort triggers according to a specified parameter',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_PrimarySort_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_PrimarySort');

appdata = [];
appdata.lastValidTag = 'text22';

h50 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String','Secondary sort',...
'Style','text',...
'Position',[0.0486601471326853 0.400688559322034 0.924542795521021 0.123146186440678],...
'Children',[],...
'Tag','text22',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_SecondarySort';

h51 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String',{  'Absolute time'; 'Trigger duration'; 'Previous trigger onset'; 'Previous trigger offset'; 'Next trigger onset'; 'Next trigger offset'; 'Trigger label'; 'Preceding event onset'; 'Preceding event offset'; 'Following event onset'; 'Following event offset'; 'First event onset'; 'First event offset'; 'Last event onset'; 'Last event offset'; 'Number of events'; 'Is in event' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.102726977280113 0.236493644067797 0.816409135226165 0.172404661016949],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_SecondarySort_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Secondary sorting of triggers that are identical by the primary sort parameters',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Secondary sorting of triggers that are identical by the primary sort parameters',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_SecondarySort_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_SecondarySort');

appdata = [];
appdata.lastValidTag = 'check_PrimaryDescending';

h52 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String','Descending',...
'Style','checkbox',...
'Position',[0.102941176470588 0.564356435643564 0.401960784313725 0.118811881188119],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_PrimaryDescending_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Reverse primary sorting',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Reverse primary sorting',...
'Tag','check_PrimaryDescending',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_SecondaryDescending';

h53 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String','Descending',...
'Style','checkbox',...
'Position',[0.102726977280113 0.0722987288135596 0.816409135226165 0.123146186440678],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_SecondaryDescending_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Reverse secondary sorting',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Reverse secondary sorting',...
'Tag','check_SecondaryDescending',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_GroupLabels';

h54 = uicontrol(...
'Parent',h47,...
'Units','normalized',...
'String','Group labels',...
'Style','checkbox',...
'Position',[0.541436464088398 0.567796610169492 0.453038674033149 0.11864406779661],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_GroupLabels_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Group triggers with identical labels together after primary sorting',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Group triggers with identical labels together after primary sorting',...
'Tag','check_GroupLabels',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Filtering';

h55 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Filtering',...
'Tag','panel_Filtering',...
'Clipping','off',...
'Position',[0.0179856115107914 0.0112781954887218 0.155 0.0977443609022556],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'list_Filter';

h56 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String',{  'Trigger duration'; 'Previous trigger onset'; 'Previous trigger offset'; 'Next trigger onset'; 'Next trigger offset'; 'Preceding event onset'; 'Preceding event offset'; 'Following event onset'; 'Following event offset'; 'First event onset'; 'First event offset'; 'Last event onset'; 'Last event offset'; 'Number of events'; 'Is in event' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.101604278074866 0.558823529411765 0.807486631016043 0.323529411764706],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('list_Filter_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Only include triggers within a specified parameter range',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Only include triggers within a specified parameter range',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('list_Filter_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','list_Filter');

appdata = [];
appdata.lastValidTag = 'text27';

h57 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String','From',...
'Style','text',...
'Position',[0.0481283422459893 0.176470588235294 0.219251336898396 0.220588235294118],...
'Children',[],...
'Tag','text27',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'edit_FilterFrom';

h58 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String','-inf',...
'Style','edit',...
'Position',[0.262032085561497 0.132352941176471 0.219251336898396 0.308823529411765],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('edit_FilterFrom_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Only include triggers within a specified parameter range',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Only include triggers within a specified parameter range',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('edit_FilterFrom_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','edit_FilterFrom');

appdata = [];
appdata.lastValidTag = 'edit_FilterTo';

h59 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String','inf',...
'Style','edit',...
'Position',[0.582887700534759 0.132352941176471 0.219251336898395 0.308823529411765],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('edit_FilterTo_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Only include triggers within a specified parameter range',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Only include triggers within a specified parameter range',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('edit_FilterTo_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','edit_FilterTo');

appdata = [];
appdata.lastValidTag = 'text28';

h60 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String','to',...
'Style','text',...
'Position',[0.486631016042781 0.176470588235294 0.0855614973262032 0.220588235294118],...
'Children',[],...
'Tag','text28',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text29';

h61 = uicontrol(...
'Parent',h55,...
'Units','normalized',...
'String','sec',...
'Style','text',...
'Position',[0.807486631016043 0.176470588235294 0.144385026737968 0.220588235294118],...
'Children',[],...
'Tag','text29',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Plot';

h62 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Raster',...
'Tag','panel_Plot',...
'Clipping','off',...
'Position',[0.82641196013289 0.226019845644983 0.153654485049834 0.600882028665932],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'list_Plot';

h63 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String',{  '<HTML><FONT COLOR=FFFFFF>Previous trigger onset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Previous trigger offset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Previous trigger box</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Current trigger onset</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Current trigger offset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Current trigger box</FONT></HTML>'; '<HTML><FONT COLOR=000000>Next trigger onset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Next trigger offset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Next trigger box</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Event onset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Event offset</FONT></HTML>'; '<HTML><FONT COLOR=000000>Event box</FONT></HTML>'; '<HTML><FONT COLOR=000000>PSTH plot</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>PSTH area</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>PSTH trigger line</FONT></HTML>'; '<HTML><FONT COLOR=000000>Vertical histogram plot</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Vertical histogram area</FONT></HTML>'; '<HTML><FONT COLOR=000000>Vertical histogram background</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Warp partition points - raster</FONT></HTML>'; '<HTML><FONT COLOR=FF0000>Warp partition points - PSTH</FONT></HTML>'; '<HTML><FONT COLOR=000000>Trial background</FONT></HTML>'; '<HTML><FONT COLOR=000000>Window start</FONT></HTML>'; '<HTML><FONT COLOR=000000>Window stop</FONT></HTML>'; '<HTML><FONT COLOR=000000>Window box</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI start - raster</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI stop - raster</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI box - raster</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI start - PSTH</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI stop - PSTH</FONT></HTML>'; '<HTML><FONT COLOR=000000>ROI box - PSTH</FONT></HTML>' },...
'Style','listbox',...
'Value',1,...
'Position',[0.104972375690608 0.524904214559387 0.81767955801105 0.415708812260536],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('list_Plot_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','List of objects (in red) to include in the raster and histograms',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','List of objects (in red) to include in the raster and histograms',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('list_Plot_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','list_Plot',...
'FontSize',7);

appdata = [];
appdata.lastValidTag = 'check_PlotInclude';

h64 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Include',...
'Style','checkbox',...
'Position',[0.104972375690608 0.490421455938697 0.38121546961326 0.0287356321839081],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_PlotInclude_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Include currently selected object',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Include currently selected object',...
'Tag','check_PlotInclude',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_PlotContinuous';

h65 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Continuous',...
'Style','checkbox',...
'Position',[0.481651376146789 0.469107551487414 0.458715596330275 0.0526315789473684],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_PlotContinuous_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Plot currently selected object as a continuous curve, rather than tick marks',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Plot currently selected object as a continuous curve, rather than tick marks',...
'Tag','check_PlotContinuous',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_PlotColor';

h66 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Color',...
'Position',[0.102941176470588 0.421052631578947 0.382352941176471 0.057017543859649],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_PlotColor_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify the color of currently selected objects',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify the color of currently selected objects',...
'Tag','push_PlotColor',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_TickUnits';

h67 = uibuttongroup(...
'Parent',h62,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Trial height units',...
'Tag','panel_TickUnits',...
'Clipping','off',...
'Position',[0.104972375690608 0.149425287356321 0.81767955801105 0.187739463601533],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_TickTrials';

h68 = uicontrol(...
'Parent',h67,...
'Units','normalized',...
'String','Trials',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.0596026490066226 0.747126436781606 0.470198675496689 0.172413793103448],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically span each trial by a fixed number of trials',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertically span each trial by a fixed number of trials',...
'Tag','radio_TickTrials',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_TickSeconds';

h69 = uicontrol(...
'Parent',h67,...
'Units','normalized',...
'String','Seconds',...
'Style','radiobutton',...
'Position',[0.0596026490066226 0.517241379310342 0.470198675496689 0.172413793103448],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically span each trial by a fixed amount of time',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'Enable','off',...
'TooltipString','Vertically span each trial by a fixed amount of time',...
'Tag','radio_TickSeconds',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_TickInches';

h70 = uicontrol(...
'Parent',h67,...
'Units','normalized',...
'String','Inches',...
'Style','radiobutton',...
'Position',[0.52317880794702 0.747126436781608 0.403973509933775 0.172413793103448],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically span each trial by a fixed height on the screen',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertically span each trial by a fixed height on the screen',...
'Tag','radio_TickInches',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_TickPercent';

h71 = uicontrol(...
'Parent',h67,...
'Units','normalized',...
'String','Percent',...
'Style','radiobutton',...
'Position',[0.52317880794702 0.517241379310344 0.470198675496689 0.172413793103448],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically span each trial by a fixed percentage of the raster height',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertically span each trial by a fixed percentage of the raster height',...
'Tag','radio_TickPercent',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_TickHeight';

h72 = uicontrol(...
'Parent',h67,...
'Units','normalized',...
'String','Trial height',...
'Position',[0.258278145695364 0.103448275862068 0.470198675496689 0.35632183908046],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_TickHeight_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify the height of each trial',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify the height of each trial',...
'Tag','push_TickHeight',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_YAxis';

h73 = uibuttongroup(...
'Parent',h62,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Y axis',...
'Tag','panel_YAxis',...
'Clipping','off',...
'Position',[0.535911602209945 0.0344827586206897 0.43646408839779 0.113026819923372],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_YTime';

h74 = uicontrol(...
'Parent',h73,...
'Units','normalized',...
'String','Time',...
'Style','radiobutton',...
'Value',get(0,'defaultuicontrolValue'),...
'Position',[0.227848101265823 0.111111111111111 0.632911392405063 0.311111111111111],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically position triggers according to their absolute time',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertically position triggers according to their absolute time',...
'Tag','radio_YTime',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_YTrial';

h75 = uicontrol(...
'Parent',h73,...
'Units','normalized',...
'String','Trial #',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.227848101265823 0.511111111111111 0.658227848101266 0.333333333333333],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioYAxis_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertically position triggers according to the sorted trial number',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertically position triggers according to the sorted trial number',...
'Tag','radio_YTrial',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_TimeAxis';

h76 = uibuttongroup(...
'Parent',h62,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Time axis',...
'Tag','panel_TimeAxis',...
'Clipping','off',...
'Position',[0.104972375690608 0.0172413793103448 0.49171270718232 0.132183908045977],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_TimeLimits';

h77 = uicontrol(...
'Parent',h76,...
'Units','normalized',...
'String','Time limits',...
'Position',[-0.0112359550561798 -0.0181818181818182 0.775280898876405 0.545454545454545],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_TimeLimits_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify time limits for the raster and PSTH',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify time limits for the raster and PSTH',...
'Tag','push_TimeLimits',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_CopyWindow';

h78 = uicontrol(...
'Parent',h76,...
'Units','normalized',...
'String','Auto limits',...
'Style','checkbox',...
'Value',1,...
'Position',[-0.0112359550561798 0.618181818181818 0.98876404494382 0.254545454545455],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_CopyWindow_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Automatically fix time limits to include the entire window',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Automatically fix time limits to include the entire window',...
'Tag','check_CopyWindow',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text65';

h79 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Objects',...
'Style','text',...
'Position',[0.0497237569060773 0.942528735632184 0.922651933701657 0.0287356321839081],...
'Children',[],...
'Tag','text65',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_AutoColor';

h80 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Auto color by label',...
'Position',[0.215686274509804 0.353070175438596 0.598039215686274 0.057017543859649],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_AutoColor_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Automatically color currently selected objects according to trigger label',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Automatically color currently selected objects according to trigger label',...
'Tag','push_AutoColor',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_AutoInclude';

h81 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Auto include trigger objects',...
'Style','checkbox',...
'Value',1,...
'Position',[0.102941176470588 0.969298245614033 0.877450980392157 0.0328947368421053],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_AutoInclude_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Automatically include only sorted trigger boundaries',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Automatically include only sorted trigger boundaries',...
'Tag','check_AutoInclude',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_PlotWidth';

h82 = uicontrol(...
'Parent',h62,...
'Units','normalized',...
'String','Width',...
'Position',[0.541284403669725 0.421052631578947 0.380733944954129 0.05720823798627],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_PlotWidth_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify the line width / transparency of currently selected objects',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify the line width / transparency of currently selected objects',...
'Tag','push_PlotWidth',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Exporting';

h83 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Exporting',...
'Tag','panel_Exporting',...
'Clipping','off',...
'Position',[0.421453287197232 0.00784313725490196 0.229065743944637 0.141176470588235],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_ExportHeight';

h84 = uibuttongroup(...
'Parent',h83,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Height units',...
'Tag','panel_ExportHeight',...
'Clipping','off',...
'Position',[0.0323624595469256 0.219047619047619 0.29126213592233 0.752380952380953],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_HeightAbsolute';

h85 = uicontrol(...
'Parent',h84,...
'Units','normalized',...
'String','Absolute',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.111111111111111 0.671641791044773 0.876543209876543 0.223880597014926],...
'Children',[],...
'Tooltip','Choose a fixed raster height',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Choose a fixed raster height',...
'Tag','radio_HeightAbsolute',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_HeightPerTrial';

h86 = uicontrol(...
'Parent',h84,...
'Units','normalized',...
'String','Per trial',...
'Style','radiobutton',...
'Position',[0.111111111111111 0.373134328358206 0.876543209876543 0.223880597014926],...
'Children',[],...
'Tooltip','Determine raster height by the number of triggers',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Determine raster height by the number of triggers',...
'Tag','radio_HeightPerTrial',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_HeightPerTime';

h87 = uicontrol(...
'Parent',h84,...
'Units','normalized',...
'String','Per time',...
'Style','radiobutton',...
'Position',[0.111111111111111 -0.142857142857143 0.75 0.469387755102041],...
'Children',[],...
'Tooltip','Determine raster width by the time period spanned by triggers',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Determine raster width by the time period spanned by triggers',...
'Tag','radio_HeightPerTime',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_Export';

h88 = uicontrol(...
'Parent',h83,...
'Units','normalized',...
'String','PPT export',...
'Position',[0.669902912621359 0.457142857142857 0.255663430420712 0.285714285714286],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_Export_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Export plots to a new slide in PowerPoint (must be open)',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Export plots to a new slide in PowerPoint (must be open)',...
'Tag','push_Export',...
'UserData',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_ExportWidth';

h89 = uibuttongroup(...
'Parent',h83,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Width units',...
'Tag','panel_ExportWidth',...
'Clipping','off',...
'Position',[0.304597701149425 0.404494382022472 0.290229885057471 0.561797752808989],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_WidthAbsolute';

h90 = uicontrol(...
'Parent',h89,...
'Units','normalized',...
'String','Absolute',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.111111111111111 0.531914893617017 0.876543209876543 0.319148936170213],...
'Children',[],...
'Tooltip','Specify a fixed raster width',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify a fixed raster width',...
'Tag','radio_WidthAbsolute',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_WidthPerTime';

h91 = uicontrol(...
'Parent',h89,...
'Units','normalized',...
'String','Per time',...
'Style','radiobutton',...
'Position',[0.111111111111111 0.1063829787234 0.876543209876543 0.319148936170213],...
'Children',[],...
'Tooltip','Determine raster width by the time axis limits',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Determine raster width by the time axis limits',...
'Tag','radio_WidthPerTime',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_Dimensions';

h92 = uicontrol(...
'Parent',h83,...
'Units','normalized',...
'String','Dimensions',...
'Position',[0.32183908045977 0.0898876404494382 0.255747126436782 0.280898876404494],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_Dimensions_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify raster and histogram dimensions and resolution',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify raster and histogram dimensions and resolution',...
'Tag','push_Dimensions',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_IncludePSTH';

h93 = uicontrol(...
'Parent',h83,...
'Units','normalized',...
'String','With histograms',...
'Style','checkbox',...
'Value',1,...
'Position',[0.647249190938511 0.790476190476191 0.330097087378641 0.142857142857143],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_IncludePSTH_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Include histograms in the PowerPoint export',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Include histograms in the PowerPoint export',...
'Tag','check_IncludePSTH',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_MatlabExport';

h94 = uicontrol(...
'Parent',h83,...
'Units','normalized',...
'String','Matlab export',...
'Position',[0.669902912621359 0.0857142857142858 0.255663430420712 0.285714285714286],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_MatlabExport_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Export raster information to Matlab',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Export raster information to Matlab',...
'Tag','push_MatlabExport',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_GenerateRaster';

h95 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Generate raster!',...
'Position',[0.196013289036545 0.206174200661521 0.166943521594684 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_GenerateRaster_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Plot selected raster and histogram objects',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'Enable','off',...
'TooltipString','Plot selected raster and histogram objects',...
'Tag','push_GenerateRaster',...
'FontSize',10,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_Warping';

h96 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Time warping',...
'Tag','panel_Warping',...
'Clipping','off',...
'Position',[0.0179856115107914 0.112781954887218 0.155 0.389724310776943],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'list_WarpPoints';

h97 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','(None)',...
'Style','listbox',...
'Value',1,...
'Position',[0.101604278074866 0.653955209534794 0.807291666666667 0.183391003460208],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('list_WarpPoints_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','List of events used for time warping',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','List of events used for time warping',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('list_WarpPoints_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','list_WarpPoints');

appdata = [];
appdata.lastValidTag = 'text57';

h98 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Partition points',...
'Style','text',...
'Position',[0.101604278074866 0.838948591016876 0.807486631016043 0.0440653956015884],...
'Children',[],...
'Tag','text57',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text59';

h99 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Algorithm',...
'Style','text',...
'Position',[0.101604278074866 0.498245866974241 0.807291666666667 0.0449826989619377],...
'Children',[],...
'Tag','text59',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_WarpingAlgorithm';

h100 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String',{  'Linear stretch'; 'Align left'; 'Align center'; 'Align right' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.0989010989010989 0.438066465256798 0.807692307692308 0.0574018126888218],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_WarpingAlgorithm_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Algorithm used for time warping',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Algorithm used for time warping',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_WarpingAlgorithm_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_WarpingAlgorithm');

appdata = [];
appdata.lastValidTag = 'panel_WarpedDurations';

h101 = uibuttongroup(...
'Parent',h96,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Warped interval durations',...
'Tag','panel_WarpedDurations',...
'Clipping','off',...
'Position',[0.0481283422459893 0.0134568467471209 0.914438502673797 0.296706997050696],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_IntervalDuration';

h102 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Duration',...
'Position',[0.52046783625731 0.0459770114942537 0.415204678362573 0.35632183908046],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_IntervalDuration_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify a custom duration to warp the current interval to',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify a custom duration to warp the current interval to',...
'Tag','push_IntervalDuration',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text63';

h103 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Interval',...
'Style','text',...
'Position',[0.52046783625731 0.770114942528736 0.415204678362573 0.172413793103448],...
'Children',[],...
'Tag','text63',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_IntervalLeft';

h104 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','<',...
'Position',[0.52046783625731 0.482758620689656 0.12280701754386 0.264367816091954],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_IntervalLeft_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Go to the previous interval between warping partition points',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Go to the previous interval between warping partition points',...
'Tag','push_IntervalLeft',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_IntervalRight';

h105 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','>',...
'Position',[0.812865497076024 0.482758620689656 0.12280701754386 0.264367816091954],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_IntervalRight_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Go to the next interval between warping partition points',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Go to the next interval between warping partition points',...
'Tag','push_IntervalRight',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text_Interval';

h106 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','+1',...
'Style','text',...
'Position',[0.666666666666667 0.505747126436783 0.12280701754386 0.241379310344828],...
'Children',[],...
'Tooltip','Interval between warping partition points (wrt the current trigger)',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Interval between warping partition points (wrt the current trigger)',...
'Tag','text_Interval',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_WarpCustom';

h107 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Custom',...
'Style','radiobutton',...
'Value',get(0,'defaultuicontrolValue'),...
'Position',[0.0526315789473684 0.0574712643678161 0.35672514619883 0.183908045977011],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioWarpedDurations',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Warp current interval to a custom-specified duration',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Warp current interval to a custom-specified duration',...
'Tag','radio_WarpCustom',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton32';

h108 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Maximum',...
'Style','radiobutton',...
'Position',[0.0526315789473684 0.28735632183908 0.415204678362573 0.183908045977011],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioWarpedDurations',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Warp current interval to its maximum duration',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Warp current interval to its maximum duration',...
'Tag','radiobutton32',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton33';

h109 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Median',...
'Style','radiobutton',...
'Position',[0.0526315789473684 0.517241379310345 0.415204678362573 0.172413793103448],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioWarpedDurations',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Warp current interval to its median duration',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Warp current interval to its median duration',...
'Tag','radiobutton33',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radiobutton34';

h110 = uicontrol(...
'Parent',h101,...
'Units','normalized',...
'String','Mean',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.0526315789473684 0.735632183908046 0.409356725146199 0.183908045977011],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('RadioWarpedDurations',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Warp current interval to its average duration',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Warp current interval to its average duration',...
'Tag','radiobutton34',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_WarpOptions';

h111 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Options',...
'Position',[0.0989010989010989 0.329305135951662 0.324175824175824 0.0906344410876133],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_WarpOptions_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Specify options related to correlation alignment and time warping',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Specify options related to correlation alignment and time warping',...
'Tag','push_WarpOptions',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_AddPoint';

h112 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Add',...
'Position',[0.0994152046783626 0.557152918638719 0.380116959064328 0.0905619854432645],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_AddPoint_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Add the current trigger to the list of warping partition points',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Add the current trigger to the list of warping partition points',...
'Tag','push_AddPoint',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_DeletePoint';

h113 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Delete',...
'Position',[0.53125 0.557069396386005 0.380208333333333 0.0899653979238755],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_DeletePoint_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Delete the currently selected warping partition point',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Delete the currently selected warping partition point',...
'Tag','push_DeletePoint',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text69';

h114 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Correlation alignment',...
'Style','text',...
'Position',[0.101604278074866 0.958477508650519 0.807291666666667 0.0449826989619376],...
'Children',[],...
'Tag','text69',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_Correlation';

h115 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','(None)',...
'Style','popupmenu',...
'Value',1,...
'Position',[0.1 0.883636363636364 0.809090909090909 0.0763636363636364],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_Correlation_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Continuous function used for correlation-based alignment (macro mode only)',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Continuous function used for correlation-based alignment (macro mode only)',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_Correlation_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_Correlation');

appdata = [];
appdata.lastValidTag = 'check_WarpingOn';

h116 = uicontrol(...
'Parent',h96,...
'Units','normalized',...
'String','Warping on',...
'Style','checkbox',...
'Value',1,...
'Position',[0.478021978021978 0.341389728096677 0.489010989010989 0.0634441087613293],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_WarpingOn_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Turn time warping on and off without losing the list of partition points',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Turn time warping on and off without losing the list of partition points',...
'Tag','check_WarpingOn',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_HoldOn';

h117 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Hold on to add events',...
'Style','checkbox',...
'Position',[0.505908419497784 0.166875784190715 0.1 0.0163111668757842],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_HoldOn_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Plot additional events without changing current triggers',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Plot additional events without changing current triggers',...
'Tag','check_HoldOn',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_Colors';

h118 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Colors',...
'Position',[0.196013289036545 0.157662624035281 0.0606312292358804 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_Colors_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Change background and continuous function colors',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Change background and continuous function colors',...
'Tag','push_Colors',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'context_Color';

h119 = uicontextmenu(...
'Parent',h1,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('context_Color_Callback',hObject,eventdata,guidata(hObject)),...
'Tag','context_Color',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Background';

h120 = uimenu(...
'Parent',h119,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Background_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Background',...
'Tag','menu_Background',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Colormap';

h121 = uimenu(...
'Parent',h119,...
'Separator','on',...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Colormap_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Colormap',...
'Tag','menu_Colormap',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_InvertColormap';

h122 = uimenu(...
'Parent',h119,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_InvertColormap_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Invert colormap',...
'Tag','menu_InvertColormap',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_EditColormap';

h123 = uimenu(...
'Parent',h119,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_EditColormap_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Edit colormap',...
'Tag','menu_EditColormap',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_CLimits';

h124 = uimenu(...
'Parent',h119,...
'Separator','on',...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_CLimits_Callback',hObject,eventdata,guidata(hObject)),...
'Label','C-limits',...
'Tag','menu_CLimits',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_SetAutoCLim';

h125 = uimenu(...
'Parent',h119,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_SetAutoCLim_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Set auto c-limits',...
'Tag','menu_SetAutoCLim',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_LogScale';

h126 = uimenu(...
'Parent',h119,...
'Separator','on',...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_LogScale_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Log scale',...
'Tag','menu_LogScale',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_MinDown';

h127 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','\/',...
'Position',[0.28339925506804 0.157662624035281 0.0199335548172758 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_MinDown_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Change continuous function color limits',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Change continuous function color limits',...
'Tag','push_MinDown',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_MinUp';

h128 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','/\',...
'Position',[0.305824504237475 0.157662624035281 0.0199335548172758 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_MinUp_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Change continuous function color limits',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Change continuous function color limits',...
'Tag','push_MinUp',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text67';

h129 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','right',...
'String','Min',...
'Style','text',...
'Position',[0.258493353028065 0.165621079046424 0.0214180206794682 0.0188205771643664],...
'Children',[],...
'Tag','text67',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_MaxDown';

h130 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','\/',...
'Position',[0.358331656663902 0.157662624035281 0.0199335548172758 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_MaxDown_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Change continuous function color limits',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Change continuous function color limits',...
'Tag','push_MaxDown',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_MaxUp';

h131 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','/\',...
'Position',[0.380756905833338 0.157662624035281 0.0199335548172758 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_MaxUp_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Change continuous function color limits',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Change continuous function color limits',...
'Tag','push_MaxUp',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text68';

h132 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'HorizontalAlignment','right',...
'String','Max',...
'Style','text',...
'Position',[0.331610044313147 0.165621079046424 0.0228951255539143 0.0188205771643664],...
'Children',[],...
'Tag','text68',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'context_Select';

h133 = uicontextmenu(...
'Parent',h1,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('context_Select_Callback',hObject,eventdata,guidata(hObject)),...
'Tag','context_Select',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select1';

h134 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select1_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Trial number',...
'Tag','menu_Select1',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select2';

h135 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select2_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Absolute time',...
'Tag','menu_Select2',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_SelectLabel';

h136 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_SelectLabel_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Trigger label',...
'Tag','menu_SelectLabel',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select3';

h137 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select3_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Trigger duration',...
'Tag','menu_Select3',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select8';

h138 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select8_Callback',hObject,eventdata,guidata(hObject)),...
'Label','File number',...
'Tag','menu_Select8',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select4';

h139 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select4_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Previous trigger onset',...
'Tag','menu_Select4',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select5';

h140 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select5_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Previous trigger offset',...
'Tag','menu_Select5',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select6';

h141 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select6_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Next trigger onset',...
'Tag','menu_Select6',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select7';

h142 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select7_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Next trigger offset',...
'Tag','menu_Select7',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select9';

h143 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select9_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Preceding event onset',...
'Tag','menu_Select9',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select10';

h144 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select10_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Preceding event offset',...
'Tag','menu_Select10',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select11';

h145 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select11_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Following event onset',...
'Tag','menu_Select11',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select12';

h146 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select12_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Following event offset',...
'Tag','menu_Select12',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select13';

h147 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select13_Callback',hObject,eventdata,guidata(hObject)),...
'Label','First event onset',...
'Tag','menu_Select13',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select14';

h148 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select14_Callback',hObject,eventdata,guidata(hObject)),...
'Label','First event offset',...
'Tag','menu_Select14',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select15';

h149 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select15_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Last event onset',...
'Tag','menu_Select15',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select16';

h150 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select16_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Last event offset',...
'Tag','menu_Select16',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select17';

h151 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select17_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Number of events',...
'Tag','menu_Select17',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_Select18';

h152 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_Select18_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Is in event',...
'Tag','menu_Select18',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_SelectAll';

h153 = uimenu(...
'Parent',h133,...
'Separator','on',...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_SelectAll_Callback',hObject,eventdata,guidata(hObject)),...
'Label','All',...
'Tag','menu_SelectAll',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_InvertSelection';

h154 = uimenu(...
'Parent',h133,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_InvertSelection_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Invert selection',...
'Tag','menu_InvertSelection',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text_NumTriggers';

h155 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','0 triggers',...
'Style','text',...
'Position',[0.670588235294118 0.196078431372549 0.0782006920415225 0.0196078431372549],...
'Children',[],...
'Tag','text_NumTriggers',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text_Info';

h156 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'Style','text',...
'Position',[0.190199335548173 0.970231532524807 0.62375415282392 0.0220507166482911],...
'Children',[],...
'Tag','text_Info',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_DeleteEvents';

h157 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Delete events',...
'Position',[0.420343071102234 0.157662624035281 0.0780730897009967 0.0341786108048512],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_DeleteEvents_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Delete currently selected events',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Delete currently selected events',...
'Tag','push_DeleteEvents',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_EventList';

h158 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','(None)',...
'Style','popupmenu',...
'Value',1,...
'Position',[0.420069204152249 0.202614379084967 0.237370242214533 0.0222222222222222],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_EventList_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Select from the list of events currently included in the raster',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Select from the list of events currently included in the raster',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_EventList_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_EventList');

appdata = [];
appdata.lastValidTag = 'text72';

h159 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Selected events',...
'Style','text',...
'Position',[0.420343071102234 0.223814773980154 0.252 0.0165380374862183],...
'Children',[],...
'Tag','text72',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text74';

h160 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Selected',...
'Style','text',...
'Position',[0.670588235294118 0.215686274509804 0.0775086505190311 0.0169934640522876],...
'Children',[],...
'Tag','text74',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_SkipSorting';

h161 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Skip sorting',...
'Style','checkbox',...
'Position',[0.605339555232989 0.166875784190715 0.0600000000000001 0.0163111668757842],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_SkipSorting_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Do not sort raster, allowing sorting on a different set of events',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Do not sort raster, allowing sorting on a different set of events',...
'Tag','check_SkipSorting',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'context_MatlabExport';

h162 = uicontextmenu(...
'Parent',h1,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('context_MatlabExport_Callback',hObject,eventdata,guidata(hObject)),...
'Tag','context_MatlabExport',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_ExportData';

h163 = uimenu(...
'Parent',h162,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_ExportData_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Data',...
'Tag','menu_ExportData',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'menu_ExportFigure';

h164 = uimenu(...
'Parent',h162,...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('menu_ExportFigure_Callback',hObject,eventdata,guidata(hObject)),...
'Label','Figure',...
'Tag','menu_ExportFigure',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'presetPanel';

h165 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Presets',...
'Tag','presetPanel',...
'Clipping','off',...
'Position',[0.665051903114187 0.00915032679738561 0.164705882352941 0.171241830065359],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'presetMenuLabel';

h166 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String','Available presets',...
'Style','text',...
'Position',[0.0486601471326853 0.893273305084746 0.924542795521021 0.123146186440678],...
'Children',[],...
'Tag','presetMenuLabel',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_LoadPreset';

h167 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String','Load preset',...
'Position',[0.0854700854700855 0.398148148148148 0.549145299145299 0.212962962962963],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_LoadPreset_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Load the selected preset. This will apply all saved settings to the raster controls.',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Load the selected preset. This will apply all saved settings to the raster controls.',...
'Tag','push_LoadPreset',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_SavePreset';

h168 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String','Save current settings as new preset',...
'Position',[0.0854700854700855 0.175925925925926 0.876068376068377 0.212962962962963],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_SavePreset_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Save the current raster control settings as a preset file that can be loaded later.',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Save the current raster control settings as a preset file that can be loaded later.',...
'Tag','push_SavePreset',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_ReloadPreset';

h169 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String','R',...
'Position',[0.858974358974359 0.620370370370371 0.102564102564103 0.222222222222222],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_ReloadPreset_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Reload list of saved presets',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Reload list of saved presets',...
'Tag','push_ReloadPreset',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_Presets';

h170 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String',blanks(0),...
'Style','popupmenu',...
'Value',1,...
'Position',[0.0897435897435898 0.611111111111112 0.764957264957265 0.222222222222222],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_Presets_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','List of preset files found in the electro_gui folder. Loading a preset will set all the raster controls to the saved settings.',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','List of preset files found in the electro_gui folder. Loading a preset will set all the raster controls to the saved settings.',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_Presets_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_Presets');

appdata = [];
appdata.lastValidTag = 'push_DeletePreset';

h171 = uicontrol(...
'Parent',h165,...
'Units','normalized',...
'String','Delete preset',...
'Position',[0.641025641025642 0.398148148148148 0.320512820512821 0.212962962962963],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_DeletePreset_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Delete the selected preset.',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Delete the selected preset.',...
'Tag','push_DeletePreset',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_Select';

h172 = uicontrol(...
'Parent',h1,...
'Units','normalized',...
'String','Select triggers',...
'Position',[0.750865051903114 0.193464052287582 0.0692041522491349 0.0392156862745098],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_Select_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Select triggers in the current raster according to specified parameters',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Select triggers in the current raster according to specified parameters',...
'Tag','push_Select',...
'FontSize',10,...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'panel_PSTH';

h173 = uipanel(...
'Parent',h1,...
'TitlePosition','centertop',...
'Title','Histograms',...
'Tag','panel_PSTH',...
'Clipping','off',...
'Position',[0.826297577854671 0.0104575163398693 0.15363321799308 0.210457516339869],...
'Layout',[],...
'FontSize',12,...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'uipanel27';

h174 = uibuttongroup(...
'Parent',h173,...
'BorderType','none',...
'TitlePosition','centertop',...
'Title','Axis limits',...
'Tag','uipanel27',...
'UserData',[],...
'Clipping','off',...
'Position',[0.534313725490196 0.0206896551724138 0.446078431372549 0.317241379310345],...
'Layout',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_PSTHAuto';

h175 = uicontrol(...
'Parent',h174,...
'Units','normalized',...
'String','Auto',...
'Style','radiobutton',...
'Value',1,...
'Position',[0.197802197802198 0.531250000000001 0.637362637362638 0.46875],...
'Children',[],...
'Tooltip','Choose axis limits for histograms automatically',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Choose axis limits for histograms automatically',...
'Tag','radio_PSTHAuto',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'radio_PSTHManual';

h176 = uicontrol(...
'Parent',h174,...
'Units','normalized',...
'String','Manual',...
'Style','radiobutton',...
'Position',[0.197802197802198 0.0937500000000005 0.637362637362638 0.46875],...
'Children',[],...
'Tooltip','Apply custom-specified axis limits to histograms',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Apply custom-specified axis limits to histograms',...
'Tag','radio_PSTHManual',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text54';

h177 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','Axis',...
'Style','text',...
'Position',[0.0497237569060773 0.732142857142857 0.922651933701657 0.0892857142857143],...
'Children',[],...
'Tag','text54',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_PSTHUnits';

h178 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String',{  'Rate (Hz)'; 'Count per trial'; 'Total count' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.104972375690608 0.619047619047619 0.81767955801105 0.119047619047619],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_PSTHUnits_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','PSTH y-axis',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','PSTH y-axis',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_PSTHUnits_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_PSTHUnits');

appdata = [];
appdata.lastValidTag = 'push_PSTHBinSize';

h179 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','Options',...
'Position',[0.104972375690608 0.0520833333333335 0.38121546961326 0.178571428571429],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_PSTHBinSize_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Options related to the currently selected histogram',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Options related to the currently selected histogram',...
'Tag','push_PSTHBinSize',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'text56';

h180 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','Count',...
'Style','text',...
'Position',[0.0497237569060773 0.5 0.922651933701657 0.0892857142857143],...
'Children',[],...
'Tag','text56',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_PSTHCount';

h181 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String',{  'Onsets'; 'Offsets'; 'Full duration' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.104972375690608 0.386904761904762 0.81767955801105 0.119047619047619],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_PSTHCount_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Events to include for PSTH calculation',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Events to include for PSTH calculation',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_PSTHCount_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_PSTHCount');

appdata = [];
appdata.lastValidTag = 'push_HistHoriz';

h182 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','PSTH',...
'Position',[0.104972375690608 0.845238095238095 0.248618784530387 0.136904761904762],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_HistHoriz_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Select PSTH',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Select PSTH',...
'Tag','push_HistHoriz',...
'UserData',[],...
'FontWeight','bold',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'push_HistVert';

h183 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','Vert.',...
'Position',[0.38121546961326 0.845238095238095 0.248618784530387 0.136904761904762],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('push_HistVert_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Select vertical histogram',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Select vertical histogram',...
'Tag','push_HistVert',...
'UserData',[],...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'check_HistShow';

h184 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String','Show',...
'Style','checkbox',...
'Value',1,...
'Position',[0.662983425414365 0.869047619047619 0.314917127071823 0.0892857142857143],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('check_HistShow_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Calculate and show the currently selected histogram',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Calculate and show the currently selected histogram',...
'Tag','check_HistShow',...
'CreateFcn', {@local_CreateFcn, blanks(0), appdata} );

appdata = [];
appdata.lastValidTag = 'popup_HistUnits';

h185 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String',{  'Rate (Hz)'; 'Count per trial'; 'Total count'; 'Fraction of time'; 'Time per trial'; 'Total time' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.18232044198895 0.571428571428571 0.81767955801105 0.119047619047619],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_HistUnits_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Vertical histogram x-axis',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Vertical histogram x-axis',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_HistUnits_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_HistUnits');

appdata = [];
appdata.lastValidTag = 'popup_HistCount';

h186 = uicontrol(...
'Parent',h173,...
'Units','normalized',...
'String',{  'Onsets'; 'Offsets'; 'Full duration' },...
'Style','popupmenu',...
'Value',1,...
'Position',[0.18232044198895 0.333333333333333 0.81767955801105 0.119047619047619],...
'BackgroundColor',[1 1 1],...
'Callback',@(hObject,eventdata)egm_Sorted_rasters_export('popup_HistCount_Callback',hObject,eventdata,guidata(hObject)),...
'Children',[],...
'Tooltip','Events to include for vertical histogram calculation',...
'TooltipMode',get(0,'defaultuicontrolTooltipMode'),...
'TooltipString','Events to include for vertical histogram calculation',...
'Visible','off',...
'CreateFcn', {@local_CreateFcn, @(hObject,eventdata)egm_Sorted_rasters_export('popup_HistCount_CreateFcn',hObject,eventdata,guidata(hObject)), appdata} ,...
'Tag','popup_HistCount');

handles = [ h118 h127 h128 h130 h131 ];
set(handles, 'uicontextmenu', h119);

handles = [ h157 h172 ];
set(handles, 'uicontextmenu', h133);

handles = [ h94 ];
set(handles, 'uicontextmenu', h162);


hsingleton = h1;


% --- Set application data first then calling the CreateFcn. 
function local_CreateFcn(hObject, eventdata, createfcn, appdata)

if ~isempty(appdata)
   names = fieldnames(appdata);
   for i=1:length(names)
       name = char(names(i));
       setappdata(hObject, name, getfield(appdata,name));
   end
end

if ~isempty(createfcn)
   if isa(createfcn,'function_handle')
       createfcn(hObject, eventdata);
   else
       eval(createfcn);
   end
end


% --- Handles default GUIDE GUI creation and callback dispatch
function varargout = gui_mainfcn(gui_State, varargin)

gui_StateFields =  {'gui_Name'
    'gui_Singleton'
    'gui_OpeningFcn'
    'gui_OutputFcn'
    'gui_LayoutFcn'
    'gui_Callback'};
gui_Mfile = '';
for i=1:length(gui_StateFields)
    if ~isfield(gui_State, gui_StateFields{i})
        error(message('MATLAB:guide:StateFieldNotFound', gui_StateFields{ i }, gui_Mfile));
    elseif isequal(gui_StateFields{i}, 'gui_Name')
        gui_Mfile = [gui_State.(gui_StateFields{i}), '.m'];
    end
end

numargin = length(varargin);

if numargin == 0
    % EGM_SORTED_RASTERS_EXPORT
    % create the GUI only if we are not in the process of loading it
    % already
    gui_Create = true;
elseif local_isInvokeActiveXCallback(gui_State, varargin{:})
    % EGM_SORTED_RASTERS_EXPORT(ACTIVEX,...)
    vin{1} = gui_State.gui_Name;
    vin{2} = [get(varargin{1}.Peer, 'Tag'), '_', varargin{end}];
    vin{3} = varargin{1};
    vin{4} = varargin{end-1};
    vin{5} = guidata(varargin{1}.Peer);
    feval(vin{:});
    return;
elseif local_isInvokeHGCallback(gui_State, varargin{:})
    % EGM_SORTED_RASTERS_EXPORT('CALLBACK',hObject,eventData,handles,...)
    gui_Create = false;
else
    % EGM_SORTED_RASTERS_EXPORT(...)
    % create the GUI and hand varargin to the openingfcn
    gui_Create = true;
end

if ~gui_Create
    % In design time, we need to mark all components possibly created in
    % the coming callback evaluation as non-serializable. This way, they
    % will not be brought into GUIDE and not be saved in the figure file
    % when running/saving the GUI from GUIDE.
    designEval = false;
    if (numargin>1 && ishghandle(varargin{2}))
        fig = varargin{2};
        while ~isempty(fig) && ~ishghandle(fig,'figure')
            fig = get(fig,'parent');
        end
        
        designEval = isappdata(0,'CreatingGUIDEFigure') || (isscalar(fig)&&isprop(fig,'GUIDEFigure'));
    end
        
    if designEval
        beforeChildren = findall(fig);
    end
    
    % evaluate the callback now
    varargin{1} = gui_State.gui_Callback;
    if nargout
        [varargout{1:nargout}] = feval(varargin{:});
    else       
        feval(varargin{:});
    end
    
    % Set serializable of objects created in the above callback to off in
    % design time. Need to check whether figure handle is still valid in
    % case the figure is deleted during the callback dispatching.
    if designEval && ishghandle(fig)
        set(setdiff(findall(fig),beforeChildren), 'Serializable','off');
    end
else
    if gui_State.gui_Singleton
        gui_SingletonOpt = 'reuse';
    else
        gui_SingletonOpt = 'new';
    end

    % Check user passing 'visible' P/V pair first so that its value can be
    % used by oepnfig to prevent flickering
    gui_Visible = 'auto';
    gui_VisibleInput = '';
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        % Recognize 'visible' P/V pair
        len1 = min(length('visible'),length(varargin{index}));
        len2 = min(length('off'),length(varargin{index+1}));
        if ischar(varargin{index+1}) && strncmpi(varargin{index},'visible',len1) && len2 > 1
            if strncmpi(varargin{index+1},'off',len2)
                gui_Visible = 'invisible';
                gui_VisibleInput = 'off';
            elseif strncmpi(varargin{index+1},'on',len2)
                gui_Visible = 'visible';
                gui_VisibleInput = 'on';
            end
        end
    end
    
    % Open fig file with stored settings.  Note: This executes all component
    % specific CreateFunctions with an empty HANDLES structure.

    
    % Do feval on layout code in m-file if it exists
    gui_Exported = ~isempty(gui_State.gui_LayoutFcn);
    % this application data is used to indicate the running mode of a GUIDE
    % GUI to distinguish it from the design mode of the GUI in GUIDE. it is
    % only used by actxproxy at this time.   
    setappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]),1);
    if gui_Exported
        gui_hFigure = feval(gui_State.gui_LayoutFcn, gui_SingletonOpt);

        % make figure invisible here so that the visibility of figure is
        % consistent in OpeningFcn in the exported GUI case
        if isempty(gui_VisibleInput)
            gui_VisibleInput = get(gui_hFigure,'Visible');
        end
        set(gui_hFigure,'Visible','off')

        % openfig (called by local_openfig below) does this for guis without
        % the LayoutFcn. Be sure to do it here so guis show up on screen.
        movegui(gui_hFigure,'onscreen');
    else
        gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        % If the figure has InGUIInitialization it was not completely created
        % on the last pass.  Delete this handle and try again.
        if isappdata(gui_hFigure, 'InGUIInitialization')
            delete(gui_hFigure);
            gui_hFigure = local_openfig(gui_State.gui_Name, gui_SingletonOpt, gui_Visible);
        end
    end
    if isappdata(0, genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]))
        rmappdata(0,genvarname(['OpenGuiWhenRunning_', gui_State.gui_Name]));
    end

    % Set flag to indicate starting GUI initialization
    setappdata(gui_hFigure,'InGUIInitialization',1);

    % Fetch GUIDE Application options
    gui_Options = getappdata(gui_hFigure,'GUIDEOptions');
    % Singleton setting in the GUI MATLAB code file takes priority if different
    gui_Options.singleton = gui_State.gui_Singleton;

    if ~isappdata(gui_hFigure,'GUIOnScreen')
        % Adjust background color
        if gui_Options.syscolorfig
            set(gui_hFigure,'Color', get(0,'DefaultUicontrolBackgroundColor'));
        end

        % Generate HANDLES structure and store with GUIDATA. If there is
        % user set GUI data already, keep that also.
        data = guidata(gui_hFigure);
        handles = guihandles(gui_hFigure);
        if ~isempty(handles)
            if isempty(data)
                data = handles;
            else
                names = fieldnames(handles);
                for k=1:length(names)
                    data.(char(names(k)))=handles.(char(names(k)));
                end
            end
        end
        guidata(gui_hFigure, data);
    end

    % Apply input P/V pairs other than 'visible'
    for index=1:2:length(varargin)
        if length(varargin) == index || ~ischar(varargin{index})
            break;
        end

        len1 = min(length('visible'),length(varargin{index}));
        if ~strncmpi(varargin{index},'visible',len1)
            try set(gui_hFigure, varargin{index}, varargin{index+1}), catch break, end
        end
    end

    % If handle visibility is set to 'callback', turn it on until finished
    % with OpeningFcn
    gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
    if strcmp(gui_HandleVisibility, 'callback')
        set(gui_hFigure,'HandleVisibility', 'on');
    end

    feval(gui_State.gui_OpeningFcn, gui_hFigure, [], guidata(gui_hFigure), varargin{:});

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        % Handle the default callbacks of predefined toolbar tools in this
        % GUI, if any
        guidemfile('restoreToolbarToolPredefinedCallback',gui_hFigure); 
        
        % Update handle visibility
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);

        % Call openfig again to pick up the saved visibility or apply the
        % one passed in from the P/V pairs
        if ~gui_Exported
            gui_hFigure = local_openfig(gui_State.gui_Name, 'reuse',gui_Visible);
        elseif ~isempty(gui_VisibleInput)
            set(gui_hFigure,'Visible',gui_VisibleInput);
        end
        if strcmpi(get(gui_hFigure, 'Visible'), 'on')
            figure(gui_hFigure);
            
            if gui_Options.singleton
                setappdata(gui_hFigure,'GUIOnScreen', 1);
            end
        end

        % Done with GUI initialization
        if isappdata(gui_hFigure,'InGUIInitialization')
            rmappdata(gui_hFigure,'InGUIInitialization');
        end

        % If handle visibility is set to 'callback', turn it on until
        % finished with OutputFcn
        gui_HandleVisibility = get(gui_hFigure,'HandleVisibility');
        if strcmp(gui_HandleVisibility, 'callback')
            set(gui_hFigure,'HandleVisibility', 'on');
        end
        gui_Handles = guidata(gui_hFigure);
    else
        gui_Handles = [];
    end

    if nargout
        [varargout{1:nargout}] = feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    else
        feval(gui_State.gui_OutputFcn, gui_hFigure, [], gui_Handles);
    end

    if isscalar(gui_hFigure) && ishghandle(gui_hFigure)
        set(gui_hFigure,'HandleVisibility', gui_HandleVisibility);
    end
end

function gui_hFigure = local_openfig(name, singleton, visible)

% openfig with three arguments was new from R13. Try to call that first, if
% failed, try the old openfig.
if nargin('openfig') == 2
    % OPENFIG did not accept 3rd input argument until R13,
    % toggle default figure visible to prevent the figure
    % from showing up too soon.
    gui_OldDefaultVisible = get(0,'defaultFigureVisible');
    set(0,'defaultFigureVisible','off');
    gui_hFigure = matlab.hg.internal.openfigLegacy(name, singleton);
    set(0,'defaultFigureVisible',gui_OldDefaultVisible);
else
    % Call version of openfig that accepts 'auto' option"
    gui_hFigure = matlab.hg.internal.openfigLegacy(name, singleton, visible);  
%     %workaround for CreateFcn not called to create ActiveX
%         peers=findobj(findall(allchild(gui_hFigure)),'type','uicontrol','style','text');    
%         for i=1:length(peers)
%             if isappdata(peers(i),'Control')
%                 actxproxy(peers(i));
%             end            
%         end
end

function result = local_isInvokeActiveXCallback(gui_State, varargin)

try
    result = ispc && iscom(varargin{1}) ...
             && isequal(varargin{1},gcbo);
catch
    result = false;
end

function result = local_isInvokeHGCallback(gui_State, varargin)

try
    fhandle = functions(gui_State.gui_Callback);
    result = ~isempty(findstr(gui_State.gui_Name,fhandle.file)) || ...
             (ischar(varargin{1}) ...
             && isequal(ishghandle(varargin{2}), 1) ...
             && (~isempty(strfind(varargin{1},[get(varargin{2}, 'Tag'), '_'])) || ...
                ~isempty(strfind(varargin{1}, '_CreateFcn'))) );
catch
    result = false;
end


