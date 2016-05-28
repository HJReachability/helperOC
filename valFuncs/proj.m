function [gOut, dataOut] = proj(g, data, dims, xs, NOut)

if length(dims) ~= g.dim
  error('Dimensions are inconsistent!')
end

if nnz(~dims) == g.dim
  gOut = g;
  dataOut = data;
  warning('Input and output dimensions are the same!')
  return
end

if nargin < 4
  xs = 'min';
end

if isnumeric(xs) && length(xs) ~= nnz(dims)
  error('Dimension of xs and dims do not match!')
end

if nargin < 5
  NOut = g.N(~dims);
end

dims = logical(dims);

% Create ouptut grid by keeping dimensions that we are not collapsing
gOut.dim = nnz(~dims);
gOut.min = g.min(~dims);
gOut.max = g.max(~dims);
gOut.bdry = g.bdry(~dims);

if numel(NOut) == 1
  gOut.N = NOut*ones(gOut.dim, 1);
else
  gOut.N = NOut;
end

gOut = processGrid(gOut);

% Only compute the grid if value function is not requested
if nargout < 2
  return
end

temp = eval(getCmdStr_projData(g.dim, dims));
dataOut = squeeze(temp);
dataOut = eval(getCmdStr_matchGrid(g.dim, dims));
end

function cmdStr = getCmdStr_projData(totalDim, dims)
% For example, if totalDim = 4, dims = [0 1 0 1], returns the string 
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data, g.vs{1}, xs(1), ...
%   g.vs{3}, xs(2));

cmdStr = 'interpn(';
% interpn(

for i = 1:totalDim
  cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}, ']);
end
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, 

cmdStr = cat(2, cmdStr, 'data, ');
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data, 

xsDim = 1;
for i = 1:totalDim
  if dims(i)
    cmdStr = cat(2, cmdStr, ['xs(' num2str(xsDim) ')']);
    xsDim = xsDim + 1;
  else
    cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}']);
  end
  
  if i < totalDim
    cmdStr = cat(2, cmdStr, ', ');
  else
    cmdStr = cat(2, cmdStr, ')');
  end
end
% interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, data, g.vs{1}, xs(1), ...
%   g.vs{3}, xs(2));

end

function cmdStr = getCmdStr_matchGrid(totalDim, dims)
% For example, if totalDim = 3 and dims = [0 1 0], returns the string
%   interpn(g.vs{1}, g.vs{3}, dataOut, gOut.xs{1}, gOut.xs{2})

cmdStr = 'interpn(';
% interpn(

for i = 1:totalDim
  if ~dims(i)
    cmdStr = cat(2, cmdStr, ['g.vs{' num2str(i) '}, ']);
  end
end
% interpn(g.vs{1}, g.vs{3}, 

cmdStr = cat(2, cmdStr, 'dataOut, ');
% interpn(g.vs{1}, g.vs{3}, dataOut, 

for i = 1:nnz(~dims)
  cmdStr = cat(2, cmdStr, ['gOut.xs{' num2str(i) '}']);
  
  if i < nnz(~dims)
    cmdStr = cat(2, cmdStr, ', ');
  else
    cmdStr = cat(2, cmdStr, ')');
  end
end
% interpn(g.vs{1}, g.vs{3}, dataOut, gOut.xs{1}, gOut.xs{2})

end