function [ul, uu, cInds] = jointCtrl_MIE(t, datals, dataus, schemeData)
% [ul, uu, cInds] = jointCtrl_MIE(t, datals, dataus, schemeData)
% Only for double integrator maximal reachable set!

%% Preliminaries
% Unpack 1D grid
g = schemeData.grid;
dynSys = schemeData.dynSys;
uModeU = schemeData.uModeU;
uModeL = schemeData.uModeL;
MIEdims = schemeData.MIEdims;

Pl = extractCostates(g, datals);
Pu = extractCostates(g, dataus);

ul = zeros(size(datals));
uu = zeros(size(dataus));

%% Control when boundaries are far away
% Control if boundaries are independent
uli = dynSys.optCtrl(t, g.xs, Pl, uModeL, MIEdims);
uui = dynSys.optCtrl(t, g.xs, Pu, uModeU, MIEdims);

% Control if boundaries are dependent
this_active_inds = datals < dataus;

ul(this_active_inds) = uli(this_active_inds);
ul(~this_active_inds) = uui(~this_active_inds);

uu(this_active_inds) = uui(this_active_inds);
uu(~this_active_inds) = uli(~this_active_inds);

%% Control when the boundaries are near each other
% Assumed spacing in x direction
dx = g.dx; % Equal spacing
grid_width = 6; % local grid width (in number of grid points)
actual_width = 2; % grid width for applying joint control
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
    min(g.vs{1}(cInds{i})) - extra_width*dx, ...
    max(g.vs{1}(cInds{i})) + extra_width*dx);
  [~, datau_local] = truncateGrid(g, dataus, ...
    min(g.vs{1}(cInds{i})) - extra_width*dx, ...
    max(g.vs{1}(cInds{i})) + extra_width*dx);
  
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
  
  ul(cInds{i}) = dynSys.optCtrl(t, {g.xs{1}(cInds{i})}, {p2l}, uModeL, MIEdims);
  uu(cInds{i}) = dynSys.optCtrl(t, {g.xs{1}(cInds{i})}, {p2u}, uModeL, MIEdims);
end

cInds = cell2mat(cInds);
end