function rotate2D_test()
addpath('..')

%% Create a random vector (50% chance to be column)
if rand < 0.5
  disp('Testing with column vector')
  v = rand(2,1);
else
  disp('Testing with row vector')
  v = rand(1,2);
end

%% Plot
figure;
quiver(0, 0, v(1), v(2), 'k', 'linewidth', 2);
hold on

%% Generate random angles
N = 10;
thetas = -2*pi + 4*pi*rand(N,1);

%% Rotate and plot
colors = jet(N);
qs = [];
for i = 1:N
  vOut = rotate2D(v, thetas(i));
  qs = [qs quiver(0, 0, vOut(1), vOut(2), 'color', colors(i,:))];
end

legend(qs, cellstr(num2str(thetas*180/pi)))
end