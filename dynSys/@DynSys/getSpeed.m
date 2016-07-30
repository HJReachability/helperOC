function [s, shist] = getSpeed(obj)
% function getSpeed(obj)
%     returns the speed and optionally speed history of the vehicle

% If vdim is a scalar, then speed is given by the vdim dimension of the state
if isscalar(obj.vdim)
  s = obj.x(vdim);
  shist = obj.xhist(vdim, :);
  return
end

% Otherwise, compute speed from velocity
[v, vhist] = obj.getVelocity;
s = norm(v);

shist = zeros(1, size(vhist, 2));
for i = 1:size(vhist, 2)
  shist(i) = norm(vhist(:,i));
end


end