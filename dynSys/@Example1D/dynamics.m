function dx = dynamics(obj, t, x, u, d)
% Dynamics of the Plane
%    \dot{x}_1 = u + d
%   Control: u
%   Disturbance: d
%

if iscell(x)
  dx = cell(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx{1} = u + (1./x{1}).*d;
else
  dx = zeros(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx(1) = u + (1./x(1)).*d;
end


end