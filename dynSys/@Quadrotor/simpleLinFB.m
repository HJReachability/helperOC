function u = simpleLinFB(obj, uFB, ref_pos, ref_vel)
% u = simpleLinFB(uFB, pos_err, vel_err)
% method of Quadrotor class
%
% Simple position and velocity feedback; gains could be tuned

if numel(uFB) ~= obj.nu
  error(['Reference input must be ' num2str(obj.nu) 'D!'])
end

if ~iscolumn(uFB)
  uFB = uFB';
end

if ~iscolumn(ref_pos)
  ref_pos = ref_pos';
end

if ~iscolumn(ref_vel)
  ref_vel = ref_vel';
end

% Gains
k_p = 1;
k_v = 1;

u = uFB + k_p*(ref_pos - obj.getPosition) + ...
  k_v*(ref_vel - obj.getVelocity);

% Acceleration limit
if any(u > obj.uMax)
  u = u / max(u) * obj.uMax;
end

if any(u < obj.uMin)
  u = u / min(u) * obj.uMin;
end
end