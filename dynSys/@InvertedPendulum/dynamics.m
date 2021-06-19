function dx = dynamics(obj, t, x, u, d)

    l = obj.l;    % [m]        length of pendulum
    m = obj.m;    % [kg]       mass of pendulum
    g = obj.g; % [m/s^2]    acceleration of gravity
    b = obj.b; % [s*Nm/rad] friction coefficient

if iscell(x)
  dx = cell(obj.nx, 1);

   f1 = x{2};
   f2 = (-b*x{2} + m*g*l*sin(x{1})/2 ) / (m*l^2/3);
   g1 = 0;
   g2 = -1 / (m*l^2/3);
   
  dx{1} = f1 + g1.*u;
  dx{2} = f2 + g2.*u;
else
  dx = zeros(obj.nx, 1);
  
  f1 = x(2);
  f2 = (-b*x(2) + m*g*l*sin(x(1))/2 ) / (m*l^2/3);
  g1 = 0;
  g2 = -1 / (m*l^2/3);
   
  dx(1) = f1 + g1.*u;
  dx(2) = f2 + g2.*u;
end


end