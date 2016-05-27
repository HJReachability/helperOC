function alpha = plane4Dpartial(t, data, derivMin, derivMax, schemeData, dim)
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

switch dim
  case 1
    alpha = abs(g.xs{4}.*cos(g.xs{3}));
    
  case 2
    alpha = abs(g.xs{4}.*sin(g.xs{3}));
    
  case 3
    alpha = wMax;
    
  case 4
    alpha = max(abs(arange));
    
  otherwise
    error([ 'Partials only exist in dimensions 1-4' ]);
end
end