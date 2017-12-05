function uOpt = optCtrl(obj, ~, x, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, y, deriv, uMode, dMode, MIEdims)

%% Input processing
if nargin < 5
  uMode = 'max';
end

if ~(strcmp(uMode, 'max') || strcmp(uMode, 'min'))
  error('uMode must be ''max'' or ''min''!')
end

convert_back = false;
if ~iscell(x)
  convert_back = true;
  x = num2cell(x);
  deriv = num2cell(deriv);
end

%% Determinant for control
det = cell(obj.nu, 1);
det{1} = -deriv{1};
det{2} = deriv{1}.*x{2}  - deriv{2}.*x{1} - deriv{3};

%% Optimal control
uMin = [obj.vRangeA(1); -obj.wMaxA];
uMax = [obj.vRangeA(2); obj.wMaxA];
uOpt = cell(obj.nu, 1);

for i = 1:obj.nu
  if strcmp(uMode, 'max')
    uOpt{i} = (det{i}>=0)*uMax(i) + (det{i}<0)*uMin(i);
  else
    uOpt{i} = (det{i}>=0)*uMin(i) + (det{i}<0)*uMax(i);
  end
end

%% If input x and deriv were not cells, then convert uOpt back to vector
if convert_back
  uOpt = cell2mat(uOpt);
end
end