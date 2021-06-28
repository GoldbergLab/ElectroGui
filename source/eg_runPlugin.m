function varargout = eg_runPlugin(pluginGroup, name, varargin)
% Look for the requested plugin by name, then run it with the
%   given arguments, and return arbitrary output arguments
% 
% pluginGroup: A struct array containing plugin info, created by the 
%   gatherPlugins/findPlugins functions. This is stored in the electro_gui 
%   handles structure as handles.plugins.(groupName) where groupName is the
%   name of a plugin type, such as:
%   - spectrums
%   - segmenters
%   - filters
%   - colormaps
%   - macros
%   - eventDetectors
%   - eventFeatures
%   - loaders
% name: The name of the plugin, without the 'eg*_' prefix, and without the
%   file extension.
% varargin: Arbitrary number of input arguments for the plugin
% varargout: Arbitrary output arguments from the plugin

foundIt = false;
for k = 1:length(pluginGroup)
    if strcmp(pluginGroup(k).name, name)
        plugin = pluginGroup(k).func;
        foundIt = true;
        break;
    end
end
if foundIt
    varargout = cell(1, nargout);
    % Run plugin and gather output arguments.
    [varargout{:}] = plugin(varargin{:});
else
    error('Attempted to run plugin ''%s'', but it could not be found.', name);
end