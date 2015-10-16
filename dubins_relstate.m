function xr = air3Drelpos(xe, xp)
% xr = air3Drelpos(xe, xp)
xr = xp' - xe';

% Rotate to evader heading being 0
xr(1:2) = [cos(-xe(3)) -sin(-xe(3)); sin(-xe(3)) cos(-xe(3))] * xr(1:2);

xr = xr';
if xr(3) >= 2*pi
  xr(3) = xr(3) - 2*pi;
end
if xr(3) < 0
  xr(3) = xr(3) + 2*pi;
end
end