function uOpt = optCtrl(obj, t, y, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, ~)

if nargin < 5
  uMode = 'max';
end

if ~(strcmp(uMode, 'max') || strcmp(uMode, 'min'))
  error('uMode must be ''max'' or ''min''!')
end

if ~iscell(y)
  deriv = num2cell(y);
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

% Determinant for sign of control
det = deriv{1}.*y{2}  - deriv{2}.*y{1} - deriv{3};

% Maximize Hamiltonian
if strcmp(uMode, 'max')
  uOpt = (det>=0)*obj.uMax + (det<0)*(-obj.uMax);
else
  uOpt = (det>=0)*(-obj.uMax) + (det<0)*obj.uMax;
end

end