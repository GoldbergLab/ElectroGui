function convertIntanTxtToNc(pathInput, recursive, regex, skipPreexisting)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertIntanNcToTxt: A function for converting Intan legacy .txt channel
%   files to new .nc binary channel files.
% usage:  
%   convertIntanNcToTxt(pathToNcs)
%   convertIntanNcToTxt(pathToNcs, recursive)
%   convertIntanNcToTxt(pathToNcs, recursive, regex)
%   convertIntanNcToTxt(pathToNcs, recursive, regex, skipPreexisting)
%
% where,
%    pathInput is a char array representing a path to either a single .txt
%       file, or a directory containing them, or a cell array containing
%       multiple of those.
%    recursive is an optional boolean flag indicating whether or not to 
%       look in subdirectories. You can also specify a positive integer 
%       indicating how many levels deep to look. Default is true.
%    regex is an optional char array representing a regular expression to
%       use to filter the files found. Default is '.*\.[Tt][Xx][Tt]$'
%    skipPreexisting is an optional boolean flag indicating whether or not
%       to skip converting txt files if the corresponding nc file already 
%       exists. Default is true.
%
% This function can be used to convert old .txt Intan channel files (which
%   were created from .rhd files), to the new .nc format. This function can
%   work on a single file, or it can be given a directory and will work on
%   all the .txt files within the directory.
%
% See also: convertIntanNcToTxt, intan_converter_to_binary_channel_files
%
% Version: <version>
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

fprintf('Found %d txt files to convert. Converting...\n', length(pathsToFiles));
for k = 1:length(pathsToFiles)
    displayProgress('\tCompleted %d of %d\n', k, length(pathsToFiles), 20);
    pathToTxt = pathsToFiles{k};
    
    [path, name, ~] = fileparts(pathToTxt);

    pathToNc = fullfile(path, [name, '.nc']);
    if skipPreexisting
        if exist(pathToNc, 'file')
            % Nc file already exists, and user requested to skip
            % preexisting nc files, so skip it.
            skipCount = skipCount + 1;
            continue;
        end
    end

    chanTxt = regexp(name, 'chan([0-9]+)$', 'tokens');
    if isempty(chanTxt)
        warning('Could not extract channel number from path name - defaulting to channel 0.');
        channel = 0;
    else
        channel = str2double(chanTxt{1});
    end

    fs = 20000;
    delimiterIn = ' ';
    headerLinesIn = 3;
    dateTimeLine = 1;
    metaDataLine = 2;
    deltaTLine = 3;

    A = importdata(pathToTxt,delimiterIn,headerLinesIn);
    textData = A.textdata;
    data = A.data;
    % Split timestamp text on '.' symbol, since datevec can't handle
    %   microseconds
    dateTimeParts = strsplit(textData{dateTimeLine}, '.');
    dateTimeString = dateTimeParts{1};
    timeStampVector = datevec(dateTimeString, 'mm/dd/yyyy	HH:MM:SS');
    % Add in microseconds value
    timeStampVector = [timeStampVector, str2double(dateTimeParts{2})];

    deltaTString = regexp(textData(deltaTLine), '[0-9]?\.?[0-9]+', 'match');
    deltaT = str2double(deltaTString{1});
    metaData = textData{metaDataLine};

    writeIntanNcFile(pathToNc, timeStampVector, deltaT, channel, metaData, data, true);
end

fprintf('\nFound %d files, converted %d files and skipped %d preexisting files.\n', length(pathsToFiles), length(pathsToFiles) - skipCount, skipCount);
