function computeOptTraj_test(whatTest)
if nargin < 1
  whatTest = 'DubinsCar';
end

if strcmp(whatTest, 'DubinsCar')
  %% Grid
  grid_min = [-1; -1; -3*pi/2];
  grid_max = [1; 1; pi/2];
  grid_N = [41; 41; 41];
  g = createGrid(grid_min, grid_max, grid_N, 3);
  dynSys = DubinsCar([-0.75; 0.3; 0], 1, 1);
  
  %% Compute BRS
  schemeData.grid = g;
  schemeData.dynSys = dynSys;
  schemeData.uMode = 'min';
  tau = 0:0.025:5;
  data0 = shapeCylinder(g, 3, [0.7; -0.7; 0], 0.05);
  extraArgs.stopInit = dynSys.x;
  
  obstacles = ones([size(data0) length(tau)]);
  for i = 1:length(tau)
    %   obstacles(:,:,:,i) = shapeCylinder(g, 3, [-0.2; 0; 0], ...
    %     0.2*(length(tau)-i)/length(tau));
    if tau(i) < 0.3
      obstacles(:,:,:,i) = ...
        shapeRectangleByCorners(g, [0.5; -inf; -inf], [0.6; inf; inf]);
    end
  end
  extraArgs.obstacles = obstacles;
  
  extraArgs.visualize = true;
  extraArgs.deleteLastPlot = true;
  extraArgs.targets = data0;
  
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  tau = -flip(tau);
  data = flip(data, g.dim+1);
  
  %% Compute trajectory
  extraArgs.projDim = [1 1 0];
  extraArgs.save_png = true;
  [traj, traj_tau] = computeOptTraj(g, data, tau, dynSys, extraArgs);
  fprintf('Length of traj = %d; length of traj_tau = %d\n', size(traj, 2), ...
    length(traj_tau))
end

if strcmp(whatTest, 'Plane')
  %% Grid
  grid_min = [-1; -1; -3*pi/2];
  grid_max = [1; 1; pi/2];
  grid_N = [95; 95; 95];
  g = createGrid(grid_min, grid_max, grid_N, 3);
  dynSys = Plane([-0.5; 0; 0], 0.6, [0.75 0.75]);
  
  %% Compute BRS
  schemeData.grid = g;
  schemeData.dynSys = dynSys;
  schemeData.uMode = 'min';
  tau = -5:0.01:0;
  data0 = shapeCylinder(g, 3, [0.7; 0.2; 0], 0.025);
  extraArgs.stopInit = dynSys.x;

  extraArgs.visualize = true;
  extraArgs.deleteLastPlot = true;
  extraArgs.targets = data0;
  
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  tau = -flip(tau);
  data = flip(data, g.dim+1);
  
  %% Compute trajectory
  extraArgs.projDim = [1 1 0];
  extraArgs.save_png = true;
  computeOptTraj(g, data, tau, dynSys, extraArgs);
end

if strcmp(whatTest, 'SPP')
  load('computeNIRS_test', 'Q1')
  grid_min = [-1; -1; -3*pi/2];
  grid_max = [1; 1; pi/2];
  grid_N = [101; 101; 101];
  g = createGrid(grid_min, grid_max, grid_N, 3);
  
  dynSys = Plane(Q1.x, 0.6, [0.75 0.75]);
  extraArgs.visualize = true;
  extraArgs.projDim = [1 1 0];
  computeOptTraj(g, Q1.BRS1, Q1.BRS1_tau, dynSys, extraArgs);
end

end