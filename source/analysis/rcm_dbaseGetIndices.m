function dbase=rcm_dbaseGetIndices(dbase)

%This function creates dbase.indx,dbase.stimindx and dbase.moveindx and
%also gets runs dbaseGetRaster to get the spike, stim, and move times

%IMPORTANT: This function assumes Event Functions where spikes are 'FIRBandPass', Stims are
%'Raw' and Movement is 'SubMeanSqSmooth_vg'

%It also assumes that the dbase.title has the form dbaseXXXChan8.mat
%because in cases where there are multiple 'FIRBandPass', for example, it
%will pick the one that corresponds to the Chan # in the title

% if ~isfield(dbase,'indx');
indx=[];stimindx=[];
for i = 1:length(dbase.EventDetectors)
    %     if strcmp(dbase.EventFunctions{i},'SubMeanSqSmooth_vg');
    if strcmp(dbase.EventFunctions{i},'DetrendSqSmooth_vg');

        dbase.moveindx=i;
        %         [dbase.moveonsets,dbase.moveoffsets,dbase.movedurs]=dbaseGetMoveRaster(dbase, dbase.moveindx);
    end
    if strcmp(dbase.EventFunctions{i},'(Raw)');
        stimindx=[stimindx i];  dbase.stimindx=i;
        if length(stimindx)>1%this loop below considers cases where there are more than one Raw used
            chan=dbase.title(3+strfind(dbase.title,'han'));%han allows for Chan or chan
            for j=1:length(stimindx)
                if str2num(chan) == str2num(dbase.EventSources{stimindx(j)}(end-1:end))
                    dbase.stimindx=stimindx(j);
                end
            end
        end
        dbase.stimtimes = vgm_dbaseGetRaster_NotSpikes(dbase,dbase.stimindx);
    end


    if strcmp(dbase.EventDetectors{i},'Spikes_AA') &&...
        (strcmp(dbase.EventFunctions{i},'FIRBandPass2')) || strcmp(dbase.EventFunctions{i},'FIRBandPass');
        indx=[indx i];  dbase.indx=i;
        if length(indx)>1;%this loop below considers cases where there are more than one FIR bandpasses used
            chan=dbase.title(4+strfind(dbase.title,'chan'):5+strfind(dbase.title,'chan')); 
            firbandx = dbase.title(3+strfind(dbase.title,'FIR'));  
            for j=1:length(indx)
                if str2num(chan) == str2num(dbase.EventSources{indx(j)}(end-1:end))   
                    if isempty(firbandx)
                        dbase.indx=indx(j);
                    elseif strcmp(firbandx,dbase.EventFunctions{indx(j)}(end))
                        dbase.indx=indx(j);
                    end
                end
            end
        end
        dbase = vgm_dbaseGetRaster_Spikes(dbase,dbase.indx);

    end

    %feedback events below
    if strcmp(dbase.EventFunctions{i},'Multiunit_plot') && strcmp(dbase.EventDetectors{i},'ThresholdCrossings')
        dbase.fdbkindx=i;fdbkindx=i;

        for i=1:size(dbase.EventTimes{fdbkindx},2)
            if ~isempty(dbase.EventTimes{fdbkindx}{1,i})
                a=size(dbase.EventIsSelected{fdbkindx}{1,i});b=size(dbase.EventIsSelected{fdbkindx}{end,i});

                if a(1)~=b(1);dbase.EventIsSelected{fdbkindx}{end,i}=dbase.EventIsSelected{fdbkindx}{end,i}';end
                if a(2)~=b(2);%then inequal number of onsets and offsets (file cutoff)
                    ons=dbase.EventTimes{fdbkindx}{1,i};offs=dbase.EventTimes{fdbkindx}{2,i};
                    if length(ons)>length(offs); dbase.EventIsSelected{fdbkindx}{1,i}(end)=[];dbase.EventTimes{fdbkindx}{1,i}(end)=[];end
                    if length(offs)>length(ons);dbase.EventIsSelected{fdbkindx}{2,i}(1)=[];dbase.EventTimes{fdbkindx}{2,i}(1)=[];end
                end
            end
        end

        dbase.fdbktimes = vgm_dbaseGetRaster_NotSpikes(dbase,dbase.fdbkindx);
    end

end


% [filestarttimes fileendtimes dbase.syllstarttimes dbase.syllendtimes dbase.sylldurs preintrvl postintrvl allintrvls dbase.syllnames] = dbaseGetSylls(dbase);
% dbase.filestarttimes=filestarttimes;dbase.fileendtimes=fileendtimes;
% dbase.allsyllnames=cell2mat(concatenate(dbase.syllnames));