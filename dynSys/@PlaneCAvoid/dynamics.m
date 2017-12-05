function dx = dynamics(obj, t, x, u, d, ~)
% Dynamics relative to Plane A:
%     \dot{x}_1 = -vA + vB*cos(x_3) + wA*x_2 + d1
%     \dot{x}_2 = vB*sin(x_3) - wA*x_1 + d2
%     \dot{x}_3 = wB - wA + d3
%         vA in vRangeA, vB in vRangeB
%         wA in [-wMaxA, wMaxA], wB in [-wMaxB, wMaxB]
%         norm(d1, d2) <= dMaxA(1) + dMaxB(1)
%         abs(d3) <= dMaxA(2) + dMaxB(2)
%
%     u = (vA, wA)
%     d = (vB, wB, d1, d2, d3)

if numel(u) ~= obj.nu
  error('Incorrect number of control dimensions!')
end

if numel(d) ~= obj.nd
  error('Incorrect number of disturbance dimensions!')
end

if iscell(x)
  dx = cell(obj.nx, 1);
  
  dx{1} = -u{1} + d{1}.*cos(x{3}) + u{2}.*x{2} + d{3};
  dx{2} = d{1}.*sin(x{3}) - u{2}.*x{1} + d{4};
  dx{3} = d{2} - u{2} + d{5};
else
  dx = zeros(obj.nx, 1);
  
  dx(1) = -u(1) + d(1)*cos(x(3)) + u(2)*x(2) + d(3);
  dx(2) = d(1)*sin(x(3)) - u(2)*x(1) + d(4);
  dx(3) = d(2) - u(2) + d(5);
end


end