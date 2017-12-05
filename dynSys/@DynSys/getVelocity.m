function [v, vhist] = getVelocity(obj)
% vel = getPosition(obj)
%     returns the velocity and optinally the velocity history of the vehicle

if ~isempty(obj.vdim)
  v = obj.x(obj.vdim);
  vhist = obj.xhist(obj.vdim, :);
end

% Plane is a special case, since speed is one of the controls
if isa(obj, 'Plane')
  v = mean(obj.vrange);
  vhist = mean(obj.vrange);
  
  if ~isempty(obj.u)
    v = obj.u(1);
    vhist = [vhist obj.uhist(1,:)];
  end
end

% DubinsCar is a special case, since speed is a constant, not a state
if isa(obj, 'DubinsCar')
  v = obj.speed;
  vhist = v*ones(1, size(obj.x, 2));
end

% If the velocity is a scalar, and there's a heading dimension, then we need to
% compute the velocity from speed and heading
if isscalar(v) && ~isempty(obj.hdim)
  [h, hhist] = obj.getHeading();
  v = v * [cos(h); sin(h)];
  vhist = [vhist.*cos(hhist); vhist.*sin(hhist)];
end

end