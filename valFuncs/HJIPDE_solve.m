function [data, tau, extraOuts] = ...
  HJIPDE_solve(data0, tau, schemeData, minWith, extraArgs)
% [data, tau, extraOuts] = ...
%   HJIPDE_solve(data0, tau, schemeData, minWith, extraargs)
%     Solves HJIPDE with initial conditions data0, at times tau, and with
%     parameters schemeData and extraArgs
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
%     .compRegion: unused for now (meant to limit computation region)
%     .visualize:  set to true to visualize reachable set
%     .plotData:   information required to plot the data (need to fill in)
%     .deleteLastPlot:
%         set to true to delete previous plot before displaying next one
%     .fig_filename:
%         provide this to save the figures (requires export_fig package)
%     .stopInit:   stop the computation once the reachable set includes the
%                  initial state
%     .stopSetInclude:
%         stops computation when reachable set includes this set
%     .stopSetIntersect:
%         stops computation when reachable set intersects this set
%     .stopLevel:  level of the stopSet to check the inclusion for. Default
%                  level is zero.
%     .targets:    a single target or a list of targets with time
%                  stamps tau (targets must have same time stamp as the
%                  solution). This functionality is mainly useful when the
%                  targets are time-varying, in case of variational
%                  inequality for example; data0 can be used to
%                  specify the target otherwise.
%     .stopConverge:
%         set to true to stop the computation when it converges
%     .convergeThreshold:
%         Max change in each iteration allowed when checking convergence
%
%     .SDModFunc, .SDModParams:
%         Function for modifying scheme data every time step given by tau.
%         Currently this is only used to switch between using optimal control at
%         every grid point and using maximal control for the SPP project when
%         computing FRS using centralized controller
%
%     .save_filename, .saveFrequency:
%         file name under which temporary data is saved at some frequency in
%         terms of the number of time steps
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

if nargin < 4
  minWith = 'zero';
end

if nargin < 5
  extraArgs = [];
end

extraOuts = [];
small = 1e-4;
g = schemeData.grid;
gDim = g.dim;
colons = repmat({':'}, 1, gDim);


%% Extract the information from extraargs
% Extract the information about obstacles
obsMode = 'none';
if isfield(extraArgs, 'obstacles')
  obstacles = extraArgs.obstacles;
  
  if numDims(obstacles) == gDim
    obsMode = 'static';
    obstacle_i = obstacles;
  elseif numDims(obstacles) == gDim + 1
    obsMode = 'time-varying';
  else
    error('Inconsistent obstacle dimensions!')
  end
end

% Extract the information about targets
if isfield(extraArgs, 'targets')
  targets = extraArgs.targets;
end

% Check validity of stopInit if needed
if isfield(extraArgs, 'stopInit')
  if ~isvector(extraArgs.stopInit) || ...
      gDim ~= length(extraArgs.stopInit)
    error('stopInit must be a vector of length g.dim!')
  end
end

% Check validity of stopSet if needed
if isfield(extraArgs, 'stopSet') % For backwards compatibility
  extraArgs.stopSetInclude = extraArgs.stopSet;
end

if isfield(extraArgs,'stopSetInclude') || isfield(extraArgs,'stopSetIntersect')
  if isfield(extraArgs,'stopSetInclude')
    stopSet = extraArgs.stopSetInclude;
  else
    stopSet = extraArgs.stopSetIntersect;
  end
  
  if numDims(stopSet) ~= gDim || any(size(stopSet) ~= g.N')
    error('Inconsistent stopSet dimensions!')
  end
  
  % Extract set of indices at which stopSet is negative
  setInds = find(stopSet(:) < 0);
  
  % Check validity of stopLevel if needed
  if isfield(extraArgs, 'stopLevel')
    stopLevel = extraArgs.stopLevel;
  else
    stopLevel = 0;
  end
end

%% Visualization
if isfield(extraArgs, 'visualize') && extraArgs.visualize
  % Extract the information about plotData
  plotDims = ones(gDim, 1);
  projpt = [];  
  if isfield(extraArgs, 'plotData')
    % Dimensions to visualize
    % It will be an array of 1s and 0s with 1s means that dimension should
    % be plotted.
    plotDims = extraArgs.plotData.plotDims;
    % Points to project other dimensions at. There should be an entry point
    % corresponding to each 0 in plotDims.
    projpt = extraArgs.plotData.projpt;
  end
  
  deleteLastPlot = false;
  if isfield(extraArgs, 'deleteLastPlot')
    deleteLastPlot = extraArgs.deleteLastPlot;
  end
  
  % Initialize the figure for visualization  
  f = figure;
  hold on
  need_light = true;
  
  if strcmp(obsMode, 'static')
    visSetIm(g, obstacle_i, 'k');
  end
  
  if isfield(extraArgs, 'stopInit') 
    projectedInit = extraArgs.stopInit(logical(plotDims));
    if nnz(plotDims) == 2
      plot(projectedInit(1), projectedInit(2), 'b*')
    elseif nnz(plotDims) == 3
      plot3(projectedInit(1), projectedInit(2), projectedInit(3), 'b*')
    end
  end
end

% Extract cdynamical system if needed
if isfield(schemeData, 'dynSys')
  schemeData.hamFunc = @genericHam;
  schemeData.partialFunc = @genericPartial;
end

stopConverge = false;
if isfield(extraArgs, 'stopConverge')
  stopConverge = extraArgs.stopConverge;
  if isfield(extraArgs, 'convergeThreshold')
    convergeThreshold = extraArgs.convergeThreshold;
  else
    convergeThreshold = 1e-5;
  end
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
integratorOptions = odeCFLset('factorCFL', 0.8, 'singleStep', 'on');

startTime = cputime;

%% Initialize PDE solution
data0size = size(data0);
data = zeros([data0size(1:gDim) length(tau)]);

if numDims(data0) == gDim
  % New computation
  data(colons{:}, 1) = data0;
  istart = 2;
elseif numDims(data0) == gDim + 1
  % Continue an old computation
  data(colons{:}, 1:data0size(end)) = data0;
  
  % Start at custom starting index if specified
  if isfield(extraArgs, 'istart')
    istart = extraArgs.istart;
  else
    istart = data0size(end)+1;
  end
else
  error('Inconsistent initial condition dimension!')
end

for i = istart:length(tau)
  fprintf('tau(i) = %f\n', tau(i))
  %% Variable schemeData
  if isfield(extraArgs, 'SDModFunc')
    if isfield(extraArgs, 'SDModParams')
      paramsIn = extraArgs.SDModParams;
    else
      paramsIn = [];
    end
    
    schemeData = extraArgs.SDModFunc( ...
      schemeData, i, tau, data, obstacles, paramsIn);
  end
  
  y0 = data(colons{:}, i-1);
  y = y0(:);
  
  tNow = tau(i-1);
  %% Main integration loop to get to the next tau(i)
  while tNow < tau(i) - small
    % Save previous data if needed
    if strcmp(minWith, 'zero')
      yLast = y;
    end
    
    fprintf('  Computing [%f %f]...\n', tNow, tau(i))
    [tNow, y] = feval(integratorFunc, schemeFunc, [tNow tau(i)], y, ...
      integratorOptions, schemeData);
    
    if any(isnan(y))
      keyboard
    end
    
    % Min with zero
    if strcmp(minWith, 'zero')
      y = min(y, yLast);
    end
    
    % Min with targets
    if isfield(extraArgs, 'targets')
      if numDims(targets) == gDim
        y = min(y, targets(:));
      else
        target_i = targets(colons{:}, i);
        y = min(y, target_i(:));
      end
    end
    
    % "Mask" using obstacles
    if isfield(extraArgs, 'obstacles')
      if strcmp(obsMode, 'time-varying')
        obstacle_i = obstacles(colons{:}, i);
      end
      y = max(y, -obstacle_i(:));
    end
  end
  
  if stopConverge
    change = max(abs(y - y0(:)));
    fprintf('Max change since last iteration: %f\n', change)
  end
  
  % Reshape value function
  data(colons{:}, i) = reshape(y, g.shape);
  data_i = data(colons{:}, i);
  %% If commanded, stop the reachable set computation once it contains
  % the initial state.
  if isfield(extraArgs, 'stopInit')
    initValue = eval_u(g, data_i, extraArgs.stopInit);
    if ~isnan(initValue) && initValue <= 0
      extraOuts.stoptau = tau(i);
      data(colons{:}, i+1:size(data, gDim+1)) = [];
      tau(i+1:end) = [];
      break
    end
  end
  
  %% Stop computation if reachable set contains a "stopSet"
  if exist('stopSet', 'var')
    temp = data(colons{:}, i);
    dataInds = find(temp(:) <= stopLevel);
    
    if isfield(extraArgs, 'stopSetInclude')
      stopSetFun = @all;
    else
      stopSetFun = @any;
    end
    
    if stopSetFun(ismember(setInds, dataInds))
      extraOuts.stoptau = tau(i);
      data(colons{:}, i+1:size(data, gDim+1)) = [];
      tau(i+1:end) = [];
      break
    end
  end
  
  if stopConverge && change < convergeThreshold
    extraOuts.stoptau = tau(i);
    data(colons{:}, i+1:size(data, gDim+1)) = [];
    tau(i+1:end) = [];
    break
  end
  
  %% If commanded, visualize the level set.
  if isfield(extraArgs, 'visualize') && extraArgs.visualize
    % Number of dimensions to be plotted and to be projected
    pDims = nnz(plotDims);
    projDims = length(projpt);
    
    % Basic Checks
    if(length(plotDims) ~= gDim || projDims ~= (gDim - pDims))
      error('Mismatch between plot and grid dimensions!');
    end
    
    if (pDims >= 4 || gDim > 4)
      error('Currently plotting up to 3D is supported!');
    end
    
    % Visualize the reachable set
    figure(f)
    
    if deleteLastPlot 
      if isfield(extraOuts, 'hT')
        delete(extraOuts.hT);
      end
      
      if isfield(extraOuts, 'hO') && strcmp(obsMode, 'time-varying')
        delete(extraOuts.hO);
      end
    end
    
    if projDims == 0
      gPlot = g;
      dataPlot = data_i;
      
      if strcmp(obsMode, 'time-varying')
        obsPlot = obstacle_i;
      end
    else
      [gPlot, dataPlot] = proj(g, data_i, 1-plotDims, projpt);
      
      if strcmp(obsMode, 'time-varying')
        [~, obsPlot] = proj(g, obstacle_i, 1-plotDims, projpt);
      end
    end
    
    extraOuts.hT = visSetIm(gPlot, dataPlot, 'r', 0, [], false);
    
    if strcmp(obsMode, 'time-varying')
      extraOuts.hO = visSetIm(gPlot, obsPlot, 'k', 0, [], false);
    end
    
    if need_light && gDim == 3
      camlight left
      camlight right
      need_light = false;
    end
    title(['t = ' num2str(tNow)])
    drawnow;
    
    if isfield(extraArgs, 'fig_filename')
      export_fig(sprintf('%s%d', extraArgs.fig_filename, i), '-png')
    end
  end
  
  %% Save the results if needed
  if isfield(extraArgs, 'save_filename')
    if mod(i, extraArgs.saveFrequency) == 0
      ilast = i;
      save(extraArgs.save_filename, 'data', 'tau', 'ilast', '-v7.3')
    end
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