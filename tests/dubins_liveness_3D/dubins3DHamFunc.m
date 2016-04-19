function hamValue = dubins3DHamFunc(t, data, deriv, schemeData)

checkStructureFields(schemeData, 'grid', 'speed', 'U');

g = schemeData.grid;
v = schemeData.speed;
uMin = schemeData.U(1);
uMax = schemeData.U(2);

% Dynamics:
% \dot x = v * cos(\theta)
% \dot y = v * sin(\theta)
% \dot \theta = u

hamValue = ...
  deriv{1} .* (v * cos(g.xs{3})) + deriv{2} .* (v * sin(g.xs{3})) + ...
  (deriv{3} >= 0) .* deriv{3} * uMin + (deriv{3} < 0) .* deriv{3} * uMax;

hamValue = -hamValue;
end
