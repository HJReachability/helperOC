function data = ...
  computeDataByUnion(base_g, base_data, g, data0, pdims, adim, bdry_only)
% data = ...
%   computeDataByUnion(base_g, base_data, g, data0, pdims, adim, bdry_only)
%       Computes the reachable set using by taking unions of a base
%       reachable translated and rotated according to the states in the 
%       target set
%
% Inputs:
%   g         - grid structure corresponding to target set
%   data0     - target set (initial condition)
%                   The union will be taken over the set of points at which
%                   data0 is negative; shifts and rotations are determined
%                   by the corresponding indices in g.xs
%   base_g    - base grid structure
%   base_data - base reachable set represented on the grid g
%                   For better computation speed, migrate base_g and
%                   base_data to a coarser grid before calling this 
%                   function
%   pdims     - dimensions that represent position
%   adim      - dimension that represents heading
%   bdry_only - set to true to take the union only over boundary points
%                   If true, remember to take union of data and the
%                   full-dimensional initial condition
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

if nargin < 6
  bdry_only = true;
end

% Get indices of points inside target
if bdry_only
  near_and_in = find(bwperim(data0<0));
else
  near_and_in = find(data0<0);
end

disp([num2str(nnz(near_and_in)) ' out of ' num2str(nnz(data0<0)) ...
  ' grid points near the interface'])

% Get the list of shifts and rotations
shifts = zeros(nnz(near_and_in), g.dim);
shifts_x = g.xs{pdims(1)}(near_and_in);
shifts_y = g.xs{pdims(2)}(near_and_in);
shifts(:, pdims) = [shifts_x shifts_y];

if ~isempty(adim)
  thetas = g.xs{adim}(near_and_in);
end

% Take the union of base reachable sets that are shifted and rotated
data = inf(g.shape);
for i = 1:length(near_and_in)
  if isempty(adim)
    data_rot = base_data;
  else
    data_rot = rotateData(base_g, base_data, thetas(i), pdims, adim);
  end
  
  g_shift = shiftGrid(base_g, shifts(i,:));
  data_rot_shift_migrated = migrateGrid(g_shift, data_rot, g);
%   data_rot_shift = shiftData(base_g, data_rot, shifts(i,:), pdims);
%   data_rot_shift_migrated = migrateGrid(base_g, data_rot_shift, g);
  data = min(data, data_rot_shift_migrated);
end
end
