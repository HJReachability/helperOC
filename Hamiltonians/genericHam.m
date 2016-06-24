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

MIEdims = 0;
if isfield(schemeData, 'MIEdims')
  MIEdims = schemeData.MIEdims;
end

%% Optimal control and disturbance
if isfield(schemeData, 'uIn')
  u = schemeData.uIn;
else
  u = dynSys.optCtrl(t, g.xs, deriv, schemeData.uMode, MIEdims);
end

if isfield(schemeData, 'dIn')
  d = schemeData.dIn;
else
  d = dynSys.optDstb(t, g.xs, deriv, schemeData.dMode, MIEdims);
end

%% Plug optimal control into dynamics to compute Hamiltonian
dx = dynSys.dynamics(t, g.xs, u, d, MIEdims);
hamValue = 0;
for i = MIEdims+1:length(dx)
  hamValue = hamValue + deriv{i-MIEdims}.*dx{i};
end

%% Modified Hamiltonian for MIE formulation, if needed
for i = 1:MIEdims
  hamValue = hamValue - dx{i};
end

%% Negate hamValue if backward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
end

end