function [gOut, dataOut] = proj(g, data, dims, xs, NOut)

if length(dims) ~= g.dim
  error('Dimensions are inconsistent!')
end

if nargin < 4
  xs = 'min';
end

if nargin < 5
  NOut = g.N(~dims);
end

dims = logical(dims);

% Create ouptut grid by keeping dimensions that we are not collapsing
gOut.dim = nnz(~dims);
gOut.min = g.min(~dims);
gOut.max = g.max(~dims);
gOut.bdry = g.bdry(~dims);

if numel(NOut) == 1
  gOut.N = NOut*ones(gOut.dim, 1);
else
  gOut.N = NOut;
end

gOut = processGrid(gOut);

% Only compute the grid if value function is not requested
if nargout < 2
  return
end
end