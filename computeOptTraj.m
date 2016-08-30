function [traj, traj_tau] = computeOptTraj(g, data, tau, dynSys, extraArgs)

if nargin < 5
  extraArgs = [];
end

% Default parameters
uMode = 'min';
visualize = false;
save_png = false;

if isfield(extraArgs, 'uMode')
  uMode = extraArgs.uMode;
end

% Visualization
if isfield(extraArgs, 'visualize') && extraArgs.visualize
  visualize = extraArgs.visualize;
  
  showDims = find(extraArgs.projDim);
  hideDims = ~extraArgs.projDim;
  
  figure
end

if isfield(extraArgs, 'save_png') && extraArgs.save_png
  save_png = extraArgs.save_png;
  folder = sprintf('%s_%f', mfilename, now);
  system(sprintf('mkdir %s', folder));
end

colons = repmat({':'}, 1, g.dim);

if any(diff(tau)) < 0
  error('Time stamps must be in ascending order!')
end

% Time parameters
small = 1e-4;
BRS_t = 1;
traj_t = 1;
tauLength = length(tau);
subSamples = 4;
dtSmall = (tau(2) - tau(1))/subSamples;

% Initialize trajectory
traj = nan(3, tauLength);
traj(:,1) = dynSys.x;

while BRS_t <= tauLength
  % Determine the earliest time that the current state is in the reachable set
  for tEarliest = tauLength:-1:BRS_t
    valueAtX = eval_u(g, data(colons{:}, tEarliest), dynSys.x);
    if valueAtX < small
      break
    end
  end
  
  % BRS at current time
  BRS_at_t = data(colons{:},tEarliest);
  
  % Visualize BRS corresponding to current trajectory point
  if visualize
    plot(traj(showDims(1), traj_t), traj(showDims(2), traj_t), 'k.')
    hold on
    [g2D, data2D] = proj(g, BRS_at_t, hideDims, traj(hideDims,traj_t));
    visSetIm(g2D, data2D);
    tStr = sprintf('t = %.3f; tEarliest = %.3f', tau(traj_t), tau(tEarliest));
    title(tStr)
    drawnow
    
    if save_png
      export_fig(sprintf('%s/%d', folder, traj_t), '-png')
    end
    hold off
  end
  
  if tEarliest == tauLength
    % Trajectory has entered the target
    break
  end
  
  % Update trajectory
  Deriv = computeGradients(g, BRS_at_t);
  for j = 1:subSamples
    deriv = eval_u(g, Deriv, dynSys.x);
    u = dynSys.optCtrl(tau(BRS_t), dynSys.x, deriv, uMode);
    dynSys.updateState(u, dtSmall, dynSys.x);
  end
  
  % Record new point on nominal trajectory
  traj_t = traj_t + 1;
  traj(:,traj_t) = dynSys.x;
  BRS_t = tEarliest + 1;
end

% Delete unused indices
traj(:,traj_t:end) = [];
traj_tau = tau(1:traj_t-1);
end