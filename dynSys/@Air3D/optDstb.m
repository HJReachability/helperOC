function dOpt = optDstb(obj, ~, y, deriv, dMode, ~)
% dOpt = optDstb(obj, t, y, deriv, ~, ~)

if nargin < 5
  dMode = 'max';
end

if ~(strcmp(dMode, 'max') || strcmp(dMode, 'min'))
  error('dMode must be ''max'' or ''min''!')
end

if ~iscell(y)
  y = num2cell(y);
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

% Minimize Hamiltonian
if strcmp(dMode, 'max')
  dOpt = (deriv{3}>=0)*obj.dMax + (deriv{3}<0)*(-obj.dMax);
else
  dOpt = (deriv{3}>=0)*(-obj.dMax) + (deriv{3}<0)*obj.dMax;
end


end