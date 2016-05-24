function v = eval_u(gs, datas, xs)
% v = eval_u(g, datas, x)
%   Computes the interpolated value of the value functions datas at the
%   states xs
%
% Inputs:
%   Option 1: Single grid, single value function, multiple states
%     gs    - a single grid structure
%     datas - a single matrix (look-up stable) representing the value 
%             function
%     xs    - set of states; each row is a state
%
%   Option 2: Single grid, multiple value functions, single state
%     gs    - a single grid structure
%     datas - a cell structure of matrices representing the value function
%     xs    - a single state
%
%   Option 3: Multiple grids, value functions, and states. The number of 
%             grids, value functions, and states must be equal under this 
%             option
%     gs    - a cell structure of grid structures
%     datas - a cell structure of matrices representing value functions
%     xs    - a cell structure of states
%
% Mo Chen, 2016-05-18

if isstruct(gs) && isnumeric(datas) && ismatrix(xs)
  % Option 1
  v = eval_u_single(gs, datas, xs);
  
elseif isstruct(gs) && iscell(datas) && isvector(xs)
  % Option 2
  v = zeros(length(datas), 1);
  for i = 1:length(datas)
    v(i) = eval_u_single(gs, datas{i}, xs);
  end
  
elseif iscell(gs) && iscell(datas) && iscell(xs)
  % Option 3
  v = zeros(length(gs), 1);
  for i = 1:length(gs)
    v(i) = eval_u_single(gs{i}, datas{i}, xs{i});
  end
  
else
  error('Unrecognized combination of input data types!')
end
end

function v = eval_u_single(g, data, x)
% v = eval_u_single(g, data, x)
%   Computes the interpolated value of a value function data at state x
%
% Inputs:
%   g       - grid
%   data    - implicit function describing the set
%   x       - points to check; each row is a point
%
% OUTPUT
%   v:  value at points x
%
% Mo Chen, 2015-10-15
% Updated 2016-05-18

%% Dealing with periodicity
for i = 1:g.dim
  if isequal(g.bdry{i}, @addGhostPeriodic)
    % Grid points
    g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));

    % Input data
    data = eval(periodicAugmentCmd(i, g.dim));
  end
end

%% Interpolate
% Input checking
x = checkInterpInput(g, x);

switch g.dim
  case 1
    v = interpn(g.vs{1}, data, x);
    
  case 2
    v = interpn(g.vs{1}, g.vs{2}, data, x(:,1),x(:,2));
    
  case 3
    v = interpn(g.vs{1}, g.vs{2}, g.vs{3}, data, x(:,1),x(:,2),x(:,3));
    
  case 4
    v = interpn(g.vs{1},g.vs{2},g.vs{3}, g.vs{4}, data, ...
      x(:,1),x(:,2),x(:,3),x(:,4));
    
  case 6
    v = interpn(g.vs{1}, g.vs{2},g.vs{3}, g.vs{4}, g.vs{5}, g.vs{6}, ...
      data, x(:,1), x(:,2), x(:,3), x(:,4), x(:,5), x(:,6));
    
  otherwise
    error(['Cannot evaluate matrices with dimension' num2str(g.dim) '!'])
end

end

function cmd = periodicAugmentCmd(idim, dims)
% cmd = periodicAugmentCmd(idim, dims)
%
% Creates the command for concatenating the first slice of data to the end of
% the data to deal with periodic dimensions.
%
% eg. periodicAugmentCmd(1, 3) returns 'cat(1, data, data(1,:,:))'
%     periodicAugmentCmd(3, 3) returns 'cat(3, data, data(:,:,1))'
%
% Mo Chen, 2016-02-19


cmd = ['cat(' num2str(idim) ', data, data('];

for i = 1:dims
  if i == idim
    cmd = [cmd '1'];
  else
    cmd = [cmd ':'];
  end
  
  if i == dims
    cmd = [cmd '));'];
  else
    cmd = [cmd ','];
  end
end
end