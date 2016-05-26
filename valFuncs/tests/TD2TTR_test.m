function TD2TTR_test()

%% Load TD file if possible
filename = 'dubins_liveness_3D/testData.mat';
if exist(filename, 'file')
  load(filename)
else
  % Grid
  grid_min = [-1; -1; -pi];
  grid_max = [1; 1; pi];
  N = [51; 51; 51];
  pdDims = 3;
  g = createGrid(grid_min, grid_max, N, pdDims);
  
  % Initial condition and time stamps
  data0 = shapeCylinder(g, 3, [0; 0; 0], 0.2);
  tau = 0:0.005:1;
  
  % Pack problem parameters
  schemeData.grid = g;
  schemeData.U = [-1 1];
  schemeData.speed = 1;
  schemeData.hamFunc = @dubins3DHamFunc;
  schemeData.partialFunc = @dubins3DPartialFunc;
  
  minWithZero = true;
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, minWithZero);
  save(filename, 'g', 'data', 'tau')
end

%% Convert to TTR
TTR = TD2TTR(g, data, tau);

numPlots = 4;
spC = ceil(sqrt(numPlots));
spR = ceil(numPlots / spC);

%% Visualize
% TD function
figure;
for i = 1:numPlots
  subplot(spR, spC, i)
  ind = ceil(i * 0.8*length(tau) / numPlots);
  visualizeLevelSet(g, data(:,:,:,ind), 'surface', 0, ...
    ['TD value function, t = ' num2str(tau(ind))]);
  axis(g.axis)
  camlight left
  camlight right
end

% TTR function
figure;
for i = 1:numPlots
  subplot(spR, spC, i)
  ind = ceil(i * 0.8*length(tau) / numPlots);
  level = tau(ind);
  visualizeLevelSet(g, TTR, 'surface', level, ...
    ['TTR value function, ' num2str(level) ' level']);
  axis(g.axis)
  camlight left
  camlight right
end

end