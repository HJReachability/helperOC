function helperOC_tutorial()
% modify size of the white noise's variance or the control bounds to the
% effect of the additive random noise.
% To do this, modify the wMax or
% HJIextraArgs.addGausianNoiseStandardDeviation variables

%% Should we compute the trajectory?
compTraj = false;

%% Grid
grid_min = [-5; -5]; % Lower corner of computation domain
grid_max = [5; 5];    % Upper corner of computation domain
N = [41; 41];         % Number of grid points per dimension
g = createGrid(grid_min, grid_max, N);
% Use "g = createGrid(grid_min, grid_max, N);" if there are no periodic
% state space dimensions

%% target set
R = 1;
% data0 = shapeCylinder(grid,ignoreDims,center,radius)
data0 = shapeCylinder(g, 2, [0; 0], R);
% also try shapeRectangleByCorners, shapeSphere, etc.

%% time vector
t0 = 0;
tMax = 2;
dt = 0.05;
tau = t0:dt:tMax;

%% problem parameters

% input bounds
wMax = 1; % try wMax = 0.1
HJIextraArgs.addGaussianNoiseStandardDeviation = [0;0.3]; % try [0;2]

% control trying to min or max value function?
uMode = 'max';
dMode = 'min';

%% Pack problem parameters

% Define dynamic system
dubInt = DoubleInt([0,0],[-wMax,wMax])

% Put grid and dynamic systems into schemeData
schemeData.grid = g;
schemeData.dynSys = dubInt;
schemeData.accuracy = 'high'; %set accuracy
schemeData.uMode = uMode;
schemeData.dMode = dMode;


%% If you have obstacles, compute them here
%{
obstacles = shapeCylinder(g, 3, [-1.5;-1.5;0], 0.75);
HJIextraArgs.obstacles = obstacles;
%}

%% Compute value function

HJIextraArgs.visualize = true; %show plot
HJIextraArgs.fig_num = 1; %set figure number
HJIextraArgs.deleteLastPlot = true; %delete previous plot as you update

%[data, tau, extraOuts] = ...
% HJIPDE_solve(data0, tau, schemeData, minWith, extraArgs)
[data, tau2, ~] = ...
  HJIPDE_solve(data0, tau, schemeData, 'zero', HJIextraArgs);

%% Compute optimal trajectory from some initial state
if compTraj
  pause
  
  %set the initial state
  xinit = [2, 1, -pi];
  
  %check if this initial state is in the BRS/BRT
  %value = eval_u(g, data, x)
  value = eval_u(g,data(:,:,:,end),xinit);
  
  if value <= 0 %if initial state is in BRS/BRT
    % find optimal trajectory
    
    dubInt.x = xinit; %set initial state of the dubins car

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
      computeOptTraj(g, dataTraj, tau2, dubInt, TrajextraArgs);
  else
    error(['Initial state is not in the BRS/BRT! It have a value of ' num2str(value,2)])
  end
end
end