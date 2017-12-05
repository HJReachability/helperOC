function dx = dynamics(obj, t, x, u, ~, ~)
% Dynamics of the 2D kinematic vehicle
%    \dot{x}_1 = v_x
%    \dot{x}_2 = v_y
%        u = (v_x, v_y)

dx = u;

end