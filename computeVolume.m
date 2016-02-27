function volume = computeVolume(g, data)
% volume = computeVolume(g, data)
% 
% Computes the volume of the sub-zero level set of the implicit surface function
% represented by the grid g and look-up table data
%
% Notes:
%   - Uses MATLAB's trapezoidal rule function, trapz
%   - Adjust N to control accuracy (be careful with using large N's...)
%
% Mo Chen, 2016-02-26

if g.dim > 4
  error('This function is implemented for more than 4 dimensions!')
end

%% Constant grid sizes depending on number of dimensions
N = [8001 2001 251 61];

%% Migrate data into a fine grid
gFine.dim = g.dim;
gFine.N = N(g.dim)*ones(g.dim, 1);
gFine.min = g.min;
gFine.max = g.max;
gFine.bdry = g.bdry;
gFine = processGrid(gFine);

dataFine = migrateGrid(g, data, gFine);

%% Convert implicit surface function to logical
dataLogical = ones(size(dataFine)) .* (dataFine<=0);

%% Integrate
volume = dataLogical;
for i = g.dim:-1:1
  volume = trapz(gFine.vs{i}, volume, i);
end
end