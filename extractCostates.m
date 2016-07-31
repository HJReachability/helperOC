function [derivC, derivL, derivR] = extractCostates(g, data, derivFunc, upWind)
% [derivC, derivL, derivR] = extractCostates(g, data, derivFunc, upWind)
%     Obsolete function... use computeGradients instead

[derivC, derivL, derivR] = computeGradients(g, data, derivFunc, upWind);

end