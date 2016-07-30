function u = followPlatoon(obj, tfm, debug)
% u = followPlatoon(obj, tfm, debug)
% method of Quadrotor class
%
% Follows the platoon that the current vehicle is in; the vehicle's current
% platoon is given by obj.p
%
% Input: obj - vehicle object
%
% Mo Chen, 2015-06-21

if ~strcmp(obj.q, 'Follower')
  error('Vehicle must be a follower!')
end

if nargin < 3
  debug = false;
end

%% Check if there's a free slot in front inside the platoon
idx = obj.p.getFirstEmptySlot;
if idx < obj.idx
  obj.p.slotStatus(obj.idx) = 0;
  obj.p.vehicles{obj.idx} = [];
  
  obj.p.slotStatus(idx) = 1;
  obj.p.vehicles{idx} = obj;
  obj.idx = idx;
end

%% Determine if the vehicle is too far away for simple controller
% Phantom position
[pPh_rel, pPh_abs] = obj.p.phantomPosition(tfm.ipsd, obj.idx);

err = norm(pPh_abs - obj.getPosition);

if err > 5
  %% If needed (too far away), use reachability-based controller
  if debug
    disp(['Vehicle ' num2str(obj.ID) ' catching up...'])
  end
  
  u = obj.getToRelpos(obj.p.vehicles{1}, tfm, pPh_rel);  
  return
end

%% If close enough, use simple controller
if debug
  disp(['Vehicle ' num2str(obj.ID) ' using simple controller...'])
end
u = simpleLinFB(obj, obj.p.vehicles{1}.u, pPh_abs, ...
  obj.p.vehicles{1}.getVelocity);

end % end function

