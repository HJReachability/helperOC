function hamValue = addCRadiusham(t, data, deriv, schemeData)
% hamValue = addCRadiusham(t, data, deriv, schemeData)
%     Hamiltonian function for adding a constant radius around a set of any
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
hamValue = 0;

for i = 1:length(deriv)
  hamValue = hamValue + R*deriv{i}.^2;
end

hamValue = sqrt(hamValue);

end