function addCRadius_test()
% addCRadius_test()
%     tests addCRadius in 2 and 3 dimensions

dims = 2:3;
Ns = [101; 41];
numTrials = [9; 4];

for i = 1:length(dims)
  %% Create the computation grid.
  g = createGrid(-10*ones(dims(i),1), 10*ones(dims(i),1), ...
    Ns(i)*ones(dims(i),1));
  
  %% Run numTrials(i) random instances
  figure;
  spC = ceil(sqrt(numTrials(i)));
  spR = ceil(numTrials(i)/spC);
  for j = 1:numTrials(i)
    subplot(spR, spC, j)
    addCRadius_single(g)
    drawnow
  end
end
end

function addCRadius_single(g)
%% Define the intial set
% Sphere
sc = -1 + 2*rand(g.dim,1);
r = 0.5 + 3.5*rand;
data1 = shapeSphere(g, sc, r);

% Rectangle
rc = 1 + 2*rand(g.dim,1);
w = 0.5 + 3.5*rand;
data2 = shapeRectangleByCenter(g, rc, w);

% Union
data = min(data1, data2);

%% Plot intial set
visSetIm(g, data, 'b');
hold on

%% Add random radius and plot resulting set
extra_radius = 1 + 4*rand;
dataOut = addCRadius(g, data, extra_radius);

h = visSetIm(g, dataOut, 'r');
if g.dim == 3
  h.FaceAlpha = 0.5;
end

grid on
axis equal
title(['Extra radius: ' num2str(extra_radius)])
end