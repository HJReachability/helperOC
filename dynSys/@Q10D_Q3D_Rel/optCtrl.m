function uOpt = optCtrl(obj, t, y, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dims)

%% Input processing
if nargin < 5
  uMode = 'max';
end

convert_back = false;
if ~iscell(deriv)
  convert_back = true;
  deriv = num2cell(deriv);
end

dims = obj.dims;
%% Optimal control
if strcmp(uMode, 'max')
  %planner tries to min
  if any(dims==1)
    uOpt{1} = ((-deriv{dims==1})>=0)*obj.uMin(1) + ((-deriv{dims==1})<0)*obj.uMax(1);
  end
  
  %tracker tries to max
  if any(dims == 4)
    uOpt{2} = (deriv{dims==4}>=0)*obj.uMax(2) + (deriv{dims==4}<0)*obj.uMin(2);
  end
  
    %planner tries to min
  if any(dims == 5)
     uOpt{3} = ((-deriv{dims==5})>=0)*obj.uMin(3) + ((-deriv{dims==5})<0)*obj.uMax(3);
  end
  
  %tracker tries to max
  if any(dims == 8)
    uOpt{4} = (deriv{dims==8}>=0)*obj.uMax(4) + (deriv{dims==8}<0)*obj.uMin(4);
  end
  
    %planner tries to min
  if any(dims==9)
     uOpt{5} = ((-deriv{dims==9})>=0)*obj.uMin(5) + ((-deriv{dims==9})<0)*obj.uMax(5);
  end
  
  %tracker tries to max
  if any(dims == 10)
    uOpt{6} = (deriv{dims==10}>=0)*obj.uMax(6) +(deriv{dims==10}<0)*obj.uMin(6);
  end
  
elseif strcmp(uMode, 'min')
  %planner tries to max
  if any(dims==1)
    uOpt{1} = ((-deriv{dims==1})>=0)*obj.uMax(1) + ((-deriv{dims==1})<0)*obj.uMin(1);
  end
  
  %tracker tries to min
  if any(dims == 4)
    uOpt{2} = (deriv{dims==4}>=0)*obj.uMin(2) + (deriv{dims==4}<0)*obj.uMax(2);
  end
  
  %planner tries to max
  if any(dims == 5)
     uOpt{3} = ((-deriv{dims==5})>=0)*obj.uMax(3) + ((-deriv{dims==5})<0)*obj.uMin(3);
  end
  
  %tracker tries to min
  if any(dims == 8)
    uOpt{4} = (deriv{dims==8}>=0)*obj.uMin(4) + (deriv{dims==8}<0)*obj.uMax(4);
  end
  
  %planner tries to max
  if any(dims==9)
     uOpt{5} = ((-deriv{dims==9})>=0)*obj.uMax(5) + ((-deriv{dims==9})<0)*obj.uMin(5);
  end
  
  %tracker tries to min
  if any(dims == 10)
    uOpt{6} = (deriv{dims==10}>=0)*obj.uMin(6) +(deriv{dims==10}<0)*obj.uMax(6);
  end
else
  error('Unknown uMode!')
end

if convert_back
  uOpt = cell2mat(uOpt);
end
end