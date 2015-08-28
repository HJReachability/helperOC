% Script to test eval_u.m
%
% Loads spheres in 2, 3, 4, 6 dimensions, evaluates the implicit surface
% functions, and compares the evaluations with analytic values
%
% Errors should be very small
clear

load('spheres2346D')

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

clear