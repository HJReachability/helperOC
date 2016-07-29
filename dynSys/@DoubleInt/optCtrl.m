function uOpt = optCtrl(obj, t, y, deriv, uMode, dims)
% uOpt = optCtrl(obj, t, y, deriv, uMode, MIEdims)
%     dims must specify dimensions of deriv

if nargin < 5
  uMode = 'min';
end

if nargin < 6
  dims = 1:obj.nx;
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

if strcmp(uMode, 'max')
  uOpt = (deriv{dims==2}>=0)*obj.uMax + (deriv{dims==2}<0)*obj.uMin;
elseif strcmp(uMode, 'min')
  uOpt = (deriv{dims==2}>=0)*obj.uMin + (deriv{dims==2}<0)*obj.uMax;
else
  error('Unknown uMode!')
end


end