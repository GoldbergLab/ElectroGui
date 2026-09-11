function egm_batch_UnSort(obj)
% ElectroGui macro
% Batch UN-sort: set a boolean file property (default bSorted) to FALSE for
% every file in a range, optionally clearing the detected events too.
% Files with bSorted = 0 are excluded from the raster/latency decks; syllables
% (WhisperSeg -> VAE) are audio-only and unaffected.
arguments
    obj electro_gui
end
numFiles = obj.getNumFiles(obj.dbase);
answer = inputdlg({'File range (e.g. 1:50 or [3 7 12])', 'Property name', ...
                   'Also clear the spikes in those files? (y/n)'}, ...
                  'Batch un-sort', 1, {['1:' num2str(numFiles)], 'bSorted', 'n'});
if isempty(answer)
    return
end
filenums = eval(answer{1});
filenums = filenums(filenums >= 1 & filenums <= numFiles);
propertyname = strtrim(answer{2});
clearEvents = strncmpi(strtrim(answer{3}), 'y', 1);
if isempty(propertyname)
    warndlg('No property name given.', 'Batch un-sort');
    return
end
if ~any(strcmp(obj.dbase.PropertyNames, propertyname))
    warndlg(sprintf('Property "%s" does not exist in this dbase.', propertyname), 'Batch un-sort');
    return
end
if clearEvents
    eventSourceIndices = {[], []};
    for axnum = 1:2
        eventSourceIndices{axnum} = obj.GetChannelAxesEventSourceIdx(axnum);
    end
    if isempty(eventSourceIndices{1}) && isempty(eventSourceIndices{2})
        warndlg('To clear spikes, select the event source on one of the channel axes first.', 'No event source');
        return
    end
end
progressBar = waitbar(0, 'Un-sorting files...');
nCleared = 0;
for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    obj.setPropertyValue(propertyname, false, filenum, false);
    if clearEvents
        for axnum = 1:2
            eventSourceIdx = eventSourceIndices{axnum};
            if ~isempty(eventSourceIdx)
                nParts = size(obj.dbase.EventTimes, 1);   % rows = event parts (e.g. peak / trough)
                for part = 1:nParts
                    obj.dbase.EventTimes{part, filenum}      = [];
                    obj.dbase.EventIsSelected{part, filenum} = [];
                end
                nCleared = nCleared + 1;
            end
        end
    end
    if ~isvalid(progressBar)
        msgbox('Batch un-sort stopped');
        return
    end
    waitbar(fileIdx/length(filenums), progressBar, sprintf('File %d', filenum));
    drawnow;
end
obj.UpdateFileInfoBrowser();
delete(progressBar);
if clearEvents
    msgbox(sprintf('%s = 0 on %d files; spikes cleared in %d.', propertyname, length(filenums), nCleared));
else
    msgbox(sprintf('%s = 0 on %d files.', propertyname, length(filenums)));
end