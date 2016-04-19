function [data, tau] = HJIPDE_solve(data0, tau, schemeData, ...
  minWithZero, compRegion)
% [data, tau] = HJIPDE_solve(data0, tau, schemeData, ...
%   minWithZero, compRegion)
%
% Solves HJIPDE with initial conditions data0, at times tau, and with
% parameters schemeData

if numel(tau) < 2
  error('Time vector must have at least two elements!')
end

if nargin < 4
  minWithZero = true;
end

if nargin < 5
  compRegion = [];
end

%% SchemeFunc and SchemeData
schemeFunc = @termLaxFriedrichs;
g = schemeData.grid;

%% Numerical approximation functions
dissType = 'global';
accuracy = 'veryHigh';
[schemeData.dissFunc, integratorFunc, schemeData.derivFunc] = ...
  getNumericalFuncs(dissType, accuracy);

%% Time integration
integratorOptions = odeCFLset('factorCFL', 0.5, 'stats', 'on');

startTime = cputime;

data = zeros([size(data0) length(tau)]);
eval(updateData_cmd(g.dim, '1'));

for i = 2:length(tau)
  y0 = eval(get_dataStr(g.dim, 'i-1'));
  y0 = y0(:);
  [ ~, y ] = feval(integratorFunc, schemeFunc, [tau(i-1) tau(i)], y0,...
                    integratorOptions, schemeData);
  eval(updateData_cmd(g.dim, 'i'));
  
  if minWithZero
    eval(minWithZero_cmd(g.dim));
  end
end

endTime = cputime;
fprintf('Total execution time %g seconds\n', endTime - startTime);
end

function cmdStr = updateData_cmd(dims, indStr)
%% Generate command for updating data
% data(:,:,:,i)
cmdStr = get_dataStr(dims, indStr);

% data(:,:,:,i) =
cmdStr = cat(2, cmdStr, ' = ');

if strcmp(indStr, '1')
  % data(:,:,:,i) = data0;
  cmdStr = cat(2, cmdStr, 'data0;');
else
  % data(:,:,:,i) = reshape(y, schemeData.grid.shape);
  cmdStr = cat(2, cmdStr, 'reshape(y, schemeData.grid.shape);');
end
end

function cmdStr = minWithZero_cmd(dims)
% data(:,:,:,i)
data_i = get_dataStr(dims, 'i');

% data(:,:,:,i-1)
data_im1 = get_dataStr(dims, 'i-1');

% data(:,:,:,i) = min(data(:,:,:,i), data(:,:,:,i-1));
cmdStr = [data_i ' = min(' data_i ', ' data_im1 ');'];
end

function [dissFunc, integratorFunc, derivFunc] = ...
  getNumericalFuncs(dissType, accuracy)
% Dissipation
switch(dissType)
 case 'global'
  dissFunc = @artificialDissipationGLF;
 case 'local'
  dissFunc = @artificialDissipationLLF;
 case 'locallocal'
  dissFunc = @artificialDissipationLLLF;
 otherwise
  error('Unknown dissipation function %s', dissFunc);
end

% Accuracy
switch(accuracy)
 case 'low'
  derivFunc = @upwindFirstFirst;
  integratorFunc = @odeCFL1;
 case 'medium'
  derivFunc = @upwindFirstENO2;
  integratorFunc = @odeCFL2;
 case 'high'
  derivFunc = @upwindFirstENO3;
  integratorFunc = @odeCFL3;
 case 'veryHigh'
  derivFunc = @upwindFirstWENO5;
  integratorFunc = @odeCFL3;
 otherwise
  error('Unknown accuracy level %s', accuracy);  
end
end