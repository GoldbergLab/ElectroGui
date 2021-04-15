function [dbase excludedfiles]=dbaseExcludeDatada(dbase);

%This function goes through the dbase and any filenum with the boolean
%bExcluded=1 has all its spikes/events/sylls/sounds made to =[];

%note for dbases where you have two bExcludeds (like if you have units on two electrodes, 
%you will make bExcluded and bExcluded2 (you can make two logicals).  if bExcluded2, then
%excluded='bExcluded2'

excluded='bExcluded';%This is the name of the boolean which you want to use to tag files to be excluded
excludedfiles=[];

for filenum=1:length(dbase.FileLength)
    
    % Determine which property is bExcluded
    which_b = 0;
    for prop_num = 1:length(dbase.Properties.Names{filenum})
        if strcmp(dbase.Properties.Names{filenum}{prop_num},excluded)
            which_b = prop_num;
        end
    end
    
    if which_b > 0 & dbase.Properties.Values{filenum}{which_b}==1
        %in here is where you will delete all spiketimes and all syll segments
        dbase.SegmentTimes{filenum}=[];
        dbase.SegmentTitles{filenum}=[];
        dbase.SegmentIsSelected{filenum}=[];
        
        for event_num = 1:length(dbase.EventTimes) % go through all events categories (like spikes and stim pulses)
            for event_component = 1:size(dbase.EventTimes{event_num},1) % go through all event components (like zeniths and nadirs)
                dbase.EventTimes{event_num}{event_component,filenum} = [];
                dbase.EventIsSelected{event_num}{event_component,filenum} = [];
            end
        end
        
        excludedfiles=[excludedfiles filenum];
    end
end