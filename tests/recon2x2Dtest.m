clear all;
close all;
addpath('..')

% Test the recon2x2D function using a 2D quadrotor collision example
load('quad2Dcollision.mat')

% Grid bounds (bigger bound than original grid to ensure that we get the
% entire grid)
xmin = [gx.min; gy.min] - 1;
xmax = [gx.max; gy.max] + 1;
x = [xmin xmax];

% Evalulation time (as big as possible)
t = inf;

% Reconstruct
tic
[~, TD_out, TTR_out] = recon2x2D(tau, ...
  {gx; gy}, {datax; datay}, x, t);
disp(['Time for full reconstruction: ' num2str(toc)])

% Visualize the results by taking slices at various relative velocities
v_slices = [0 0; 0 3; -2 -2; 2 3]';
num_times = 6;
ttrs = linspace(0, 5, num_times);
colors = lines(6);

num_plots = size(v_slices,2);
spC = ceil(sqrt(num_plots));
spR = ceil(num_plots/spC);

f1 = figure;
f2 = figure;
for i = 1:num_plots
  % Plot time-dependent zero level sets
  figure(f1)
  subplot(spR, spC, i)
  [g2D, data2D] = proj2D(TD_out.g, TD_out.value, [0 1 0 1], v_slices(:,i));
  contour(g2D.xs{1}, g2D.xs{2}, data2D, [0 0]); hold on
  title(['v_r=[' num2str(v_slices(1,i)) ' ' num2str(v_slices(2,i)) ']'])
  
  % Plot time-to-reach functions
  figure(f2)
  subplot(spR, spC, i)
  [g2D, data2D] = ...
    proj2D(TTR_out.g, TTR_out.value, [0 1 0 1], v_slices(:,i));
  contour(g2D.xs{1}, g2D.xs{2}, data2D);
  title(['v_r=[' num2str(v_slices(1,i)) ' ' num2str(v_slices(2,i)) ']'])
end

% Test reconstruction time for a single state (should be safe)
x = [2 0 2 0];
tic
TD_out_x = recon2x2D(tau, {gx; gy}, {datax; datay}, x, t);
disp(['Time for state reconstruction: ' num2str(toc)])
disp(['valuex=' num2str(TD_out_x.value)])