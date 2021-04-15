function dbase = vgm_dprime(dbase, N)
%vgm_dprime does the dprime shuffle analysis and makes the field dprime in
%the dbase
%N is the shuffle number

win = 0.2;
winsz = 0.05;
stepsz = 0.005;

eventOnsetsHit = dbase.trigInfoFhitbin25.events;
eventOnsetsEscape = dbase.trigInfocatchbin25.events;
eventOnsetsAll = [eventOnsetsHit eventOnsetsEscape];
dataStart = dbase.trigInfoFhitbin25.edges(1);
dataStop = dbase.trigInfoFhitbin25.edges(end);

winstart = dataStart:stepsz:dataStop-winsz;
X = winstart+winsz/2;

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

for i= 1:length(winstart)
    dprime(i) = (mean(EscapeMat(:,i))-mean(HitMat(:,i)))/sqrt(0.5*(var(HitMat(:,i))+var(EscapeMat(:,i))));
end

dprime_max = max(dprime(X>0 & X<=win));
dprime_min = min(dprime(X>0 & X<=win));

Nhit = length(eventOnsetsHit);
Nescape = length(eventOnsetsEscape);
Nall = Nhit+Nescape;

for sn = 1:N
    ind_all = randperm(Nall);
    ind_hit = ind_all(1:Nhit);
    ind_escape = ind_all(Nhit+1:end);
    eventsHit = eventOnsetsAll(ind_hit);
    eventsEscape = eventOnsetsAll(ind_escape);
    
    HitMat = [];
    for i=1:length(winstart)
        for k=1:length(eventsHit)
            HitMat(k,i) = sum(eventsHit{k} >= winstart(i) & eventsHit{k} < winstart(i)+winsz);
        end
    end
    
    EscapeMat = [];
    for i=1:length(winstart)
        for k=1:length(eventsEscape)
            EscapeMat(k,i) = sum(eventsEscape{k} >= winstart(i) & eventsEscape{k} < winstart(i)+winsz);
        end
    end
    
    for i= 1:length(winstart)
        dprime_mc(i) = (mean(EscapeMat(:,i))-mean(HitMat(:,i)))/sqrt(0.5*(var(HitMat(:,i))+var(EscapeMat(:,i))));
    end
    dprime_mc_max(sn) = max(dprime_mc);
    dprime_mc_min(sn) = min(dprime_mc);
end

ptile_dprime_max = 100*sum(dprime_mc_max<dprime_max)/N;
ptile_dprime_min = 100*sum(dprime_mc_min<dprime_min)/N;

dbase.dprime.N = N;
dbase.dprime.win = win;
dbase.dprime.X = X;
dbase.dprime.dprime = dprime;
dbase.dprime.dprime_max = dprime_max;
dbase.dprime.dprime_min = dprime_min;
dbase.dprime.dprime_mc_max = dprime_mc_max;
dbase.dprime.dprime_mc_min = dprime_mc_min;
dbase.dprime.ptile_dprime_max = ptile_dprime_max;
dbase.dprime.ptile_dprime_min = ptile_dprime_min;
end

