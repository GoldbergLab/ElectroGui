function all_dbases = dbaseGater(combinedDbase)
if ischar(combinedDbase)
    % User passed path - load dbase
    filename = combinedDbase;
    s = load(combinedDbase);
    combinedDbase = s.dbase;
    saveToFile = true;
    [path, name, ext] = fileparts(filename);
else
    saveToFile = false;
end

directed = cellfun(@(val)logical(val{2}), combinedDbase.Properties.Values);
undirected = ~directed;
fileMasks = {directed, undirected};
maskNames = {'directed', 'undirected'};


for fm = 1:length(fileMasks)
    mask = fileMasks{fm};
    maskName = maskNames{fm};
    dbase = combinedDbase;

    dbase.Times = combinedDbase.Times(mask);
    dbase.FileLength = combinedDbase.FileLength(mask);
    dbase.SoundFiles = combinedDbase.SoundFiles(mask);

    % dbase_directed.ChannelFiles{c} = {};
    % dbase_undirected.ChannelFiles{c} = {};
    for c = 1:length(combinedDbase.ChannelFiles)
        dbase.ChannelFiles{c} = combinedDbase.ChannelFiles{c}(mask);
    end

    dbase.SegmentThresholds = combinedDbase.SegmentThresholds(directed);

    dbase.SegmentTimes = combinedDbase.SegmentTimes(mask);

    dbase.SegmentTitles = combinedDbase.SegmentTitles(mask);

    dbase.SegmentIsSelected = combinedDbase.SegmentIsSelected(mask);

    dbase.MarkerTimes = combinedDbase.MarkerTimes(mask);

    dbase.MarkerTitles = combinedDbase.MarkerTitles(mask);

    dbase.MarkerIsSelected = combinedDbase.MarkerIsSelected(mask);

    dbase.EventThresholds = combinedDbase.EventThresholds(:, mask);

    for type = 1:length(combinedDbase.EventTimes)
        dbase.EventTimes{type} = combinedDbase.EventTimes{type}(:, mask);
    end

    for type = 1:length(combinedDbase.EventIsSelected)
        dbase.EventIsSelected{type} = combinedDbase.EventIsSelected{type}(:, mask);
    end

    dbase.Properties.Names = combinedDbase.Properties.Names(mask);
    dbase.Properties.Values = combinedDbase.Properties.Values(mask);
    dbase.Properties.Types = combinedDbase.Properties.Types(mask);
    
    if saveToFile
        newFileName = fullfile(path, [name, '_', maskName, ext]);
        save(newFileName, 'dbase');
    end
    
    all_dbases.(maskName) = dbase;

end