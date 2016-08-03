function uOpt = optCtrl(obj, ~, ~, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  uMode = 'max';
end

convert_back = false;
if ~iscell(deriv)
  convert_back = true;
  deriv = num2cell(deriv);
end

%% Optimal control
if strcmp(uMode, 'max')
  uOpt = (-deriv{2}>=0)*obj.aMax + (-deriv{2}<0)*(-obj.aMax);
elseif strcmp(uMode, 'min')
  uOpt = (-deriv{2}>=0)*(-obj.aMax) + (-deriv{2}<0)*obj.aMax;
else
  error('Unknown uMode!')
end

if convert_back
  uOpt = cell2mat(uOpt);
end
end