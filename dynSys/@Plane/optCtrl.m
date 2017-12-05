function uOpt = optCtrl(obj, ~, y, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dMode, MIEdims)

%% Input processing
if nargin < 5
  uMode = 'min';
end


%% Optimal control
if iscell(deriv)
  uOpt = cell(obj.nu, 1);
  det1 = deriv{1} .* cos(y{3}) + deriv{2} .* sin(y{3});
  if strcmp(uMode, 'max')
    uOpt{1} = (det1 >= 0) * max(obj.vrange) + (det1 < 0) * min(obj.vrange);
    uOpt{2} = (deriv{3}>=0)*obj.wMax - (deriv{3}<0)*obj.wMax;
    
  elseif strcmp(uMode, 'min')
    uOpt{1} = (det1 >= 0) * min(obj.vrange) + (det1 < 0) * max(obj.vrange);
    uOpt{2} = -(deriv{3}>=0)*obj.wMax + (deriv{3}<0)*obj.wMax;
  else
    error('Unknown uMode!')
  end  
  
else
  uOpt = zeros(obj.nu, 1);
  det1 = deriv(1) .* cos(y(3)) + deriv(2) .* sin(y(3));
  if strcmp(uMode, 'max')
    uOpt(1) = (det1 >= 0) * max(obj.vrange) + (det1 < 0) * min(obj.vrange);
    uOpt(2) = (deriv(3)>=0)*obj.wMax - (deriv(3)<0)*obj.wMax;
    
  elseif strcmp(uMode, 'min')
    uOpt(1) = (det1 >= 0) * min(obj.vrange) + (det1 < 0) * max(obj.vrange);
    uOpt(2) = -(deriv(3)>=0)*obj.wMax + (deriv(3)<0)*obj.wMax;
    
  else
    error('Unknown uMode!')
  end
end




end