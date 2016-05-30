function vs = createConsecutiveGroups(v)
% vs = createConsecutiveGroups(v)
%     splits the vector v into a cell vs whose elements contain a vector
%     containing consecutive integers

% Count number of groups needed
dv = diff(v);
vs = cell(nnz(dv~=1)+1, 1);

% Create the groups
i = 1;
while ~isempty(v)
  % Find the end index of the group
  groupEnd = find(dv ~= 1, 1, 'first');
  
  % Add a group, and remove the corresponding elements in v
  if isempty(groupEnd)
    vs{i} = v;
    v = [];
  else
    vs{i} = v(1:groupEnd);
    v (1:groupEnd) = [];
  end
  
  % Repeat
  dv = diff(v);
  i = i + 1;
end

end