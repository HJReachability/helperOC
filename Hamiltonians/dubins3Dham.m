function hamValue = dubins3Dham(t, data, deriv, schemeData)
% hamValue = dubins3Dham(t, data, deriv, schemeData)
%   Hamiltonian function for Dubins car used with the level set toolbox
%
% Inputs:
%   schemeData - problem parameters
%     .grid: grid structure
%     .vrange: speed range of vehicle
%     .wMax:  turn rate bounds (w \in [-wMax, wMax])
%     .uMode: 'min' or 'max' (defaults to 'min')
%     .dMax:  disturbance bounds (see below)
%     .dMode: 'min' or 'max' (defaults to 'max')
%     .tMode: 'backward' or 'forward'
%
% Dynamics:
%   \dot x      = v * cos(\theta) + d1
%   \dot y      = v * sin(\theta) + d2
%   \dot \theta = u + d3
% (d1, d2) \in disk of radius dMax(1)
% d3 \in [-dMax(2), dMax(2)]
%
% Mo Chen, 2016-05-21

checkStructureFields(schemeData, 'grid', 'vrange', 'wMax');

g = schemeData.grid;

%% Speed range
vrange = schemeData.vrange;
if isscalar(vrange)
  vrange = [vrange vrange];
end
vMin = vrange(1);
vMax = vrange(2);

%% Defaults: min over control, max over disturbance, backward reachable set
if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

if ~isfield(schemeData, 'dMode')
  schemeData.dMode = 'max';
end

if ~isfield(schemeData, 'tMode')
  schemeData.tMode = 'backward';
end

if ~isfield(schemeData, 'dMax')
  schemeData.dMax = [0 0];
end

%% Modify Hamiltonian control terms based on uMode
if strcmp(schemeData.uMode, 'min')
  % the speed when the determinant term (terms multiplying v) is positive
  % or negative
  v_when_det_pos = vMin;
  v_when_det_neg = vMax;
  
  % turn rate term
  wTerm = -schemeData.wMax*abs(deriv{3});
elseif strcmp(schemeData.uMode, 'max')
  v_when_det_pos = vMax;
  v_when_det_neg = vMin;
  wTerm = schemeData.wMax*abs(deriv{3});
else
  error('Unknown uMode! Must be ''min'' or ''max''')
end

%% Hamiltonian control terms
% Speed control
hamValue = (deriv{1}.*cos(g.xs{3}) + deriv{2}.*sin(g.xs{3}) >= 0) .* ...
  (deriv{1}.*cos(g.xs{3}) + deriv{2}.*sin(g.xs{3})) * v_when_det_pos + ...
   (deriv{1}.*cos(g.xs{3}) + deriv{2}.*sin(g.xs{3}) < 0) .* ...
  (deriv{1}.*cos(g.xs{3}) + deriv{2}.*sin(g.xs{3})) * v_when_det_neg;

% turn rate control
hamValue = hamValue + wTerm;

%% Add disturbances if needed
dTerm = schemeData.dMax(1)*sqrt(deriv{1}.^2 + deriv{2}.^2) + ...
  schemeData.dMax(2)*abs(deriv{3});

if strcmp(schemeData.dMode, 'min') 
  hamValue = hamValue - dTerm;
elseif strcmp(schemeData.dMode, 'max')
  hamValue = hamValue + dTerm;
else
  error('Unknown dMode! Must be ''min'' or ''max''!')
end


%% Backward or forward reachable set
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
elseif ~strcmp(schemeData.tMode, 'forward')
  error('tMode must be ''forward'' or ''backward''!')
end
end
