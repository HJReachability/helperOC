function dataOut = addCRadius(gIn, dataIn, radius)
% dataOut = addCRadius(gIn, dataIn, radius)
%
% Expands a set given by gIn and dataIn by radius units all around

% Solve HJI PDE for expanding set
schemeData.dynSys = KinVehicleND(zeros(gIn.dim, 1), 1);
schemeData.grid = gIn;

extraArgs.quiet = true;

dataOut = HJIPDE_solve(dataIn, [0 radius], schemeData, 'zero', extraArgs);

% Discard initial set from output
colons = repmat({':'}, 1, gIn.dim);
dataOut = dataOut(colons{:}, 2);
end