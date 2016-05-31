function dataOut = fillInMissingDims(gFull, dataIn, dataDim)
% dataOut = fillInMissingDims(gFull, dataIn, dataDim)
%   Fills in the missing dimensions in dataIn with respect to the full grid
%   gFull
%
% Inputs:
%   gFull   - full-dimensional grid structure
%   dataIn  - input data with missing dimensions
%   dataDim - data dimensions present in dataIn
%
% Output:
%   dataOut - full-dimensional data
%
% Mo Chen, 2016-05-15

%% Expand dataIn across the full dimension without repeating its values
tempSize = ones(1, gFull.dim);
tempSize(dataDim) = gFull.N(dataDim);
temp = zeros(tempSize);

% temp(1,:,:) = dataIn
eval([getFlatDataStr(gFull.dim, dataDim, 'temp') ' = dataIn;']);

%% Repeat temporary data across the missing dimensions
% dataOut = repmat(temp, gFull.N(1), 1);
dataOut = eval(getRepmatStr(gFull.dim, dataDim, 'temp'));
end

function dataStr = getFlatDataStr(full_dim, dataDim, dataName)
% dataStr = getFlatDataStr(full_dim, dataDim, dataName)
%   Outputs something like dataName(:, :, 1, 1), where the :'s are at the
%   dimensions specified by dataDim

% dataName(
dataStr = [dataName '('];

for i = 1:full_dim
  if any(i == dataDim)
    % dataName(:
    dataStr = cat(2, dataStr, ':');
  else
    % dataName(:,1
    dataStr = cat(2, dataStr, '1');
  end
  
  
  if i < full_dim
    % dataName(:,
    dataStr = cat(2, dataStr, ',');
  else
    % dataName(:,1)
    dataStr = cat(2, dataStr, ')');
  end
end

end

function repmatStr = getRepmatStr(full_dim, dataDim, dataName)
% repmatStr = getRepmatStr(full_dim, dataDim, dataName)
%   Outputs something like repmat(dataName, 1, gFull.N(2), 1)

% repmat(dataName,
repmatStr = ['repmat(' dataName ', '];

for i = 1:full_dim
  if any(i == dataDim)
    % repmat(dataName, 1
    repmatStr = cat(2, repmatStr, '1');
  else
    % repmat(dataName, 1, gFull.N(2)
    repmatStr = cat(2, repmatStr, ['gFull.N(' num2str(i) ')']);
  end
  
  if i < full_dim
    % repmat(dataName, 1, 
    repmatStr = cat(2, repmatStr, ', ');
  else
    % repmat(dataName, 1, gFull.N(2))
    repmatStr = cat(2, repmatStr, ')');
  end
end

end