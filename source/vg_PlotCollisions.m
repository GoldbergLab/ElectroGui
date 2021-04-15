%Note: The indices below are of files that have a collision on the first
%stim. 
% close all
clear ColInd;
clear NoColInd;
%ColInd = [2 13; 3 10; 5 14; 5 21; 7 4; 8 4; 9 21; 9 38; 13 22; 16 10; 16 17; 18 3; 18 16; 18 31; 18 52; 19 1; 19 7; 19 30; 19 35];


% These are the files I used to make set 1
% ColInd = [2 13; 5 21; 5 14; 7 4; 8 4];
% NoColInd = [1 2; 1 3; 1 4; 1 5; 1 8; 1 9];


% for set 2
ColInd = [9 21; 9 38; 13 22; 16 10; 16 17];
NoColInd = [9 22; 13 23; 16 18; 16 4; 16 9];

preStimMs = 5;
postStimMs = 25;
x = linspace(-1*preStimMs, postStimMs, 1201);
j = 21;

% for i = 1:size(dbase.stimclips.anticlips{j},1)
%     figure(i)
%     y = dbase.stimclips.anticlips{j}(i,:);
%     plot(x,y)
%     xlim([-5 25])
%     ylim([-1 1])
% end

hf1 = figure(1);
hold on
for i = 1:length(ColInd)
%     figure(i)
    y = dbase.stimclips.anticlips{ColInd(i,1)}(ColInd(i,2),:);
    plot(x, y, '-k')
%     xlim([-5 7])
% ylim([-1 1])
    
end
hold off
xlim([-5 7])
ylim([-0.6 0.6])
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')


hf2 = figure(2);
hold on
for i = 1:length(NoColInd)
%     figure(20+i)
    y = dbase.stimclips.anticlips{NoColInd(i,1)}(NoColInd(i,2),:);
    plot(x, y, '-k')
%     xlim([-5 7])
% ylim([-1 1])
    
end
hold off
xlim([-5 7])
ylim([-0.6 0.6])
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')


s = 5;
figure(3)
hold on
for i = 1:length(NoColInd)

    yNC = dbase.stimclips.anticlips{NoColInd(i,1)}(NoColInd(i,2),:);

    plot(x, yNC, '-r')
end
for i = 1:length(ColInd)
    yC = dbase.stimclips.anticlips{ColInd(i,1)}(ColInd(i,2),:);
  
    plot(x, yC, '-k')
   
end

hold off
xlim([-5 7])
ylim([-0.6 0.6])
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')
%%
% ColInd = [19 1; 19 7; 19 30; 19 35];
% NoColInd = [19 2; 19 3; 19 4; 19 5];

% ColInd = [18 3; 18 16; 18 31; 18 52];
% NoColInd = [18 4; 18 5; 18 6; 18 7];

% ColInd = [9 21; 9 38; 13 22; 16 10; 16 17];
% NoColInd = [9 22; 13 23; 16 11; 16 18];