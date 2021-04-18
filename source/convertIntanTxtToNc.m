function convertIntanTxtToNc(pathToTxt)

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