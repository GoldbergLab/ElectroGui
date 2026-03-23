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

stats2d = obj.dbase.Properties(filenums, :)' * obj.dbase.Properties(filenums, :);
disp(size(stats2d))

numReadFiles = sum(obj.dbase.FileReadState(filenums));

propertyNames = ['viewed', propertyNames];
stats = [numReadFiles, stats];

f = figure('NumberTitle', 'off', 'Name', 'Boolean statistics'); 
f.ToolBar = "none";

ax1 = subplot(2, 1, 1);
ax2 = subplot(2, 1, 2);

ax2.Visible = false;

ax1.Toolbar.Visible = "off";
ax1.Title.Interpreter = "none";
ax1.Title.String = 'electro_gui boolean statistics';
hold(ax1, 'on');
bar(propertyNames, stats, 'Parent', ax1, 'Labels', arrayfun(@num2str, stats, "UniformOutput", false));
ax1.YLim = [0, numFiles];
ax1.YTick(end+1) = numFiles;
ax1.YLabel.String = 'Number of files with boolean';
hold(ax1, 'off');

units = ax2.Units;
position = ax2.Position;

[X, Y] = ndgrid(1:numProperties, 1:numProperties);

stats2d(Y > X) = NaN;

h = heatmap(propertyNames(2:end), propertyNames(2:end), stats2d, 'Parent', f, 'ColorLimits', [0, numFiles], 'Title', 'Pairwise combined counts');


h.Units = units;
h.Position = position;
