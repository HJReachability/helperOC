function rotateData_test()
% rotateData_test()
%   Tests the rotateData function

%% Create some dummy data
g = createGrid([-10; -10; -pi], [10; 10; pi], [51; 51; 51], 3);
data = shapeRectangleByCorners(g, [-5 -5 -2], [0 0 0]);
data = min(data, shapeSphere(g, [0 0 0], 3));

%% Create a list of rotations
N = 9;
spC = ceil(sqrt(N));
spR = ceil(N/spC);
thetas = linspace(0, 2*pi, N);

%% visualize
figure
for i = 1:N
  dataRot = rotateData(g, data(:,:,:,end), thetas(i));
  
  subplot(spR, spC, i)
  visSetIm(g, dataRot);
  title(['\theta = ' num2str(thetas(i))])
  axis square
  axis(g.axis)
  view(2)
end


end