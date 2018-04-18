function Plane_test()
% Plane_test()
%   Tests the Plane class by computing a reachable set and then computing the
%   optimal trajectory from the reachable set.

%% Plane parameters
initState = [100; 75; 220*pi/180];
wMax = 1.2;
vrange = [1.1, 1.3];
dMax = [0; 0];
pl = Plane(initState, wMax, vrange, dMax);

%% Target and obstacles
g = createGrid([0; 0; 0], [150; 150; 2*pi], [41; 41; 11]);
target = shapeCylinder(g, 3, [75; 50; 0], 10);
obs1 = shapeRectangleByCorners(g, [300; 250; -inf], [350; 300; inf]);
obs2 = shapeRectangleByCorners(g, [5; 5; -inf], [145; 145; inf]);
obs2 = -obs2;
obstacle = min(obs1, obs2);

%% Compute reachable set
tau = 0:0.5:500;

schemeData.dynSys = pl;
schemeData.grid = g;
schemeData.uMode = 'min';
schemeData.dMode = 'max';

extraArgs.targets = target;
extraArgs.obstacles = obstacle;
extraArgs.stopInit = pl.x;
extraArgs.visualize = true;
extraArgs.plotData.plotDims = [1 1 0];
extraArgs.plotData.projpt = pl.x(3);
extraArgs.deleteLastPlot = true;

[data, tau2] = HJIPDE_solve(target, tau, schemeData, 'none', extraArgs);

%% Compute optimal trajectory
extraArgs.projDim = [1 1 0];
[traj, traj_tau] = computeOptTraj(g, flip(data,4), tau2, pl, extraArgs);


end