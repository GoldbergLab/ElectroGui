function [pairs, unpairedNcFiles, unpairedTxtFiles] = compareIntanNcAndTxt(rootDir)

ncFiles = findFilesByRegex(rootDir, '.*\.[nNcC]');
txtFiles = findFilesByRegex(rootDir, '.*\.[tTxXtT]');

pairs = struct.empty();

unpairedNcFiles = {};
unpairedTxtFiles = {};

pairedTxtIdx = [];

for k = 1:length(ncFiles)
    ncFile = ncFiles{k};
    [~, ncFileName, ~] = fileparts(ncFile);
    foundMatch = false;
    for j = 1:length(txtFiles)
        if find(pairedTxtIdx==j, 1)
            % Make sure we don't match a txt file to a nc file twice
            continue
        end
        txtFile = txtFiles{j};
        [~, txtFileName, ~] = fileparts(txtFile);
        if strcmp(ncFileName, txtFileName)
            idx = length(pairs)+1;
            pairs(idx).ncFile = ncFile;
            pairs(idx).txtFile = txtFile;
            foundMatch = true;
            pairedTxtIdx(end+1) = j;
            break
        end
    end
    if ~foundMatch
        unpairedNcFiles{end+1} = ncFile;
    end
end

for j = 1:length(txtFiles)
    txtFile = txtFiles{j};
    [~, txtFileName, ~] = fileparts(txtFile);
    foundMatch = false;
    for k = 1:length(ncFiles)
        ncFile = ncFiles{k};
        [~, ncFileName, ~] = fileparts(ncFile);
        if strcmp(ncFileName, txtFileName)
            foundMatch = true;
            break
        end
    end
    if ~foundMatch
        unpairedTxtFiles{end+1} = txtFile;
    end
end


for k = 1:length(pairs)
    displayProgress('Compared %d of %d\n', k, length(pairs), 20)
    [ncData, ncFs, ncDateandtime, ncLabel, ~] = egl_Intan_Nc(pairs(k).ncFile, true);
    [txtData, txtFs, txtDateandtime, txtLabel, ~] = egl_HC_ad(pairs(k).txtFile, true);
    match = true;
    matchErrors = {};
    
    pairs(k).maxDiff = max(abs(ncData - txtData));
    
    if any(abs(ncData - txtData) > eps(single(ncData)))
        match = false;
        matchErrors{end+1} = 'Data does not match';
    end
    if ncFs ~= txtFs
        match = false;
        matchErrors{end+1} = 'Fs does not match';
    end
    if ~all(ncDateandtime == txtDateandtime)
        match = false;
        matchErrors{end+1} = 'Timestamp does not match';
    end
    if ~strcmp(ncLabel, txtLabel)
        match = false;
        matchErrors{end+1} = 'Label does not match';
    end
    pairs(k).match = match;
    pairs(k).matchErrors = matchErrors;
end