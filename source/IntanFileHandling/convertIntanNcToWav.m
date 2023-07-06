function convertIntanNcToWav(pathInput, recursive, regex, skipPreexisting)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertIntanNcToWav: Convert .nc binary channel files to wav files.
%
% usage:  
%   convertIntanNcToWav(pathToNcs)
%   convertIntanNcToWav(pathToNcs, recursive)
%   convertIntanNcToWav(pathToNcs, recursive, regex)
%   convertIntanNcToWav(pathToNcs, recursive, regex, skipPreexisting)
%
% where,
%    pathToNcs is a char array representing a path to either a single .nc
%       file, or a directory containing them, or a cell array containing
%       multiple of those
%    recursive is an optional boolean flag indicating whether or not to 
%       look in subdirectories. You can also specify a positive integer 
%       indicating how many levels deep to look. Default is true.
%    regex is an optional char array representing a regular expression to
%       use to filter the files found. Default is '.*\.[Nn][Cc]$'
%    skipPreexisting is an optional boolean flag indicating whether or not
%       to skip converting nc files if the corresponding wav file already 
%       exists. Default is true.
%
% See also: convertIntanTxtToNc, convertIntanNcToTxt,
%           intan_converter_to_binary_channel_files
%
% Version: 1.0
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('regex', 'var') || isempty(regex)
    regex = '.*\.[Nn][Cc]$';
end
if ~exist('recursive', 'var') || isempty(recursive)
    recursive = true;
end
if ~exist('skipPreexisting', 'var') || isempty(skipPreexisting)
    skipPreexisting = true;
end

if ~iscell(pathInput)
    % If user provides a single file/dir char array, wrap it in a cell
    % array for consistency with other input patterns.
    pathInput = {pathInput};
end
pathsToFiles = {};
for k = 1:length(pathInput)
    path = pathInput{k};
    if exist(path, 'dir')
        pathsToFiles = [pathsToFiles, findFilesByRegex(path, regex, false, recursive)];
    elseif exist(path, 'file')
        pathsToFiles{end+1} = path;
    else
        error('''%s'' is not a valid file or directory.', path);
    end
end

skipCount = 0;

fprintf('Found %d nc files to convert. Converting...\n', length(pathsToFiles));
for k = 1:length(pathsToFiles)
    displayProgress('\tCompleted %d of %d\n', k, length(pathsToFiles), 20);
    pathToNc = pathsToFiles{k};
    
    data = readIntanNcFile(pathToNc);
    [path, name, ~] = fileparts(pathToNc);
    pathToWav = fullfile(path, [name, '.wav']);
    if skipPreexisting
        if exist(pathToWav, 'file')
            % Wav file already exists, and user requested to skip
            % preexisting wav files, so skip it.
            skipCount = skipCount + 1;
            continue;
        end
    end

    audiowrite(pathToWav, data.data, round(1/data.dt));
end

fprintf('\nFound %d files, converted %d files and skipped %d preexisting files.\n', length(pathsToFiles), length(pathsToFiles) - skipCount, skipCount);
