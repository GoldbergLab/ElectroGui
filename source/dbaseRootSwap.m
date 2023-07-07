function dbase = dbaseRootSwap(dbase, originalRoots, newRoots)

if ~isstruct(dbase)
    if ischar(dbase)
        dbase = load(dbase);
    else
        error("dbase argument must be either a char array representing the path to a dbase file, or a loaded dbase struct.");
    end
end

switch class(originalRoots)
    case 'char'
        originalRoots = {originalRoots};
    case 'cell'
    otherwise
        error('originalRoots must be a char array containing a drive letter, or a cell array of them.');
end
switch class(newRoots)
    case 'char'
        newRoots = {newRoots};
    case 'cell'
    otherwise
        error('newRoots must be a char array containing a drive letter, or a cell array of them.');
end

if length(originalRoots) ~= length(newRoots)
    error('You must supply the same number of original and new roots');
end

for k = 1:length(originalRoots)
    originalRoot = ['^', regexpEscape(originalRoots{k})];
    newRoot = newRoots{k};
    dbase.PathName = regexprep(dbase.PathName, originalRoot, newRoot);
    for j = 1:length(dbase.SoundFiles)
        if isfield(dbase.SoundFiles(j), 'folder')
            dbase.SoundFiles(j).folder = regexprep(dbase.SoundFiles(j).folder, originalRoot, newRoot);
        end
    end
    for j = 1:length(dbase.ChannelFiles)
        for m = 1:length(dbase.ChannelFiles{j})
            if isfield(dbase.ChannelFiles{j}(k), 'folder')
                dbase.ChannelFiles{j}(k).folder = regexprep(dbase.ChannelFiles{j}(k).folder, originalRoot, newRoot);
            end
        end
    end
end

function expr = regexpEscape(expr)
expr = [repmat('\', 1, length(expr)); expr];
expr = expr(:)';