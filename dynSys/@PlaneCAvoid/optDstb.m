function dOpt = optDstb(obj, t, x, deriv, dMode, ~)
% dOpt = optDstb(obj, t, x, deriv, dMode, ~)

%% Input processing
if nargin < 5
  dMode = 'min';
end

if ~(strcmp(dMode, 'max') || strcmp(dMode, 'min'))
  error('dMode must be ''max'' or ''min''!')
end

convert_back = false;
if ~iscell(x)
  convert_back = true;
  x = num2cell(x);
  deriv = num2cell(deriv);
end

%% Determinants for disturbance (vB, wB, d3)
det = cell(obj.nu, 1);
det{1} = deriv{1}.*cos(x{3}) + deriv{2}.*sin(x{3});
det{2} = deriv{3};
det{5} = deriv{3};

%% Optimal disturbance (vB, wB, d3)
dMin = [obj.vRangeB(1); -obj.wMaxB; nan; nan; -obj.dMaxA(2) - obj.dMaxB(2)];
dMax = [obj.vRangeB(2); obj.wMaxB; nan; nan; obj.dMaxA(2) + obj.dMaxB(2)];
dOpt = cell(obj.nd, 1);

for i = [1 2 5]
  if strcmp(dMode, 'max')
    dOpt{i} = (det{i}>=0)*dMax(i) + (det{i}<0)*dMin(i);
  else
    dOpt{i} = (det{i}>=0)*dMin(i) + (det{i}<0)*dMax(i);
  end
end

%% Optimal disturbance (d1, d2)
if strcmp(dMode, 'max')
  s = 1;
else
  s = -1;
end

denom = sqrt(deriv{1}.^2 + deriv{2}.^2);
dOpt{3} = s*(obj.dMaxA(1) + obj.dMaxB(1)) * deriv{1} ./ denom;
dOpt{3}(denom == 0) = 0;
dOpt{4} = s*(obj.dMaxA(1) + obj.dMaxB(1)) * deriv{2} ./ denom;
dOpt{4}(denom == 0) = 0;

%% If input x and deriv were not cells, then convert dOpt back to vector
if convert_back
  dOpt = cell2mat(dOpt);
end
end