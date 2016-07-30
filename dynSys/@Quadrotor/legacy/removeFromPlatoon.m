function removeFromPlatoon(obj)
% UNUSED???
% Remove QR from platoon and treat as intruder


if obj.platoon.n > 1 % Obj is in a platoon with more than one vehicle
    
    if obj.idx == 1 % Leader abandons platoon
        obj.platoon.vehicle{2}.q = 'EmergLeader'; % Designate first follower as new leader
        obj.platoon.ID = obj.platoon.vehicle{2}.ID;
        obj.BQ.FQ = obj.BQ;
        
    elseif obj.idx == obj.platoon.n  % Trailing quadrotor abandons platoon
        obj.FQ.BQ = obj.FQ;
        
    else   % A quadrotor in the middle abandons platoon
        obj.FQ.BQ = obj.BQ;
        obj.BQ.FQ = obj.FQ;
    end
    
    % Update index for trailing vehicles
    for i = obj.idx+1:obj.platoon.n
        obj.platoon.vehicle{i}.idx = i-1;
    end
    
    obj.platoon.vehicle
    obj.platoon.IDvehicle
    
    % Update platoon lists
    obj.platoon.vehicle = [obj.platoon.vehicle(1:obj.idx-1), obj.platoon.vehicle(obj.idx+1:end)];
%     obj.platoon.IDvehicle = [obj.platoon.IDvehicle(1:obj.idx-1), obj.platoon.IDvehicle(obj.idx+1:end)];
    obj.platoon.n = obj.platoon.n - 1;
    
else
    
    % Obj is the single vehicle in its platoon, so when it abandons, its
    % platoon disappears. Update platoon pointers
    obj.platoon.FP.BP = obj.platoon.BP;
    obj.platoon.BP.FP = obj.platoon.FP; 
    
end

% Update vehicle mode
obj.q = 'Faulty';
obj.platoon = [];
obj.FQ = [];
obj.BQ = [];
obj.Leader = [];
end