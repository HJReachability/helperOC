function [data, tau2] = Quad4DCAvoid_test()

%% Grid
grid_min = [-8; -8; -5; -3]; % Lower corner of computation domain
grid_max = [8; 8; 5; 3];    % Upper corner of computation domain
N = 21*ones(4,1);         % Number of grid points per dimension

g = createGrid(grid_min, grid_max, N);

%% target set
R = 3;
data0 = shapeCylinder(g, [2, 4], [0; 0; 0; 0], R);

%% time vector
t0 = 0;
tMax = 3;
dt = 0.1;
tau = t0:dt:tMax;

%% problem parameters
aMax = [6 2];
bMax = [6 2];

uMode = 'max';
dMode = 'min';
% do dStep2 here


%% Pack problem parameters
dCar = Quad4DCAvoid([0,0,0,0], aMax, bMax);

% Put grid and dynamic systems into schemeData
schemeData.grid = g;
schemeData.dynSys = dCar;
schemeData.accuracy = 'veryHigh'; %set accuracy
schemeData.uMode = uMode;
schemeData.dMode = dMode;

%% Compute value function
HJIextraArgs.visualize = true;
HJIextraArgs.fig_num = 1;
HJIextraArgs.deleteLastPlot = true;
HJIextraArgs.stopConverge = true;

[data, tau2] = HJIPDE_solve(data0, tau, schemeData, 'zero', HJIextraArgs);

deriv = computeGradients(g, data);

end
