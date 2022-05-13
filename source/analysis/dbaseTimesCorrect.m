function [dbase]=dbaseTimesCorrect(dbase);

%This function fixes the problem that the start time of file #n can be
%after the start time of file #n+1 if you manually pressed 'Start
%Recording' and stopped it before the automated buffer time that Aaron's
%GUI collects during isSinging detection.  All files whose start time is
%later than the start time of the next file will be eradiate of data
%(excluded)

%This function must be run before Get raster, because the overlap fix
%requires it.

fs=dbase.Fs;
for filenum=1:length(dbase.Times)-1
    if dbase.Times(filenum) > dbase.Times(filenum+1) & dbase.Times(filenum+1)>0
        dbase.SegmentTimes{filenum}=[];
        dbase.SegmentTitles{filenum}=[];
        dbase.SegmentIsSelected{filenum}=[];

        for event_num = 1:length(dbase.EventTimes) % go through all events categories (like spikes and stim pulses)
            for event_component = 1:size(dbase.EventTimes{event_num},1) % go through all event components (like zeniths and nadirs)
                dbase.EventTimes{event_num}{event_component,filenum} = [];
                dbase.EventIsSelected{event_num}{event_component,filenum} = [];
            end
        end
    end
end
dbase2=dbase;

