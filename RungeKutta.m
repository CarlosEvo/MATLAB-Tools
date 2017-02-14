function [ y_out ] = RungeKutta( y_in, func, tRange, varargin )
% RungeKutta: Runge Kutta Method
%
% [ out ] = RungeKutta( y_n, func, tRange, Name, Value ): gives y_out based on input value of func(t, y), y_in, tRange and number of steps stepNo or step size stepSize

	p = inputParser;
	addRequired(p, 'y_in', @isscalar);
	addRequired(p, 'func', @(x) isa(x, 'function_handle'));
	addRequired(p, 'tRange', @isvector);
	addParameter(p, 'stepNo', 10, @(x) mod(x, 1) == 0 && x > 0);
	addParameter(p, 'stepSize', 0, @isscalar)
	parse(p, y_in, func, tRange, varargin{:});

	yn = p.Results.y_in;
	func = p.Results.func;
	tRange = p.Results.tRange;
	stepNo = p.Results.stepNo;
	stepSize = p.Results.stepSize;

	switch p.UsingDefaults{1}
		case 'stepNo'
			if mod(range(tRange), stepSize) ~= 0
				error('Step Size error: t-Range is not divisible by step size.');
			end
		case 'stepSize'
			 stepSize = range(tRange) / stepNo;
		 otherwise
			 error('Too many arguments');
	end

	for tn = min(tRange) : stepSize : max(tRange) - stepSize
		kn1 = func(tn, yn);
		kn2 = func(tn + stepSize * 0.5, yn + stepSize * kn1 * 0.5);
		kn3 = func(tn + stepSize * 0.5, yn + stepSize * kn2 * 0.5);
		kn4 = func(tn + stepSize, yn + stepSize * kn3);
		yn = yn + stepSize * (kn1 + 2 * kn2 + 2 * kn3 + kn4) / 6;
	end

	y_out = yn;

end  % RungeKutta
