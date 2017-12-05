function [g, data] = augmentPeriodicData(g, data)

%% Dealing with periodicity
for i = 1:g.dim
  if isfield(g, 'bdry') && isequal(g.bdry{i}, @addGhostPeriodic)
    % Grid points
    g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
    
    % Input data; eg. data = cat(:, data, data(:,:,1))
    colons1 = repmat({':'}, 1, g.dim);
    colons1{i} = 1;
    cat_argin = {i; data; data(colons1{:})};
    data = cat(cat_argin{:});
  end
end

end