function vOut = rotate2D(vIn, theta)
% function vOut = rotate2D(vIn)
%
% Rotates the 2D vector vIn by the angle theta and outputs the result vOut.
%
% Counterclockwise is positive. 
%
% Size of vOut matches size of vIn.
%
% Mo Chen, 2015-10-26

% Check if input is 2D
if all(size(vIn) ~= 2)
  error('Input vector must be 2D!')
end

% Rotate matrix and preserve vector size
vOut = zeros(size(vIn));
transpose = false;
if size(vIn, 1) ~= 2
  vIn = vIn';
  vOut = vOut';
  transpose = true;
end

if iscolumn(theta)
  theta = theta';
end

vOut(1,:) = cos(theta) .* vIn(1,:) - sin(theta) .* vIn(2,:);
vOut(2,:) = sin(theta) .* vIn(1,:) + cos(theta) .* vIn(2,:);

if transpose
  vOut = vOut';
end

end