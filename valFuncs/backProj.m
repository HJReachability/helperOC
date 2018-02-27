function dataOut = backProj(gFull, dataIn, dataDim)
% dataOut = backProj(gFull, dataIn, dataDim)
%   Backprojects dataIn with respect to the full grid gFull
%
% Inputs:
%   gFull   - full-dimensional grid structure
%   dataIn  - input data with missing dimensions
%   dataDim - data dimensions present in dataIn
%
% Output:
%   dataOut - full-dimensional data

%% Expand dataIn across the full dimension without repeating its values
tempSize = ones(1, gFull.dim);
tempSize(dataDim) = gFull.N(dataDim);
temp = zeros(tempSize);

tempArgin = repmat({1}, 1, gFull.dim);
for i = 1:length(dataDim)
  tempArgin{dataDim(i)} = ':';
end
temp(tempArgin{:}) = dataIn;

%% Repeat temporary data across the missing dimensions
repmatArgin = num2cell(gFull.N);
for i = 1:length(dataDim)
  repmatArgin{dataDim(i)} = 1;
end
dataOut = repmat(temp, repmatArgin{:});
end