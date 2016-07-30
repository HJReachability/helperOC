function d = sepDist(obj, other)
% Separation distance between obj and other vehicle
% Qie Hu, 2015-08-06

d = norm(obj.x(obj.pdim) - other.x(other.pdim),2);
    
end