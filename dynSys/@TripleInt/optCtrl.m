function uOpt = optCtrl(obj, ~, ~, deriv, uMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode, MIEdims)
%     dims must specify dimensions of deriv

if nargin < 5
  uMode = 'min';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%% Optimal Control
if strcmp(uMode, 'max')
  uOpt = (deriv{obj.dims==3}>=0)*obj.uMax + (deriv{obj.dims==3}<0)*obj.uMin;
elseif strcmp(uMode, 'min')
  uOpt = (deriv{obj.dims==3}>=0)*obj.uMin + (deriv{obj.dims==3}<0)*obj.uMax;
else
  error('Unknown uMode!')
end
end