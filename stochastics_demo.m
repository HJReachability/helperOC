function helperOC_tutorial()
% This demo simulates a double integrator system (like is often used as a
% simple model of a quadrotor) with additive gaussian noise in the
% acceleration term:
%
%    \dot{x} = v
%    \dot{v} = u + w
%
%        where: w is distributed Normal(0,stDev^2)
%               u is bound in [-uMax, uMax]
%
% Try modifying the size of the white noise's variance (S) or the control
% bounds to play with the effect of the additive random noise.
%    To do this, modify the uMax or stDev quantities and re-run the script

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

%% change the Value function from signed distance to probability of being
% contained in the safe set for all time
data0 = 0.5 * (1 + sign(data0));
HJIextraArgs.RS_level = 0.5; % visualize the 50%-probability safe set

%% time vector
t0 = 0;
tMax = 3;
dt = 0.05;
tau = t0:dt:tMax;

%% problem parameters

% input bounds
uMax = 1;
stDev = 3 % try stDev = 3
HJIextraArgs.addGaussianNoiseStandardDeviation = [0;stDev]
%    [stDev;0]; % Noise on first state
%    [stDev,0;0,stDev]; % Independent noise on both states
%    [stDev;1]; % Coupled noise on both states
%    {(g.xs{1}+g.xs{2})/2;zeros(size(g.xs{1}))}; % State-dependent noise

% control trying to min or max value function?
uMode = 'max';

%% Pack problem parameters

% Define dynamic system
dubInt = DoubleInt([0,0],[-uMax,uMax])

% Put grid and dynamic systems into schemeData
schemeData.grid = g;
schemeData.dynSys = dubInt;
schemeData.accuracy = 'high'; %set accuracy
schemeData.uMode = uMode;


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