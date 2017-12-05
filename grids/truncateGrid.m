function [gNew, dataNew] = truncateGrid(gOld, dataOld, xmin, xmax, process)
% [gNew, dataNew] = truncateGrid(gOld, dataOld, xmin, xmax)
%    Truncates dataOld to be within the bounds xmin and xmax
%
% Inputs:
%   gOld, gNew - old and new grid structures
%   dataOld    - data corresponding to old grid structure
%   process    - specifies whether to call processGrid to generate
%                grid points
%
% Output: dataNew    - equivalent data corresponding to new grid structure
%
% Mo Chen, 2015-08-27

% Gather indices of new grid vectors that are within the bounds of the old
% grid

if nargin < 5
  process = true;
end

gNew.dim = gOld.dim;
gNew.vs = cell(gNew.dim, 1);
gNew.N = zeros(gNew.dim, 1);
gNew.min = zeros(gNew.dim, 1);
gNew.max = zeros(gNew.dim, 1);
gNew.bdry = gOld.bdry;
small = 1e-3;

for i = 1:gNew.dim
  gNew.vs{i} = gOld.vs{i}(gOld.vs{i} > xmin(i) & gOld.vs{i} < xmax(i));
  gNew.N(i) = length(gNew.vs{i});
  gNew.min(i) = min(gNew.vs{i});
  if gNew.N(i) == 1
    gNew.max(i) = max(gNew.vs{i}) + small;
  else
    gNew.max(i) = max(gNew.vs{i});
  end
  if gNew.N(i) < gOld.N(i)
    gNew.bdry{i} = @addGhostExtrapolate;
  end
end

if process
  gNew = processGrid(gNew);
end

if nargout < 2
  return
end

dataNew = [];
% Truncate everything that's outside of xmin and xmax
switch gOld.dim
  case 1
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin & gOld.vs{1}<xmax);
    end
    
  case 2
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2));
    end
    
  case 3
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
        gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3) );
    end
    
  case 4
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
        gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3), ...
        gOld.vs{4}>xmin(4) & gOld.vs{4}<xmax(4) );
    end
    
  otherwise
    error('truncateGrid has only been implemented up to 4 dimensions!')
end


end