function uOpt = optCtrl(obj, t, xs, deriv, uMode, ~)
% uOpt = optCtrl(obj, t, deriv, uMode, dMode, MIEdims)

%% Input processing
if nargin < 5
  uMode = 'min';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end


%% Optimal control

% https://arxiv.org/pdf/1709.07523.pdf
% Appendix 
% need dot product of deriv and dx = f(x)
% then argmin terms with action to find optimal control

% we have    
%   dx(1) = velocity;
% u ~ { 0, 1, 2 }
%   dx(2) = (u - 1) * force + cos(3 * position) * (-gravity);

% u* = argmin_u (deriv{[0, 1]} * dx(2))
%    = argmin_u (deriv{[0, 1]} (u - 1) * force)
%    = 0 when deriv{[0, 1]} >= 0, 2 when deriv{[0, 1]} < 0

%% Optimal control
if strcmp(uMode, 'max')
  uOpt = (deriv{1} >= 0) * 2 + (deriv{1} < 0) * 0;
elseif strcmp(uMode, 'min')
  uOpt = (deriv{1} >= 0) * 0 + (deriv{1} < 0) * 2;
else
  error('Unknown uMode!')
end

end