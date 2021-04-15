function trigInfo = vgm_reliability(dbase, trigInfo, state)
%This function takes a trigInfo and calculates the reliability of spiking
%in a window centered around a significant peak or valley

if strcmp(state,'all')
    rate = dbase.rates.all;
elseif strcmp(state,'bout')
    rate = dbase.rates.bout;
elseif strcmp(state,'silent')
    rate = dbase.rates.silent;
else
    error('Input argument not recognized')
end
window = 0.075; % 75 ms window in which to calculate mean IFR

Relmins = [];
Relmaxs = [];

if isempty(trigInfo.edges)
    return
end

edges = trigInfo.edges;
events = trigInfo.events;

if trigInfo.pval.minrates < 0.05
    Rel = [];
    wincent = trigInfo.corrtime.mins;
    win(1) = wincent-window/2;
    win(2) = wincent+window/2;
    for j = 1:length(events)
        firstspike = events{j}(find(events{j} < win(1),1,'last'));
        if isempty(firstspike)
            firstspike = edges(1);
        end
        lastspike = events{j}(find(events{j} > win(2),1,'first'));
        if isempty(lastspike)
            lastspike = edges(end);
        end
        middlespikes = events{j}(events{j} > win(1) & events{j} < win(2));
        if isempty(middlespikes)
            IFR_mean = 1/(lastspike-firstspike);
        else
            IFR_mean = ((middlespikes(1)-win(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (win(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(win(2)-win(1));
        end
        if IFR_mean < rate
            Rel(j) = 1;
        else
            Rel(j) = 0;
        end
        
    end
    Relmins = sum(Rel)/length(Rel);
else
    Relmins = [];
end

if trigInfo.pval.maxrates < 0.05
    Rel = [];
    wincent = trigInfo.corrtime.maxs;
    win(1) = wincent-window/2;
    win(2) = wincent+window/2;
    for j = 1:length(events)
        firstspike = events{j}(find(events{j} < win(1),1,'last'));
        if isempty(firstspike)
            firstspike = edges(1);
        end
        lastspike = events{j}(find(events{j} > win(2),1,'first'));
        if isempty(lastspike)
            lastspike = edges(end);
        end
        middlespikes = events{j}(events{j} > win(1) & events{j} < win(2));
        if isempty(middlespikes)
            IFR_mean = 1/(lastspike-firstspike);
        else
            IFR_mean = ((middlespikes(1)-win(1))/(middlespikes(1)-firstspike) + length(middlespikes)-1 + (win(2)-middlespikes(end))/(lastspike-middlespikes(end)))/(win(2)-win(1));
        end
        if IFR_mean > rate
            Rel(j) = 1;
        else
            Rel(j) = 0;
        end
        
    end
    
    Relmaxs = sum(Rel)/length(Rel);
else
    Relmaxs = [];
end

trigInfo.reliability.mins = Relmins;
trigInfo.reliability.maxs = Relmaxs;

end

