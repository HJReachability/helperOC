function gs = splitGrid(g, dims, bounds, padding)
% gs = splitGrid(g, pieces, dims, padding, sizes)
% 
% Inputs:
%   g - original grid
%   dims   - cell vector of output grid dimensions
%              eg. dims = {[1; 3], [2; 4]} would produce two 2D grids. The
%                  first grid has dimensions corresponding to the 1st and 
%                  3rd dimensions in the original grid
%   padding - amount of space to add to each grid
%   sizes   - custom grid sizes; each row
%           - defaults to pieces of equal sizes
%
% Output:
%   gs - cell vector of grids

if nargin < 4
  padding = 0.05 * (g.max - g.min);
end

% Separate the grid into different dimensions
gs_temp = sepGrid(g, dims);

% For each dimension, split the grid according to bounds
gs = cell(size(gs_temp));
for i = 1:length(gs_temp)
  gs{i} = splitGrid_sameDim(gs_temp{i}, bounds(dims{i}), padding(dims{i}));
end

end

