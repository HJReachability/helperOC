function vf = reconSC(vfs, range_lower, range_upper,minOverTime)
% vf = reconSC(vfs_SC, range_lower, range_upper)
%
% Inputs:
%     vfs - Self-contained (decoupled) value functions
%              .gs:     cell structure of grids
%              .tau:    common time vector
%              .datas:  cell structure of SC datas (value function look-up
%                       tables)
%              .dims: dimensions of each value function (cell}
%     eg. Dubins car with self-contained components (x, theta), (y, theta)
%                .vfs.gs:     2D grids, periodic in theta dimension
%                .datas:  {data_xt; data_yt}
%                .dims: {[1; 3]; [2; 3]}
%
%   range_lower - lower range of computation domain
%   range_upper - upper range of computation domain
%     (by default, lower and upper ranges are chosen to be within a few
%     grid points of the state x)
%
% Output:
%   vf    - value function within the computation range
%             (by default, the computation range is within a neighborhood
%             of the state x)
%             .g
%             .data
%             .tau
%
% Mo Chen, 2016-05-15

%% Input checking
% Grids and corresponding value functions
if ~isvector(vfs.gs) || ~isvector(vfs.datas)
  error('Lower and upper ranges must be vectors!')
end

% Computation range
if ~isvector(range_lower) || ~isvector(range_upper)
  error('Lower and upper ranges must be vectors!')
end

if numel(range_lower) ~= numel(range_upper)
  error('Dimension of lower and upper ranges do not agree!')
end

if any(range_upper <= range_lower)
  error('Upper range must be strictly greater than lower range!')
end

% Make sure value function has dimensions from 1 to length(range_lower)
dims = unique(cell2mat(vfs.dims));
full_dim = length(range_lower);
for i = 1:full_dim
  if dims(i) ~= i
    error('Missing value function dimension!')
  end
end

% Number of value functions
num_vfs = length(vfs.gs);
if num_vfs ~= length(vfs.datas) || num_vfs ~= length(vfs.dims)
  error('Number of value functions is inconsistent!')
end

% Subsystem grid dimensions
for i = 1:num_vfs
  if vfs.gs{i}.dim ~= length(vfs.dims)
    error('Grid dimensions are inconsistent!')
  end
end

%% Truncate grids according to the computation range
gs_trunc = cell(num_vfs, 1);
rl = cell(num_vfs, 1);
ru = cell(num_vfs, 1);

minN = 3; % Minimum number of grid points
for i = 1:num_vfs
  rl{i} = range_lower(vfs.dims{i});
  ru{i} = range_upper(vfs.dims{i});
  
  gs_trunc{i} = truncateGrid(vfs.gs{i}, [], rl{i}, ru{i});
  
  if any(gs_trunc{i}.N < minN)
    warning(['Number of grid points is less than ' num2str(minN) '!'])
  end
end

%% Create full dimensional grid (no periodic dimensions will remain!)
% Grid grid bounds and number of grid points
grid_min = zeros(full_dim, 1);
grid_max = zeros(full_dim, 1);
N = zeros(full_dim, 1);
for j = 1:num_vfs
  grid_min(vfs.dims{j}) = gs_trunc{j}.min;
  grid_max(vfs.dims{j}) = gs_trunc{j}.max;
  N(vfs.dims{j}) = gs_trunc{j}.N;
end

% Make sure the diffent truncated grids have the same bounds and number of
% grid points in each dimension (just a sanity check)
for i = 1:full_dim
  for j = 1:num_vfs
    if any(grid_min(vfs.dims{j}) ~= gs_trunc{j}.min)
      error('Lower bounds of truncated grids are not compatible!')
    end
    
    if any(grid_max(vfs.dims{j}) ~= gs_trunc{j}.max)
      error('Upper bounds of truncated grids are not compatible!')
    end
    
    if any(N(vfs.dims{j}) ~= gs_trunc{j}.N)
      error('Upper bounds of truncated grids are not compatible!')
    end
  end
end

% Actually create the grid
vf.g = createGrid(grid_min, grid_max, N);

%% Time stamps
vf.tau = vfs.tau;

%% Expand look-up tables to fill in missing dimensions
vf.data = -inf([vf.g.N' length(vf.tau)]); 
colons = repmat({':'}, 1, vf.g.dim);

for i = 1:num_vfs
  colonsi = repmat({':'}, 1, vfs.gs{i}.dim);

  for t = 1:length(vf.tau)
    [~, data_trunc] = ...
      truncateGrid(vfs.gs{i}, vfs.datas{i}(colonsi{:}, t), rl{i}, ru{i});
    
    vf.data(colons{:}, t) = max(vf.data(colons{:}, t), ...
      fillInMissingDims(vf.g, data_trunc, vfs.dims{i}));
  end
end

%% If we're just interested in min over time, min over all vf.data
if minOverTime
  vf.data = min(vf.data,[],vf.g.dim+1);
end
end