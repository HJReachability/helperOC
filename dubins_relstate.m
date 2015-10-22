function xr = dubins_relstate(xe, xp)
% xr = air3Drelpos(xe, xp)

if numel(xe) ~= 3 || numel(xp) ~= 3
  error('Evader and pursuer states must be 3D!')
end

if size(xe, 1) ~= 3
  xe = xe';
end

if size(xp, 1) ~= 3
  xp = xp';
end

xr = xp - xe;

% Rotate to evader heading being 0
xr(1:2) = [cos(-xe(3)) -sin(-xe(3)); sin(-xe(3)) cos(-xe(3))] * xr(1:2);


if xr(3) >= 2*pi
  xr(3) = xr(3) - 2*pi;
end
if xr(3) < 0
  xr(3) = xr(3) + 2*pi;
end
end