function gs = splitGrid_sameDim(g, bounds, padding)

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
gs = cell(size(bounds_grid{1})-1);

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