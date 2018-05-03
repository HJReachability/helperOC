function [m, b, mNorm] = feas_ctrl_constr(obj, ~, x, deriv, dMode)
% [m, b] = feas_ctrl_constr(obj, ~, x, deriv, uMode, dMode)
%
%     Feasible control constraints in the form of m*u + b >= 0 or <= 0

if nargin < 5
  dMode = 'min';
end

dOpt = obj.optDstb([], [], deriv, dMode);

% Compute b using Hamiltonian with zero control
b = 0;
uZero = {zeros(size(x{1})); zeros(size(x{1}))};
dx = obj.dynamics([], x, uZero, dOpt);
for i = 1:obj.nx
  b = b + deriv{i}.*dx{i};
end

% Compute m by hard-coding terms in Hamiltonian involving u
m = cell(obj.nu, 1);
if any(obj.dims==2)
  m{1} = -deriv{obj.dims==2};
end

if any(obj.dims==4)
  m{2} = -deriv{obj.dims==4};
end

mNorm = sqrt(m{1}.^2 + m{2}.^2);

m{1}(mNorm>0) = m{1}(mNorm>0)./mNorm(mNorm>0);
m{2}(mNorm>0) = m{2}(mNorm>0)./mNorm(mNorm>0);
b(mNorm>0) = b(mNorm>0)./mNorm(mNorm>0);

end