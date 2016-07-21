function ...
  alpha = dblInt_partialCustom(t, data, derivMin, derivMax, schemeData, dim)
% alpha = dblInt_partial(t, data, derivMin, derivMax, schemeData, dim)
%
% 

checkStructureFields(schemeData, 'grid', 'uMax');

g = schemeData.grid;

switch dim
  case 1
    alpha = 0;
  case 2
    alpha = schemeData.uMax;
    
  otherwise
    error([ 'Partials for this problem' ...
            ' only exist in dimension 1-2' ]);
end
