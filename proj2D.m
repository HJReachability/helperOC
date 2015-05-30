function [g2D, data2D] = proj2D(g, dims, N2D, data, xs)
% [g2D, data2D] = proj2D(g4D, dims, N2D, data4D, xs)
% Projects 4D data down to 2D onto the dimensions dims at the point xs
%
% Inputs:
%   g      -    high-D grid structure
%   data   -    high-D data
%   dims   -    dimensions from which projection is done
%                   eg. [0 0 1 1] means the last two dimensions will be
%                       squeezed
%   N2D    -    number of grid points in 2D grid
%   xs     -    point on which to project
%
% Outputs:
%   g2D    -    2D grid structure
%   data2D -    projected data
%
% Mo Chen, Oct. 4, 2013

dims = logical(dims);

if nargin<3, N2D = 200; end

g2D.dim = 2;
g2D.min = g.min(~dims);
g2D.max = g.max(~dims);
g2D.bdry = g.bdry(~dims);

if nargin<3, N2D = g4D.N(~dims); end
if isempty(N2D), N2D = g4D.N(~dims); end
if numel(N2D) == 1,     g2D.N = [N2D; N2D];
else                    g2D.N = N2D; end

g2D = processGrid(g2D);

% Project data onto 2D space if required; otherwise, just convert grid
if nargin > 3
    switch g.dim
        case 6
            if sum(dims) ~= 4, error('Must project onto two dimensions!'); end
           
            if dims == [0 1 1 0 1 1]
                temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                    g.vs{5}, g.vs{6}, data, ...
                    g.vs{1}, xs(1), xs(2), g.vs{4}, xs(3), xs(4));
                x1_g2D = g.vs{1};
                x2_g2D = g.vs{4};                 
            else
                error('Can only project onto x-y position for now...')
            end
            
            data2D = squeeze(temp);
            data2D = interpn(x1_g2D, x2_g2D, data2D, g2D.xs{1}, g2D.xs{2});            
        case 4
            if sum(dims) ~= 2, error('Must project onto two dimensions!'); end
            
            if dims(1)          % dims = [1 * * *]
                if dims(2)      % dims = [1 1 0 0]
                    temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                        data, xs(1), xs(2), g.vs{3}, g.vs{4});
                    x1_g2D = g.vs{3};
                    x2_g2D = g.vs{4};
                elseif dims(3)  % dims = [1 0 1 0]
                    temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                        data, xs(1), g.vs{2}, xs(2), g.vs{4});
                    x1_g2D = g.vs{2};
                    x2_g2D = g.vs{4};
                else            % dims = [1 0 0 1]
                    temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                        data, xs(1), g.vs{2}, g.vs{3},  xs(2));
                    x1_g2D = g.vs{2};
                    x2_g2D = g.vs{3};
                end
            elseif dims(2)      % dims = [0 1 * *]
                if dims(3)      % dims = [0 1 1 0]
                    temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                        data, g.vs{1}, xs(1), xs(2), g.vs{4});
                    x1_g2D = g.vs{1};
                    x2_g2D = g.vs{4};
                else            % dims = [0 1 0 1]
                    temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                        data, g.vs{1}, xs(1), g.vs{3}, xs(2));
                    x1_g2D = g.vs{1};
                    x2_g2D = g.vs{3};
                end
            else                % dims = [0 0 1 1]
                temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, ...
                    data, g.vs{1}, g.vs{2}, xs(1), xs(2));
                x1_g2D = g.vs{1};
                x2_g2D = g.vs{2};
            end
            
            data2D = squeeze(temp);
            data2D = interpn(x1_g2D, x2_g2D, data2D, g2D.xs{1}, g2D.xs{2});
            
        case 3
            if sum(dims) ~= 1, error('Must project onto two dimensions!'); end
            
            if dims(1)          % dims = [1 0 0]
                temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, ...
                    data, xs, g.vs{2}, g.vs{3});
                x1_g2D = g.vs{2};
                x2_g2D = g.vs{3};
            elseif dims(2)      % dims = [0 1 0]
                temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, ...
                    data, g.vs{1}, xs, g.vs{3});
                x1_g2D = g.vs{1};
                x2_g2D = g.vs{3};
            else                % dims = [0 0 1]
                temp = interpn(g.vs{1}, g.vs{2}, g.vs{3}, ...
                    data, g.vs{1}, g.vs{2}, xs);
                x1_g2D = g.vs{1};
                x2_g2D = g.vs{2};
            end
            
            data2D = squeeze(temp);
            data2D = interpn(x1_g2D, x2_g2D, data2D, g2D.xs{1}, g2D.xs{2});  
    end
    
else
    data2D = [];
end
end