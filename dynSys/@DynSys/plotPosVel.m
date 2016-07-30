function plotPosVel(obj, x_or_y, color)
% Plots position and velocity on the same plot, for the x_or_y

if nargin < 2
  x_or_y = 'x';
end

switch x_or_y
  case 'x'
    pvdim = 1;
  case 'y'
    pvdim = 2;
  otherwise
    error('x_or_y must be x or y!')
end

[p, phist] = obj.getPosition;
[v, vhist] = obj.getVelocity;

if isempty(obj.hpvhist{pvdim}) || ~isvalid(obj.hpvhist{pvdim})
  % If no graphics handle has been created, create it. Use custom color
  % if provided.  
  if nargin<3
    obj.hpvhist{pvdim} = plot(phist(pvdim,:), vhist(pvdim,:), ':');
  else
    obj.hpvhist{pvdim} = plot(phist(pvdim,:), vhist(pvdim,:), ':', 'color', color);
  end
  hold on
else
  % Otherwise, simply update the graphics handles
  obj.hpvhist{pvdim}.XData = phist(pvdim,:);
  obj.hpvhist{pvdim}.YData = vhist(pvdim,:);
end

%% Plot current position and velocity using an arrow
if isempty(obj.hpv{pvdim}) || ~isvalid(obj.hpv{pvdim})
  % If no graphics handle has been created, create it with the specified
  % color. Use default color if no color is provided.
  if nargin<3
    obj.hpv{pvdim} = plot(p(pvdim), v(pvdim), 'o');
  else
    obj.hpv{pvdim} = plot(p(pvdim), v(pvdim), 'o', 'color', color);
  end
  hold on
  
  obj.hpv{pvdim}.Color = obj.hpvhist{pvdim}.Color;
  obj.hpv{pvdim}.MarkerFaceColor = obj.hpvhist{pvdim}.Color;
  obj.hpv{pvdim}.MarkerSize = 6;
else
  % Otherwise, simply update graphics handles
  obj.hpv{pvdim}.XData = p(pvdim);
  obj.hpv{pvdim}.YData = v(pvdim);
end

end