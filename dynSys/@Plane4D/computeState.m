function x1 = computeState(obj, u, x0, T)
% function x1 = computeState(obj, u, x0)
% Computes (DOES NOT update!) state based on control; use updateState to
% update the state
%
% Inputs:   obj - current plane object
%           u   - control (defaults to previous control)
%           x0  - initial state (defaults to current state)
%
% Outputs:  x1  - final state
%
% Mahesh Vashishtha, 2015-12-3

% If no control is specified, use previous control
if nargin  < 2
  u = obj.u;
end

if nargin < 3
  x0 = obj.x;
end

% Forward euler (unstable for large dt)
x1 = x0 + T * dynamics(obj, T, x0, u);
end