function MIE2Implicit_test()
% Tests the MIE2Implicit() function

addpath('..')

% Dimensions to test, and # of grid points for each dimension
dims = 2:4;
Ns = [101 75 41];

for i = 1:length(dims)
  %% MIE Value function
  grid_min = -10*ones(dims(i)-1, 1);
  grid_max = 10*ones(dims(i)-1, 1);
  N = Ns(dims(i)-1)*ones(dims(i)-1, 1);
  gMIE = createGrid(grid_min, grid_max, N);
  
  lower = -10 + 12*rand(dims(i),1);
  upper = lower + 5 + 5*rand(dims(i),1);
  upper = min(9*ones(dims(i),1), upper);
  [data_l, data_u] =  MIE_box(gMIE, lower, upper);
  
  %% Terminal integrator grid
  
  gTI = createGrid(-10, 10, 51);
  
  [gIm, dataIm_l] = MIE2Implicit(gMIE, data_l, 'lower', gTI);
  [~, dataIm_u] = MIE2Implicit(gMIE, data_u, 'upper', gTI);
  
  %% Visualize
  % MIE
  figure
  visSetMIE(gMIE, data_l, 'b');
  hold on
  visSetMIE(gMIE, data_u, 'r');
  
  % Implicit
  visSetIm(gIm, dataIm_l, 'b');
  hold on
  visSetIm(gIm, dataIm_u, 'r');
  
  xlim([gIm.min(1) gIm.max(1)])
  ylim([gIm.min(2) gIm.max(2)])
  if gIm.dim >= 3
    zlim([gIm.min(3) gIm.max(3)])
  end
end
end