function shiftData_test()
% shiftData_test()
%   tests the shiftData function

%% Create some dummy data
g = createGrid([-10; -10; -pi], [10; 10; pi], [51; 51; 51], 3);
data = shapeRectangleByCorners(g, [-5 -5 -2], [0 0 0]);
data = min(data, shapeSphere(g, [0 0 0], 3));

%% Randomize shifting vectors
N = 9;
spC = ceil(sqrt(N));
spR = ceil(N/spC);
shifts = -5 + 10*rand(N, 2);

%% Shift and visualize
figure
for i = 1:N
  dataShift = shiftData(g, data(:,:,:,end), shifts(i,:));
  
  subplot(spR, spC, i)
  visSetIm(g, dataShift);
  title(['shift = [' num2str(shifts(i, 1)) ' ' num2str(shifts(i, 2)) ']'])
  axis square
  axis(g.axis)
  view(2)
end
end