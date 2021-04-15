function [dbase]=V_VTABatchAnalysis2();


fold{1}='G:\Vikram\Rig Data\VTA\MetaAnalysis\N';

%%

%initial analyses to extract eventTimes
dbase=vg_dbaseGetIndices(dbase);
dbase=dbaseGetMoveRaster(dbase, dbase.moveindx);
dbase=vg_dbaseBoutNonsongISI(dbase,dbase.indx);
dbase=vg_dbaseBoutNonsongIMI(dbase,dbase.moveindx);

if bplot
    vg_plotisidist(dbase,s);
    vg_plotimidist(dbase,s);
end

%spike train autocorrs
lag=1.5;
[dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
if bplot
    figure;plot(dbase.ifrautocorr.bout.lags/4000,dbase.ifrautocorr.bout.ifr);
    hold on;plot(dbase.ifrautocorr.nonsong.lags/4000,dbase.ifrautocorr.nonsong.ifr,'r');
end
[dbase]=vg_dbaseSpikeTrainAutocorrelation(dbase,lag, bplot);

[dbase]=vg_dbaseMakeTrigInfoAllsylls(dbase,0);

%Motif aligned hists
motif{1}='abcde';motif{2}='abcdef';motif{3}='abcdey';
fdbkmotif{1}='abcDe';fdbkmotif{2}='abcDef';fdbkmotif{3}='abcDey';
[dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);




%%
%fold is the name of the folder with all the dbases from a cell type
%fold is the name of the folder with all the dbases from a cell type
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
tic
bplot=0;btriginfo=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])

            if ~isfield(dbase,'trigInfoNoBout');

                % [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBout(dbase);
                % [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBout(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOffsetsNoBoutSmooth(dbase);
                [dbase]=dbaseMakeTrigInfoSubsongOnsetsNoBoutSmooth(dbase);

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
                save(dbase.dbasePathNameJesse, 'dbase');
                dbase.title
            end
        end
    end
end
toc
%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
tic
bplot=0;btriginfo=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])


            if isfield(dbase,'moveindx');
                if isfield(dbase.trigInfoNoMove.Onsets3,'edges');
                    figure;plot(dbase.trigInfoNoBout.Onsets3.edges,dbase.trigInfoNoBout.Onsets3.rd)

                    hold on;plot(dbase.trigInfoNoMove.Onsets3.edges,dbase.trigInfoNoMove.Onsets3.rd,'r');
                    xlim([-.3,.3]);title(dbase.title);
                end


            end
        end
    end
end
toc

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if strfind(dbase.allsylls, 'abcdef')>=6
                %
                %                 [dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
                %                 save(dbase.dbasePathNameJesse, 'dbase');


                trigInfo1=dbase.trigInfomotif{3}.warped;
                trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
                if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);

                    figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));

                    hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                    xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                    title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf']);
                    count=count+1
                end

            end
        end
    end
end

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if strfind(dbase.allsylls, 'abcdef')>=6
                %
                %                 [dbase]=vg_dbaseMakeTrigInfomotif(dbase,motif,fdbkmotif);
                %                 save(dbase.dbasePathNameJesse, 'dbase');


                trigInfo1=dbase.trigInfomotif{3}.warped;
                trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
                if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);

                    figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));

                    hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                    xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                    title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf' ' y=' num2str(y) ' i=' num2str(i)]);
                    count=count+1
                end

            end
        end
    end
end

%%

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
motif{1}='abcdef';motif{2}='bcdef';motif{3}='cdef';motif{4}='def';
fdbkmotif{1}='abcdEf';fdbkmotif{2}='bcdEf';fdbkmotif{3}='cdEf';fdbkmotif{4}='dEf';
bplot=0;btriginfo=0;count=0;

allcellmovedurs=[];
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            if isfield(dbase,'moveindx');
                dbase=vg_dbaseGetallmoves(dbase);
                save(dbase.dbasePathNameJesse, 'dbase');
                allcellmovedurs=[allcellmovedurs dbase.allmovedurs];
            end

        end
    end
end

%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';

bplot=0;

allcellmovedurs=[];
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])

            if isfield(dbase,'moveindx');
                figure;
                trigger=concatenate(dbase.syllstarttimes);
                events=concatenate(dbase.moveonsets);
                exclude=[concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,1);hold on; plot(t.edges,t.rd);title(['moveons vs ' num2str(length(t.events)) ' syllons']);

                trigger=concatenate(dbase.moveoffsets);
                events=concatenate(dbase.spiketimes);
                exclude=[concatenate(dbase.syllstarttimes) concatenate(dbase.syllendtimes) concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,2);hold on; plot(t.edges,t.rd);title(['spikes vs' num2str(length(t.events)) ' moveons']);
                xlabel([dbase.title]);

                trigger=concatenate(dbase.syllendtimes);
                events=concatenate(dbase.spiketimes);
                exclude=[concatenate(dbase.moveonsets) concatenate(dbase.moveoffsets) concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                subplot(1,3,3);hold on; plot(t.edges,t.rd);title(['spikes vs ' num2str(length(t.events)) ' syllons']);


            end
        end
    end
end

%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';


for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])






            if isfield(dbase,'motif') && isfield(dbase,'fdbkmotif');
                for m=1:length(dbase.motif);
                    motif=dbase.motif{m};

                    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif);
                    dbase.motifstarts{m}=motifstarts;
                    dbase.motifends{m}=motifends;
                    dbase.motifdurs{m}=motifdurs;


                end

                for m=1:length(dbase.fdbkmotif);
                    motif=dbase.fdbkmotif{m};

                    [motifstarts motifends motifdurs] = dbaseGetNamedMotifs(dbase, motif);
                    dbase.fdbkmotifstarts{m}=motifstarts;
                    dbase.fdbkmotifends{m}=motifends;
                    dbase.fdbkmotifdurs{m}=motifdurs;

                end
                save(dbase.dbasePathNameJesse, 'dbase');
            end
        end
    end
end
%%
fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';

bplot=0;
for y=[1:3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])



            trigger=concatenate(dbase.syllstarttimes);
            events=concatenate(dbase.spiketimes);
            exclude=[];
            exclude=sort(exclude);
            t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
            figure;hold on; plot(t.edges,t.rd);title([dbase.title 'numsylls=' num2str(length(t.events))]);



            if isfield(dbase,'motif') && isfield(dbase,'fdbkmotif');
                figure;
                trigger=concatenate(dbase.motifstarts{2});
                events=concatenate(dbase.spiketimes);
                exclude=[];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                hold on; plot(t.edges,t.rd);
                num=length(t.events);


                trigger=concatenate(dbase.fdbkmotifstarts{2});
                events=concatenate(dbase.spiketimes);
                exclude=[];
                exclude=sort(exclude);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, bplot);
                hold on; plot(t.edges,t.rd,'r');
                title([dbase.title 'ctrl=' num2str(num) 'fdbk=' num2str(length(t.events))]);
            end
        end
    end
end

%%

%explore ifr autocorr

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
lag=1;

for y=[3];
    contents=dir(fold{y});
    for i=3:length(contents);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            %             [dbase.ifrautocorr]=xdbaseIFRautocorrelation3(dbase,lag);
            figure;plot(dbase.ifrautocorr.bout.lags/4000,dbase.ifrautocorr.bout.ifr);
            hold on;plot(dbase.ifrautocorr.nonsong.lags/4000,dbase.ifrautocorr.nonsong.ifr,'r');
            title([dbase.title ' y=' num2str(y) ' i=' num2str(i)]);
            vg_plotisidist(dbase,s);

            %             save(dbase.dbasePathNameJesse, 'dbase');
        end
    end
end

%%
%keeps below are dbases that had peaks in the ifrautocorr during singing
%but not during nonsong (y,i);
keep=     [2    23
    2     9
    1    24
    1    23
    1    14
    1    11
    1     5
    1     4];

iis=keep(:,2);

fold{1}='E:\VTA\MetaAnalysis\odromic-dbases\';
fold{2}='E:\VTA\MetaAnalysis\odromic+dbases\';
fold{3}='E:\VTA\MetaAnalysis\adromic dbases\';
lag=1;

for y=[1 2];
    contents=dir(fold{y});
    for newi=1:length(unique(keep(:,2)));
        i=iis(newi);
        if strcmp(contents(i).name(end),'t');
            load([fold{y} contents(i).name])
            trigger=concatenate(dbase.syllstarttimes);
            events=concatenate(dbase.spiketimes);
            exclude=[concatenate(dbase.boutstarts) concatenate(dbase.boutends)];
            exclude=sort(exclude);
            t=vg_MakeTrigInfoFlex(trigger, events, exclude, dbase, 0);
            figure; plot(t.edges,t.rd);title(['spikes vs ' num2str(length(t.events)) ' syllons']);
            trigInfo1=dbase.trigInfomotif{3}.warped;
            trigInfo2=dbase.trigInfofdbkmotif{3}.warped;
            if ~isempty(trigInfo1.rd) && ~isempty(trigInfo2.rd);
                figure;plot(trigInfo1.edges,smooth(trigInfo1.rd,5));
                hold on; plot(trigInfo2.edges,smooth(trigInfo2.rd,5),'r');
                xlim([trigInfo2.edges(1) trigInfo2.edges(end)]);
                title([dbase.title '-' num2str(length(trigInfo1.motifdurs)) 'x cdef' '-vs-' num2str(length(trigInfo2.motifdurs)) 'x cdEf' '-y=' num2str(y) '-i=' num2str(i)]);
            end
        end
    end
end