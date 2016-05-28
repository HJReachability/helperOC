function hamValue = plane4Dham(t, data, deriv, schemeData)
% hamValue = plane4Dham(t, data, deriv, schemeData)
%   Hamiltonian function for a 4D plane (Dubins car with finite acceleration)
%
% Inputs:
%   schemeData - problem parameters
%     .grid:   grid structure
%     .wMax:   max turn rate
%     .arange: acceleration range
%
% Dynamics:
%   \dot x      = v \cos \theta
%   \dot y      = v \sin \theta
%   \dot \theta = w
%   \dot v      = a
%     |w| <= wMax
%     arange(1) <= a <= arange(2)
%

checkStructureFields(schemeData, 'grid',  'wMax', 'arange')

g = schemeData.grid;
wMax = schemeData.wMax;
arange = schemeData.arange;

hamValue = deriv{1} .* (g.xs{4}.*cos(g.xs{3})) + ...
  deriv{2} .* (g.xs{4}.*sin(g.xs{3})) + ...
  -wMax * abs(deriv{3}) + ...
  (deriv{4}>=0).*deriv{4}*arange(1) + (deriv{4}<0).*deriv{4}*arange(2);

hamValue = -hamValue;
end