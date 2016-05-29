function fillInMissingDims_test()

% Number of grid points in each dimension
N = 51;

%% 2D grid
low_dim = 2;
low_grid_min = -10*ones(low_dim, 1);
low_grid_max = 10*ones(low_dim, 1);
g2D = createGrid(low_grid_min, low_grid_max, N);

%% 2D data (random rectangle)
rectLower = -10 + 5*rand(low_dim,1);
rectUpper = rectLower + 5 + 10*rand(low_dim, 1);
data2D = shapeRectangleByCorners(g2D, rectLower, rectUpper);

%% Visualize 2D
figure
visSetIm(g2D, data2D, 'r');

%% 4D grid
full_dim = 4;
full_grid_min = -10*ones(full_dim, 1);
full_grid_max = 10*ones(full_dim, 1);
gFull = createGrid(full_grid_min, full_grid_max, N);

%% 4D data
dataDim1 = randi(3);
dataDim2 = dataDim1 + randi(full_dim-dataDim1);
dataDim = [dataDim1 dataDim2]
dataFull = fillInMissingDims(gFull, data2D, dataDim);

for sliceDim = 1:4
  figure
  visSetIm(gFull, dataFull, 'r', 0, sliceDim);
end


end