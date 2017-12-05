function dx = dynamics(obj, t, x, u, d, ~)
% function dx = dynamics(t, x, u)
%     Dynamics of the Air3D system

%% For reachable set computations
if iscell(x)
  dx = cell(3,1);
  
  dx{1} = -obj.va + obj.vb * cos(x{3}) + u.*x{2};
  dx{2} = obj.vb * sin(x{3}) - u.*x{1};
  dx{3} = d - u;
end

%% For simulations
if isnumeric(x)
  dx = zeros(3,1);
  
  dx(1) = -obj.va + obj.vb * cos(x(3)) + u*x(2);
  dx(2) = obj.vb * sin(x(3)) - u*x(1);
  dx(3) = d - u;
end

end
