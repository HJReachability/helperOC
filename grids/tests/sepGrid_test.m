function sepGrid_test()
% sepGrid_test()
%   Tests the sepGrid() function

% Create a 4D grid
g = createGrid([0; 1; 0; 1], [1; 2; 1; 2], 45*ones(4,1));

% Split into two 2D grids
gs = sepGrid(g, {[1 3], [2 4]});

% Visualize
colors = lines(length(gs));
figure
for i = 1:length(gs)
  visGrid(gs{i}, colors(i,:));
  hold on
end

end