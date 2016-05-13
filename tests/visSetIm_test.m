function visSetIm_test()
% Tests the visSetIm() function
addpath('..')

%% Level, color, list of dimensions, list of grid points to use
level = 0;
color = 'r';
dims = 2:4;
Ns = [101 75 41]; % Number of grid points for visualization
for i = 1:length(dims)
  figure
  
  %% Create a grid
  grid_min = -10 * ones(dims(i), 1);
  grid_max = 10 * ones(dims(i), 1);
  g = createGrid(grid_min, grid_max, Ns(i));

  %% Create a random sphere
  Scenter = -5 + 10*rand(dims(i),1);
  Sradius = 3 + 2*rand;
  dataS = shapeSphere(g, Scenter, Sradius);
  
  %% Create a random rectangle
  Rcenter = -5 + 10*rand(dims(i),1);
  Rwidths = 3 + 2*rand(dims(i),1);
  dataR = shapeRectangleByCenter(g, Rcenter, Rwidths);

  %% Take the union and visualize
  data = shapeUnion(dataS, dataR);
  
  if dims(i) == 4
    sliceDim = randi(4);
    visSetIm(g, data, color, level, sliceDim);
  else
    visSetIm(g, data, color, level);
  end

end

end