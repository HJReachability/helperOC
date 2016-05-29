function MIE_box_test()
% Tests the MIE_box function
%
% Mo Chen, Mahesh Vashishtha, 2016-05-11
dims = 2:4;
Ns = [201 101 81 45];
trials = [3; 3; 3];

for i = 1:length(dims)
  %% MIE Approximation grid
  grid_min = -10*ones(dims(i)-1, 1);
  grid_max = 10*ones(dims(i)-1, 1);
  N = Ns(dims(i)-1)*ones(dims(i)-1, 1);
  gMIE = createGrid(grid_min, grid_max, N);
  
  %% True grid
  grid_min = -10*ones(dims(i), 1);
  grid_max = 10*ones(dims(i), 1);
  N = Ns(dims(i))*ones(dims(i), 1);
  gTrue = createGrid(grid_min, grid_max, N);
  
  %% Initialize visualization
  for j = 1:trials(i)
    %% Create MIE and true data
    lower = -10 + 12*rand(dims(i),1);
    upper = lower + 5 + 5*rand(dims(i),1);
    upper = min(9*ones(dims(i),1), upper);
    [data_l, data_u] =  MIE_box(gMIE, lower, upper);
    
    dataTrue = shapeRectangleByCorners(gTrue, lower, upper);
    
    %% Plot
    figure
    visSetMIE(gMIE, data_l, 'b');
    hold on
    visSetMIE(gMIE, data_u, 'r');
    visSetIm(gTrue, dataTrue, 'g');    

    xlim([grid_min(1) grid_max(1)])
    ylim([grid_min(2) grid_max(2)])
    if dims(i) >= 3
      zlim([grid_min(3) grid_max(3)])
    end
  end % end for j
end % end for i

end