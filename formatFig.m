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
addRequired(p, 'ax', @(x) isOrContain(x, 'matlab.graphics.axis.Axes'));
addRequired(p, 'fileName', @ischar);
% Parameters
addParameter(p, 'size', 'Landscape', @(x)...
	~isempty(regexpi(x, {'Landscape', 'Portrait', 'Image'})));
addParameter(p, 'axisLocation', 'default',...
	@(x) memberOrContain(x, {'default', 'origin'}));
addParameter(p, 'XAxisLocation', 'bottom',...
	@(x) memberOrContain(x, {'bottom', 'origin', 'top'}));
addParameter(p, 'YAxisLocation', 'left',...
	@(x) memberOrContain(x, {'left', 'origin', 'right'}));
addParameter(p, 'axisScale', 'linear',...
	@(x) memberOrContain(x, {'linear', 'semilogx', 'semilogy', 'loglog'}));
addParameter(p, 'XLabel', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'YLabel', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'YLabelLeft', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'YLabelRight', '', @(x) isOrContain(x, 'char'));
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

% Convert to cells
axisNum = numel(ax);
if ~isa(ax, 'cell')
	buffer = ax;
	ax = cell(axisNum, 1);
	ax{:} = deal(buffer);
end
axisProperties = {'axisLocation', 'XAxisLocation', 'YAxisLocation',...
	'axisScale', 'XLabel', 'YLabel', 'YLabelLeft', 'YLabelRight'};
for itemIdx = 1:numel(axisProperties)
	item = axisProperties{itemIdx};
	itemValue = eval(item);
	if ~isa(itemValue, 'cell') % Single element
		eval(['clear(''' item ''')']);
		eval([item '(1 :axisNum) = {''' itemValue '''}']);
	elseif isa(itemValue, 'cell') && numel(itemValue) == 1 % A cell containing only one element
		eval(['clear(''' item ''')']);
		eval([item '(1 :axisNum) = ' itemValue]);
	elseif numel(itemValue) ~= axisNum
		error('%s should have the same number as axes.', item);
	end
end

% Prepare
set(fig,'PaperPositionMode', 'auto');
Lx = cellfun(@(ax) get(ax, 'XLim'), ax,...
	'UniformOutput', 0);
Ly = cellfun(@(ax) get(ax, 'YLim'), ax,...
	'UniformOutput', 0);

% Execution
% Axis Locations
if ~useDefault('XAxisLocation', p) || ~useDefault('YAxisLocation', p)
	cellfun(@(ax, XAxisLocation, YAxisLocation)...
		set(ax, 'XAxisLocation', XAxisLocation,	'YAxisLocation', YAxisLocation),...
		ax, XAxisLocation, YAxisLocation);
elseif ~useDefault('AxisLocation', p)
	cellfun(@(ax, axisLocation) set(ax, 'XAxisLocation', axisLocation,...
		'YAxisLocation', axisLocation), ax, axisLocation, axisLocation);
end

% Axis Labels
if ~useDefault('YLabelLeft', p) || ~useDefault('YLabelRight', p)
	cellfun(@(ax, YLabelLeft, YLabelRight)...
	setLnRYLabels(ax, YLabelLeft, YLabelRight), ax, YLabelLeft, YLabelRight)
elseif ~useDefault('YLabel', p)
	cellfun(@(ax, YLabel) set(ax.YLabel,'String', YLabel), ax, YLabel);
end
cellfun(@(ax, XLabel) set(ax.XLabel, 'String', XLabel), ax, XLabel);

% Axis Scale
[xScale, yScale, xTick, yTick] =...
	cellfun(@(axisScale, Lx, Ly) genScaleTick (axisScale, Lx, Ly, tickNum),...
	axisScale, Lx, Ly, 'UniformOutput', 0);

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
cellfun(@(ax, xTick, yTick, xScale, yScale) set(ax,...
    'XTick', xTick, 'YTick', yTick,...
    'XScale', xScale, 'YScale', yScale,...
    'FontSize', fontSize),...
    ax, xTick, yTick, xScale, yScale)

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

bool = ~isempty(find(arrayfun(@(x) strcmpi(exp, x), p.UsingDefaults), 1));

end

function bool = isOrContain(obj, class)
	if isa(obj, 'cell')
		bool = all(cellfun(@(x) isa(x, class), obj));
	else
		bool = isa(obj, class);
	end
end

function bool = memberOrContain( obj, group )
	if isa(obj, 'cell')
		bool = all(cellfun(@(x) ~isempty(regexpi(x, group)), obj));
	else
		bool = ~isempty(regexpi(obj, group));
	end
end

function [xScale, yScale, xTick, yTick] = genScaleTick (axisScale, Lx, Ly, tickNum)
	switch axisScale
		case 'semilogx'
			xScale = 'log';
			yScale = 'linear';
			xTick = logspace(log10(Lx(1)), log10(Lx(2)), tickNum);
			yTick = linspace(Ly(1), Ly(2), tickNum);
		case 'semilogy'
			xScale = 'linear';
			yScale = 'log';
			xTick = linspace(Lx(1), Lx(2), tickNum);
			yTick = logspace(log10(Ly(1)), log10(Ly(2)), tickNum);
		case 'loglog'
			xScale = 'log';
			yScale = 'log';
			xTick = logspace(log10(Lx(1)), log10(Lx(2)), tickNum);
			yTick = logspace(log10(Ly(1)), log10(Ly(2)), tickNum);
		case 'linear'
			xScale = 'linear';
			yScale = 'linear';
			xTick = linspace(Lx(1), Lx(2), tickNum);
			yTick = linspace(Ly(1), Ly(2), tickNum);
	end
end