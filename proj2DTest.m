% Script for testing proj2D.m
%
% Loads spheres in 2, 3, 4, 6 dimensions, and then takes random slices in
% random dimensions, including invalid dimension specifications
%
% Output should be concentric circles in a total of 3 different colors
close all;
clear

load('spheres2346D')

N = 30;

figure;
colors = hsv(length(dims));

for i = 1:length(dims)
  % Randomly create a list of point and a list of dimensions to project
  x = rand(N,g{i}.dim-2);
  proj_dim = randi(2, N, g{i}.dim) - 1;
  disp(['===== Projecting to ' num2str(dims(i)) 'D ====='])
  
  for j = 1:N
    % Try performing projection, and then plot the results; if this fails,
    % output error message. 
    try
      [g2D, data2D] = proj2D(g{i}, proj_dim(j,:), g{i}.N(~proj_dim(j,:)), ...
        sphere{i}, x(j,:));
      disp('Plotting...')
      contour(g2D.xs{1}, g2D.xs{2}, data2D, [0 0], 'color', colors(i,:))
      hold on
    catch err
      disp(err.message)
      continue
    end
  end
end

clear