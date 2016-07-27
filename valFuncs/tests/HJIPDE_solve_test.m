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
%     'stopSet':   Test the functionality of stopping reacahble set
%                  computation once it contains some set
%     'plotData':  Test the functionality of plotting reachable sets as
%                  they are being computed

if nargin < 1
  whatTest = 'minWith';
end

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
wMax = 1;

%% Pack problem parameters
schemeData.grid = g; % Grid MUST be specified!

% Dynamical system parameters
dCar = DubinsCar([0, 0, 0], wMax, speed);
schemeData.grid = g;
schemeData.dynSys = dCar;

%% Compute time-dependent value function
if strcmp(whatTest, 'minWith')
  minWiths = {'none', 'zero'};
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

%% Test using time-varying targets
if strcmp(whatTest, 'tvTargets')
  targets = zeros([size(data0) length(tau)]);
  for i = 1:length(tau)
    targets(:,:,:,i) = shapeCylinder(g, 3, [1.5; 1.5; 0], i/length(tau)*R);
  end
  extraArgs.targets = targets;
  
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

%% Test using single obstacle
if strcmp(whatTest, 'singleObs')
  obstacles = shapeCylinder(g, 3, [1.5; 1.5; 0], 0.75*R);
  extraArgs.obstacles = obstacles;
  
  targets = data0;
  extraArgs.targets = targets;
  
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
  tau = linspace(0, 2, 5);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, extraOuts] = ...
    HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
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
if strcmp(whatTest, 'stopSet')
  extraArgs.stopSet = shapeSphere(g, [-1.1 1.1 0], 0.5);
  tau = linspace(0, 2, 5);
  
  numPlots = 4;
  spC = ceil(sqrt(numPlots));
  spR = ceil(numPlots / spC);
  
  [data, tau, extraOuts] = ...
    HJIPDE_solve(data0, tau, schemeData, 'none', extraArgs);
  
  % Visualize
  figure;
  for i = 1:numPlots
    subplot(spR, spC, i)
    ind = ceil(i * length(tau) / numPlots);
    visSetIm(g, extraArgs.stopSet, 'b');
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
  extraArgs.visualize = true;
  %   extraArgs.plotData.plotDims = [1, 1, 0];
  %   extraArgs.plotData.projpt = pi/2;
  tau = linspace(0, 2, 5);
  
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
end