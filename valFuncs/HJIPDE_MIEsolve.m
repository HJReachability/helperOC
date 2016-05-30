function [datal, datau, tau, extraOuts] = HJIPDE_MIEsolve( ...
  data0l, data0u, tau, schemeData, minWith, extraArgs)
% [data, tau] = HJIPDE_solve( ...
%   data0, tau, schemeData, minWith, extraargs)
%
% Solves HJIPDE with initial conditions data0, at times tau, and with
% parameters schemeData and obstacles
%
% Inputs:
%   data0      - initial value function
%   tau        - list of computation times
%   schemeData - problem parameters passed into the Hamiltonian function
%                  .grid: grid (required!)
%   minWith    - set to 'zero' to do min with zero
%              - set to 'none' to compute reachable set (not tube)
%   extraArgs  - this structure can be used to leverage other additional
%                functionalities within this function. Its subfields are:
%     .obstacles:  a single obstacle or a list of obstacles with time
%                  stamps tau (obstacles must have same time stamp as the
%                  solution)
%     .visualize:  set to true to visualize reachable set
%     .plotData:   information required to plot the data (need to fill in)
%     .stopInit:   stop the computation once the reachable set includes the
%                  initial state
%
% Outputs:
%   data - solution corresponding to grid g and time vector tau
%   tau  - list of computation times (redundant)
%   extraOuts - This structure can be used to pass on extra outputs, for
%               example:
%      .stoptau: time at which the reachable set contains the initial
%                state; tau and data vectors only contain the data till
%                stoptau time.
%      .hT:      figure handle
%

%% Default parameters
if numel(tau) < 2
  error('Time vector must have at least two elements!')
end

if nargin < 5
  minWith = 'zero';
end

if nargin < 6
  extraArgs = [];
end

extraOuts = [];
small = 1e-4;
colons = repmat({':'}, 1, schemeData.grid.dim);

%% Extract the information from extraargs
% Extract the information about obstacles
if isfield(extraArgs, 'obstacles')
  obstacles = extraArgs.obstacles;
end

if isfield(extraArgs, 'visualize') && extraArgs.visualize
  % Extract the information about plotData
  if isfield(extraArgs, 'plotData')
    % Dimensions to visualize
    % It will be an array of 1s and 0s with 1s means that dimension should
    % be plotted.
    plotDims = extraArgs.plotData.plotDims;
    % Points to project other dimensions at. There should be an entry point
    % corresponding to each 0 in plotDims.
    projpt = extraArgs.plotData.projpt;
    % Initialize the figure for visualization
  else
    plotDims = ones(schemeData.grid.dim, 1);
    projpt = [];
  end
  
  f = figure;
  need_light = true;
end

% Extract the information about stopInit
if isfield(extraArgs, 'stopInit')
  initState = extraArgs.stopInit.initState;
end

%% SchemeFunc and SchemeData
schemeFunc = @termLaxFriedrichs;
% Extract accuracy parameter o/w set default accuracy
accuracy = 'veryHigh';
if isfield(schemeData, 'accuracy')
  accuracy = schemeData.accuracy;
end

%% Numerical approximation functions
dissType = 'global';
[schemeData.dissFunc, integratorFunc, schemeData.derivFunc] = ...
  getNumericalFuncs(dissType, accuracy);

%% Time integration
integratorOptions = odeCFLset('factorCFL', 0.8, 'stats', 'on', ...
  'singleStep', 'on');

startTime = cputime;

if schemeData.grid.dim == 1
  datal = zeros(length(data0l), length(tau));
  datau = zeros(length(data0u), length(tau));
else
  datal = zeros([size(data0l) length(tau)]);
  datau = zeros([size(data0u) length(tau)]);
end

datal(colons{:}, 1) = data0l;
datau(colons{:}, 1) = data0u;

schemeDataLower = schemeData;
schemeDataUpper = schemeData;
for i = 2:length(tau)
  %   y0 = eval(get_dataStr(g.dim, 'i-1'));
  y0l = datal(colons{:}, i-1);
  y0u = datau(colons{:}, i-1);
  yl = y0l(:);
  yu = y0u(:);
  
  tNow = tau(i-1);
  %% Main computation
  while tNow < tau(i) - small
    % Save previous data if needed
    if strcmp(minWith, 'zero')
      ylLast = yl;
      yuLast = yu;
    end
    
    % Compute controls to be used
    [ul, uu] = dblInt_JC_MIE(yl, yu, schemeData);
    schemeDataLower.uIn = ul;
    [~, yl] = feval(integratorFunc, schemeFunc, [tNow tau(i)], yl, ...
      integratorOptions, schemeDataLower);

    schemeDataUpper.uIn = uu;
    [tNow, yu] = feval(integratorFunc, schemeFunc, [tNow tau(i)], yu, ...
      integratorOptions, schemeDataUpper);    
    % Min with zero
    if strcmp(minWith, 'zero')
      yl = min(yl, ylLast);
      yu = min(yu, yuLast);
    end
  end
  
  % Reshape value function
  datal(colons{:}, i) = reshape(yl, schemeData.grid.shape);
  datau(colons{:}, i) = reshape(yu, schemeData.grid.shape);
  
  %% If commanded, stop the reachable set computation once it contains
  % the initial state.
  if isfield(extraArgs, 'stopInit')
    if iscolumn(initState)
      initState = initState';
    end
    %     reachSet = eval(get_dataStr(g.dim, 'i'));
    %     initValue = eval_u(g, reachSet, initState);
    initValue = eval_u(schemeData.grid, datal(colons{:}, i), initState);
    if ~isnan(initValue) && initValue <= 0
      extraOuts.stoptau = tau(i);
      datal(colons{:}, i+1:size(datal, schemeData.grid.dim+1)) = [];
      datau(colons{:}, i+1:size(datau, schemeData.grid.dim+1)) = [];
      tau(i+1:end) = [];
      break
    end
  end
  
  %% If commanded, visualize the level set.
  if isfield(extraArgs, 'visualize') && extraArgs.visualize
    % Number of dimensions to be plotted and to be projected
    pDims = nnz(plotDims);
    projDims = length(projpt);
    
    % Basic Checks
    if(length(plotDims) ~= schemeData.grid.dim || ...
        projDims ~= (schemeData.grid.dim - pDims))
      error('Mismatch between plot and grid dimesnions!');
    end
    
    if (pDims >= 4 || schemeData.grid.dim > 4)
      error('Currently only 3D plotting upto 3D is supported!');
    end
    
    % Visualize the reachable set
    figure(f)
    
    if projDims == 0
      extraOuts.hT = visSetMIE(schemeData.grid, datal(colons{:}, i), ...
        'r', 0, [], false);
      
      if need_light && schemeData.grid.dim == 3
        camlight left
        camlight right
        need_light = false;
      end
    else
      [gProj, dataProj] = proj(schemeData.grid, datal(colons{:}, i), ...
        1-plotDims, projpt);
      extraOuts.hT = visSetMIE(gProj, dataProj, 'r', 0, [], false);
      
      if need_light && gProj.dim == 3
        camlight left
        camlight right
        need_light = false;
      end
    end
    
    drawnow;
  end
end

endTime = cputime;
fprintf('Total execution time %g seconds\n', endTime - startTime);
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