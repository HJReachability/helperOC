close all
clear all

%% This example is designed for playing around with 8 types of reachability problem:
% which is determined by selecting the following options
% 'backward' vs 'forward'
% 'set' vs 'tube'
% and 'minimal' vs 'maximal' reachability.
% Note that the 'min'/'max' of the reachability problem does not necessarily correspond to uMode.
% In this example, setting uMode to 'max' corresponds to 'minimal reachability' in the backward problem.
% On the other hand, in the forward problem, 'max' uMode corresponds to the maximal reachability.
% For more details, please refer to Mitchell, "Comparing Forward and Backward Reachability
% as Tools for Safety Analysis".

% Finally, you can also add an obstacle to the problem, in this case, you will be solving a reach-avoid problem.
% The method for this is developed in Fisac et al., "Reach-Avoid Problems with Time-Varying Dynamics,
% Targets and Constraints". Set the below toggle to true to include the obstacle in the problem.
set_obstacle = false;

%% Set up grid.
grid_min = [-5; -5]; % Lower corner of computation domain
grid_max = [5; 5];    % Upper corner of computation domain
N = [101; 101];         % Number of grid points per dimension
g = createGrid(grid_min, grid_max, N);
%% Define target function.
data0 = shapeRectangleByCorners(g, [-1, -1], [1, 1]);

if set_obstacle
    obstacle_function = shapeCylinder(g, [], [-1; -2;], 1);
    HJIextraArgs.obstacleFunction = obstacle_function;
end
% set target function.
HJIextraArgs.targetFunction = data0;
% plot target function.
figure(1);
subplot(1, 2, 1);
visFuncIm(g, data0, 'r', 0.5);
hold on;
grid on;
axis equal;
subplot(1, 2, 2);
visSetIm(g, data0, 'r', 0); 
hold on;
axis equal;
grid on;
xticks(-5:1:5);

%% time vector
t0 = 0;
tMax = 3;
dt = 0.02;
tau = t0:dt:tMax;

% 'min' or 'max'?
uMode = 'min';
schemeData.uMode = uMode;
% backward or forward?
schemeData.tMode = 'backward';
%Define dynamical system.
boat = SimpleFloatingBoat();
% Put grid and dynamic systems into schemeData
schemeData.grid = g;
schemeData.dynSys = boat;
% set accuracy
schemeData.accuracy = 'high'; 

%% Compute value function
HJIextraArgs.visualize.valueSet = 1;
HJIextraArgs.visualize.initialValueSet = 1;
HJIextraArgs.visualize.figNum = 2; %set figure number
HJIextraArgs.visualize.deleteLastPlot = true; %delete previous plot as you update

% For set computation, use 'none'. For tube computation, use 'minVWithL'
compMethod = 'minVWithL';
[data, tau2, ~] = ...
  HJIPDE_solve(data0, tau, schemeData, compMethod, HJIextraArgs);

% Plot the final time target function.
figure(1);
subplot(1, 2, 1);
hold on;
visFuncIm(g, squeeze(data(:, :, end)), 'b', 0.5);
subplot(1, 2, 2);
hold on;
visSetIm(g, squeeze(data(:, :, end)), 'b', 0); 

%% Compute optimal trajectory from some initial state
% set the initial state
xinit = [-2.0; -3];
boat.x = xinit; %set initial state of the dubins car
% set if control wants to min or max
TrajextraArgs.uMode = uMode; 
% flip data time points so we start from the beginning of time
dataTraj = flip(data,3);
[traj, traj_tau] = ...
  computeOptTraj(g, dataTraj, tau2, boat, TrajextraArgs);

% Showing trajectory.
figure(1);
subplot(1, 2, 2);
plot(traj(1, :), traj(2, :));
