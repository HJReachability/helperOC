function jointCtrl_MIE_test()

%% Parameters
N = 201;
dblInt = DoubleInt([0 0], [-1 1]);
MIEdims = 1;

%% MIE grid and initial conditions
gMIE = createGrid(-10, 10, N);
data0Upper = 0.5*gMIE.xs{1};
data0Lower = gMIE.xs{1};

%% TI and implicit grid and initial conditions
gTI = createGrid(-10, 10, N);
[gIm, data0Imu] = MIE2Implicit(gMIE, data0Upper, 'upper', gTI);
[~, data0Iml] = MIE2Implicit(gMIE, data0Lower, 'lower', gTI);
data0 = max(data0Imu, data0Iml);

%% Controls on MIE boundary according to implicit function
P0 = extractCostates(gIm, data0);
p2l = eval_u(gIm, P0{2}, [data0Lower gMIE.xs{1}]);
p2u = eval_u(gIm, P0{2}, [data0Upper gMIE.xs{1}]);

ul_fromIm = dblInt.optCtrl(0, gMIE.xs, {p2l}, 'min', MIEdims);
uu_fromIm = dblInt.optCtrl(0, gMIE.xs, {p2u}, 'min', MIEdims);

%% Controls on MIE boundary according to dblInt_JC_MIE
schemeData.grid = gMIE;
schemeData.dynSys = dblInt;
schemeData.uModeU = 'max';
schemeData.uModeL = 'min';
schemeData.MIEdims = MIEdims;
[ul, uu, cInds] = jointCtrl_MIE(0, data0Lower, data0Upper, schemeData);

%% Visuaslize
figure
subplot(2, 1, 1)
plot(gMIE.xs{1}, ul_fromIm, 'r.-')
hold on
plot(gMIE.xs{1}, ul, 'b:', 'linewidth', 2)
plot(gMIE.xs{1}(cInds), ul(cInds), 'bx')
title('Lower')

subplot(2, 1, 2)
plot(gMIE.xs{1}, uu_fromIm, 'r-')
hold on
plot(gMIE.xs{1}, uu, 'b:', 'linewidth', 2)
plot(gMIE.xs{1}(cInds), uu(cInds), 'bx')
title('Upper')
end