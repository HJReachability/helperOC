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
if isfield(schemeData, 'side')
  if strcmp(schemeData.side, 'lower')
    if schemeData.dissComp
      hamValue = hamValue - schemeData.dc;
    end
    
  elseif strcmp(schemeData.side, 'upper')
    if schemeData.dissComp
      hamValue = hamValue + schemeData.dc;
    end
    
    deriv{1} = -deriv{1};
    if schemeData.trueMIEDeriv
      deriv{2} = -deriv{2};
    end
    
  else
    error('Side of an MIE function must be upper or lower!')
  end
  
  if ~schemeData.trueMIEDeriv
    deriv(2) = computeGradients(schemeData.grid, data);
  end
end

% for i = 1:length(dims)
for i = 1:dynSys.nx
  hamValue = hamValue + deriv{i}.*dx{i};
end

%% Negate hamValue if backward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
end

end