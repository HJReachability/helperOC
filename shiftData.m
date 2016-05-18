function dataOut = shiftData(g, dataIn, shift, pdims)

% Default position dimensions
if nargin < 4
  pdims = [1 2];
end

rxs = g.xs;

%% Get a list of new indices
% Shift grid backwards
for i = 1:length(shift)
  rxs{pdims(i)} = g.xs{pdims(i)} - shift(i);
end

%% Interpolate dataIn to get approximation of rotated data
dataOut = eval_u(g, dataIn, [rxs{1}(:) rxs{2}(:) rxs{3}(:)]);
dataOut = reshape(dataOut, g.shape);

end