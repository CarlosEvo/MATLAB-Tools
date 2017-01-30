function [ str ] = splitCell( line1, line2 )

str = ['\begin{tabular}[c]{@{}c@{}}', line1, '\\', line2, '\end{tabular}'];

end

