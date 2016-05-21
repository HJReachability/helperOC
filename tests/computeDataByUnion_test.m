function computeDataByUnion_test()
% Tests the computeDataByUnion function
addpath(genpath('..'))

%% Grid
grid_min = [-5; -5; -pi];
grid_max = [5; 5; pi];
N = [75; 75; 75];
pdDim = 3;
g = createGrid(grid_min, grid_max, N, pdDim);

Nfine = [151; 151; 151];
base_g = createGrid(grid_min, grid_max, Nfine, pdDim);
%% time vector
dt = 0.025;
tIAT = 2;
tau = 0:dt:tIAT;

%% Problem parameters
schemeData.uMax = 1;
schemeData.speed = 1;
schemeData.grid = g;
schemeData.hamFunc = @dubins3Dham;
schemeData.partialFunc = @dubins3Dpartial;

schemeDataFine = schemeData;
schemeDataFine.grid = base_g;
%% Initial conditions
data0{1} = shapeCylinder(g, 3, [0; 0; 0], 0.5);
data0{2} = shapeSphere(g, -1 + 2*rand(3,1), 0.5);

%% Base reachable set
filename = ['baseBRS_' num2str(schemeData.uMax) ...
  '_' num2str(schemeData.speed) '.mat'];

if exist(filename, 'file')
  load(filename)
else
  base_data0 = shapeRectangleByCorners(base_g, -g.dx/2, g.dx/2);
  base_data = HJIPDE_solve(base_data0, tau, schemeDataFine, 'zero');
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