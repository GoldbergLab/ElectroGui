function [dbase]=V_VTABatchAnalysis();
%%
%fold is the name of the folder with all the dbases from a cell type

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
fold{4}='C:\Users\jesseg\Desktop\MetaAnalysis\nostimresponse\';
%%
bplot=0;btriginfo=0;
for y=1:3;
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            dbase.dbasePathName=[fold{y} contents(i).name];
            dbase.title=contents(i).name;
            dbase=vg_dbaseGetIndices(dbase);%This function defines indixes and gets EventTimes
            dbase=vg_dbaseGetUnusables(dbase);
            %get ISI distribtions:
            [dbase]=vg_dbaseBoutNonsongISI(dbase,dbase.indx);%Get interspike interval (ISI)
            [dbase]=vg_dbaseMakeTrigInfoAllsylls(dbase,0);

            %Movement related analysis: Syll Onsets/Offsets without
            %movement contamination, and movement Onsets/Offsets with
            %and without syll contamination
            if btriginfo;%~isfield(dbase,'trigInfo');
                if isfield(dbase,'moveindx');
                    [dbase]=vg_dbaseBoutNonsongIMI(dbase,dbase.moveindx);%Get intermove interval (IMI) = move onsets are analyzed
                    dbase=dbaseMakeTrigInfoSubsongOnsetsNoMoveSmooth(dbase);
                    dbase=dbaseMakeTrigInfoSubsongOffsetsNoMoveSmooth(dbase);
                    dbase=dbaseMakeTrigInfoMoveOnSpikes(dbase);
                    dbase=dbaseMakeTrigInfoMoveOffSpikes(dbase);
                    dbase=dbaseMakeTrigInfoMoveOnSpikesNoSylls(dbase);
                    dbase=dbaseMakeTrigInfoMoveOffSpikesNoSylls(dbase);
                    dbase=dbaseMakeTrigInfoSyllOnMoveOns(dbase);
                    dbase=dbaseMakeTrigInfoSyllOffMoveOns(dbase);
                end


                %4. Get syllable and song aligned histogram data (I call these structures 'trigInfo'
                %Bout onset and offset aligned histograms:

                [dbase trigInfo]=dbaseMakeTrigInfoBoutOffsets(dbase);
                [dbase trigInfo]=dbaseMakeTrigInfoBoutOnsets(dbase);

                %Syllable onset and offset aligned histograms
                [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBout(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBout(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBoutSmooth(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBoutSmooth(dbase);

                %Named syllable onset histograms
                bplot=0;
                [dbase]=vg_dbaseMakeTrigInfoAllsylls(dbase,bplot);


                %
                %5. (Optional) Spike width analysis
                %[dbase.spikewidth dbase.thespike dbase.bestfile] = dbasespikewidth(dbase);%self explanatory if you go to the code

                %6. Motif-locked trigInfos
                %you will need updated function named:  dbaseGetNamedMotifs
                motif{1}='def';motif{2}='dEf';motif{3}='cdef';motif{4}='cdEf';
                dbase.motif=motif;bplot=0;
                [dbase]=V_dbaseMakeTrigInfomotif(dbase,motif,bplot);

                %7. Syllable locked trigInfos
                [dbase]=V_dbaseMakeTrigInfoAllsylls(dbase,bplot);
            end
            %%
            %8. (Optional) Spike train autocorrelation
            %an autocorrelation is basically a spike triggered spike histogram
            %it's a useful spike train analysis for examining burstiness of a neuron's firing
            %TANs do not burst and have very flat spike train autocorrs
            lag=0.2;%Lag, in seconds, of how far out you want to plot
            bplot=0; %if you want to plot the autocorr; 0 if you don't want to
            [dbase]=xsdbaseSpikeTrainAutocorrelationFee2(dbase,lag, bplot);
            [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
            %%
            %How to save
            %dbase.dbasePathName=['C:\foldername\foldername\' dbase.title];
            save(dbase.dbasePathName, 'dbase');
        end

    end
end
%%
%If you want to see any of the bout onset or syllable onset aligned
%histograms, use function TrigInfoPlot
if bplot
    if dbase.isTrigInfoNoBout.Onsets && dbase.isTrigInfoNoBout.Offsets
        z=size(dbase.trigInfoNoBout.Onsets3.currTrigOffset);
        numsylls=z(2);
        trigInfoPlot(dbase.trigInfoNoBout.Onsets3,0);%the 0 is if you don't want to see the raster (faster).
        xlabel('Onsets (s)')
        title(['#sylls=' num2str(numsylls) 'Peak p=' num2str(dbase.trigInfoNoBout.Onsets3.pval.maxrate) ' - Min p=' num2str(dbase.trigInfoNoBout.Onsets3.pval.minrate)]);

        trigInfoPlot(dbase.trigInfoNoBout.Offsets3,0)
        xlabel('Offsets (s)')
        xlabel('Offsets (s)')
        title(['#sylls=' num2str(numsylls) 'Peak p=' num2str(dbase.trigInfoNoBout.Offsets3.pval.maxrate) ' - Min p=' num2str(dbase.trigInfoNoBout.Offsets3.pval.minrate)]);
    end
end