function [safe, uSafe, valuex] = isSafe(obj, others, safeV, costates)
% [safe, uSafe, valuex] = isSafe(obj, others, safeV, costates)
% Check if this plane is safe relative to other planes. Assume that
% all velocities are fixed and equal and that safeV is computed
% assuming the same fixed velocity. Also returns optimal angular
% control input (this input is the optimal input for avoiding each
% plane in isolation)
%
% Inputs:  obj    - this plane
%          other - other planes with whom safety should be checked
%          safeV  - safety reachable set value function
%
% Outputs: safe   - boolean array indicating safety for each vehicle
%          uSafe  - the optimal safe controllers
%          valuex - the values of levelset function
%
% Mahesh Vashishtha, 2015-10-27
others = checkVehiclesList(others, 'plane');

g = safeV.g;
data = safeV.data;
for i = 1:length(others)
  z = obj.getRelativeStates(others{i});
  z = z(1,:);
  z = z(1:3);
  valuex(i) = eval_u(g, data, z);
  p = calculateCostate(g, costates, z);
  if p(1) * z(2) - p(2) * z(1) - p(3) > 0
    uSafe(i) = 1;
  else
    uSafe(i) = -1;
  end
  safe(i) = isnan(valuex) || valuex >= obj.V_TOL;
end
end