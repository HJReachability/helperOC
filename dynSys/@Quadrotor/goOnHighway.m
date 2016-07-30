function u = goOnHighway(obj, hw, target, tfm)
% u = goOnHighway(obj, hw, target, tfm)
% method of Quadrotor class
%
% Calls TFM to get control signal for joining a highway at some target
% position

u = tfm.goOnHighway(obj, hw, target);

end