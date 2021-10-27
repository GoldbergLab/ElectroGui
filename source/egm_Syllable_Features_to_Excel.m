function handles = egm_Syllable_Features_to_Excel(handles)

if ~isfield(handles,'ExcelFile')
    handles.ExcelFile = actxserver('Excel.Application');
    set(handles.ExcelFile,'Visible',1);
    invoke(handles.ExcelFile.Workbooks,'Add');
end
if isempty(handles.ExcelFile.Activesheet)
    handles.ExcelFile = actxserver('Excel.Application');
    set(handles.ExcelFile,'Visible',1);
    invoke(handles.ExcelFile.Workbooks,'Add');
end

op = handles.ExcelFile;
sheet = op.Activesheet;

row = 0;
str = 'dummy';
while ~isempty(str)
    row = row+1;
    rng = get(sheet,'Range',['A' num2str(row)]);
    str = get(rng,'Text');
end

chan = cell(1,2);
lab = cell(1,2);
for axnum = 1:length(handles.axes_Channel)
    if strcmp(get(handles.axes_Channel(axnum),'visible'),'on')
        v = get(handles.popup_Functions(axnum),'value');
        str = get(handles.popup_Functions(axnum),'string');
        str = str{v};
        if isempty(findstr(str,' - '))
            chan{axnum}{1} = handles.(['chan' num2str(axnum)]);
            lab{axnum}{1} = str;
        else
            chan{axnum} = handles.BackupChan{axnum};
            lab{axnum} = handles.BackupLabel{axnum};
        end
    end
end

if row == 1
    set(get(sheet,'Range','A1'),'Value','File #');
    set(get(sheet,'Range','B1'),'Value','Syllable #');
    set(get(sheet,'Range','C1'),'Value','Start (s)');
    set(get(sheet,'Range','D1'),'Value','End (s)');
    set(get(sheet,'Range','E1'),'Value','Label');
    
    col = 5;
    for axnum = 1:length(handles.axes_Channel)
        for j = 1:length(lab{axnum})
                col = col + 1;
                vl = dec2base(col-1,26);
                str = [];
                for c = 1:length(vl);
                    str = [str char(base2dec(vl(c),26)+64+(c==length(vl)))];
                end
                set(get(sheet,'Range',[str '1']),'Value',lab{axnum}{j});            
        end
    end
    row = row+1;
end

filenum = str2num(get(handles.edit_FileNumber,'string'));
f = find(handles.SegmentSelection{filenum}==1);
for c = 1:length(f)
    set(get(sheet,'Range',['A' num2str(row)]),'Value',filenum);
    set(get(sheet,'Range',['B' num2str(row)]),'Value',c);
    set(get(sheet,'Range',['C' num2str(row)]),'Value',handles.SegmentTimes{filenum}(f(c),1)/handles.fs);
    set(get(sheet,'Range',['D' num2str(row)]),'Value',handles.SegmentTimes{filenum}(f(c),2)/handles.fs);
    set(get(sheet,'Range',['E' num2str(row)]),'Value',handles.SegmentTitles{filenum}{f(c)});
        
    col = 5;
    for axnum = 1:2
        for j = 1:length(lab{axnum})
            col = col + 1;
            vl = dec2base(col-1,26);
            str = [];
            for d = 1:length(vl);
                str = [str char(base2dec(vl(d),26)+64+(d==length(vl)))];
            end
            t1 = max([1 round(handles.SegmentTimes{filenum}(f(c),1)*length(chan{axnum}{j})/length(handles.sound))]);
            t2 = min([length(chan{axnum}{j}) round(handles.SegmentTimes{filenum}(f(c),2)*length(chan{axnum}{j})/length(handles.sound))]);
            set(get(sheet,'Range',[str num2str(row)]),'Value',mean(chan{axnum}{j}(t1:t2)));
        end
    end
    
    row = row+1;
end
