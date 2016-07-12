function gs = sepGrid(g, dims)
% gs = sepGrid(g, dims)
%   Separates a grid into the different dimensions specified in dims
%
% Inputs:
%   g    - grid
%   dims - cell structure of grid dimensions
%            eg. {[1 3], [2 4]} would split the grid into two; one grid in
%                the 1st and 3rd dimensions, and another in the 2nd and 4th
%                dimensions
%
% Output:
%   gs - cell vector of separated grids

gs = cell(size(dims));
for i = 1:length(dims)
  dims_i = ones(1, g.dim);
  dims_i(dims{i}) = 0;
  gs{i} = proj(g, [], dims_i);
end

end