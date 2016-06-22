function nearLevel = getNearLevel(g, data, grad, levelIn, maxDist)
% nearLevel = getNearLevel(g, data, grad, level, maxDist)
%     computes the level curve of the value function data that is within a
%     maximum distance of maxDist away from the specified level levelIn
%
% Inputs:
%     g, data, grad - grid, value function, and gradient of the value function
%     levelIn       - level of the value function to look at
%     maxDist       - maximum distance from the specified level
%
% Output:
%     nearLevel     - the level that is within maxDist away from levelIn
%

if nargin < 4
  levelIn = 0;
end

if nargin < 5
  maxDist = min(g.dx/2);
end

if ~iscolumn(maxDist)
  maxDist = maxDist';
end

% find all indices near the specified level
inds = find(isNearInterface(data, levelIn));

grads = zeros(length(inds), g.dim);
for i = 1:g.dim
  grads(:, i) = grad{i}(inds);
end

% find maximum gradient in each component at the specified indices
gradMax = max( sqrt(sum(grads.^2, 2)) );

% value = gradient * distance; nearLevel is minimum over the dimensions
nearLevel = gradMax * maxDist;

end
