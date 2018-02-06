function dx = dynamics(obj, t, x, u, ~)
% Dynamics of the Plane
%    \dot{x}_1 = vx 
%    \dot{x}_2 = vy 
%   Control: u = [vx; vy];
%

if numel(u) ~= obj.nu
  error('Incorrect number of control dimensions!')
end

if iscell(x)
  dx = cell(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx{1} = u{1};
  dx{2} = u{2};
else
  dx = zeros(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx(1) = u(1);
  dx(2) = u(2);
end


end