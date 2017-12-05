function genericHamTest(whatTest)

if nargin<1
  whatTest = 'air3D';
end

if strcmp(whatTest, 'air3D')
  % Create grid
  N = 51;
  g = createGrid([-6 -10 0], [20 10 2*pi], N*ones(3,1), 3);  
  
  % Time stamps
  tMax = 2.6;
  dt = 0.2;
  tau = 0:dt:tMax;
  
  % Dynamical system parameters
  dynSys = Air3D([0, 0, 0], 1, 1, 5, 5); % Initial state is irrelevant here
  schemeData.grid = g;
  schemeData.dynSys = dynSys;
  
  % Target set and visualization
  data0 = shapeCylinder(g, 3, [0; 0; 0], 5);
  extraArgs.visualize = true;
  data = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  daspect([1 1 0.4])
end

%% Dubins Car
if strcmp(whatTest, 'DubinsCar')
  % Create grid
  N = 31;
  L = 10;
  g = createGrid([-L -L 0], [L L 2*pi], N*ones(3,1), 3);
  
  % Time stamps
  tMax = 1;
  dt = 0.01;
  tau = 0:dt:tMax;
  
  % Dynamical system parameters
  dCar = DubinsCar([0, 0, 0], 1, 5);
  schemeData.grid = g;
  schemeData.dynSys = dCar;
  
  % Target set and visualization
  data0 = shapeCylinder(g, 3, [0; 0; 0], 1);
  extraArgs.visualize = true;
  HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
end
end