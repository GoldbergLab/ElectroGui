function handles = egm_ExportView(handles)
% Export current data view to a simple figure

% Get user axes selections
defaults = {false, true, true, true, logical(handles.axes_Channel1.Visible), logical(handles.axes_Channel2.Visible)};
include = getInputs('ExportView: Which axes to include?', {'Sound', 'Sonogram', 'Segments', 'Amplitude', 'Top channel', 'Bottom channel'}, defaults, {'', '', '', '', '', ''});
if isempty(include)
    % User cancelled
    return
end
% Convert axes selections to logical mask
include = cell2mat(include);

% Create a new figure
f = figure('Units', handles.figure_Main.Units, 'Position', handles.figure_Main.Position);

% Filter axes to include
displayAxes = [handles.axes_Sound, handles.axes_Sonogram, handles.axes_Segments, handles.axes_Amplitude, handles.axes_Channel1, handles.axes_Channel2];
displayAxes = displayAxes(include);
% displayAxes = displayAxes([displayAxes.Visible]);
for k = 1:length(displayAxes)
    copyobj(displayAxes(k), f);
end

% Arrange axes nicely
stackChildren(f, 'Direction', 'vertical')
shrinkToContent(f, 'Margin', 0, 'PositionType', 'OuterPosition');

% Turn it into a flexfig
flexfig(f, 'SnapToAxes', true);

