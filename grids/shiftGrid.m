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

% Dimensionality of grid
gShift.dim = gIn.dim;
gShift.bdry = gIn.bdry;
gShift.dx = gIn.dx;
gShift.N = gIn.N;

%% Shift the grid
gShift.xs = cell(gShift.dim, 1);
gShift.vs = cell(gShift.dim, 1);
gShift.min = zeros(gShift.dim, 1);
gShift.max = zeros(gShift.dim, 1);

for i = 1:length(shiftAmount)
  gShift.xs{i} = gIn.xs{i} + shiftAmount(i);
  gShift.min(i) = min(gShift.xs{i}(:));
  gShift.max(i) = max(gShift.xs{i}(:));
  gShift.vs{i} = unique(gShift.xs{i}(:));
end

end