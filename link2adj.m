function [A, Coordinates] = link2adj(link)
% LINK2ADJ Linkage to Adjacency Matrix
%   function [A, Coordinates] = link2adj(link) takes linkage struct array as
% input, and returns adjacency matrix A, and Coordinates.
%   link is a struct of length N >= 3 and with fields 'length' and 'angle'.
%   A is a N x N adjacency matrix and Coordinates is a N x 2 matrix. The first
% link's starting point is taken as the origin

    % Validate input
    if length(link) < 3
        error('The number of link must be at least 3');
    elseif ~isfield(link, 'length') || ~isfield(link, 'angle')
        error('The link struct array must contain lengths and angles');
    end

    % Obtain number of links
    N = length(link);

    % Initialize results
    A = zeros(N);
    Coordinates = zeros(N, 2);

    % Set origin
	if ~isfield(link, 'origin')
        Coordinates(1, :) = [0, 0];
    else
        Coordinates(1, :) = link(1).origin(end, :);
    end

    % Find R-joint location using addition
    for link_idx = 2 : N
        Coordinates(link_idx, :) =...
            Coordinates(link_idx - 1, :)...
            + link(link_idx - 1).length(end)...
            .* [...
                cos(link(link_idx - 1).angle(end)),...
                sin(link(link_idx - 1).angle(end))...
            ];
    end

    % Define adjacency matrix
    A(sub2ind(size(A), 1 : N - 1, 2 : N)) = 1;
    A(N, 1) = 1;

end
