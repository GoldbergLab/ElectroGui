function handles = egm_Template(handles)
% ElectroGui macro
% Template for creating electro_gui macros
%   Save this as egm_<<macro name>>.m and edit it to do whatever you want
%   Below is some skeleton code that may or may not be useful, feel free to 
%       delete or change it to suit your purposes.

% Get some user input for macro
fileRangeString = ['1:' num2str(handles.TotalFileNumber)];
answer = inputdlg( ...
    {'File range to do stuff on', ...
     'Another parameter'}, ...
     'Macro name', 1, ...
     {fileRangeString, ...
      0});

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});
param = eval(answer{2});

% Loop over selected files and do something
for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    fprintf('Doing something with file #%d (%d of %d)', filenum, fileIdx, length(filenums))

    % You can acccess the current state of the loaded dbase like so:
    obj.dbase
    % You can access the current settings like so:
    obj.settings
    % Most purposes should only require those two structs, but you can also
    %   interact with the GUI itself if you want by looking through the 
    %   other fields in the 'obj' object.
end
