clear
fold{1}='H:\Vikram\Rig Data\VTA\MetaAnalysis\N\';
% fold{1}='L:\Vikram\Rig Data\VTA\MetaAnalysis\movementfeedback dbases\';
% fold{1}='F:\Vikram\Rig Data\VTA\MetaAnalysis\Nmovementfeedback\';
y=1;
contents=dir(fold{y});
for i=10%6:length(contents);
    i-2
    if strcmp(contents(i).name(end),'t');
        load([fold{y} contents(i).name]);
        dbase.dbasePathName=[fold{y} contents(i).name];
        motif = dbase.motif;
        fdbkmotif = dbase.fdbkmotif;
%         dbase = rmfield(dbase, 'trigInfomotif');
%         dbase = rmfield(dbase, 'trigInfofdbkmotif');
        [dbase]=vgm_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
        
        trigInfo = dbase.trigInfomotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfomotif{1}.warped = trigInfo;
        clear trigInfo
        
        trigInfo = dbase.trigInfofdbkmotif{1}.warped;
        trigInfo=vgm_MonteCarlo_t(trigInfo);
        dbase.trigInfofdbkmotif{1}.warped = trigInfo;
        clear trigInfo
        
%         if i~=16
            trigInfo = dbase.trigInfofdbkmotif{2}.warped;
            trigInfo=vgm_MonteCarlo_t(trigInfo);
            dbase.trigInfofdbkmotif{2}.warped = trigInfo;
%         end
        
        save(dbase.dbasePathName,'dbase');
        
    end
    
end