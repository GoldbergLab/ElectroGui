% function dbase=vgm_lassoglm(dbase)

% this function uses the lassoglm function to estimate the relative
% contributon of movement and song syllable in predicting the firing rate
% of neurons

boutstarts = concatenate(dbase.boutstarts);
boutends = concatenate(dbase.boutends);
boutdurs = boutends-boutstarts;
cumboutdurs = cumsum(boutdurs);
spiketimes = concatenate(dbase.spiketimes);
syllstarts = concatenate(dbase.syllstarttimes);
syllends = concatenate(dbase.syllendtimes);
movestarts = concatenate(dbase.moveonsets);
moveends = concatenate(dbase.moveoffsets);

fullspiketimes = [];
fullsyllstarts = [];
fullsyllends = [];
fullmovestarts = [];
fullmoveends = [];
for i = 1:length(boutstarts)
    boutspiketimes = spiketimes(spiketimes > boutstarts(i) & spiketimes < boutends(i));
    boutsyllstarts = syllstarts(syllstarts > boutstarts(i) & syllends < boutends(i));
    boutsyllends = syllends(syllstarts > boutstarts(i) & syllends < boutends(i));
    boutmovestarts = movestarts(movestarts > boutstarts(i) & moveends < boutends(i));
    boutmoveends = moveends(movestarts > boutstarts(i) & moveends < boutends(i));
    
    boutspiketimes = boutspiketimes-boutstarts(i);
    boutsyllstarts = boutsyllstarts-boutstarts(i);
    boutsyllends = boutsyllends-boutstarts(i);
    boutmovestarts = boutmovestarts-boutstarts(i);
    boutmoveends = boutmoveends-boutstarts(i);
    
    if i >= 2
        boutspiketimes = boutspiketimes+cumboutdurs(i-1);
        boutsyllstarts = boutsyllstarts+cumboutdurs(i-1);
        boutsyllends = boutsyllends+cumboutdurs(i-1);
        boutmovestarts = boutmovestarts+cumboutdurs(i-1);
        boutmoveends = boutmoveends+cumboutdurs(i-1);
    end
    fullspiketimes = [fullspiketimes boutspiketimes];
    fullsyllstarts = [fullsyllstarts boutsyllstarts];
    fullsyllends = [fullsyllends boutsyllends];
    fullmovestarts = [fullmovestarts boutmovestarts];
    fullmoveends = [fullmoveends boutmoveends];
end
t = 0:0.001:sum(boutdurs);
fullisi = diff(fullspiketimes);
fullifr = 1./fullisi;

ifr = zeros(1,length(t));
for i = 1:length(fullifr)
    ifr(t >= fullspiketimes(i) & t < fullspiketimes(i+1)) = fullifr(i);
end

spkcnt = zeros(1,length(t));
for i = 1:length(t)-1
    spkcnt(i) = sum(fullspiketimes >= t(i) & fullspiketimes < t(i+1));
end

syll = zeros(1,length(t));
for i = 1:length(fullsyllstarts)
    syll(t >= fullsyllstarts(i) & t <= fullsyllends(i)) = 1;
end

move = zeros(1,length(t));
for i = 1:length(fullmovestarts)
    move(t >= fullmovestarts(i) & t <= fullmoveends(i)) = 1;
end

Y = ifr;
% Y = spkcnt;

t_lag = 1;
N_lag = 100;


X(1,:) = move;
for i = 1:N_lag
    X(1+i,:) = circshift(move,[0 t_lag*i]);
    X(N_lag+1+i,:) = circshift(move,[0 -t_lag*i]);
end
X(2*N_lag+2,:) = syll;
for i = 1:N_lag
    X(2*N_lag+2+i,:) = circshift(syll,[0 t_lag*i]);
    X(3*N_lag+2+i,:) = circshift(syll,[0 -t_lag*i]);
end

% Y(Y==0) = eps;

Y = Y';
X = X';

Xz = zscore(X);

distr = 'poisson';

[B1,FitInfo1] = lassoglm(Xz,Y,distr, 'CV', 10);
Xnull = ones(size(X,1),1);
[Bnull,FitInfonull] = lassoglm(Xnull,Y,distr, 'CV', 10);
ind = 1;

dev_mod = FitInfo1.Deviance(ind);
dev_null = FitInfonull.Deviance(1);
dev_red = 1-dev_mod/dev_null;



NormBmove1 = norm(B1(1:2*N_lag+1,ind));
NormBsyll1 = norm(B1(2*N_lag+2:4*N_lag+2,ind));
NormB1 = norm(B1(1:4*N_lag+2, ind));

movecont = NormBmove1^2/NormB1^2;


cnst = FitInfo1.Intercept(ind);
Bint = [cnst;B1(:,ind)];

preds = glmval(Bint,X,'log');


%%
dbase.lassoglm.t = t;
dbase.lassoglm.ifr = ifr;
dbase.lassoglm.spkcnt = spkcnt;
dbase.lassoglm.move = move;
dbase.lassoglm.syll = syll;
dbase.lassoglm.X = X;
dbase.lassoglm.Xz = Xz;
dbase.lassoglm.Y = Y;
dbase.lassoglm.B = B1;
dbase.lassoglm.FitInfo = FitInfo1;
dbase.lassoglm.Bnull = Bnull;
dbase.lassoglm.FitInfonull = FitInfonull;
dbase.lassoglm.preds = preds;
dbase.lassoglm.dev.mod = dev_mod;
dbase.lassoglm.dev.null = dev_null;
dbase.lassoglm.dev.red = dev_red;
dbase.lassoglm.norm.move = NormBmove1;
dbase.lassoglm.norm.syll = NormBsyll1;
dbase.lassoglm.norm.B = NormB1;
dbase.lassoglm.movecont = movecont;
dbase.lassoglm.distr = distr;



% end