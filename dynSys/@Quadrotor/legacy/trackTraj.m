function u = trackTraj(obj, traj, traj_t, t0, T)
% ---------
% UNUSED
% -----------
    % Track a trajectory
    % traj should be a sequence of [x;y] values with each column being a
    % time point
    %
    % Try MPC
    
    dim = size(traj, 1);
    
    % Interpolate trajectory at vehicle's sampling times
    t = t0:obj.dt:t0+T;                                     % Planning horizon
    tinds = logical(t >= min(traj_t) & t <= max(traj_t));   % Overlap with trajectory time stamps
    
    newtraj = zeros(dim, nnz(tinds));
    for i = 1:dim
        newtraj(i,:) = interpn(traj_t, traj(i,:), t(tinds));
    end
    
    tsteps = length(t);
    
    cvx_begin
        variable p(dim, tsteps)
        variable u(obj.nu, tsteps)
        variable x(obj.nx, tsteps)
        
        minimize norm(p(:,tinds) - newtraj, 'fro')
        
        subject to
            % First time step
            x(:,1) == obj.computeState(u(:,1), obj.x)   % Dynamics
            obj.umin <= u(:,1) <= obj.umax              % Control bounds
            p(:,1) == x([1 3],1)                        % Position components
            
            % All time steps afterwards
            for i = 2:tsteps
                x(:,i) == obj.computeState(u(:,i), x(:,i-1))    % Dynamics
                obj.umin <= u(:,i) <= obj.umax                  % Control bounds
                p(:,i) == x([1 3],i)                            % Position components
            end
    cvx_end
    

end