function dataOut = rotateData(g, dataIn, theta, pdims, adim, interp_method)
% Rotates about origin
% The grid structure g is common to dataIn and dataOut

% Default position dimensions
if nargin < 4
  pdims = [1 2];
end

% Default angle dimension
if nargin < 5
  adim = 3;
end

if nargin < 6
  interp_method = 'linear';
end

rxs = g.xs;

%% Get a list of new indices
% Multiply by rotation matrix for position dimensions
rxs{pdims(1)} = cos(-theta) * g.xs{pdims(1)} - sin(-theta) *g.xs{pdims(2)};
rxs{pdims(2)} = sin(-theta) * g.xs{pdims(1)} + cos(-theta) *g.xs{pdims(2)};

% Translate in angle
if ~isempty(adim)
  rxs{adim} = g.xs{adim} - theta;
end

%% Interpolate dataIn to get approximation of rotated data
if g.dim == 2
  dataOut = eval_u(g, dataIn, [rxs{1}(:) rxs{2}(:)], interp_method);
  dataOut(isnan(dataOut)) = max(dataOut);
  dataOut = reshape(dataOut, g.shape);
else
  rxsVec = [];
  for i = 1:g.dim
    rxsVec = [rxsVec rxs{i}(:)];
  end
  
  dataOut = eval_u(g, dataIn, rxsVec, interp_method);
  dataOut(isnan(dataOut)) = max(dataOut);
  dataOut = reshape(dataOut, g.shape);
end
end