function dbase = rc_dbaseRemoveEmptySylls(dbase)

for i=1:length(dbase.Times)
    ind_empty = find(strcmp(dbase.SegmentTitles{i},''));
    dbase.SegmentTitles{i}(ind_empty)=[];
    dbase.SegmentTimes{i}(ind_empty,:)=[];
    dbase.SegmentIsSelected{i}(ind_empty)=[];
end