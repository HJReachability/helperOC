function dx = dynamics(obj, ~, x, u, d, ~)
% Dynamics:
%    \dot{x}_1 = v * cos(x_3) + d1 - v1
%    \dot{x}_2 = v * sin(x_3) + d2 - v2
%    \dot{x}_3 = u            + d3
%         v \in [vrange(1), vrange(2)]
%         u \in [-wMax, wMax]
%         (v1, v2) \in vMax-ball

if numel(u) ~= obj.nu
  error('Incorrect number of control dimensions!')
end

if iscell(x)
  dx = cell(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx{1} = u{1} .* cos(x{3}) + d{1} - d{4};
  dx{2} = u{1} .* sin(x{3}) + d{2} - d{5};
  dx{3} = u{2} + d{3};  
else
  dx = zeros(obj.nx, 1);
  
  % Kinematic plane (speed can be changed instantly)
  dx(1) = u(1) * cos(x(3)) + d(1) - d(4);
  dx(2) = u(1) * sin(x(3)) + d(2) - d(5);
  dx(3) = u(2) + d(3);
end


end