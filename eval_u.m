function v = eval_u(g, data, x)
% v = eval_u(g, data, x)
% Checks weather the point x is inside the set described by data
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
% Updated 2016-02-19

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