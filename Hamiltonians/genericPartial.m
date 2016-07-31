function alpha = genericPartial(t, data, derivMin, derivMax, schemeData, dim)
% alpha = genericPartial(t, data, derivMin, derivMax, schemeData, dim)

g = schemeData.grid;
dynSys = schemeData.dynSys;

if ismethod(dynSys, 'partialFunc')
%   disp('Using partial function from dynamical system')
  alpha = dynSys.partialFunc(t, data, derivMin, derivMax, schemeData, dim);
  return
end

if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

if ~isfield(schemeData, 'dMode')
  schemeData.dMode = 'min';
end

TIdim = [];
dims = 1:dynSys.nx;
if isfield(schemeData, 'MIEdims')
  TIdim = schemeData.TIdim;
  dims = schemeData.MIEdims;
end

x = cell(dynSys.nx, 1);
x(dims) = g.xs;

%% Compute control
if isfield(schemeData, 'uIn')
  % Control
  uU = schemeData.uIn;
  uL = schemeData.uIn;
 
else
  % Optimal control assuming maximum deriv
  uU = dynSys.optCtrl(t, g.xs, derivMax, schemeData.uMode, dims);
  
  % Optimal control assuming minimum deriv
  uL = dynSys.optCtrl(t, g.xs, derivMin, schemeData.uMode, dims);
end

%% Compute disturbance
if isfield(schemeData, 'dIn')
  dU = schemeData.dIn;
  dL = schemeData.dIn;
  
else
  dU = dynSys.optDstb(t, g.xs, derivMax, schemeData.dMode, dims);
  dL = dynSys.optDstb(t, g.xs, derivMin, schemeData.dMode, dims);
end
  
%% Compute alpha
x = cell(dynSys.nx, 1);
x(dims) = g.xs;

dxUU = dynSys.dynamics(t, x, uU, dU, dims(dim));
dxUL = dynSys.dynamics(t, x, uU, dL, dims(dim));
dxLL = dynSys.dynamics(t, x, uL, dL, dims(dim));
dxLU = dynSys.dynamics(t, x, uL, dU, dims(dim));
alpha = max(abs(dxUU{dim}), abs(dxUL{dim}));
alpha = max(alpha, abs(dxLL{dim}));
alpha = max(alpha, abs(dxLU{dim}));
end
