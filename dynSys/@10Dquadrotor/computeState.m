function x1 = computeState(obj, u, x0)
% Update state based on control

% If no control is specified, use previous control
if nargin < 2
    u = obj.u; 
end

% If no state is specified, use current state
if nargin < 3
    x0 = obj.x; 
end
% 
% x1  = x0 + (obj.A*x0 + obj.B*u + obj.G)*obj.dt;

x1  = (eye(obj.nx) - obj.dt*obj.A)\(x0 + obj.B*u *obj.dt + obj.G *obj.dt);

end