function dbase=jg_vta_dbasegetmishits(dbase);

%this function gets mishittimes

mishitsylls=dbase.allsyllstarts(find(isstrprop(dbase.allsyllnames,'upper') & dbase.allsyllnames~=dbase.fdbksyll & dbase.allsyllnames~='Z' & dbase.allsyllnames~='z'));
mishitsylloffs=dbase.allsyllends(find(isstrprop(dbase.allsyllnames,'upper') & dbase.allsyllnames~=dbase.fdbksyll & dbase.allsyllnames~='Z' & dbase.allsyllnames~='z'));
allfdbks=concatenate(dbase.fdbktimes);

if ~isempty(mishitsylls)
    mishittimes=[];
    for i=1:length(mishitsylls);
        temp=allfdbks-mishitsylls(i);
        temp=temp(find(temp>0 & temp<mishitsylloffs(i)));
        if ~isempty(temp)
            temp=min(temp);
            temp=temp+mishitsylls(i);
            mishittimes=[mishittimes temp];
        end
    end

    dbase.mishittimes=mishittimes;

else
    dbase.mishittimes=[];
end