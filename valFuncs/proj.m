function [gOut, dataOut] = proj(g, data, dims, xs, NOut, process)
% [gOut, dataOut] = proj(g, data, dims, xs, NOut)
%   Projects data corresponding to the grid g in g.dim dimensions, removing
%   dimensions specified in dims. If a point is specified, a slice of the
%   full-dimensional data at the point xs is taken.
%
% Inputs:
%   g       - grid corresponding to input data
%   data    - input data
%   dims    - vector of length g.dim specifying dimensions to project
%                 For example, if g.dim = 4, then dims = [0 0 1 1] would
%                 project the last two dimensions
%   xs      - Type of projection (defaults to 'min')
%       'min':    takes the union across the projected dimensions
%       'max':    takes the intersection across the projected dimensions
%       a vector: takes a slice of the data at the point xs
%   NOut    - number of grid points in output grid (defaults to the same
%             number of grid points of the original grid in the unprojected
%             dimensions)
%   process            - specifies whether to call processGrid to generate
%                        grid points
%
% Outputs:
%   gOut    - grid corresponding to projected data
%   dataOut - projected data
%
% See proj_test.m

%% Input checking
if length(dims) ~= g.dim
  error('Dimensions are inconsistent!')
end

if nnz(~dims) == g.dim
  gOut = g;
  dataOut = data;
  warning('Input and output dimensions are the same!')
  return
end

% By default, do a projection
if nargin < 4
  xs = 'min';
end

% If a slice is requested, make sure the specified point has the correct
% dimension
if isnumeric(xs) && length(xs) ~= nnz(dims)
  error('Dimension of xs and dims do not match!')
end

if nargin < 5
  NOut = g.N(~dims);
end

if nargin < 6
  process = true;
end

%% Project data
dataDims = numDims(data);
if dataDims == g.dim
  [gOut, dataOut] = projSingle(g, data, dims, xs, NOut, process);
  
elseif dataDims == g.dim + 1
  % Project grid
  gOut = projSingle(g, [], dims, xs, NOut, process);
  
  % Project data
  numTimeSteps = size(data, dataDims);
  dataOut = zeros([NOut' numTimeSteps]);
  colonsIn = repmat({':'}, 1, g.dim);
  
  colonsOut = repmat({':'}, 1, gOut.dim);
  for i = 1:numTimeSteps
    [~, dataOut(colonsOut{:},i)] = ...
      projSingle(g, data(colonsIn{:},i), dims, xs, NOut, process);
  end
else
  error('Inconsistent input data dimensions!')
end
end
function [gOut, dataOut] = projSingle(g, data, dims, xs, NOut, process)
% [gOut, dataOut] = proj(g, data, dims, xs, NOut)
%   Projects data corresponding to the grid g in g.dim dimensions, removing
%   dimensions specified in dims. If a point is specified, a slice of the
%   full-dimensional data at the point xs is taken.
%
% Inputs:
%   g       - grid corresponding to input data
%   data    - input data
%   dims    - vector of length g.dim specifying dimensions to project
%                 For example, if g.dim = 4, then dims = [0 0 1 1] would
%                 project the last two dimensions
%   xs      - Type of projection (defaults to 'min')
%       'min':    takes the union across the projected dimensions
%       'max':    takes the intersection across the projected dimensions
%       a vector: takes a slice of the data at the point xs
%   NOut    - number of grid points in output grid (defaults to the same
%             number of grid points of the original grid in the unprojected
%             dimensions)
%   process            - specifies whether to call processGrid to generate
%                        grid points
%
% Outputs:
%   gOut    - grid corresponding to projected data
%   dataOut - projected data
%
% See proj_test.m

%% Create ouptut grid by keeping dimensions that we are not collapsing
dims = logical(dims);
gOut.dim = nnz(~dims);
gOut.min = g.min(~dims);
gOut.max = g.max(~dims);
gOut.bdry = g.bdry(~dims);

if numel(NOut) == 1
  gOut.N = NOut*ones(gOut.dim, 1);
else
  gOut.N = NOut;
end

% Process the grid to populate the remaining fields if necessary
if process
  gOut = processGrid(gOut);
end

% Only compute the grid if value function is not requested
if nargout < 2
  return
end

% 'min' or 'max'
if ischar(xs)
  dimsToProj = find(dims);
  
  for i = length(dimsToProj):-1:1
    if strcmp(xs,'min')
      data = squeeze(min(data, [], dimsToProj(i)));
    elseif strcmp(xs,'max')
      data = squeeze(max(data, [], dimsToProj(i)));
    else
      error('xs must be a vector, ''min'', or ''max''!')
    end
  end
  
  dataOut = data;
  return
end

% Take a slice
temp = eval(getCmdStr_projData(g.dim, dims));
dataOut = squeeze(temp);
dataOut = eval(getCmdStr_matchGrid(g.dim, dims));
end

function cmdStr = getCmdStr_projData(totalDim, dims)
% For example, if totalDim = 4, dims = [0 1 0 1], returns the string
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data, g.vs{1}, xs(1), ...
%   g.vs{3}, xs(2));

cmdStr = 'interpn(';
% interpn(

for i = 1:totalDim
  cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}, ']);
end
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4},

cmdStr = cat(2, cmdStr, 'data, ');
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data,

xsDim = 1;
for i = 1:totalDim
  if dims(i)
    cmdStr = cat(2, cmdStr, ['xs(' num2str(xsDim) ')']);
    xsDim = xsDim + 1;
  else
    cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}']);
  end
  
  if i < totalDim
    cmdStr = cat(2, cmdStr, ', ');
  else
    cmdStr = cat(2, cmdStr, ')');
  end
end
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data, g.vs{1}, xs(1), ...
%   g.vs{3}, xs(2));

end

function cmdStr = getCmdStr_matchGrid(totalDim, dims)
% For example, if totalDim = 3 and dims = [0 1 0], returns the string
%   interpn(g.vs{1}, g.vs{3}, dataOut, gOut.xs{1}, gOut.xs{2})

cmdStr = 'interpn(';
% interpn(

for i = 1:totalDim
  if ~dims(i)
    cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}, ']);
  end
end
% interpn(g.vs{1}, g.vs{3},

cmdStr = cat(2, cmdStr, 'dataOut, ');
% interpn(g.vs{1}, g.vs{3}, dataOut,

for i = 1:nnz(~dims)
  cmdStr = cat(2, cmdStr, ['gOut.xs{' num2str(i) '}']);
  
  if i < nnz(~dims)
    cmdStr = cat(2, cmdStr, ', ');
  else
    cmdStr = cat(2, cmdStr, ')');
  end
end
% interpn(g.vs{1}, g.vs{3}, dataOut, gOut.xs{1}, gOut.xs{2})

end