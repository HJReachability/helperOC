function uOpt = optCtrl(obj, ~, x, deriv, uMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if ~(strcmp(uMode, 'max') || strcmp(uMode, 'min'))
  error('uMode must be ''max'' or ''min''!')
end

if isfield(obj, 'uForced')
    uOpt = obj.uForced;
end

convert_back = false;
if ~iscell(x)
  convert_back = true;
  x = num2cell(x,numel(obj.dims));
  deriv = num2cell(deriv,numel(obj.dims));
end

if any(obj.dims == 1) && ~any(obj.dims == 2)
    det = deriv{obj.dims==1}.*x{obj.dims==1};
elseif ~any(obj.dims == 1) && any(obj.dims == 2)
    det = deriv{obj.dims==2};
elseif any(obj.dims == 1) && any(obj.dims == 2)
    det = deriv{obj.dims==1}.*x{obj.dims==1} +...
        deriv{obj.dims==2};
else
    error('dimensions are wrong')
end

if strcmp(uMode, 'max')
    uOpt = (det>=0)*obj.uMax +(det<0)*obj.uMin;
elseif strcmp(uMode, 'min')
    uOpt = (det>=0)*obj.uMin +(det<0)*obj.uMax;
else
    error('undefined uMode')
end
    
%% Optimal control
% if strcmp(uMode, 'max')
%   if any(obj.dims == 1) && ~any(obj.dims == 2)
%     uOpt = ((x{obj.dims==1}.*(deriv{obj.dims==3}))>=0)*obj.uMax + ...
%       ((y{obj.dims==1}.*(deriv{obj.dims==3}))<0)*obj.uMin;
%   end
%   
%   if any(obj.dims == 2) && ~any(obj.dims == 1)
%     uOpt = (deriv{obj.dims==2}>=0)*obj.uMax + ...
%       (deriv{obj.dims==2}<0)*obj.uMin;
%   end
%   
%     
%   if any(obj.dims == 2) && any(obj.dims == 1)
%     uOpt = ((deriv{obj.dims==1}.*y{dims==1}+deriv{obj.dims==2})>=0)*obj.uMax +...
%         ((deriv{obj.dims==1}.*y{dims==1}+deriv{obj.dims==2})<0)*obj.uMin;
%   end
% 
% elseif strcmp(uMode, 'min')
%   if any(obj.dims == 1) && ~any(obj.dims == 2)
%     uOpt = ((y{obj.dims==1}.*(deriv{obj.dims==3}))>=0)*obj.uMin + ...
%       ((y{obj.dims==1}.*(deriv{obj.dims==3}))<0)*obj.uMax;
%   end
%   
%   if any(obj.dims == 2) && ~any(obj.dims == 1)
%     uOpt = (deriv{obj.dims==2}>=0)*obj.uMin + ...
%       (deriv{obj.dims==2}<0)*obj.uMax;
%   end
%   
%     
%   if any(obj.dims == 2) && any(obj.dims == 1)
%     uOpt = ((deriv{obj.dims==1}.*y{dims==1}+deriv{obj.dims==2})>=0)*obj.uMin +...
%         ((deriv{obj.dims==1}.*y{dims==1}+deriv{obj.dims==2})<0)*obj.uMax;
%   end
% else
%   error('Unknown uMode!')
% end
if convert_back
  uOpt = cell2mat(uOpt);
end
end