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
% NOTE: For 3D arrays, this code automatically checks whether the 3rd
% dimension is periodic by checking whether g.bdry{3} is @addGhostPeriodic
%
% Mo Chen, 2015-10-15

% Input checking
x = checkInterpInput(g, x);

switch g.dim
  case 1
    v = interpn(g.vs{1}, data, x);
  case 2
    v = interpn(g.vs{1}, g.vs{2}, data, x(:,1),x(:,2));
  case 3
    if isequal(g.bdry{3}, @addGhostPeriodic)
      v = interpn(g.vs{1}, g.vs{2}, [g.vs{3}; 2*pi], cat(3, data, ... 
        data(:,:,1)), x(:,1),x(:,2),x(:,3));
    else
      v = interpn(g.vs{1}, g.vs{2}, g.vs{3}, data, x(:,1),x(:,2),x(:,3));
    end
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