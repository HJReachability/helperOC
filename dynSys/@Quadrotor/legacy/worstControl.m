function uWorst = worstControl(obj, other, safeV)
% Finds the worst possible control
%
% Inputs:  obj   - this vehicle
%          other - other vehicle
%
% Outputs: 
%          uWorst - the worst controller
%

% States in 6D reachable set %obj - pursuer, other - evader
xr = other.x(1) - obj.x(1);
vxr = other.x(2) - obj.x(2);
vx = other.x(2);
yr = other.x(3) - obj.x(3);
vyr = other.x(4) - obj.x(4);
vy = other.x(4);
x = [xr vxr vx yr vyr vy];
   
% Compute value and gradient at current state 
[valuex, gradx, ~, ~, ~, ind] = recon2x3D(safeV.tau, ...
    safeV.g, safeV.dataC, safeV.g, safeV.dataC, x);

%%TODO: Double check
% Compute worst controller
uWorst = [(gradx(2)>=0)*obj.uMin + (gradx(2)<0)*obj.uMax; ...
    (gradx(5)>=0)*obj.uMin + (gradx(5)<0)*obj.uMax];
end

