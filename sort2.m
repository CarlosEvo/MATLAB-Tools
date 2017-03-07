function [x_f , y_f] = sort2(x_i, y_i)
%SORT2 Sort Data and Clean Duplicates
%   sort2(x_i, y_i) will sort data array according to the values of x_i and
%   clean up duplicate x_i data by taking average

	[x_tmp, sortIdx] = sort(x_i);
	y_tmp = y_i(sortIdx);
	[x_f, i2fIdx] = unique(x_tmp);
	i2fIdx = [i2fIdx; i2fIdx(end) + 1];
	y_f = arrayfun(@(idx) mean(y_tmp(i2fIdx(idx): i2fIdx(idx + 1) - 1)),...
		1:length(i2fIdx) - 1);

end

