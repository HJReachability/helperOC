function [valuex, gradx, g, value, grad] = recon2x3Dold(tau, g1, data1, g2, data2, x, t)
% function [valuex, gradx, g, value, grad] = recon2x2D(tau, g1, data1, g2,
%                                                                 data2, x)
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

if nargin < 7, t = tau(end); end

ind = min(length(tau), find(tau<=t,1,'last')+1);
tau = tau(1:ind);

if iscell(x)
    gs3D1 = x{1};
    gs3D2 = x{2};
else
    widthx = 0.5*g1.dx;
    widthy = 0.5*g2.dx;
    Nx = 3;
    Ny = 3;

    % Small version 2D grid in first decoupled component
    gs3D1.dim = 3;                              % Number of dimensions
    gs3D1.min = x(1:3)' - widthx;     % Bounds on computational domain
    gs3D1.max = x(1:3)' + widthx;
    gs3D1.bdry = @addGhostExtrapolate;
    gs3D1.N = Nx;
    gs3D1 = processGrid(gs3D1);

    gs3D2.dim = 3;                              % Number of dimensions
    gs3D2.min = x(4:6)' - widthy;     % Bounds on computational domain
    gs3D2.max = x(4:6)' + widthy;
    gs3D2.bdry = @addGhostExtrapolate;
    gs3D2.N = Ny;
    gs3D2 = processGrid(gs3D2);

end

gs6D.dim = 6;
gs6D.min = [gs3D1.min; gs3D2.min];
gs6D.max = [gs3D1.max; gs3D2.max];
gs6D.bdry = @addGhostExtrapolate;
gs6D.N = [gs3D1.N; gs3D2.N];
gs6D = processGrid(gs6D);

% % Create grid with time as a dimension
% g4D1.dim = 4;                              % Number of dimensions
% g4D1.min = [g1.min; tau(1)];     % Bounds on computational domain
% g4D1.max = [g1.max; tau(end)];
% g4D1.bdry = @addGhostExtrapolate;
% g4D1.N = [g1.N; length(tau)];
% g4D1 = processGrid(g4D1);
% 
% % Create grid with time as a dimension
% g4D2.dim = 4;                              % Number of dimensions
% g4D2.min = [g2.min; tau(1)];     % Bounds on computational domain
% g4D2.max = [g2.max; tau(end)];
% g4D2.bdry = @addGhostExtrapolate;
% g4D2.N = [g2.N; length(tau)];
% g4D2 = processGrid(g4D2);
% 
% % Create grid with time as a dimension
% g4D1s.dim = 4;                              % Number of dimensions
% g4D1s.min = [gs3D1.min; tau(1)];     % Bounds on computational domain
% g4D1s.max = [gs3D1.max; tau(end)];
% g4D1s.bdry = @addGhostExtrapolate;
% g4D1s.N = [gs3D1.N; length(tau)];
% g4D1s = processGrid(g4D1s);
% 
% % Create grid with time as a dimension
% g4D2s.dim = 4;                              % Number of dimensions
% g4D2s.min = [gs3D2.min; tau(1)];     % Bounds on computational domain
% g4D2s.max = [gs3D2.max; tau(end)];
% g4D2s.bdry = @addGhostExtrapolate;
% g4D2s.N = [gs3D2.N; length(tau)];
% g4D2s = processGrid(g4D2s);

% Copy large 3D look-up table into our small grid
data1s = zeros([gs3D1.N' length(tau)]);
data2s = zeros([gs3D1.N' length(tau)]);
for i = 1:length(tau)
    data1s(:,:,:,i) = migrateGrid(g1, data1(:,:,:,i), gs3D1);
    data2s(:,:,:,i) = migrateGrid(g2, data2(:,:,:,i), gs3D2);
end
% g4D1.N
% g4D1s.N
% size(data1)
% data1s = migrateGrid(g4D1, data1, g4D1s);
% data2s = migrateGrid(g4D2, data2, g4D2s);

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
    
    if nargin<7 && ~iscell(x)
        if eval_u(gs6D, data6Ds, x) <= 0, break; end
    end    
end
% disp(['Final time is ' num2str(tau(end))])

if iscell(x), valuex = [];
else          valuex = eval_u(gs6D, data6Ds, x);
end

value = data6Ds;
g = gs6D;
grad = extractCostates(g, value);

if iscell(x), gradx = [];
else          gradx = calculateCostate(g, grad, x);
end


end