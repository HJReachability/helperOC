function [data, tau, extraOuts] = ...
    HJIPDE_solve(data0, tau, schemeData, compMethod, extraArgs)
% [data, tau, extraOuts] = ...
%   HJIPDE_solve(data0, tau, schemeData, minWith, extraargs)
%     Solves HJIPDE with initial conditions data0, at times tau, and with
%     parameters schemeData and extraArgs
%
% ----- How to use this function -----
%
% Inputs:
%   data0           - initial value function
%   tau             - list of computation times
%   schemeData      - problem parameters passed into the Hamiltonian func
%                       .grid: grid (required!)
%                       .accuracy: accuracy of derivatives
%   compMethod      - Informs which optimization we're doing
%                       - 'set' or 'none' to compute reachable set
%                         (not tube)
%                       - 'zero' or 'minWithZero' to min Hamiltonian with
%                          zero
%                       - 'minVOverTime' to do min with previous data
%                       - 'maxVOverTime' to do max with previous data
%                       - 'minVWithL' or 'minVWithTarget' to do min with
%                          targets
%                       - 'maxVWithL' or 'maxVWithTarget' to do max with
%                          targets
%                       - 'minVWithV0' to do min with original data
%                         (default)
%                       - 'maxVWithV0' to do max with original data
%   extraArgs       - this structure can be used to leverage other
%                       additional functionalities within this function.
%                       Its subfields are:
%     .obstacleFunction:    (matrix) a function describing a single
%                           obstacle or a list of obstacles with time
%                           stamps tau (obstacles must have same time stamp
%                           as the solution)
%     .targetFunction:      (matrix) the function l(x) that describes a
%                           stationary goal/unsafe set or a list of targets
%                           with time stamps tau (targets must have same
%                           time stamp as the solution). This functionality
%                           is mainly useful when the targets are
%                           time-varying, in case of variational inequality
%                           for example; data0 can be used to specify the
%                           target otherwise. This is also useful when
%                           warm-starting with a value function (data0)
%                           that is not equal to the target/cost function
%                           (l(x))
%     .keepLast:            (bool) Only keep data from latest time stamp
%                           and delete previous datas
%     .quiet:               (bool) Don't spit out stuff in command window
%     .lowMemory:           (bool) use methods to save on memory
%     .fipOutput:           (bool) flip time stamps of output
%     .stopInit:            (vector) stop the computation once the
%                           reachable set includes the initial state
%     .stopSetInclude:      (matrix) stops computation when reachable set
%                           includes this set
%     .stopSetIntersect:    (matrix) stops computation when reachable set
%                           intersects this set
%     .stopLevel:           (double) level of the stopSet to check the
%                           inclusion for. Default level is zero.
%     .stopConverge:        (bool) set to true to stop the computation when
%                           it converges
%     .convergeThreshold:   Max change in each iteration allowed when
%                           checking convergence
%     .ignoreBoundary:      Ignores the boundary of the grid when
%                           calculating convergence
%     .discountFactor:      (double) amount by which you'd like to discount
%                           the value function. Used for ensuring
%                           convergence. Remember to move your targets
%                           function (l(x)) and initial value function
%                           (data0) down so they are below 0 everywhere.
%                           you can raise above 0 by the same amount at the
%                           end.
%     .discountMode:        Options are 'Kene' or 'Jaime'.  Defaults to
%                           'Jaime'. Math is in Kene's minimum discounted
%                           rewards paper and Jaime's "bridging
%                           hamilton-jacobi safety analysis and
%                           reinforcement learning" paper
%     .discountAnneal:      (string) if you want to anneal your discount
%                           factor over time so it converges to the right
%                           solution, use this.
%                               - 'soft' moves it slowly towards 1 each
%                                 time convergence happens
%                               - 'hard' sets it to 1 once convergence
%                                  happens
%                               - 1 sets it to 'hard'
%     .SDModFunc, .SDModParams:
%         Function for modifying scheme data every time step given by tau.
%         Currently this is only used to switch between using optimal control at
%         every grid point and using maximal control for the SPP project when
%         computing FRS using centralized controller
%
%     .saveFilename, .saveFrequency:
%         file name under which temporary data is saved at some frequency in
%         terms of the number of time steps
%
%     .compRegion:          unused for now (meant to limit computation
%                           region)
%     .addGaussianNoiseStandardDeviation:
%           adds random noise
%
%     .makeVideo:           (bool) whether or not to create a video
%     .videoFilename:       (string) filename of video
%     .frameRate:           (int) framerate of video
%     .visualize:           either fill in struct or set to 1 for generic
%                           visualization
%                           .plotData:          (struct) information
%                                               required to plot the data:
%                                               .plotDims: dims to plot
%                                               .projpt: projection points.
%                                                        Can be vector or
%                                                        cell. e.g.
%                                                        {pi,'min'} means
%                                                        project at pi for
%                                                        first dimension,
%                                                        take minimum
%                                                        (union) for second
%                                                        dimension
%                           .sliceLevel:        (double) level set of
%                                               reachable set to visualize
%                                               (default is 0)
%                           .holdOn:            (bool) leave whatever was
%                                                already on the figure?
%                           .lineWidth:         (int) width of lines
%                           .viewAngle:         (vector) [az,el] angles for
%                                               viewing plot
%                           .camlightPosition:  (vector) location of light
%                                               source
%                           .viewGrid:          (bool) view grid
%                           .viewAxis:          (vector) size of axis
%                           .xTitle:            (string) x axis title
%                           .yTitle:            (string) y axis title
%                           .zTitle:            (string) z axis title
%                           .dtTime             How often you want to
%                                               update time stamp on title
%                                               of plot
%                           .fontSize:          (int) font size of figure
%                           .deleteLastPlot:    (bool) set to true to
%                                               delete previous plot
%                                               before displaying next one
%                           .figNum:            (int) for plotting a
%                                               specific figure number
%                           .figFilename:       (string) provide this to
%                                               save the figures (requires
%                                               export_fig package)
%                           .initialValueSet:   (bool) view initial value
%                                               set
%                           .initialValueFunction: (bool) view initial
%                                               value function
%                           .valueSet:          (bool) view value set
%                           .valueFunction:     (bool) view value function
%                           .obstacleSet:       (bool) view obstacle set
%                           .obstacleFunction:  (bool) view obstacle
%                                               function
%                           .targetSet:         (bool) view target set
%                           .targetFunction:    (bool) view target function
%                           .plotColorVS0:      color of initial value set
%                           .plotColorVF0:      color of initial value
%                                               function
%                           .plotAlphaVF0:      transparency of initial
%                                               value function
%                           .plotColorVS:       color of value set
%                           .plotColorVF:       color of value function
%                           .plotAlphaVF:       transparency of initial
%                                               value function
%                           .plotColorOS:       color of obstacle set
%                           .plotColorOF:       color of obstacle function
%                           .plotAlphaOF:       transparency of obstacle
%                                               function
%                           .plotColorTS:       color of target set
%                           .plotColorTF:       color of target function
%                           .plotAlphaTF:       transparency of target
%                                               function

% Outputs:
%   data - solution corresponding to grid g and time vector tau
%   tau  - list of computation times (redundant)
%   extraOuts - This structure can be used to pass on extra outputs, for
%               example:
%      .stoptau: time at which the reachable set contains the initial
%                state; tau and data vectors only contain the data till
%                stoptau time.
%
%      .hVS0:   These are all figure handles for the appropriate
%      .hVF0	set/function
%      .hTS
%      .hTF
%      .hOS
%      .hOF
%      .hVS
%      .hVF
%
%
% -------Updated 11/14/18 by Sylvia Herbert (sylvia.lee.herbert@gmail.com)
%

%% Default parameters
if numel(tau) < 2
    error('Time vector must have at least two elements!')
end

if nargin < 4
    compMethod = 'minVOverTime';
end

if nargin < 5
    extraArgs = [];
end

extraOuts = [];
quiet = false;
lowMemory = false;
keepLast = false;
flipOutput = false;

small = 1e-4;
g = schemeData.grid;
gDim = g.dim;
clns = repmat({':'}, 1, gDim);

%% Backwards compatible

if isfield(extraArgs, 'low_memory')
    extraArgs.lowMemory = extraArgs.low_memory;
    extraArgs = rmfield(extraArgs, 'low_memory');
    warning('we now use lowMemory instead of low_memory');
end

if isfield(extraArgs, 'flip_output')
    extraArgs.flipOutput = extraArgs.low_memory;
    extraArgs = rmfield(extraArgs, 'flip_output');
    warning('we now use flipOutput instead of flip_output');
end

if isfield(extraArgs, 'stopSet')
    extraArgs.stopSetInclude = extraArgs.stopSet;
    extraArgs = rmfield(extraArgs, 'stopSet');
    warning('we now use stopSetInclude instead of stopSet');
end

if isfield(extraArgs, 'visualize')
    
    
    if ~isstruct(extraArgs.visualize) && ...
            extraArgs.visualize
        % remove visualize boolean
        extraArgs = rmfield(extraArgs, 'visualize');
        
        % reset defaults
        extraArgs.visualize.initialValueSet = 1;
        extraArgs.visualize.valueSet = 1;
    end
    
    if isfield(extraArgs, 'RS_level')
        extraArgs.visualize.sliceLevel = extraArgs.RS_level;
        extraArgs = rmfield(extraArgs, 'RS_level');
        warning(['we now use extraArgs.visualize.sliceLevel instead of'...
            'extraArgs.RS_level']);
    end
    
    if isfield(extraArgs, 'plotData')
        extraArgs.visualize.plotData = extraArgs.plotData;
        extraArgs = rmfield(extraArgs, 'plotData');
        warning(['we now use extraArgs.visualize.plotData instead of'...
            'extraArgs.plotData']);
    end
    
    if isfield(extraArgs, 'deleteLastPlot')
        extraArgs.visualize.deleteLastPlot = extraArgs.deleteLastPlot;
        extraArgs = rmfield(extraArgs, 'deleteLastPlot');
        warning(['we now use extraArgs.visualize.deleteLastPlot instead'...
            'of extraArgs.deleteLastPlot']);
    end
    
    if isfield(extraArgs, 'fig_num')
        extraArgs.visualize.figNum = extraArgs.fig_num;
        extraArgs = rmfield(extraArgs, 'fig_num');
        warning(['we now use extraArgs.visualize.figNum instead'...
            'of extraArgs.fig_num']);
    end
    
    if isfield(extraArgs, 'fig_filename')
        extraArgs.visualize.figFilename = extraArgs.fig_filename;
        extraArgs = rmfield(extraArgs, 'fig_filename');
        warning(['we now use extraArgs.visualize.figFilename instead'...
            'of extraArgs.fig_filename']);
    end
    
    if isfield(extraArgs, 'target')
        warning(['you wrote extraArgs.target instead of' ...
            'extraArgs.targetFunction'])
        extraArgs.targetFunction = extraArgs.target;
        extraArgs = rmfield(extraArgs, 'target');
    end
    
    if isfield(extraArgs, 'targets')
        warning(['you wrote extraArgs.targets instead of' ...
            'extraArgs.targetFunction'])
        extraArgs.targetFunction = extraArgs.targets;
        extraArgs = rmfield(extraArgs, 'targets');
    end
    
    if isfield(extraArgs, 'obstacle')
        extraArgs.obstacleFunction = extraArgs.obstacle;
        warning(['you wrote extraArgs.obstacle instead of' ...
            'extraArgs.obstacleFunction'])
        extraArgs = rmfield(extraArgs, 'obstacle');
    end
    
    if isfield(extraArgs, 'obstacles')
        extraArgs.obstacleFunction = extraArgs.obstacles;
        warning(['you wrote extraArgs.obstacles instead of' ...
            'extraArgs.obstacleFunction'])
        extraArgs = rmfield(extraArgs, 'obstacles');
    end
end


%% Extract the information from extraargs
% Quiet mode
if isfield(extraArgs, 'quiet') && extraArgs.quiet
    fprintf('HJIPDE_solve running in quiet mode...\n')
    quiet = true;
end

% Low memory mode
if isfield(extraArgs, 'lowMemory') && extraArgs.lowMemory
    fprintf('HJIPDE_solve running in low memory mode...\n')
    lowMemory = true;
    
    % Save the output in reverse order
    if isfield(extraArgs, 'flipOutput') && extraArgs.flipOutput
        flipOutput = true;
    end
    
end

% Only keep latest data (saves memory)
if isfield(extraArgs, 'keepLast') && extraArgs.keepLast
    keepLast = true;
end

%---Extract the information about obstacles--------------------------------
obsMode = 'none';


if isfield(extraArgs, 'obstacleFunction')
    obstacles = extraArgs.obstacleFunction;
    
    % are obstacles moving or not?
    if numDims(obstacles) == gDim
        obsMode = 'static';
        obstacle_i = obstacles;
    elseif numDims(obstacles) == gDim + 1
        obsMode = 'time-varying';
        obstacle_i = obstacles(clns{:}, 1);
    else
        error('Inconsistent obstacle dimensions!')
    end
    
    % We always take the max between the data and the obstacles
    % note that obstacles are negated.  That's because if you define the
    % obstacles using something like ShapeSphere, it sets it up as a
    % target. To make it an obstacle we just negate that.
    data0 = max(data0, -obstacle_i);
end

%---Extract the information about targets----------------------------------
targMode = 'none';

if isfield(extraArgs, 'targetFunction')
    targets = extraArgs.targetFunction;
    
    % is target function moving or not?
    if numDims(targets) == gDim
        targMode = 'static';
        target_i = targets;
    elseif numDims(targets) == gDim + 1
        targMode = 'time-varying';
        target_i = targets(clns{:}, 1);
    else
        error('Inconsistent target dimensions!')
    end
end

%---Stopping Conditions----------------------------------------------------

% Check validity of stopInit if needed
if isfield(extraArgs, 'stopInit')
    if ~isvector(extraArgs.stopInit) || gDim ~= length(extraArgs.stopInit)
        error('stopInit must be a vector of length g.dim!')
    end
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
if (isfield(extraArgs, 'visualize') && isstruct(extraArgs.visualize))...
        || (isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo)
    % Mark initial iteration, state that for the first plot we need
    % lighting
    timeCount = 0;
    needLight = true;
    
    
    %---Video Parameters---------------------------------------------------
    
    % If we're making a video, set up the parameters
    if isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo
        if ~isfield(extraArgs, 'videoFilename')
            extraArgs.videoFilename = ...
                [datestr(now,'YYYYMMDD_hhmmss') '.mp4'];
        end
        
        vout = VideoWriter(extraArgs.videoFilename,'MPEG-4');
        vout.Quality = 100;
        if isfield(extraArgs, 'frameRate')
            vout.FrameRate = extraArgs.frameRate;
        else
            vout.FrameRate = 30;
        end
        
        try
            vout.open;
        catch
            error('cannot open file for writing')
        end
    end
    
    
    %---Projection Parameters----------------------------------------------
    
    % Extract the information about plotData
    plotDims = ones(gDim, 1);
    projpt = [];
    if isfield(extraArgs.visualize, 'plotData')
        % Dimensions to visualize
        % It will be an array of 1s and 0s with 1s means that dimension should
        % be plotted.
        plotDims = extraArgs.visualize.plotData.plotDims;
        
        % Points to project other dimensions at. There should be an entry point
        % corresponding to each 0 in plotDims.
        projpt = extraArgs.visualize.plotData.projpt;
    end
    
    % Number of dimensions to be plotted and to be projected
    pDims = nnz(plotDims);
    projDims = length(projpt);
    
    % Basic Checks
    if (pDims > 4)
        error('Currently plotting up to 3D is supported!');
    end
    
    %---Defaults-----------------------------------------------------------
    
    if isfield(extraArgs, 'obstacleFunction') && isfield(extraArgs, 'visualize')
        if ~isfield(extraArgs.visualize, 'obstacleSet')
            extraArgs.visualize.obstacleSet = 1;
        end
    end
    
    if isfield(extraArgs, 'targetFunction') && isfield(extraArgs, 'visualize')
        if ~isfield(extraArgs.visualize, 'targetSet')
            extraArgs.visualize.targetSet = 1;
        end
    end
    grid on
    
    % Number of dimensions to be plotted and to be projected
    pDims = nnz(plotDims);
    if isnumeric(projpt)
        projDims = length(projpt);
    else
        projDims = gDim - pDims;
    end
    
    % Set level set slice
    if isfield(extraArgs.visualize, 'sliceLevel')
        sliceLevel = extraArgs.visualize.sliceLevel;
    else
        sliceLevel = 0;
    end
    
    % Do we want to see every single plot at every single time step, or
    % only the most recent one?
    if isfield(extraArgs.visualize, 'deleteLastPlot')
        deleteLastPlot = extraArgs.visualize.deleteLastPlot;
    else
        deleteLastPlot = false;
    end
    
    
    view3D = 0;
    
    %---Perform Projections------------------------------------------------
    
    % Project
    if projDims == 0
        gPlot = g;
        dataPlot = data0;
        
        if isfield(extraArgs, 'obstacleFunction')
            obsPlot = obstacle_i;
        end
        if isfield(extraArgs, 'targetFunction')
            targPlot = target_i;
        end
    else
        % if projpt is a cell, project each dimensions separately. This
        % allows us to take the union/intersection through some dimensions
        % and to project at a particular slice through other dimensions.
        if iscell(projpt)
            idx = find(plotDims==0);
            plotDimsTemp = ones(size(plotDims));
            gPlot = g;
            dataPlot = data0;
            if isfield(extraArgs, 'obstacleFunction')
                obsPlot = obstacle_i;
            end
            if isfield(extraArgs, 'targetFunction')
                targPlot = target_i;
            end
            
            for ii = length(idx):-1:1
                plotDimsTemp(idx(ii)) = 0;
                if isfield(extraArgs, 'obstacleFunction')
                    [~, obsPlot] = proj(gPlot, obsPlot, ~plotDimsTemp,...
                        projpt{ii});
                end
                if isfield(extraArgs, 'targetFunction')
                    [~, targPlot] = proj(gPlot, targPlot, ...
                        ~plotDimsTemp, projpt{ii});
                end
                
                [gPlot, dataPlot] = proj(gPlot, dataPlot, ~plotDimsTemp,...
                    projpt{ii});
                plotDimsTemp = ones(1,gPlot.dim);
            end
            
        else
            [gPlot, dataPlot] = proj(g, data0, ~plotDims, projpt);
            
            if isfield(extraArgs, 'obstacleFunction')
                [~, obsPlot] = proj(g, obstacle_i, ~plotDims, projpt);
            end
            if isfield(extraArgs, 'targetFunction')
                [~, targPlot] = proj(g, target_i, ~plotDims, projpt);
            end
        end
        
        
        
    end
    
    
    
    
    %---Initialize Figure--------------------------------------------------
    
    
    % Initialize the figure for visualization
    if isfield(extraArgs.visualize,'figNum')
        f = figure(extraArgs.visualize.figNum);
    else
        f = figure;
    end
    
    % Clear figure unless otherwise specified
    if ~isfield(extraArgs.visualize,'holdOn')|| ~extraArgs.visualize.holdOn
        clf
    end
    hold on
    grid on
    
    % Set defaults
    eAT_visSetIm.sliceDim = gPlot.dim;
    eAT_visSetIm.applyLight = false;
    if isfield(extraArgs.visualize, 'lineWidth')
        eAT_visSetIm.LineWidth = extraArgs.visualize.lineWidth;
        eAO_visSetIm.LineWidth = extraArgs.visualize.lineWidth;
    else
        eAO_visSetIm.LineWidth = 2;
    end
    
    % If we're stopping once we hit an initial condition requirement, plot
    % said requirement
    if isfield(extraArgs, 'stopInit')
        projectedInit = extraArgs.stopInit(logical(plotDims));
        if nnz(plotDims) == 2
            plot(projectedInit(1), projectedInit(2), 'b*')
        elseif nnz(plotDims) == 3
            plot3(projectedInit(1), projectedInit(2), projectedInit(3), 'b*')
        end
    end
    
    %% Visualize Inital Value Function/Set
    
    %---Visualize Initial Value Set----------------------------------------
    if isfield(extraArgs.visualize, 'initialValueSet') &&...
            extraArgs.visualize.initialValueSet
        
        if ~isfield(extraArgs.visualize,'plotColorVS0')
            extraArgs.visualize.plotColorVS0 = 'g';
        end
        
        extraOuts.hVS0 = visSetIm(...
            gPlot, dataPlot, extraArgs.visualize.plotColorVS0,...
            sliceLevel, eAT_visSetIm);
        
        if isfield(extraArgs.visualize,'plotAlphaVS0')
            extraOuts.hVS0.FaceAlpha = extraArgs.visualize.plotAlphaVS0;
        end
    end
    
    %---Visualize Initial Value Function-----------------------------------
    if isfield(extraArgs.visualize, 'initialValueFunction') &&...
            extraArgs.visualize.initialValueFunction
        
        % If we're making a 3D plot, mark so we know to view this at an
        % angle appropriate for 3D
        if gPlot.dim >= 2
            view3D = 1;
        end
        
        % Set up default parameters
        if ~isfield(extraArgs.visualize,'plotColorVF0')
            extraArgs.visualize.plotColorVF0 = 'g';
        end
        
        if ~isfield(extraArgs.visualize,'plotAlphaVF0')
            extraArgs.visualize.plotAlphaVF0 = .5;
        end
        
        % Visualize Initial Value function (hVF0)
        [extraOuts.hVF0]= visFuncIm(gPlot,dataPlot,...
            extraArgs.visualize.plotColorVF0,...
            extraArgs.visualize.plotAlphaVF0);
    end
    
    %% Visualize Target Function/Set
    
    %---Visualize Target Set-----------------------------------------------
    if isfield(extraArgs.visualize, 'targetSet') ...
            && extraArgs.visualize.targetSet
        
        
        if ~isfield(extraArgs.visualize,'plotColorTS')
            extraArgs.visualize.plotColorTS = 'g';
        end
        
        extraOuts.hTS = visSetIm(gPlot, targPlot, ...
            extraArgs.visualize.plotColorTS, sliceLevel, eAT_visSetIm);
        
        if isfield(extraArgs.visualize,'plotAlphaTS')
            extraOuts.hTS.FaceAlpha = extraArgs.visualize.plotAlphaTS;
        end
    end
    
    %---Visualize Target Function------------------------------------------
    if isfield(extraArgs.visualize, 'targetFunction') &&...
            extraArgs.visualize.targetFunction
        % If we're making a 3D plot, mark so we know to view this at an
        % angle appropriate for 3D
        if gPlot.dim >= 2
            view3D = 1;
        end
        
        % Set up default parameters
        if ~isfield(extraArgs.visualize,'plotColorTF')
            extraArgs.visualize.plotColorTF = 'g';
        end
        
        if ~isfield(extraArgs.visualize,'plotAlphaTF')
            extraArgs.visualize.plotAlphaTF = .5;
        end
        
        % Visualize Target function (hTF)
        [extraOuts.hTF]= visFuncIm(gPlot,targPlot,...
            extraArgs.visualize.plotColorTF,...
            extraArgs.visualize.plotAlphaTF);
    end
    
    %% Visualize Obstacle Function/Set
    
    %---Visualize Obstacle Set---------------------------------------------
    if isfield(extraArgs.visualize, 'obstacleSet') ...
            && extraArgs.visualize.obstacleSet
        
        if ~isfield(extraArgs.visualize,'plotColorOS')
            extraArgs.visualize.plotColorOS = 'r';
        end
        
        % Visualize obstacle set (hOS)
        extraOuts.hOS = visSetIm(gPlot, obsPlot, ...
            extraArgs.visualize.plotColorOS, sliceLevel, eAO_visSetIm);
    end
    
    %---Visualize Obstacle Function----------------------------------------
    if  isfield(extraArgs.visualize, 'obstacleFunction') ...
            && extraArgs.visualize.obstacleFunction
        % If we're making a 3D plot, mark so we know to view this at an
        % angle appropriate for 3D
        if gPlot.dim >= 2
            view3D = 1;
        end
        
        % Set up default parameters
        if ~isfield(extraArgs.visualize,'plotColorOF')
            extraArgs.visualize.plotColorOF = 'r';
        end
        
        if ~isfield(extraArgs.visualize,'plotAlphaOF')
            extraArgs.visualize.plotAlphaOF = .5;
        end
        
        % Visualize function
        [extraOuts.hOF]= visFuncIm(gPlot,-obsPlot,...
            extraArgs.visualize.plotColorOF,...
            extraArgs.visualize.plotAlphaOF);
    end
    %% Visualize Value Function/Set
    %---Visualize Value Set Heat Map---------------------------------------
    if isfield(extraArgs.visualize, 'valueSetHeatMap') &&...
            extraArgs.visualize.valueSetHeatMap
        maxVal = max(abs(data0(:)));
        clims = [-maxVal-1 maxVal+1];
        extraOuts.hVSHeat = imagesc(...
            gPlot.vs{1},gPlot.vs{2},dataPlot,clims);
        if isfield(extraArgs.visualize,'colormap')
            colormap(extraArgs.visualize.colormap)
        else
            cmapAutumn = colormap('autumn');
            cmapCool = colormap('cool');
            cmap(1:32,:) = cmapCool(64:-2:1,:);
            cmap(33:64,:) = cmapAutumn(64:-2:1,:);
            colormap(cmap);
        end
        colorbar
    end
    
    %---Visualize Value Set------------------------------------------------
    if isfield(extraArgs.visualize, 'valueSet') &&...
            extraArgs.visualize.valueSet
        
        if ~isfield(extraArgs.visualize,'plotColorVS')
            extraArgs.visualize.plotColorVS = 'b';
        end
        
        extraOuts.hVS = visSetIm(gPlot, dataPlot, ...
            extraArgs.visualize.plotColorVS, sliceLevel, eAT_visSetIm);
    end
    
    %---Visualize Value Function-------------------------------------------
    if isfield(extraArgs.visualize, 'valueFunction') && ...
            extraArgs.visualize.valueFunction
        % If we're making a 3D plot, mark so we know to view this at an
        % angle appropriate for 3D
        if gPlot.dim >= 2
            view3D = 1;
        end
        
        % Set up default parameters
        if ~isfield(extraArgs.visualize,'plotColorVF')
            extraArgs.visualize.plotColorVF = 'b';
        end
        
        if ~isfield(extraArgs.visualize,'plotAlphaVF')
            extraArgs.visualize.plotAlphaVF = .5;
        end
        
        % Visualize Value function (hVF)
        [extraOuts.hVF]= visFuncIm(gPlot,dataPlot,...
            extraArgs.visualize.plotColorVF,...
            extraArgs.visualize.plotAlphaVF);
        
    end
    
    %% General Visualization Stuff
    
    %---Set Angle, Lighting, axis, Labels, Title---------------------------
    
    % Set Angle
    if pDims >2 || view3D || isfield(extraArgs.visualize, 'viewAngle')
        if isfield(extraArgs.visualize, 'viewAngle')
            view(extraArgs.visualize.viewAngle)
        else
            view(30,10)
        end
        
        % Set Lighting
        if needLight% && (gPlot.dim == 3)
            lighting phong
            c = camlight;
            %need_light = false;
        end
        if isfield(extraArgs.visualize, 'camlightPosition')
            c.Position = extraArgs.visualize.camlightPosition;
        else
            c.Position = [-30 -30 -30];
        end
    end
    
    % Grid and axis
    if isfield(extraArgs.visualize, 'viewGrid') && ...
            ~extraArgs.visualize.viewGrid
        grid off
    end
    
    if isfield(extraArgs.visualize, 'viewAxis')
        axis(extraArgs.visualize.viewAxis)
    end
    axis square
    
    % Labels
    if isfield(extraArgs.visualize, 'xTitle')
        xlabel(extraArgs.visualize.xTitle, 'interpreter','latex')
    end
    
    if isfield(extraArgs.visualize, 'yTitle')
        ylabel(extraArgs.visualize.yTitle,'interpreter','latex')
    end
    
    if isfield(extraArgs.visualize, 'zTitle')
        zlabel(extraArgs.visualize.zTitle,'interpreter','latex')
    end
    
    title(['t = ' num2str(0) ' s'])
    set(gcf,'Color','white')
    
    if isfield(extraArgs.visualize, 'fontSize')
        set(gca,'FontSize',extraArgs.visualize.fontSize)
    end
    
    if isfield(extraArgs.visualize, 'lineWidth')
        set(gca,'LineWidth',extraArgs.visualize.lineWidth)
    end
    
    drawnow;
    
    % If we're making a video, grab the frame
    if isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo
        current_frame = getframe(gcf); %gca does just the plot
        writeVideo(vout,current_frame);
    end
    
    % If we're saving each figure, do so now
    if isfield(extraArgs.visualize, 'figFilename')
        export_fig(sprintf('%s%d', extraArgs.visualize.figFilename, 0), '-png')
    end
end


%% Extract dynamical system if needed
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

% if we're doing minWithZero or zero as the comp method, actually implement
% correctly using level set toolbox
if strcmp(compMethod, 'minWithZero') || strcmp(compMethod, 'zero')
    schemeFunc = @termRestrictUpdate;
    schemeData.innerFunc = @termLaxFriedrichs;
    schemeData.innerData = schemeData;
    schemeData.innerData = schemeData;
    schemeData.positive = 0;
end

%% Time integration
integratorOptions = odeCFLset('factorCFL', 0.8, 'singleStep', 'on');

startTime = cputime;

%% Stochastic additive terms
if isfield(extraArgs, 'addGaussianNoiseStandardDeviation')
    % We are taking all the previous scheme terms and adding noise to it
    % Save all the previous terms as the deterministic component in detFunc
    detFunc = schemeFunc;
    detData = schemeData;
    % The full computation scheme will include this added term so clear
    % out the schemeFunc so we can pack everything back in later with the
    % new stuff
    clear schemeFunc schemeData;
    
    % Create the Hessian term corresponding to white noise diffusion
    stochasticFunc = @termTraceHessian;
    stochasticData.grid = g;
    stochasticData.L = extraArgs.addGaussianNoiseStandardDeviation';
    stochasticData.R = extraArgs.addGaussianNoiseStandardDeviation;
    stochasticData.hessianFunc = @hessianSecond;
    
    % Add the (saved) deterministic terms and the (new) stochastic term
    % together into the complete scheme
    schemeFunc = @termSum;
    schemeData.innerFunc = { detFunc; stochasticFunc };
    schemeData.innerData = { detData; stochasticData };
end

%% Initialize PDE solution
data0size = size(data0);

if numDims(data0) == gDim
    % New computation
    if keepLast
        data = data0;
    elseif lowMemory
        data = single(data0);
    else
        data = zeros([data0size(1:gDim) length(tau)]);
        data(clns{:}, 1) = data0;
    end
    
    istart = 2;
elseif numDims(data0) == gDim + 1
    % Continue an old computation
    if keepLast
        data = data0(clns{:}, data0size(end));
    elseif lowMemory
        data = single(data0(clns{:}, data0size(end)));
    else
        data = zeros([data0size(1:gDim) length(tau)]);
        data(clns{:}, 1:data0size(end)) = data0;
    end
    
    % Start at custom starting index if specified
    if isfield(extraArgs, 'istart')
        istart = extraArgs.istart;
    else
        istart = data0size(end)+1;
    end
else
    error('Inconsistent initial condition dimension!')
end


if isfield(extraArgs,'ignoreBoundary') &&...
        extraArgs.ignoreBoundary
    [~, dataTrimmed] = truncateGrid(...
        g, data0, g.min+4*g.dx, g.max-4*g.dx);
end

for i = istart:length(tau)
    if ~quiet
        fprintf('tau(i) = %f\n', tau(i))
    end
    %% Variable schemeData
    if isfield(extraArgs, 'SDModFunc')
        if isfield(extraArgs, 'SDModParams')
            paramsIn = extraArgs.SDModParams;
        else
            paramsIn = [];
        end
        
        schemeData = extraArgs.SDModFunc(schemeData, i, tau, data, obstacles, ...
            paramsIn);
    end
    
    if keepLast
        y0 = data;
    elseif lowMemory
        if flipOutput
            y0 = data(clns{:}, 1);
        else
            y0 = data(clns{:}, size(data, g.dim+1));
        end
        
    else
        y0 = data(clns{:}, i-1);
    end
    y = y0(:);
    
    
    tNow = tau(i-1);
    
    %% Main integration loop to get to the next tau(i)
    while tNow < tau(i) - small
        % Save previous data if needed
        if strcmp(compMethod, 'minVOverTime') || ...
                strcmp(compMethod, 'maxVOverTime')
            yLast = y;
        end
        
        if ~quiet
            fprintf('  Computing [%f %f]...\n', tNow, tau(i))
        end

        
        % Solve hamiltonian and apply to value function (y) to get updated
        % value function
        [tNow, y] = feval(integratorFunc, schemeFunc, [tNow tau(i)], y, ...
            integratorOptions, schemeData);
        
        
        
        if any(isnan(y))
            keyboard
        end
        
        
        %% Here's where we do the min/max for BRTS or nothing for BRSs.  Note that
        %  if we're doing discounting there are two methods: Kene's and Jaime's.
        %  Kene requires that we do the compmethod inside of the discounting.
        %  Jaime's does not.  Thus why the if statements are a little funky.
        
        % 1. If not discounting at all OR not discounting using Kene's
        %    method, do normal compMethod first
        if ~isfield(extraArgs, 'discountMode') || ...
                ~strcmp(extraArgs.discountMode, 'Kene')
            
            %   compMethod
            % - 'set' or 'none' to compute reachable set (not tube)
            % - 'zero' or 'minWithZero' to min Hamiltonian with zero
            % - 'minVOverTime' to do min with previous data
            % - 'maxVOverTime' to do max with previous data
            % - 'minVWithL' or 'minVWithTarget' to do min with targets
            % - 'maxVWithL' or 'maxVWithTarget' to do max with targets
            % - 'minVWithV0' to do min with original data (default)
            % - 'maxVWithV0' to do max with original data
            
            if strcmp(compMethod, 'zero') ...
                    || strcmp(compMethod, 'set')...
                    || strcmp(compMethod, 'none')
                % note: compMethod 'zero' is handled at the beginning of
                % the code. compMethod 'set' and 'none' require no
                % computation.
            elseif strcmp(compMethod, 'minVOverTime') %Min over Time
                y = min(y, yLast);
            elseif strcmp(compMethod, 'maxVOverTime')
                y = max(y, yLast);
            elseif strcmp(compMethod, 'minVWithV0')%Min with data0
                y = min(y,data0(:));
            elseif strcmp(compMethod, 'maxVWithV0')
                y = max(y,data0(:));
            elseif strcmp(compMethod, 'maxVWithL')...
                    || strcmp(compMethod, 'maxVwithL') ...
                    || strcmp(compMethod, 'maxVWithTarget')
                if ~isfield(extraArgs, 'targetFunction')
                    error('Need to define target function l(x)!')
                end
                if numDims(targets) == gDim
                    y = max(y, targets(:));
                else
                    target_i = targets(clns{:}, i);
                    y = max(y, target_i(:));
                end
            elseif strcmp(compMethod, 'minVWithL') ...
                    || strcmp(compMethod, 'minVwithL') ...
                    || strcmp(compMethod, 'minVWithTarget')
                if ~isfield(extraArgs, 'targetFunction')
                    error('Need to define target function l(x)!')
                end
                if numDims(targets) == gDim
                    y = min(y, targets(:));
                else
                    target_i = targets(clns{:}, i);
                    y = min(y, target_i(:));
                end
                
            else
                error('Check which compMethod you are using')
            end
            
            
            % 2. If doing discounting but not using Kene's method, default
            %    to Jaime's method from ICRA 2019 paper
            if isfield(extraArgs, 'discountFactor') && ...
                    extraArgs.discountFactor && ...
                    (~isfield(extraArgs, 'discountMode') || ...
                    strcmp(extraArgs.discountMode,'Kene'))
                y = extraArgs.discountFactor*y;
                
                if isfield(extraArgs, 'targetFunction')
                    y = y + ...
                        (1-extraArgs.discountFactor).*extraArgs.targets(:);
                else
                    y = y + ...
                        (1-extraArgs.discountFactor).*data0(:);
                end
            end
            
            
            
            % 3. If we are doing Kene's discounting from minimum discounted
            %    rewards paper, do that now and do compmethod with it
        elseif isfield(extraArgs, 'discountFactor') && ...
                extraArgs.discountFactor && ...
                isfield(extraArgs, 'discountMode') && ...
                strcmp(extraArgs.discountMode,'Kene')
            
            if ~isfield(extraArgs, 'targetFunction')
                error('Need to define target function l(x)!')
            end
            
            % move everything below 0
            maxVal = max(abs(extraArgs.targetFunction(:)));
            ytemp = y - maxVal;
            targettemp = extraArgs.targetFunction - maxVal;
            
            % Discount
            ytemp = extraArgs.discountFactor*ytemp;
            
            if strcmp(compMethod, 'minVWithL') ...
                    || strcmp(compMethod, 'minVwithL') ...
                    || strcmp(compMethod, 'minVWithTarget')
                % Take min
                ytemp = min(ytemp, targettemp(:));
                
            elseif strcmp(compMethod, 'maxVWithL')...
                    || strcmp(compMethod, 'maxVwithL') ...
                    || strcmp(compMethod, 'maxVWithTarget')
                % Take max
                ytemp = max(ytemp, targettemp(:));
            else
                error('check your compMethod!')
            end
            
            % restore height
            y = ytemp + maxVal;
        else
            % if this didn't work, check why
            error('check your discountFactor and discountMode')
        end
        
        
        
        
        % "Mask" using obstacles
        if isfield(extraArgs, 'obstacleFunction')
            if strcmp(obsMode, 'time-varying')
                obstacle_i = obstacles(clns{:}, i);
            end
            y = max(y, -obstacle_i(:));
        end
        
        
        % Update target function
        if isfield(extraArgs, 'targetFunction')
            if strcmp(targMode, 'time-varying')
                target_i = targets(clns{:}, i);
            end
        end
        
        
    end
    
    % Reshape value function
    data_i = reshape(y, g.shape);
    if keepLast
        data = data_i;
    elseif lowMemory
        if flipOutput
            data = cat(g.dim+1, reshape(y, g.shape), data);
        else
            data = cat(g.dim+1, data, reshape(y, g.shape));
        end
        
    else
        data(clns{:}, i) = data_i;
    end
    
    % If we're stopping once converged, print how much change there was in
    % the last iteration
    if stopConverge
        if isfield(extraArgs,'ignoreBoundary') &&...
                extraArgs.ignoreBoundary
            [~, dataNew] = truncateGrid(...
                g, data_i, g.min+4*g.dx, g.max-4*g.dx);
            change = max(abs(dataNew(:)-dataTrimmed(:)));
            dataTrimmed = dataNew;
            if ~quiet
                fprintf('Max change since last iteration: %f\n', change)
            end
        else
            change = max(abs(y - y0(:)));
            if ~quiet
                fprintf('Max change since last iteration: %f\n', change)
            end
        end
    end
    
    %% If commanded, stop the reachable set computation once it contains
    % the initial state.
    if isfield(extraArgs, 'stopInit')
        initValue = eval_u(g, data_i, extraArgs.stopInit);
        if ~isnan(initValue) && initValue <= 0
            extraOuts.stoptau = tau(i);
            tau(i+1:end) = [];
            
            if ~lowMemory && ~keepLast
                data(clns{:}, i+1:size(data, gDim+1)) = [];
            end
            break
        end
    end
    
    %% Stop computation if reachable set contains a "stopSet"
    if exist('stopSet', 'var')
        dataInds = find(data_i(:) <= stopLevel);
        
        if isfield(extraArgs, 'stopSetInclude')
            stopSetFun = @all;
        else
            stopSetFun = @any;
        end
        
        if stopSetFun(ismember(setInds, dataInds))
            extraOuts.stoptau = tau(i);
            tau(i+1:end) = [];
            
            if ~lowMemory && ~keepLast
                data(clns{:}, i+1:size(data, gDim+1)) = [];
            end
            break
        end
    end
    
    %% Stop computation if we've converged
    if stopConverge && change < convergeThreshold
        
        if isfield(extraArgs, 'discountFactor') && ...
                extraArgs.discountFactor && ...
                isfield(extraArgs, 'discountAnneal') && ...
                extraArgs.discountFactor ~= 1
            
            if strcmp(extraArgs.discountAnneal, 'soft')
                extraArgs.discountFactor = 1-((1-extraArgs.discountFactor)/2);
                
                if abs(1-extraArgs.discountFactor) < .00005
                    extraArgs.discountFactor = 1;
                end
                fprintf('\nDiscount factor: %f\n\n', ...
                    extraArgs.discountFactor)
            elseif strcmp(extraArgs.discountAnneal, 'hard') ...
                    || extraArgs.discountAnneal==1
                extraArgs.discountFactor = 1;
                fprintf('\nDiscount factor: %f\n\n', ...
                    extraArgs.discountFactor)
            end
        else
            extraOuts.stoptau = tau(i);
            tau(i+1:end) = [];
            
            if ~lowMemory && ~keepLast
                data(clns{:}, i+1:size(data, gDim+1)) = [];
            end
            break
        end
    end
    
    %% If commanded, visualize the level set.
    
    if (isfield(extraArgs, 'visualize') && ...
            (isstruct(extraArgs.visualize) || extraArgs.visualize == 1))...
            || (isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo)
        timeCount = timeCount + 1;

        % Number of dimensions to be plotted and to be projected
        pDims = nnz(plotDims);
        if isnumeric(projpt)
            projDims = length(projpt);
        else
            projDims = gDim - pDims;
        end

        % Basic Checks
        if(length(plotDims) ~= gDim || projDims ~= (gDim - pDims))
            error('Mismatch between plot and grid dimensions!');
        end

        
        %---Delete Previous Plot-------------------------------------------
        
        if deleteLastPlot
            if isfield(extraOuts, 'hOS') && strcmp(obsMode, 'time-varying')
                if iscell(extraOuts.hOS)
                    for hi = 1:length(extraOuts.hOS)
                        delete(extraOuts.hOS{hi})
                    end
                else
                    delete(extraOuts.hOS);
                end
            end
            
            if isfield(extraOuts, 'hOF') && strcmp(obsMode, 'time-varying')
                if iscell(extraOuts.hOF)
                    for hi = 1:length(extraOuts.hOF)
                        delete(extraOuts.hOF{hi})
                    end
                else
                    delete(extraOuts.hOF);
                end
            end
            if isfield(extraOuts, 'hTS') && strcmp(targMode, 'time-varying')
                if iscell(extraOuts.hTS)
                    for hi = 1:length(extraOuts.hTS)
                        delete(extraOuts.hTS{hi})
                    end
                else
                    delete(extraOuts.hTS);
                end
            end
            
            if isfield(extraOuts, 'hTF') && strcmp(targMode, 'time-varying')
                if iscell(extraOuts.hTF)
                    for hi = 1:length(extraOuts.hTF)
                        delete(extraOuts.hTF{hi})
                    end
                else
                    delete(extraOuts.hTF);
                end
            end
            if isfield(extraOuts, 'hVSHeat')
                if iscell(extraOuts.hVSHeat)
                    for hi = 1:length(extraOuts.hVSHeat)
                        delete(extraOuts.hVSHeat{hi})
                    end
                else
                    delete(extraOuts.hVSHeat);
                end
            end
            if isfield(extraOuts, 'hVS')
                if iscell(extraOuts.hVS)
                    for hi = 1:length(extraOuts.hVS)
                        delete(extraOuts.hVS{hi})
                    end
                else
                    delete(extraOuts.hVS);
                end
            end
            if isfield(extraOuts, 'hVF')
                if iscell(extraOuts.hVF)
                    for hi = 1:length(extraOuts.hVF)
                        delete(extraOuts.hVF{hi})
                    end
                else
                    delete(extraOuts.hVF);
                end
            end
            
        end
        
        %---Perform Projections--------------------------------------------
        
        % Project
        if projDims == 0
            gPlot = g;
            dataPlot = data_i;
            
            if strcmp(obsMode, 'time-varying')
                obsPlot = obstacle_i;
            end
            
            if strcmp(targMode, 'time-varying')
                targPlot = target_i;
            end
        else
            % if projpt is a cell, project each dimensions separately. This
            % allows us to take the union/intersection through some dimensions
            % and to project at a particular slice through other dimensions.
            if iscell(projpt)
                idx = find(plotDims==0);
                plotDimsTemp = ones(size(plotDims));
                gPlot = g;
                dataPlot = data_i;
                if strcmp(obsMode, 'time-varying')
                    obsPlot = obstacle_i;
                end
                
                if strcmp(targMode, 'time-varying')
                    targPlot = target_i;
                end
                
                for ii = length(idx):-1:1
                    plotDimsTemp(idx(ii)) = 0;
                    if strcmp(obsMode, 'time-varying')
                        [~, obsPlot] = proj(gPlot, obsPlot, ~plotDimsTemp,...
                            projpt{ii});
                    end
                    
                    if strcmp(targMode, 'time-varying')
                        [~, targPlot] = proj(gPlot, targPlot, ~plotDimsTemp,...
                            projpt{ii});
                    end
                    
                    [gPlot, dataPlot] = proj(gPlot, dataPlot, ~plotDimsTemp,...
                        projpt{ii});
                    plotDimsTemp = ones(1,gPlot.dim);
                end
                
            else
                [gPlot, dataPlot] = proj(g, data_i, ~plotDims, projpt);
                
                if strcmp(obsMode, 'time-varying')
                    [~, obsPlot] = proj(g, obstacle_i, ~plotDims, projpt);
                end
                
                if strcmp(targMode, 'time-varying')
                    [~, targPlot] = proj(g, obstacle_i, ~plotDims, projpt);
                end
            end
            
            
        end
        
        
        
        %% Visualize Target Function/Set
        
        %---Visualize Target Set-----------------------------------------------
        if strcmp(targMode, 'time-varying') ...
                && isfield(extraArgs.visualize, 'targetSet') ...
                && extraArgs.visualize.targetSet
            
            % Visualize obstacle set (hOS)
            extraOuts.hTS = visSetIm(gPlot, targPlot, ...
                extraArgs.visualize.plotColorTS, sliceLevel, eAT_visSetIm);
            
            if isfield(extraArgs.visualize,'plotAlphaTS')
                extraOuts.hTS.FaceAlpha = extraArgs.visualize.plotAlphaTS;
            end
            
        end
        
        %---Visualize Target Function------------------------------------------
        if  strcmp(targMode, 'time-varying') ...
                && isfield(extraArgs.visualize, 'targetFunction')...
                && extraArgs.visualize.targetFunction
            
            % Visualize function
            [extraOuts.hTF]= visFuncIm(gPlot,targPlot,...
                extraArgs.visualize.plotColorTF,...
                extraArgs.visualize.plotAlphaTF);
        end
        
        %% Visualize Obstacle Function/Set
        
        %---Visualize Obstacle Set-----------------------------------------
        if strcmp(obsMode, 'time-varying') ...
                && isfield(extraArgs.visualize, 'obstacleSet') ...
                && extraArgs.visualize.obstacleSet
            
            % Visualize obstacle set (hOS)
            extraOuts.hOS = visSetIm(gPlot, obsPlot, ...
                extraArgs.visualize.plotColorOS, sliceLevel, eAO_visSetIm);
            
            if isfield(extraArgs.visualize,'plotAlphaOS')
                extraOuts.hOS.FaceAlpha = extraArgs.visualize.plotAlphaOS;
            end
        end
        
        %---Visualize Obstacle Function------------------------------------
        if  strcmp(obsMode, 'time-varying') ...
                && extraArgs.visualize.obstacleFunction
            
            % Visualize function
            [extraOuts.hOF]= visFuncIm(gPlot,-obsPlot,...
                extraArgs.visualize.plotColorOF,...
                extraArgs.visualize.plotAlphaOF);
        end
        %% Visualize Value Function/Set
        %---Visualize Value Set Heat Map-----------------------------------
        if isfield(extraArgs.visualize, 'valueSetHeatMap') &&...
                extraArgs.visualize.valueSetHeatMap
            extraOuts.hVSHeat = imagesc(...
                gPlot.vs{1},gPlot.vs{2},dataPlot,clims);
            %colorbar
        end
        %---Visualize Value Set--------------------------------------------
        if isfield(extraArgs.visualize, 'valueSet') &&...
                extraArgs.visualize.valueSet
            
            extraOuts.hVS = visSetIm(gPlot, dataPlot, ...
                extraArgs.visualize.plotColorVS, sliceLevel, eAT_visSetIm);
        end
        
        if isfield(extraArgs.visualize,'plotAlphaVS')
            extraOuts.hVS.FaceAlpha = extraArgs.visualize.plotAlphaVS;
        end
        %---Visualize Value Function---------------------------------------
        if isfield(extraArgs.visualize, 'valueFunction') && ...
                extraArgs.visualize.valueFunction
            % Visualize Target function (hTF)
            [extraOuts.hVF]= visFuncIm(gPlot,dataPlot,...
                extraArgs.visualize.plotColorVF,...
                extraArgs.visualize.plotAlphaVF);
            
        end
        
        %---Update Title---------------------------------------------------
        if ~isfield(extraArgs.visualize, 'dtTime') &&...
                ~isfield(extraArgs.visualize, 'convergeTitle')
            title(['t = ' num2str(tNow,'%4.2f') ' s'])
        elseif isfield(extraArgs.visualize, 'dtTime') && floor(...
                extraArgs.visualize.dtTime/((tau(end)-tau(1))/length(tau))) ...
                == timeCount
            
            title(['t = ' num2str(tNow,'%4.2f') ' s'])
            timeCount = 0;
        elseif isfield(extraArgs,'stopConverge') &&...
                extraArgs.stopConverge &&...
                isfield(extraArgs.visualize, 'convergeTitle') &&...
                extraArgs.visualize.convergeTitle
            title(['t = ' num2str(tNow, '%4.2f') ...
                ' s, max change = ' num2str(change,'%4.4f')])
        else
            title(['t = ' num2str(tNow,'%4.2f') ' s'])
        end
        drawnow;
        
        
        %---Save Video, Figure---------------------------------------------
        if isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo
            current_frame = getframe(gcf); %gca does just the plot
            writeVideo(vout,current_frame);
        end
        
        if isfield(extraArgs.visualize, 'figFilename')
            export_fig(sprintf('%s%d', ...
                extraArgs.visualize.figFilename, i), '-png')
        end
        
    end
    
    %% Save the results if needed
    if isfield(extraArgs, 'saveFilename')
        if mod(i, extraArgs.saveFrequency) == 0
            ilast = i;
            save(extraArgs.saveFilename, 'data', 'tau', 'ilast', '-v7.3')
        end
    end
end

%% Finish up
if isfield(extraArgs, 'discountFactor') && extraArgs.discountFactor
    extraOuts.discountFactor = extraArgs.discountFactor;
end

endTime = cputime;
if ~quiet
    fprintf('Total execution time %g seconds\n', endTime - startTime);
end

if isfield(extraArgs, 'makeVideo') && extraArgs.makeVideo
    vout.close
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
        error('Unknown dissipation function %s', dissType);
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