function dOpt = optDstb(obj, ~, ~, deriv, dMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode)
%     Dynamics of the Plane5D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1 (x position)
%         \dot{x}_2 = x_4 * sin(x_3) + d_2 (y position)
%         \dot{x}_3 = x_5                  (heading)
%         \dot{x}_4 = u_1 + d_3            (linear speed)
%         \dot{x}_5 = u_2 + d_4            (turn rate)

%% Input processing
if nargin < 5
  dMode = 'max';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

dOpt = cell(obj.nd, 1);

%% Optimal disturbance
if strcmp(dMode, 'max')
  if any(obj.dims == 1)
    dOpt{1} = (deriv{obj.dims==1}>=0)*obj.dMax(1) + ...
      (deriv{obj.dims==1}<0)*(-obj.dMax(1));
  end
  
  if any(obj.dims == 2)
    dOpt{2} = (deriv{obj.dims==2}>=0)*obj.dMax(2) + ...
      (deriv{obj.dims==2}<0)*(-obj.dMax(2));
  end
  
  if any(obj.dims == 4)
    dOpt{3} = (deriv{obj.dims==3}>=0)*obj.dMax(3) + ...
      (deriv{obj.dims==3}<0)*(-obj.dMax(3));
  end
  
  if any(obj.dims == 5)
    dOpt{4} = (deriv{obj.dims==4}>=0)*obj.dMax(4) + ...
      (deriv{obj.dims==4}<0)*(-obj.dMax(4));
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
  
  if any(obj.dims == 4)
    dOpt{3} = (deriv{obj.dims==3}>=0)*(-obj.dMax(3)) + ...
      (deriv{obj.dims==3}<0)*obj.dMax(3);
  end
  
  if any(obj.dims == 5)
    dOpt{4} = (deriv{obj.dims==4}>=0)*(-obj.dMax(4)) + ...
      (deriv{obj.dims==4}<0)*obj.dMax(4);
  end  
  
else
  error('Unknown dMode!')
end

end