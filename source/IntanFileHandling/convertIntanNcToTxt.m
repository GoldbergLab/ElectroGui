function convertIntanNcToTxt(pathToNcs, recursive, regex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convertIntanNcToTxt: A function for converting new .nc binary channel 
%   files to Intan legacy .txt channel files. This is really only useful
%   for verifying that the txt=>nc converter is working correctly, and
%   debugging if not.
%
% usage:  
%   convertIntanNcToTxt(pathToNcs)
%   convertIntanNcToTxt(pathToNcs, recursive)
%   convertIntanNcToTxt(pathToNcs, recursive, regex)
%
% where,
%    pathToNcs is a char array representing a path to either a single .nc
%       file, or a directory containing them.
%    recursive is an optional boolean flag indicating whether or not to 
%       look in subdirectories. You can also specify a positive integer 
%       indicating how many levels deep to look. Default is true.
%    regex is an optional char array representing a regular expression to
%       use to filter the files found. Default is '.*\.[Nn][Cc]$'
%
% See also: convertIntanTxtToNc, intan_converter_to_binary_channel_files
%
% Version: <version>
% Author:  Brian Kardon
% Email:   bmk27=cornell*org, brian*kardon=google*com
% Real_email = regexprep(Email,{'=','*'},{'@','.'})
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('regex', 'var')
    regex = '.*\.[Nn][Cc]$';
end
if ~exist('recursive', 'var')
    recursive = true;
end

if exist(pathToNcs, 'dir')
    pathToNcs = findFilesByRegex(pathToNcs, regex, false, recursive);
elseif exist(pathToNcs, 'file')
    pathToNcs = {pathToNcs};
else
    error('''%s'' is not a valid file or directory.', pathToNcs);
end

fprintf('Found %d nc files to convert. Converting...\n', length(pathToNcs));
for k = 1:length(pathToNcs)
    pathToNc = pathToNcs{k};
    
    data = readIntanNcFile(pathToNc);
    [path, name, ~] = fileparts(pathToNc);
    pathToTxt = fullfile(path, [name, '.txt']);

    year = data.time(1);
    month = data.time(2);
    day = data.time(3);
    hour = data.time(4);
    minute = data.time(5);
    second = double(data.time(6))+double(data.time(7))/1000000;
    date = sprintf('%02u/%02u/%d', month, day, year);
    time = sprintf('%02u:%02u:%f', hour, minute, second);

    fileID = fopen(pathToTxt,'w');
    fprintf(fileID,'%s\t%s\r\n', date, time);
    fprintf(fileID,'%s\r\n', data.metaData);
    fprintf(fileID,'%s%f\r\n\r\n', 'delta_t = ', data.dt);
    fprintf(fileID,'%f\r\n', data.data);

    fclose(fileID);
end