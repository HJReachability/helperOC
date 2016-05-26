function dataOut = rotateData(g, dataIn, theta, pdims, adim)
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

rxs = g.xs;

%% Get a list of new indices
% Multiply by rotation matrix for position dimensions
rxs{pdims(1)} = cos(-theta) * g.xs{pdims(1)} - sin(-theta) *g.xs{pdims(2)};
rxs{pdims(2)} = sin(-theta) * g.xs{pdims(1)} + cos(-theta) *g.xs{pdims(2)};

% Translate in angle
small = 0.1;
if ~isempty(adim)
  rxs{adim} = g.xs{adim} - theta;
  
  if abs(g.min(adim)) < small
    rxs{adim} = wrapTo2Pi(rxs{adim});
  end

  if abs(g.min(adim) + pi) < small
    rxs{adim} = wrapToPi(rxs{adim});
  end  
end

%% Interpolate dataIn to get approximation of rotated data
dataOut = eval_u(g, dataIn, [rxs{1}(:) rxs{2}(:) rxs{3}(:)]);
dataOut = reshape(dataOut, g.shape);
end