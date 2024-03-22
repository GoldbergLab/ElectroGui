function dateTime = budgieFileTimestampParser(filePath)
% Parse the timestamp contained in the file path for budgie data files,
% such as:
% z2:\Budgie\6252_0877\data_twoHS_1209-0122\200122\txtfiles\Headstage1\6252_d000001_20200122T000026_chan9.txt
% These timestamps are formatted like so: yyyymmddThhmmss, except the ss is
% sometimes just s ¯\_(ツ)_/¯

% Get filename from file path
[~, fileName, ~] = fileparts(filePath);

% Use regex to parse date and time fields from file name
tokens = regexp(fileName, '([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{1,2})', 'tokens');

if isempty(tokens) || length(tokens{1}) < 6
    dateTime = datetime.empty();
    return;
end

timeValues = str2double(tokens{1});

% Construct datetime object
dateTime = datetime(timeValues);
