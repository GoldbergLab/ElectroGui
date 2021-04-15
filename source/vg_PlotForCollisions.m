clear StimClipNoCol
clear StimClipCol
close all



ColInd = [1 2; 2 2; 2 10; 2 19; 3 13; 4 1; 4 3; 5 3; 5 4; 5 6; 5 15; 8 7; 8 13; 9 16; 10 6; 11 17; 12 12];
BadInd = [1 5; 2 5; 2 13; 3 15; 5 14; 5 16; 6 3; 6 9; 7 2; 7 8; 7 10; 8 11; 9 7; 10 16; 11 6; 11 7; 11 12; 12 11; 13 4];





countC = 0;
countNC = 0;
for i = 1:size(dbase.stimclips.anticlips,2)
    for j = 1:size(dbase.stimclips.anticlips{i},1)
        
        if any(ColInd(:,1) == i & ColInd(:,2) == j)
            countC = countC+1;
            StimClipCol(countC,:) = dbase.stimclips.anticlips{i}(j,:);
        elseif ~any(BadInd(:,1) == i & BadInd(:,2) == j)
            countNC = countNC+1;
            StimClipNoCol(countNC,:) = dbase.stimclips.anticlips{i}(j,:);
        end
        
        
        
        
        
        
        
        
    end
end

preStimMs = 5;
postStimMs = 25;
figure(1)

x = linspace(-1*preStimMs, postStimMs, 1201);
if size(StimClipCol,1) > 1
yC = mean(StimClipCol);
else 
    yC = StimClipCol;
end
plot(x,yC, 'r')
hold on
yNC = mean(StimClipNoCol);
plot(x,yNC, 'b')
xlim([-5 10])
ylim([-1 1])
xlabel('Time relative to stim onset (ms)')
ylabel('Amplitude(V)')
legend('Collisions', 'No Collisions')

% preStimMs = 5;
% postStimMs = 25;
% figure(j)
%
% x = linspace(-1*preStimMs, postStimMs, 1201);
% y = dbase.stimclips.anticlips{n}(j,:);
% plot(x,y)
% title(num2str(j))
% xlim([-5 10])
% ylim([-1 1])

%%
%Note: The indices below are of files that have a collision on the first
%stim. 

%ColInd = [2 13; 3 10; 5 14; 5 21; 7 4; 8 4; 9 21; 9 38; 13 22; 16 10; 16 17; 18 3; 18 16; 18 31; 18 52; 19 1; 19 7; 19 30; 19 35];


% These are the files I used to make the plot
% ColInd = [2 13; 5 21; 5 14; 7 4; 8 4];
% NoColInd = [1 1; 1 2; 1 3; 1 4; 1 5];

ColInd = [2 1; 2 4; 2 6; 2 7; 2 8; 2 9; 3 1; 3 2; 3 4; 3 10];
NoColInd = [1 12; 1 13; 1 14; 1 19; 1 21; 1 22; 1 23; 1 24; 1 25; 1 26];

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
ylim([-1 1])
set(gca, 'XTick', [])
set(gca, 'XTickLabel', [])
set(gca, 'YTick', [])
set(gca, 'YTickLabel', [])
set(gca, 'Visible', 'off')


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
ylim([-1 1])
set(gca, 'XTick', [])
set(gca, 'XTickLabel', [])
set(gca, 'YTick', [])
set(gca, 'YTickLabel', [])
set(gca, 'Visible', 'off')



%%


preStimMs = 5;
postStimMs = 25;
x = linspace(-1*preStimMs, postStimMs, 1201);

% hf1 = figure(1);
% hold on
for i = 1:27
    figure(i)
    y = dbase.stimclips.anticlips{2}(i,:);
    plot(x, y, '-k')
    xlim([-5 7])
ylim([-1 1])
    
end
% hold off
xlim([-5 7])
ylim([-1 1])
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')

%%
% ColInd = [2 1; 2 4; 2 6; 2 7; 2 8; 2 9; 3 1; 3 2; 3 4; 3 10];
ColInd = [2 6; 2 7; 2 8; 3 2; 3 5; 3 8; 3 10];
NoColInd = [1 4; 1 5; 1 12; 1 13; 1 19; 1 21; 1 22]%; 1 23; 1 24; 1 25];

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
    plot(x, y, '-r')
%     xlim([-5 7])
% ylim([-1 1])
    
end
% hold off
% xlim([-5 7])
% ylim([-1 1])
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')


% hf2 = figure(2);
% hold on
for i = 1:length(NoColInd)
%     figure(20+i)
    y = dbase.stimclips.anticlips{NoColInd(i,1)}(NoColInd(i,2),:);
    plot(x, y, '-k')
%     xlim([-5 7])
% ylim([-1 1])
    
end
hold off
xlim([-5 5])
ylim([-1 1])
xlabel('Time (ms)')
ylabel('Amplitude (V)')
% legend('Collisions', 'No Collisions')
% set(gca, 'XTick', [])
% set(gca, 'XTickLabel', [])
% set(gca, 'YTick', [])
% set(gca, 'YTickLabel', [])
% set(gca, 'Visible', 'off')













