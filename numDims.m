function dims = numDims(data)
% dims = numDims(data)
%
% Returns number of dimensions of data
% A row vector, column vector, or scalar has one dimension

if isvector(data)
  dims = 1;
  return
end

dims = length(size(data));

end