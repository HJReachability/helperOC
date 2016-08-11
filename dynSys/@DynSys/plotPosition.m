function plotPosition(obj, color, arrowLength)
% function plotPosition(obj, color)
%
% Plots the current state and the trajectory of the quadrotor
%
% Inputs: obj   - vehicle object
%         color - color for plotting
%
% Mo Chen, 2015-06-21
% Modified: Mo Chen, 2015-10-20

if nargin < 2
  color = 'k';
end

if nargin < 3
  arrowLength = 0.1;
end

%% Get position and velocity
[p, phist] = obj.getPosition;
v = obj.getVelocity;
v = v/norm(v);

%% Plot position trajectory
if isempty(obj.hpxpyhist) || ~isvalid(obj.hpxpyhist)
  % If no graphics handle has been created, create it.
  obj.hpxpyhist = plot(phist(1,:), phist(2,:), '.', 'color', color);
  hold on
else
  % Otherwise, simply update the graphics handles
  obj.hpxpyhist.XData = phist(1,:);
  obj.hpxpyhist.YData = phist(2,:);
end

%% Plot current position and velocity using an arrow
if isempty(obj.hpxpy) || ~isvalid(obj.hpxpy)
  % If no graphics handle has been created, create it with the specified
  % color. Use default color if no color is provided.
  obj.hpxpy = quiver(p(1), p(2), v(1), v(2), 'ShowArrowHead', ...
    'on', 'AutoScaleFactor', arrowLength);
  hold on
  
  obj.hpxpy.Color = obj.hpxpyhist.Color;
  obj.hpxpy.MarkerFaceColor = obj.hpxpyhist.Color;
  obj.hpxpy.MarkerSize = 6;
else
  % Otherwise, simply update graphics handles
  obj.hpxpy.XData = p(1);
  obj.hpxpy.YData = p(2);
  obj.hpxpy.UData = v(1);
  obj.hpxpy.VData = v(2);
end

end