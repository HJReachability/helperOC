function [g3D, data3D] = proj3D(g4D, dims, N3D, data4D, xs)
% [g3D, data3D] = proj3D(g4D, dims, N2D, data4D, xs)
% Projects 4D data down to 3D onto the dimension dim at the point xs
%
% Inputs:
%   g4D      -    4D grid structure
%   data4D   -    4D data
%   dims   -    dimensions from which projection is done
%                   eg. [0 0 0 1] means the last dimension will be
%                       squeezed
%   N3D    -    number of grid points in 3D grid
%   xs     -    point on which to project
%
% Outputs:
%   g3D    -    2D grid structure
%   data3D -    projected data
%
% Requires processGrid() function from the levelset toolbox
%
% Mo Chen, Dec. 17, 2014

dims = logical(dims);

if nargin<3, N3D = g4D.N(~dims); end
if isempty(N3D), N3D = g4D.N(~dims); end

g3D.dim = 3;
g3D.min = g4D.min(~dims);
g3D.max = g4D.max(~dims);
g3D.bdry = g4D.bdry(~dims);

if numel(N3D) == 1,     g3D.N = [N3D; N3D; N3D];
else                    g3D.N = N3D; end

g3D = processGrid(g3D);

% Project data onto 3D space if required; otherwise, just convert grid
if nargin > 3
    switch g4D.dim
        case 4
            if nnz(dims) ~= 1, error('Must project onto three dimensions!'); end
            
            if ischar(xs)
                if strcmp(xs,'min')
                    data3D = squeeze(min(data4D, [], find(dims)));
                elseif strcmp(xs,'max')
                    data3D = squeeze(max(data4D, [], find(dims)));
                end
            else
                
                
                if dims(1)          % dims = [1 0 0 0]
                    temp = interpn(g4D.vs{1}, g4D.vs{2}, g4D.vs{3}, g4D.vs{4}, ...
                        data4D, xs, g4D.vs{2}, g4D.vs{3},  g4D.vs{4});
                    x1_g3D = g4D.vs{2};
                    x2_g3D = g4D.vs{3};
                    x3_g3D = g4D.vs{4};
                    
                elseif dims(2)      % dims = [0 1 0 0]
                    temp = interpn(g4D.vs{1}, g4D.vs{2}, g4D.vs{3}, g4D.vs{4}, ...
                        data4D, g4D.vs{1}, xs, g4D.vs{3}, g4D.vs{4});
                    x1_g3D = g4D.vs{1};
                    x2_g3D = g4D.vs{3};
                    x3_g3D = g4D.vs{4};
                    
                elseif dims(3)      % dims = [0 0 1 0]
                    temp = interpn(g4D.vs{1}, g4D.vs{2}, g4D.vs{3}, g4D.vs{4}, ...
                        data4D, g4D.vs{1}, g4D.vs{2}, xs, g4D.vs{4});
                    x1_g3D = g4D.vs{1};
                    x2_g3D = g4D.vs{2};
                    x3_g3D = g4D.vs{4};
                    
                else                % dims = [0 0 0 1]
                    temp = interpn(g4D.vs{1}, g4D.vs{2}, g4D.vs{3}, g4D.vs{4}, ...
                        data4D, g4D.vs{1}, g4D.vs{2}, g4D.vs{3}, xs);
                    x1_g3D = g4D.vs{1};
                    x2_g3D = g4D.vs{2};
                    x3_g3D = g4D.vs{3};
                end
                
                data3D = squeeze(temp);     % Squeeze unwanted dimension
                data3D = interpn(x1_g3D, x2_g3D, x3_g3D, data3D, g3D.xs{1}, g3D.xs{2}, g3D.xs{3}); % Convert data to new grid
            end
            
        otherwise
            error('Only projection from 4D has been implemented!')
    end
    
else
    data3D = [];
end
end