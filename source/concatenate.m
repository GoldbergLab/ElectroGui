function catspikes=concatenate(spiketimes)

catspikes = [];
a=size(spiketimes);
for i=1:a(1)
    for j = 1:a(2)
        catspikes = [catspikes, spiketimes{i,j}];
    end
end