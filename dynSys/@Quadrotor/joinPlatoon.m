function u = joinPlatoon(obj, platoon, tfm)
% u = joinPlatoon(obj, platoon)
% method of Quadrotor class
%
% Requests the control signal to join a platoon from the tfm

u = tfm.joinPlatoon(obj, platoon);

end
