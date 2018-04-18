function dx = dynamics(obj, ~, x, u, d)
% dx = dynamics(obj, ~, x, u, d)
%     Dynamics of the Plane4D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1
%         \dot{x}_2 = x_4 * sin(x_3) + d_1
%         \dot{x}_3 = u_1 = u_1
%         \dot{x}_4 = u_2 = u_2

if nargin < 5
  d = [0; 0; 0];
end

dx = cell(obj.nx, 1);

returnVector = false;
if ~iscell(x)
  returnVector = true;
  x = num2cell(x);
  u = num2cell(u);
  d = num2cell(d);
end

for i = 1:length(obj.dims)
  dx{i} = dynamics_i(x, u, d, obj.dims, obj.dims(i));
end

if returnVector
  dx = cell2mat(dx);
end
end

function dx = dynamics_i(x, u, d, dims, dim)

switch dim
  case 1
    dx = x{dims==4} .* cos(x{dims==3}) + d{1};
  case 2
    dx = x{dims==4} .* sin(x{dims==3}) + d{2};
  case 3
    dx = u{1};
  case 4
    dx = u{2};
  otherwise
    error('Only dimension 1-4 are defined for dynamics of Plane4D!')    
end
end