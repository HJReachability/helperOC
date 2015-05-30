function p = extractCostates(grid, data, derivFunc, upWind)
% function p = extractCostates(grid, data, upWind)
% Estimates the costate p at position x for cost function data on grid g by
% numerically taking partial derivatives along each grid direction.
% Numerical derivatives are taken using the levelset toolbox
% HACK ALERT: for now we assume 4-D system to save coding time

if nargin<3
    derivFunc = @upwindFirstWENO5;
end

if nargin<4
    upWind = false;
end
numInfty = 1e6;

data(isnan(data)) = numInfty;

p = cell(grid.dim,1);
for i = 1:grid.dim
    [derivL, derivR] = derivFunc(grid, data, i);
    
    if upWind
        p{i} = derivL.*(derivL>0 & derivR>0) + ...
            derivR.*(derivL<0 & derivR<0) + ...
            derivL.*(derivL>0 & derivR<0 & -derivL<=derivR) + ...
            derivR.*(derivL>0 & derivR<0 & -derivL>derivR);
    else
        p{i} = (derivL + derivR)/2;
    end
end

end