function dbase = egm_ZZ_countSorted(handles)
% print how many bProd and bAud are sorted
dbase = handles.dbase;
idx_sort = find(strcmp(dbase.PropertyNames, 'bSorted'));
idx_prod = find(strcmp(dbase.PropertyNames, 'bProd'));
idx_aud = find(strcmp(dbase.PropertyNames, 'bAud'));
idx_call = find(strcmp(dbase.PropertyNames, 'bCall'));
idx_playback = find(strcmp(dbase.PropertyNames, 'bBack'));
a = dbase.Properties;
sort_prod = a(:,idx_sort) .* a(:,idx_prod);
fprintf('Sorted production: %d\n', sum(sort_prod));
sort_aud = a(:,idx_sort) .* a(:,idx_aud);
fprintf('Sorted auditory: %d\n', sum(sort_aud));
sort_call = a(:,idx_sort) .* a(:,idx_call);
fprintf('Sorted call: %d\n', sum(sort_call));
sort_playback = a(:,idx_sort) .* a(:,idx_playback);
fprintf('Sorted playback: %d\n', sum(sort_playback));
end


