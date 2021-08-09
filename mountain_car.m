%% https://rvl.cs.toronto.edu/backwards-reachability/#22-in-two-simple-dimensions
%% https://github.com/rvl-lab-utoronto/backwards-reachability

%% https://www.cs.ubc.ca/~mitchell/ToolboxLS/
%% https://github.com/HJReachability/helperOC/blob/master/Intro%20to%20Reachability%20Code.pdf


%% https://gieseanw.wordpress.com/2012/10/21/a-comprehensive-step-by-step-tutorial-to-computing-dubins-paths/ 

function mountain_car()
% 1. Run Backward Reachable Set (BRS) with a goal
%     uMode = 'min' <-- goal
%     minWith = 'none' <-- Set (not tube)
%     compTraj = false <-- no trajectory
% 2. Run BRS with goal, then optimal trajectory
%     uMode = 'min' <-- goal
%     minWith = 'none' <-- Set (not tube)
%     compTraj = true <-- compute optimal trajectory
% 3. Run Backward Reachable Tube (BRT) with a goal, then optimal trajectory
%     uMode = 'min' <-- goal
%     minWith = 'minVOverTime' <-- Tube (not set)
%     compTraj = true <-- compute optimal trajectory
% 5. Change to an avoid BRT rather than a goal BRT
%     uMode = 'max' <-- avoid
%     dMode = 'min' <-- opposite of uMode
%     minWith = 'minVOverTime' <-- Tube (not set)
%     compTraj = false <-- no trajectory
% 6. Change to a Forward Reachable Tube (FRT)
%     add schemeData.tMode = 'forward'
%     note: now having uMode = 'max' essentially says "see how far I can
%     reach"
% 7. Add obstacles
%     add the following code:
%     obstacles = shapeCylinder(g, 3, [-1.5; 1.5; 0], 0.75);
%     HJIextraArgs.obstacles = obstacles;
% 8. Add random disturbance (white noise)
%     add the following code:
%     HJIextraArgs.addGaussianNoiseStandardDeviation = [0; 0; 0.5];


%% https://en.wikipedia.org/wiki/Mountain_car_problem
%% https://github.com/openai/gym/blob/master/gym/envs/classic_control/mountain_car.py

min_velocity = -0.07;
max_velocity = 0.07;

min_position = -1.2;
max_position = 0.6;

%% Should we compute the trajectory?
compTraj = true;
% compTraj = false;

%% Grid
grid_min = [min_position; min_velocity]; % Lower corner of computation domain
grid_max = [max_position; max_velocity];    % Upper corner of computation domain
N = [181; 181];         % Number of grid points per dimension
grid = createGrid(grid_min, grid_max, N);

% state space dimensions

%% target set
% R = 1;
% data0 = shapeCylinder(grid,ignoreDims,center,radius)
% making the inital shape 
% data0 = shapeCylinder(grid, 3, [0; 0; 0], R);
% also try shapeRectangleByCorners, shapeSphere, etc.

% center = [0.55; 0];
% widths = [0.05; 0.01];

center = [0.5; 0];
widths = [0.1; 0.02];

data0 = shapeRectangleByCenter(grid, center, widths);

%% time vector
t0 = 0;
% changed the time from 2 seconds to 15
tMax = 80;
dt = 0.1;
tau = t0:dt:tMax;

%% problem parameters
gravity = 0.0025;
force = 0.001;

% control trying to min or max value function?
uMode = 'min';


%% Pack problem parameters

% Define dynamic system
mCar = MountainCarV0([0, 0], gravity, force);

% Put grid and dynamic systems into schemeData
schemeData.grid = grid;
schemeData.dynSys = mCar;
% schemeData.accuracy = 'high'; 
schemeData.accuracy = 'veryHigh'; 
schemeData.uMode = uMode;

%% Compute value function

HJIextraArgs.visualize.valueSet = 1;
HJIextraArgs.visualize.initialValueSet = 1;
HJIextraArgs.visualize.figNum = 1; %set figure number
HJIextraArgs.visualize.deleteLastPlot = true; %delete previous plot as you update
% HJIextraArgs.visualize.valueSetHeatMap = true;

HJIextraArgs.makeVideo = true; % generate video of output
% You can further customize the video file in the following ways 
% HJIextraArgs.videoFilename:       (string) filename of video
% HJIextraArgs.frameRate:           (int) framerate of video
HJIextraArgs.visualize.xTitle = 'x axis';
HJIextraArgs.visualize.yTitle = 'y axis';

% uncomment if you want to see a 2D slice
% HJIextraArgs.visualize.plotData.plotDims = [1 1 0]; %plot x, y
% HJIextraArgs.visualize.plotData.projpt = [0]; %project at theta = 0
% HJIextraArgs.visualize.viewAngle = [0,90]; % view 2D

%[data, tau, extraOuts] = ...
% HJIPDE_solve(data0, tau, schemeData, minWith, extraArgs)

minWith = 'none';
% minWith = 'maxVOverTime';

[data, tau2, ~] = ...
  HJIPDE_solve(data0, tau, schemeData, minWith, HJIextraArgs);

%% Compute optimal trajectory from some initial state
if compTraj
  pause
  
  %set the initial state
  xinit = [-0.5, 0];
  
  figure(6)
  clf
  h = visSetIm(grid, data(:,:,:,end));
%   h.FaceAlpha = .3;
  hold on
  s = scatter3(xinit(1), xinit(2), xinit(3));
  s.SizeData = 70;
  
  %check if this initial state is in the BRS/BRT
  %value = eval_u(g, data, x)
  value = eval_u(grid,data(:,:,:,end),xinit);
  
  if value <= 0 %if initial state is in BRS/BRT
    % find optimal trajectory
    
    mCar.x = xinit; %set initial state of the dubins car

    TrajextraArgs.uMode = uMode; %set if control wants to min or max
    TrajextraArgs.visualize = true; %show plot
    TrajextraArgs.fig_num = 2; %figure number
    
    %we want to see the first two dimensions (x and y)
    TrajextraArgs.projDim = [1 1 0]; 
    
    %flip data time points so we start from the beginning of time
    dataTraj = flip(data,4);
    
    % [traj, traj_tau] = ...
    % computeOptTraj(g, data, tau, dynSys, extraArgs)
    [traj, traj_tau] = ...
      computeOptTraj(grid, dataTraj, tau2, mCar, TrajextraArgs);
  else
    error(['Initial state is not in the BRS/BRT! It have a value of ' num2str(value,2)])
  end
end
end