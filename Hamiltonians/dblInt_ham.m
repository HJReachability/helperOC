function hamValue = dblInt_ham(t, data, deriv, schemeData)
% air3DHamFunc: analytic Hamiltonian for 3D collision avoidance example.
%
% hamValue = air3DHamFunc(t, data, deriv, schemeData)
%
% This function implements the hamFunc prototype for the three dimensional
%   aircraft collision avoidance example (also called the game of
%   two identical vehicles).
%
% It calculates the analytic Hamiltonian for such a flow field.
%
% Parameters:
%   t            Time at beginning of timestep (ignored).
%   data         Data array.
%   deriv	 Cell vector of the costate (\grad \phi).
%   schemeData	 A structure (see below).
%
%   hamValue	 The analytic hamiltonian.
%
% schemeData is a structure containing data specific to this Hamiltonian
%   For this function it contains the field(s):
%
%   .grid	 Grid structure.
%   .velocityA	 Speed of the evader (positive constant).
%   .velocityB	 Speed of the pursuer (positive constant).
%   .inputA	 Maximum turn rate of the evader (positive).
%   .inputB	 Maximum turn rate of the pursuer (positive).
%
% Ian Mitchell 3/26/04

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
