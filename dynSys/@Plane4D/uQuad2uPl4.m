function uPl4 = uQuad2uPl4(obj, uQuad)
% uPl4 = uQuad2uPl4(obj, uQuad)
%
% Converts controls (acceleration in x and y directions) in a Quadrotor to 
% controls in a Plane4 (acceleration and turn rate)
%
% Mo Chen, 2016-02-01

if numel(uQuad) ~= 2
  error('Quadrotor control must be 2D!')
end

if ~iscolumn(uQuad);
  uQuad = uQuad';
end

theta = obj.getHeading;
v = obj.getSpeed;

M = [-sin(theta)/v cos(theta)/v; cos(theta) sin(theta)];

uPl4 = M * uQuad;
end