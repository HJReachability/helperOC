function dOpt = optDstb(obj, ~, ~, deriv, dMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  dMode = 'min';
end

convert_back = false;
if ~iscell(deriv)
  convert_back = true;
  deriv = num2cell(deriv);
end

%% Optimal control
if strcmp(dMode, 'max')
  dOpt = (deriv{2}>=0)*obj.bMax + (deriv{2}<0)*(-obj.bMax);
elseif strcmp(dMode, 'min')
  dOpt = (deriv{2}>=0)*(-obj.bMax) + (deriv{2}<0)*obj.bMax;
else
  error('Unknown uMode!')
end

if convert_back
  dOpt = cell2mat(dOpt);
end
end