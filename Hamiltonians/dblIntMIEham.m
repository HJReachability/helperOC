function hamValue = dblIntMIEham(t, data, deriv, schemeData)

checkStructureFields(schemeData, 'grid', 'uMax');

g = schemeData.grid;

%% Default to minimize over u, and backward reachable set
if ~isfield(schemeData, 'uMode')
  schemeData.uMode = 'min';
end

if ~isfield(schemeData, 'tMode')
  schemeData.tMode = 'backward';
end

%% Compute Hamiltonian 
if isfield(schemeData, 'PIn') && isfield(schemeData, 'gIn') && ...
    isfield(schemeData, 'tauIn')
  %% using pre-specified gradient of implicit value function
  [~, tInd] = min(abs(t-schemeData.tauIn));
  P2 = schemeData.PIn{2}(:,:,tInd);
  p2 = eval_u(schemeData.gIn, P2, [data g.xs{1}]);
  
  if strcmp(schemeData.uMode, 'min')
    uIn = -sign(p2);
  elseif strcmp(schemeData.uMode, 'max')
    uIn = sign(p2);
  else
    error('Unknown uMode!')
  end  
  
  hamValue = uIn.*deriv{1} - g.xs{1};
  
elseif isfield(schemeData, 'uIn')
  %% using constant control
  hamValue = schemeData.uIn.*deriv{1} - g.xs{1};
  
else
  %% using only gradient of current MIE value function
  uTerm = schemeData.uMax*abs(deriv{1});
  
  if strcmp(schemeData.uMode, 'min')
    hamValue = -uTerm - g.xs{1};
  elseif strcmp(schemeData.uMode, 'max')
    hamValue = uTerm - g.xs{1};
  else
    error('Unknown uMode!')
  end
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