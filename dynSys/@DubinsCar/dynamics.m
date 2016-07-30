function dx = dynamics(obj, t, x, u, ~, ~)
% Dynamics of the Dubins Car
%    \dot{x}_1 = v * cos(x_3)
%    \dot{x}_2 = v * sin(x_3)
%    \dot{x}_3 = w
%   Control: u = w;
%
% Mo Chen, 2016-06-08

if iscell(x)
  dx = cell(obj.nx, 1);
  
  dx{1} = obj.speed * cos(x{3});
  dx{2} = obj.speed * sin(x{3});
  dx{3} = u;
else
  dx = zeros(obj.nx, 1);
  
  dx(1) = obj.speed * cos(x(3));
  dx(2) = obj.speed * sin(x(3));
  dx(3) = u;
end


end