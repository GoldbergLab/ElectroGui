function makeFolder
x = int2str(day(date))
y = int2str(month(date))
z = int2str(year(date))
str = sprintf('%s_%s_%s',y,x,z)
mkdir ('Z:\FieldL_16ch_ephys\RHD\rhd', str)
end

