function uOpt = optCtrl(obj, t, y, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if strcmp(uMode, 'max')
  s = 1;
elseif strcmp(uMode, 'min')
  s = -1;
else
  error('Unknown uMode!')
end

%% Optimal control
uOpt = deriv;
denom = 0;
if iscell(deriv)
  for i = 1:obj.nx
    denom = denom + deriv{i}.^2;
  end
  denom = sqrt(denom);

  for i = 1:obj.nx
    uOpt{i} = s*obj.vMax*uOpt{i} ./ denom;
    uOpt{i}(denom == 0) = 0;
  end

else
  for i = 1:obj.nx
    denom = denom + deriv(i).^2;
  end
  denom = sqrt(denom);
  
  if denom > 0
  for i = 1:obj.nx
    uOpt(i) = s*obj.vMax*uOpt(i) ./ denom;
  end
  else
    uOpt = zeros(obj.nx, 1);
  end
end



end