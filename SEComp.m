function [value, SE] = SEComp(func, varargin)
% SEComp Function value with standard error
% [value, SE] = SEComp(func, var1, var1SE,..., varN, varNSE)

    if mod(length(varargin), 2) ~= 0
        error('Wrong number of input arguments');
    end

	% Input prcessing
    var = varargin(1:2:end - 1);
    varSE = varargin(2:2:end);
	n = length(varargin) / 2;

	% Function values
	value = func(var{:});

	% Symbolic functions
    vars = symvar(sym(func), n);
	varSEs = sym('se', [1, n]);
    funcs = symfun(sym(func), vars(:));

	% Find SE functions
	sum = symfun(0, varSEs);
	for idx = 1: n
		dif = diff(funcs, vars(idx));
		sum = sum + (dif(var{:}) .* varSEs(idx)) .^ 2;
	end

	funcSE = sqrt(sum);
	SE = double(funcSE(varSE{:}));

end
