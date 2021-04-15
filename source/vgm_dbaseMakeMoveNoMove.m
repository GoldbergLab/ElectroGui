function dbase = vgm_dbaseMakeMoveNoMove(dbase)

% This function identifies hits and escapes that do or do not have movement onsets and offsets
% in a [0 0.2] window and makes separate fields for
% them in the dbase. The relevant feedback times are also identified
win = [0 0.2];
moveonsets = concatenate(dbase.moveonsets);
moveoffsets = concatenate(dbase.moveoffsets);
moves = sort([moveonsets moveoffsets]);

count_moves = 0;
count_nomoves = 0;
hitsyllstarts_moves = [];
fdbkdelays_moves = [];
hitsyllstarts_nomoves = [];
fdbkdelays_nomoves = [];

for j = 1:length(dbase.hitsyllstarts)
    if any(moves - (dbase.hitsyllstarts(j)+dbase.fdbkdelays(j)+win(1)) > 0 & moves - (dbase.hitsyllstarts(j)+dbase.fdbkdelays(j)+win(2)) < 0)
        count_moves = count_moves + 1;
        hitsyllstarts_moves(count_moves) = dbase.hitsyllstarts(j);
        fdbkdelays_moves(count_moves) = dbase.fdbkdelays(j);
    else
        count_nomoves = count_nomoves + 1;
        hitsyllstarts_nomoves(count_nomoves) = dbase.hitsyllstarts(j);
        fdbkdelays_nomoves(count_nomoves) = dbase.fdbkdelays(j);
    end
end
       
dbase.hitsyllstarts_moves = hitsyllstarts_moves;
dbase.fdbkdelays_moves = fdbkdelays_moves;
dbase.hitsyllstarts_nomoves = hitsyllstarts_nomoves;
dbase.fdbkdelays_nomoves = fdbkdelays_nomoves;

count_moves = 0;
count_nomoves = 0;
catchsyllstarts_moves = [];
catchsyllstarts_nomoves = [];

for j = 1:length(dbase.catchsyllstarts)
    if any(moves - (dbase.catchsyllstarts(j)+median(dbase.fdbkdelays)+win(1)) > 0 & moves - (dbase.catchsyllstarts(j)+median(dbase.fdbkdelays)+win(2)) < 0)
        count_moves = count_moves + 1;
        catchsyllstarts_moves(count_moves) = dbase.catchsyllstarts(j);
    else
        count_nomoves = count_nomoves + 1;
        catchsyllstarts_nomoves(count_nomoves) = dbase.catchsyllstarts(j);
    end
end
       
dbase.catchsyllstarts_moves = catchsyllstarts_moves;
dbase.catchsyllstarts_nomoves = catchsyllstarts_nomoves;

end