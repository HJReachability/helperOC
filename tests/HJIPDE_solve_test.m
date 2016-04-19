function HJIPDE_solve_test()
% HJIPDE_solve_test()
%
% Mo Chen, 2016-04-18

%% Grid
grid_min = [-5; -5; -pi];
grid_max = [5; 5; pi];
N = [51; 51; 51];
pdDims = 3;
g = createGrid(grid_min, grid_max, N, pdDims);

%% target set
R = 1;
data0 = shapeCylinder(g, 3, [0; 0; 0], R);

%% time vector
t0 = 0;
tMax = 2;
dt = 0.025;
tau = t0:dt:tMax;

%% problem parameters
speed = 1;
U = [-1 1];

%% Pack problem parameters
schemeData.grid = g;
schemeData.U = U;
schemeData.speed = speed;
schemeData.hamFunc = @dubins3DHamFunc;
schemeData.partialFunc = @dubins3DPartialFunc;

%% Compute time-dependent value function and time-to-reach value function
minWithZero = true;
[data, tau] = HJIPDE_solve(data0, tau, schemeData, minWithZero);

%% Visualize
numPlots = 4;
spC = ceil(sqrt(numPlots));
spR = ceil(numPlots / spC);

% TD function
figure;
for i = 1:numPlots
  subplot(spR, spC, i)
  ind = ceil(i * length(tau) / numPlots);
  visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
    ['TD value function, t = ' num2str(tau(ind))]);
  axis(g.axis)
  camlight left
  camlight right
end
end