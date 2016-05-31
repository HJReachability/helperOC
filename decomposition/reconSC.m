function vf = reconSC(vfs_SC, range_lower, range_upper)
% vf = reconSC(vfs_SC, range_lower, range_upper)
%    UNTESTED!!!!!
%
% Inputs:
%   vfs_SC  - Self-contained value functions
%              .gs:     cell structure of grids
%              .tau:    common time vector
%              .datas:  cell structure of SC datas (value function look-up
%                       tables)
%              .SCdims: dimensions of each value function (cell}
%     eg. Dubins car with self-contained components (x, theta), (y, theta)
%         vfs_MIE.gs:     2D grids, periodic in theta dimension
%                .datas:  {data_xt; data_yt}
%                .SCdims: {[1; 3]; [2; 3]}
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
if ~isvector(vfs_SC.gs) || ~isvector(vfs_SC.datas)
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

% Value function dimensions
dims = unique(cell2mat(vfs_SC.SCdims));
full_dim = length(range_lower);
for i = 1:full_dim
  if dims(i) ~= i
    error('Missing value function dimension!')
  end
end

% Number of value functions
num_vfs = length(vfs_SC.gs);
if num_vfs ~= length(vfs_SC.datas) || num_vfs ~= length(vfs_SC.SCdims)
  error('Number of value functions is inconsistent!')
end

% Subsystem grid dimensions
for i = 1:num_vfs
  if vfs_SC.gs{i}.dim ~= length(vfs_SC.SCdims)
    error('Grid dimensions are inconsistent!')
  end
end

%% Truncate grids according to the computation range
gs_trunc = cell(num_vfs, 1);
rl = cell(num_vfs, 1);
ru = cell(num_vfs, 1);

minN = 3; % Minimum number of grid points
for i = 1:num_vfs
  rl{i} = range_lower(vfs_SC.SCdims{i});
  ru{i} = range_upper(vfs_SC.SCdims{i});
  
  gs_trunc{i} = truncateGrid(vfs_SC.gs{i}, [], rl{i}, ru{i});
  
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
  grid_min(vfs_SC.SCdims{j}) = gs_trunc{j}.min;
  grid_max(vfs_SC.SCdims{j}) = gs_trunc{j}.max;
  N(vfs_SC.SCdims{j}) = gs_trunc{j}.N;
end

% Make sure the diffent truncated grids have the same bounds and number of
% grid points in each dimension
for i = 1:full_dim
  for j = 1:num_vfs
    if any(grid_min(vfs_SC.SCdims{j}) ~= gs_trunc{j}.min)
      error('Lower bounds of truncated grids are not compatible!')
    end
    
    if any(grid_max(vfs_SC.SCdims{j}) ~= gs_trunc{j}.max)
      error('Upper bounds of truncated grids are not compatible!')
    end
    
    if any(N(vfs_SC.SCdims{j}) ~= gs_trunc{j}.N)
      error('Upper bounds of truncated grids are not compatible!')
    end
  end
end

% Actually create the grid
vf.g = createGrid(grid_min, grid_max, N);

%% Time stamps
vf.tau = vfs_SC.tau;

%% Initialize truncated data
datas_trunc = cell(num_vfs, 1);
for i = 1:num_vfs
  datas_trunc{j} = zeros(vf.g.N');
end

%% Expand look-up tables to fill in missing dimensions
vf.data = -inf([vf.g.N' length(vf.tau)]);

for i = 1:length(vf.tau)
  for j = 1:num_vfs
    % vfs_SC.datas{j}(:,:,:,i)
    dataRawStr = get_dataStr(gs_trunc{j}.dim, 'i', 'vfs_SC.datas{j}');
    
    % datas_trunc{j}(:,:,:,i)
    dataTruncStr = get_dataStr(gs_trunc{j}.dim, 'i', 'datas_trunc{j}');
    
    % vf.data(:,:,:,i)
    dataOutStr = get_dataStr(vf.g.dim, 'i', 'vf.data');

    % Truncate data
    % [~, datas_trunc{j}(:,:,:,i)] = ...
    %   truncateGrid(vfs_SC.gs{j}, vfs_SC.datas{j}(:,:,:,i), rl{j}, ru{j});
    eval(['[~, ' dataTruncStr '] = truncateGrid(vfs_SC.gs{j}, ' ... 
      dataRawStr ', rl{j}, ru{j});'])
    
    % Expand and take maximum 
    % vf.data(:,:,:,i) = max(vf.data(:,:,:,i), ...
    %   fillInMissingDims(vf.g, datas_trunc{j}(:,:,i), vfs_SC.SCdims{j}));
    eval([dataOutStr ' = max(' dataOutStr ', fillInMissingDims(' ...
        'vf.g, ' dataTruncStr ', vfs_SC.SCdims{j}));'])
  end
end

end