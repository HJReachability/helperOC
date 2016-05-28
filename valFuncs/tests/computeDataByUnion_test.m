function computeDataByUnion_test()
% Tests the computeDataByUnion function

%% Grid
grid_min = [-1; -1; 0]; % Lower corner of computation domain
grid_max = [1; 1; 2*pi];    % Upper corner of computation domain
N = [101; 101; 101];         % Number of grid points per dimension
pdDims = 3;               % 3rd diemension is periodic
g = createGrid(grid_min, grid_max, N, pdDims);

Nfine = [201; 201; 201];
grid_min_fine = [-0.6; -0.25; 0]; % Lower corner of computation domain
grid_max_fine = [0.15; 0.25; 2*pi];    % Upper corner of computation domain
base_g = createGrid(grid_min_fine, grid_max_fine, Nfine, pdDims);

%% time vector
dt = 0.01;
tIAT = 0.5;
tau = 0:dt:tIAT;

%% Problem parameters
% Vehicle
speed = [0.5 1];
U = 1;
dMax = [0.1 0.2];

%% Pack problem parameters
schemeData.grid = g; % Grid MUST be specified!
schemeData.wMax = U;
schemeData.vrange = speed;
schemeData.dMax = dMax;
schemeData.uMode = 'min';
schemeData.dMode = 'min';
schemeData.tMode = 'backward';

% System dynamics
schemeData.hamFunc = @dubins3Dham;
schemeData.partialFunc = @dubins3Dpartial;

schemeDataFine = schemeData;
schemeDataFine.grid = base_g;
%% Initial conditions
% data0{1} = shapeCylinder(g, 3, [0; 0; 0], 0.5);
data0{1} = shapeSphere(g, [0; 0; 0], 0.25);

%% Base reachable set
filename = ['baseRS_' schemeData.tMode '_' num2str(schemeData.wMax) ...
  '_' num2str(schemeData.vrange(1)) '_' num2str(schemeData.vrange(2)) ...
  '.mat'];

if exist(filename, 'file')
  load(filename)
else
  base_data0 = shapeRectangleByCorners(base_g, -g.dx/2, g.dx/2);
  wrap_vector = [0; 0; 2*pi];
  base_data0 = shapeUnion(base_data0, shapeRectangleByCorners(base_g, ...
    wrap_vector - g.dx/2, wrap_vector + g.dx/2));
  
  extraArgs.plotData.plotDims = [1, 1, 1];
  extraArgs.plotData.projpt = [];
  
  base_data = HJIPDE_solve(base_data0, tau, schemeDataFine, 'zero', extraArgs);
  save(filename, 'base_g', 'base_data', '-v7.3')
end

for i = 1:length(data0)
  %% Compute reachable set directly
  dataTrue = HJIPDE_solve(data0{i}, tau, schemeData, 'zero');
  
  %% Compute reachable set by union
  tic
  dataUnion = computeDataByUnion(base_g, base_data(:,:,:,end), g, data0{i});
  toc

  %% Visualize
  figure
  hT = visSetIm(g, dataTrue(:,:,:,end));
  hT.FaceAlpha = 0.5;

  hold on
  hU = visSetIm(g, dataUnion, 'b');
  hU.FaceAlpha = 0.5;
end

end