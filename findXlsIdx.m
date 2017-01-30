function [ idx ] = findXlsIdx( names, exp )
% findXlsIdx: find index of spreadsheet
%
% [ idx ] = findXlsIdx( names, exp ): find indices of spreadsheet whose name(s) matches expression exp

idx = find(~cellfun(@isempty, regexp(names, exp)));

end  % findXlsIdx
