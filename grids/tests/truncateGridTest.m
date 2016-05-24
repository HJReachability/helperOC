close all;
clear all;
addpath('..')

%%%%% FIRST TEST: 3D Rectangular box %%%%%
% Create the first grid.
Nx1 = 101;
g1.dim = 2; 
g1.min = [ -2 ; -2];
g1.max = [ 2 ; 2];
g1.bdry = { @addGhostExtrapolate; @addGhostExtrapolate };
g1.N = [ Nx1; ceil(Nx1/(g1.max(1)-g1.min(1))*(g1.max(2)-g1.min(2))) ];
g1 = processGrid(g1);

% Create data structure
data1 = shapeRectangleByCorners(g1, [-1, -1], [1, 1]);

% Plot
figure;
[~, h1] = contour(g1.xs{1}, g1.xs{2}, data1); hold on
h1.LineColor = 'r';

[gNew, dataNew] = truncateGrid(g1, data1, [0.5 0.5], [1.5 1.5]);
[~, h2] = contour(gNew.xs{1}, gNew.xs{2}, dataNew); hold on


%%%%% SECOND TEST: Air3D %%%%%
load('air3D_gridMigration.mat')
[g2, data2] = truncateGrid(g1, data1, [10 -5 2], [18 2 4]);
figure;
h1 = visualizeLevelSet(g1, data1, 'surface', 0); hold on
h1.FaceAlpha = 0.6;
axis(g1.axis);
camlight

h2 = visualizeLevelSet(g2, data2, 'surface', 0);
h2.FaceColor = [0 0 1];
h2.FaceAlpha = 0.6;
% axis(g2.axis);
camlight