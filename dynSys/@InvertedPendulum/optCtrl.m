function uOpt = optCtrl(obj, t, xs, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, deriv, uMode, dMode, MIEdims)

    l = obj.l;    % [m]        length of pendulum
    m = obj.m;    % [kg]       mass of pendulum

    g1 = 0;
    g2 = -1 / (m*l^2/3);
    
%% Input processing
if nargin < 5
  uMode = 'min';
end

%% Optimal control
if iscell(deriv)
 multiplier = deriv{1}.*g1 + deriv{2}.*g2;
  uOpt = cell(obj.nu, 1);
  if strcmp(uMode, 'max')
    uOpt = (multiplier>=0)*obj.uMax + (multiplier<0)* obj.uMin;
    
  elseif strcmp(uMode, 'min')
    uOpt = (multiplier>=0)* obj.uMin + (multiplier<0)*obj.uMax;
  else
    error('Unknown uMode!')
  end  
  
else
  uOpt = zeros(obj.nu, 1);
  multiplier = deriv(1).*g1 + deriv(2).*g2;
  if strcmp(uMode, 'max')
    uOpt = (multiplier>=0)*obj.uMax + (multiplier<0)* obj.uMin;
    
  elseif strcmp(uMode, 'min')
    uOpt = (multiplier>=0)* obj.uMin + (multiplier<0)*obj.uMax;
    
  else
    error('Unknown uMode!')
  end
end




end