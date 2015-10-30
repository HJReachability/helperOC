function rotate2DGrid_test()
% Tests plotting rotated versions of the reachable set

% Load 3D data and plot a random slice
load('air3D_simulation.mat')
rel_heading = 2*pi*rand;
[g2D, data2D] = proj2D(g, [0 0 1], g.N(3), data, rel_heading);

figure;
contour(g2D.xs{1}, g2D.xs{2}, data2D, [0 0], 'k')
hold on

% Rotate the plot by N different random angles
N = 5;
thetas = 2*pi*rand(N,1);
colors = lines(N);
hs = [];
for i = 1:N
  gRot = rotate2DGrid(g2D, thetas(i));

  [~, h] = contour(gRot.xs{1}, gRot.xs{2}, data2D, [0 0], ...
    'color', colors(i,:));
  hs = [hs h];
end
axis equal
legend(hs, cellstr(num2str(thetas*180/pi)))
end