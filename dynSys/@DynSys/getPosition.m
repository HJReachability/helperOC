function [p, phist] = getPosition(obj)
% pos = getPosition(obj)
%     returns the position and optionally position history of the vehicle

p = obj.x(obj.pdim);
phist = obj.xhist(obj.pdim, :);

end