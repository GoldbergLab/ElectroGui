function obj = egm_BooleanStats(obj)
% ElectroGui macro
% Template for creating electro_gui macros
%   Save this as egm_<<macro name>>.m and edit it to do whatever you want
%   Below is some skeleton code that may or may not be useful, feel free to 
%       delete or change it to suit your purposes.
arguments
    obj electro_gui
end

% Get some user input for macro
fileRangeString = ['1:' num2str(electro_gui.getNumFiles(obj.dbase))];
answer = inputdlg( ...
    {'File range'}, ...
     'Boolean Stats', ... 
     1, ...
     {fileRangeString} ...
     );

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});

propertyNames = obj.dbase.PropertyNames;

numProperties = length(propertyNames);
numFiles = length(filenums);

if numProperties == 0
    warndlg('No boolean properties found.');
    return;
end

stats = zeros(1, numProperties);
for propertyIdx = 1:numProperties
    stats(propertyIdx) = sum(obj.dbase.Properties(filenums, propertyIdx));
end

numReadFiles = sum(obj.dbase.FileReadState(filenums));

propertyNames = ['viewed', propertyNames];
stats = [numReadFiles, stats];

f = figure('NumberTitle', 'off', 'Name', 'Boolean statistics'); 
f.ToolBar = "none";
ax = axes(f);
ax.Toolbar.Visible = "off";
ax.Title.Interpreter = "none";
ax.Title.String = 'electro_gui boolean statistics';
hold(ax, 'on');
bar(propertyNames, stats, 'Parent', ax, 'Labels', arrayfun(@num2str, stats, "UniformOutput", false));
ax.YLim = [0, numFiles];
ax.YTick(end+1) = numFiles;
ax.YLabel.String = 'Number of files with boolean';
hold(ax, 'off');