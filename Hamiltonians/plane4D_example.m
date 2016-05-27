function plane4D_example()

if exist('plane4D_example.mat', 'file')
  load('plane4D_example.mat')

else
  grid_min = [-5; -10;   0;   6];
  grid_max = [15;  10; 2*pi; 12];
  N = 31*ones(4,1);
  pdDims = 3;
  
  g = createGrid(grid_min, grid_max, N, pdDims);
  
  center = [0; 0;   pi; 9];
  widths = [2; 2; pi/2; 1];
  
  data0 = shapeRectangleByCenter(g, center, widths);
  
  tMax = 1;
  dt = 0.1;
  tau = 0:dt:tMax;
  
  extraArgs.visualize = true;
  
  schemeData.grid = g;
  schemeData.wMax = 1;
  schemeData.arange = [0.5 1];
  schemeData.hamFunc = @plane4Dham;
  schemeData.partialFunc = @plane4Dpartial;
  
  data = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  
  save('plane4D_example.mat', 'g','data','tau')
end

[g3D, data3D] = proj3D(g, data(:,:,:,:,end), [0 0 0 1], 'min');

figure
visSetIm(g3D, data3D);
end