function printInfo(obj)
% printInfo(obj)
% Method of Node class
%
% Prints information about the current node

if isa(obj, 'TFM')
  %% =========================== TFM ====================================
  disp('===== TFM Info =====')
  disp(['  Highway speed = ' num2str(obj.hw_speed)])
  disp(['  Intra-platoon separation distance = ' num2str(obj.ipsd)])
  disp(['  Number of registered vehicles = ' num2str(length(obj.aas))]);
  disp(['  Collision radius = ' num2str(obj.cr)]);
  disp(['  Target threshold time = ' num2str(obj.ttt)]);
  disp(['  Reachable set threshold time = ' num2str(obj.rtt)]);
  disp(['  Period of zero order hold = ' num2str(obj.dt)]);
  disp('====================')
  
elseif isa(obj, 'Highway')
  %% ============================ Highway ===============================
  disp('===== Highway Info =====')
  disp(['  width = ' num2str(obj.width)])
  
  pla_str = '  Platoons:';
  for i = 1:length(obj.ps)
    pla_str = [pla_str ' ' num2str(obj.ps{i}.ID)];
  end
  disp(pla_str)
  disp('========================')
  
elseif isa(obj, 'Platoon')
  %% ======================= Platoon ====================================
  disp('===== Platoon Info =====')
  disp(['  ID = ' num2str(obj.ID)])
  
  veh_str = '  Vehicles:';
  for i = 1:length(obj.vehicles)
    if ~isempty(obj.vehicles{i})
      veh_str = [veh_str ' ' num2str(obj.vehicles{i}.ID)];
    end
  end
  disp(veh_str)
  
  disp(['  Slot status = ' num2str(obj.slotStatus')])
  disp(['  n = ' num2str(obj.n)])
  disp(['  FP ID = ' num2str(obj.FP.ID)])
  disp(['  BP ID = ' num2str(obj.BP.ID)])
  disp('========================')
  
elseif isa(obj, 'Vehicle')
  %% ======================= Vehicle ====================================
  disp('===== Vehicle Info =====')
  disp(['  Type = ' class(obj)])
  disp(['  ID = ' num2str(obj.ID)])
  disp(['  Mode = ' obj.q]);
  disp(['  Position = ' num2str(obj.getPosition')])
  disp(['  Velocity = ' num2str(obj.getVelocity')])
  disp(['  Heading = ' num2str(obj.getHeading)])
  disp(['  Last control = ' num2str(obj.u')])
  disp(['  tfm status = ' obj.tfm_status])
  
  if ~isempty(obj.p)
    disp(['  Platoon ID = ' num2str(obj.p.ID)])
    disp(['  FQ ID = ' num2str(obj.FQ.ID)])
    disp(['  BQ ID = ' num2str(obj.BQ.ID)])
  else
    disp('  Not in a platoon')
  end
else
    error('Unknown node type!')
  end
  disp('========================')
end