function h = visSetMIE(g, data, color, sliceDim)
% h = visSetMIE(g, data, color, sliceDim)
% Visualizes the MIE representation of a set
%
% Inputs: g        - grid structure
%         data     - value function corresponding to grid g
%         color    - 
%         sliceDim - dimension to slice for 4D sets
%
% Output: h        - graphic handle
%
% Mo Chen, 2016-05-12

%% Default parameters
if nargin < 3
  color = 'b';
end

if nargin < 4
  sliceDim = g.dim;
end

%% Visualize
switch g.dim
  case 1
    h = plot(data, g.xs{1}, '-', 'color', color);
    
  case 2
    h = plot3(data, g.xs{1}, g.xs{2}, '.', 'color', color);

  case 3
    h = visSetMIE4D(g, data, color, sliceDim);
    
end


end

function h = visSetMIE4D(g, data, color, sliceDim)
% h = visSetMIE4D(g, data, color, sliceDim)
% Takes 6 different slices of the 4D set and visualizes the 3D slices

N = 6;
spC = 3;
spR = 2;
h = cell(N,1);
for i = 1:N
  
  subplot(spR, spC, i)
  xs = g.min(sliceDim) + i/(N+1) * (g.max(sliceDim) - g.min(sliceDim));  
  dim = zeros(1, 3);
  dim(sliceDim) = 1;
  [g2D, data2D] = proj2D(g, data, dim, xs);

  h{i} = plot3(data2D, g2D.xs{1}, g2D.xs{2}, '.', 'color', color);
  hold on
end
end