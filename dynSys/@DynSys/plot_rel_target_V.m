function plot_rel_target_V(obj, rel_target_V, other, level)
% plot_abs_target_V(obj, abs_target_V, target_position, ...
%   target_heading, level)
%
% Plots the reachable set for creating a platoon

if nargin < 4
  level = 0:10;
end

if numel(level) == 1
  level = [level level];
end

[g2D, data2D] = obj.get_target_V_plotData(rel_target_V, ...
  other.getPosition, other.getHeading);

% Plot result
if isempty(obj.h_rel_target_V)
  [~, obj.h_rel_target_V] = contour(g2D.xs{1}, g2D.xs{2}, data2D, ...
    level, 'linestyle', ':', 'linewidth', 2, 'color', obj.hpxpy.Color);
else
  obj.h_rel_target_V.XData = g2D.xs{1};
  obj.h_rel_target_V.YData = g2D.xs{2};
  obj.h_rel_target_V.ZData = data2D;
  obj.h_rel_target_V.Visible = 'on';
end
end