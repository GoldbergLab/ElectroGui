function dbase = vgm_dbaseMakeMidBoutEnd(dbase)

% This function identifies hits and escapes that are in the middle of a
% bout and those that are the last in bout and makes separate fields for
% them in the dbase. The relevant feedback times are also identified

count_midbout = 0;
count_endbout = 0;
hitsyllstarts_midbout = [];
fdbkdelays_midbout = [];
hitsyllstarts_endbout = [];
fdbkdelays_endbout = [];

for j = 1:length(dbase.hitsyllstarts)
    ind_nextsyllstart = find(dbase.allsyllstarts - dbase.hitsyllends(j) > 0, 1, 'first');
    nextsyllstart = dbase.allsyllstarts(ind_nextsyllstart);
    if nextsyllstart - dbase.hitsyllends(j) <= 0.150
        count_midbout = count_midbout + 1;
        hitsyllstarts_midbout(count_midbout) = dbase.hitsyllstarts(j);
        fdbkdelays_midbout(count_midbout) = dbase.fdbkdelays(j);
    else
        count_endbout = count_endbout + 1;
        hitsyllstarts_endbout(count_endbout) = dbase.hitsyllstarts(j);
        fdbkdelays_endbout(count_endbout) = dbase.fdbkdelays(j);
    end
end
dbase.hitsyllstarts_midbout = hitsyllstarts_midbout;
dbase.fdbkdelays_midbout = fdbkdelays_midbout;
dbase.hitsyllstarts_endbout = hitsyllstarts_endbout;
dbase.fdbkdelays_endbout = fdbkdelays_endbout;

count_midbout = 0;
count_endbout = 0;
catchsyllstarts_midbout = [];
catchsyllstarts_endbout = [];

for j = 1:length(dbase.catchsyllstarts)
    ind_nextsyllstart = find(dbase.allsyllstarts - dbase.catchsyllends(j) > 0, 1, 'first');
    nextsyllstart = dbase.allsyllstarts(ind_nextsyllstart);
    if nextsyllstart - dbase.catchsyllends(j) <= 0.150
        count_midbout = count_midbout + 1;
        catchsyllstarts_midbout(count_midbout) = dbase.catchsyllstarts(j);
    else
        count_endbout = count_endbout + 1;
        catchsyllstarts_endbout(count_endbout) = dbase.catchsyllstarts(j);
    end
end
dbase.catchsyllstarts_midbout = catchsyllstarts_midbout;
dbase.catchsyllstarts_endbout = catchsyllstarts_endbout;

end