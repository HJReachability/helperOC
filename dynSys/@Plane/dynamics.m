function dx = dynamics(obj, t, x, u, d, ~)
% Dynamics of the Plane
%    \dot{x}_1 = v * cos(x_3) + d1
%    \dot{x}_2 = v * sin(x_3) + d2
%    \dot{x}_3 = w + d3
%   Control: u = [v; w];
%
% Mo Chen, 2016-03-09

if nargin < 5
  d = [0; 0; 0];
end

if numel(u) ~= obj.nu
  error('Incorrect number of control dimensions!')
end

if iscell(x)
  dx = cell(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx{1} = u{1} .* cos(x{3}) + d{1};
  dx{2} = u{1} .* sin(x{3}) + d{2};
  dx{3} = u{2} + d{3};  
else
  dx = zeros(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx(1) = u(1) * cos(x(3)) + d(1);
  dx(2) = u(1) * sin(x(3)) + d(2);
  dx(3) = u(2) + d(3);
end


end