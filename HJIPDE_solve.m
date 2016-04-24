function [data, tau] = HJIPDE_solve(data0, tau, schemeData, ...
  minWith, obstacles, accuracy, compRegion)
% [data, tau] = HJIPDE_solve(data0, tau, schemeData, ...
%   minWith, obstacles, compRegion)
%
% Solves HJIPDE with initial conditions data0, at times tau, and with
% parameters schemeData and obstacles
%
% Inputs:
%   data0      - initial value function
%   tau        - list of computation times
%   schemeData - problem parameters passed into the Hamiltonian function
%                  .g: grid (required!)
%   minWith    - set to 'zero' to do min with zero
%              - set to 'none' to compute reachable set (not tube)
%              - set to 'data0' to do min with data0 (for variational
%                inequality)
%   obstacles  - a single obstacle or a list of obstacles with time stamps
%                tau (obstacles must have same time stamp as the solution)
%   compRegion - unused for now (meant to limit computation region)
%
% Outputs:
%   data - solution corresponding to grid g and time vector tau
%   tau  - list of computation times (redundant)
%
% Mo Chen, 2016-04-23

%% Default parameters
if numel(tau) < 2
  error('Time vector must have at least two elements!')
end

if nargin < 4
  minWith = 'zero';
end

if nargin < 5
  obstacles = [];
end

if nargin < 6
  accuracy = 'veryHigh';
end

%% SchemeFunc and SchemeData
schemeFunc = @termLaxFriedrichs;
g = schemeData.grid;

%% Numerical approximation functions
dissType = 'global';
[schemeData.dissFunc, integratorFunc, schemeData.derivFunc] = ...
  getNumericalFuncs(dissType, accuracy);

%% Time integration
integratorOptions = odeCFLset('factorCFL', 0.8, 'stats', 'on');

startTime = cputime;

data = zeros([size(data0) length(tau)]);
eval(updateData_cmd(g.dim, '1'));

for i = 2:length(tau)
  y0 = eval(get_dataStr(g.dim, 'i-1'));
  y0 = y0(:);
  [~, y] = feval(integratorFunc, schemeFunc, [tau(i-1) tau(i)], y0, ...
                    integratorOptions, schemeData);
  
  eval(updateData_cmd(g.dim, 'i'));
  
  % Obstacles
  if ~isempty(obstacles)
    eval(maskWithObs_cmd(g.dim, numDims(obstacles) == g.dim));
  end
  
  % Min with zero
  if ~strcmp(minWith, 'none')
    eval(minWith_cmd(g.dim, minWith));
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

function cmdStr = maskWithObs_cmd(dims, single)
% data(:,:,:,i)
data_i = get_dataStr(dims, 'i');

if single
  % data(:,:,:,i) = max(data(:,:,:,i), -obstacles);
  cmdStr = [data_i ' = max(' data_i ', -obstacles);'];
else
  % data(:,:,:,i) = max(data(:,:,:,i), -obstacles(:,:,:,i));
  obstacle_i = get_dataStr(dims, 'i', 'obstacles');
  cmdStr = [data_i ' = max(' data_i ', -' obstacle_i ');'];
end

end


function cmdStr = minWith_cmd(dims, minWith)
% data(:,:,:,i)
data_i = get_dataStr(dims, 'i');

if strcmp(minWith, 'zero')
  % data(:,:,:,i-1)
  data_im1 = get_dataStr(dims, 'i-1');

  % data(:,:,:,i) = min(data(:,:,:,i), data(:,:,:,i-1));
  cmdStr = [data_i ' = min(' data_i ', ' data_im1 ');'];
  
elseif strcmp(minWith, 'data0')
  % data(:,:,:,i) = min(data(:,:,:,i), data0);
  cmdStr = [data_i ' = min(' data_i ', data0);'];  
  
else
  error('Unknown minWith! Must be ''zero'' or ''data0''!')
end

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