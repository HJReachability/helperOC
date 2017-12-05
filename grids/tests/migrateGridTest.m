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
h1 = visualizeLevelSet(g1, data1, 'contour', 0); hold on
h1.LineColor = 'r';

% Create the second grid.
Nx2 = 151;
g2.dim = 2;                            
g2.min = [ -3 ; -3]; 
g2.max = [ 3 ; 3];
g2.bdry = { @addGhostExtrapolate; @addGhostExtrapolate};
g2.N = [ Nx2; ceil(Nx2/(g2.max(1)-g2.min(1))*(g2.max(2)-g2.min(2)))];
g2 = processGrid(g2);

% Migrate data to new grid
data2 = migrateGrid(g1, data1, g2);

% Plot
h2 = visualizeLevelSet(g2, data2, 'contour', 0);
h2.LineStyle = ':';
h2.LineWidth = 1;

%%%%% SECOND TEST: Air3D %%%%%
load('air3D_gridMigration.mat')
data2 = migrateGrid(g1, data1, g2);
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

%%%%% THIRD TEST: 4D Dubins Car Reachable Set %%%%%
