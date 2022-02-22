function varargout = PatternID(varargin)
% PATTERNID MATLAB code for PatternID.fig
%      PATTERNID, by itself, creates a new PATTERNID or raises the existing
%      singleton*.
%
%      H = PATTERNID returns the handle to a new PATTERNID or the handle to
%      the existing singleton*.
%
%      PATTERNID('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PATTERNID.M with the given input arguments.
%
%      PATTERNID('Property','Value',...) creates a new PATTERNID or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PatternID_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PatternID_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PatternID

% Last Modified by GUIDE v2.5 21-Feb-2022 20:01:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PatternID_OpeningFcn, ...
                   'gui_OutputFcn',  @PatternID_OutputFcn, ...
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


% --- Executes just before PatternID is made visible.
function PatternID_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PatternID (see VARARGIN)

% Choose default command line output for PatternID
handles.output = hObject;

set(handles.figure1, 'KeyPressFcn', @keyPressHandler);

handles.patterns = varargin{1};
% Patterns struct should contain the following fields:
%   pattern
%   fileNum
%   start
%   end
%   paddedPattern

if ~isfield(handles.patterns, 'ID')
    % Initialize patterns struct with ID variable
    handles.patterns(1).ID = '';
end
handles.unselectedColor = 'blue';
handles.selectedColor = 'red';

set(handles.patternNumberList, 'String', arrayfun(@(x)num2str(x), 1:length(handles.patterns), 'UniformOutput', false));
set(handles.patternNumberList, 'Value', 1);
handles = updateAxes(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PatternID wait for user response (see UIRESUME)
uiwait(handles.figure1);

function keyPressHandler(hObject, eventdata)
handles = guidata(hObject);
switch eventdata.Key
    case 'uparrow'
        patternNum = getSelectedPatternNum(handles);
        handles = setSelectedPatternNum(handles, mod(patternNum-1 + 1, length(handles.patterns))+1);
    case 'downarrow'
        patternNum = getSelectedPatternNum(handles);
        handles = setSelectedPatternNum(handles, mod(patternNum-1 - 1, length(handles.patterns))+1);
end
guidata(hObject, handles);

function lineClickCallback(lineRef, eventdata)
ax = get(lineRef, 'Parent');
handles = guidata(ax);
patternNum = findPatternNumFromLineID(handles, lineRef);
handles = switchSelectedPattern(handles, patternNum);
guidata(ax, handles);

function handles = switchSelectedPattern(handles, patternNum)
handles = setSelectedPatternNum(handles, patternNum);
handles = updatePatternLabelDisplay(handles);

function handles = updatePatternLabelText(handles)
selectedPatternNum = getSelectedPatternNum(handles);
set(handles.patternLabelText, 'String', handles.patterns(selectedPatternNum).ID);

function handles = applyPatternLabelToSelected(handles)
selectedPatternNum = getSelectedPatternNum(handles);
handles.patterns(selectedPatternNum).ID = get(handles.patternLabelText, 'String');

function handles = applyPatternLabelToAll(handles)
selectedPatternNum = getSelectedPatternNum(handles);
selectedID =  get(handles.patternLabelText, 'String');
for k = 1:length(patterns)
    handles.patterns(k).ID = selectedID;
end

function handles = setSelectedPatternNum(handles, patternNum)
set(handles.patternNumberList, 'Value', patternNum);
handles = updateAxes(handles);
handles = updatePatternLabelText(handles);

function selectedPatternNum = getSelectedPatternNum(handles)
selectedPatternNum = get(handles.patternNumberList, 'Value');

function patternNum = findPatternNumFromLineID(handles, lineID)
patternNum = find([handles.patterns.line]==lineID);

function handles = updatePatternLabelDisplay(handles)
selectedPatternNum = getSelectedPatternNum(handles);
set(handles.patternLabelText, 'String', handles.patterns(selectedPatternNum).ID);

function handles = updateAxes(handles)
selectedPatternNum = getSelectedPatternNum(handles);
cla(handles.axes1);
hold(handles.axes1, 'on');
for k = 1:length(handles.patterns)
    if k == selectedPatternNum
        color = handles.selectedColor;
    else
        color = handles.unselectedColor;
    end
    handles.patterns(k).line = plot(handles.axes1, 0.5*handles.patterns(k).paddedPattern + k, 'Color', color);
    text(50, k+0.25, num2str(handles.patterns(k).ID), 'Color', color);
    set(handles.patterns(k).line, 'ButtonDownFcn', @lineClickCallback);
end
ylim(handles.axes1, [0.5, k+1.5]);

% --- Outputs from this function are returned to the command line.
function varargout = PatternID_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles = guidata(hObject);
varargout{1} = handles.patterns;
delete(hObject);

% --- Executes on selection change in patternNumberList.
function patternNumberList_Callback(hObject, eventdata, handles)
% hObject    handle to patternNumberList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns patternNumberList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from patternNumberList

patternNum = getSelectedPatternNum(handles);
handles = switchSelectedPattern(handles, patternNum);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function patternNumberList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to patternNumberList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function patternLabelText_Callback(hObject, eventdata, handles)
% hObject    handle to patternLabelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of patternLabelText as text
%        str2double(get(hObject,'String')) returns contents of patternLabelText as a double


% --- Executes during object creation, after setting all properties.
function patternLabelText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to patternLabelText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in labelThisPatternButton.
function labelThisPatternButton_Callback(hObject, eventdata, handles)
% hObject    handle to labelThisPatternButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
patternNum = getSelectedPatternNum(handles);
handles.patterns(patternNum).ID = get(handles.patternLabelText, 'String');
handles = updateAxes(handles);
handles = updatePatternLabelDisplay(handles);
guidata(hObject, handles);

% --- Executes on button press in labelAllPatternsButton.
function labelAllPatternsButton_Callback(hObject, eventdata, handles)
% hObject    handle to labelAllPatternsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for patternNum = 1:length(handles.patterns)
    handles.patterns(patternNum).ID = get(handles.patternLabelText, 'String');
end
handles = updateAxes(handles);
handles = updatePatternLabelDisplay(handles);
guidata(hObject, handles);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%delete(hObject);
uiresume(hObject);