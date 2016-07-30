function plotPosition(obj, color)
% function plotPosition(obj, color)
%
% Plots the current state and the trajectory of the quadrotor
%
% Inputs: obj   - vehicle object
%         color - color for plotting
%
% Mo Chen, 2015-06-21
% Modified: Mo Chen, 2015-10-20

%% Get position and velocity
[p, phist] = obj.getPosition;
v = obj.getVelocity;

%% Plot position trajectory
if isempty(obj.hpxpyhist) || ~isvalid(obj.hpxpyhist)
  % If no graphics handle has been created, create it. Use custom color
  % if provided.
  if nargin<2
    obj.hpxpyhist = plot(phist(1,:), phist(2,:), ':'); 
  else
    obj.hpxpyhist = plot(phist(1,:), phist(2,:), ':', 'color', color); 
  end
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
  if nargin<2
    obj.hpxpy = quiver(p(1), p(2), v(1), v(2), 'o', 'MaxHeadSize', 2, ...
      'ShowArrowHead', 'on');
  else
    obj.hpxpy = quiver(p(1), p(2), v(1), v(2), 'o', 'MaxHeadSize', 2, ...
      'ShowArrowHead', 'on', 'color', color);
  end
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