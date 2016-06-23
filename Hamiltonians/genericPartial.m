function alpha = genericPartial(t, data, derivMin, derivMax, schemeData, dim)
% alpha = genericPartial(t, data, derivMin, derivMax, schemeData, dim)

g = schemeData.grid;
dynSys = schemeData.dynSys;

if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

MIEdims = 0;
if isfield(schemeData, 'MIEdims')
  MIEdims = schemeData.MIEdims;
end

%% Compute alpha
if isfield(schemeData, 'uIn')
  % Control
  u = schemeData.uIn;
  dx = dynSys.dynamics(t, g.xs, u, MIEdims);
  alpha = abs(dx{dim + MIEdims});
else
  % Optimal control assuming maximum deriv
  uU = dynSys.optCtrl(t, g.xs, derivMax, schemeData.uMode, MIEdims);
  dxU = dynSys.dynamics(t, g.xs, uU, MIEdims);
  
  % Optimal control assuming minimum deriv
  uL = dynSys.optCtrl(t, g.xs, derivMin, schemeData.uMode, MIEdims);
  dxL = dynSys.dynamics(t, g.xs, uL, MIEdims);
  
  alpha = max(abs(dxU{dim + MIEdims}), abs(dxL{dim + MIEdims}));
end



end
