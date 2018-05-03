function feas_ctrl_constr_test(dCar, g, data, deriv)
% [m, b] = feas_ctrl_constr(obj, ~, x, deriv, uMode, dMode)
%
%     Feasible control constraints in the form of m*u + b >= 0 or <= 0

dMode = 'min';

% Velocity slice
vx = 4;
vy = 2;

% Visualize reachable set
[g2D, data2D] = proj(g, data(:,:,:,:,end), [0 1 0 1], [vx vy]);

figure;
visSetIm(g2D, data2D, 'r');

% Compute gradient at the points on the v slice
derivN = {deriv{1}(:,:,:,:,end); deriv{2}(:,:,:,:,end); 
  deriv{3}(:,:,:,:,end); deriv{4}(:,:,:,:,end)};

xsSlice = [g2D.xs{1}(:) vx*ones(size(g2D.xs{1}(:))) g2D.xs{2}(:) ...
  vy*ones(size(g2D.xs{1}(:)))];

deriv_xy = cell(4,1);
for i = 1:4
  deriv_xy{i} = eval_u(g, derivN{i}, xsSlice);
  deriv_xy{i} = reshape(deriv_xy{i}, g2D.shape);
end

% Compute feasible controls
xsSliceCell = {g2D.xs{1}; vx*ones(size(g2D.xs{1})); g2D.xs{2}; ...
  vy*ones(size(g2D.xs{1}))};

[m, b, mNorm] = dCar.feas_ctrl_constr([], xsSliceCell, deriv_xy, dMode);

% Plot feasible controls
hold on

quiver(g2D.xs{1}, g2D.xs{2}, m{1}, m{2});

ctrl_all_feas = mNorm==0 & b >= 0;
plot(g2D.xs{1}(ctrl_all_feas), g2D.xs{2}(ctrl_all_feas), 'o')

% Plot locations where no control is feasible
ctrl_all_infeas = mNorm==0 & b < 0;
plot(g2D.xs{1}(ctrl_all_infeas), g2D.xs{2}(ctrl_all_infeas), 'x')

axis equal
end