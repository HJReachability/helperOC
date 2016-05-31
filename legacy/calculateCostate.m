function p = calculateCostate(g, P, x)
% function p = calculateCostate(g, P, x)
%   This function is no longer needed... simply use eval_u(g, P, x).
%   Calculates the gradient (costate) at x given an array of gradients 
%   stored in P. Periodicity is automatically checked in eval_u.
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
% Updated 2016-05-18

% Interpolate gradient
p = eval_u(g, P, x);

end