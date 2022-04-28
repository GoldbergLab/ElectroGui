function value = getKeyValuePair(key, keys, values, defaultValue)
% Emulate dictionary key-value pair mapping behavior
%   key = a char array key to retrieve
%   keys = a cell array of keys, where each key is a char array
%   values = a list of values, in corresponding order to the keys list
%   defaultValue = an optional default value to return if the key is not
%       found in the keys list. If defaultValue is not supplied, an error
%       will be raised when an unknown key is provided.

value = values(strcmp(key, keys));
if isempty(value)
    if ~exist('defaultValue', 'var')
        error('No key found to match "%s".', key);
    else
        value = defaultValue;
    end
elseif length(value) > 1
    error('More than one key matched "%s".', key);
else
    value = value{1};
end