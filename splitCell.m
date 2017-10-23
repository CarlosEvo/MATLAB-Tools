function [ str ] = splitCell( line1, line2 )

str = sprintf('\\begin{tabular}[c]{@{}c@{}}%s \\\\ %s\\end{tabular}', line1, line2);

end

