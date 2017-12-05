function splitGrid_test()
% splitGrid_test()
%   tests the splitGrid() function

%% Create a [0, 1] x [1, 2] x [2, 3] x [3, 4] 4D grid
g = createGrid([0; 1; 2; 3], [1; 2; 3; 4], 45*ones(4,1), [], false);

%% Specify how the 4D grid will be split
% Split into a number of 2D grids in the 1st and 3rd, and 2nd and 4th dimensions
dims = {[1 3], [2 4]};

% Split the dimensions evenly using the linspace command. Split 
%     the 1st dimension into 2 equal grids; 
%         2nd dimension,     3 equal grids; 
%         3rd dimension,     2 equal grids; 
%     and 4th dimension,     3 equal grids
bounds = {linspace(0, 1, 3), linspace(1, 2, 4), linspace(2, 3, 3), ...
  linspace(3, 4, 4)};

% Split and visualize
gs = splitGrid(g, dims, bounds);
for i = 1:length(gs)
  figure
  colors = lines(numel(gs{i}));
  
  for j = 1:numel(gs{i})
    visGrid(gs{i}{j}, colors(j,:));
    hold on
  end
end


end