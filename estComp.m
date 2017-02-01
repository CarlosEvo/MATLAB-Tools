function [output] = estComp(func, varargin)
%ESTCOMP Computation on estm class
%   [output] = estComp(func, estm1, ..., estmN) performs
%   calculations with standard error. func is the function handle of the
%   calculation. estm1, ..., estmN are the estm class values.
%   Output is estm class.

	assert(isa(func, 'function_handle'), 'Expecting the first input to be a function handle.');
	notEstIdx = find(cellfun(@(x) ~isa(x, 'estm'), varargin));
	varargin(notEstIdx) = cellfun(@(x) estm(x, 'SE', 0, 'SD', 0),...
		varargin(notEstIdx), 'UniformOutput', 0);


	% Input prcessing
	var = cellfun(@(x) x.Value, varargin, 'UniformOutput', 0);
	varSE = cellfun(@(x) x.StandardError, varargin, 'UniformOutput', 0);
	varSD = cellfun(@(x) x.StandardDeviation, varargin,...
		'UniformOutput', 0);
	% Replace empty SE/SD with 0
	varSE(cellfun(@isempty, varSE)) = {0};
	varSD(cellfun(@isempty, varSD)) = {0};
	n = numel(varargin);

	% Function values
	value = func(var{:});

	% If function not cached, create functions
	% Symbolic functions
	vars = symvar(sym(func));
	varSEs = sym('se', [1, n]);
	varSDs = sym('sd', [1, n]);
	funcs = symfun(sym(func), vars(:));

	% Find SE & SD functions
	sumSE = symfun(0, varSEs);
	sumSD = symfun(0, varSDs);
	for idx = 1: n
		dif = diff(funcs, vars(idx));
		sumSE = sumSE + (dif(var{:}) * varSEs(idx))^2;
		sumSD = sumSD + (dif(var{:}) * varSDs(idx))^2;
	end
	funcSE = matlabFunction(sqrt(sumSE));
	funcSD = matlabFunction(sqrt(sumSD));

	SE = funcSE(varSE{:});
	SD = funcSD(varSD{:});
	output = estm(value, 'SE', SE, 'SD', SD);

end
