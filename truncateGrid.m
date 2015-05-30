function [gNew, dataNew] = truncateGrid(gOld, dataOld, xmin, xmax)
% function dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%
% Output: dataNew    - equivalent data corresponding to new grid structure

% Gather indices of new grid vectors that are within the bounds of the old
% grid

gNew.dim = gOld.dim;
gNew.xs = cell(gNew.dim, 1);

% Truncate everything that's outside of xmin and xmax
switch gOld.dim
    case 1
        % Grid
        if ~isempty(gOld)
            gNew.xs{1} = gOld.xs{1}(gOld.vs{1}>xmin & gOld.vs{1}<xmax);
        else
            gNew = [];
        end
        
        % Data
        if ~isempty(dataOld)
            dataNew = dataOld(gOld.vs{1}>xmin & gOld.vs{1}<xmax);
        else
            dataNew = [];
        end
    case 2
        % Grid
        if ~isempty(gOld)
            for i = 1:gNew.dim
                gNew.xs{i} = ...
                    gOld.xs{i}(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                    gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2) );
            end
        else
            gNew = [];
        end
        
        % Data
        if ~isempty(dataOld)
            dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2));
        else
            dataNew = [];
        end
    case 3
        % Grid
        if ~isempty(gOld)
            for i = 1:gNew.dim
                gNew.xs{i} = ...
                    gOld.xs{i}(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                    gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
                    gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3) );
            end
        else
            gNew = [];
        end
        
        % Data
        if ~isempty(dataOld)
            dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
                gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3) );
        else
            dataNew = [];
        end
    case 4
        % Grid
        if ~isempty(gOld)
            for i = 1:gNew.dim
                gNew.xs{i} = ...
                    gOld.xs{i}(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                    gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
                    gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3), ...
                    gOld.vs{4}>xmin(4) & gOld.vs{4}<xmax(4) );
            end
        else
            gNew = [];
        end
        
        % Data
        if ~isempty(dataOld)
            dataNew = dataOld(gOld.vs{1}>xmin(1) & gOld.vs{1}<xmax(1), ...
                gOld.vs{2}>xmin(2) & gOld.vs{2}<xmax(2), ...
                gOld.vs{3}>xmin(3) & gOld.vs{3}<xmax(3), ...
                gOld.vs{4}>xmin(4) & gOld.vs{4}<xmax(4) );
        else
            dataNew = [];
        end
    otherwise
        error('migrateGrid has only been implemented up to 4 dimensions!')
end

gNew.N = size(gNew.xs{1})';

end