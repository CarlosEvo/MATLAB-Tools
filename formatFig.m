function [] = formatFig( fig, ax, fileName, varargin )
%FORMATFIG Format Figure and Save as PDF
%		function [] = formatFig( fig, {ax}, fileName, varargin )
%   Format figure according to scientific paper's standard. Output
%		fileName.pdf to the current directory.
%   axOptLs = {'axisLocation', 'axisScale',...
%              'XLabel', 'YLabel',...
%              'YLabelLeft', 'YLabelRight', 'FontSize'};
%   figOptLs = {'size'};

p = inputParser;
% Required
addRequired(p, 'fig', @(x) isa(x, 'matlab.ui.Figure'));
addRequired(p, 'ax', @(x) (isa(x, 'cell') && all(cellfun(@(y) ...
	isa(y,'matlab.graphics.axis.Axes'), x))));
addRequired(p, 'fileName', @ischar);
% Parameters
addParameter(p, 'size', 'Landscape', @(x)...
	~isempty(regexpi(x, {'Landscape', 'Portrait', 'Image'})));
addParameter(p, 'axisLocation', 'default', @(x)...
	~isempty(regexpi(x, {'default', 'origin'})));
addParameter(p, 'XAxisLocation', 'bottom', @(x)...
	~isempty(regexpi(x, {'bottom', 'origin', 'top'})));
addParameter(p, 'YAxisLocation', 'left', @(x)...
	~isempty(regexpi(x, {'left', 'origin', 'right'})));
addParameter(p, 'axisScale', 'linear', @(x)...
	~isempty(regexpi(x, {'linear', 'semilogx', 'semilogy', 'loglog'})));
addParameter(p, 'XLabel', '', @ischar);
addParameter(p, 'YLabel', '', @ischar);
addParameter(p, 'YLabelLeft', '', @ischar);
addParameter(p, 'YLabelRight', '', @ischar);
addParameter(p, 'tickNum', 6, @isinteger);
addParameter(p, 'fontSize', 20, @isfloat);

% Parse input
parse(p, fig, ax, fileName, varargin{:});
fig = p.Results.fig;
ax = p.Results.ax;
fileName = p.Results.fileName;
size = p.Results.size;
axisLocation = p.Results.axisLocation;
XAxisLocation = p.Results.XAxisLocation;
YAxisLocation = p.Results.YAxisLocation;
axisScale = p.Results.axisScale;
XLabel = p.Results.XLabel;
YLabel = p.Results.YLabel;
YLabelLeft = p.Results.YLabelLeft;
YLabelRight = p.Results.YLabelRight;
tickNum = p.Results.tickNum;
fontSize = p.Results.fontSize;

% Prepare
set(fig,'PaperPositionMode', 'auto');
Lx = cellfun(@(ax) get(ax, 'XLim'), ax,...
	'UniformOutput', 0);
Ly = cellfun(@(ax) get(ax, 'YLim'), ax,...
	'UniformOutput', 0);
xTick = cellfun(@(Lx) linspace(Lx(1), Lx(2), tickNum),...
    Lx, 'UniformOutput', false);
yTick = cellfun(@(Ly) linspace(Ly(1), Ly(2), tickNum),...
    Ly, 'UniformOutput', false);

% Execution
% Axis Locations
if ~useDefault('XAxisLocation', p) || ~useDefault('YAxisLocation', p)
	cellfun(@(ax) set(ax, 'XAxisLocation', XAxisLocation,...
		'YAxisLocation', YAxisLocation), ax);
elseif ~useDefault('AxisLocation', p)
	cellfun(@(ax) set(ax, 'XAxisLocation', axisLocation,...
		'YAxisLocation', axisLocation), ax);
end

% Axis Labels
if ~useDefault('YLabelLeft', p) || ~useDefault('YLabelRight', p)
	cellfun(@(ax) setLnRYLabels(ax, YLabelLeft, YLabelRight), ax)
elseif ~useDefault('YLabel', p);
	cellfun(@(ax) set(ax.YLabel,'String', YLabel), ax);
end
cellfun(@(ax) set(ax.XLabel,'String', XLabel), ax);

% Axis Scale
switch axisScale
	case 'semilogx'
		xScale = 'log';
		yScale = 'linear';
		xTick = cellfun(@(Lx) logspace(Lx(1), Lx(2), tickNum),...
    		Lx, 'UniformOutput', false);
		yTick = cellfun(@(Ly) linspace(Ly(1), Ly(2), tickNum),...
		    Ly, 'UniformOutput', false);
	case 'semilogy'
		xScale = 'linear';
		yScale = 'log';
		xTick = cellfun(@(Lx) linspace(Lx(1), Lx(2), tickNum),...
    		Lx, 'UniformOutput', false);
		yTick = cellfun(@(Ly) logspace(Ly(1), Ly(2), tickNum),...
		    Ly, 'UniformOutput', false);
	case 'loglog'
		xScale = 'log';
		yScale = 'log';
		xTick = cellfun(@(Lx) logspace(Lx(1), Lx(2), tickNum),...
    		Lx, 'UniformOutput', false);
		yTick = cellfun(@(Ly) logspace(Ly(1), Ly(2), tickNum),...
		    Ly, 'UniformOutput', false);
	case 'linear'
		xScale = 'linear';
		yScale = 'linear';
		xTick = cellfun(@(Lx) linspace(Lx(1), Lx(2), tickNum),...
    		Lx, 'UniformOutput', false);
		yTick = cellfun(@(Ly) linspace(Ly(1), Ly(2), tickNum),...
		    Ly, 'UniformOutput', false);
end

% Paper Size
switch size
	case 'image'
		set(fig, 'Units', 'Inches');
		pos = get(fig, 'Position');
		set(fig, 'PaperUnits', 'Inches',...
			'PaperSize', [pos(3), pos(4)])
	case {'Landscape', 'Portrait'}
		set(fig, 'PaperOrientation', size);
end

% Set ticks & font size
cellfun(@(ax, xTick, yTick) set(ax,...
    'XTick', xTick, 'YTick', yTick,...
    'XScale', xScale, 'YScale', yScale,...
    'FontSize', fontSize),...
    ax, xTick, yTick)

print(fig, fileName, '-dpdf', '-r0', '-fillpage');

end

function [] = setLnRYLabels( ax, labelLeft, labelRight )
% setLnRYLabels: set the text of the ylabel left and right
%
% [] = setLnRYLabels( ax, labelLeft, labelRight )

	subplot(ax);
	yyaxis left;
	ax.YLabel.String = labelLeft;
	yyaxis right;
	ax.YLabel.String = labelRight;

end  % setLnRYLabels

function bool = useDefault(exp, p)

bool = ~isempty(find(cellfun(@(x) strcmpi(exp, x), p.UsingDefaults), 1));

end
