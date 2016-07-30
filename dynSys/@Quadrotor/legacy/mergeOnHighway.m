function u = mergeOnHighway(obj, hw, target)
% function u = mergeOnHighway(obj, hw, target)
%
% Inputs:  target  - target position on highway (2D vector or scalar
%                    between 0 and 1
%          hw      - highway object to merge onto
%
% Output:  u - control signal to merge onto highway
%
% 2015-06-17, Mo Chen
% Modified: Kene Akametalu, summer 2015
% Modified: Mo Chen, 2015-10-20

% Parse target state
x = zeros(1,4);
if numel(target) == 1
  s = target;
  s = min(1,s);
  s = max(0,s);
  x(obj.pdim) = hw.fn(s);
  
elseif numel(target) == 2
  x(obj.pdim) = target;
  
else
  error('Invalid target!')
end

% Target velocity (should be velocity along the highway)
x(obj.vdim) = hw.speed * hw.ds;

% Time horizon for MPC
tsteps = 5;

switch obj.q
  case 'Free'
    % state on liveness reachable set grid
    x_liveV(obj.pdim) = obj.getPosition - x(obj.pdim)';
    x_liveV(obj.vdim) = obj.getVelocity;
    
    [arrived, inRS, uRS] = mergeStatus(x_liveV, hw.liveV, obj.uMin, ...
                                                                 obj.uMax);
    
    % Perform merging maneuver until obj becomes leader
    if arrived
      % If we're close to the target set, form a platoon and become a 
      % leader
      obj.p = platoon(obj, hw);  % Create platoon
      u = obj.followPath(tsteps, hw);
      return
    end
    
    if inRS
      % If inside reachable set, use control obtained from reachable set
      u = uRS;
      return
    end
    
    % Otherwise, simply take a straight line to the target
    disp('Open-loop')

    % Path to target
    pathToTarget = linpath(obj.x(obj.pdim), target);
    u = obj.followPath(tsteps, pathToTarget);
    
  case 'Leader'
    error('Vehicle cannot be a leader!')
    % Unless we're joining another highway... need to implement this
    
  case 'Follower'
    error('Vehicle cannot be a follower!')
    
  otherwise
    error('Unknown mode!')
end
end

function [arrived, inRS, uRS] = mergeStatus(x_liveV, liveV, uMin, uMax)
% function arrived = hasArrived(x_liveV liveV)
%
% Checks whether the quadrotor has arrived at the target set or inside
% livesness reachable set

% Initialize outputs
arrived = false;
inRS = false;
uRS = [];

% Number of seconds until target set is reached
arrivedThreshold = 1;

% Evaluate value function
if iscell(liveV.g)
  % If liveV.g is a cell structure, then it must be a cell structure
  % of two elements, each containing the grid corresponding to a 2D
  % reachable set

  [TD_out_x, ~, TTR_out_x] = recon2x2D(liveV.tau, liveV.g, liveV.data, ...
                                                                  x_liveV);
  
  % If arriving at target set, skip the rest
  if TTR_out_x.value <= arrivedThreshold
    arrived = true;
    inRS = true;
    return;
  end
  
  if TD_out_x.value <= 0
    inRS = true;
    gradx = TD_out_x.grad;
  end
  
else
  % if liveV.g is not a cell structure, then it must be a struct
  % representing the grid structure for a 4D reachable set
  valuex = eval_u(liveV.g, liveV.data, x_liveV);
  
  % If arriving at target set, skip the rest
  if valuex <= arrivedThreshold
    arrived = true;
    inRS = true;
    uRS = [];
    return;
  end
  
  % If inside reachable set, save gradient
  if valuex <= abs(max(liveV.tau) - min(liveV.tau));
    inRS = true;
    gradx = calculateCostate(liveV.g, liveV.grad, x_liveV);
  end
end

% Compute control if inside reachable set
if inRS
  disp('Locked-in')
  ux = (gradx(2)>=0)*uMin + (gradx(2)<0)*uMax;
  uy = (gradx(4)>=0)*uMin + (gradx(4)<0)*uMax;
  uRS = [ux; uy];
end

end