function genericHamTest()

%% Initialization
N = 75;
% MIE initial value functions
gMIE = createGrid(-11, 11, N);
data0Upper = 0.25*gMIE.xs{1};
data0Lower = gMIE.xs{1};

% Implicit value function
gTI = createGrid(-11, 11, N);
[gIm, data0u] = MIE2Implicit(gMIE, data0Upper, 'upper', gTI);
[~, data0l] = MIE2Implicit(gMIE, data0Lower, 'lower', gTI);
data0 = max(data0u, data0l);

% Time
tMax = 1;
dt = 0.01;
tau = 0:dt:tMax;

% Dynamical system
dblInt = DoubleInt([0 0], [-1 1]);

%% Implicit solve
sDIm.grid = gIm;
sDIm.dynSys = dblInt;

extraArgs.visualize = false;
data = HJIPDE_solve(data0, tau, sDIm, 'none', extraArgs);

%% MIE solve individually
sDMIEilower = sDIm;
sDMIEilower.grid = gMIE;
sDMIEilower.MIEdims = 1;
dataLower = HJIPDE_solve(data0Lower, tau, sDMIEilower, 'none', extraArgs);

sDMIEiupper = sDMIEilower;
sDMIEiupper.uMode = 'max';
dataUpper = HJIPDE_solve(data0Upper, tau, sDMIEiupper, 'none', extraArgs);


%% MIE solve jointly


%% Visualize
visSetIm(gIm, data(:,:,end));
hold on

h = visSetMIE(gMIE, dataLower(:,end));
h.LineStyle = '--';
h.LineWidth = 1.5;

h = visSetMIE(gMIE, dataUpper(:,end));
h.LineStyle = '--';
h.LineWidth = 1.5;

xlim([-10 10])
ylim([-10 10])
grid on
end