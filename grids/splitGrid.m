function gs = splitGrid(g, dims, bounds, padding)
% gs = splitGrid(g, pieces, dims, padding, sizes)
%     Splits a high-dimensional grid to a number of lower-dimensional grids
%     See splitGrid_test() for an example
% 
% Inputs:
%     g - original grid
%     dims   - cell vector of output grid dimensions
%              eg. dims = {[1; 3], [2; 4]} would produce two 2D sets of grids. 
%                  The first set has dimensions corresponding to the 1st and 
%                  3rd dimensions in the original grid
%     bounds - list of bounds of the smaller grids. This should be a g.dim
%              dimensional matrix that specifies the "grid" of bounds.
%         Example 1: suppose the original grid is a [-1, 1]^2 grid in 2D, and 
%             dims = {[1 2]} (i.e. no lower-dimesional grids are created; all 
%             grids remain in 2D). Then, the following bounds would split it 
%             into [-1, 0]^2, [0, 1]^2, [-1, 0] x [0, 1], and [0, 1] x [-1, 0] 
%             grids:
%                 bounds = {[-1, 0, 1], [-1, 0, 1]};
%         Example 2: uppose the original grid is a [-1, 1]^2 grid in 2D, and 
%             dims = {[1], [2]} (i.e. split the grid into one-dimensional
%             grids). Then the following bounds would split it into [-1, 0], [0,
%             1] grids in the first dimension, and [-1, 0], [0, 1] grids in the
%             second dimension:
%                 bounds = {[-1, 0, 1], [-1, 0, 1]};
%
%     padding - amount of overlap between two adjacent subgrids
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

