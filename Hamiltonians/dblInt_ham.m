function hamValue = dblInt_ham(t, data, deriv, schemeData)
% hamValue = dblInt_ham(t, data, deriv, schemeData)

checkStructureFields(schemeData, 'grid', 'uMax');

g = schemeData.grid;

%% Default to minimize over u, and backward reachable set
if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

if ~isfield(schemeData, 'tMode')
  schemeData.tMode = 'backward';
end

%% Compute Hamiltonian term
uTerm = schemeData.uMax * abs(deriv{2});
hamValue = deriv{1}.*g.xs{2};
if strcmp(schemeData.uMode, 'min')
  hamValue = hamValue - uTerm;
elseif strcmp(schemeData.uMode, 'max')
  hamValue = hamValue + uTerm;
else
  error('Unknown uMode!')
end

%% Negate dynamics if computing backward reachable set/tube
if strcmp(schemeData.tMode, 'backward')
  hamValue = -hamValue;
elseif strcmp(schemeData.tMode, 'forward')
  % Nothing to do here
else
  error('Unknown tMode!')
end
end
