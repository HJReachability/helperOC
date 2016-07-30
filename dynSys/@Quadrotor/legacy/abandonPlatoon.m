function abandonPlatoon(obj)
% Break away from current platoon without splitting it
% Qie Hu, 2015-07-01
% Modified: 2015-07-21, Mo Chen
% keyboard
if obj.p.n > 1 % Obj is in a platoon with more than one vehicle
  if obj.idx == 1 % Leader abandons platoon
    obj.p.vehicles{2}.q = 'Leader'; % Designate first follower as new leader
    obj.p.ID = obj.p.vehicles{2}.ID;
    obj.BQ.FQ = obj.BQ;
    
    % Update leader pointers
    for i = 2:obj.p.n
      obj.p.vehicles{i}.Leader = obj.p.vehicles{2};
    end
    
    
  elseif obj.idx == obj.p.n  % Trailing quadrotor abandons platoon
    obj.FQ.BQ = obj.FQ;
    
  else   % A quadrotor in the middle abandons platoon
    obj.FQ.BQ = obj.BQ;
    obj.BQ.FQ = obj.FQ;
  end
  
  % Update index for trailing vehicles
  for i = obj.idx+1:obj.p.n
    obj.p.vehicles{i}.idx = obj.p.vehicles{i}.idx-1;
  end
  
  % Update platoon lists
  obj.p.vehicles(obj.idx:end-1) = obj.p.vehicles(obj.idx+1:end);
  obj.p.vehicles{end} = [];
  
  obj.p.n = obj.p.n - 1;
  
  obj.p.slotStatus(obj.idx:obj.p.nmax-1) = obj.p.slotStatus(obj.idx+1:obj.p.nmax);
  obj.p.slotStatus(end) = 0;
  
  % If there are vehicles trying to join this platoon,
  % update their idxJoin
  vs_tf = find((obj.p.slotStatus == -1) & ... 
    ~cellfun('isempty', obj.p.vJoin));
  if ~isempty(vs_tf)
    for i = vs_tf
      obj.p.vJoin{i}.idxJoin = obj.p.vJoin{i}.idxJoin - 1;
    end
  end
else
  
  % Obj is the single vehicle in its platoon, so when it abandons, its
  % platoon disappears. Update platoon pointers
  obj.p.FP.BP = obj.p.BP;
  obj.p.BP.FP = obj.p.FP;
  delete(obj.p)
end

% Update vehicle information
obj.q = 'Free';
obj.p = [];
obj.FQ = [];
obj.BQ = [];
obj.Leader = [];

% If vehicle was attempting to join another platoon, free up the slot
if ~isempty(obj.pJoin)
  obj.pJoin.slotStatus(obj.idxJoin) = 0;
  obj.pJoin.vJoin{obj.idxJoin} = [];
end

end