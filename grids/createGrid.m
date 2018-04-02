function g = createGrid(grid_min, grid_max, N, pdDims, process, low_mem)
% g = createGrid(grid_min, grid_max, N, pdDim)
%
% Thin wrapper around processGrid to create a grid compatible with the
% level set toolbox
%
% Inputs:
%   grid_min, grid_max - minimum and maximum bounds on computation domain
%   N                  - number of grid points in each dimension
%   pdDims             - periodic dimensions (eg. pdDims = [2 3] if 2nd and
%                          3rd dimensions are periodic)
%   process            - specifies whether to call processGrid to generate
%                        grid points
%
% Output:
%   g - grid structure
% 
% Mo Chen, 2016-04-18

if nargin < 4
  pdDims = [];
end

if nargin < 5
  process = true;
end

if nargin < 6
  low_mem = false;
end

%% Input checks
if isscalar(N)
  N = N*ones(size(grid_min));
end

if ~isvector(grid_min) || ~isvector(grid_max) || ~isvector(N)
  error('grid_min, grid_max, N must all be vectors!')
end

if numel(grid_min) ~= numel(grid_max)
  error('grid min and grid_max must have the same number of elements!')
end

if numel(grid_min) ~= numel(N)
  error('grid min, grid_max, and N must have the same number of elements!')
end

if ~iscolumn(grid_min)
  grid_min = grid_min';
end

if ~iscolumn(grid_max)
  grid_max = grid_max';
end

if ~iscolumn(N)
  N = N';
end

%% Create the grid
g.dim = length(grid_min);
g.min = grid_min;
g.max = grid_max;
g.N =  N;

g.bdry = cell(g.dim, 1);
for i = 1:g.dim
  if any(i == pdDims)
    g.bdry{i} = @addGhostPeriodic;
    g.max(i) = g.min(i) + (g.max(i) - g.min(i)) * (1 - 1/g.N(i));
  else
    g.bdry{i} = @addGhostExtrapolate;
  end
end

if low_mem
  g.dx = (grid_max - grid_min) ./ (N-1);
  g.vs = cell(g.dim, 1);
  for i = 1:g.dim
    g.vs{i} = (grid_min(i) : g.dx(i) : grid_max(i))';
  end
elseif process
  g = processGrid(g);
end
end