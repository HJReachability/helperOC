function x1 = stateFromCtrlSeq(obj, U, Ts, x0)
% x = stateFromCtrlSeq(obj, U, Ts, x0)
%     Computes the resulting state from applying the control sequence (U, Ts)
%     starting from state x0
%
% Inputs:
%     obj - vehicle object
%     U   - obj.nu by length(Ts) matrix specifying the control to apply between
%           Ts(i-1) and Ts(i)
%     Ts  - times at which constant control is changed
%     x0  - initial state (defaults to obj.x0)
%
% Outputs:
%     x1  - resulting state
%

%% Process inputs
if ~isvector(Ts)
  error('Control switching times must be a vector!')
end

if size(U, 1) ~= obj.nu
  error('Input control dimensions are inconsistent!')
end

if size(U, 2) ~= length(Ts)
  error('Number of input controls do not match length of switching times!')
end

if nargin < 4
  x0 = obj.x0;
end

%% Loop over constant control pieces and integrate
x1 = x0;
t0 = 0;
for i = 1:length(Ts)
  if i > 1
    t0 = Ts(i-1);
  end
  
  t1 = Ts(i);
  x1 = obj.updateState(U(:,i), t1-t0, x1);
end

end