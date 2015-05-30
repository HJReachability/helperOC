function p = calculateCostate(g, P, x, periodicDim)
% function p = calculateCostate(g, P, x, periodicDim)
%
% g      -- grid
% P      -- gridded costates. P{i} is the derivative in the ith component
% x      -- each row is one point x to evaluate costate at
%
%
% Calculates the costate at position x by interpolating using the gridded
% costates given in P
%
% Periodic dimensions are specified in periodicDim
%
 

p = zeros(size(x,1), g.dim);

switch g.dim
    case 1
        if nargin<4, periodicDim = 0; end
        
        % Dealing with periodicity
        if periodicDim
            g.vs{1} = cat(1, g.vs{1}, g.vs{1}(end)+g.dx(1));
            P{1} = cat(1, P{1}, P{1}(1));
        end
        
        % Interpolate
        p(:,1) = interpn(g.vs{1}, P{1}, x(:,1));
    case 2 
        if nargin<4, periodicDim = [0 0]; end
        
        % Dealing with periodicity
        for i = 1:2
            if periodicDim(i)
                g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
            end
        end
        
        if periodicDim(1), P{1} = cat(1, P{1}, P{1}(1,:)); end
        if periodicDim(2), P{2} = cat(2, P{2}, P{2}(:,1)); end       
%QH         if periodicDim(2), P{2} = cat(1, P{2}, P{2}(:,1)); end       
        
        % Interpolate
        for i = 1:2
            p(:,i) = interpn(g.vs{1}, g.vs{2}, P{i}, x(:,1), x(:,2)); 
        end
    case 3
        if nargin<4, periodicDim = [0 0 0]; end
        
        % Dealing with periodicity
        for i = 1:3
            if periodicDim(i)
                g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
            end
        end
        
        if periodicDim(1), P{1} = cat(1, P{1}, P{1}(1,:,:)); end
        if periodicDim(2), P{2} = cat(2, P{2}, P{2}(:,1,:)); end
        if periodicDim(3), P{3} = cat(3, P{3}, P{3}(:,:,1)); end
%QH         if periodicDim(2), P{2} = cat(1, P{2}, P{2}(:,1,:)); end
%QH         if periodicDim(3), P{3} = cat(1, P{3}, P{2}(:,:,1)); end
        
        % Interpolate
        for i = 1:3
            p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, P{i}, x(:,1), x(:,2), x(:,3));
        end
    case 4
        if nargin<4, periodicDim = [0 0 0 0]; end

        % Dealing with periodicity
        for i = 1:4
            if periodicDim(i)
                g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
            end
        end
        
        if periodicDim(1), P{1} = cat(1, P{1}, P{1}(1,:,:,:)); end
        if periodicDim(2), P{2} = cat(2, P{2}, P{2}(:,1,:,:)); end
        if periodicDim(3), P{3} = cat(3, P{3}, P{3}(:,:,1,:)); end
        if periodicDim(4), P{4} = cat(4, P{4}, P{4}(:,:,:,1)); end
       
        % Interpolate
        for i = 1:4
            p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, P{i}, x(:,1), x(:,2), x(:,3), x(:,4)); 
        end
    case 6
        if nargin<4, periodicDim = [0 0 0 0 0 0]; end

        % Dealing with periodicity
        for i = 1:g.dim
            if periodicDim(i)
                g.vs{i} = cat(1, g.vs{i}, g.vs{i}(end) + g.dx(i));
            end
        end
        
        if periodicDim(1), P{1} = cat(1, P{1}, P{1}(1,:,:,:,:,:)); end
        if periodicDim(2), P{2} = cat(2, P{2}, P{2}(:,1,:,:,:,:)); end
        if periodicDim(3), P{3} = cat(3, P{3}, P{3}(:,:,1,:,:,:)); end
        if periodicDim(4), P{4} = cat(4, P{4}, P{4}(:,:,:,1,:,:)); end
        if periodicDim(5), P{5} = cat(5, P{5}, P{5}(:,:,:,:,1,:)); end
        if periodicDim(6), P{6} = cat(6, P{6}, P{6}(:,:,:,:,:,1)); end
       
        % Interpolate
        for i = 1:g.dim
            p(:,i) = interpn(g.vs{1}, g.vs{2}, g.vs{3}, g.vs{4}, g.vs{5}, g.vs{6}, P{i}, ...
                x(:,1), x(:,2), x(:,3), x(:,4), x(:,5), x(:,6)); 
        end
        
    otherwise
        error('calculateCostate has not been implemented for this number of dimensions!')
end

end