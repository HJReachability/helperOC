classdef Q6D_Q3D_Rel < DynSys
  properties
    uMin        % Control bounds (3x1 vector)
    uMax
    
    dMin
    dMax
    
    pMin
    pMax
    
    % Constants
    grav = 9.81    % Acceleration due to gravity (for convenience)
    
    % active dimensions
    dims
  end
  
  methods
    function obj = Q6D_Q3D_Rel(x, uMin, uMax, dMin, dMax, pMin, pMax, dims)
        % obj = Q6D_Q3D_Rel(x, uMin, uMax, dMin, dMax, pMin, pMax, dims)
        %     Constructor for a 10D quadrotor
        %
%     Dynamics of the 6D Quadrotor
%         \dot x_1 = x_4 - d(1) - d(2) 
%         \dot x_2 = x_5 - d(3) - d(4)
%         \dot x_3 = x_6 - d(5) - d(6)
%         \dot x_4 = g * tan(u(1))
%         \dot x_5 = - g * tan(u(2))
%         \dot x_6 = u(3) - g
%         min (radians)      <=     [u(1); u(2)]   <= max (radians)
%         min thrust (m/s^2) <=         u(3)       <= max thrust (m/s^2)
%         dist vmin (m/s)    <= [d(1); d(3); d(5)] <= dist vmax (m/s)
%         dist amin (m/s^2)  <= [d(7); d(8); d(9)] <= dist amax (m/s^2)
%         planner vmin (m/s) <= [d(2); d(4); d(6)] <= planner vmax (m/s)

        if nargin < 1
            x = zeros(obj.nx, 1);
        end
        
        if nargin < 2
            angleMax = deg2rad(15);
            uMin = [-angleMax; -angleMax; 4];
            uMax = [angleMax; angleMax; 16];
        end
        
        if nargin < 4
            dMin = zeros(1,6);
            dMax = zeros(1,6);
        end
        
        if nargin < 6
            pMin = -.5*ones(1,3);
            pMax = .5*ones(1,3);
        end
        
        if nargin < 8
            dims = 1:6;
        end
        
        obj.x = x;
        obj.xhist = x;
        
        obj.uMax = uMax;
        obj.uMin = uMin;
        obj.dMax = dMax;
        obj.dMin = dMin;
        obj.pMax = pMax;
        obj.pMin = pMin;
        
        obj.dims = dims;
        obj.nx = length(dims);
        obj.nu = 3;
        obj.nd = 9;
        obj.pdim = [1 3 5];
        obj.vdim = [2 4 6];
    end
  end
end