%% code for plotting ISI distributions and CV of ISI value
function dbase = rcm_ISIdist(dbase,bPlot)
boutISI = dbase.boutISI;
interboutISI = dbase.interboutISI;
nonsongISI = dbase.nonsongISI;
if isempty(nonsongISI)
    nonsongISI = dbase.interboutISI;
end

dbase.ISI.cvBoutISI = std(boutISI)/mean(boutISI);
dbase.ISI.cvInterboutISI = std(interboutISI)/mean(interboutISI);
dbase.ISI.cvNonsongISI = std(nonsongISI)/mean(nonsongISI);

if bPlot
    binISI = 0.005;
    edges=[min([boutISI interboutISI nonsongISI]):binISI:max([boutISI interboutISI nonsongISI])];

    boutdist=histc(boutISI,edges);boutdist=boutdist/sum(boutdist);
    interboutdist=histc(interboutISI,edges);interboutdist=interboutdist/sum(interboutdist);
    nonsongdist=histc(nonsongISI,edges);nonsongdist=nonsongdist/sum(nonsongdist);

    % figure(1);
    % plot(edges,smooth(boutdist),'b'); 
    % hold on; 
    % plot(edges,smooth(interboutdist),'r'); 
    % plot(edges, smooth(nonsongdist), 'g');
    % xlabel('Interspike interval (s)');
    % ylabel('Probability Density'); 
    % xlim([-.001,0.3]);
    % title('Distribution of Interspike intervals')
    % legend('boutISI','interboutISI','nonsongISI')

    figure;
    semilogx(edges,smooth(boutdist),'b'); 
    hold on; 
    semilogx(edges,smooth(interboutdist),'r'); 
    semilogx(edges, smooth(nonsongdist), 'g');
    xlabel('Interspike interval (s)');
    ylabel('Probability Density'); 
    title('Distribution of Interspike intervals')
    legend('boutISI','interboutISI','nonsongISI')

% figure(1)
% subplot(2,2,1)
% hist(boutISI,edges);
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','b','EdgeColor','w')
% set(gca,'xlim',[-0.015 0.3])
% legend('bout ISI','Location','northeast')
% xlabel('ISI (s)')
% ylabel('Count')
% 
% subplot(2,2,2)
% hist(interboutISI,edges);
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','r','EdgeColor','w')
% set(gca,'xlim',[-0.015 0.3])
% legend('interbout ISI','Location','northeast')
% xlabel('ISI (s)')
% ylabel('Count')
% 
% subplot(2,2,3)
% hist(nonsongISI,edges);
% h = findobj(gca,'Type','patch');
% set(h,'FaceColor','g','EdgeColor','w')
% set(gca,'xlim',[-0.015 0.3])
% legend('nonsong ISI','Location','northeast')
% xlabel('ISI (s)')
% ylabel('Count')
% 
% subplot(2,2,4)
% [counts1 bincenters1] = hist(boutISI,edges);
% [counts2 bincenters2] = hist(interboutISI,edges);
% [counts3 bincenters3] = hist(nonsongISI,edges);
% plot(bincenters1, counts1, 'b-');
% hold on;
% plot(bincenters2, counts2, 'r-');
% plot(bincenters3, counts3, 'g-');
% set(gca,'xlim',[-0.015 0.3])
% xlabel('ISI (s)')
% ylabel('Count')
% legend('bout ISI','interbout ISI','nonsong ISI')
% 
end