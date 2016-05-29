function visSetMIE_test()
% visSetMIE_test()
% Tests the visSetMIE() function

%% Visualization parameters
color_u = 'r'; % color for upper function
color_l = 'b'; % color for lower function
dims = 2:4;
Ns = [201 101 75]; % Number of grid points for visualization

for i = 1:length(dims)
  figure
  
  %% Generate a random box
  grid_min = -10 * ones(dims(i)-1, 1);
  grid_max = 10 * ones(dims(i)-1, 1);
  g = createGrid(grid_min, grid_max, Ns(i));

  lower = -10 + 12*rand(dims(i), 1);
  upper = lower + 5 + 5*rand(dims(i), 1);
  upper = min(9*ones(dims(i),1), upper);
  
  [data_u, data_l] = MIE_box(g, lower, upper);
  
  %% Plot the box
  if dims(i) == 4
    sliceDim = 3;
    visSetMIE(g, data_u, color_u, sliceDim);
    visSetMIE(g, data_l, color_l, sliceDim);
  else
    visSetMIE(g, data_u, color_u);
    hold on
    visSetMIE(g, data_l, color_l);
  end

  %% Grid limits
  xlim([lower(1) upper(1)])
  ylim([lower(2) upper(2)])
  if dims(i) >= 3
    zlim([lower(3) upper(3)])
  end
end
end