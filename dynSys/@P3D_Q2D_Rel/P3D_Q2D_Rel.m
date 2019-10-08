classdef P3D_Q2D_Rel < DynSys
  properties
    % Control bounds
    uMin
    uMax
    
    % Planner bounds
    pMin
    pMax
    
    %Disturbance bounds
    dMin
    dMax
    
    % Tracker speed
    v
    
    % active dimensions
    dims
  end
  
  methods
    function obj = P3D_Q2D_Rel(x, uMin, uMax, pMin, pMax, dMin, dMax, v, dims)
      % obj = P3D_Q2D_Rel(x, uMin, uMax, pMin, pMax, dMin, dMax, dims)
      %     Constructor for a 3D plane relative to a 2D quadrotor
      %
      % Dynamics:
      %     \dot x_1 = v*cos(x_3)  + d{1}  - d{2}
      %     \dot x_2 = v*sin(x_3)  + d{3}  - d{4}               
      %     \dot x_3 = u{1}
      %         uMin <= u <= uMax
      
      % u       <- control of 3D plane (tracker)
      % d{2,4}  <- control of 2D quadrotor (planner)
      % d{1,3}  <- disturbance
      
      if nargin < 1 || isempty(x)
        x = zeros(obj.nx, 1);
      end
      
      if ~iscolumn(x)
        x = x';
      end      
      
      if nargin < 2
        uMin = -1;        
        uMax = 1;
      end
      
      if nargin < 4
        pMin = [-1; -1];
        pMax = [1; 1];
      end
      
      if nargin < 6
        dMax = [0.1; 0.1];
        dMin = [-0.1; -0.1];
      end
      
      if nargin < 8
        v = 5;
      end
      
      if nargin < 9
        dims = 1:3;
      end
      
      obj.x = x;
      obj.xhist = x;
      
      obj.uMin = uMin;
      obj.uMax = uMax;

      obj.pMin = pMin;
      obj.pMax = pMax;      
      
      obj.dMin = dMin;
      obj.dMax = dMax;
      
      obj.v = v;
      
      obj.dims = dims;
      obj.nx = length(dims);
      
      obj.nu = 1;
      obj.nd = 4;
      
      obj.pdim = [find(dims == 1) find(dims == 2)]; % Position dimensions
      obj.vdim = [find(dims == 3)]; % angle dimensions
    end
  end
end