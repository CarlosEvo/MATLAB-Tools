function [m, b, r2, func] = ldm2estm( ldm )
% ldm2estm: Extract LDM Info to Estm
%
% [ m, b, r2, func ] = ldm2estm( ldm ): returns m, b, r2, func of the linear model ldm.
% m, b are in estm class, and r2 is float

	m = estm(table2array(ldm.Coefficients(2, 1)), table2array(ldm.Coefficients(2, 2)));
	b = estm(table2array(ldm.Coefficients(1, 1)), table2array(ldm.Coefficients(1, 2)));
	r2 = ldm.Rsquared.ordinary;
	func = @(x) m.Value * x + b.Value;

end  % ldm2estm
