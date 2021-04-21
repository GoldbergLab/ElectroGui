function convertIntanTxtToNc(pathToTxts, recursive, regex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertIntanNcToTxt: A function for converting Intan legacy .txt channel
%   files to new .nc binary channel files.
% usage:  
%   convertIntanNcToTxt(pathToNcs)
%   convertIntanNcToTxt(pathToNcs, recursive)
%   convertIntanNcToTxt(pathToNcs, recursive, regex)
%
% where,
%    pathToTxts is a char array representing a path to either a single .txt
%       file, or a directory containing them.
%    recursive is an optional boolean flag indicating whether or not to 
%       look in subdirectories. You can also specify a positive integer 
%       indicating how many levels deep to look. Default is true.
%    regex is an optional char array representing a regular expression to
%       use to filter the files found. Default is '.*\.[Tt][Xx][Tt]$'
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

if ~exist('regex', 'var')
    regex = '.*\.[Tt][Xx][Tt]$';
end
if ~exist('recursive', 'var')
    recursive = true;
end

if exist(pathToTxts, 'dir')
    pathToTxts = findFilesByRegex(pathToTxts, regex, false, recursive);
elseif exist(pathToTxts, 'file')
    pathToTxts = {pathToTxts};
else
    error('''%s'' is not a valid file or directory.', pathToTxts);
end

fprintf('Found %d txt files to convert. Converting...\n', length(pathToTxts));
for k = 1:length(pathToTxts)
    pathToTxt = pathToTxts{k};
    
    [path, name, ~] = fileparts(pathToTxt);
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

    newPath = fullfile(path, [name, '.nc']);

    writeIntanNcFile(newPath, timeStampVector, deltaT, channel, metaData, data, true);
    fprintf('\tCompleted %d of %d\n', k, length(pathToTxts));
end