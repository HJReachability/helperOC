function g2D = shift2DGrid(g2D, shiftAmount)
% function g2D = shift2DGrid(g2D, shiftAmount)
%
% Shifts a 2D grid g2D by the amount shiftAmount
%
% Mo Chen, 2015-10-20

% Input checks
if g2D.dim ~= 2
  error('Grid must be 2D!')
end

if numel(shiftAmount) ~= 2
  error('Shift amount must be a 2D vector!')
end

% Make sure shiftAmount is a column vector
if size(shiftAmount,1) ~= 2
  shiftAmount = shiftAmount';
end

% Shift the grid
g2Dt.dim = g2D.dim;
g2Dt.min = g2D.min + shiftAmount;
g2Dt.max = g2D.max + shiftAmount;
g2Dt.N = g2D.N;
g2Dt.bdry = g2D.bdry;
g2Dt = processGrid(g2Dt);
g2D = g2Dt;
end