function visSetIm_test()
addpath('..')

level = 0;
color = 'r';
dims = 2:4;
Ns = [101 75 41]; % Number of grid points for visualization
for i = 1:length(dims)
  figure
  grid_min = -10 * ones(dims(i), 1);
  grid_max = 10 * ones(dims(i), 1);
  g = createGrid(grid_min, grid_max, Ns(i));

  Scenter = -5 + 10*rand(dims(i),1);
  Sradius = 3 + 2*rand;
  dataS = shapeSphere(g, Scenter, Sradius);
  
  Rcenter = -5 + 10*rand(dims(i),1);
  Rwidths = 3 + 2*rand(dims(i),1);
  dataR = shapeRectangleByCenter(g, Rcenter, Rwidths);

  data = shapeUnion(dataS, dataR);
  
  if dims(i) == 4
    sliceDim = randi(4);
    visSetIm(g, data, color, level, sliceDim);
  else
    visSetIm(g, data, color, level);
  end

end

end