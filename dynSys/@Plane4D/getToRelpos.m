function u = getToRelpos(obj, other, tfm, relpos, debug)
% u = getToRelpose(obj, other, tfm, position, heading, debug)
%
% Requests from tfm the control needed to drive the vehicle to some target
% position relative to the vehicle "other". The relative velocity at the
% target relative position is 0
%
% Mahesh Vashishtha 2016-01-25

if nargin < 5
  debug = false;
end

u = tfm.getToRelpos(obj, other, relpos, debug);

end