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
  nSet = zeros(3^g.dim, g.dim);
  
  % Count in base 3 to get all sequences involving digits 0 to 2
  for i = 1:3^g.dim
    str = dec2base(i-1, 3, g.dim);
    for j = 1:g.dim
      nSet(i, j) = str2double(str(j));
    end
  end
  
  % Subtract 1 to get the indices relative to i
  nSet = nSet - 1;
end

%% Dealing with periodicity
for i = 1:g.dim
  if isequal(g.bdry{i}, @addGhostPeriodic)
    % Grid points
    g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));

    % Input data
    data = eval(periodicAugmentCmd(i, g.dim));
  end
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
  [isl, rN, r, c] = findIslandSingle(g.vs, shape(1, :), shape, nSet);
  isls = [isls; isl];
  rNs = [rNs; rN];
  rs = [rs; r];
  cs = [cs; c];
  
  [~, ii] = intersect(shape, isl, 'rows');
  shape(ii, :) = [];
end
end

function [isl, rN, r, c] = findIslandSingle(vs, ind, indSet, nSet)
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
  % neighbors of current point under consideration
  nbs = gadd(isl(check_ind, :), nSet);

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
  rN(i) = ( max((isl(:, i))) - min((isl(:, i))) ) / 2;
  r(i) = ( max(vs{i}(isl(:, i))) - min(vs{i}(isl(:, i))) ) / 2;
  c(i) = ( max(vs{i}(isl(:, i))) + min(vs{i}(isl(:, i))) ) / 2;
end

end