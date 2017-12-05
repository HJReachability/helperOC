function L = drag(obj, alpha, V, CD)
% Lift of EngineOutPlane
%     alpha - angle of attack
%     V     - speed
%     CD    - drag cofficient (function handle)

% Constants
S = obj.S;
rho = obj.rho;

L = 0.5*rho * S * V^2 * CD(alpha);

end