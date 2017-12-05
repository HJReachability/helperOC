function uOpt = optCtrl(obj, ~, ~, deriv, uMode, ~)
% uOpt = optCtrl(obj, ~, ~, deriv, uMode, ~)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%% Optimal control
dims = obj.dims;
uOpt = cell(obj.nu, 1);
if strcmp(uMode, 'max')
  if any(dims == 2)
    uOpt{1} = (deriv{dims==2}>=0)*obj.uMax + (deriv{dims==2}<0)*obj.uMin;
  end
  
  if any(dims == 4)
    uOpt{2} = (deriv{dims==4}>=0)*obj.uMax + (deriv{dims==4}<0)*obj.uMin;
  end
  
elseif strcmp(uMode, 'min')
  if any(dims == 2)
    uOpt{1} = (deriv{dims==2}>=0)*obj.uMin + (deriv{dims==2}<0)*obj.uMax;
  end
  
  if any(dims == 4)
    uOpt{2} = (deriv{dims==4}>=0)*obj.uMin + (deriv{dims==4}<0)*obj.uMax;
  end
else
  error('Unknown uMode!')
end

end