function egm_UpdateTimes(obj)
% ElectroGui macro
% Update the timestamp for files in the dbase by loading each file's
% time information. Useful for populating timestamps after creating a new
% dbase or after adding files.
arguments
    obj electro_gui
end

numFiles = electro_gui.getNumFiles(obj.dbase);

if numFiles == 0
    warndlg('No files loaded in dbase.');
    return;
end

answer = inputdlg( ...
    {'File range', 'Update existing timestamps? (yes/no)'}, ...
    'Update Times', 1, ...
    {['1:', num2str(numFiles)], 'no'});
if isempty(answer)
    return;
end

filenums = eval(answer{1}); %#ok<EVLC>
forceUpdate = strcmpi(strtrim(answer{2}), 'yes');

progressBar = waitbar(0, 'Updating file timestamps...');

for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    if ~isvalid(progressBar)
        return;
    end
    waitbar(fileIdx / length(filenums), progressBar, ...
        sprintf('Updating file %d of %d (file #%d)...', fileIdx, length(filenums), filenum));
    obj.updateFileTime(filenum, forceUpdate);
end

delete(progressBar);
msgbox(sprintf('Updated timestamps for %d files.', length(filenums)));
