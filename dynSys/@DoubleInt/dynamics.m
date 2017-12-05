function dx = dynamics(obj, ~, x, u, ~)
% function dx = dynamics(t, x, u)
%     Dynamics of the double integrator
%     \dot{x}_1 = x_2
%     \dot{x}_2 = u

if iscell(x)
  dx = cell(length(obj.dims), 1);
  for i = 1:length(obj.dims)
    dx{i} = obj.dyn_helper(x, u, obj.dims, obj.dims(i));
  end
else
  dx = [x(2); u];
end
  
end