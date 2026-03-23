function obj = egm_Headbob_detect(obj)
% ElectroGui macro
% Run Caleb's headbob detection algorithm

% Get some user input for macro
fileRangeString = ['1:' num2str(electro_gui.getNumFiles(obj.dbase))];
answer = inputdlg( ...
    {'File range in which to detect headbobs', ...
     'Accelerometer channel #', ...
     'Accelerometer sampling rate, Hz (leave blank to use loaded sampling rate)', ...
     'Headbob marker name'}, ...
     'Macro name', 1, ...
     {fileRangeString, ...
      '18', ...
      '', ...
      'h'});

if isempty(answer)
    % User cancelled
    return
end

filenums = eval(answer{1});
accel_chan = str2double(answer{2});
accel_fs = str2double(answer{3});
markerName = answer{4};

progressBar = ProgressBar('Detecting headbobs...');

hb_struct = [];

% Loop over selected files and do something
for fileIdx = 1:length(filenums)
    filenum = filenums(fileIdx);
    progressBar.Progress = fileIdx / length(filenums);
    drawnow();

    [channelData, loaded_accel_fs] = obj.loadChannelData(accel_chan, "FileNum", filenum);
    if isnan(accel_fs)
        current_accel_fs = loaded_accel_fs;
    else
        current_accel_fs = accel_fs;
    end

    filename = obj.dbase.ChannelFiles{accel_chan}(filenum).name;

    new_hb_struct = make_headbob_struct([], filename, filenum, 'AccelFs', current_accel_fs, 'Data', channelData);
    
    if ~isempty(new_hb_struct)
        [new_hb_struct(:).cfs] = deal([]); % trim off data so dbase is reasonably sized 
        [new_hb_struct(:).aa1] = deal([]);
    end

    hb_struct = concatenateStructArrays(hb_struct, new_hb_struct);

    % Remove markers with headbob title
    numMarkers = length(obj.dbase.MarkerTitles{filenum});
    markersToDelete = [];
    for markerNum = 1:numMarkers
        if strcmp(obj.dbase.MarkerTitles{filenum}(markerNum), markerName)
            markersToDelete = [markersToDelete, markerNum]; %#ok<AGROW>
        end
    end
    obj.DeleteMarker(filenum, markersToDelete);

    % Add new marker for each headbob
    for hbnum = 1:length(new_hb_struct)
        % Calculate onset (account for accel sampling rate)
        onset = new_hb_struct(hbnum).onset * (obj.dbase.Fs/current_accel_fs);
        offset = new_hb_struct(hbnum).offset * (obj.dbase.Fs/current_accel_fs);
        obj.CreateNewMarker([onset, offset], "Filenum", filenum, "Title", markerName, "UpdateGUI", false);
    end

    % Remove entries from headbob_detects for this file
    matching_filenums = [obj.dbase.headbob_detects.filenum] == filenum;
    obj.dbase.headbob_detects(matching_filenums) = [];
end

% Add new headbob struct entries
obj.dbase.headbob_detects = concatenateStructArrays(obj.dbase.headbob_detects, hb_struct);

% Sort by filenum, seems polite
[~, sortOrder] = sort([obj.dbase.headbob_detects.filenum]);
obj.dbase.headbob_detects = obj.dbase.headbob_detects(sortOrder);

% Update GUI
obj.updateAnnotations();

delete(progressBar);

msgbox(sprintf('Found %d headbob bouts in %d files', length(hb_struct), length(filenums)));

