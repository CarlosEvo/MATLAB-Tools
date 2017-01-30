function [ names, varargout ] = xlsReadAll( file )

[~, names] = xlsfinfo(file);
names = names';
sheets = length(names);
varargout = cell(sheets, 1);

for idx = 1: sheets
	varargout{idx} = xlsread(file, idx);
end

end