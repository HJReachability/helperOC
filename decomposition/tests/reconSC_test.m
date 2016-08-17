function reconSC_test(full_comp)

% By default, do not do full computation
if nargin < 1
  full_comp = false;
end

%% Common parameters
% Grid
N = 31;
N = N * ones(4,1);
gMin = [-5; -5; -5; -5];
gMax = [5; 5; 5; 5];

% Acceleration bounds
aMax = [3; 3];
bMax = [3; 3];

% Time vector
dt = 0.01;
tMax = 1;
tau = 0:dt:tMax;

% Target set
tarLower = [-0.5; -inf; -0.5; -inf];
tarUpper = [0.5; inf; 0.5; inf];

uMode = 'max';
dMode = 'min';

% visualization
vslice = [2 3];
%% Decoupled computation
dims = {[1 2]; [3 4]};
sD = cell(2,1);
data = cell(2,1);
extraArgs.visualize = true;
for i = 1:2
  sD{i}.grid = createGrid(gMin(dims{i}), gMax(dims{i}), N(dims{i}));
  sD{i}.dynSys = Quad4DCAvoidX([0; 0], aMax(i), bMax(i));
  sD{i}.uMode = uMode;
  sD{i}.dMode = dMode;
  data0 = shapeRectangleByCorners(...
    sD{i}.grid, tarLower(dims{i}), tarUpper(dims{i}));
  data{i} = HJIPDE_solve(data0, tau, sD{i}, 'none', extraArgs);
end

%% Combine the two 2D sets into 4D
vfs.gs = {sD{1}.grid; sD{2}.grid};
vfs.tau = tau;
vfs.datas = data;
vfs.dims = dims;
range_lower = gMin - 1; % Full range reconstruction
range_upper = gMax + 1;
vf = reconSC(vfs, range_lower, range_upper);

% Visualize reconstructed reachable set
[g2D, reconRSet2D] = proj(vf.g, vf.data(:,:,:,:,end), [0 1 0 1], vslice);
figure
visSetIm(g2D, reconRSet2D);

% Visualize reconstructed reachable tube
RTube = min(vf.data, [], 5);
[g2D, reconRSTube2D] = proj(vf.g, RTube, [0 1 0 1], vslice);
figure
visSetIm(g2D, reconRSTube2D);

%% Full computation
if full_comp
  filename = 'reconSC_test.mat';
  
  if exist(filename, 'file')
    load(filename)
  else
    sDFull.grid = createGrid(gMin, gMax, N);
    sDFull.dynSys = Quad4DCAvoid(zeros(4,1), aMax, bMax);
    sDFull.uMode = uMode;
    sDFull.dMode = dMode;
    
    data0 = shapeRectangleByCorners(sDFull.grid, tarLower, tarUpper);
    
    EAFull.visualize = true;
    EAFull.plotData.plotDims = [1 0 1 0];
    EAFull.plotData.projpt = vslice;
    
    % Time vector (avoid using too many time-steps to save memory...)
    dt = 0.05;
    tMax = 1;
    tau = 0:dt:tMax;
    
    dataFull = HJIPDE_solve(data0, tau, sDFull, 'zero', EAFull);
    
    save(filename, 'sDFull', 'dataFull', '-v7.3')
  end
  
  [g2D, RSTube2D] = proj(sDFull.grid, dataFull(:,:,:,:,end), [0 1 0 1], vslice);
  figure
  visSetIm(g2D, RSTube2D);
  
  %% Visualize the tubes together
  figure
  h = visSetIm(g2D, reconRSTube2D);
  h.LineStyle = '--';
  h.LineWidth = 2;
  
  hold on
  visSetIm(g2D, RSTube2D, 'k');
end
end