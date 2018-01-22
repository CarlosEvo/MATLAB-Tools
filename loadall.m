function [] = loadall(varagin)
%LOADALL Load All Specified .mat Files
%   loadall(filename1, filename2, ...) loads all specified .mat data files
%   to the current workspace if not already loaded

	cellfun(@(fn) load(fn), varagin);

end

