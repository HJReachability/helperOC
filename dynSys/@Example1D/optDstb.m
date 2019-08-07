function dOpt = optDstb(obj, ~, ~, deriv, dMode)
%% Input processing
if nargin < 5
  dMode = 'max';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%% Optimal disturbance
if iscell(deriv)
  dOpt = cell(obj.nu, 1);
  if strcmp(dMode, 'max')
    dOpt = (deriv{1}>=0)*obj.dMax + (deriv{1}<0)* obj.dMin;
    
  elseif strcmp(dMode, 'min')
    dOpt = (deriv{1}>=0)* obj.dMin + (deriv{1}<0)*obj.dMax;
  else
    error('Unknown uMode!')
  end  
  
else
  dOpt = zeros(obj.nu, 1);
  if strcmp(dMode, 'max')
    dOpt = (deriv(1)>=0)*obj.dMax + (deriv(1)<0)* obj.dMin;
    
  elseif strcmp(dMode, 'min')
    dOpt = (deriv(1)>=0)* obj.dMin + (deriv(1)<0)*obj.dMax;
    
  else
    error('Unknown dMode!')
  end
end

end