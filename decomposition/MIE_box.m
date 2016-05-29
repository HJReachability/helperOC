function [data_l, data_u] = MIE_box(g, lower, upper, diff)
% MIE value functions for 2D box
% decreasing 'diff' gives a better approximation
%
% Equations for approximation of 2W by 2H box in 2D centered at origin and 
% symmetric along each axis with line transitions at +/-M:
%   (approximation better as M approaches H)
%
% Mahesh Vashishtha, 2016-05-06
% Modified: Mo Chen, 2016-05-10

%% Input checking
if ~isvector(lower) || ~isvector(upper)
  error('Lower and upper corners must be vectors!')
end

if g.dim + 1 ~= length(lower)
  error('Grid dimensions are inconsistent!')
end

if length(lower) ~= length(upper)
  error('Lower and upper bound dimensions do not match!')
end

% By default, approximate left and right edges differ from true edges by 5%
if nargin < 4
  diff = 0.05 * (upper(2) - lower(2));
end

%% Box width and center
% Width
W = (upper - lower)/2;

% Center
C = (upper + lower)/2;

% Slope of slanted lines
m = diff/W(1);
minv = 1/m;

%% Upper and lower functions
% First dimension
data_l = max(-(W(1)-C(1)), minv*(g.xs{1}-upper(2))+C(1));
data_l = max(data_l, -minv*(g.xs{1}-lower(2))+C(1));
data_u = min(W(1)+C(1), -minv*(g.xs{1}-upper(2))+C(1));
data_u = min(data_u, minv*(g.xs{1}-lower(2))+C(1));

% The rest of the dimensions
for i = 2:g.dim
  data_l = max(data_l, minv*(g.xs{i}-upper(i+1))+C(1));
  data_l = max(data_l, -minv*(g.xs{i}-lower(i+1))+C(1));
  data_u = min(data_u, -minv*(g.xs{i}-upper(i+1))+C(1));
  data_u = min(data_u, minv*(g.xs{i}-lower(i+1))+C(1));
end

end