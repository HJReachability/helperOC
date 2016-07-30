function plotMergeHighwayV(obj, target, hw)
% function plotMergeHighwayV(obj, target)
%
% Plots the zero sublevel set of value function for merging onto the
% highway
%
% Inputs:  obj    - quadrotor object
%          target - target state that quadrotor is aiming to reach
%
% Mo Chen, 2015-06-21

% Unpack constants

%% Construct grid
% Position domain should cover all grid positions around the OTHER vehicle
% since p = [px py] indicates that this vehicle is at (px, py) where the
% origin is centered around the other vehicle
%
% Velocity domain should cover a thin layer around current relative
% velocity
if hw.liveV.g.dim == 2
  reference = zeros(obj.nx, 1);
  reference(obj.pdim) = nan;
  reference(obj.vdim) = obj.getVelocity;
  [xmin, xmax] = highDimGridBounds(hw.liveV.g, reference);
  
  % Compute value for V(t,x) on the relative velocity slice and project down
  % to 2D
  [g2D, value2D] = reconProj2D(hw.liveV, xmin, xmax, inf, obj.getVelocity);
  
  % Visualization level
  level = 0;
  
elseif hw.liveV.g.dim == 4
  [g2D, value2D] = proj2D(hw.liveV.g, [0 1 0 1], hw.liveV.g.N([1 3]), ...
    hw.liveV.data, obj.getVelocity);

  level = abs(max(hw.liveV.tau) - min(hw.liveV.tau));
else
  error('Highway liveness reachable set must be 2D or 4D!')
end

% Shift the grid
shiftAmount = target';
g2Dt = shift2DGrid(g2D, shiftAmount);

% Plot result
if isempty(obj.hmergeHighwayV)
  [~, obj.hmergeHighwayV] = contour(g2Dt.xs{1}, g2Dt.xs{2}, value2D, ...
    [level level], 'lineStyle', ':', 'linewidth', 2);
else
  obj.hmergeHighwayV.XData = g2Dt.xs{1};
  obj.hmergeHighwayV.YData = g2Dt.xs{2};
  obj.hmergeHighwayV.ZData = value2D;
  obj.hmergeHighwayV.Visible = 'on';
end

% Color
if isempty(obj.hpxpyhist.Color)
  obj.hmergeHighwayV.LineColor = 'r';
else
  obj.hmergeHighwayV.LineColor = obj.hpxpyhist.Color;
end

end