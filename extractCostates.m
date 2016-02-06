function P = extractCostates(grid, data, derivFunc, upWind)
% function p = extractCostates(grid, data, upWind)
%
% Estimates the costate p at position x for cost function data on grid g by
% numerically taking partial derivatives along each grid direction.
% Numerical derivatives are taken using the levelset toolbox
%
% Inputs: grid      - grid structure
%         data      - array of g.dim dimensions containing function values
%         derivFunc - derivative approximation function (from level set
%                     toolbox)
%         upWind    - whether to use upwinding
%
% Output: p         - gradient in a g.dim by 1 vector
%
% Mo Chen, 2015-10-15
% Originally adapted from Haomiao Huang's code

if nargin<3
  derivFunc = @upwindFirstWENO5;
end

if nargin<4
  upWind = false;
end

% Just in case there are NaN values in the data (usually from Fast Marching
% calculations)
numInfty = 1e6;
data(isnan(data)) = numInfty;

% Go through each dimension and compute the gradient in each
P = cell(grid.dim,1);
for i = 1:grid.dim
  [derivL, derivR] = derivFunc(grid, data, i);
  
  if upWind
    P{i} = derivL.*(derivL>0 & derivR>0) + ...
      derivR.*(derivL<0 & derivR<0) + ...
      derivL.*(derivL>0 & derivR<0 & -derivL<=derivR) + ...
      derivR.*(derivL>0 & derivR<0 & -derivL>derivR);
  else
    P{i} = (derivL + derivR)/2;
  end
end

end