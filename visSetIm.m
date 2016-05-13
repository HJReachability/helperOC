function h = visSetIm(g, data, color, level, sliceDim, applyLight)
% h = visSetIm(g, data, color, level, sliceDim, applyLight)
%
% Code for quickly visualizing level sets
%
% Mo Chen, 2016-05-12

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

switch g.dim
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

N = 6;
spC = 3;
spR = 2;
h = cell(N,1);
for i = 1:N
  subplot(spR, spC, i)
  xs = g.min(sliceDim) + i/(N+1) * (g.max(sliceDim) - g.min(sliceDim));
  
  dim = zeros(1, 4);
  dim(sliceDim) = 1;
  [g3D, data3D] = proj3D(g, data, dim, xs);
  
  % Visualize 3D slices
  h{i} = visSetIm3D(g3D, data3D, color, level, applyLight);
  
end
end