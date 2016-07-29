function [derivC, derivL, derivR] = extractCostates(g, data, derivFunc, upWind)
% function P = extractCostates(g, data, derivFunc, upWind)
%
% Estimates the costate p at position x for cost function data on grid g by
% numerically taking partial derivatives along each grid direction.
% Numerical derivatives are taken using the levelset toolbox
%
% Inputs: grid      - grid structure
%         data      - array of g.dim dimensions containing function values
%         derivFunc - derivative approximation function (from level set
%                     toolbox)
%         upWind    - whether to use upwinding (ignored; to be implemented in
%                     the future
%
% Output: P         - gradient in a g.dim by 1 vector
%
% Mo Chen, 2015-10-15
% Originally adapted from Haomiao Huang's code

if nargin<3
  derivFunc = @upwindFirstWENO5;
end

if nargin > 3 && upWind
  error('Upwinding has not been implemented!')
end

% Just in case there are NaN values in the data (usually from Fast Marching
% calculations)
numInfty = 1e6;
data(isnan(data)) = numInfty;

% Go through each dimension and compute the gradient in each
derivC = cell(g.dim,1);
derivL = cell(g.dim,1);
derivR = cell(g.dim,1);

if numDims(data) == g.dim
  tau_length = 1;
elseif numDims(data) == g.dim + 1
  tau_length = size(data);
  tau_length = tau_length(end);
  colons = repmat({':'}, 1, g.dim);
else
  error('Dimensions of input data and grid don''t match!')
end

for i = 1:g.dim
  derivC{i} = zeros(size(data));
  derivL{i} = zeros(size(data));
  derivR{i} = zeros(size(data));
  
  %% data at a single time stamp
  if tau_length == 1
    [derivL{i}, derivR{i}] = derivFunc(g, data, i);
    derivC{i} = 0.5*(derivL{i} + derivR{i});
    continue
  end
  
  %% data at multiple time stamps
  for t = 1:tau_length
    [derivL, derivR] = derivFunc(g, data(colons{:}, t), i);
    derivC{i}(colons{:}, t) = 0.5*(derivL{i} + derivR{i});
  end
  
end

end