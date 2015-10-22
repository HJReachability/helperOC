function p = calculateCostate(g, P, x)
% function p = calculateCostate(g, P, x)
%
% Calculates the gradient (costate) at x given an array of gradients stored
% in P. Periodicity is automatically checked
%
% Inputs: 
%   g - grid structure
%   P - array of gradients; P{i} is the ith component
%   x - each row is one point x to evaluate costate at
%
% Output: 
%   p - interpolated gradient at x
%
% Mo Chen, 2015-10-15
% Originally adapted from Haomiao Huang's code

% Check input
x = checkInterpInput(g, x);

p = zeros(size(x,1), g.dim);

switch g.dim
  case 1
    % Dealing with periodicity
    if isequal(g.bdry, @addGhostPeriodic)
      g.vs{1} = cat(1, g.vs{1}, g.vs{1}(end)+g.dx(1));
      P{1} = cat(1, P{1}, P{1}(1));
    end
    
    % Interpolate
    p(:,1) = interpn(g.vs{1}, P{1}, x(:,1));
    
  case 2
    % Dealing with periodicity
    for i = 1:2
      if isequal(g.bdry{i}, @addGhostPeriodic)
        g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
      end
    end
    
    if isequal(g.bdry{1}, @addGhostPeriodic)
      for i = 1:2
        P{i} = cat(1, P{i}, P{i}(1,:));
      end
    end
    
    if isequal(g.bdry{2}, @addGhostPeriodic)
      for i = 1:2
        P{2} = cat(2, P{i}, P{i}(:,1));
      end
    end
    
    % Interpolate
    for i = 1:2
      p(:,i) = interpn(g.vs{1}, g.vs{2}, P{i}, x(:,1), x(:,2));
    end
    
  case 3
    % Dealing with periodicity
    for i = 1:3
      if isequal(g.bdry{i}, @addGhostPeriodic)
        g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
      end
    end
    
    if isequal(g.bdry{1}, @addGhostPeriodic)
      for i = 1:3
        P{1} = cat(1, P{i}, P{i}(i,:,:));
      end
    end
    
    if isequal(g.bdry{2}, @addGhostPeriodic)
      for i = 1:3
        P{2} = cat(2, P{i}, P{i}(:,1,:));
      end
    end
    
    if isequal(g.bdry{3}, @addGhostPeriodic)
      for i = 1:3
        P{i} = cat(3, P{i}, P{i}(:,:,1));
      end
    end
    
    % Interpolate
    for i = 1:3
      p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, P{i}, x(:,1), ...
        x(:,2), x(:,3));
    end
    
  case 4
    % Dealing with periodicity
    for i = 1:4
      if isequal(g.bdry{i}, @addGhostPeriodic)
        g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
      end
    end
    
    if isequal(g.bdry{1}, @addGhostPeriodic)
      for i = 1:4
        P{i} = cat(1, P{i}, P{i}(1,:,:,:));
      end
    end
    
    if isequal(g.bdry{2}, @addGhostPeriodic)
      for i = 1:4
        P{i} = cat(2, P{i}, P{i}(:,1,:,:));
      end
    end
    
    if isequal(g.bdry{3}, @addGhostPeriodic)
      for i = 1:4
        P{i} = cat(3, P{i}, P{i}(:,:,1,:));
      end
    end
    
    if isequal(g.bdry{4}, @addGhostPeriodic)
      for i = 1:4
        P{4} = cat(4, P{i}, P{i}(:,:,:,1));
      end
    end
    
    % Interpolate
    for i = 1:4
      p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, P{i}, ... 
        x(:,1), x(:,2), x(:,3), x(:,4));
    end
    
  case 6
    % Dealing with periodicity
    for i = 1:g.dim
      if isequal(g.bdry{i}, @addGhostPeriodic)
        g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
      end
    end
    
    if isequal(g.bdry{1}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(1, P{i}, P{i}(1,:,:,:,:,:));
      end
    end
    
    if isequal(g.bdry{2}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(2, P{i}, P{i}(:,1,:,:,:,:));
      end
    end
    
    if isequal(g.bdry{3}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(3, P{i}, P{i}(:,:,1,:,:,:));
      end
    end
    
    if isequal(g.bdry{4}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(4, P{i}, P{i}(:,:,:,1,:,:));
      end
    end
    
    if isequal(g.bdry{5}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(5, P{i}, P{i}(:,:,:,:,1,:));
      end
    end
    
    if isequal(g.bdry{6}, @addGhostPeriodic)
      for i = 1:6
        P{i} = cat(6, P{i}, P{i}(:,:,:,:,:,1));
      end
    end
    
    % Interpolate
    for i = 1:g.dim
      p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, g.vs{5}, ...
        g.vs{6}, P{i}, x(:,1), x(:,2), x(:,3), x(:,4), x(:,5), x(:,6));
    end
    
  otherwise
    error(['calculateCostate has not been implemented for ' ... 
      num2str(g.dim) ' dimensions!'])
end

end