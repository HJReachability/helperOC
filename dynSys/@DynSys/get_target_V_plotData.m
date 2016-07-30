function [g2D, data2D] = get_target_V_plotData(obj, abs_target_V, ...
  target_position, target_heading)
% plot_abs_target_V(obj, abs_target_V, target_position, ...
%   target_heading, level)
%
% Plots the reachable set for creating a platoon

% Project reachable set to 2D
[g2D, data2D] = proj2D(abs_target_V.g, abs_target_V.data, [0 1 0 1], ...
  rotate2D(obj.getVelocity, -target_heading));

% translation and rotation
g2D = rotateGrid(g2D, target_heading);
g2D = shiftGrid(g2D, target_position);

% Make sure the boundary of the grid is being shown
large = 1e4;
data2D(:,1) = large;
data2D(:,end) = large;
data2D(1,:) = large;
data2D(end,:) = large;
end