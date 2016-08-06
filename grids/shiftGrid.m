function gShift = shiftGrid(gIn, shiftAmount)
% function g2D = shift2DGrid(g2D, shiftAmount)
%
% Shifts a grid by the amount shiftAmount. The result may no longer
% be a valid grid structure, but is still sufficient for plotting
%
% Mo Chen, 2015-10-20

%% Input checks
if numel(shiftAmount) ~= gIn.dim
  error('Length of shiftAmount must match dimension of the grid!')
end

% Make sure shiftAmount is a column vector
if ~iscolumn(shiftAmount)
  shiftAmount = shiftAmount';
end

%% Shift the grid
gShift.xs = gIn.xs;
for i = 1:length(shiftAmount)
  gShift.xs{i} = gIn.xs{i} + shiftAmount(i);
end

end