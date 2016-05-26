function splitGrid_test()
% splitGrid_test()
%   tests the splitGrid() function
%

% Create a 4D grid
g = createGrid([0; 1; 2; 3], [1; 2; 3; 4], 45*ones(4,1));

% Specify how the 4D grid will be split
dims = {[1 3], [2 4]};
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