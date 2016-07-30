function uOpt = optCtrl(obj, t, y, deriv, uMode, dims)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if nargin < 6
  dims = 1:obj.nx;
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%% Optimal control
if strcmp(uMode, 'max')
  uOpt = (deriv{dims==3}>=0)*obj.wMax - (deriv{dims==3}<0)*obj.wMax;
elseif strcmp(uMode, 'min')
  uOpt = -(deriv{dims==3}>=0)*obj.wMax + (deriv{dims==3}<0)*obj.wMax;
else
  error('Unknown uMode!')
end

end