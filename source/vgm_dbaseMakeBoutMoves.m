function [dbase] = vgm_dbaseMakeBoutMoves(dbase)
% this function takes a dbase and makes a field dbase.boutsyllstarttimes
% with the starttimes of syllables within bouts. Also makes endtimes. Also
% makes dbase.boutsyllnames and dbase.allboutsyllnames

boutmoveonsets = {};
boutmoveoffsets = {};

boutstarts = dbase.boutstarts;
boutends = dbase.boutends;
moveonsets = dbase.moveonsets;
moveoffsets = dbase.moveoffsets;

for j = 1:length(boutstarts)
    
    jboutstarts = boutstarts{1,j};
    jboutends = boutends{1,j};
    jmoveonsets = moveonsets{1,j};
    jmoveoffsets = moveoffsets{1,j};
    
    tempmoveonsets = [];
    tempmoveoffsets = [];
    
    for r = 1:length(jboutstarts)
        ind_onsets = jmoveonsets >= jboutstarts(r) & jmoveonsets <= jboutends(r);
        ind_offsets = jmoveoffsets >= jboutstarts(r) & jmoveoffsets <= jboutends(r);
        ind = ind_onsets & ind_offsets;
        rmoveonsets = jmoveonsets(ind);
        rmoveoffsets = jmoveoffsets(ind);
        tempmoveonsets = [tempmoveonsets rmoveonsets];
        tempmoveoffsets = [tempmoveoffsets rmoveoffsets];
    end
    boutmoveonsets{1,j} = tempmoveonsets;
    boutmoveoffsets{1,j} = tempmoveoffsets;
end

dbase.boutmoveonsets = boutmoveonsets;
dbase.boutmoveoffsets = boutmoveoffsets;
dbase.allboutmoveonsets = concatenate(boutmoveonsets);
dbase.allboutmoveoffsets = concatenate(boutmoveoffsets);

end