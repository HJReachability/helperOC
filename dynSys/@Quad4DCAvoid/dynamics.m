function dx = dynamics(obj, t, x, u, d, ~)
% Dynamics of the Quad4DCAvoid, two quadrotors performing collision avoidance
%     \dot{x}_1 = x_2
%     \dot{x}_2 = uB(1) - uA(1)
%     \dot{x}_3 = x_4
%     \dot{x}_4 = uB(2) - uA(2)
%       |uA(i)| <= aMax(i)
%       |uB(i)| <= bMax(i), i = 1,2

if iscell(x)
  dx = cell(obj.nx, 1);
  
  dx{1} = x{2};
  dx{2} = d{1} - u{1};
  dx{3} = x{4};
  dx{4} = d{2} - u{2};
else
  dx = zeros(obj.nx, 1);
  
  dx(1) = x(2);
  dx(2) = d(1) - u(1);
  dx(3) = x(4);
  dx(4) = d(2) - u(2);
end


end