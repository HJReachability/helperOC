function h = visGrid(g, color)
% h = visGrid(g, color)
%   Visualizes a grid of up to three dimensions
%
% This function is used and tested in splitGrid_sameDim_test

if nargin < 2
  color = 'b';
end

switch g.dim
  case 1
    plot(zeros(g.N, 1), g.vs{1}, '.', 'color', color)
  case 2
    plot(g.xs{1}(:), g.xs{2}(:), '.', 'color', color)
  case 3
    plot3(g.xs{1}(:), g.xs{2}(:), g.xs{3}(:), '.', 'color', color)
  otherwise
    error('Only grids of up to 3 dimensions can be visualized!')
end

end