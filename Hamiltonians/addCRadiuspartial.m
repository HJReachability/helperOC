function ...
  alpha = addCRadiuspartial(t, data, derivMin, derivMax, schemeData, dim)
% alpha = addCRadiuspartial(t, data, derivMin, derivMax, schemeData, dim)
%     Partial function for adding a constant radius around a set of any
%     dimension
%
% Dynamics: 
%     let z be the full state
%     \dot z = u
%         u \in ball of radius velocity
%
% addCRadius.m assumes t \in [0, 1]

checkStructureFields(schemeData, 'grid', 'velocity');

g = schemeData.grid;
R = schemeData.velocity;

% Dynamics without disturbances
denom = 0;
for i = 1:length(derivMax)
  denom = denom + derivMax{i}.^2;
end
denom = sqrt(denom);

alpha = R*abs(derivMax{dim}) / denom;

end