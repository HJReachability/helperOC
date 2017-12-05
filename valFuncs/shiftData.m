function dataOut = shiftData(g, dataIn, shift, pdims, interp_method)

% Default position dimensions
if nargin < 4
  pdims = [1 2];
end

if nargin < 5
  interp_method = 'linear';
end

rxs = g.xs;

%% Get a list of new indices
% Shift grid backwards
for i = 1:length(shift)
  rxs{pdims(i)} = g.xs{pdims(i)} - shift(i);
end

%% Interpolate dataIn to get approximation of rotated data
if g.dim == 2
  dataOut = eval_u(g, dataIn, [rxs{1}(:) rxs{2}(:)], interp_method);
  dataOut(isnan(dataOut)) = max(dataOut(:));
  dataOut = reshape(dataOut, g.shape);
else
  dataOut = ...
    eval_u(g, dataIn, [rxs{1}(:) rxs{2}(:) rxs{3}(:)], interp_method);
  dataOut(isnan(dataOut)) = max(dataOut(:));
  dataOut = reshape(dataOut, g.shape);
end
end