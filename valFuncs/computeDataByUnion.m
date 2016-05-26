function data = computeDataByUnion(g, base_data, target, pdims, adim)
% data = computeDataByUnion(g, base_data, target, pdims, adim)
%   Computes the reachable set using by taking unions of a base reachable
%   translated and rotated according to the states in the target set
%
% Inputs:
%   g         - grid structure
%   base_data - base reachable set represented on the grid g
%                 (migrate to the common grid before calling this function!)
%   target    - target set value function
%   pdims     - dimensions that represent position
%   adim      - dimension that represents heading
%
% Output:
%   data      - value function representing reachable set
%
% See computeDataByUnion_test

% Default position dimensions
if nargin < 4
  pdims = [1 2];
end

% Default angle dimension
if nargin < 5
  adim = 3;
end

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
  data_rot = rotateData(g, base_data, thetas(i), pdims, adim);
  data_rot_shift = shiftData(g, data_rot, shifts(i,:), pdims);
  data = min(data, data_rot_shift);
end

end
