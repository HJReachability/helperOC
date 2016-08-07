function h = visSetIm(g, data, color, level, sliceDim, applyLight)
% h = visSetIm(g, data, color, level, sliceDim, applyLight)
% Code for quickly visualizing level sets
%
% Inputs: g          - grid structure
%         data       - value function corresponding to grid g
%         color      - (defaults to red)
%         level      - level set to display (defaults to 0)
%         sliceDim   - for 4D sets, choose the dimension of the slices (defaults
%                      to last dimension)
%         applyLight - Whether to apply camlight (defaults to true)
%
% Output: h - figure handle
%
% Adapted from Ian Mitchell's visualizeLevelSet function from the level set
% toolbox
%
% Mo Chen, 2016-05-12

%% Default parameters and input check
if g.dim ~= numDims(data) && g.dim+1 ~= numDims(data)
  error('Grid dimension is inconsistent with data dimension!')
end

if nargin < 3
  color = 'r';
end

if nargin < 4
  level = 0;
end

% Slice last dimension by default
if nargin < 5
  sliceDim = g.dim;
end

% Add cam light?
if nargin < 6
  applyLight = true;
end

%%
if g.dim == numDims(data)
  % Visualize a single set
  h = visSetIm_single(g, data, color, level, sliceDim, applyLight);
else
  dataSize = size(data);
  numSets = dataSize(end);
  h = cell(numSets, 1);
  colons = repmat({':'}, 1, g.dim);
  
  for i = 1:numSets
    if i > 4
      applyLight = false;
    end
    
    h{i} = visSetIm_single(g, data(colons{:},i), color, level, sliceDim, ...
      applyLight);

    drawnow;
  end
end


end

%% Visualize a single set
function h = visSetIm_single(g, data, color, level, sliceDim, applyLight)
% h = visSetIm_single(g, data, color, level, applyLight)
%     Displays level set depending on dimension of grid and data

switch g.dim
  case 1
    h = plot(g.xs{1}, data, '-', 'color', color);
    hold on
    plot(g.xs{1}, zeros(size(g.xs{1})), 'k:')
    
  case 2
    [~, h] = contour(g.xs{1}, g.xs{2}, data, [level level], 'color', color);
    
  case 3
    h = visSetIm3D(g, data, color, level, applyLight);
    
  case 4
    h = visSetIm4D(g, data, color, level, sliceDim, applyLight);
end
end

%% 3D Visualization
function h = visSetIm3D(g, data, color, level, applyLight)
% h = visSetIm3D(g, data, color, level, applyLight)
% Visualizes a 3D reachable set


[ mesh_xs, mesh_data ] = gridnd2mesh(g, data);

h = patch(isosurface(mesh_xs{:}, mesh_data, level));
isonormals(mesh_xs{:}, mesh_data, h);
h.FaceColor = color;
h.EdgeColor = 'none';

lighting phong

if applyLight
  camlight left
  camlight right
end

view(3)
end

%% 4D Visualization
function h = visSetIm4D(g, data, color, level, sliceDim, applyLight)
% h = visSetIm4D(g, data, color, level, sliceDim, applyLight)
% Visualizes a 4D reachable set
%
% Takes 6 slices in the dimension sliceDim and shows the 3D projections

N = 6;
spC = 3;
spR = 2;
h = cell(N,1);
for i = 1:N
  subplot(spR, spC, i)
  xs = g.min(sliceDim) + i/(N+1) * (g.max(sliceDim) - g.min(sliceDim));
  
  dim = zeros(1, 4);
  dim(sliceDim) = 1;
  [g3D, data3D] = proj(g, data, dim, xs);
  
  % Visualize 3D slices
  h{i} = visSetIm3D(g3D, data3D, color, level, applyLight);
  
end
end