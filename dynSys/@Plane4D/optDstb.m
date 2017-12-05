function dOpt = optDstb(obj, ~, ~, deriv, dMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode)
%     Dynamics of the Plane4D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1
%         \dot{x}_2 = x_4 * sin(x_3) + d_2
%         \dot{x}_3 = u_1 = u_1
%         \dot{x}_4 = u_2 = u_2

%% Input processing
if nargin < 5
  dMode = 'max';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

dOpt = cell(obj.nd, 1);

%% Optimal control
if strcmp(dMode, 'max')
  if any(obj.dims == 1)
    dOpt{1} = (deriv{obj.dims==1}>=0)*obj.dMax(1) + ...
      (deriv{obj.dims==1}<0)*(-obj.dMax(1));
  end
  
  if any(obj.dims == 2)
    dOpt{2} = (deriv{obj.dims==2}>=0)*obj.dMax(2) + ...
      (deriv{obj.dims==2}<0)*(-obj.dMax(2));
  end

elseif strcmp(dMode, 'min')
  if any(obj.dims == 1)
    dOpt{1} = (deriv{obj.dims==1}>=0)*(-obj.dMax(1)) + ...
      (deriv{obj.dims==1}<0)*obj.dMax(1);
  end
  
  if any(obj.dims == 2)
    dOpt{2} = (deriv{obj.dims==2}>=0)*(-obj.dMax(2)) + ...
      (deriv{obj.dims==2}<0)*obj.dMax(2);
  end
else
  error('Unknown dMode!')
end

end