function recon2x2Dtest()
% Test the recon2x2D function using a 2D quadrotor collision example

addpath('..')
load('quad2Dcollision.mat')
gs = {gx; gy};
datas = {datax; datay};

% Reconstruct entire grid
recon2x2D_testFullGrid(gs, datas, tau)

% Test reconstruction time for a single state
recon2x2D_testSingleState(gs, datas, tau)

% Test reconstruction time for a slice
recon2x2D_testSingleSlice(gs, datas, tau)

end

function recon2x2D_testFullGrid(gs, datas, tau)
% Grid bounds (bigger bound than original grid to ensure that we get the
% entire grid)
xmin = [gs{1}.min; gs{2}.min] - 1;
xmax = [gs{1}.max; gs{2}.max] + 1;
x = [xmin xmax];

% Evalulation time (as big as possible)
t = inf;

% Reconstruct
tic
[~, TD_out, TTR_out] = recon2x2D(tau, gs, datas, x, t);
disp(['Time for full reconstruction: ' num2str(toc)])

% Visualize the results by taking slices at various relative velocities
v_slices = [0 0; 0 3; -2 -2; 2 3];
num_times = 6;
ttrs = linspace(0, max(tau), num_times);

num_plots = size(v_slices, 1);
spC = ceil(sqrt(num_plots));
spR = ceil(num_plots/spC);

f1 = figure;
f2 = figure;
for i = 1:num_plots
  % Plot time-dependent zero level sets
  figure(f1)
  subplot(spR, spC, i)
  [g2D, data2D] = proj2D(TD_out.g, TD_out.value, [0 1 0 1], v_slices(i,:));
  contour(g2D.xs{1}, g2D.xs{2}, data2D, [0 0], 'linewidth', 1);
  title(['v_r=[' num2str(v_slices(i,1)) ' ' num2str(v_slices(i,2)) ']'])
  
  % Plot time-to-reach functions
  figure(f2)
  subplot(spR, spC, i)
  [g2D, data2D] = proj2D(TTR_out.g, TTR_out.value, [0 1 0 1], v_slices(i,:));
  contour(g2D.xs{1}, g2D.xs{2}, data2D, ttrs, 'linewidth', 1);
  title(['v_r=[' num2str(v_slices(i,1)) ' ' num2str(v_slices(i,2)) ']'])
end
end

function recon2x2D_testSingleState(gs, datas, tau)
x = [2 0 2 0];
t = inf;
tic
TD_out_x = recon2x2D(tau, gs, datas, x, t);
disp(['Time for state reconstruction: ' num2str(toc)])
disp(['valuex=' num2str(TD_out_x.value)])
end

function recon2x2D_testSingleSlice(gs, datas, tau)
% Visualize the results by taking slices at various relative velocities
v_slices = [0 0; 0 3; -2 -2; 2 3];
num_times = 6;
ttrs = linspace(0, max(tau), num_times);

num_plots = size(v_slices, 1);
spC = ceil(sqrt(num_plots));
spR = ceil(num_plots/spC);

f1 = figure;
f2 = figure;
for i = 1:num_plots
  % Specify velocity but keep entire (x, y) range
  xmin = [gs{1}.min(1) - 1; v_slices(i,1); gs{2}.min(1) - 1; v_slices(i,2)];
  xmax = [gs{1}.max(1) + 1; v_slices(i,1); gs{2}.max(1) + 1; v_slices(i,2)];
  x = [xmin xmax];

  % Evalulation time (as big as possible)
  t = inf;

  tic
  [~, TD_out, TTR_out] = recon2x2D(tau, gs, datas, x, t);
  disp(['Time for slice reconstruction: ' num2str(toc)])
  
  % Plot time-dependent zero level sets
  figure(f1)
  subplot(spR, spC, i)
  contour(TD_out.g.xs{1}, TD_out.g.xs{2}, TD_out.value, [0 0], 'linewidth', 1);
  title(['v_r=[' num2str(v_slices(i,1)) ' ' num2str(v_slices(i,2)) ']'])
  
  % Plot time-to-reach functions
  figure(f2)
  subplot(spR, spC, i)
  contour(TTR_out.g.xs{1}, TTR_out.g.xs{2}, TTR_out.value, ttrs, 'linewidth',1); 
  title(['v_r=[' num2str(v_slices(i,1)) ' ' num2str(v_slices(i,2)) ']'])  
end
end