function [grids, datas, tau] = computeV_relDyn(obj, x)
% Reachable set from target state
if isempty(obj.mergePlatoonV)
  [grids, datas, tau] = quad2D_joinHighwayPlatoon(x, 0);
  obj.mergePlatoonV.grids = grids;
  obj.mergePlatoonV.datas = datas;
  obj.mergePlatoonV.tau = tau;
else
  grids = obj.mergePlatoonV.grids;  
  datas = obj.mergePlatoonV.datas;
  tau = obj.mergePlatoonV.tau;
end
end