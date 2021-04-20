function convertIntanNcToTxt(pathToNc)

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