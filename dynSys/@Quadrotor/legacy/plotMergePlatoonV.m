function plotMergePlatoonV(obj)
% function plotMergePlatoonV(obj)
%
% Plots the value function for merging with platoon
%
% Input: obj - quadrotor object
%
% Mo Chen, 2015-06-21
% 
% if isempty(obj.pJoin)
%     warning('Vehicle already finished merging into platoon.')
%     return
% end

% State dimensions for position and velocity
pdim = obj.pdim;
vdim = obj.vdim;

% Unpack constants
if ~isempty(obj.mergePlatoonV)
    mergeV = obj.mergePlatoonV;
else
    delete(obj.hmergePlatoonV);
    obj.hmergePlatoonV = [];
    return
end

% Leader
if isempty(obj.Leader)
  Leader = obj.pJoin.vehicles{1}; 
else
  Leader = obj.Leader;
end

tau = mergeV.tau;
g1 = mergeV.g1;
g2 = mergeV.g2;
datax = mergeV.datax;
datay = mergeV.datay;

% ----- Construct grid -----
% Position domain should cover all grid positions around the OTHER vehicle
% since p = [px py] indicates that this vehicle is at (px, py) where the
% origin is centered around the other vehicle
%
% Velocity domain should cover a thin layer around current relative
% velocity

% Slice to visualize

max_domain_size = 1;
domain_thickness = 3.1;
xmin = zeros(4,1);
xmin(1) = max_domain_size*g1.min(1);
xmin(2) = obj.x(vdim(1))-Leader.x(vdim(1)) - domain_thickness*g1.dx(2);
xmin(3) = max_domain_size*g2.min(1);
xmin(4) = obj.x(vdim(2))-Leader.x(vdim(2)) - domain_thickness*g2.dx(2);

xmax = zeros(4,1);
xmax(1) = max_domain_size*g1.max(1);
xmax(2) = obj.x(vdim(1))-Leader.x(vdim(1)) + domain_thickness*g1.dx(2);
xmax(3) = max_domain_size*g2.max(1);
xmax(4) = obj.x(vdim(2))-Leader.x(vdim(2)) + domain_thickness*g2.dx(2);

% Compute value for V(t,x) on the relative velocity slice and project down
% to 2D
[~, ~, g4D, value, ~] = recon2x2D(tau, g1, datax, g2, datay, [xmin xmax], inf);
xs = obj.x(vdim)-Leader.x(vdim);

% figure;
% Shift the grid!!!
[g2D, value2D] = proj2D(g4D, [0 1 0 1], g4D.N([1 4]), value, xs);
g2Dt.dim = g2D.dim;
g2Dt.min = g2D.min + Leader.x(pdim);
g2Dt.max = g2D.max + Leader.x(pdim);
g2Dt.N = g2D.N;
g2Dt.bdry = g2D.bdry;
g2Dt = processGrid(g2Dt);

% Plot result
if isempty(obj.hmergePlatoonV) || ~isvalid(obj.hmergePlatoonV)
    [~, obj.hmergePlatoonV] = contour(g2Dt.xs{1}, g2Dt.xs{2}, value2D, [0 0], ...
        'lineStyle', ':', 'linewidth', 2);

else
    obj.hmergePlatoonV.XData = g2Dt.xs{1};
    obj.hmergePlatoonV.YData = g2Dt.xs{2};
    obj.hmergePlatoonV.ZData = value2D;
end

% Color
if isempty(obj.hpxpyhist.Color)
    obj.hmergePlatoonV.LineColor = 'b';
else
   obj.hmergePlatoonV.LineColor = obj.hpxpyhist.Color;
end


end