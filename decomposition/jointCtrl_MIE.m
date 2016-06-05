function [ul, uu, cInds] = jointCtrl_MIE(datals, dataus, schemeData)
% Only for double integrator maximal reachable set!

%% Preliminaries
% Unpack 1D grid
g = schemeData.grid;
uMax = schemeData.uMax;

Pl = extractCostates(g, datals);
Pu = extractCostates(g, dataus);

ul = zeros(size(datals));
uu = zeros(size(dataus));

%% Control when boundaries are far away
% Indices at which the current boundary is active
this_active_inds = datals < dataus;

% Control when the boundary is active
ul(this_active_inds) = -uMax*sign(Pl{1}(this_active_inds));
uu(this_active_inds) = uMax*sign(Pu{1}(this_active_inds));

% Control when the other boundary is active
ul(~this_active_inds) = uMax*sign(Pu{1}(~this_active_inds));
uu(~this_active_inds) = -uMax*sign(Pl{1}(~this_active_inds));

%% Control when the boundaries are near each other
% Assumed spacing in x direction
dx = g.dx; % Equal spacing
grid_width = 5; % 5 grid points wide
actual_width = 2; % must be within 3 grid points to be "combined"
extra_width = grid_width - actual_width;

% Create a grid of this width in the y direction
%   width_threshold*dx \times max(g.vs{1}(cInds)) - min(g.vs{1}(cInds))
cInds = find(abs(datals - dataus) < actual_width*dx);

if isempty(cInds)
  return
end

cInds = createConsecutiveGroups(cInds);
for i = 1:length(cInds)
  % Truncate MIE grid to only contain the part where boundaries are close
  % together; width is actual_width + extra_width = grid_width
  [gMIE_local, datal_local] = truncateGrid(g, datals, ...
    min(g.vs{1}(cInds{i})) - extra_width, max(g.vs{1}(cInds{i})) + extra_width);
  [~, datau_local] = truncateGrid(g, dataus, ...
    min(g.vs{1}(cInds{i})) - extra_width, max(g.vs{1}(cInds{i})) + extra_width);
  
  % Create terminal integrator grid of width grid_width*dx
  gInds = min(cInds{i})-extra_width : max(cInds{i})+extra_width;
  gTI_min = min(min(datals(gInds), dataus(gInds)));
  gTI_max = max(max(datals(gInds), dataus(gInds)));
  gTI_N = ceil((gTI_max - gTI_min)/g.dx);
  gTI = createGrid(gTI_min, gTI_max, gTI_N);
  
  % Convert MIE functions to implicit function
  [gIm, datalIm] = MIE2Implicit(gMIE_local, datal_local, 'lower', gTI);
  [~, datauIm] = MIE2Implicit(gMIE_local, datau_local, 'upper', gTI);
  dataIm = max(datalIm, datauIm);
  PIm = extractCostates(gIm, dataIm);
  
  % Extract gradients of implicit function
  p2l = eval_u(gIm, PIm{2}, [datals(cInds{i}), g.xs{1}(cInds{i})]);
  p2u = eval_u(gIm, PIm{2}, [dataus(cInds{i}), g.xs{1}(cInds{i})]);
  
  ul(cInds{i}) = -uMax*sign(p2l);
  uu(cInds{i}) = -uMax*sign(p2u);
end
end