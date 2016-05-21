function data = computeDataByUnion(bg, bdata, g, target, pdims, adim)
% data = computeDataByUnion(bg, bdata, g, target, pdims, adim)
%   Computes the reachable set using by taking unions of a base reachable
%   translated and rotated according to the states in the target set
%
% 
%
% Mo Chen, 2016-05-18

% Default position dimensions
if nargin < 6
  pdims = [1 2];
end

% Default angle dimension
if nargin < 6
  adim = 3;
end

% Transfer base data to the same grid as the target set
bdata = migrateGrid(bg, bdata, g);

% Get indices of points inside target
in_target = find(target<0);

% Get the list of shifts and rotations
shifts_x = g.xs{pdims(1)}(in_target);
shifts_y = g.xs{pdims(2)}(in_target);
shifts = [shifts_x shifts_y];

if ~isempty(adim)
  thetas = g.xs{adim}(in_target);
end

% Take the union of base reachable sets that are shifted and rotated
data = inf(g.shape);
for i = 1:length(in_target)
  data_rot = rotateData(g, bdata, thetas(i), pdims, adim);
  data_rot_shift = shiftData(g, data_rot, shifts(i,:), pdims);
  data = min(data, data_rot_shift);
end

end
