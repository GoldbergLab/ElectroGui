function [dbase] = vgm_dbaseMakeBoutSylls(dbase)
% this function takes a dbase and makes a field dbase.boutsyllstarttimes
% with the starttimes of syllables within bouts. Also makes endtimes. Also
% makes dbase.boutsyllnames and dbase.allboutsyllnames

boutsyllstarttimes = {};
boutsyllendtimes = {};
boutsyllnames = {};

boutstarts = dbase.boutstarts;
boutends = dbase.boutends;
syllstarts = dbase.syllstarttimes;
syllends = dbase.syllendtimes;
syllnames = dbase.syllnames;

for j = 1:length(boutstarts)
    
    jboutstarts = boutstarts{1,j};
    jboutends = boutends{1,j};
    jsyllstarts = syllstarts{1,j};
    jsyllends = syllends{1,j};
    jsyllnames = syllnames{1,j};
    
    tempsyllstarts = [];
    tempsyllends = [];
    tempsyllnames = [];
    
    for r = 1:length(jboutstarts)
        rsyllstarts = jsyllstarts(jsyllstarts >= jboutstarts(r) & jsyllstarts <= jboutends(r));
        rsyllends = jsyllends(jsyllends >= jboutstarts(r) & jsyllends <= jboutends(r));
        rsyllnames = jsyllnames(jsyllstarts >= jboutstarts(r) & jsyllstarts <= jboutends(r));
        tempsyllstarts = [tempsyllstarts rsyllstarts];
        tempsyllends = [tempsyllends rsyllends];
        tempsyllnames = [tempsyllnames rsyllnames];
    end
    boutsyllstarttimes{1,j} = tempsyllstarts;
    boutsyllendtimes{1,j} = tempsyllends;
    boutsyllnames{1,j} = tempsyllnames;
end

dbase.boutsyllstarttimes = boutsyllstarttimes;
dbase.boutsyllendtimes = boutsyllendtimes;
dbase.allboutsyllstarts = concatenate(boutsyllstarttimes);
dbase.allboutsyllends = concatenate(boutsyllendtimes);
dbase.boutsyllnames = boutsyllnames;
dbase.allboutsyllnames = concatenate(concatenate(boutsyllnames));

end