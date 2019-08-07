function dOpt = optDstb(obj, ~, ~, deriv, dMode)
% dOpt = optCtrl(obj, t, y, deriv, dMode)
%     Dynamics of the DubinsCar
%         \dot{x}_1 = v * cos(x_3) + d_1
%         \dot{x}_2 = v * sin(x_3) + d_2
%         \dot{x}_3 = u

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
  for i = 1:3
    if any(obj.dims == i)
      dOpt{i} = (deriv{obj.dims==i}>=0)*obj.dMax(i) + ...
        (deriv{obj.dims==i}<0)*(-obj.dMax(i));
    end
  end

elseif strcmp(dMode, 'min')
  for i = 1:3
    if any(obj.dims == i)
      dOpt{i} = (deriv{obj.dims==i}>=0)*(-obj.dMax(i)) + ...
        (deriv{obj.dims==i}<0)*obj.dMax(i);
    end
  end
else
  error('Unknown dMode!')
end

end