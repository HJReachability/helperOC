function TD2TTR_test()

%% Load TD file if possible
filename = 'TD2TTR_test.mat';
if exist(filename, 'file')
  load(filename)
else
  % Grid
  grid_min = [-1; -1];
  grid_max = [1; 1];
  N = [101; 101];
  g = createGrid(grid_min, grid_max, N);
  
  % Initial condition and time stamps
  data0 = shapeCylinder(g, 3, [0; 0; 0], 0.2);
  tau = 0:0.005:1;
  
  % Pack problem parameters
  schemeData.grid = g;
  schemeData.dynSys = DoubleInt([0; 0], [-1 1]);
  schemeData.uMode = 'min';
  
  extraArgs.visualize = true;
  [data, tau] = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  save(filename, 'g', 'data', 'tau')
end

%% Convert to TTR
TTR = TD2TTR(g, data, tau);

%% Visualize
numLevels = 4;
timesToPlot = rand(numLevels,1);

colors = hsv(numLevels);

figure;
for i = 1:numLevels
  % TD function
  t = timesToPlot(i);
  ind = find(tau>=t, 1, 'first');
  h = visSetIm(g, data(:,:,ind));
  h.LineStyle = '--';
  h.LineWidth = 3;
  
  hold on
  
  % TTR function
  visSetIm(g, TTR, colors(i,:), t);
end

end