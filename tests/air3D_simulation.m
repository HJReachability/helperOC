function air3D_simulation()
% Add code to path and load data
addpath('..')
load('air3D_simulation.mat')

% Time integration parameters

dt = 0.1;
tMax = 8;

t = 0:dt:tMax;

% Initial states
z1 = [0 0 0];
z2 = [100 1 pi];
x = dubins_relstate(z1, z2);

% Constant control for player 2
u2 = 0;

% Safety value threshold
safety_threshold = 0.1;

% Plot initial states
figure;
h1 = quiver(z1(1), z1(2), ...
  params.velocityA*cos(z1(3)), params.velocityA*sin(z1(3)), 'b'); 
hold on
h2 = quiver(z2(1), z2(2), params.velocityB*cos(z2(3)), ...
  params.velocityB*sin(z2(3)), 'r');
h1.Marker = '.';
h2.Marker = '.';
title('t = 0')
xlim([0 100])
ylim([-25 25])

drawnow;

for i = 1:length(t)
  % Safety check and control computation
  safety_value = eval_u(g, data, x);
  disp((i))
  disp(safety_value)
  
  if safety_value <= safety_threshold
    % If unsafe, compute control based on reachable set
    p = calculateCostate(g, P, x);
    
    if p(1)*x(2) - p(2)*x(1) - p(3) >= 0
      u1 = params.inputA;
    else
      u1 = -params.inputA;
    end
  else
    % If safe, just go straight
    u1 = 0;
  end
  
  disp(['u1 = ' num2str(u1)])
  % Update states
  z1 = updatePos(z1, dt, u1, params.velocityA);
  z2 = updatePos(z2, dt, u2, params.velocityB);
  x = dubins_relstate(z1, z2);
  disp(['z1 = ' num2str(z1)])
  
  % Update plots
  h1.XData = z1(1);
  h1.YData = z1(2);
  h1.UData = params.velocityA*cos(z1(3));
  h1.VData = params.velocityA*sin(z1(3));
  
  h2.XData = z2(1);
  h2.YData = z2(2);
  h2.UData = params.velocityA*cos(z2(3));
  h2.VData = params.velocityA*sin(z2(3));
  
  title(['t = ' num2str(t(i))])
  drawnow;
end
end

function xnew = updatePos(xold, dt, u, v)
% xnew = updatePos(xold, dt, u)
%
% xold: old state
% dt: time discretization size
% u: control input
%
% Assume velocity is 1
xnew = zeros(1,3);

xnew(1) = xold(1) + v*cos(xold(3))*dt;
xnew(2) = xold(2) + v*sin(xold(3))*dt;
xnew(3) = xold(3) + u*dt;

if xnew(3) >= 2*pi
  xnew(3) = xnew(3) - 2*pi;
end

if xnew(3) < 0
  xnew(3) = xnew(3) + 2*pi;
end
end