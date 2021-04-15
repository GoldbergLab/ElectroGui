function dbase=vgm_dbasegetmishits(dbase)

%this function gets mishittimes
ind_mis = find(isstrprop(dbase.allsyllnames,'upper') & dbase.allsyllnames~=dbase.fdbksyll & dbase.allsyllnames~='Z' & dbase.allsyllnames~='z');
mishitsylls=dbase.allsyllstarts(ind_mis);
mishitsylloffs=dbase.allsyllends(ind_mis);
mishitsyllnames = dbase.allsyllnames(ind_mis);
allfdbks=concatenate(dbase.fdbktimes);

if ~isempty(mishitsylls)
    mishittimes=[];
    mishittimessyllnames = [];
    for i=1:length(mishitsylls);
        temp=allfdbks-mishitsylls(i);
        temp=temp(temp>0 & temp+mishitsylls(i) < mishitsylloffs(i));
        if ~isempty(temp)
            temp=min(temp);
            temp=temp+mishitsylls(i);
            mishittimes=[mishittimes temp];
            mishittimessyllnames = [mishittimessyllnames mishitsyllnames(i)];
        end
    end

    dbase.mishittimes=mishittimes;
    dbase.mishitsyllnames = mishittimessyllnames;

else
    dbase.mishittimes=[];
end