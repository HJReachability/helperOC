function dataNew = migrateGrid(gOld, dataOld, gNew)
% function dataNew = migrateGrid(gOld, dataOld, gNew)
%    Transfers dataOld onto a from the grid gOld to the grid gNew
%
% Inputs: gOld, gNew - old and new grid structures
%         dataOld    - data corresponding to old grid structure
%
% Output: dataNew    - equivalent data corresponding to new grid structure

% Gather indices of new grid vectors that are within the bounds of the old
% grid
vinds = cell(gOld.dim,1);
for i = 1:gOld.dim
    vinds{i} = logical(gNew.vs{i}>=gOld.min(i) & gNew.vs{i}<=gOld.max(i));
end

% Set value of new data to the maximum of old data
dataMax = max(dataOld(:));
dataNew = dataMax * ones(gNew.N');

% Interpolate to obtain new data from old data in the range of axis values
% that are within the bounds of the old grid
switch gOld.dim
    case 1
        dataNew(vinds{1}) = ...
            interpn(gOld.vs{1}, dataOld, ...
            gNew.xs{1}(vinds{1}) );
    case 2
        dataNew(vinds{1}, vinds{2}) = ...
            interpn(gOld.vs{1}, gOld.vs{2}, dataOld, ...
            gNew.xs{1}(vinds{1}, vinds{2}), ...
            gNew.xs{2}(vinds{1}, vinds{2}) );
    case 3
        dataNew(vinds{1}, vinds{2}, vinds{3}) = ...
            interpn(gOld.vs{1}, gOld.vs{2}, gOld.vs{3}, dataOld, ...
            gNew.xs{1}(vinds{1}, vinds{2}, vinds{3}), ...
            gNew.xs{2}(vinds{1}, vinds{2}, vinds{3}), ...
            gNew.xs{3}(vinds{1}, vinds{2}, vinds{3}));
    case 4
        dataNew(vinds{1}, vinds{2}, vinds{3}, vinds{4}) = ...
            interpn(gOld.vs{1}, gOld.vs{2}, gOld.vs{3}, gOld.vs{4}, dataOld, ...
            gNew.xs{1}(vinds{1}, vinds{2}, vinds{3}, vinds{4}), ...
            gNew.xs{2}(vinds{1}, vinds{2}, vinds{3}, vinds{4}), ...
            gNew.xs{3}(vinds{1}, vinds{2}, vinds{3}, vinds{4}), ...
            gNew.xs{4}(vinds{1}, vinds{2}, vinds{3}, vinds{4}) );
    otherwise
        error('migrateGrid has only been implemented up to 4 dimensions!')
end


end