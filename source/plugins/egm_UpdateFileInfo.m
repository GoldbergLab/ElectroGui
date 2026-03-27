function egm_UpdateFileInfo(obj)
% ElectroGui macro
% Update timestamps and file lengths for files in the dbase. Loads each
% file once to efficiently populate both fields. Useful after creating a
% new dbase or adding files.
arguments
    obj electro_gui
end

numFiles = electro_gui.getNumFiles(obj.dbase);

if numFiles == 0
    warndlg('No files loaded in dbase.');
    return;
end

answer = inputdlg( ...
    {'File range', 'Update existing values? (yes/no)'}, ...
    'Update File Info', 1, ...
    {['1:', num2str(numFiles)], 'no'});
if isempty(answer)
    return;
end

filenums = eval(answer{1}); %#ok<EVLC>
forceUpdate = strcmpi(strtrim(answer{2}), 'yes');

progressBar = waitbar(0, 'Updating file info...');

for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    if ~isvalid(progressBar)
        return;
    end
    waitbar(fileIdx / length(filenums), progressBar, ...
        sprintf('Updating file %d of %d (file #%d)...', fileIdx, length(filenums), filenum));
    obj.updateFileInfo(filenum, forceUpdate);
end

delete(progressBar);
msgbox(sprintf('Updated file info for %d files.', length(filenums)));
