function x1 = updateState(obj, u, x0)
% Update state based on control

% If no control is specified, use previous control
if nargin < 2
    u = obj.u; 
end

% If no state is specified, use current state
if nargin < 3
    x0 = obj.x; 
end

x1 = obj.computeState(u, x0);

obj.x = x1;
obj.u = u;

obj.xhist = cat(2, obj.xhist, obj.x);
obj.uhist = cat(2, obj.uhist, obj.u);
end