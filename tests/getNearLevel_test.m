function getNearLevel_test(whatTest)

if nargin < 1
  whatTest = 'sphere';
end

%% Test using a sphere
if strcmp(whatTest, 'sphere')
  % Create a sphere
  g = createGrid(-ones(3,1), ones(3,1), [75; 51; 41]);
  R = 0.5;
  data = shapeSphere(g, zeros(3,1), R);
end

%% Test using a sphere
if strcmp(whatTest, 'cylinder')
  % Create a sphere
  g = createGrid(-ones(3,1), ones(3,1), [75; 51; 41]);
  R = 0.5;
  data = shapeCylinder(g, 3, zeros(3,1), R);
end

%% Test using example SPP data
if strcmp(whatTest, 'SPP')
  load('getNearLevel_testData')
end

%% Compute gradient
grad = extractCostates(g, data);

%% Compute and display nearLevel
nearLevel = getNearLevel(g, data, grad, 0, min(0.9*g.dx));

fprintf('  g.dx = [%f; %f; %f]\n  nearLevel = %f\n', ...
  g.dx(1), g.dx(2), g.dx(3), nearLevel);

%% Visualize the two levels
visSetIm(g, data);
h = visSetIm(g, data, 'b', nearLevel);
h.FaceAlpha = 0.5;

end