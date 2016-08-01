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

% Custom derivative for MIE
if isfield(schemeData, 'deriv')
  deriv = schemeData.deriv;
end

%% Copy state matrices in case we're doing MIE
% Dimension information (in case we're doing MIE)
% TIdim = [];
dims = 1:dynSys.nx;
if isfield(schemeData, 'MIEdims')
%   TIdim = schemeData.TIdim;
  dims = schemeData.MIEdims;
end
% 
% TIderiv = -1; % Coefficient correction (for MIE only)
% dc = 0; % Dissipation compensation (for MIE only)

x = cell(dynSys.nx, 1);
x(dims) = g.xs;

%% Optimal control and disturbance
if isfield(schemeData, 'uIn')
  u = schemeData.uIn;
else
  u = dynSys.optCtrl(t, x, deriv, schemeData.uMode);
end

if isfield(schemeData, 'dIn')
  d = schemeData.dIn;
else
  d = dynSys.optDstb(t, x, deriv, schemeData.dMode);
end

%% Plug optimal control into dynamics to compute Hamiltonian
dx = dynSys.dynamics(t, x, u, d);
hamValue = 0;

% for i = 1:length(dims)
for i = 1:dynSys.nx
  hamValue = hamValue + deriv{i}.*dx{i};
end

% %% Modified Hamiltonian for MIE formulation, if needed
% % Compute coefficient correction and dissipation compensation if necessary
% if isfield(schemeData, 'absValDeriv');
%   uZero = schemeData.uZero;
%   lZero = schemeData.lZero;
%   
%   [derivL, derivR] = absValDeriv(schemeData.absValDeriv, lZero, uZero, data);
%   TIderiv = 0.5*(derivL + derivR);
%   
%   dc = dissComp(derivL, derivR, t, data, schemeData);
% end
% 
% if ~isempty(TIdim)
%   dx = dynSys.dynamics(t, x, u, d, TIdim);
%   hamValue = hamValue + TIderiv.*dx{1} - dc;
% end


%% Negate hamValue if backward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
end

end