function dx = dynamics(obj, ~, x, u, ~)
% dx = dynamics(obj, t, x, u, d)
%     Dynamics of the quadrotor

dx = cell(obj.nx,1);
dims = obj.dims;

returnVector = false;
if ~iscell(x)
  returnVector = true;
  x = num2cell(x);
  u = num2cell(u);
end

for i = 1:length(dims)
  dx{i} = dynamics_cell_helper(x, u, dims, dims(i));
end

if returnVector
  dx = cell2mat(dx);
end
end

function dx = dynamics_cell_helper(x, u, dims, dim)

switch dim
  case 1
    dx = x{dims==2};
  case 2
    dx = u{1};
  case 3
    dx = x{dims==4};
  case 4
    dx = u{2};
  otherwise
    error('Only dimensions 1-4 are defined for dynamics of Quad4DC!')
end
end