function alpha = dblIntMIEpartial(t, data, derivMin, derivMax, schemeData, dim)

checkStructureFields(schemeData, 'grid', 'uMax');

switch dim
  case 1
    alpha = schemeData.uMax;
    
  otherwise
    error([ 'Partials for this problem' ...
            ' only exist in dimension 1' ]);
end
