%script to calculate the movement threshold for a given dbase
clear
close all

dbase_dir = 'X:\Budgie\0010_0572\dbases\caleb_dbases\Sorted_newsegs'; %hard code directory 
files = dir([dbase_dir '\*dbase*.mat']);
names = {files.name};
afs = 5000;

n = 10; %every nth file

%smoothwin for move
smoothwin_move = 60;
smoothwin_move = round(smoothwin_move/1000*afs);

for i = 50:length(names)
    dbase = load([dbase_dir '\' names{i}]);
    dbase = dbase.dbase;
    path = dbase.PathName;
    chan = names{i}(strfind(names{1},'chan')+4:strfind(names{1},'chan')+5);
    chan = strrep(chan,'_','');
    birdID = names{i}(6:9); %hard coded, trusts stereotyped name format
    lc = strfind(names{i},'_');
    date = names{i}(lc(1)+1:lc(2)-1);
    
    zfiles = dir([path '\*chan18.*']);
    xfiles = dir([path '\*chan19.*']);
    yfiles = dir([path '\*chan20.*']);
    zfiles = {zfiles.name};
    zfiles = natsort(zfiles);
    xfiles = {xfiles.name};
    xfiles = natsort(xfiles);
    yfiles = {yfiles.name};
    yfiles = natsort(yfiles);
    all_mov = [];
    xmeans = [];
    ymeans = [];
    zmeans = [];
    if ~isfield(dbase,'accmeans')
        for k = 1:n:length(xfiles)
            disp(['File ' num2str(k) ' of ' num2str(length(xfiles))])
            movex = cj_txtread_datonly([path '\' xfiles{k}]);
            movey = cj_txtread_datonly([path '\' yfiles{k}]);
            movez = cj_txtread_datonly([path '\' zfiles{k}]);
            xmeans = [xmeans; mean(movex)];
            ymeans = [ymeans; mean(movey)];
            zmeans = [zmeans; mean(movez)];
        end
        xmean = mean(xmeans);
        ymean = mean(ymeans);
        zmean = mean(zmeans);
        dbase.accmeans.xmov = xmean;
        dbase.accmeans.ymov = ymean;
        dbase.accmeans.zmov = zmean;
    else
        xmean = dbase.accmeans.xmov;
        ymean = dbase.accmeans.ymov;
        zmean = dbase.accmeans.zmov;
    end
    for k = 1:n:length(xfiles)
        disp(['File ' num2str(k) ' of ' num2str(length(xfiles))])
        movex = cj_txtread_datonly([path '\' xfiles{k}]);
        movey = cj_txtread_datonly([path '\' yfiles{k}]);
        movez = cj_txtread_datonly([path '\' zfiles{k}]);
        if length(movex)~=length(movey) || length(movez) ~= length(movex)
            continue
        end
        movecom = [movex-xmean,movey-ymean,movez-zmean];
        % detrend and rectify 
        yeetus = [1:1000:(length(movecom)-1000) length(movecom)];
        movecom = detrend(movecom,'linear',yeetus);
        movecom = sqrt(sum(movecom.^2,2));
        movecom = smooth(movecom.^2,smoothwin_move);
        movecom = sqrt(movecom);         
        all_mov = [all_mov; movecom];
    end
    %threshold just like RC
    logmove = log10(all_mov);
    [~,C] = kmeans(logmove,2);
    threshold = 10^mean(C);
    %add things to dbase
    dbase.accmeans.threshold = threshold;
    dbase.accmeans.kmeansC = C;
    %make hist of movement values to show bimodal
    HIST = figure;
    histogram(logmove);
    yl = get(gca,'Ylim');
    line([mean(C) mean(C)],[0 yl(2)],'LineWidth',3,'Color','r')
    box off
    set(gca,'Color','none')
    set(gca,'FontSize',12)
    xlabel('log10(movement)')
    ylabel('Accelerometer Samples')
    title(names{i})
    dbase.accmeans.allmove = all_mov;

    %save dbase with new fancy things
    save([dbase_dir '\' names{i}],'dbase')
    
end