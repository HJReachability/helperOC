function dx = dynamics(obj, t, x, u, d, ~)
% Dynamics of the Quad4DCAvoidX, two quadrotors performing collision avoidance
% This is the [1 2] or [3 4] component of the Quadr4DCAvoid system
% Dynamics:
%     \dot{x}_1 = x_2
%     \dot{x}_2 = uB - uA
%       |uA| <= aMax
%       |uB| <= bMax

if iscell(x)
  dx = cell(obj.nx, 1);
  
  dx{1} = x{2};
  dx{2} = d - u;
else
  dx = zeros(obj.nx, 1);
  
  dx(1) = x(2);
  dx(2) = d - u;
end


end