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

dims = obj.dims;
%% Optimal control
if strcmp(dMode, 'max')
  if any(dims == 1)
    dOpt{1} = (deriv{dims==1}>=0)*obj.dxMax + (deriv{dims==1}<0)*(-obj.dxMax);
  end
  
  if any(dims == 2)
    dOpt{2} = (deriv{dims==2}>=0)*obj.bMax(1) + ...
      (deriv{dims==2}<0)*(-obj.bMax(1));
  end
  
  if any(dims == 3)
    dOpt{3} = (deriv{dims==3}>=0)*obj.dyMax + (deriv{dims==3}<0)*(-obj.dyMax);
  end
  
  if any(dims == 4)
    dOpt{4} = (deriv{dims==4}>=0)*obj.bMax(2) + ...
      (deriv{dims==4}<0)*(-obj.bMax(2));
  end
  
elseif strcmp(dMode, 'min')
  if any(dims == 1)
    dOpt{1} = (deriv{dims==1}>=0)*(-obj.dxMax) + (deriv{dims==1}<0)*obj.dxMax;
  end
  
  if any(dims == 2)
    dOpt{2} = (deriv{dims==2}>=0)*(-obj.bMax(1)) + ...
      (deriv{dims==2}<0)*obj.bMax(1);
  end
  
  if any(dims == 3)
    dOpt{3} = (deriv{dims==3}>=0)*(-obj.dyMax) + (deriv{dims==3}<0)*obj.dyMax;
  end
  
  if any(dims == 4)
    dOpt{4} = (deriv{dims==4}>=0)*(-obj.bMax(2)) + ...
      (deriv{dims==4}<0)*obj.bMax(2);
  end
  
else
  error('Unknown uMode!')
end

if convert_back
  dOpt = cell2mat(dOpt);
end
end