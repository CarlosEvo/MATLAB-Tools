function [f, v, reynold] = frictionFactor( f_init, roughness, v_func, reynold_func )
% FRICTIONFACTOR Solve for friction factor
% function [f, v, reynold] = frictionFactor( f_init, roughness, v_func, reynold_func )

	% Validate Inputs
	validateattributes(f_init, {'numeric'}, {'numel', 1, '>', 0});
	validateattributes(roughness, {'numeric'}, {'numel', 1, '>=', 0});
	validateattributes(v_func, {'function_handle'}, {});
	validateattributes(reynold_func, {'function_handle'}, {});

	zero_func = @(f) f - moody(f, roughness, reynold_func(v_func(f)));
	f = fzero(zero_func, f_init, optimset('Display','iter'));
	v = v_func(f);
	reynold = reynold_func(v);

end

function f = moody( f_init, roughness, reynold )

zero_func = @(f) (reynold > 3000) * (f^(-0.5) + 2 * log10(roughness / 3.7 + 2.51 / (reynold * f^(0.5)))) + (reynold < 2500) * 64 / reynold;
f = fzero(zero_func, f_init);

end
