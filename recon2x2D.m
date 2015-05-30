function [valuex, gradx, g, value, grad, ind] = recon2x2D(tau, g1, data1, g2, data2, x, t)
% function [valuex, gradx, g, value, grad] = recon2x2D(tau, g1, data1, g2,
%                                                                 data2, x)
%
% Inputs:  tau           - time stamps for data1, data2
%          g1, g2        - grids for corresponding to data1, data2
%          data1, data2  - 2D value functions
%          x             - location to evaluate 4D value function
%                          could also be a grid structure, in which case
%                          the 4D value function will be evaluated on this
%                          grid
%          t             - time to evaluate 4D value function (defaults to
%                          minimum time at which V(t,x) <= 0
%
% Outputs: valuex, gradx - value and gradient at state x
%          g             - 4D grid structure
%          value, grad   - values and gradients around state x

if nargin<7, t = tau(end); end

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

[gs2D1, data1s1] = ...
    truncateGrid(g1, data1(:,:,1), xmin(1:g1.dim),     xmax(1:g1.dim)    );

if any(gs2D1.N<3)
    valuex = max(data1(:));
    gradx = zeros(4,1);
    g = [];
    value = [];
    grad = [];
    return
end

[gs2D2, data2s1] = ...
    truncateGrid(g2, data2(:,:,1), xmin(g1.dim+1:end), xmax(g1.dim+1:end));

if any(gs2D2.N<3)
    valuex = max(data2(:));
    gradx = zeros(4,1);
    g = [];
    value = [];
    grad = [];
    return
end


data1s = zeros([gs2D1.N' length(tau)]);
data2s = zeros([gs2D2.N' length(tau)]);
data1s(:,:,1) = data1s1;
data2s(:,:,1) = data2s1;

gs4D.dim = 4;
xs1 = gs2D1.xs;
xs2 = gs2D2.xs;
gs4D.min = [xs1{1}(1,1);   xs1{2}(1,1); ...
            xs2{1}(1,1);   xs2{2}(1,1)   ];
gs4D.max = [xs1{1}(end,1); xs1{2}(1,end); ...
            xs2{1}(end,1); xs2{2}(1,end) ];
gs4D.bdry = @addGhostExtrapolate;
gs4D.N = [gs2D1.N; gs2D2.N];
gs4D = processGrid(gs4D);

% Copy large 2D look-up table into our small grid
for i = 1:length(tau)
    [~, data1s(:,:,i)] = ...
        truncateGrid(g1, data1(:,:,i), xmin(1:g1.dim),     xmax(1:g1.dim)    );
    [~, data2s(:,:,i)] = ...
        truncateGrid(g2, data2(:,:,i), xmin(g1.dim+1:end), xmax(g1.dim+1:end));
end

% Extend x slice across y
data1_4D = repmat(data1s(:,:,1), 1, 1, gs4D.N(3), gs4D.N(4));

% Extend y slice across x
data2_4D = zeros(size(data1_4D));
data2_4D(1,1,:,:) = data2s(:,:,1);
data2_4D = repmat(data2_4D(1,1,:,:), gs4D.N(1), gs4D.N(2), 1, 1);

% Create initial conditions
data4Ds = max(data1_4D, data2_4D);

for i = 2:length(tau)
    data4Ds_last = data4Ds;
    
    % Extend 2D value functions across the other two dimensions
    data1_4D = repmat(data1s(:,:,i), 1, 1, gs4D.N(3), gs4D.N(4));
    data2_4D = zeros(size(data1_4D));
    data2_4D(1,1,:,:) = data2s(:,:,i);
    data2_4D = repmat(data2_4D(1,1,:,:), gs4D.N(1), gs4D.N(2), 1, 1);
    
    % Freeze the value function
    data4Ds = max(data1_4D, data2_4D);
    data4Ds = min(data4Ds,data4Ds_last);
    
    if nargin<7 && size(x,2) == 1
        if eval_u(gs4D, data4Ds, x') <= 0, break; end
    end
end
% disp(['Final time is ' num2str(tau(i))])

if size(x,2)>1, valuex = [];
else            valuex = eval_u(gs4D, data4Ds, x');
end

value = data4Ds;
g = gs4D;
grad = extractCostates(g, value);

if size(x,2)>1, gradx = [];
else            gradx = calculateCostate(g, grad, x');
end

end