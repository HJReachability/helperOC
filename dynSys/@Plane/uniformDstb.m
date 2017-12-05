function d = uniformDstb(obj)
% d = uniformDstb(obj)
%     uniform disturbance for the Plane class

d = zeros(obj.nd, 1);

first = true;
while first || norm(d(1:2)) > obj.dMax(1)
  d(1:2) = -obj.dMax(1) + 2*obj.dMax(1)*rand(2,1);
  first = false;
end

d(3) = -obj.dMax(2) + 2*obj.dMax(2)*rand;

end