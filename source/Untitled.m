format compact
name = input('What''s your name: ', 's');
if ~isempty(name)
    fprintf('Hello %s\n', name)
end
