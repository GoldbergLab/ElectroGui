function dbase = vgm_nonsongISInoZ(dbase)

win = 0.3;

isi = [];
spktimes = [];


bunusestarts = dbase.filestarttimes(logical(dbase.unusables));
bunuseends = dbase.fileendtimes(logical(dbase.unusables));
Zstarts = dbase.allsyllstarts(dbase.allsyllnames == 'Z' | dbase.allsyllnames == 'z');
Zends = Zstarts+win;
spiketimes = concatenate(dbase.spiketimes);


for i = 1:length(bunusestarts)
    tempZstarts = Zstarts(Zstarts > bunusestarts(i) & Zstarts < bunuseends(i));
    tempZends = Zends(Zstarts > bunusestarts(i) & Zstarts < bunuseends(i));
    if ~isempty(tempZstarts)
        tempspiketimes = spiketimes(spiketimes > bunusestarts(i) & spiketimes < tempZstarts(1));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi];
        for j = 1:length(tempZstarts)-1
            tempspiketimes = spiketimes(spiketimes > tempZends(j) & spiketimes < tempZstarts(j+1));
            tempisi = diff(tempspiketimes);
            spktimes = [spktimes tempspiketimes];
            isi = [isi tempisi];
        end
        tempspiketimes = spiketimes(spiketimes > tempZends(end) & spiketimes < bunuseends(i));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi];
    else
        tempspiketimes = spiketimes(spiketimes > bunusestarts(i) & spiketimes < bunuseends(i));
        tempisi = diff(tempspiketimes);
        spktimes = [spktimes tempspiketimes];
        isi = [isi tempisi]; 
    end
end

dbase.ISI.nonsongnoZ = isi;
dbase.nonsongnoZspiketimes = spktimes;

end


