function children = getChildren(obj)
% getChildren(obj)
% method of Node class
%
% Returns the children of a node

if isa(obj, 'TFM')
  children = obj.hws;
  
elseif isa(obj, 'Highway')
  children = obj.ps;
  
elseif isa(obj, 'Platoon')
  children = {};
  for i = 1:length(obj.vehicles);
    if ~isempty(obj.vehicles{i})
      children{length(children)+1, 1} = obj.vehicles{i};
    end
  end
  
elseif isa(obj, 'Vehicle')
  children = {};
  
else
  error('Unknown Node type!')
  
end

end