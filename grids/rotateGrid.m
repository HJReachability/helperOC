function gRot = rotateGrid(gIn, theta, dims)
% function gRot = rotate2DGrid(g2D, theta)
%
% Rotates the grid so that the contours from some function corresponding to
% g2D would be rotated by theta
%
% i.e. contour(gRot.xs{1}, gRot.xs{2}, data) would look like
%      contour(g2D.xs{1}, g2D.xs{2}, data) rotated by theta
%
% Inputs: g2D   - original grid
%         theta - rotation angle
%         dims  - which dimensions to rotate
% Output: gRot  - grid which makes the contour rotated by theta
%
% Mo Chen, 2015-10-30

if nargin < 3
  dims = 1:2;
end

% Some basic input checks
if ~isstruct(gIn)
  error('Input grid must be a struct!')
end

if numel(dims) ~= 2
  error('Must rotate two dimensions!')
end

% Rotate the grid using a 2D rotation matrix
gRot.xs = gIn.xs;
gRot.xs{dims(1)} = cos(theta)*gIn.xs{dims(1)} - sin(theta)*gIn.xs{dims(2)};
gRot.xs{dims(2)} = sin(theta)*gIn.xs{dims(1)} + cos(theta)*gIn.xs{dims(2)};
gRot.dim = gIn.dim;
end