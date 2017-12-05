function rotateData_test(which_test)
% rotateData_test()
%   Tests the rotateData function

if nargin < 1
  which_test = 'sphere_rect';
end

switch which_test
  case 'sphere_rect'
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
      view(3)
    end
    
  case 'cylinder'
    %% Create some dummy data
    g = createGrid([-10; -10; 0], [10; 10; 2*pi], [51; 51; 51], 3);
    dataLarge = shapeCylinder(g, 3, [-5 -5 -2], 3);
    plane = shapeHyperplane(g, [0;0;1], [0;0;pi]);
    dataLarge = shapeDifference(dataLarge, plane);
    dataSmall = shapeCylinder(g, 3, [-5 -5 -2], 1.5);
    data = shapeUnion(dataLarge, dataSmall);
    
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
      view(3)
    end
    
  otherwise
    error('Unknown test!')
end

end