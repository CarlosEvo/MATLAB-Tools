function [fig, ax] = drawLinkage(linkage)
% Draw a linkage

fig = figure;
ax = gca;
hold on;

tot_length = sum(linkage.length);
y_offset = tot_length /75;

origin = [0, 0];
for idx = 1:length(linkage.length)
	
	delta = linkage.length(idx) .* [cos(linkage.angle(idx)); sin(linkage.angle(idx))];
	end_point = origin + delta;
	line([origin(1), end_point(1)], [origin(2), end_point(2)], 'Linewidth', 1.5, 'Marker', 'o');
	
	mid_point = delta / 2 + origin;
	text(mid_point(1), mid_point(2) + y_offset, sprintf('%d', idx), 'FontSize', 16);
	
	origin = end_point;
	
end

end