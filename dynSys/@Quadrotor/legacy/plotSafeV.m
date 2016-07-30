function plotSafeV(obj, others, safeV, t)
% function plotSafeV(obj, other, t)
%
% Plots the safe region around other that obj must stay out of in order to
% be safe.
%
% Inputs: obj   - this quadrotor
%         other - other quadrotor
%         safeV - Reachable set
%         t     - time horizon
%
% Mo Chen, 2015-06-21

% Check input
others = checkVehiclesList(others, 'quadrotor');

% Safety time horizon
if nargin<4
  t = obj.tauInt;
end

for i = 1:length(others)
  %% Construct grid
  % Position domain should cover all grid positions around the OTHER vehicle
  % since p = [px py] indicates that this vehicle is at (px, py) where the
  % origin is centered around the other vehicle
  %
  % Velocity domain should cover a thin layer around current relative
  % velocity
  
  reference = zeros(2*safeV.g.dim, 1);
  if safeV.g.dim == 2
    % Reference for reconstruction
    reference(obj.pdim) = nan;
    reference(obj.vdim) = obj.getVelocity;
    
    % Relative and absolute velocity slice for projection
    slice = zeros(4,1);
    slice([1 3]) = obj.getVelocity - others{i}.getVelocity;
    slice([2 4]) = obj.getVelocity;
  elseif safeV.g.dim == 3
    % Reference for reconstruction
    reference([1 4]) = nan;
    reference([2 5]) = obj.getVelocity - others{i}.getVelocity;
    reference([3 6]) = obj.getVelocity;
    
    % Relative velocity slice for projection
    slice = obj.getVelocity - others{i}.getVelocity;    
  else
    error('Unexpected grid dimension (expected 2 or 3)!')
  end
  
  [xmin, xmax] = highDimGridBounds(safeV.g, reference);
  
  %% Compute V(t,x) on the relative velocity slice and project down to 2D
  [g2D, value2D] = reconProj2D(safeV, xmin, xmax, t, slice);
  
  %% Shift, plot, and update result
  shiftPlotUpdate(g2D, value2D, obj, others{i})
end
end

%% =======================================================================
function shiftPlotUpdate(g2D, value2D, obj, other)
% function shiftPlotUpdate(g2D, value2D, obj, other)
%
% Given 2D array for plotting, shift the grid to the other quadrotor's
% position and plots the result. Also updates the list of handles and
% corresponding quadrotor pointers
%
% Inputs: g2D     - 2D grid structure (unshifted)
%         value2D - 2D reachable set data
%         obj     - this quadrotor
%         other   - other quadrotor
%
% Mo Chen, 2015-10-20

% Shift the grid
shiftAmount = other.getPosition;
g2Dt = shift2DGrid(g2D, shiftAmount);

% Check if the vehicle is already in the list of safe reachable sets being
% plotted, and if plot already exists, simply update the plot
newPlot = true;
for i = 1:length(obj.safeV_vehicles)
  if isequal(other, obj.safeV_vehicles{i})
    obj.hsafeV{i}.XData = g2Dt.xs{1};
    obj.hsafeV{i}.YData = g2Dt.xs{2};
    obj.hsafeV{i}.ZData = value2D;
    obj.hsafeV{i}.Visible = 'on';
    newPlot = false;
    break;
  end
end

% If not, add a figure handle and a quadrotor to the plotted list
if newPlot
  % Create figure handle
  [~, hsafeV] = contour(g2Dt.xs{1}, g2Dt.xs{2}, value2D, ...
    [0 0], 'lineStyle', '--');
  
  if isempty(obj.hpxpyhist.Color)
    hsafeV.Color = [0.5, 0.5, 0.5];
  else
    hsafeV.Color = obj.hpxpyhist.Color;
  end
  
  % Update lists
  if isempty(obj.hsafeV)
    obj.hsafeV = {hsafeV};
    obj.safeV_vehicles = {other};
  else
    obj.hsafeV = {obj.hsafeV; hsafeV};
    obj.safeV_vehicles = {obj.safeV_vehicles; other};
  end
end
end