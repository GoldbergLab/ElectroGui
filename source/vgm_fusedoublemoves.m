function dbase=vgm_fusedoublemoves(dbase)

movedurs=[];

for i=1:length(dbase.moveonsets);
    tempoffsets=dbase.moveoffsets{i};
    temponsets=dbase.moveonsets{i};

    for m=2:length(tempoffsets)
        if (temponsets(m)-tempoffsets(m-1))<.01
            temponsets(m)=NaN;
            tempoffsets(m-1)=NaN;
        end
    end
    dbase.moveonsets{i}=temponsets(~isnan(temponsets));
    dbase.moveoffsets{i}=tempoffsets(~isnan(tempoffsets));

    movedurs=[movedurs dbase.moveoffsets{i}-dbase.moveonsets{i}];
end

dbase.movedurs=movedurs;