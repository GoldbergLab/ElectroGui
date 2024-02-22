function [data, fs,dateandtime, label, props] = egl_HC_ad(filename, loaddata)
% Anindita Das
% ElectroGui file loader
% Reads Intan data files saved as txt files
% Extracts date and time information from the file
 
if loaddata == 1
    fs = 20000;
    delimiterIn = ' ';
    headerlinesIn = 4;
    A = importdata(filename,delimiterIn,headerlinesIn);
    data = A.data(:,1);
    % this line is a very poor way to address the negative time stamp
    % problem
    A.textdata{headerlinesIn-3,1} = strrep(A.textdata{headerlinesIn-3,1},'-','');
    dateandtime = datenum(A.textdata{headerlinesIn-3,1});
    label = 'Voltage';
else
    data = [];
    fs = [];
    dateandtime = [];
    label = [];
end

props.Names = {};
props.Values = {};
props.Types = [];