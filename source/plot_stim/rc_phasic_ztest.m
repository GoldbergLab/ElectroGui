function [Xsigon, Xsigoff] = rc_phasic_ztest(trigInfo,rd,edges)

% this is a z test using [-1.03,-0.03] time period as baseline

Ncon = 2; % # conseq bins required for significance.
Ncoff = 2;
winsz = edges(2)-edges(1);
stepsz = min(0.005,winsz/2);
dataStart=edges(1);
dataStop=edges(end);
Xsigon = [];
Xsigoff = [];

winstart = dataStart:stepsz:dataStop-winsz;
X = winstart+winsz/2;

% new histogram
RateMat = [];
for i=1:length(winstart)
    for k=1:length(trigInfo.events)
        RateMat(k,i) = sum(trigInfo.events{k} >= winstart(i) & trigInfo.events{k} < winstart(i)+winsz);
    end
end
% allevents=concatenate(trigInfo.events);
% RateVec=histc(allevents,winstart);
% RateVec = smooth(RateVec,smoothwin);

RateVec = mean(RateMat,1);

prior_win = winstart<-winsz & winstart >= -1-winsz;
prior_rate = RateVec(prior_win);            

Mprior_rate = mean(prior_rate);
sigmaprior_rate = std(prior_rate);
% special case: no firing in window
if sigmaprior_rate == 0 && Mprior_rate == 0
    return;
end

for i = 1:length(winstart)
    [H(i), p(i)] = ztest(RateVec(i), Mprior_rate, sigmaprior_rate, 'alpha', 0.05);
end 

H(winstart<-0.1) = 0;
Xsig = X(logical(H));

Hsigon = H;
if Ncon>1
    for i = 1:Ncon-1
        Hsigon = Hsigon & [H(i+1:end) zeros(1,i)];
    end
end
Hsigon = [0 diff(Hsigon)] > 0;
Xsigon = X(Hsigon);

notH = not(H);
Hsigoff = notH;
if Ncoff>1
    for i = 1:Ncoff-1
        Hsigoff = Hsigoff & [notH(i+1:end) zeros(1,i)];
    end
end
Hsigoff = [0 diff(Hsigoff)] > 0;
Hsigoff(end) = true;
Xsigoff = X(Hsigoff);

Xsigofftemp = [];
for i = 1:length(Xsigon)
    Xsigofftemp(i) = Xsigoff(find(Xsigoff - Xsigon(i) > 0, 1, 'first'));
end
Xsigoff = Xsigofftemp;
Xsigoff = Xsigoff - stepsz;
[Xsigoff, ind] = unique(Xsigoff);
Xsigon = Xsigon(ind);

% response

[~, ind_max_rate] = max(rd); 
max_X_rate = edges(ind_max_rate) + winsz/2; %change value to half of bin size used in trigInfo
ind_Xsig_rate_max = (Xsigon <= max_X_rate+0.0001) & (Xsigoff+0.0001 >= max_X_rate); % small value to tolerate floating point inaccuracy

[~, ind_min_rate] = min(rd); 
min_X_rate = edges(ind_min_rate) + winsz/2; %change value to half of bin size used in trigInfo
ind_Xsig_rate_min = (Xsigon <= min_X_rate+0.0001) & (Xsigoff+0.0001 >= min_X_rate);

ind_Xsig_rate = ind_Xsig_rate_max | ind_Xsig_rate_min;
Xsigon = Xsigon(ind_Xsig_rate);
Xsigoff = Xsigoff(ind_Xsig_rate);


% latency and duration