function computeVolume_test()
% computeVolume_test()
% Tests the computeVolume function
%
% Mo Chen, 2016-02-26

% Number of trials per dimension
N = 10;
disp(['Testing with ' num2str(N) ' trials per dimension'])

% Test up to dimension 4 and reporpt average error and computation time
for i = 1:4
  disp(['===== Testing ' num2str(i) ' dimension(s) ====='])
  
  errors = zeros(N, 1);
  tic
  for j = 1:N
    errors(j) = computeVolume_test_single(i);
  end
  toc
  
  disp(['Average error = ' num2str(mean(errors)*100) '%'])
end
end

function error_single = computeVolume_test_single(dims)
%% Create the grid
g.dim = dims;
g.N = 51*ones(g.dim, 1);

% Domain is anywhere from [-2.5, 1.5]^g.dim to [-1.5, 2.5]^g.dim
shift = -0.5 + rand(g.dim, 1);
g.min = -2*ones(g.dim, 1) + shift;
g.max = g.min + 4;
g.bdry = @addGhostExtrapolate;
g = processGrid(g);

%% Create a random sphere and compute its volume
% Radius is anywhere from 0 to 1
% Center is anywhere from -0.5*ones(g.dim, 1) to 0.5*ones(g.dim, 1)
radius = 0.5 + 0.5*rand;
center = -0.5+rand(g.dim, 1);
data = shapeSphere(g, center, radius);

approxV = computeVolume(g, data);

%% Compute error
trueV = pi^(g.dim/2) / gamma(g.dim/2 + 1) * radius^(g.dim);
error_single = abs(approxV - trueV) / trueV;


end