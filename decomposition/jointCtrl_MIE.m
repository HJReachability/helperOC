function [ul, uu, cInds] = jointCtrl_MIE(t, datals, dataus, schemeData)
% [ul, uu, cInds] = jointCtrl_MIE(t, datals, dataus, schemeData)
% Only for double integrator maximal reachable set!

%% Preliminaries
% Unpack 1D grid
g = schemeData.grid;
dynSys = schemeData.dynSys;
uMode = schemeData.uMode;
MIEdims = schemeData.MIEdims;

% Compute implied gradient of the implicit value function V
grad_l = computeGradients(g, datals); % For lower function, Vlower = phi - x
grad_u = computeGradients(g, -dataus); % For upper function, Vupper = x - phi

ul = zeros(size(datals));
uu = zeros(size(dataus));

%% Control when Vupper and Vlower differ by a lot
% Control if boundaries are independent
uli = dynSys.optCtrl(t, g.xs, grad_l, uMode, MIEdims);
uui = dynSys.optCtrl(t, g.xs, grad_u, uMode, MIEdims);

% Control if boundaries are dependent
this_active_inds = datals < dataus;

ul(this_active_inds) = uli(this_active_inds);
ul(~this_active_inds) = uui(~this_active_inds);

uu(this_active_inds) = uui(this_active_inds);
uu(~this_active_inds) = uli(~this_active_inds);

%% Control when Vupper and Vlower affect each other's gradients
grid_width = 3;            % local grid width (in number of grid points)
width = grid_width * g.dx; % local grid width

% Range of MIE functions
maxIR_datau = movmax(dataus, 2*grid_width+1);
minIR_datau = movmin(dataus, 2*grid_width+1);
maxIR_datal = movmax(datals, 2*grid_width+1);
minIR_datal = movmin(datals, 2*grid_width+1);

% Range of implicit functions at x = datal
maxIR_Vu = datals - maxIR_datau;
minIR_Vu = datals - minIR_datau;
maxIR_Vl = maxIR_datal - datals;
minIR_Vl = minIR_datal - datals;

% Need common control for indices where upper and lower value function ranges
% overlap (this is sufficient, but not necessary)
cInds = find(maxIR_Vu>=minIR_Vl & minIR_Vu<=maxIR_Vl);

if isempty(cInds)
  return
end

for i = 1:length(cInds)
  % Lower common control
  [gMIE_lower, datall_local] = truncateGrid(g, datals - datals(cInds(i)), ...
    min(g.xs{1}(cInds(i))) - width, max(g.xs{1}(cInds(i))) + width);
  [~, dataul_local] = truncateGrid(g,  datals(cInds(i)) - dataus, ...
    min(g.xs{1}(cInds(i))) - width, max(g.xs{1}(cInds(i))) + width);
  
  datal_local = max(datall_local, dataul_local);
  PMIEl = computeGradients(gMIE_lower, datal_local);
  pMIEl = eval_u(gMIE_lower, PMIEl, g.xs{1}(cInds(i)));
  
  ul(cInds(i)) = dynSys.optCtrl(t, g.xs{1}(cInds(i)), {pMIEl}, uMode, MIEdims);
  
  % Upper common control
  [gMIE_upper, datalu_local] = truncateGrid(g, datals - dataus(cInds(i)), ...
    min(g.xs{1}(cInds(i))) - width, max(g.xs{1}(cInds(i))) + width);
  [~, datauu_local] = truncateGrid(g,  dataus(cInds(i)) - dataus, ...
    min(g.xs{1}(cInds(i))) - width, max(g.xs{1}(cInds(i))) + width);
  
  datau_local = max(datalu_local, datauu_local);
  PMIEu = computeGradients(gMIE_upper, datau_local);
  pMIEu = eval_u(gMIE_lower, PMIEu, g.xs{1}(cInds(i)));  
  
  uu(cInds(i)) = dynSys.optCtrl(t, g.xs{1}(cInds(i)), {pMIEu}, uMode, MIEdims);
end
end