function [keys, values] = setKeyValuePair(key, value, keys, values)
% Emulate dictionary key-value pair mapping behavior - set a new value for
%   the given key.
%   key = a char array key to set a value for
%   value = a new value to associate with the given key
%   keys = a cell array of keys, where each key is a char array
%   values = a list of values, in corresponding order to the keys list

if length(keys) ~= length(values)
    error('Cell arrays "keys" and "values" must be the same length.');
end

keys{end+1} = key;
values{end+1} = value;