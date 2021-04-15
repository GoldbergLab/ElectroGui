%% This script takes a dbase made by electro_gui gets it ready for plotting VTA manuscript figures

clear

fold{1}='D:\Box Sync\VP_dbases\analysisfor110215\';
% fold{2}='D:\Box Sync\VP_dbases\analysisfor110215\time\';
% fold{3}='D:\Box Sync\VP_dbases\analysisfor110215\others\';


for y=1%:3
    contents=dir(fold{y});
    for i=3:length(contents);
        disp(['dbase no. ' num2str(i-2)])
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name]);
                       
            %set path for where the dbase file is located and make the
            %title field
            dbase.dbasePathNameRuidong=[fold{y} contents(i).name];
            
            dbase.title=contents(i).name;
            
            %initial analyses to extract eventTimes
            dbase=vgm_dbaseGetIndices(dbase);
            
            dbase=vgm_dbaseBoutNonsongISI(dbase,dbase.indx);
            
            [filestarttimes, fileendtimes, dbase.syllstarttimes, dbase.syllendtimes,...
                dbase.sylldurs, preintrvl, postintrvl, allintrvls, dbase.syllnames]...
                = vgm_dbaseGetSylls(dbase);
            dbase.filestarttimes=filestarttimes;
            dbase.fileendtimes=fileendtimes;
            dbase.allsyllnames=cell2mat(concatenate(dbase.syllnames));
            
 
            %spike train analyses
            lag=1.2;%Lag, in seconds, of how far out you want to plot
            bplot1=0; %if you want to plot the autocorr; 0 if you don't want to
            for binsize = [0.01 0.025 0.050]
                [dbase] = vgm_dbaseSpikeTrainAutocorrelation(dbase, lag, bplot1, binsize);
            end
            
                
            save(dbase.dbasePathNameRuidong,'dbase');
        end
        
    end
end














