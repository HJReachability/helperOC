function dataNew = migrateGrid(gOld, dataOld, gNew, filler)
% dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%         filler     - which values to use at unknown grid points.
%                       - select 'max' for largest data value (default)
%                       - select 'min' for smallest data value
%                       - select 'inf' for inf
%                       - select '-inf' for -inf
%
% Output: dataNew    - equivalent data corresponding to new grid structure

if nargin < 4
  filler = 'max';
end

dataDims = numDims(dataOld);
if dataDims == gOld.dim
  dataNew = migrateGridSingle(gOld, dataOld, gNew);
  
elseif dataDims == gOld.dim + 1
  numTimeSteps = size(dataOld, dataDims);
  dataNew = zeros([gNew.N' numTimeSteps]);
  colons = repmat({':'}, 1, gOld.dim);
  for i = 1:numTimeSteps
    dataNew(colons{:},i) = migrateGridSingle(gOld, ...
      dataOld(colons{:},i), gNew, filler);
  end
  
else
  error('Inconsistent input data dimensions!')
end

end

function dataNew = migrateGridSingle(gOld, dataOld, gNew, filler)
% dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%         filler     - which values to use at unknown grid points.
%                       - select 'max' for largest data value (default)
%                       - select 'min' for smallest data value
%                       - select 'inf' for inf
%                       - select '-inf' for -inf
%
% Output: dataNew    - equivalent data corresponding to new grid structure
%
% Mo Chen, 2015-08-27
if nargin < 4
  filler = 'max';
end


gNew_xsVec = zeros(prod(gNew.N), gOld.dim);
for i = 1:gOld.dim
  gNew_xsVec(:,i) = gNew.xs{i}(:);
end

dataNew = eval_u(gOld, dataOld, gNew_xsVec);

if length(gNew.N)>1
dataNew = reshape(dataNew, gNew.N');
end

if strcmp(filler, 'max')
  dataNew(isnan(dataNew)) = max(dataNew(:));
elseif strcmp(filler, 'min')
  dataNew(isnan(dataNew)) = min(dataNew(:));
elseif strcmp(filler, 'inf')
  dataNew(isnan(dataNew)) = inf;
elseif strcmp(filler, '-inf')
  dataNew(isnan(dataNew)) = -inf;
end

end