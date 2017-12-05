function data = shapeEllipsoid(grid, center, semi_axes)
% data = shapeEllipsoid(grid, center, semi_axes)
%     Generates an ellipse around center with given semi-axes
%
% Inputs:
%     grid - grid compatible with level set toolbox
%     center - vector of length grid.dim specifying the center of the ellipsoid
%     semi_axes - vector of length grid.dim specifying the semi axes
%
% Output:
%     data - implicit surface function representing the ellipsoid

data1 = 0;
data2 = 0;
data3 = 0;
for i = 1:grid.dim
  data1 = data1 + (grid.xs{i} - center(i)).^2 / semi_axes(i)^2;
  
  % Dealing with periodic conditions
  if isequal(grid.bdry{i}, @addGhostPeriodic)
    data2 = data2 + (grid.xs{i} - center(i) - 2*pi).^2 / semi_axes(i)^2;
    data3 = data3 + (grid.xs{i} - center(i) + 2*pi).^2 / semi_axes(i)^2;  
  else
    data2 = data2 + (grid.xs{i} - center(i)).^2 / semi_axes(i)^2;
    data3 = data3 + (grid.xs{i} - center(i)).^2 / semi_axes(i)^2;
  end
end

data1 = data1 - 1;
data2 = data2 - 1;
data3 = data3 - 1;

data = min(data1, data2);
data = min(data, data3);
end