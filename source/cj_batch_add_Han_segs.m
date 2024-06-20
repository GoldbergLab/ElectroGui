%script to update all sorted dbases with Han's markers and segmentations,
%THIS WILL REPLACE ANY EXISTING SEGMENTATIONS SO BE CAREFUL, THIS COULD
%BRUTUALLY SCREW YOU OVER IF YOU ARE USING THIS WILLY NILLY 
clear
direc = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs\';

names = dir([direc '*.mat']);
names = {names.name};
names = natsort(names);
for i = 1:length(names)
    display(['dbase ' num2str(i) ' of ' ...
    num2str(length(names))])
    dbase = load([direc names{i}]);
    dbase = dbase.dbase;
    dbase = cj_add_Han_segments(dbase,0);

    %thisname = strrep(names{i},'.mat','');
    save([direc names{i}],'dbase')

end
