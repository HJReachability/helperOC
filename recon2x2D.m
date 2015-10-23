function [TD_out_x, TD_out, TTR_out] = recon2x2D(tau, grids, datas, x, t)
% function [TD_out_x, TD_out, TTR_out] = recon2x2D(tau, grids, datas, x, t)
%
% Inputs:  tau   - time stamps for datas
%          grids - grids{i} is the grid corresponding to datas{i}
%          datas - 2D value functions
%          x     - If a vector, it's the state at which 4D value function
%                  is reconstructed.
%                  If two vectors, it specifies the bounds on the 4D grid
%                  within which the 4D value function is reconstructed
%          t     - time to evaluate 4D value function 
%                  (defaults to minimum time at which V(t,x) <= 0)
%
% Outputs: TD_out_x - value and gradient at state x
%          TD_out   - grid, value, and gradient around state x or within
%                     the bounds specified by x
%          TTR_out  - grid, value, and gradient for the time to reach
%                     function around the state x or within the bounds
%                     specified by x
%
% Created by Mo Chen
% Modified, Kene Akametalu
% Modified, Mo Chen, 2015-08-25

% Check input grid and data format
if length(grids) ~= 2 || length(datas) ~= 2
  error('grids and datas must be cell structures of length 2!')
end

% Find smallest time in time vector that is bigger than the specified time.
% By default, this is just the largest time from the time vector because we
% want to go through the entire set of times
if nargin<5
  t = tau(end);
end
ind = min(length(tau), find(tau<=t, 1, 'last') + 1);
tau = tau(1:ind);

% Make sure the input state is always a column vector or two
if size(x,2) > size(x,1)
  x = x';
end

% Reconstruction is done inside grid bounds specified by xmin and xmax
if size(x,2) == 1
  widthx = 1.6*grids{1}.dx;
  widthy = 1.6*grids{2}.dx;
  xmin = [x(1:grids{1}.dim) - widthx; x(grids{1}.dim+1:end) - widthy];
  xmax = [x(1:grids{1}.dim) + widthx; x(grids{1}.dim+1:end) + widthy];
elseif size(x,2) == 2
  xmin = x(:,1);
  xmax = x(:,2);
else
  error('Input state x must be a column vector or two!')
end

% Truncate grids and check to see if the state x is outside of either grid
gs2D = cell(size(grids));
datas1 = cell(size(datas));
for i = 1:length(grids)
  % Truncate grid according to specified limits
  [gs2D{i}, datas1{i}] = truncateGrid(grids{i}, datas{i}(:,:,1), ...
                               xmin(2*i-1:2*i), xmax(2*i-1:2*i));

  % If x is too close to the edge of the grid, the value is assumed to be
  % the maximum value over the entire grid.
  if any(gs2D{i}.N<3)
    TD_out_x.value = max(datas{i}(:));
    TD_out_x.grad = [];
    TD_out = [];
    TTR_out = [];
    return
  end
end

% Initialize value function within small grid bounds
data1s = zeros([gs2D{1}.N' length(tau)]);
data2s = zeros([gs2D{2}.N' length(tau)]);
data1s(:,:,1) = datas1{1};
data2s(:,:,1) = datas1{2};

% Construct 4D grid based on parameters of the 2D grids and specified grid
% bounds
gs4D.dim = 4;
xs1 = gs2D{1}.xs;
xs2 = gs2D{2}.xs;
gs4D.min = [xs1{1}(1,1); xs1{2}(1,1); xs2{1}(1,1); xs2{2}(1,1)];
gs4D.max = [xs1{1}(end,1); xs1{2}(1,end); xs2{1}(end,1); xs2{2}(1,end)];
gs4D.bdry = @addGhostExtrapolate;
gs4D.N = [gs2D{1}.N; gs2D{2}.N];
gs4D = processGrid(gs4D);

% Copy large 2D look-up table into our small grid
for i = 1:length(tau)
  [~, data1s(:,:,i)] = truncateGrid(grids{1}, datas{1}(:,:,i), ...
                               xmin(1:2), xmax(1:2));
  [~, data2s(:,:,i)] = truncateGrid(grids{2}, datas{2}(:,:,i), ...
                       xmin(3:4), xmax(3:4));
end

% Extend x slice across y
data1_4D = repmat(data1s(:,:,1), 1, 1, gs4D.N(3), gs4D.N(4));

% Extend y slice across x
data2_4D = zeros(size(data1_4D));
data2_4D(1,1,:,:) = data2s(:,:,1);
data2_4D = repmat(data2_4D(1,1,:,:), gs4D.N(1), gs4D.N(2), 1, 1);

% Create initial conditions
data4Ds = max(data1_4D, data2_4D);

% Initialize time-to-reach value function
if nargout>2
  TTR_out.value = 1e5 * ones(size(data4Ds));
  TTR_out.value(data4Ds<=0) = 0;
end

for i = 2:length(tau)
  % Save value function at the last time step
  data4Ds_last = data4Ds;
  
  % Extend 2D value functions across the other two dimensions
  data1_4D = repmat(data1s(:,:,i), 1, 1, gs4D.N(3), gs4D.N(4));
  data2_4D = zeros(size(data1_4D));
  data2_4D(1,1,:,:) = data2s(:,:,i);
  data2_4D = repmat(data2_4D(1,1,:,:), gs4D.N(1), gs4D.N(2), 1, 1);
  
  % Freeze the value function
  data4Ds = max(data1_4D, data2_4D);
  data4Ds = min(data4Ds, data4Ds_last);
  
  % If a single state vector is specified, then stop reconstruction
  % whenever the value becomes negative
  if nargin<5 && size(x,2) == 1
    if eval_u(gs4D, data4Ds, x') <= 0
      break;
    end
  end
  
  % Update time-to-reach value function
  if nargout>2
    TTR_out.value((data4Ds<0) & (data4Ds_last>0)) = tau(i);
  end
end

% If input state is a single vector, return the value function at that
% vector
if size(x,2)==1
  TD_out_x.value = eval_u(gs4D, data4Ds, x');
else
  TD_out_x.value = [];
end

% Output values on grid that's within the specified bounds
TD_out.value = data4Ds;
TD_out.g = gs4D;
TD_out.grad = extractCostates(gs4D, data4Ds);

% If input state is a single vector, return the gradient at that vector
if size(x,2)==1
  TD_out_x.grad = calculateCostate(gs4D, TD_out.grad, x');
else
  TD_out_x.grad = [];
end

% Output time-to-reach value gradients
if nargout>2
  TTR_out.g = gs4D;
  TTR_out.grad = extractCostates(gs4D, TTR_out.value);
end

end