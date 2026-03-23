function obj = egm_labelCapitalize(obj)

% Get some user input for macro
fileRangeString = ['1:' num2str(electro_gui.getNumFiles(obj.dbase))];
answer = inputdlg( ...
    {'File range to do stuff on'}, ...
     'Macro name', 1, ...
     {fileRangeString});

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});

% Loop over selected files and do something
for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    fprintf('Doing something with file #%d (%d of %d)\n', filenum, fileIdx, length(filenums))

    % You can acccess the current state of the loaded dbase like so:
    %1. Get segments
    segTimes = obj.dbase.SegmentTimes{filenum};
    %2. Get Aux sound channel
    auxChan = obj.getAuxiliarySoundSources();
    auxChan = auxChan{1};
    for seg = 1:size(segTimes,1)
    %5. Capitalize the segment titles
    obj.dbase.SegmentTitles{filenum}{seg} = upper(obj.dbase.SegmentTitles{filenum}{seg});
    end
end

obj.updateAnnotations();