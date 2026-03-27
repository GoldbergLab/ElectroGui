function egm_UpdateTimes(obj)
% ElectroGui macro
% Update the timestamp for every file in the dbase by loading each file's
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

progressBar = waitbar(0, 'Updating file timestamps...');

for filenum = 1:numFiles
    if ~isvalid(progressBar)
        return;
    end
    waitbar(filenum / numFiles, progressBar, ...
        sprintf('Updating file %d of %d...', filenum, numFiles));
    obj.updateFileTime(filenum, true);
end

delete(progressBar);
msgbox(sprintf('Updated timestamps for %d files.', numFiles));
