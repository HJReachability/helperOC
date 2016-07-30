function p = splitPlatoon(obj)
% Split current platoon in two and become Leader of the trailing platoon
%
% Qie Hu, Jaime Fernandez-Fisac, 2015-Mar
% Modified: Qie Hu, 2015-07-04
% Modified: Qie Hu, 2015-07-17


if ~strcmp(obj.q,'Follower')
    warning([
        sprintf('Cannot split from platoon.\n'),...
        sprintf('\t%s is currently in %s mode.\n',obj.ID,obj.q),...
        sprintf('\tOnly Follower vehicles can split from a platoon.\n')
        ]);
    p = [];
    return
end

% Pointer to old platoon before splitting
orig_p = obj.p;

% Index of obj in old platoon
old_obj_idx = obj.idx;

% Create new platoon w/ new leader only
% max size to allow re-joining, same followTime as existing platoon)
p = platoon(obj, obj.p.hw, obj.p.nmax - (obj.idx-1), obj.p.followTime);

% Update platoon pointers
if orig_p.BP == orig_p,  
    p.BP = p;
else
    p.BP = orig_p.BP; 
    orig_p.BP.FP = p; 
end
orig_p.BP = p;
p.FP = orig_p;

for i = old_obj_idx:orig_p.loIdx
    % Update vehicle list
    p.vehicles{i-old_obj_idx+1} = orig_p.vehicles{i};
    orig_p.vehicles{i} = [];
    
    % Update vehicle slot status
    p.slotStatus(i-old_obj_idx+1) = orig_p.slotStatus(i);
    orig_p.slotStatus(i) = 0;
    
    % Update join list pointers
    p.vJoin{i-old_obj_idx+1} = orig_p.vJoin{i};
    orig_p.vJoin{i} = [];
    
end

% Update number of vehicles in platoon
p.n = sum(p.slotStatus == 1);
orig_p.n = orig_p.n - p.n;

% Update last occupied index
p.loIdx = find(p.slotStatus==1, 1, 'last');
orig_p.loIdx = find(orig_p.slotStatus==1, 1, 'last');

% Update vehicle pointer for obj
obj.BQ = p.vehicles{2};
obj.FQ = obj;

% Update vehicle pointers for trailing vehicle in original platoon
orig_p.vehicles{orig_p.loIdx}.BQ = orig_p.vehicles{orig_p.loIdx};

% Update follower vehicles in new trailing platoon
for i = find(p.slotStatus==1)'
    p.vehicles{i}.p = p;
    p.vehicles{i}.Leader = p.vehicles{1};
    p.vehicles{i}.idx = i;
    if ~isempty(p.vehicles{i}.pJoin)
        p.vehicles{i}.pJoin = [];
        p.vehicles{i}.idxJoin = [];
        p.vehicles{i}.mergePlatoonV = [];
    end
end

end
