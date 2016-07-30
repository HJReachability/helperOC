function u = mergeWithPlatoon(obj, p)
% function u = mergeWithPlatoon(obj, p)
%
% Computes the control used to merge into a platoon
% Free vehicles will merge into the first available slot
% Leader vehicles will take its entire platoon to combine with the target
% platoon
%
% Inputs:  obj  - quadrotor objects
%          p    - target platoon object to merge with
%
% Output:  u - control signal for the merge
%
% 2015-06-17, Mo
% Modified: Qie Hu, 2015-07-01
% Modified: Mo Chen, 2015-07-06
% Modified: Mo Chen, 2015-08-26

% Check if the current vehicle is a follower
switch obj.q
  case 'Free'
    % Check if platoon is full (should never have to check if outside logic is
    % correct
    if p.n+1 > p.nmax
      error('Platoon already full!')
    end
    
    % Index in the platoon to join
    idxJoin = find(~p.slotStatus, 1, 'first');
    
  case 'Leader'
    if p.loIdx + obj.p.loIdx > p.nmax
      error('Not enough slots at the back of the target platoon!')
    end
    
    % Index in the platoon to join
    idxJoin = p.loIdx + 1;
    
  case 'Follower'
    warning(['Followers aren''t supposed to have the choice to join a' ...
      'platoon! Interpreting as catching up to platoon'])
    
end

pdim = obj.pdim;
vdim = obj.vdim;

if ~strcmp(obj.q, 'Follower')
  % Update join list
  if isempty(obj.pJoin)
    % If current vehicle is not currently joining a platoon, then mark
    % p as the platoon to join and add to join list
    obj.idxJoin = idxJoin;
    p.slotStatus(obj.idxJoin) = -1;
    p.vJoin{obj.idxJoin} = obj;
    obj.pJoin = p;
    
  else
    % Otherwise, empty previous marked platoon and remove from other
    % platoon's join list; also mark this platoon for joining
    if obj.pJoin ~= p
      obj.pJoin.slotStatus(obj.idxJoin) = 0;
      obj.pJoin.vJoin{obj.idxJoin} = [];
      
      obj.idxJoin = idxJoin;
      p.slotStatus(obj.idxJoin) = -1;
      p.vJoin{obj.idxJoin} = obj;
      obj.pJoin = p;
    end
  end
  
  % If vehicle has trailing vehicles inside the same platoon, recursively
  % update their info too (could also do a loop, but this seems to work)
  %
  % This needs to be tested! Using visualizeVehicles.m is recommended.
  vehicle = obj;
  while vehicle.BQ ~= vehicle
    vehicle.BQ.idxJoin = vehicle.idxJoin + 1;
    p.slotStatus(vehicle.BQ.idxJoin) = -1;
    p.vJoin{vehicle.BQ.idxJoin} = vehicle.BQ;
    
    vehicle.BQ.pJoin = p;
    vehicle = vehicle.BQ;
  end
end
% Parse target state
x = zeros(4,1);
x(vdim) = [0 0];

% Determine phantom position (First free position)
idx = obj.idxJoin;
xPh = p.phantomPosition(idx);
x(pdim) = xPh - p.vehicles{1}.getPosition;

if strcmp(obj.q, 'Free') || strcmp(obj.q, 'Leader')
  % If vehicle is free or a leader, then try to join the
  % platoon at the back
  
  % Reachable set from target state
  [grids, datas, tau] = obj.computeV_relDyn(x);
  
  if abs(x-(obj.x-p.vehicles{1}.x))<=1.1*[grids{1}.dx; grids{2}.dx]
    % if relative state is within one grid point of target relative
    % state, roughly, then vehicle gets assimilated into platoon
    p.assimVehicle(obj);
    u = obj.followPlatoon;
    
  else
    % if relative state is not close enough, then try to head towards
    % the relative target state
    u = obj.computeCtrl_relDyn(p.vehicles{1}.x, xPh, ...
      grids, datas, tau, obj.vMax);
  end
  
else
  error('Unknown mode!')
end

end
