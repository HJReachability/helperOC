function p = calculateCostate(g, P, x)
% function p = calculateCostate(g, P, x)
%
% Calculates the gradient (costate) at x given an array of gradients stored
% in P. Periodicity is automatically checked in eval_u
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
% Updated 2016-02-20

% Check input
p = zeros(size(x,1), g.dim);

% Interpolate gradient
for i = 1:g.dim
  p(i) = eval_u(g, P{i}, x);
end

end