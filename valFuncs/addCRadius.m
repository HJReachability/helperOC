function dataOut = addCRadius(gIn, dataIn, radius)
% dataOut = addCRadius(gIn, dataIn, radius)
%
% Expands a set given by gIn and dataIn by radius units all around

% Solve HJI PDE for expanding set
schemeData.hamFunc = @addCRadiusham;
schemeData.partialFunc = @addCRadiuspartial;
schemeData.grid = gIn;
schemeData.velocity = radius;

dataOut = HJIPDE_solve(dataIn, [0 1], schemeData, 'zero');

% Discard initial set from output
eval([get_dataStr(gIn.dim, '1', 'dataOut') ' = [];']);
end