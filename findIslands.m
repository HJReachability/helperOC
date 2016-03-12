function [isls, rNs, rs, cs] = findIslands(g, data, level, nSet)
% [isls, rNs, rs, cs] = findIslands(g, data, level, nSet)
%
% Finds all islands described by the elements of data that are below a certain
% level.
%
% Inputs:  g     - grid structure
%          data  - data containing shape (value function)
%          level - level to be considered
%          nSet  - neighborhood set (of every grid point)
%
% Outputs: isls  - cell structure of indices of each island
%          rNs   - cell structure of radius in # of grid points of each island
%          rs    - cell structure of radius of each island
%          cs    - cell structure of centers of each island
%
% Mo Chen, 2016-03-11

if g.dim ~= 2 && g.dim ~= 3
  error([mfilename ' has only been implemented for 2D or 3D matrices!'])
end

if nargin < 3
  level = 0;
end

%% Default neighbor set (All indices i-1 to i+1 in all dimensions)
if nargin < 4
  nSet = create_nSet(g.dim);
end

%% Find all indices below the specified level
switch g.dim
  case 2
    [i, j] = ind2sub(size(data), find(data <= level));
    shape = [i j];
  case 3
    [i, j, k] = ind2sub(size(data), find(data <= level));
    shape = [i j k];
end

%% Go through each index to gather neighbors
isls = {};
rNs = {};
rs = {};
cs = {};
while ~isempty(shape)
  [isl, rN, r, c] = findIslandSingle(g, shape(1, :), shape, nSet);
  isls = [isls; isl];
  rNs = [rNs; rN];
  rs = [rs; r];
  cs = [cs; c];
  
  [~, ii] = intersect(shape, isl, 'rows');
  shape(ii, :) = [];
end
end

function [isl, rN, r, c] = findIslandSingle(g, ind, indSet, nSet)
% [isl, rN, r, c] = findIslandSingle(vs, ind, indSet, nSet)
%
% Finds the island that the index ind belongs to in the set of indices indSet
%
% Inputs:  vs     - vector of grid points
%          ind    - index of consideration
%          indSet - set of indices from which the island is determined
%          nSet   - neighborhood set
%
% Outputs: isl    - list of indices in the island
%          rN     - radius of island in terms of # of grid points
%          r      - radius of island
%          c      - center of island
%
% Mo Chen, 2016-03-11

isl = ind;

check_ind = 1;
while check_ind <= size(isl, 1)
  indToCheck = isl(check_ind, :);
  
  % neighbors of current point under consideration
  nbs = gadd(indToCheck, nSet);
  
  % If there's a periodic grid, add neighbors for boundary points if needed
  for i = 1:g.dim
    if isequal(g.bdry{i}, @addGhostPeriodic)
      % If the current point is a boundary point (lower or upper)
      if indToCheck(i) == 1 || indToCheck(i) == g.N(i)
        extra_nSet2D = create_nSet(g.dim - 1);
        extra_nbs2D = gadd(indToCheck([1:i-1 i+1:end]), extra_nSet2D);
        
        otherSide = 1;
        if indToCheck(i) == 1
          otherSide = g.N(i);
        end
        
        extra_nbs = [extra_nbs2D(:, 1:i-1) ...
          otherSide*ones(size(extra_nbs2D, 1), 1) ...
          extra_nbs2D(:, i:end)];
        
        nbs = [nbs; extra_nbs];
      end
    end
  end
  
  % find common indices in neighbors and indices set
  [newInds, ii] = intersect(indSet, nbs, 'rows');
  
  % add common indices to list of island indices, and remove it from indices set
  isl = [isl; newInds];
  isl = unique(isl, 'rows', 'stable');
  indSet(ii, :) = [];
  check_ind = check_ind + 1;
end

dim = numel(ind);
rN = zeros(dim, 1);
r = zeros(dim, 1);
c = zeros(dim, 1);
for i = 1:dim
  % Checking for situations where periodicity is causing multiple island pieces
  if isequal(g.bdry{i}, @addGhostPeriodic)
    vp_isl_slice = virtual_pd_isl(unique(isl(:, i)), g.N(i));
  else
    vp_isl_slice = isl(:, i);
  end
  
  % Compute outputs
  rN(i) = (max(vp_isl_slice) - min(vp_isl_slice)) / 2;
  r(i) = rN(i) * g.dx(i);
  c(i) = g.min(i) + g.dx(i) * ( max(vp_isl_slice) + min(vp_isl_slice) ) / 2;
  
  if isequal(g.bdry{i}, @addGhostPeriodic) && c(i) > g.max(i)
    c(i) = c(i) - (g.max(i) + g.dx(i) - g.min(i));
  end
end

end

function vp_isl = virtual_pd_isl(isl_slice, N)
% vp_isl = virtual_pd_isl(isl_slice, N)
%
% Processes the list of indices to detect whether the island has been broken
% into two pieces due to periodicity

% Check to see if island has two pieces which are actually the same piece
pd = false;
if any(isl_slice == 1) && any(isl_slice == N)
  pd = true;
end

if pd
  % If island has two pieces, find the index of the top piece
  for k = 1:length(isl_slice)-1
    if isl_slice(k+1) - isl_slice(k) ~= 1;
      break
    end
  end
  vp_isl = [isl_slice(k+1:end); isl_slice(1:k) + N];
  
else
  vp_isl = isl_slice;
  
end
end

function nSet = create_nSet(dim)
nSet = zeros(3^dim, dim);

% Count in base 3 to get all sequences involving digits 0 to 2
for i = 1:3^dim
  str = dec2base(i-1, 3, dim);
  for j = 1:dim
    nSet(i, j) = str2double(str(j));
  end
end

% Subtract 1 to get the indices relative to i
nSet = nSet - 1;
end