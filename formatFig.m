function [] = formatFig( fig, ax, fileName, varargin )
%FORMATFIG Format Figure and Save as PDF
%		function [] = formatFig( fig, {ax}, fileName, varargin )
%   Format figure according to scientific paper's standard. Output
%		fileName.pdf to the current directory.
%   axOpts = {'axisLocation', 'axisScale',...
%              'XLabel', 'YLabel',...
% 			   'XLim', 'YLim',...
%              'YLabelLeft', 'YLabelRight',...
%              'FontSize'...
%	};
%   figOpts = {'size'};

p = inputParser;
% Required
addRequired(p, 'fig', @(x) isa(x, 'matlab.ui.Figure'));
addRequired(p, 'ax', @(x) isOrContain(x, 'matlab.graphics.axis.Axes'));
addRequired(p, 'fileName', @ischar);
% Parameters
addParameter(p, 'size', 'image', @(x)...
	~isempty(regexpi(x, {'Landscape', 'Portrait', 'Image'})));
addParameter(p, 'axisLocation', 'default',...
	@(x) memberOrContain(x, {'default', 'origin'}));
addParameter(p, 'XAxisLocation', 'bottom',...
	@(x) memberOrContain(x, {'bottom', 'origin', 'top'}));
addParameter(p, 'YAxisLocation', 'left',...
	@(x) memberOrContain(x, {'left', 'origin', 'right'}));
addParameter(p, 'axisScale', 'default',...
	@(x) memberOrContain(x, {'linear', 'semilogx', 'semilogy', 'loglog', 'default'}));
addParameter(p, 'XLabel', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'YLabel', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'XLim', [],	@(x) isOrContain(x, 'double'));
addParameter(p, 'YLim', [], @(x) isOrContain(x, 'double'));
addParameter(p, 'YLabelLeft', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'YLabelRight', '', @(x) isOrContain(x, 'char'));
addParameter(p, 'tickNum', 5, @isinteger);
addParameter(p, 'fontSize', 18, @isfloat);
addParameter(p, 'fontName', 'Times New Roman', @ischar);

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
XLim = p.Results.XLim;
YLim = p.Results.YLim;
YLabelLeft = p.Results.YLabelLeft;
YLabelRight = p.Results.YLabelRight;
tickNum = p.Results.tickNum;
fontSize = p.Results.fontSize;
fontName = p.Results.fontName;

% Convert to cells
axisNum = numel(ax);
if ~isa(ax, 'cell')
	buffer = ax;
	ax = cell(axisNum, 1);
	ax{:} = deal(buffer);
end
axisProperties = {...
	'axisLocation', 'XAxisLocation', 'YAxisLocation',...
	'axisScale',...
	'XLabel', 'YLabel',...
	'YLabelLeft', 'YLabelRight'...
};
for itemIdx = 1:numel(axisProperties)
	item = axisProperties{itemIdx};
	itemValue = eval(item);
	if ~isa(itemValue, 'cell') % Single element
		evalc(['clear(''' item ''')']);
		evalc([item '(1: axisNum) = {''' itemValue '''}']);
	elseif isa(itemValue, 'cell') && numel(itemValue) == 1 % A cell containing only one element
		evalc(['clear(''' item ''')']);
		evalc([item '(1: axisNum) = ' itemValue]);
	elseif numel(itemValue) ~= axisNum
		error('%s should have the same number as axes.', item);
	end
end

% For XLim and YLim
XLim_tmp = XLim;
if ~isa(XLim, 'cell')
	clear('XLim');
	XLim(1: axisNum) = {XLim_tmp};
elseif isa(XLim, 'cell') && numel(XLim) == 1
	clear('XLim');
	XLim(1: axisNum) = XLim_tmp;
elseif numel(XLim) ~= axisNum
	error('XLim should have the same number as axes.');
end
YLim_tmp = YLim;
if ~isa(YLim, 'cell')
	clear('YLim');
	YLim(1: axisNum) = {YLim_tmp};
elseif isa(YLim, 'cell') && numel(YLim) == 1
	clear('YLim');
	YLim(1: axisNum) = YLim_tmp;
elseif numel(YLim) ~= axisNum
	error('YLim should have the same number as axes.');
end

% Prepare
set(fig,'PaperPositionMode', 'auto');

% Execution
% Axis Locations
if ~useDefault('XAxisLocation', p) || ~useDefault('YAxisLocation', p)
	cellfun(@(ax, XAxisLocation, YAxisLocation)...
		set(ax, 'XAxisLocation', XAxisLocation,	'YAxisLocation', YAxisLocation),...
		ax, XAxisLocation, YAxisLocation);
elseif ~useDefault('AxisLocation', p)
	cellfun(@(ax, axisLocation) set(ax, 'XAxisLocation', axisLocation,...
		'YAxisLocation', axisLocation), ax, axisLocation);
end

% Axis Labels
if ~useDefault('YLabelLeft', p) || ~useDefault('YLabelRight', p)
	cellfun(@(ax, YLabelLeft, YLabelRight)...
	setLnRYLabels(ax, YLabelLeft, YLabelRight), ax, YLabelLeft, YLabelRight)
elseif ~useDefault('YLabel', p)
	cellfun(@(ax, YLabel) set(ax.YLabel,'String', YLabel), ax, YLabel);
end
cellfun(@(ax, XLabel) set(ax.XLabel, 'String', XLabel), ax, XLabel);

% Axis Limits
if ~useDefault('XLim', p)
	cellfun(@(ax, XLim) set(ax, 'XLim', XLim), ax, XLim);
	Lx = XLim;
else
	Lx = cellfun(@(ax) get(ax, 'XLim'), ax,...
		'UniformOutput', 0);
end
if ~useDefault('YLim', p)
	cellfun(@(ax, YLim) set(ax, 'YLim', YLim), ax, YLim);
	Ly = YLim;
else
	Ly = cellfun(@(ax) get(ax, 'YLim'), ax,...
		'UniformOutput', 0);
end

% Axis Scale
if ~useDefault('axisScale', p)
	[xScale, yScale, xTick, yTick] = cellfun(...
		@(axisScale, Lx, Ly) genScaleTick(axisScale, Lx, Ly, tickNum),...
		axisScale, Lx, Ly, 'UniformOutput', 0 ...
	);

	% Set ticks & font size
	cellfun(@(ax, xTick, yTick, xScale, yScale) set(ax,...
		'XTick', xTick, 'YTick', yTick,...
		'XScale', xScale, 'YScale', yScale),...
		ax, xTick, yTick, xScale, yScale);
end

% Font type and size
cellfun(@(ax) set(ax, 'FontSize', fontSize, 'FontName', fontName), ax);

% Paper Size
switch size
	case 'image'
		set(fig, 'PaperUnits', 'Inches',...
			'PaperSize', [3, 2])
	case {'Landscape', 'Portrait'}
		set(fig, 'PaperOrientation', size);
end

print(fig, fileName, '-depsc');


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
            xTick = logspace(...
				floor(log10(abs(Lx(1))) * abs(Lx(1)) / Lx(1)),...
				ceil(log10(abs(Lx(2)))  * abs(Lx(2)) / Lx(2)),...
				getLogNum(Lx, tickNum)...
			);
			yTick = linspace(Ly(1), Ly(2), tickNum);
		case 'semilogy'
			xScale = 'linear';
			yScale = 'log';
			xTick = linspace(Lx(1), Lx(2), tickNum);
            yTick = logspace(...
				floor(log10(abs(Ly(1))) * abs(Ly(1)) / Ly(1)),...
				ceil(log10(abs(Ly(2))) * abs(Ly(2)) / Ly(2)),...
				getLogNum(Ly, tickNum)...
			);
		case 'loglog'
			xScale = 'log';
			yScale = 'log';
			xTick = logspace(...
				floor(log10(abs(Lx(1))) * abs(Lx(1)) / Lx(1)),...
				ceil(log10(abs(Lx(2)))  * abs(Lx(2)) / Lx(2)),...
				getLogNum(Lx, tickNum)...
			);
			yTick = logspace(...
				floor(log10(abs(Ly(1))) * abs(Ly(1)) / Ly(1)),...
				ceil(log10(abs(Ly(2))) * abs(Ly(2)) / Ly(2)),...
				getLogNum(Ly, tickNum)...
			);
		case 'linear'
			xScale = 'linear';
			yScale = 'linear';
			xTick = linspace(Lx(1), Lx(2), tickNum);
			yTick = linspace(Ly(1), Ly(2), tickNum);
	end
end

function [logNum] = getLogNum(axLim, tickNum)

	axLog = [floor(log10(axLim(1))), ceil(log10(axLim(2)))];

	if range(axLog) + 1 == tickNum
		logNum = tickNum;
	elseif range(axLog) + 1 < tickNum
		logNum = range(axLog) + 1;
	else
		div = 1: tickNum - 1;
		logNum = max(div(~rem(axLog, div))) + 1;
	end

end
