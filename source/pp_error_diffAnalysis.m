function [Xsigon, Xsigoff] = pp_error_diffAnalysis(dbase,errorzscore,varargin)


if isempty(varargin);
binsize = 25;
else
binsize=varargin{1};
end


bdirection = 0;

count = 0;
Ncon = 4; % # conseq bins required for significance. 4 for DA responses
Ncoff = 8;
winsz = 0.03;
stepsz = 0.002;

fsz = 20;
lw = 2;

count = count+1;

eventOnsetsHit = dbase.(['trigInfoFhitbin' num2str(binsize)]).events;
eventOnsetsEscape = dbase.(['trigInfocatchbin' num2str(binsize)]).events;
% eventOnsetsHitpreCC = dbase.(['trigInfoFhitbin' num2str(binsize)])preCC.events;
% eventOnsetsEscapepreCC = dbase.(['trigInfocatchbin' num2str(binsize)])preCC.events;
% eventOnsetsHitpostCC = dbase.(['trigInfoFhitbin' num2str(binsize)])postCC.events;
% eventOnsetsEscapepostCC = dbase.(['trigInfocatchbin' num2str(binsize)])postCC.events;
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
% eventOnsetsAllpreCC = [eventOnsetsHitpreCC eventOnsetsEscapepreCC];
% eventOnsetsAllpostCC = [eventOnsetsHitpostCC eventOnsetsEscapepostCC];
% eventOnsetsMove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
% eventOnsetsMoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.events;
% eventOnsetsMoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.events;
edges = dbase.(['trigInfoFhitbin' num2str(binsize)]).edges;
rdhit = dbase.(['trigInfoFhitbin' num2str(binsize)]).rd;
% rdhitpreCC = dbase.(['trigInfoFhitbin' num2str(binsize)])preCC.rd;
% rdhitpostCC = dbase.(['trigInfoFhitbin' num2str(binsize)])postCC.rd;
rdescape = dbase.(['trigInfocatchbin' num2str(binsize)]).rd;
% rdescapepreCC = dbase.(['trigInfocatchbin' num2str(binsize)])preCC.rd;
% rdescapepostCC = dbase.(['trigInfocatchbin' num2str(binsize)])postCC.rd;
% rdmove = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rd;
% rdmoveNoSyll = dbase.trigInfoMoveOnsetsSpikesNoSylls.rd;
% rdmoveBout = dbase.trigInfoBoutMoveOnsetsSpikes.rd;
rdhitsmooth = dbase.(['trigInfoFhitbin' num2str(binsize)]).rds;
rdescapesmooth = dbase.(['trigInfocatchbin' num2str(binsize)]).rds;
% rdmovesmooth = dbase.trigInfoMoveOnsetsSpikesNoBoutSylls.rds;
% rdmoveNoSyllsmooth = dbase.trigInfoMoveOnsetsSpikesNoSylls.rds;
% rdmoveBoutsmooth = dbase.trigInfoBoutMoveOnsetsSpikes.rds;
dataStart = dbase.(['trigInfoFhitbin' num2str(binsize)]).edges(1);
dataStop = dbase.(['trigInfoFhitbin' num2str(binsize)]).edges(end);
pmin = dbase.(['trigInfoFhitbin' num2str(binsize)]).pval.minrates;
pmin_stats(count) = pmin;
mintime = dbase.(['trigInfoFhitbin' num2str(binsize)]).corrtime.mins;
pmax = dbase.(['trigInfocatchbin' num2str(binsize)]).pval.maxrates;
pmax_stats(count) = pmax;
maxtime = dbase.(['trigInfocatchbin' num2str(binsize)]).corrtime.maxs;
hitmin = min(rdhitsmooth);
escapemax = max(rdescapesmooth);
yrange = escapemax-hitmin;
trigStarts = dbase.(['trigInfoFhitbin' num2str(binsize)]).trigStarts;

fdbktimes = concatenate(dbase.fdbktimes);
fdbkdur = 0.050;

winstart = dataStart:stepsz:dataStop-winsz;
X = winstart+winsz/2;

% difference analysis

HitMat = [];
for i=1:length(winstart)
    for k=1:length(eventOnsetsHit)
        HitMat(k,i) = sum(eventOnsetsHit{k} >= winstart(i) & eventOnsetsHit{k} < winstart(i)+winsz);
    end
end

EscapeMat = [];
for i=1:length(winstart)
    for k=1:length(eventOnsetsEscape)
        EscapeMat(k,i) = sum(eventOnsetsEscape{k} >= winstart(i) & eventOnsetsEscape{k} < winstart(i)+winsz);
    end
end

HitVec = mean(HitMat);
EscapeVec = mean(EscapeMat);
DiffVec = EscapeVec-HitVec;

prior_diff = DiffVec(winstart<-winsz);            

Mprior_diff = mean(prior_diff);
sigmaprior_diff = std(prior_diff);


for i = 1:length(winstart)
    [H(i), p(i)] = ztest(DiffVec(i), Mprior_diff, sigmaprior_diff, 'alpha', 0.05);

end 



%             %directionality requirement
if bdirection == 1
    H(HitVec>EscapeVec) = 0;
end

Xsig = X(logical(H));

Hsigon = H;
for i = 1:Ncon-1
    Hsigon = Hsigon & [H(i+1:end) zeros(1,i)];
end
Hsigon = [0 diff(Hsigon)] > 0;
Xsigon = X(Hsigon);

notH = not(H);
Hsigoff = notH;
for i = 1:Ncoff-1
    Hsigoff = Hsigoff & [notH(i+1:end) zeros(1,i)];
end
Hsigoff = [0 diff(Hsigoff)] > 0;
Hsigoff(end) = true;
Xsigoff = X(Hsigoff);

Xsigofftemp = [];
for i = 1:length(Xsigon)
    Xsigofftemp(i) = Xsigoff(find(Xsigoff - Xsigon(i) > 0, 1, 'first'));
end
Xsigoff = Xsigofftemp;
[Xsigoff, ind] = unique(Xsigoff);
Xsigon = Xsigon(ind);

[~, ind_max_errorzscore] = max(errorzscore); 
max_X_diff = edges(ind_max_errorzscore) + 0.005; %change value to half of bin size used in trigInfo

ind_Xsig_diff = Xsigon < max_X_diff & Xsigoff > max_X_diff;
Xsigon = Xsigon(ind_Xsig_diff);
Xsigoff = Xsigoff(ind_Xsig_diff);

if ~isempty(Xsigon)
    latency_diff(count) = Xsigon;
    duration_diff(count) = Xsigoff-Xsigon;
else
    latency_diff(count) = NaN;
    duration_diff(count) = NaN;
end
end %for