function alpha = dubins3Dpartial( ...
  t, data, derivMin, derivMax, schemeData, dim)
% Inputs:
%   schemeData - problem parameters
%     .grid: grid structure
%     .vrange: speed range of vehicle
%     .wMax:  turn rate bounds (w \in [-wMax, wMax])
%     .dMax:  disturbance bounds (see below)
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
vMax = max(schemeData.vrange);

switch dim
  case 1
    % Control
    alpha = vMax*abs(cos(g.xs{3}));
    
    % Disturbance if needed
    if isfield(schemeData, 'dMax')
      dMax = schemeData.dMax;
      alpha = alpha + ...
        dMax(1) * abs(derivMax{1}) / sqrt(derivMax{1}.^2 + derivMax{2}.^2);
    end
    
  case 2
    % Control
    alpha = vMax*abs(sin(g.xs{3})); 
    
    % Disturbance if needed
    if isfield(schemeData, 'dMax')
      dMax = schemeData.dMax;
      alpha = alpha + ...
        dMax(1) * abs(derivMax{2}) / sqrt(derivMax{1}.^2 + derivMax{2}.^2);
    end
    
  case 3
    % Control
    alpha = schemeData.wMax;
    
    % Disturbance if needed
    if isfield(schemeData, 'dMax')
      dMax = schemeData.dMax;
      alpha = alpha + dMax(2);
    end
end
end