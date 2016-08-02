function [derivC, derivL, derivR] = extractCostates(g, data, derivFunc, upWind)
% [derivC, derivL, derivR] = extractCostates(g, data, derivFunc, upWind)
%     Obsolete function... use computeGradients instead

if nargin<3
  derivFunc = @upwindFirstWENO5;
end

if nargin > 3 && upWind
  error('Upwinding has not been implemented!')
end

[derivC, derivL, derivR] = computeGradients(g, data, derivFunc);

end