function [gMinOut, gMaxOut, NOut] = getOGPBounds(gBase, gMinIn, gMaxIn, padding)
% [gMinOut, gMaxOut] = getOGPBounds(gBase, gMinIn, gMaxIn)
%     Returns grid bounds based on gBase, gMinIn, and gMaxIn such that if a new
%     grid is constructed from gMinOut and gMaxOut, the grid points within the
%     bounds of gBase would be the same.
%
%     This is done without needing the actual grid points of gBase
%


% Compute or read grid spacing
if isfield(gBase, 'dx')
  dx = gBase.dx;
else
  dx = (gBase.max - gBase.min) ./ (gBase.N - 1);
end

% Add padding to both sides
gMinIn = gMinIn - padding;
gMaxIn = gMaxIn + padding;

% Initialize
gMaxOut = zeros(gBase.dim, 1);
gMinOut = zeros(gBase.dim, 1);
NOut = zeros(gBase.dim, 1);

for dim = 1:gBase.dim
  % Arbitrary reference point
  refGridPt = gBase.min(dim);
  
  % Get minimum and maximum bounds for this dimension
  ptrMax = floor((gMaxIn(dim) - refGridPt) / dx(dim));
  gMaxOut(dim) = refGridPt + ptrMax*dx(dim);
  
  ptrMin = ceil((gMinIn(dim) - refGridPt) / dx(dim));
  gMinOut(dim) = refGridPt + ptrMin*dx(dim);
  
  % Get number of grid points
  NOut(dim) = ptrMax - ptrMin + 1;
end
end