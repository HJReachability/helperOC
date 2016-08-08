function dx = dynamics(obj, t, x, u, ~, ~)
% Dynamics of the EngineOutPlane
%    Xdot = V cos(gamma) cos(xi)
%    Ydot = V cos(gamma) sin(xi)
%    Zdot = V sin(gamma)
%    Vdot = -D(alpha, V)/m - g sin(gamma)
%    gammadot = L(alpha, V) cos(phi) / (m V) - g/V cos(gamma)
%    xidot = L(alpha, V) sin(phi) / (m V cos(gamma))

% Constants
g = obj.g;
m = obj.m;

% States
X = x(1);
Y = x(2);
Z = x(3);
V = x(4);
gamma = x(5);
xi = x(6);

% Controls
alpha = u(1);
phi = u(2);

% Drag and lift
D = @obj.drag;
L = @obj.lift;

% Dynamics
xdot = V * cos(gamma) * cos(xi);
ydot = V * cos(gamma) * sin(xi);
zdot = V * sin(gamma);
Vdot = -D(alpha, V)/m - g * sin(gamma);
gammadot = L(alpha, V) * cos(phi) / (m*V) - g/V * cos(gamma);
xidot = L(alpha, V) * sin(phi) / (m * V * cos(gamma));

dx = [xdot; ydot; zdot; Vdot; gammadot; xidot];
end