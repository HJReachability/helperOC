function gRot = rotate2DGrid(g2D, theta)
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
% Output: gRot  - grid which makes the contour rotated by theta
%
% Mo Chen, 2015-10-30

% Some basic input checks
if ~isstruct(g2D)
  error('Input grid must be a struct!')
end

if g2D.dim ~= 2
  error('Input grid must be 2D!')
end

% Rotate the grid using a 2D rotation matrix
gRot.xs = g2D.xs;
gRot.xs{1} = cos(theta)*g2D.xs{1} - sin(theta)*g2D.xs{2};
gRot.xs{2} = sin(theta)*g2D.xs{1} + cos(theta)*g2D.xs{2};
gRot.dim = 2;
end