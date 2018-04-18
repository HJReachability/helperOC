function Plane4D_test()
% Plane_test()
%   Tests the Plane class by computing a reachable set and then computing the
%   optimal trajectory from the reachable set.

%% Plane parameters
initState = [100; 75; 180*pi/180; 1.25];
wMax = 0.5;
aRange = [-0.5; 0.5];
dMax = [0; 0];
pl4D = Plane4D(initState, wMax, aRange, dMax);

%% Target and obstacles
g = createGrid([0; 0; 0; -5], [150; 150; 2*pi; 10], [25; 25; 25; 25], 3);
target = shapeCylinder(g, [3 4], [75; 50; 0; 0], 10);

obs = shapeRectangleByCorners( ...
  g, [5; 5; -inf; -inf], [145; 145; inf; inf]);
obs = -obs;

%% Compute reachable set
tau = 0:0.5:500;

schemeData.dynSys = pl4D;
schemeData.grid = g;
schemeData.uMode = 'min';
schemeData.dMode = 'max';

extraArgs.targets = target;
extraArgs.obstacles = obs;
extraArgs.stopInit = pl4D.x;
extraArgs.visualize = true;
extraArgs.plotData.plotDims = [1 1 0 0];
extraArgs.plotData.projpt = pl4D.x(3:4);
extraArgs.deleteLastPlot = true;

[data, tau2] = HJIPDE_solve(target, tau, schemeData, 'none', extraArgs);

save(sprintf('%s.mat', mfilename), 'data', 'tau2');

%% Compute optimal trajectory
extraArgs.projDim = [1 1 0 0];
[traj, traj_tau] = computeOptTraj(g, flip(data,5), tau2, pl4D, extraArgs);


end