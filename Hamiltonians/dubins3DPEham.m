function hamValue = dubins3DPEham(t, data, deriv, schemeData)
% hamValue = dubins3DPEham(t, data, deriv, schemeData)
%   Hamiltonian function for the pursuit evasion game where both vehicles
%   are Dubins cars, used with level set toolbox
%
% Inputs:
%   schemeData - problem parameters
%     .grid:    grid structure
%     .virange: speed range of vehicle i
%     .wiMax:   turn rate bounds (w \in [-wMax, wMax]) of vehicle i
%     .dMax:    disturbance bounds (see below)
%     .PEmode:  pursuit-evasion mode for vehicle 1 ('evade' or 'pursue')
%
% Dynamics
%   \dot x      = -v1 + v2 cos\theta + w1 y + d1
%	  \dot y      = v2 sin\theta - w1 x       + d2
%	  \dot \theta = w2 - w1                   + d3
% (d1, d2) \in disk of radius dMax(1)
% d3 \in [-dMax(2), dMax(2)]
%
% Hamiltonian:
% H = v1 * (-p1) + v2 * (p1*cos\theta + p2*sin\theta) +
%     w1 * (p1*y - p2*x - p3) + w2 * (p3)
%
% Mo Chen, 2016-05-21

checkStructureFields(schemeData, 'grid', 'vrange1', 'vrange2', ...
  'w1Max', 'w2Max');

%% Unpack parameters
g = schemeData.grid;
vrange1 = schemeData.vrange1;
if isscalar(vrange1)
  vrange1 = [vrange1 vrange1];
end
v1Min = vrange1(1);
v1Max = vrange1(2);

vrange2 = schemeData.vrange2;
if isscalar(vrange2)
  vrange2 = [vrange2 vrange2];
end
v2Min = vrange2(1);
v2Max = vrange2(2);

w1Max = schemeData.w1Max;
w2Max = schemeData.w2Max;

% By default, vehicle 1 (assumed to be at origin) is evader
if ~isfield(schemeData, 'PEmode')
  schemeData.PEmode = 'evade';
end

%% Control determinants
det_v1 = -deriv{1};
det_v2 = deriv{1}.*cos(g.xs{3}) + deriv{2}.*sin(g.xs{3});
det_w1 = deriv{1}.*g.xs{2} - deriv{2}.*g.xs{1} - deriv{3};
det_w2 = deriv{3};

%% Add disturbances if required
dTerm = 0;
if isfield(schemeData, 'dMax');
  dTerm = schemeData.dMax(1) * sqrt(deriv{1}.^2 + deriv{2}.^2) + ...
    schemeData.dMax(2)*abs(deriv{3});
end

%% Compute Hamiltonian terms based on PEmode
if strcmp(schemeData.PEmode, 'evade')
  % player 1 maximizes, player 2 minimizes, disturbance minimizes
  v1_when_det_pos = v1Max;
  v1_when_det_neg = v1Min;
  v2_when_det_pos = v2Min;
  v2_when_det_neg = v2Max;
  
  w1term = w1Max*abs(det_w1);
  w2term = -w2Max*abs(det_w2);
  
  dTerm = -dTerm; % negate disturbance term to minimize
elseif strcmp(schemeData.PEmode, 'pursue')
  % player 1 minimizes, player 2 maximizes, disturbance maximizes
  v1_when_det_pos = v1Min;
  v1_when_det_neg = v1Max;
  v2_when_det_pos = v2Max;
  v2_when_det_neg = v2Min;
  
  w1term = -w1Max*abs(det_w1);
  w2term = w2Max*abs(det_w2);
else
  error('PEmode must be ''evade'' or ''pursue''!')
end

%% Calculate Hamiltonian
hamValue = (det_v1>=0) .* det_v1 * v1_when_det_pos + ...
  (det_v1<0) .* det_v1 * v1_when_det_neg + ...
  (det_v2>=0) .* det_v2 * v2_when_det_pos + ...
  (det_v2<0) .* det_v2 * v2_when_det_neg + w1term + w2term + dTerm;

%% Always backward reachable set
hamValue = -hamValue;
end