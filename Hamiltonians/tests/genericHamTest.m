function genericHamTest(whatTest)

if nargin<1
  whatTest = 'air3D';
end

if strcmp(whatTest, 'air3D')
  % Create grid
  N = 51;
  g = createGrid([-6 -10 0], [20 10 2*pi], N*ones(3,1), 3);  
  
  % Time stamps
  tMax = 2.6;
  dt = 0.2;
  tau = 0:dt:tMax;
  
  % Dynamical system parameters
  dynSys = Air3D([0, 0, 0], 1, 1, 5, 5); % Initial state is irrelevant here
  schemeData.grid = g;
  schemeData.dynSys = dynSys;
  
  % Target set and visualization
  data0 = shapeCylinder(g, 3, [0; 0; 0], 5);
  extraArgs.visualize = true;
  data = HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
  daspect([1 1 0.4])
end

%% Dubins Car
if strcmp(whatTest, 'DubinsCar')
  % Create grid
  N = 31;
  L = 10;
  g = createGrid([-L -L 0], [L L 2*pi], N*ones(3,1), 3);
  
  % Time stamps
  tMax = 1;
  dt = 0.01;
  tau = 0:dt:tMax;
  
  % Dynamical system parameters
  dCar = DubinsCar([0, 0, 0], 1, 5);
  schemeData.grid = g;
  schemeData.dynSys = dCar;
  
  % Target set and visualization
  data0 = shapeCylinder(g, 3, [0; 0; 0], 1);
  extraArgs.visualize = true;
  HJIPDE_solve(data0, tau, schemeData, 'zero', extraArgs);
end

%% MIE
if strcmp(whatTest, 'MIE')
  L = 3;
  %% Initialization
  N = 101;
  % MIE initial value functions
  gMIE = createGrid(-L, L, N);
  data0Upper = 0.5*gMIE.xs{1};
  data0Lower = gMIE.xs{1};
  
  % Implicit value function
  gTI = createGrid(-L, L, N);
  [gIm, data0u] = MIE2Implicit(gMIE, data0Upper, 'upper', gTI);
  [~, data0l] = MIE2Implicit(gMIE, data0Lower, 'lower', gTI);
  data0 = max(data0u, data0l);
  
  % Time
  tMax = 2;
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
  sDMIEj.grid = gMIE;
  sDMIEj.uModeU = 'max';
  sDMIEj.uModeL = 'min';
  sDMIEj.dynSys = dblInt;
  sDMIEj.MIEdims = 1;
  [datal, datau] = HJIPDE_MIEsolve(data0Lower, data0Upper, tau, sDMIEj, 'none');
  
  %% Visualize
  figure
  hIm = visSetIm(gIm, data(:,:,end));
  hold on
  
  hMIEil = visSetMIE(gMIE, dataLower(:,end));
  hMIEil.LineStyle = ':';
  hMIEil.LineWidth = 2;
  
  hMIEiu = visSetMIE(gMIE, dataUpper(:,end));
  hMIEiu.LineStyle = ':';
  hMIEiu.LineWidth = 2;
  
  hMIEl = visSetMIE(gMIE, datal(:,end));
  hMIEl.LineStyle = '--';
  hMIEl.LineWidth = 1.5;
  
  hMIEu = visSetMIE(gMIE, datau(:,end));
  hMIEu.LineStyle = '--';
  hMIEu.LineWidth = 1.5;
  
  legend([hIm, hMIEil, hMIEl], {'Implicit', 'Independent MIE', 'Joint MIE'})
  
  xlim([-L L])
  ylim([-L L])
  grid on
end
end