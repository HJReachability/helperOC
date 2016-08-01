function alpha = partialFunc(obj, ~, ~, ~, ~, schemeData, dim)

% TIdim = [];
dims = 1:obj.nx;
if isfield(schemeData, 'MIEdims')
%   TIdim = schemeData.TIdim;
  dims = schemeData.MIEdims;
end

x = cell(obj.nx, 1);
x(dims) = schemeData.grid.xs;

switch dims(dim)
  case 1
    alpha = abs(x{2});
  case 2
    alpha = obj.uMax;
  otherwise
    error('Cannot compute alpha for this dimension!')
end

end