function vf = reconSC(vfs, range_lower, range_upper, minOverTime, constrType)
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
%   minOverTime - options:
%                 0 - do not min over time (defaults to this)
%                 'end' - minovertime at the end (saves both dataMin and
%                         all data over time)
%                 'during' - minovertime during (saves only dataMin)
%                 'full'   - computes reachable tube over time
%                 'TTR'    - Computes TTR
%
%  constrType - options
%     'max' - takes maximum over subsystem value functions (default)
%     'min' - takes minimum over subsystem value functions
%
% Output:
%   vf    - value function within the computation range
%             (by default, the computation range is within a neighborhood
%             of the state x)
%             .g
%             .data
%             .tau
%             .TTR (time-to-reach function)

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
  if vfs.gs{i}.dim ~= length(vfs.dims{i})
    error('Grid dimensions are inconsistent!')
  end
end

if nargin < 5
  constrType = 'max';
end

%% Truncate grids according to the computation range
gs_trunc = cell(num_vfs, 1);
rl = cell(num_vfs, 1);
ru = cell(num_vfs, 1);
small = 1e-3;
big = 1e6;

minN = 3; % Minimum number of grid points
for i = 1:num_vfs
  rl{i} = range_lower(vfs.dims{i});
  ru{i} = range_upper(vfs.dims{i});
  
  % If the number of grid points is less than the minimum, reduce the number of
  % grid points to 1
  for j = 1:vfs.gs{i}.dim
    new_vs = vfs.gs{i}.vs{j}(vfs.gs{i}.vs{j} > rl{i}(j) & ...
      vfs.gs{i}.vs{j} < ru{i}(j));
    if numel(new_vs) <= minN
      rl{i}(j) = new_vs(1) - small;
      ru{i}(j) = new_vs(1) + small;
    end
  end
  
  gs_trunc{i} = truncateGrid(vfs.gs{i}, [], rl{i}, ru{i});
  
%   if any(gs_trunc{i}.N < minN)
%     warning(['Number of grid points is less than ' num2str(minN) '!'])
%   end
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

if strcmp(minOverTime,'during') || strcmp(minOverTime,'TTR')
  vf.TTR = big*ones(vf.g.N');

  %% Expand look-up tables to fill in missing dimensions
  for t = 1:length(vf.tau)
    for i = 1:num_vfs
      colonsi = repmat({':'}, 1, vfs.gs{i}.dim);
      
      [~, data_trunc] = ...
        truncateGrid(vfs.gs{i}, vfs.datas{i}(colonsi{:}, t), rl{i}, ru{i});
      
      if i == 1
        vf.dataMin = backProj(vf.g,data_trunc,vfs.dims{i});
      else
        if strcmp(constrType, 'min')
          vf.dataMin = min(vf.dataMin, ...
            backProj(vf.g, data_trunc, vfs.dims{i}));
        else
          vf.dataMin = max(vf.dataMin, ...
            backProj(vf.g, data_trunc, vfs.dims{i}));
        end
      end
      
    end
    
    if t>1
      vf.dataMin = min(vf.dataMin, vf.dataLast);
    end
    vf.dataLast = vf.dataMin;
    
    if strcmp(minOverTime,'TTR')
      taui = vf.tau(t);
      if t == 1
        vf.TTR(vf.dataMin <= 0) = taui;
      else
        vf.TTR(vf.dataMin <= 0) = min(vf.TTR(vf.dataMin <= 0), taui);
      end
    end
  end
else
  %% Expand look-up tables to fill in missing dimensions
  if strcmp(constrType, 'min')
    vf.data = inf([vf.g.N' length(vf.tau)]);
  else
    vf.data = -inf([vf.g.N' length(vf.tau)]);
  end
  colons = repmat({':'}, 1, vf.g.dim);
  
  for t = 1:length(vf.tau)
    for i = 1:num_vfs
      colonsi = repmat({':'}, 1, vfs.gs{i}.dim);
      
      
      [~, data_trunc] = ...
        truncateGrid(vfs.gs{i}, vfs.datas{i}(colonsi{:}, t), rl{i}, ru{i});
      
      if strcmp(constrType, 'min')
        vf.data(colons{:}, t) = min(vf.data(colons{:}, t), ...
          backProj(vf.g, data_trunc, vfs.dims{i}));
      else
        vf.data(colons{:}, t) = max(vf.data(colons{:}, t), ...
          backProj(vf.g, data_trunc, vfs.dims{i}));
      end
      
    end
  end
end

%% Get rid of singleton dimensions
if isfield(vf,'data')
  vf.data = squeeze(vf.data);
end
vf.g.dim = nnz(vf.g.N > 1.5);
vf.g.min = vf.g.min(vf.g.N > 1.5);
vf.g.max = vf.g.max(vf.g.N > 1.5);
vf.g.dx = vf.g.dx(vf.g.N > 1.5);
vf.g.bdry = vf.g.bdry(vf.g.N > 1.5);
vf.g.bdryData = vf.g.bdryData(vf.g.N > 1.5);
vf.g.vs = vf.g.vs(vf.g.N > 1.5);
vf.g.xs = vf.g.xs(vf.g.N > 1.5);
vf.g.shape = vf.g.shape(vf.g.N > 1.5);
vf.g.N = vf.g.N(vf.g.N > 1.5);
for i = 1:vf.g.dim
  vf.g.xs{i} = squeeze(vf.g.xs{i});
end

%% If we're just interested in min over time, min over all vf.data
if strcmp(minOverTime, 'end')
  vf.dataMin = min(vf.data, [], vf.g.dim+1);
elseif strcmp(minOverTime, 'full')
  vf.dataMin = inf(size(vf.data));
  colons = repmat({':'}, 1, vf.g.dim);
  for i = 1:length(vf.tau)
    if i == 1
      vf.dataMin(colons{:}, i) = vf.data(colons{:}, 1);
    else
      vf.dataMin(colons{:}, i) = min(vf.dataMin(colons{:}, i-1), ...
        vf.data(colons{:},i));
    end
  end
end
end