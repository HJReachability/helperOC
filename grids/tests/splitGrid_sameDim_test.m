function splitGrid_sameDim_test()

%% Create 2D grid
g = createGrid([0; 0], [1; 1], [101; 101]);

bounds = {[0 0.5 1]; [0 0.25 0.75 1]};

padding = [0.1; 0.2];
gs = splitGrid_sameDim(g, bounds, padding);

%% Visualize
figure
numGrids = numel(gs);
colors = jet(numGrids);
for i = 1:numGrids
  visGrid(gs{i}, colors(i,:));
  hold on
end

%% Create 3D grid
g = createGrid([0; 0; 0], [1; 1; 1], [75; 75; 75]);

bounds = {[0 0.33 0.5 0.8 1]; [0 0.5 0.75 1]; linspace(0, 1, 5)};
padding = [0.05; 0.1; 0.05];
gs = splitGrid_sameDim(g, bounds, padding);

%% Visualize
figure
numGrids = numel(gs);
colors = jet(numGrids);
for i = 1:numGrids
  visGrid(gs{i}, colors(i,:));
  hold on
end
end