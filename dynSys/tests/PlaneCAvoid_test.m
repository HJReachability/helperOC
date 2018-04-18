function PlaneCAvoid_test(which_test, gN)
% PlaneCAvoid_test()
%     Tests the PlaneCAvoid class; requires the level set toolbox, which can be
%     found at https://www.cs.ubc.ca/~mitchell/ToolboxLS/

if nargin < 1
  which_test = 'other';
end

if nargin < 2
  gN = 41;
end

%% Grid
% Choose this to be just big enough to cover the reachable set
gMin = [-10; -15; 0];
gMax = [25; 15; 2*pi];
gN = gN*ones(3,1);
g = createGrid(gMin, gMax, gN);

%% Time
% Choose tMax to be large enough for the set to converge
tMax = 3;
dt = 0.1;
tau = 0:dt:tMax;

%% Vehicle parameters
% Maximum turn rate (rad/s)
wMaxA = 1;
if strcmp(which_test, 'straight')
  wMaxB = 0;
else
  wMaxB = 1;
end

% Speed range (m/s)
vRangeA = [5 5];
vRangeB = [5 5];

% Disturbance (see PlaneCAvoid class)
dMaxA = [0 0];
dMaxB = [0 0];

%% Initial conditions
targetR = 5; % collision radius
data0 = shapeCylinder(g, 3, [0;0;0], targetR);

%% Additional solver parameters
sD.grid = g;
sD.dynSys = PlaneCAvoid([0;0;0], wMaxA, vRangeA, wMaxB, vRangeB, dMaxA, dMaxB);
sD.uMode = 'max';

if strcmp(which_test, 'cooperative')
  sD.dMode = 'max';
else
  sD.dMode = 'min';
end

extraArgs.visualize = true;
extraArgs.deleteLastPlot = true;
extraArgs.keepLast = true;

%% Call solver and save
safety_set.data = HJIPDE_solve(data0, tau, sD, 'zero', extraArgs);
safety_set.g = g;
safety_set.deriv = computeGradients(g, safety_set.data);
save(sprintf('%s_%s.mat', mfilename, which_test), 'safety_set', '-v7.3')

end