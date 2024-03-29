function deleteRedundantTxtFiles(rootDir, dryRun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deleteRedundantTxtFiles: Delete txt files that are redundant to nc files
% usage:  deleteRedundantTxtFiles(rootDir, dryRun)
%
% where
%    rootDir is a char array representing the path to a directory
%       containing txt and nc files
%    dryRun is a logical flag indicating whether to actually delete txt
%       files or just inform the user what would have been deleted.
%
% Intan electrophysiology systems record RHD files, which historically we
%   have converted into txt files. However, these files are inefficient for
%   storing data, so we switched to producing binary "netCDF" format files,
%   or nc files. 
% This function is meant to deal with deleting old txt files
%   that are redundant because they have already been converted to nc
%   files.
%
% See also: intan_converter_2, convertIntanNcToTxt, compareIntanNcAndTxt
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dry run by default
if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

if ~islogical(dryRun)
    error('dryRun should be a logical true or false.');
end

if ~iscell(rootDir)
    rootDir = {rootDir};
end

rootDir = unique(rootDir);

pairs = [];
unpairedNcFiles = {};
unpairedTxtFiles = {};

% Loop over root dirs
for k = 1:length(rootDir)
    currentRootDir = rootDir{k};
    if length(rootDir) > 1
        fprintf('\nChecking files in directory %d of %d...\n\n', k, length(rootDir));
    end

    % Compare nc and txt files
    [newPairs, newUnpairedNcFiles, newUnpairedTxtFiles] = compareIntanNcAndTxt(currentRootDir);

    % Add pairs from this root directory to the list of pairs
    if isempty(pairs)
        pairs = newPairs;
    else
        pairs = [pairs, newPairs];
    end

    % Add unpaired files from this root directory to the lists of unpaired
    %   files.
    unpairedNcFiles = [unpairedNcFiles, newUnpairedNcFiles];
    unpairedTxtFiles = [unpairedTxtFiles, newUnpairedTxtFiles];
end

% Separate pairs into valid and invalid matches
validPairs = pairs([pairs.match]);
invalidPairs = pairs(~[pairs.match]);

% Get total file count
fileCount = 2*length(pairs) + length(unpairedNcFiles) + length(unpairedTxtFiles);

% Print file stats
fprintf('Found %d files:\n', fileCount)
fprintf('\t%d pairs\n', length(pairs));
fprintf('\t\t%d valid pairs\n', length(validPairs))
fprintf('\t\t%d invalid pairs\n', length(invalidPairs));
fprintf('\t%d unpaired nc files\n', length(unpairedNcFiles));
fprintf('\t%d unpaired txt files\n', length(unpairedTxtFiles))

if dryRun
    fprintf('\n\nThis would have deleted:\n');
    disp({validPairs.txtFile}');
else
    % Get final confirmation from user
    go = input(sprintf('Are you sure you want to delete %d redundant text files? y/n  ', length(validPairs)), 's');
    if strcmp(go, 'y')
        fprintf('\n\nDeleting redundant txt files...\n')
        for k = 1:length(validPairs)
            displayProgress('Deleting %d of %d redundant txt files\n', k, length(validPairs), 20);
            txtFile = validPairs(k).txtFile;
            delete(txtFile);
        end
    else
        fprintf('Cancelled - no files deleted\n');
        return
    end
end

% Print results
fprintf('Found %d files:\n', fileCount)
fprintf('\t%d pairs\n', length(pairs));
fprintf('\t\t%d valid pairs\n', length(validPairs))
fprintf('\t\t%d invalid pairs\n', length(invalidPairs));
fprintf('\t%d unpaired nc files\n', length(unpairedNcFiles));
fprintf('\t%d unpaired txt files\n', length(unpairedTxtFiles))
if dryRun
    fprintf('\n\nWould have deleted %d redundant txt files.\n', length(validPairs));
else
    fprintf('\n\nDeleted %d redundant txt files.\n', length(validPairs));
end