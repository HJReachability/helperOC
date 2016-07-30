function dx = dynamics(obj, t, x, u)
% dx = dynamics(obj, t, x, u)
% Dynamics of the Quadrotor12D
%     \dot x_1  = x_4
%     \dot x_2  = x_5
%     \dot x_3  = x_6
%     \dot x_4  = -(\cos x_7 \sin x_8 \cos x_9 + \sin x_7 \sin x_9) u_1/m
%     \dot x_5  = -(\cos x_7 \sin x_8 \sin x_9 - \sin x_7 \cos x_9) u_1/m
%     \dot x_6  = g - (\cos x_7 \cos x_8) u_1/m
%     \dot x_7  = x_10 + \sin x_7 \tan(x_8) x_11 + \cos x_7 \tan(x_8) x_12
%     \dot x_8  = \cos x_7 x_11 - \sin x_7 x_12
%     \dot x_9  = (\sin x_7/\cos x_8)*x_11 + (\cos x_7/\cos x_8) x_12
%     \dot x_10 = x_11 x_12 (I_y - I_z)/I_x + L/I_x u_2
%     \dot x_11 = x_10 x_12 (I_z - I_x)/I_y + L/I_y u_3
%     \dot x_12 = x_10 x_11 (I_x - I_y)/I_z + 1/I_z u_4

if numel(u) ~= obj.nu
  error('Incorrect number of control dimensions!')
end

g = obj.g;
m = obj.m;
I = obj.I;
Ix = I(1);
Iy = I(2);
Iz = I(3);

dx = zeros(obj.nx, 1);

% Kinematic plane (speed can be changed instantly)
dx(1) = x(4);
dx(2) = x(5);
dx(3) = x(6);
dx(4) = -( cos(x(7))*sin(x(8))*cos(x(9)) + ...
           sin(x(7))*sin(x(9)) ...
           )*u(1)/m;
dx(5) = -( cos(x(7))*sin(x(8))*sin(x(9)) - ...
           sin(x(7))*cos(x(9)) ...
           )*u(1)/m;
dx(6) = g - ( cos(x(7))*cos(x(8)) ...
              )*u(1)/m;
dx(7) = x(10) + sin(x(7))*tan(x(8))*x(11) + cos(x(7))*tan(x(8))*x(12);
dx(8) = cos(x(7))*x(11) - sin(x(7))*x(12);
dx(9) = sin(x(7))/cos(x(8))*x(11) + cos(x(7))/cos(x(8))*x(12);
dx(10) = x(11)*x(12)*(Iy-Iz)/Ix + L/Ix*u(2);
dx(11) = x(10)*x(12)*(Iz-Ix)/Iy + L/Iy*u(3);
dx(12) = x(10)*x(11)*(Ix-Iy)/Iz + 1/Iz*u(4);

end