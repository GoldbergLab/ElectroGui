function [snd, lab] = egf_AddSubtractChannel(a, fs, params)
% Deal with microphonics

defaultParams.Names = {'Lower frequency','Higher frequency','Order'};
defaultParams.Values = {'400','9000','80'};

scalar=1;%
lab = 'Band-pass filtered';
if istext(a) && strcmp(a, 'params')
    snd = defaultParams;
    return
end

% Use default parameters if none are provided
if ~exist('params', 'var')
    params = defaultParams;
end
% Fill any missing params with defaults
params = electro_gui.applyDefaultPluginParams(params, defaultParams);

def = {'F:\RAxDLM\RA_1\2010-01-25','1','3','','1'};

prompt = {'Location of exper file','Add (1) or Subtract? (0)', 'Channel?', 'Filenum?', 'BandPass Filter (1)'};
dlg_title = 'Eliminate Microphonics';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,def);

if isempty(answer)
    % User cancelled
    snd = zeros(size(a));
    return;
end

%if preprogram for batch event yoyo
%load('C:\JesseInspiron\XPaper\filenum.mat','filenum');
% answer=def;
% answer{4}=num2str(filenum);

experlocation=[answer{1} '/exper.mat'];

load(experlocation);
exper.dir=[answer{1} '/'];

signal=loadData(exper,str2num(answer{4}),str2num(answer{3}));

b=str2num(answer{2});
if b
    snd=a+scalar*signal;
else
    snd=a-scalar*signal;
end
a=snd;
if str2num(answer{5})
    freq1 = str2num(params.Values{1});
    freq2 = str2num(params.Values{2});
    ord = str2num(params.Values{3});
    
    b = fir1(ord,[freq1 freq2]/(fs/2));
    snd = filtfilt(b, 1, a);
end
% filenum=filenum+1;
% save('C:\JesseInspiron\XPaper\filenum.mat','filenum');


