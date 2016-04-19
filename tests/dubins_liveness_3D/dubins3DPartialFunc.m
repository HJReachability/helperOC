function alpha = dubins3DPartialFunc(t, data, derivMin, derivMax, schemeData, dim)

checkStructureFields(schemeData, 'grid', 'speed', 'U');

g = schemeData.grid;
v = schemeData.speed;
U = schemeData.U;

% Dynamics:
% \dot x = v * cos(\theta)
% \dot y = v * sin(\theta)
% \dot \theta = u

switch dim
  case 1
    alpha = abs(v * cos(g.xs{3}));

  case 2
    alpha = abs(v * sin(g.xs{3}));

  case 3
    alpha = max(abs(U));

  otherwise
    error('Partials for Dubins car only exist in dimensions 1-3');
end