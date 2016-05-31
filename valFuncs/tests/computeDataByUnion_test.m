function computeDataByUnion_test(whatTest)
% Tests the computeDataByUnion function
if nargin < 1
  whatTest = 'forward';
end

% Set this to true if we only want to take the union over boundary points
bdry_only = true; 

%% Grid
grid_min = [-1; -1; 0]; % Lower corner of computation domain
grid_max = [1; 1; 2*pi];    % Upper corner of computation domain
N = 101;         % Number of grid points per dimension
pdDims = 3;               % 3rd diemension is periodic
g = createGrid(grid_min, grid_max, N*ones(3,1), pdDims);

ds = 1; % downsample factor
Nfine = max(ceil(N*2/ds), N);
grid_min_fine = [-0.7; -0.7; 0]; % Lower corner of computation domain
grid_max_fine = [0.7; 0.7; 2*pi];    % Upper corner of computation domain
base_g = createGrid(grid_min_fine, grid_max_fine, Nfine*ones(3,1), pdDims);

%% time vector
dt = 0.01;
tIAT = 0.2;
tau = 0:dt:tIAT;

%% Problem parameters
% Vehicle
speed = [0.5 1];
U = 1;
dMax = [0.1 0.2];

%% Pack problem parameters and initial conditions
schemeData.grid = g; % Grid MUST be specified!
schemeData.wMax = U;
schemeData.vrange = speed;
schemeData.dMax = dMax;

base_width = g.dx/2*ds; % Width of base target set

Rs = [0.25, 0.15]; % radii of actual target sets
data0 = cell(size(Rs));

switch whatTest
  case 'backward'
    schemeData.uMode = 'min';
    schemeData.dMode = 'min';
    schemeData.tMode = 'backward';
    
    % Target set
    data02D = cell(size(Rs));
    for i = 1:length(Rs)
      data0{i} = shapeCylinder(g, 3, [0; 0; 0], Rs(i));
      [g2D, data02D{i}] = proj2D(g, data0{i}, [0 0 1]);
    end
    
    % Base target set is a cylinder
    base_width(3) = inf;
    
    % For backward reachable set, we union over a 2D set of points, since
    % we know that the target set is a cylinder
    union_over_2D = true;
    
  case 'forward'
    schemeData.uMode = 'max';
    schemeData.dMode = 'max';
    schemeData.tMode = 'forward';
    
    % Target set
    data0{1} = shapeSphere(g, [0; 0; pi], Rs(1));
    data0{2} = shapeSphere(g, [0; 0; pi], Rs(2));

    % For forward reachable set, we take the union over a 3D set of points
    union_over_2D = false;
  otherwise
    error('Unknown test!')
end

% System dynamics
schemeData.hamFunc = @dubins3Dham;
schemeData.partialFunc = @dubins3Dpartial;

% Copy parameters to fine schemeData
schemeDataFine = schemeData;
schemeDataFine.grid = base_g;

%% Base reachable set
RSfilename = ['RS_' schemeData.tMode '_' num2str(schemeData.wMax) ...
  '_' num2str(schemeData.vrange(1)) '_' num2str(schemeData.vrange(2)) ...
  '.mat'];
base_filename = ['base_' num2str(ds) '_' RSfilename];
coarse_filename = ['coarse_' base_filename];

extraArgs.visualize = true;
%% Migrate base reachable set to coarser grid
if exist(coarse_filename, 'file')
  disp('Loading coarse base reachable set')
  load(coarse_filename)
else
  %% Compute base reachable set on fine grid if needed
  if exist(base_filename, 'file')
    disp('Loading fine base reachable set')
    load(base_filename)
  else
    disp('Computing fine base reachable set')
    
    % Base target set
    base_data0 = shapeRectangleByCorners(base_g, -base_width, base_width);
    wrap_vector = [0; 0; 2*pi];
    base_data0 = shapeUnion(base_data0, shapeRectangleByCorners(base_g, ...
      wrap_vector - base_width, wrap_vector + base_width));
    
    tic
    base_data = HJIPDE_solve( ...
      base_data0, tau, schemeDataFine, 'zero', extraArgs);
    toc
    save(base_filename, 'base_g', 'base_data', 'base_width', 'tau', '-v7.3')
  end
  % 2 5 7 11
  %% Migrate to coarse grid
  disp('Computing coarse base reachable set')
  coarse_base_data = zeros([g.N' length(tau)]);
  for i = 1:length(tau)
    coarse_base_data(:,:,:,i) = migrateGrid(base_g, base_data(:,:,:,i), g);
  end
  save(coarse_filename, 'g', 'coarse_base_data', 'base_width', 'tau')
end

for i = 1:length(data0)
  %% Compute reachable set directly
  true_filename = ['true_' num2str(Rs(i)) '_' RSfilename];
  if exist(true_filename, 'file')
    disp('Loading true reachable set')
    load(true_filename)
  else
    disp('Computing true reachable set')
    dataTrue = HJIPDE_solve(data0{i}, tau, schemeData, 'zero', extraArgs);
    save(true_filename, 'g', 'dataTrue', 'tau')
  end
  
  %% Compute reachable set by union
  disp('Computing data using union method')
  tic
  if union_over_2D
    dataUnion = computeDataByUnion(g, coarse_base_data(:,:,:,end), g2D, ...
      data02D{i}, [1 2], [], bdry_only);    
  else
    dataUnion = computeDataByUnion(g, coarse_base_data(:,:,:,end), g, ...
      data0{i}, [1 2], 3, bdry_only);
  end
  dataUnion = min(dataUnion, data0{i});
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