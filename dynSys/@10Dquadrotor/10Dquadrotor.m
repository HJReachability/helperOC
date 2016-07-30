classdef 10Dquadrotor < handle
% ----------
% UNUSED 
% ----------
% This was supposed to be for the 10D quadrotor model

    properties
        ID          % ID number (global, unique)
 
        nx = 10     % Dimension of state
        nu = 3      % Dimension of control
        
        pdim = [1 5 9];
        vdim = [2 6 10];
        
        uMin        % Control bounds
        uMax
        
        KT          % Thrust coefficient (vertical direction)
        m           % Mass (unused right now)
        
        A           % Dynamics
        B
        G           % Gravitational term
        
        n0          % Angular dynamics parameters
        d1
        d0
        
        g           % Acceleration due to gravity (for convenience)
        
    end
    
    methods
        function obj = vehicle(ID, dt, safeV)
            % Constructor
            
            % Preliminary
            obj.ID = ID;
            obj.dt = dt;
            obj.q = 'Free';
            
            % Constants
            %   The choices of n0, d1, d0 actually results in a very large
            %   steady state error in the pitch/roll; this seems to be
            %   expected according to Pat's report
            obj.g = 9.81;
            obj.n0 = 40;
            obj.d1 = 8;
            obj.d0 = 80;
%             obj.d0 = 40;
            obj.KT = 0.91; % QH changed from KT=1
            obj.m = 1.3;
            obj.umax = [10/180*pi; 10/180*pi; 2*obj.g];
            obj.umin = [-10/180*pi; -10/180*pi; 0];
            
            % A matrix
            A1 = [0 1 0 0; 0 0 obj.g 0; 0 0 0 1; 0 0 -obj.d0 -obj.d1];
            A2 = [0 1 0 0; 0 0 obj.g 0; 0 0 0 1; 0 0 -obj.d0 -obj.d1];
            A3 = [0 1; 0 0];
            obj.A = blkdiag(A1, A2, A3);
            
            % B matrix
            B1 = [0; 0; 0; obj.n0];
            B2 = [0; 0; 0; obj.n0];
            B3 = [0; obj.KT];
            obj.B = blkdiag(B1, B2, B3);
            
            % Dimensions
            [obj.nx, obj.nu] = size(obj.B);
            
            % Gravity term in dynamics
            obj.G = [zeros(obj.nx-1, 1); -obj.g];
            
            % Initial state
            obj.x = zeros(obj.nx, 1);
            obj.x(9) = 10;
            obj.xhist = obj.x;
            
            % Initial control
            obj.u = zeros(obj.nu, 0);
            obj.uhist = obj.u;
            
            % Reachable set
            obj.safeV = safeV;
        end

        
        function u = join(platoon)
            % join together from two different highways/lanes/routes
            
            % check if vehicle is a leader / only leaders can join another
            % platoon
            
            %
            
        end
        
        function u = joinslashmerge()
            % close the following distance with vehicles in the same route
        end
        
        function u = split(highway)
            % Split from group and move onto highway
        end
        
    end
end