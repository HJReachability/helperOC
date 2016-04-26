function HJIPDE_solve_test()
% HJIPDE_solve_test()
% 
% Tests the HJIPDE_solve function as well as provide an example of how to
% use it.
%
% Mo Chen, 2016-04-18

%% Grid
grid_min = [-5; -5; -pi]; % Lower corner of computation domain
grid_max = [5; 5; pi];    % Upper corner of computation domain
N = [41; 41; 41];         % Number of grid points per dimension
pdDims = 3;               % 3rd diemension is periodic
g = createGrid(grid_min, grid_max, N, pdDims);
% Use "g = createGrid(grid_min, grid_max, N);" if there are no periodic
% state space dimensions

%% target set
R = 1;
data0 = shapeCylinder(g, 3, [0; 0; 0], R);
% also try shapeRectangleByCorners, shapeSphere, etc.

%% time vector
t0 = 0;
tMax = 2;
dt = 0.025;
tau = t0:dt:tMax;
% If intermediate results are not needed, use tau = [t0 tMax];

%% problem parameters
speed = 1;
U = [-1 1];

%% Pack problem parameters
schemeData.grid = g; % Grid MUST be specified!
schemeData.U = U;
schemeData.speed = speed;

% ----- System dynamics are specified here -----
schemeData.hamFunc = @dubins3DHamFunc;
schemeData.partialFunc = @dubins3DPartialFunc;

%% Compute time-dependent value function
minWiths = {'none', 'zero', 'data0'};
% selecting 'zero' computes reachable tube (usually, choose this option)
% selecting 'none' computes reachable set
% selecting 'data0' computes reachable tube, but only use this if there are
%   obstacles (constraint/avoid sets) in the state space

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

% In practice, most of the time, the above for loop is not needed, and the
% code below is also not needed. Simply select an minWith option, and then
% also input obstacles if they are present.

% Change visualization code as necessary

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