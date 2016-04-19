function g = createGrid(grid_min, grid_max, N, pdDims)
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
% Output:
%   g - grid structure
% 
% Mo Chen, 2016-04-18

if nargin < 4
  pdDims = [];
end

%% Input checks
if ~isvector(grid_min) || ~isvector(grid_max)
  error('grid_min and grid_max must both be vectors!')
end

if numel(grid_min) ~= numel(grid_max)
  error('grid min and grid_max must have the same number of elements!')
end

if ~iscolumn(grid_min)
  grid_min = grid_min';
end

if ~iscolumn(grid_max)
  grid_max = grid_max';
end

%% Create the grid
g.dim = length(grid_min);
g.min = grid_min;
g.max = grid_max;
g.N =  N;

g.bdry = cell(g.dim, 1);
for i = 1:length(g.bdry)
  if any(i == pdDims)
    g.bdry{i} = @addGhostPeriodic;
    g.max(i) = g.max(i) * (1 - 1/g.N(i));
  else
    g.bdry{i} = @addGhostExtrapolate;
  end
end

g = processGrid(g);
end