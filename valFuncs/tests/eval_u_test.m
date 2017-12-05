function eval_u_test()
% Script to test eval_u.m
%
% Test 1:
% Loads spheres in 2, 3, 4, 6 dimensions, evaluates the implicit surface
% functions, and compares the evaluations with analytic values
%
% Test 2:
% Constructs some periodic implicit surface functions, evaluates them at the
% wrap-around point, and compares evaluations with analytic values
%
% Errors should be very small
addpath('..')

%% Test 1: Basic test using spheres
% eval_u_test1()

%% Test 2: Periodic grids
eval_u_test2()

%% Test 3: Multiple value functions
% eval_u_test3()
end

function eval_u_test1()
disp('Test 1: Spheres')
load('spheres2346D', 'g', 'sphere', 'dims')

N = 1000;

for i = 1:length(dims)
  % Randomly create a list of points
  x = rand(N, dims(i));
  
  % Analytic distance to sphere
  true_values = zeros(N,1);
  
  for j = 1:dims(i)
    true_values = true_values + x(:,j).^2;
  end
  
  true_values = sqrt(true_values) - 1;
  
  % Evaluated distance to sphere
  eval_values = eval_u(g{i}, sphere{i}, x);
  
  % Error
  error = sqrt(sum((true_values - eval_values).^2))/N;
  disp([num2str(dims(i)) 'D error = ' num2str(error)])
end
end

function eval_u_test2()
disp('Test 2: Periodic dimensions')

Ns = [201 101 71 35 11];
dims = [1 2 3 4 6];
for i = 1:length(dims)
  if exist('g', 'var')
    clear g;
  end
  
  %% Create the grid
  g.dim = dims(i);
  g.N = Ns(i)*ones(dims(i), 1);
  g.min = zeros(dims(i), 1);
  g.max = ones(dims(i), 1);
  g.bdry = cell(dims(i), 1);
  
  % Randomize which dimensions are periodic
  for j = 1:dims(i)
    if rand < 0.8
      g.bdry{j} = @addGhostPeriodic;
      g.max(j) = (g.max(j)-g.min(j)) * (1 - 1/g.N(j));
    else
      g.bdry{j} = @addGhostExtrapolate;
    end
  end
  
  g = processGrid(g);
  
  %% Value function
  if i > 1
    V = ones(g.N');
  else
    V = ones(g.N, 1);
  end
  
  shifts = rand(dims(i), 1);
  for j = 1:dims(i)
    if isequal(g.bdry{j}, @addGhostPeriodic)
      V = V .* sin(g.xs{j} - shifts(j));
    else
      V = V .* (g.xs{j} - shifts(j));
    end
  end
  
  %% Evaluate
  N = 1000;
  
  % Interpolate very close to boundary upper limit
  x = 0.99 + 0.01*rand(N, dims(i));
  
  % Interpolated values
  eval_values = eval_u(g, V, x);
  
  % True values
  true_values = 1;
  for j = 1:dims(i)
    if isequal(g.bdry{j}, @addGhostPeriodic)
      true_values = true_values .* sin(x(j) - shifts(j));
    else
      true_values = true_values .* (x(j) - shifts(j));
    end
  end
  
  % Error
  error = sqrt(sum((true_values - eval_values).^2))/N;
  disp([num2str(dims(i)) 'D error = ' num2str(error)])
end

end

function eval_u_test3()
disp('Test 3: Multiple datas')
load('spheres2346D')

N = 100;

for i = 1:length(dims)
  % Randomly create a list of points
  x = rand(N, dims(i));
  
  eval_values = zeros(size(x));
  for k = 1:N
  % Evaluated distance to sphere
    eval_values(k,:) = eval_u(g{i}, P{i}, x(k,:))';
  end
  
  % Error
  error = sqrt(sum((x(:) - eval_values(:)).^2))/N;
  disp([num2str(dims(i)) 'D error = ' num2str(error)])
end
end