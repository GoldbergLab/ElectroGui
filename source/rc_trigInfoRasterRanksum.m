function [pvals,edges,Xsigon,Xsigoff,bErrorAct] = rc_trigInfoRasterRanksum(h,c,binsize,stepsize)

alpha = 0.05; % significance lvl
Ncon = 4; % number of conseq bins required for significance
Ncoff = 4; % n of conseq bin for off
WOI = [0,0.125]; % window of interest for onset of error response
smoothwin = 3;
bdirection = 0;

events1 = h.events;
n1 = length(events1);
events2 = c.events;
n2 = length(events2);
edges = h.edges(1):stepsize:h.edges(end)-binsize;
n_bins = length(edges);

pvals = zeros(1,n_bins);
H = zeros(1,n_bins);
hitRate = zeros(1,n_bins);
escRate = zeros(1,n_bins);

for i_bin = 1:n_bins
    x = zeros(n1,1);
    y = zeros(n2,1);
    for i_trial = 1:n1
        x(i_trial) = sum(events1{i_trial}>edges(i_bin) & events1{i_trial}<(edges(i_bin)+binsize));
    end
    for i_trial = 1:n2
        y(i_trial) = sum(events2{i_trial}>edges(i_bin) & events2{i_trial}<(edges(i_bin)+binsize));
    end
    [pvals(i_bin), H(i_bin)] = ranksum(x,y,'alpha',alpha);
    hitRate(i_bin) = mean(x);
    escRate(i_bin) = mean(y);
end

% remove acausal
H(edges<-0.0001) = 0;

% for significance bar
dataStart = h.edges(1);
dataStop = h.edges(end);
winstart = linspace(dataStart,dataStop-binsize,round((dataStop-binsize-dataStart)/stepsize+1));%dataStart:stepsize:dataStop-binsize;
X = winstart+binsize/2;
X = roundn(X,-3); %round to nearest ms

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
Xsigoff = Xsigoff - stepsize; % sigoff should be the last significant bin, not the one after that.
[Xsigoff, ind] = unique(Xsigoff);
Xsigon = Xsigon(ind);

% require response to be within window of interest
ind_xsigon = (Xsigon>=WOI(1) & Xsigon<=WOI(2));
Xsigon = Xsigon(ind_xsigon);
Xsigoff = Xsigoff(ind_xsigon);

rdescapesmooth = smooth(c.rd,smoothwin);
rdhitsmooth = smooth(h.rd,smoothwin);
errorzscore = zscore(rdescapesmooth-rdhitsmooth);
edges_zscore = c.edges;

[~, ind_max_errorzscore] = max(errorzscore); 
max_X_diff = edges_zscore(ind_max_errorzscore) + binsize/2; %change value to half of bin size used in trigInfo
ind_Xsig_diff_max = Xsigon <= max_X_diff+eps & Xsigoff+eps >= max_X_diff;

[~, ind_min_errorzscore] = min(errorzscore); 
min_X_diff = edges_zscore(ind_min_errorzscore) + binsize/2; %change value to half of bin size used in trigInfo
ind_Xsig_diff_min = Xsigon <= min_X_diff+eps & Xsigoff+eps >= min_X_diff;

ind_Xsig_diff = ind_Xsig_diff_max | ind_Xsig_diff_min;
Xsigon = Xsigon(ind_Xsig_diff);
Xsigoff = Xsigoff(ind_Xsig_diff);

if ~isempty(Xsigon) && Xsigon(1)>0.125
    Xsigon = [];
    Xsigoff = [];
end

bErrorAct = 0;
if ~isempty(Xsigon)
    errorsum = 0;
    for i_sig = 1%:length(Xsigon)  % consider the first response only
        edges_sig = find(edges_zscore<=Xsigoff(i_sig)-binsize/2 & edges_zscore>=Xsigon(i_sig)-binsize/2);
%         errorsum = errorsum + sum(errorzscore(edges_sig));
        errorsum = errorsum + errorzscore(edges_sig(1));
    end
    if errorsum<0
        bErrorAct = 1;
    else
        bErrorAct = 0;
    end
    % directionality requirement
    if bdirection ==1
        for i_sig = 1:length(Xsigon)
            if bErrorAct
                edges_sig = find(errorzscore'<0 & c.edges>Xsigon(i_sig) & c.edges<Xsigoff(i_sig));
                if ~isempty(edges_sig)
                    Xsigon(i_sig) = c.edges(edges_sig(1));
                    Xsigoff(i_sig) = c.edges(edges_sig(end));
                else
                    Xsigon(i_sig) = [];
                    Xsigoff(i_sig) = [];
                end
            else
                edges_sig = find(errorzscore'>0 & c.edges>Xsigon(i_sig) & c.edges<Xsigoff(i_sig));
                if ~isempty(edges_sig)
                    Xsigon(i_sig) = c.edges(edges_sig(1));
                    Xsigoff(i_sig) = c.edges(edges_sig(end));
                else
                    Xsigon(i_sig) = [];
                    Xsigoff(i_sig) = [];
                end
            end
        end
    end
end
