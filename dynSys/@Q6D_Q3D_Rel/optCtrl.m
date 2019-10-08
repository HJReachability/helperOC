function uOpt = optCtrl(obj, t, y, deriv, uMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if nargin < 6
  dims = obj.dims;
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

uOpt = cell(obj.nu, 1);

%% Optimal control
if strcmp(uMode, 'max')
  if any(dims == 2)
    uOpt{1} = ((deriv{dims==2}*obj.grav)>=0)*obj.uMax(1) ...
        + ((deriv{dims==2}*obj.grav)<0)*obj.uMin(1);
  end
  
  if any(dims == 4)
    uOpt{2} = ((-deriv{dims==4}*obj.grav)>=0)*obj.uMax(2) ...
        + ((-deriv{dims==4}*obj.grav)<0)*obj.uMin(2);
  end
  
  if any(dims == 6)
    uOpt{3} = (deriv{dims==6}>=0)*obj.uMax(3) +(deriv{dims==6}<0)*obj.uMin(3);
  end
  
elseif strcmp(uMode, 'min')
  if any(dims == 2)
    uOpt{1} = ((deriv{dims==2}*obj.grav)>=0)*obj.uMin(1) ...
        + ((deriv{dims==2}*obj.grav)<0)*obj.uMax(1);
  end
  
  if any(dims == 4)
    uOpt{2} = ((-deriv{dims==4}*obj.grav)>=0)*obj.uMin(2) ...
        + ((-deriv{dims==4}*obj.grav)<0)*obj.uMax(2);
  end
  
  if any(dims == 6)
    uOpt{3} = (deriv{dims==6}>=0)*obj.uMin(3) ...
        + (deriv{dims==6}<0)*obj.uMax(3);
  end
else
  error('Unknown uMode!')
end

end