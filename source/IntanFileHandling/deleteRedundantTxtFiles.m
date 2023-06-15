function deleteRedundantTxtFiles(rootDir, dryRun)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deleteRedundantTxtFiles: Delete txt files that are redundant to nc files
% usage:  deleteRedundantTxtFiles(rooTDir, dryRun)
%
% where,
%    <arg1> is <description>
%    <arg2> is <description>
%    <argN> is <description>
%
% <long description>
%
% See also: <related functions>
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if ~exist('dryRun', 'var') || isempty(dryRun)
    dryRun = true;
end

if ~islogical(dryRun)
    error('dryRun should be a logical true or false.');
end

[pairs, unpairedNcFiles, unpairedTxtFiles] = compareIntanNcAndTxt(rootDir);

validPairs = pairs([pairs.match]);
invalidPairs = pairs(~[pairs.match]);

fileCount = 2*length(pairs) + length(unpairedNcFiles) + length(unpairedTxtFiles);

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
    go = input('Are you sure you want to delete %d redundant text files? y/n  ', 's');
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