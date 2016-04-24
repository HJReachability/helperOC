function HJIPDE_solve_test()
% HJIPDE_solve_test()
%
% Mo Chen, 2016-04-18

%% Grid
grid_min = [-5; -5; -pi];
grid_max = [5; 5; pi];
N = [41; 41; 41];
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

%% Compute time-dependent value function
minWiths = {'none', 'zero', 'data0'};
numPlots = 4;
spC = ceil(sqrt(numPlots));
spR = ceil(numPlots / spC);
  
for i = 1:length(minWiths)
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, minWiths{i});
  
  % Visualize
  figure;
  for j = 1:numPlots
    subplot(spR, spC, j)
    ind = ceil(j * length(tau) / numPlots);
    visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
      ['TD value function, t = ' num2str(tau(ind))]);
    axis(g.axis)
    camlight left
    camlight right
    drawnow
  end
end

%% Test using single obstacle
obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
[data, tau] = HJIPDE_solve(data0, tau, schemeData, 'data0', obstacles);

% Visualize
figure;
for i = 1:numPlots
  subplot(spR, spC, i)
  ind = ceil(i * length(tau) / numPlots);
  visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
    ['TD value function, t = ' num2str(tau(ind))]);
  axis(g.axis)
  camlight left
  camlight right
  drawnow
end

%% Test using time-varying obstacle
obstacles = zeros([size(data0) length(tau)]);
for i = 1:length(tau)
  obstacles(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
end

[data, tau] = HJIPDE_solve(data0, tau, schemeData, 'data0', obstacles);

% Visualize
figure;
for i = 1:numPlots
  subplot(spR, spC, i)
  ind = ceil(i * length(tau) / numPlots);
  visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
    ['TD value function, t = ' num2str(tau(ind))]);
  axis(g.axis)
  camlight left
  camlight right
  drawnow
end
end