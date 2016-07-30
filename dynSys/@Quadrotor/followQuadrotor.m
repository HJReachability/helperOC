function u = followQuadrotor(obj, other, tsteps)
% ------ UNUSED??? ----
% 
% function u = followQuadrotor(obj, other, tsteps)
%
% Follows the "other" quadrotor with a look-ahead horizon of tsteps time
% steps.
% 
% Inputs:  obj    - this quadrotor object
%          other  - other quadrotor object
%          tsteps - number of time steps to look-ahead
%
% Output:  u      - control signal to use at the current time step
%
% Mo Chen, 2015-05-23


% minDist = min((other.xhist(1,:) - obj.x(1)).^2 + (other.xhist(2,:) - obj.x(2)).^2);

rpath = @(s) [(1-s)*obj.x(1) + s*other.x(1); (1-s)*obj.x(3) + s*other.x(3)];
u = obj.followPath(tsteps, rpath);

end