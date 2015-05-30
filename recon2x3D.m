function [valuex, gradx, g, value, grad, ind] = recon2x3D(tau, g1, data1, g2, data2, x, t)
% function [valuex, gradx, g, value, grad] = recon2x2D(tau, g1, data1, g2,
%                                                                 data2, x)
% Inputs:  tau           - time stamps for data1, data2
%          g1, g2        - grids for corresponding to data1, data2
%          data1, data2  - 2D value functions
%          x             - location to evaluate 4D value function, OR
%                          g1.dim + g2.dim by 2 array specifying the
%                          minimum and maximum bounds of area of interest
%          t             - time to evaluate 4D value function (defaults to
%                          minimum time at which V(t,x) <= 0
%          ind           - index of time variable
%
% Outputs: valuex, gradx - value and gradient at state x
%          g             - 4D grid structure
%          value, grad   - values and gradients around state x

if nargin < 7, t = tau(end); end

ind = min(length(tau), find(tau<=t,1,'last')+1);
tau = tau(1:ind);

if size(x,2) > size(x,1), x = x'; end

if size(x,2) > 1
    xmin = x(:, 1);
    xmax = x(:, 2);
else
    widthx = 1.6*g1.dx;
    widthy = 1.6*g2.dx;
    xmin = [x(1:g1.dim) - widthx; x(g1.dim+1:end) - widthy];
    xmax = [x(1:g1.dim) + widthx; x(g1.dim+1:end) + widthy];
end

% keyboard
% Copy large 3D look-up table into our small grid
[gs3D1, data1s1] = ...
    truncateGrid(g1, data1(:,:,:,1), xmin(1:g1.dim),     xmax(1:g1.dim)    );

if any(gs3D1.N<3)
    valuex = max(data1(:));
    gradx = zeros(6,1);
    g = [];
    value = [];
    grad = [];
    return
end

[gs3D2, data2s1] = ...
    truncateGrid(g2, data2(:,:,:,1), xmin(g1.dim+1:end), xmax(g1.dim+1:end));

if any(gs3D2.N<3)
    valuex = max(data2(:));
    gradx = zeros(6,1);
    g = [];
    value = [];
    grad = [];
    return
end

data1s = zeros([gs3D1.N' length(tau)]);
data2s = zeros([gs3D2.N' length(tau)]);
data1s(:,:,:,1) = data1s1;
data2s(:,:,:,1) = data2s1;

gs6D.dim = 6;
xs1 = gs3D1.xs;
xs2 = gs3D2.xs;
gs6D.min = [xs1{1}(1,1,1);   xs1{2}(1,1,1);   xs1{3}(1,1,1); ...
            xs2{1}(1,1,1);   xs2{2}(1,1,1);   xs2{3}(1,1,1)];
gs6D.max = [xs1{1}(end,1,1); xs1{2}(1,end,1); xs1{3}(1,1,end); ...
            xs2{1}(end,1,1); xs2{2}(1,end,1); xs2{3}(1,1,end)];
gs6D.bdry = @addGhostExtrapolate;
gs6D.N = [gs3D1.N; gs3D2.N];
gs6D = processGrid(gs6D);
% keyboard
for i = 2:length(tau)
    [~, data1s(:,:,:,i)] = ...
        truncateGrid(g1, data1(:,:,:,i), xmin(1:g1.dim),     xmax(1:g1.dim)    );
    [~, data2s(:,:,:,i)] = ...
        truncateGrid(g2, data2(:,:,:,i), xmin(g1.dim+1:end), xmax(g1.dim+1:end));
end

% Extend x slice across y
data1_6D = repmat(data1s(:,:,:,1), 1, 1, 1, gs6D.N(4), gs6D.N(5), gs6D.N(6));

% Extend y slice across x
data2_6D = zeros(size(data1_6D));
data2_6D(1,1,1,:,:,:) = data2s(:,:,:,1);
data2_6D = repmat(data2_6D(1,1,1,:,:,:), gs6D.N(1), gs6D.N(2), gs6D.N(3), 1, 1, 1);

% Create initial conditions
data6Ds = max(data1_6D, data2_6D);

for i = 2:length(tau)
    data6Ds_last = data6Ds;
    
    % Extend 2D value functions across the other two dimensions
    data1_6D = repmat(data1s(:,:,:,i), 1, 1, 1, gs6D.N(4), gs6D.N(5), gs6D.N(6));
    data2_6D = zeros(size(data1_6D));
    data2_6D(1,1,1,:,:,:) = data2s(:,:,:,i);
    data2_6D = repmat(data2_6D(1,1,1,:,:,:), gs6D.N(1), gs6D.N(2), gs6D.N(3), 1, 1, 1);
    
    % Freeze the value function
    data6Ds = max(data1_6D, data2_6D);
    data6Ds = min(data6Ds,data6Ds_last);
    
    if nargin<7 && size(x,2) == 1
        if eval_u(gs6D, data6Ds, x') <= 0, break; end
    end    
end
% disp(['Final time is ' num2str(tau(end))])

if size(x,2)>1, valuex = [];
else            valuex = eval_u(gs6D, data6Ds, x');
end

value = data6Ds;
g = gs6D;
grad = extractCostates(g, value);

if size(x,2)>1, gradx = [];
else            gradx = calculateCostate(g, grad, x');
end


end