function [stopflag] = checkInclusion(location, grid, data);

% This function checks whether the locations specified in the matrix
% location are contained in the data. The correspodning entry is 1 in
% stopflag and 0 otherwise.
%
% Inputs:
%   location - A matrix of size nX times number of points,
%               where nX is the number of states.
%   grid, data - grid and data over which the inclusion is to be checked.
% Outputs:
%   stopflag(i) - A flag that is 1 if the corresponding point,
%                   location(:,i) is contained in the data.
%

% Do some basic checks
if size(location,1) ~= grid.dims
    error('Number of states do not match with number of grid dimensions!');
end

if grid.shape ~= size(data)
    error('Grid shape do not match with the data structure!');
end

% Number of points
num_pts = size(location,2);

% Convert the location into the appropriate cell structure
locationCell = mat2cell(location, ones(1,grid.dims), num_pts);
[cell_indexes, valid_mask ] = getCellIndexes(grid, locationCell);

% Initialize the stopflag
stopflag = false(size(valid_mask));

% Check Inclusion
switch g.dim
    case 4
        for i = 1:num_pts
            if valid_mask(i)
                [id1, id2, id3, id4] = ind2sub(grid.shape, cell_indexes(i));
                if (data(id1, id2, id3, id4) <= 0)
                    stopflag(i) = true;
                end
            end
        end
        
    case 3
        for i = 1:num_pts
            if valid_mask(i)
                [id1, id2, id3] = ind2sub(grid.shape, cell_indexes(i));
                if (data(id1, id2, id3) <= 0)
                    stopflag(i) = true;
                end
            end
        end
        
    case 2
        for i = 1:num_pts
            if valid_mask(i)
                [id1, id2] = ind2sub(grid.shape, cell_indexes(i));
                if (data(id1, id2) <= 0)
                    stopflag(i) = true;
                end
            end
        end
        
    case 1
        for i = 1:num_pts
            if valid_mask(i)
                [id1] = ind2sub(grid.shape, cell_indexes(i));
                if (data(id1) <= 0)
                    stopflag(i) = true;
                end
            end
        end
    otherwise
        error('Input data must be in 1D, 2D, 3D, or 4D!')
end
end