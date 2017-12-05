function HJIPDE_solve_test(whatTest)
% HJIPDE_solve_test(whatTest)
%   Tests the HJIPDE_solve function as well as provide an example of how to
%   use it.
%
% whatTest - Argument that can be used to test a particular feature
%     'minWith':   Test the minWith functionality
%     'tvTargets': Test the time-varying targets
%     'singleObs': Test with a single static obstacle
%     'tvObs':     Test with time-varying obstacles
%     'obs_stau':  single obstacle over a few time steps
%     'stopInit':  Test the functionality of stopping reachable set
%                  computation once it includes the initial state
%     'stopSetInclude':
%         Test the functionality of stopping reacahble set computation once it
%         contains some set
%     'stopSetIntersect':
%         Test the functionality of stopping reacahble set computation once it
%         intersects some set
%     'plotData':  Test the functionality of plotting reachable sets as
%                  they are being computed

if nargin < 1
  whatTest = 'minWith';
end

%% Grid
grid_min = [-5; -5; -pi]; % Lower corner of computation domain
grid_max = [5; 5; pi];    % Upper corner of computation domain
N = [41; 41; 41];         % Number of grid points per dimension
pdDims = 3;               % 3rd dimension is periodic
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
wMax = 1;

%% Pack problem parameters
% Dynamical system parameters
dCar = DubinsCar([0, 0, 0], wMax, speed);
schemeData.grid = g;
schemeData.dynSys = dCar;

%% Compute time-dependent value function
if strcmp(whatTest, 'minWith')
  minWiths = {'none', 'zero'};
  % selecting 'zero' computes reachable tube (usually, choose this option)
  % selecting 'none' computes reachable set
  % selecting 'target' computes reachable tube, but only use this if there are
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

%% Test using time-varying targets
if strcmp(whatTest, 'tvTargets')
  % Specify targets
  targets = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    targets(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraArgs.targets = targets;
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  % Visualize
  figure;
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
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

%% Test using single obstacle
if strcmp(whatTest, 'singleObs')
  obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
  extraArgs.obstacles = obstacles;
  
  targets = data0;
  extraArgs.targets = targets;
  extraArgs.visualize = true;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
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
  extraArgs.obstacles = obstacles;
  
  targets = data0;
  extraArgs.targets = targets;
  
  extraArgs.visualize = true;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, ~] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
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
if strcmp(whatTest, 'obs_stau')
  obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
  tau = linspace(0, 2, 5);
  extraArgs.obstacles = obstacles;
  
  targets = data0;
  extraArgs.targets = targets;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
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
  extraArgs.stopInit = [-1.1, -1.1, 0];
  tau = linspace(0, 2, 50);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  extraArgs.visualize = true;
  extraArgs.deleteLastPlot = true;
  extraArgs.plotData.plotDims = [1 1 0];
  extraArgs.plotData.projpt = extraArgs.stopInit(3);
  [data, tau, extraOuts] = ...
    HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  % Visualize
  figure;
  for i = 1:numPlots
    subplot(spR, spC, i)
    ind = ceil(i * length(tau) / numPlots);
    h = visSetIm(g, data(:,:,:,ind));
    h.FaceAlpha = 0.5;
    axis(g.axis)
    title(['TD value function, t = ' num2str(tau(ind))]);
    
    hold on
    plot3(extraArgs.stopInit(1), ...
      extraArgs.stopInit(2), extraArgs.stopInit(3), '*')
    
    camlight left
    camlight right
    drawnow
  end
  
  val = eval_u(g, data(:,:,:,end), extraArgs.stopInit);
  fprintf('Value at initial condition is %f\n', val)
end

%% Test the inclusion of some set
if strcmp(whatTest, 'stopSetInclude')
  extraArgs.stopSetInclude = shapeSphere(g, [-1.1 1.1 0], 0.5);
  tau = linspace(0, 2, 5);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  % Visualize
  figure;
  for i = 1:numPlots
    subplot(spR, spC, i)
    ind = ceil(i * length(tau) / numPlots);
    visSetIm(g, extraArgs.stopSetInclude, 'b');
    h = visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
      ['TD value function, t = ' num2str(tau(ind))]);
    h.FaceAlpha = 0.6;
    axis(g.axis)
    camlight left
    camlight right
    drawnow
  end
end

%% Test intersection of some set
if strcmp(whatTest, 'stopSetIntersect')
  extraArgs.stopSetIntersect = shapeSphere(g, [-1.25 1.25 0], 0.5);
  tau = linspace(0, 1, 11);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  % Visualize
  figure;
  for i = 1:numPlots
    subplot(spR, spC, i)
    ind = ceil(i * length(tau) / numPlots);
    visSetIm(g, extraArgs.stopSetIntersect, 'b');
    h = visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
      ['TD value function, t = ' num2str(tau(ind))]);
    h.FaceAlpha = 0.6;
    axis(g.axis)
    camlight left
    camlight right
    drawnow
  end
end

%% Test the intermediate plotting
if strcmp(whatTest, 'plotData')
  tau = linspace(0, 2, 51);
  
  extraArgs.visualize = true;
  extraArgs.plotData.plotDims = [1, 1, 0];
  extraArgs.plotData.projpt = -3*pi/4;
  extraArgs.deleteLastPlot = true;
  
  % Moving obstacles
  obstacles = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    obstacles(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraArgs.obstacles = obstacles;
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, extraOuts] = HJIPDE_solve(data0, tau, schemeData, 'none', ...
    extraArgs);
  
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

%% Test starting from saved data (where data0 has dimension g.dim + 1)
if strcmp(whatTest, 'savedData')
  % Compute data1
  extraArgs.visualize = true;
  data1 = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  
  % Cut off data1 at tcutoff
  tcutoff = 0.5;
  dataSaved = data1;
  dataSaved(:, :, :, tau>tcutoff) = 0;
  extraArgs.istart = nnz(tau<=tcutoff) + 1;
  
  % Continue computing
  data2 = HJIPDE_solve(dataSaved, tau, schemeData, 'zero', extraArgs);
  
  % Plot the two results and compare
  figure;
  h1 = visSetIm(g, data1(:,:,:,end));
  h1.FaceAlpha = 0.5;
  hold on
  h2 = visSetIm(g, data2(:,:,:,end), 'b');
  h2.FaceAlpha = 0.5;
  
  % Display error
  disp(['Computation from saved data differs from full computation by ' ...
    'an error of ' num2str(sum((data1(:) - data2(:)).^2))])
end

if strcmp(whatTest, 'stopConverge')
  % Parameters
  N = 61*ones(3,1);
  grid_min = [-25; -20; 0];
  grid_max = [25; 20; 2*pi];
  pdDims = 3;
  
  va = 5;
  vb = 5;
  uMax = 1;
  dMax = 1;
  
  captureRadius = 5;
  
  g = createGrid(grid_min, grid_max, N, pdDims);
  data0 = shapeCylinder(g, 3, [0;0;0], captureRadius);
  dynSys = DubinsCarCAvoid([0;0;0], uMax, dMax, va, vb); 
  
  tMax = 5;
  dt = 0.01;
  tau = 0:dt:tMax;
  
  schemeData.grid = g;
  schemeData.dynSys = dynSys;
  schemeData.uMode = 'max';
  schemeData.dMode = 'min';
  
  extraArgs.stopConverge = true;
  extraArgs.convergeThreshold = 1e-3;
  extraArgs.visualize = true;
  extraArgs.deleteLastPlot = true;
  data = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
end

%% Low memory mode
if strcmp(whatTest, 'low_memory')
  obstacles = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    obstacles(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraArgs.obstacles = obstacles;  
  extraArgs.quiet = true;
  
  tic
  data_normal = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  fprintf('Normal mode time: %f seconds\n', toc)
  
  extraArgs.low_memory = true;
  tic
  data_low_mem = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  fprintf('Low memory mode time: %f seconds\n', toc)
  
  error = max(abs(data_normal(:) - data_low_mem(:)));
  fprintf('Error = %f\n', error)
end

%% flip outputs in low memory mode
if strcmp(whatTest, 'flip_output')
  obstacles = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    obstacles(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraArgs.obstacles = obstacles;  
  extraArgs.quiet = true;
  
  tic
  data_normal = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  fprintf('Normal mode time: %f seconds\n', toc)
  
  extraArgs.flip_output = true;
  extraArgs.low_memory = true;
  tic
  data_low_mem = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  fprintf('Low memory mode time: %f seconds\n', toc)
  data_low_mem = flip(data_low_mem, 4);
  
  error = max(abs(data_normal(:) - data_low_mem(:)));
  fprintf('Error = %f\n', error)
  
  figure
  subplot(1,2,1)
  visSetIm(g, data_normal);
  subplot(1,2,2)
  visSetIm(g, data_low_mem);
end
end