clear;

foldname = 'C:\Users\GLab\Box Sync\VP_dbases\sortedRCandPavel\';
% foldname = 'C:\Users\GLab\Downloads\bf neuron powerpoints\032218_allneurons\';
% foldname = 'C:\Users\GLab\Box Sync\VP_dbases\forBOS\';
% foldname = 'D:\Box Sync\VP_dbases\sortedRCandPavel\';
contents=dir(foldname);
dbases_all = []; % This holds processed dbases.
n_dbases = length(contents)-2;

%% load dbases from files
for i_dbase = 1:n_dbases
    name_dbase = contents(i_dbase+2).name;
%     disp(name_dbase);
    load([foldname name_dbase]);
    disp(dbase.title);
    dbases_all{i_dbase} = dbase;
end

%% matrix of features
close all
[dbases_all, dbases_stats] = rc_computeStats(dbases_all,n_dbases);
stats = dbases_stats.stats;

%% initialize ppt
ppt = actxserver('PowerPoint.Application');
pptdir = 'C:\Users\GLab\Box Sync\bf neuron powerpoints\';
pptname = 'AllNeuronsMotifPlots.pptx';
bBOS = 0;

try
    Presentation = ppt.Presentation.Open([pptdir pptname]);
catch
    display('Creating a new Presentation');
    Presentation = ppt.Presentation.Add;
end

rc_vBG_write_neuron_indx;

% plot into ppt
for i = 1:n_dbases
    
    i_dbase = i;%ind_dbases(i)
    dbase = dbases_all{i_dbase};
    num = str2num(dbase.title(1:3));
%     if ~sum(indx_RAand==num)
%         continue;
%     end
%     if ~isfield(dbase,'trigInfoZbin25')
%         continue;
%     end
%     if ~sum(indx_PPE==num)
%         continue;
%     end
%     if sum(indx_PPE==num)
%         continue;
%     end

%     % a title page
%     % Create a new slide
%     blankSlide = Presentation.SlideMaster.CustomLayouts.Item(6); % title
%     iSlide = Presentation.Slides.count+1;
%     Slide1 = Presentation.Slides.AddSlide(iSlide,blankSlide);
%     Slide1.Shapes.Title.TextFrame.TextRange.Text = dbase.title(1:end-4);
%        
% %     Plot feautres
%     fig = rc_make_featureplot(dbase,n_dbases,stats,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%     
%     fig = rc_make_featureplot2(dbase,n_dbases,stats,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%   
%     fig = rc_make_featureplot3(dbase,n_dbases,stats,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);    
%    
%     fig = rc_make_featureplot4(dbase,n_dbases,stats,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);    
%        
%     fig = rc_make_Syllplot(dbase,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%     
    % this is 4ms bin, smooth over 5
    fig = rc_make_Motifplot(dbase,0);
    rc_exportfigpptx(Presentation,fig,[1,1]);
    
%     % hit and escape rasters
%     if bBOS
%         fig = VP_RC_plot_BOS_motifonly10ms(dbase,0);
%     else
%         fig = VP_RC_plot_motifonly10ms(dbase,0);
%     end
%     rc_exportfigpptx(Presentation,fig,[1,1]);
% %   Z plot
%     if isfield(dbase,'trigInfoZbin25')
%         fig = rc_make_Zplot(dbase,0);
%         ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...
%             'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
% %         text(0.5, 1,[dbase.title(1:end-4) ' target-1 ' dbase.fdbksyll],...
% %             'HorizontalAlignment','center','VerticalAlignment', 'top',...
% %             'interpreter','none','FontSize',20);
%         rc_exportfigpptx(Presentation,fig,[1,1]); 
%     end
%     
%     % target 2
%     if isfield(dbase,'fdbksyll2') && length(dbase.hitsyllstarts2)>1
%         fig = VP_RC_plot_motifonly10ms_target2(dbase,0);
%         ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],...
%         'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
%         text(0.5, 1,[dbase.title(1:end-4) ' target-2 ' dbase.fdbksyll2],...
%         'HorizontalAlignment','center','VerticalAlignment', 'top',...
%         'interpreter','none','FontSize',20);
%         rc_exportfigpptx(Presentation,fig,[1,1]);   
%     end
% %     
%     % bout end raster and histogram
%     fig = rc_make_Boutendplot(dbase,0);
%     rc_exportfigpptx(Presentation,fig,[1,1]);
%     
%     % movement histogram if movement analyzed
%     if isfield(dbase,'trigInfoBoutMoveOnsetsSpikes')
%         fig = rc_make_moveplots(dbase,0);
%         rc_exportfigpptx(Presentation,fig,[1,1]);
%     end
    disp(num)
end


% save ppt and quit
Presentation.SaveAs([pptdir pptname]);

ppt.Quit;
ppt.delete;


%% clean up indx
indx_SongLocked_pval = [];
rc_vBG_write_neuron_indx;
% plot into ppt
for i = 1:n_dbases
    
    i_dbase = i;%ind_dbases(i)
    dbase = dbases_all{i_dbase};
    num = str2num(dbase.title(1:3));
    if sum(indx_allSongRelated==num)
        continue;
    end
    tfmotif = dbase.trigInfomotif.warped{1};
    if ~isfield(tfmotif,'pval')
        tfmotif=rc_dbaseMonteCarloCorr_spiketrain(tfmotif);
        dbase.trigInfomotif.warped{1} = tfmotif;
    end
    if tfmotif.pval.warped.spikecc20>0.05
        continue;
    else
        indx_SongLocked_pval = [indx_SongLocked_pval num];
    end

    disp(num)
    continue
end