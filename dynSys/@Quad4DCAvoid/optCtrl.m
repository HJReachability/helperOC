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
  uOpt{1} = (-deriv{2}>=0)*obj.aMax(1) + (-deriv{2}<0)*(-obj.aMax(1));
  uOpt{2} = (-deriv{4}>=0)*obj.aMax(2) + (-deriv{4}<0)*(-obj.aMax(2));
elseif strcmp(uMode, 'min')
  uOpt{1} = (-deriv{2}>=0)*(-obj.aMax(1)) + (-deriv{2}<0)*obj.aMax(1);
  uOpt{2} = (-deriv{4}>=0)*(-obj.aMax(2)) + (-deriv{4}<0)*obj.aMax(2);
else
  error('Unknown uMode!')
end

if convert_back
  uOpt = cell2mat(uOpt);
end
end