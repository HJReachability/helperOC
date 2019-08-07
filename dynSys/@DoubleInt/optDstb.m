function dOpt = optDstb(obj, ~, ~, deriv, dMode)
% uOpt = optDstb(obj, t, y, deriv, uMode)
%     Dynamics of the double integrator
%     \dot{x}_1 = x_2 + d
%     \dot{x}_2 = u

%% Input processing
if nargin < 5
  dMode = 'max';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%dOpt = cell(obj.nd, 1);

%% Optimal control
if strcmp(dMode, 'max')
    dOpt = (deriv{obj.dims==1}>=0)*obj.dMax(1) + ...
      (deriv{obj.dims==1}<0)*(obj.dMin(1));

elseif strcmp(dMode, 'min')
    dOpt = (deriv{obj.dims==1}>=0)*(obj.dMin(1)) + ...
      (deriv{obj.dims==1}<0)*obj.dMax(1);

else
  error('Unknown dMode!')
end

end