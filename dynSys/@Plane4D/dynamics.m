function dx = dynamics(obj, t, x, u)
% Dynamics of the Plane4
%    \dot{x}_1 = v_x = x_4 * cos(x_3)
%    \dot{x}_2 = v_y = x_4 * sin(x_3)
%    \dot{x}_3 = u_2 = u_2
%    \dot{x}_4 = u_1 = u_1
%

dx = zeros(obj.nx, 1);

dx(1) = x(4) * cos(x(3));
dx(2) = x(4) * sin(x(3));
dx(3) = u(1);
dx(4) = u(2);

end