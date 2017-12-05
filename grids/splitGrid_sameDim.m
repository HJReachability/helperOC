function gs = splitGrid_sameDim(g, bounds, padding)
% gs = splitGrid_sameDim(g, bounds, padding)
%     Splits the grid into smaller grids, each with specified bounds.
%     Optionally, padding can be specified so that the grids overlap
%
% Inputs:
%     g      - original grid
%     bounds - list of bounds of the smaller grids. This should be a g.dim
%              dimensional matrix that specifies the "grid" of bounds.
%         For example, suppose the original grid is a [-1, 1]^2 grid in 2D.
%         Then, the following bounds would split it into [-1, 0]^2, [0, 1]^2,
%         [-1, 0] x [0, 1], and [0, 1] x [-1, 0] grids:
%             bounds = {[-1, 0, 1], [-1, 0, 1]};
%     padding - amount of overlap between two adjacent subgrids
%
% Output:
%     gs - subgrids
%


%% Create a grid for the bounds
% ndgrid(bounds{1}, bounds{2}, bounds{3});
bounds_grid_cmd = 'ndgrid(';
for i = 1:g.dim
  bounds_grid_cmd = cat(2, bounds_grid_cmd, ['bounds{' num2str(i) '}']);
  if i == g.dim
    bounds_grid_cmd = cat(2, bounds_grid_cmd, ');');
  else
    bounds_grid_cmd = cat(2, bounds_grid_cmd, ', ');
  end
end

bounds_grid = cell(g.dim, 1);
if g.dim > 1
  [bounds_grid{:}] = eval(bounds_grid_cmd);
else
  bounds_grid{1} = eval(bounds_grid_cmd);
end

%% Create grids based on the bound grid
gs = cell(size(bounds_grid{1})-(size(bounds_grid{1})>1));

ii = cell(g.dim, 1);
for i = 1:numel(gs)
  [ii{:}] = ind2sub(size(gs), i);
  iip = ii;
  for j = 1:g.dim
    iip{j} = iip{j} + 1;
  end
  grid_min = [];
  grid_max = [];
  for j = 1:g.dim
    grid_min = cat(1, grid_min, bounds_grid{j}(ii{:}));
    grid_max = cat(1, grid_max, bounds_grid{j}(iip{:}));
  end
  
  [grid_min, grid_max, N] = getOGPBounds(g, grid_min, grid_max, padding);
  
  gs{ii{:}} = createGrid(grid_min, grid_max, N);
end

end