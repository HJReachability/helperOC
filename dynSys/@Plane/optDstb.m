function dOpt = optDstb(obj, t, y, deriv, dMode, ~)
% dOpt = optDstb(obj, t, y, deriv, ~, ~)

if ~iscell(y)
  deriv = num2cell(y);
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

%% Optimal disturbance
if iscell(deriv)
  dOpt = cell(obj.nd, 1);
  normDeriv12 = sqrt(deriv{1}.^2 + deriv{2}.^2);
  if strcmp(dMode, 'max')
    dOpt{1} = obj.dMax(1) * deriv{1} ./ normDeriv12;
    dOpt{1}(normDeriv12==0) = 0;
    dOpt{2} = obj.dMax(1) * deriv{2} ./ normDeriv12;
    dOpt{2}(normDeriv12==0) = 0;
    dOpt{3} = (deriv{3}>=0) * obj.dMax(2) - (deriv{3}<0) * obj.dMax(2);
    
  elseif strcmp(dMode, 'min')
    dOpt{1} = -obj.dMax(1) * deriv{1} ./ normDeriv12;
    dOpt{1}(normDeriv12==0) = 0;
    dOpt{2} = -obj.dMax(1) * deriv{2} ./ normDeriv12;
    dOpt{2}(normDeriv12==0) = 0;
    dOpt{3} = (deriv{3}>=0) * -obj.dMax(2) + (deriv{3}<0) * obj.dMax(2);
    
  else
    error('Unknown dMode!')
  end
else
  dOpt = zeros(obj.nd, 1);
  normDeriv12 = sqrt(deriv(1).^2 + deriv(2).^2);
  if strcmp(dMode, 'max')
    if normDeriv12 > 0
      dOpt(1) = obj.dMax(1) * deriv(1) / normDeriv12;
      dOpt(2) = obj.dMax(1) * deriv(2) / normDeriv12;
    else
      dOpt(1) = 0;
      dOpt(2) = 0;
    end
    dOpt(3) = (deriv(3)>=0) * obj.dMax(2) - (deriv(3)<0) * obj.dMax(2);
    
  elseif strcmp(dMode, 'min')
    if normDeriv12 > 0
      dOpt(1) = -obj.dMax(1) * deriv(1) / normDeriv12;
      dOpt(2) = -obj.dMax(1) * deriv(2) / normDeriv12;
    else
      dOpt(1) = 0;
      dOpt(2) = 0;
    end
    dOpt(3) = (deriv(3)>=0) * -obj.dMax(2) + (deriv(3)<0) * obj.dMax(2);
    
  else
    error('Unknown dMode!')
  end
end


end