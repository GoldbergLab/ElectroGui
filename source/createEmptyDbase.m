function dbase = createEmptyDbase(defaults, rootDir, savePath)

handles = defaults(struct());
handles.PathName = rootDir;

dbase = electro_gui('eg_GatherFiles', handles.PathName, handles.FileString, ...
        handles.DefaultFileLoader, handles.DefaultChannelNumber, ...
        'GUI', false);

handles = electro_gui('InitializeDbase', handles);

