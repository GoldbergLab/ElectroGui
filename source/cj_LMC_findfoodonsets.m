function [dbase] = cj_LMC_findfoodonsets(dbase)
%Find onset times (in seconds) for servo opening. Adds new field to dbase
%that is a 1xn cell array where n is number of files
    path = dbase.PathName;
    %navigate to and load in all chan6 files
    %CHECK IF FILE NUMBER IS MAINTAINED WHEN filenames ARE CREATED - it seems
    %to be the case that it is maintained but I am unfamiliar with the
    %structure of the filename
    cd(path)
    files = dir('*chan6.dat');
    filenames = {files.name};
    foodOnsets = zeros(1,length(filenames));
    for i = 1:length(filenames)
         if mod(i,50) == 0
            disp(['On file ' num2str(i) ' of ' num2str(length(filenames))])
         end
        [data,~,~,~,~] = egl_FP_vg(filenames{i},1);                    
        pulseonsets = find(diff(data)==1);
        pulseoffsets = find(diff(data)==-1);
        if length(pulseonsets)<length(pulseoffsets)%file starts during a pulse
            pulseonsets = [1; pulseonsets]; %#ok<AGROW> 
        else 
            if length(pulseonsets)>length(pulseoffsets)%file ends during a pulse
                pulseoffsets = [pulseoffsets; length(data)];%#ok<AGROW> 
            end               
        end
        durs = pulseoffsets-pulseonsets;
        if max(durs)>90 %idk seems like a reasonable choice (short durs are 20, long are 100)
            foodOnsets(i) = pulseonsets(find(durs>90,1));
        else
            foodOnsets(i) = nan;
        end
        clear data
    end
    dbase.foodOnsets = num2cell(foodOnsets);
    %save()
end