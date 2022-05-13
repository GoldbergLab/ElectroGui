function catspikes=concatenateMotifString(spiketimes);

%This function is used with Motif Detection to make unlabelled syllables =
%'0' in the string.

catspikes = [];
for j = 1:length(spiketimes)
    if isempty(spiketimes{j})
        spiketimes{j}='0';
    end
    catspikes = [catspikes, spiketimes{j}];
end