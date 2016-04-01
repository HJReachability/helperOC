function [gNew, dataNew] = truncateGrid(gOld, dataOld, xmin, xmax)
% [gNew, dataNew] = truncateGrid(gOld, dataOld, xmin, xmax)
%    Truncates dataOld to be within the bounds xmin and xmax
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%
% Output: dataNew    - equivalent data corresponding to new grid structure
%
% Mo Chen, 2015-08-27

% Gather indices of new grid vectors that are within the bounds of the old
% grid

gNew.dim = gOld.dim;
gNew.vs = cell(gNew.dim, 1);
gNew.N = zeros(gNew.dim, 1);
gNew.min = zeros(gNew.dim, 1);
gNew.max = zeros(gNew.dim, 1);
gNew.bdry = gOld.bdry;

for i = 1:gNew.dim
  gNew.vs{i} = gOld.vs{i}(gOld.vs{i} > xmin(i) & gOld.vs{i} < xmax(i));
  gNew.N(i) = length(gNew.vs{i});
  gNew.min(i) = min(gNew.vs{i});
  gNew.max(i) = max(gNew.vs{i});
  if gNew.N(i) < gOld.N(i)
    gNew.bdry{i} = @addGhostExtrapolate;
  end
end

gNew = processGrid(gNew);

% Truncate everything that's outside of xmin and xmax
switch gOld.dim
  case 1
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin & gOld.vs{1}<xmax);
    else
      dataNew = [];
    end
    
  case 2
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2));
    else
      dataNew = [];
    end
    
  case 3
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
        gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3) );
    else
      dataNew = [];
    end
    
  case 4
    % Data
    if ~isempty(dataOld)
      dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
        gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
        gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3), ...
        gOld.vs{4}>xmin(4) & gOld.vs{4}<xmax(4) );
    else
      dataNew = [];
    end
    
  otherwise
    error('truncateGrid has only been implemented up to 4 dimensions!')
end


end