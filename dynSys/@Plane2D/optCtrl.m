function uOpt = optCtrl(obj, t, xs, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, deriv, uMode, dMode, MIEdims)

%% Input processing
if nargin < 5
  uMode = 'min';
end


%% Optimal control
if iscell(deriv)
  uOpt = cell(obj.nu, 1);
  if strcmp(uMode, 'max')
    uOpt{1} = (deriv{1}>=0)*obj.vxMax + (deriv{1}<0)* obj.vxMin;
    uOpt{2} = (deriv{2}>=0)*obj.vyMax + (deriv{2}<0)* obj.vyMin;
    
  elseif strcmp(uMode, 'min')
    uOpt{1} = (deriv{1}>=0)* obj.vxMin + (deriv{1}<0)*obj.vxMax;
    uOpt{2} = (deriv{2}>=0)* obj.vyMin + (deriv{2}<0)*obj.vyMax;
  else
    error('Unknown uMode!')
  end  
  
else
  uOpt = zeros(obj.nu, 1);
  if strcmp(uMode, 'max')
    uOpt(1) = (deriv(1)>=0)*obj.vxMax + (deriv(1)<0)* obj.vxMin;
    uOpt(2) = (deriv(2)>=0)*obj.vyMax + (deriv(2)<0)* obj.vyMin;
    
  elseif strcmp(uMode, 'min')
    uOpt(1) = (deriv(1)>=0)* obj.vxMin + (deriv(1)<0)*obj.vxMax;
    uOpt(2) = (deriv(2)>=0)* obj.vyMin + (deriv(2)<0)*obj.vyMax;
    
  else
    error('Unknown uMode!')
  end
end




end