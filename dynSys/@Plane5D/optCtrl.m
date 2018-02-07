function uOpt = optCtrl(obj, ~, ~, deriv, uMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode)
%     Dynamics of the Plane5D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1 (x position)
%         \dot{x}_2 = x_4 * sin(x_3) + d_2 (y position)
%         \dot{x}_3 = x_5                  (heading)
%         \dot{x}_4 = u_1 + d_3            (linear speed)
%         \dot{x}_5 = u_2 + d_4            (turn rate)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

uOpt = cell(obj.nu, 1);

%% Optimal control
if strcmp(uMode, 'max')
  if any(obj.dims == 4)
    uOpt{1} = (deriv{obj.dims==4}>=0)*obj.aRange(2) + ...
      (deriv{obj.dims==4}<0)*obj.aRange(1);
  end
  
  if any(obj.dims == 5)
    uOpt{2} = (deriv{obj.dims==5}>=0)*(obj.alphaMax) + ...
      (deriv{obj.dims==5}<0)*(-obj.alphaMax);
  end

elseif strcmp(uMode, 'min')
  if any(obj.dims == 4)
    uOpt{1} = (deriv{obj.dims==4}>=0)*obj.aRange(1) + ...
      (deriv{obj.dims==4}<0)*obj.aRange(2);
  end
  
  if any(obj.dims == 5)
    uOpt{2} = (deriv{obj.dims==5}>=0)*(-obj.alphaMax) + ...
      (deriv{obj.dims==5}<0)*(obj.alphaMax);
  end
else
  error('Unknown uMode!')
end

end