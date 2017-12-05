function L = lift(obj, alpha, V, CL)
% Lift of EngineOutPlane
%     alpha - angle of attack
%     V     - speed
%     CL    - lift cofficient (function handle)

% Constants
S = obj.S;
rho = obj.rho;

L = 0.5*S*V^2*CL(alpha);

end