%script to update all sorted dbases with Han's markers and segmentations,
%THIS WILL REPLACE ANY EXISTING SEGMENTATIONS SO BE CAREFUL, THIS COULD
%BRUTUALLY SCREW YOU OVER IF YOU ARE USING THIS WILLY NILLY 

clear
close all
sortdir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted';
savedir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_new_segs';
filestruc = dir([sortdir '\*.mat']);
dbase_list = {filestruc.name};

for i = 1:length(dbase_list)
    display(['dbase ' num2str(i) ' of ' ...
        num2str(length(dbase_list))])
    dbase = load([sortdir '\' dbase_list{i}]);
    dbase = dbase.dbase;

    dbase = cj_add_Han_segments(dbase,0)

    thisname = strrep(dbase_list{i},'.mat','');
    save([savedir '\' thisname '_newsegs.mat'],'dbase')

end
