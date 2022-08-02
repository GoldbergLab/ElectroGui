function helpText = eg_HelpText(handles)

helpText = sprintf('%s\n', ...
    'electro_gui:', ...
    '',...
    'A graphical tool for analyzing audio and neural data.',...
    'Created a long time ago, possibly by Aaron Andalman. Modified by',...
    'Brian Kardon, and probably others before him.',...
    '',...
    'Keyboard actions:', ...
    '    General:', ...
    '        . (period) - switch to previous file', ...
    '        , (comma) - switch to next file', ...
    '        ctrl-e - create export figure', ...
    '    Segment/Marker related:', ...
    '        a-z, A-Z, 0-9 - label the active segment or marker', ...
    '        ` (backtick or tilde key) - convert active segment to marker',...
    '            or vice versa.', ...
    '        backspace - clear the label for the active segment or marker', ...
    '        right/left arrow - make previous or next segment or marker',...
    '            active', ...
    '        up/down arrow - switch active element from marker to segment',...
    '            or back', ...
    '        space - if segment is active, join it with the next one (no',...
    '            effect on markers)', ...
    '        enter - toggle whether the segment is selected or not', ...
    '        delete - delete currently active segment or marker', ...
    'Mouse actions:', ...
    '    General:', ...
    '        Click on spectrogram: Set left side of zoom window at click',...
    '            time', ...
    '        Shift-click on spectrogram: Set right side of zoom window at',...
    '            click time', ...
    '        Click-drag on spectrogram: Zoom in', ...
    '        Double-click on spectrogram: Zoom all the way out', ...
    '    Segment/Marker related:', ...
    '        Control-click-drag on spectrogram: Create marker', ...
    '        Shift-click on sound amplitude: Set segment threshold',...
    '            (destroys all existing segments): ', ...
    '');