function dx = dynamics(obj, t, x, u)
% function dx = dynamics(t, x, u)
%
% Dynamics of the quadrotor
%
% 2015-11-24

% Dynamics
dx = obj.A * x + obj.B * u;
end

