function cj_scrollonlyx(fig, event)
    % Get the current axis limits
    currentLimits = axis;
    
    % Get the cursor position in data coordinates
    cursorPoint = get(gca, 'CurrentPoint');
    cursorX = cursorPoint(1, 1);
    
    % Calculate the width of the current x-axis range
    xWidth = currentLimits(2) - currentLimits(1);
    
    % Define the zoom factor
    zoomFactor = 0.1; % Adjust as needed
    
    % Check if scrolling up or down
    if event.VerticalScrollCount > 0
        % Zoom out by expanding the x-axis range
        newXlim = currentLimits(1) - (cursorX - currentLimits(1)) * zoomFactor;
        newYlim = currentLimits(2) + (currentLimits(2) - cursorX) * zoomFactor;
    else
        % Zoom in by shrinking the x-axis range
        newXlim = currentLimits(1) + (cursorX - currentLimits(1)) * zoomFactor;
        newYlim = currentLimits(2) - (currentLimits(2) - cursorX) * zoomFactor;
    end
    
    % Update the x-axis limits and keep y-axis limits fixed
    axis([newXlim, newYlim, currentLimits(3:4)]);
end