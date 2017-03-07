function [output] = estComp(func, varargin)
%ESTCOMP Computation on estm class
%   [output] = estComp(func, estm1, ..., estmN) performs
%   calculations with standard error. func is the function handle of the
%   calculation. estm1, ..., estmN are the estm class values.
%   Output is estm class.

	% Global Memomizatin Values
	global func_mem funcSE_mem funcSD_mem limit;
	if isempty(func_mem)
		limit = 15;
		func_mem = cell(limit, 1);
		funcSE_mem = cell(limit, 1);
		funcSD_mem = cell(limit, 1);
		[func_mem{:}, funcSE_mem{:}, funcSD_mem{:}] = deal('');
	end

	% Check validity
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

	% Find if func is cached
	func_str = func2str(func);
	matchIdxC = strfind(func_mem, func_str);
	matchIdx = find(not(cellfun(@isempty, matchIdxC)));
	if isempty(matchIdx) % If not cached
		% Symbolic functions
		vars = symvar(sym(func));
		varSEs = sym('se', [1, n]);
		varSDs = sym('sd', [1, n]);
		funcs = symfun(sym(func), vars(:));

		% Find SE & SD functions
		sumSE = symfun(0, [vars varSEs]);
		sumSD = symfun(0, [vars varSDs]);
		for idx = 1: n
			dif = diff(funcs, vars(idx));
			SESquare = symfun((dif * varSEs(idx))^2, [vars varSEs]);
			SDSquare = symfun((dif * varSDs(idx))^2, [vars varSDs]);
			sumSE = sumSE + SESquare;
			sumSD = sumSD + SDSquare;
		end
		funcSE = matlabFunction(sqrt(sumSE));
		funcSD = matlabFunction(sqrt(sumSD));

		% Add to cache
		funcSE_str = func2str(funcSE);
		funcSD_str = func2str(funcSD);
		if numel(func_mem) == limit
			func_mem = {func_mem{2: end}, func_str};
			funcSE_mem = {funcSE_mem{2: end}, funcSE_str};
			funcSD_mem = {funcSD_mem{2: end}, funcSD_str};
		else
			emptyIdx = find(cellfun(@isempty, func_mem), 1);
			func_mem{emptyIdx} = func_str;
			funcSE_mem{emptyIdx} = funcSE_str;
			funcSD_mem{emptyIdx} = funcSD_str;
		end

	else % If cached
		funcSE = str2func(funcSE_mem{matchIdx});
		funcSD = str2func(funcSD_mem{matchIdx});
	end

	SE = funcSE(var{:}, varSE{:});
	SD = funcSD(var{:}, varSD{:});
	output = estm(value, 'SE', SE, 'SD', SD);

end
