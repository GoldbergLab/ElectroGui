function dbase = vgm_boutISInohitesc(dbase)

win = 0.3;

isi = [];
spktimes = [];

boutstarts = concatenate(dbase.boutstarts);
boutends = concatenate(dbase.boutends);
hitstarts = dbase.hitsyllstarts+dbase.fdbkdelays;
escstarts = dbase.catchsyllstarts+median(dbase.fdbkdelays);
pertstarts = sort([hitstarts escstarts]);
pertends = pertstarts+win;
spiketimes = concatenate(dbase.spiketimes);


for i = 1:length(boutstarts)
    temppertstarts = pertstarts(pertstarts > boutstarts(i) & pertstarts < boutends(i));
    temppertends = pertends(pertstarts > boutstarts(i) & pertstarts < boutends(i));
    if ~isempty(temppertstarts)
        tempspiketimes = spiketimes(spiketimes > boutstarts(i) & spiketimes < temppertstarts(1));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi];
        for j = 1:length(temppertstarts)-1
            tempspiketimes = spiketimes(spiketimes > temppertends(j) & spiketimes < temppertstarts(j+1));
            tempisi = diff(tempspiketimes);
            spktimes = [spktimes tempspiketimes];
            isi = [isi tempisi];
        end
        tempspiketimes = spiketimes(spiketimes > temppertends(end) & spiketimes < boutends(i));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi];
    else
        tempspiketimes = spiketimes(spiketimes > boutstarts(i) & spiketimes < boutends(i));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi]; 
    end
end

dbase.ISI.boutnohitesc = isi;
dbase.boutnohitescspiketimes = spktimes;

end


