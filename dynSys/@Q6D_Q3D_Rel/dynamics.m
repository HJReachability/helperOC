function dx = dynamics(obj, ~, x, u, d)
% dx = dynamics(obj, ~, x, u, ~)
%     Dynamics of the 6D Quadrotor
%         \dot x_1 = x_4 - d(1) - d(2) 
%         \dot x_2 = x_5 - d(3) - d(4)
%         \dot x_3 = x_6 - d(5) - d(6)
%         \dot x_4 = g * tan(u(1))
%         \dot x_5 = - g * tan(u(2))
%         \dot x_6 = u(3) - g
%         min (radians)      <=     [u(1); u(2)]   <= max (radians)
%         min thrust (m/s^2) <=         u(3)       <= max thrust (m/s^2)
%         dist vmin (m/s)    <= [d(1); d(3); d(5)] <= dist vmax (m/s)
%         dist amin (m/s^2)  <= [d(7); d(8); d(9)] <= dist amax (m/s^2)
%         planner vmin (m/s) <= [d(2); d(4); d(6)] <= planner vmax (m/s)


if nargin < 5
  d = {0; 0; 0};
end

if nargin < 6
  dims = obj.dims;
end

convert2num = false;
if ~iscell(x)
  x = num2cell(x);
  convert2num = true;
end

if ~iscell(u)
  u = num2cell(u);
end

if ~iscell(d)
  d = num2cell(d);
end

dx = cell(length(dims), 1);

for i = 1:length(dims)
  dx{i} = dynamics_cell_helper(obj, x, u, d, dims, dims(i));
end

if convert2num
  dx = cell2mat(dx);
end

end

function dx = dynamics_cell_helper(obj, x, u, d, dims, dim)
switch dim
    case 1
        dx = x{dims==2} - d{1} - d{2};
    case 2
        dx = obj.grav * tan(u{1}) - d{3};
    case 3
        dx = x{dims==4} - d{4} - d{5};
    case 4
        dx = - obj.grav * tan(u{2}) - d{6};
    case 5
        dx = x{dims==6} - d{7} - d{8};
    case 6
        dx = u{3} - obj.grav - d{9};


    
  otherwise
    error('Only dimension 1-6 are defined for dynamics of Q6D_Q3D_Rel!')
end
end
