function g2Dt = shift2DGrid(g2D, shiftAmount)
% function g2D = shift2DGrid(g2D, shiftAmount)
%
% Shifts a 2D grid g2D by the amount shiftAmount. The result may no longer
% be a valid grid structure, but is still sufficient for plotting
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
if ~iscolumn(shiftAmount)
  shiftAmount = shiftAmount';
end

g2Dt.xs = g2D.xs;
for i = 1:length(shiftAmount)
  g2Dt.xs{i} = g2D.xs{i} + shiftAmount(i);
end

end