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

dims = obj.dims;
%% Optimal control
if strcmp(uMode, 'max')
  if any(dims == 3)
    uOpt{1} = (deriv{dims==3}>=0)*obj.uMax(1) + (deriv{dims==3}<0)*obj.uMin(1);
  end  
elseif strcmp(uMode, 'min')
  if any(dims == 3)
    uOpt{1} = (deriv{dims==3}<0)*obj.uMax(1) + (deriv{dims==3}>=0)*obj.uMin(1);
  end
else
  error('Unknown uMode!')
end

if convert_back
  uOpt = cell2mat(uOpt);
end
end