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
if numel(vIn) ~= 2
  error('Input vector must be 2D!')
end

rotate_matrix = [cos(theta) -sin(theta); sin(theta) cos(theta)];

% Rotate matrix and preserve vector size
if iscolumn(vIn)
  vOut = rotate_matrix * vIn;
else
  vOut = (rotate_matrix * vIn')';
end

end