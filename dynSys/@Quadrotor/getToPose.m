function u = getToPose(obj, tfm, position, heading, debug)
% u = getToPose(obj, tfm, target_state)
%
% Requests from tfm the control needed to drive the vehicle to some target
% pose. The target pose is specified by a position and a heading. The
% target state is assumed to be at the target position with a target speed
% of 3 in the direction of the target heading.
%
% Mo Chen 2015-11-04

if nargin < 5
  debug = false;
end

u = tfm.getToPose(obj, position, heading, debug);

end