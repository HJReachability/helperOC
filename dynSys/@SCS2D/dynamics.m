function dx = dynamics(obj, ~, x, u, d)
% Dynamics:
%    \dot{x}_1 = x_1*u + d1
%    \dot{x}_2 = u + d2
%         u \in [uMin, uMax]
%         d \in [-dMax, dMax]

% Sylvia Herbert, 2018-06-25

if nargin < 5
  d = [0; 0];
end

if iscell(x)
  dx = cell(length(obj.dims), 1);
  
  for i = 1:length(obj.dims)
    dx{i} = dynamics_cell_helper(obj, x, u, d, obj.dims, obj.dims(i));
  end
else
  dx = zeros(obj.nx, 1);
  
  dx(1) = x(dims==1) .* u + d(1);
  dx(2) = u + d(2);
end
end

function dx = dynamics_cell_helper(obj, x, u, d, dims, dim)

switch dim
  case 1
    dx = x{dims==1}.* u + d{1};
  case 2
    dx = u + d{2};
  otherwise
    error('Only dimension 1-2 are defined for dynamics of SCS2D!')
end
end