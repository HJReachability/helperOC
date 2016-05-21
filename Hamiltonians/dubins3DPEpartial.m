function alpha = dubins3DPEpartial( ...
  t, data, derivMin, derivMax, schemeData, dim)
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
%	  \dot y      = v1 sin\theta - w1 x       + d2
%	  \dot \theta = w2 - w1                   + d3
% (d1, d2) \in disk of radius dMax(1)
% d3 \in [-dMax(2), dMax(2)]
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

switch dim
  case 1
    if (v1Min == v1Max) && (v2Min == v2Max) % Constant speeds
      alpha = abs(-v1Max + v2Max*cos(g.xs{3})) + w1Max*abs(g.xs{2});
    else
      alpha = v1Max + abs(v2Max*cos(g.xs{3})) + w1Max*abs(g.xs{2});
    end
    
    if isfield(schemeData, 'dMax')
      alpha = alpha + schemeData.dMax(1)*abs(derivMax{1}) / ...
        sqrt(derivMax{1}.^2 + derivMax{2}.^2);
    end
  case 2
    alpha = abs(v1Max*sin(g.xs{3})) + w1Max*abs(g.xs{1});
    
    if isfield(schemeData, 'dMax')
      alpha = alpha + schemeData.dMax(1)*abs(derivMax{2}) / ...
        sqrt(derivMax{1}.^2 + derivMax{2}.^2);
    end
  case 3
    alpha = w1Max + w2Max;
    
    if isfield(schemeData, 'dMax')
      alpha = alpha + schemeData.dMax(2);
    end
  otherwise
    error([ 'Partials for the game of two identical vehicles' ...
      ' only exist in dimensions 1-3' ]);
end
end