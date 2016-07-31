function [derivC, derivL, derivR] = computeGradients(g, data, derivFunc, upWind)
% [derivC, derivL, derivR] = computeGradients(g, data, derivFunc, upWind)
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
% Output: derivC    - (central) gradient in a g.dim by 1 vector
%         derivL    - left gradient
%         derivR    - right gradient

if nargin<3
  derivFunc = @upwindFirstWENO5;
end

if nargin > 3 && upWind
  error('Upwinding has not been implemented!')
end

% Go through each dimension and compute the gradient in each
derivC = cell(g.dim, 1);
derivL = cell(g.dim, 1);
derivR = cell(g.dim, 1);

if numDims(data) == g.dim
  tau_length = 1;
elseif numDims(data) == g.dim + 1
  tau_length = size(data);
  tau_length = tau_length(end);
  colons = repmat({':'}, 1, g.dim);
else
  error('Dimensions of input data and grid don''t match!')
end

% Just in case there are NaN values in the data (usually from TTR functions)
numInfty = 1e6;
nanInds = isnan(data);
data(nanInds) = numInfty;

% Just in case there are inf values
infInds = isinf(data);
data(infInds) = numInfty;

for i = 1:g.dim
  derivC{i} = zeros(size(data));
  derivL{i} = zeros(size(data));
  derivR{i} = zeros(size(data));
  
  %% data at a single time stamp
  if tau_length == 1
    % Compute gradient using level set toolbox
    [derivL{i}, derivR{i}] = derivFunc(g, data, i);
    
    % Central gradient
    derivC{i} = 0.5*(derivL{i} + derivR{i});
  else
    %% data at multiple time stamps
    for t = 1:tau_length
      [derivL{i}(colons{:}, t), derivR{i}(colons{:}, t)] = ...
        derivFunc(g, data(colons{:}, t), i);
      derivC{i}(colons{:}, t) = ...
        0.5*(derivL{i}(colons{:}, t) + derivR{i}(colons{:}, t));
    end
  end
    
  % Change indices where data was nan to nan
  derivC{i}(nanInds) = nan;
  derivL{i}(nanInds) = nan;
  derivR{i}(nanInds) = nan;
  
  % Change indices where data was inf to inf
  derivC{i}(infInds) = inf;
  derivL{i}(infInds) = inf;
  derivR{i}(infInds) = inf;
end

end