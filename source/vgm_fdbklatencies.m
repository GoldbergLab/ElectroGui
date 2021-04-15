function dbase=vgm_fdbklatencies(dbase)

allfdbks=concatenate(dbase.fdbktimes);
allsyllstarts=concatenate(dbase.syllstarttimes);
hits=find(dbase.allsyllnames==upper(dbase.fdbksyll));
hitsyllstarts=allsyllstarts(hits);


for i=1:length(hitsyllstarts);
    templatency=allfdbks-hitsyllstarts(i);
    templatency=templatency(find(templatency>0));
    latency(i)=min(templatency);
end

dbase.fdbklatencies=latency;

end



