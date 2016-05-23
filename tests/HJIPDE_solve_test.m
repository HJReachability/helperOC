function HJIPDE_solve_test(whatTest)
% HJIPDE_solve_test()
%
% Tests the HJIPDE_solve function as well as provide an example of how to
% use it.
%
% whatTest - Argument that can be used to test a particular feature
%   'minWith' - Test the minWith functionality
%   'singleObs' - Test with a single static obstacle
%   'tvObs' - Test with time-verying obstacles
%   'multiObs' - Test with a single obstacle over different time steps
%   'stopInit' - Test the functionality of stopping reachable set
%   computation once it includes the initial state
%   'plotData' - Test the functionality of plotting reachable sets as they
%   are being computed
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
addpath ./dubins_liveness_3D
schemeData.hamFunc = @dubins3DHamFunc;
schemeData.partialFunc = @dubins3DPartialFunc;

%% Compute time-dependent value function
if strcmp(whatTest, 'minWith')
  minWiths = {'none', 'zero', 'data0'};
  % selecting 'zero' computes reachable tube (usually, choose this option)
  % selecting 'none' computes reachable set
  % selecting 'data0' computes reachable tube, but only use this if there are
  %   obstacles (constraint/avoid sets) in the state space
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  for i = 1:length(minWiths)
    [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, minWiths{i});
    
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
end
% In practice, most of the time, the above for loop is not needed, and the
% code below is also not needed. Simply select an minWith option, and then
% also input obstacles if they are present.

% Change visualization code as necessary

%% Test using single obstacle
if strcmp(whatTest, 'singleObs')
  obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
  extraargs.obstacles = obstacles;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'data0', extraargs);
  
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

%% Test using time-varying obstacle
if strcmp(whatTest, 'tvObs')
  obstacles = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    obstacles(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraargs.obstacles = obstacles;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'data0', extraargs);
  
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

%% Test using single obstacle but few time steps
if strcmp(whatTest, 'multiObs')
  obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
  tau = linspace(0, 2, 5);
  extraargs.obstacles = obstacles;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'data0', extraargs);
  
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

%% Test the inclusion of initial state
if strcmp(whatTest, 'stopInit')
  extraargs.stopInit.initState = [-1.1, -1.1, 0]';
  tau = linspace(0, 2, 5);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, extraOuts] = HJIPDE_solve(data0, tau, schemeData, 'data0', extraargs);
  
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

%% Test the intermediate plotting
if strcmp(whatTest, 'plotData')
  extraargs.plotData.plotDims = [1, 1, 0];
  extraargs.plotData.projpt = pi/2;
  tau = linspace(0, 2, 5);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, extraOuts] = HJIPDE_solve(data0, tau, schemeData, 'data0', extraargs);
  
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
end