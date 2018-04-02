function dx = dynamics(obj, ~, x, u, d)
% dx = dynamics(obj, ~, x, u, d)
%     Dynamics of the Plane5D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1 (x position)
%         \dot{x}_2 = x_4 * sin(x_3) + d_2 (y position)
%         \dot{x}_3 = x_5                  (heading)
%         \dot{x}_4 = u_1 + d_3            (linear speed)
%         \dot{x}_5 = u_2 + d_4            (turn rate)

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
    dx = x{dims==5};
  case 4
    dx = u{1} + d{3};
  case 5
    dx = u{2} + d{4};
  otherwise
    error('Only dimension 1-5 are defined for dynamics of Plane5D!')    
end
end