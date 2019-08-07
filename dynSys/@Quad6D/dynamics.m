function dx = dynamics(obj, ~, x, u, ~)
% Dynamics of the Dubins Car
%    \dot{x}_1 = v * cos(x_3)
%    \dot{x}_2 = v * sin(x_3)
%    \dot{x}_3 = w
%   Control: u = w;
%
% Mo Chen, 2016-06-08
dx = cell(obj.nx,1);

dims = obj.dims;

returnVector = false;
if ~iscell(x)
  returnVector = true;
  x = num2cell(x);
  u = num2cell(u);
end

for i = 1:length(dims)
  dx{i} = dynamics_cell_helper(obj, x, u, dims, dims(i));
end

if returnVector
  dx = cell2mat(dx);
end
end
% 
% if iscell(x)
%   dx = cell(length(dims), 1);
%   
%   for i = 1:length(dims)
%     dx{i} = dynamics_cell_helper(obj, x, T1, T2, dims, dims(i));
%   end
% else
%   dx = zeros(obj.nx, 1);
%   
%   dx(1) = x(2);
%   dx(2) = (-(1/obj.m)*obj.transDrag*x(2))+...
%           ((-1/obj.m)*sin(x(5))*T1)+...
%           ((-1/obj.m)*sin(x(5))*T2);
%   dx(3) = x(4);
%   dx(4) = (-1/obj.m)*(obj.m*obj.grav + obj.transDrag*x(4)) +...
%           ((1/obj.m)*cos(x(5))*T1)+...
%           ((1/obj.m)*cos(x(5))*T2);
%   dx(5) = x(6);
%   dx(6) = ((-1/obj.Iyy)*obj.rotDrag*x(6))+...
%           ((-obj.l/obj.Iyy)*T1)+...
%           ((obj.l/obj.Iyy)*T2);
%   
% end
% end

function dx = dynamics_cell_helper(obj, x, u, dims, dim)

switch dim
  case 1
    dx = x{dims==2};
  case 2
    dx = (-(1/obj.m)*obj.transDrag*x{dims==2})+...
          ((-1/obj.m)*sin(x{dims==5})*u{1})+...
          ((-1/obj.m)*sin(x{dims==5})*u{2});
  case 3
    dx = x{dims==4};
  case 4
    dx = (-1/obj.m)*(obj.m*obj.grav + obj.transDrag*x{dims==4}) +...
      ((1/obj.m)*cos(x{dims==5})*u{1})+...
      ((1/obj.m)*cos(x{dims==5})*u{2});
  case 5
    dx = x{dims==6};
  case 6
    dx = ((-1/obj.Iyy)*obj.rotDrag*x{dims==6})+...
      ((-obj.l/obj.Iyy)*u{1})+...
      ((obj.l/obj.Iyy)*u{2});
  otherwise
    error('Only dimension 1-6 are defined for dynamics of Quad6D!')
end
end