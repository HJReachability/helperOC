function hamValue = genericHam(t, data, deriv, schemeData)
% function hamValue = genericHam(t, data, deriv, schemeData)

%% Input unpacking
g = schemeData.grid;
dynSys = schemeData.dynSys;

if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

if ~isfield(schemeData, 'dMode')
  schemeData.dMode = 'min';
end

if ~isfield(schemeData, 'tMode')
  schemeData.tMode = 'backward';
end

TIdim = [];
dims = 1:dynSys.nx;
if isfield(schemeData, 'MIEdims')
  TIdim = schemeData.TIdim;
  dims = schemeData.MIEdims;
end

dxCoef = -1; % Coefficient correction (for MIE only)
dc = 0; % Dissipation compensation (for MIE only)

%% Optimal control and disturbance
if isfield(schemeData, 'uIn')
  u = schemeData.uIn;
else
  u = dynSys.optCtrl(t, g.xs, deriv, schemeData.uMode, dims);
end

if isfield(schemeData, 'dIn')
  d = schemeData.dIn;
else
  d = dynSys.optDstb(t, g.xs, deriv, schemeData.dMode, dims);
end

%% Plug optimal control into dynamics to compute Hamiltonian
x = cell(dynSys.nx, 1);
x(dims) = g.xs;

dx = dynSys.dynamics(t, x, u, d, dims);
hamValue = 0;

for i = 1:length(dims)
  hamValue = hamValue + deriv{i}.*dx{i};
end

%% Modified Hamiltonian for MIE formulation, if needed
% Compute coefficient correction and dissipation compensation if necessary
if isfield(schemeData, 'absValDeriv');
  uZero = schemeData.uZero;
  lZero = schemeData.lZero;
  
  [derivL, derivR] = absValDeriv(schemeData.absValDeriv, lZero, uZero, data);
  dxCoef = 0.5*(derivL + derivR);
  
  dc = dissComp(derivL, derivR, t, data, schemeData);
  
  if strcmp(schemeData.MIEside, 'upper')
    dxCoef = -dxCoef;
%     dc = -dc;
  end  
end

if ~isempty(TIdim)
  dx = dynSys.dynamics(t, x, u, d, TIdim);
  hamValue = hamValue + dxCoef.*dx{1} - dc;
end


%% Negate hamValue if backward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
end

end