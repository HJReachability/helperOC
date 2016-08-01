function dx = dynamics(obj, t, x, u, ~, dims)
% function dx = dynamics(t, x, u)
%     Dynamics of the double integrator

if nargin < 6
  dims = 1:obj.nx;
end

%% Initialization
if isnumeric(x)
  x = num2cell(x); % Make sure x is always a cell
  dx = zeros(length(dims, 1));
elseif iscell(x)
  dx = cell(length(dims), 1);
else
  error('Unknown state variable type!')
end

for i = 1:length(dims)
  %% Dynamics
  switch dims(i)
    case 1
      dxi = x{2};
    case 2
      dxi = u;
    otherwise
      error('DoubleInt only has dimenisions 1 and 2!')
  end
  
  %% Populate output variable
  if isnumeric(x)
    dx(i) = dxi;
  else
    dx{i} = dxi;
  end
end

end
