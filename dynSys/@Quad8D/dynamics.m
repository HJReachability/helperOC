function dx = dynamics(obj, ~, x, u, d)
% dx = dynamics(obj, ~, x, u, ~)
%     Dynamics of the 8D Quadrotor in the plane
%         This is the same as Quad10D without the last two states
%         \dot x_1 = x_2 - d_1
%         \dot x_2 = g * tan(x_3)
%         \dot x_3 = -d1 * x_3 + x_4
%         \dot x_4 = -d0 * x_3 + n0 * u1
%         \dot x_5 = x_6 - d_2
%         \dot x_6 = g * tan(x_7)
%         \dot x_7 = -d1 * x_7 + x_8
%         \dot x_8 = -d0 * x_7 + n0 * u2
%              uMin <= [u1; u2] <= uMax
%              dMin <= [d1; d2] <= dMax

if nargin < 5
  d = {0; 0};
end

if nargin < 6
  dims = obj.dims;
end

convert2num = false;
if ~iscell(x)
  x = num2cell(x);
  convert2num = true;
end

if ~iscell(u)
  u = num2cell(u);
end

if ~iscell(d)
  d = num2cell(d);
end

dx = cell(length(dims), 1);

for i = 1:length(dims)
  dx{i} = dynamics_cell_helper(obj, x, u, d, dims, dims(i));
end

if convert2num
  dx = cell2mat(dx);
end

end

function dx = dynamics_cell_helper(obj, x, u, d, dims, dim)
switch dim
  case 1
    dx = x{dims==2} + d{1};
  case 2
    dx = obj.g * tan(x{dims==3});
  case 3
    dx = -obj.d1 * x{dims==3} + x{dims==4};
  case 4
    dx = -obj.d0 * x{dims==3} + obj.n0 * u{1};
  case 5
    dx = x{dims==6} + d{2};
  case 6
    dx = obj.g * tan(x{dims==7});
  case 7
    dx = -obj.d1 * x{dims==7} + x{dims==8};
  case 8
    dx = -obj.d0 * x{dims==7} + obj.n0 * u{2};
    
  otherwise
    error('Only dimension 1-8 are defined for dynamics of Quad8D!')
end
end
