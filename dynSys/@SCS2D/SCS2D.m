classdef SCS2D < DynSys
    %example for "self-contained subsystems" that's 2D (which in 2D means
    %only coupled through control)
    %Sylvia Herbert (06-25-18)
    
  properties
    %control bounds
    uMin
    uMax
    
    % Disturbance
    dMax
    
    % Dimensions that are active
    dims
  end
  
  methods
    function obj = SCS2D(x, uMin, uMax, dMax, dims)
      % obj = SCS2D(x, wMax, speed, dMax, dims)
      %     Self Contained Subsystems 2D class
      %
      % Dynamics:
      %    \dot{x}_1 = x_1*u + d1
      %    \dot{x}_2 = u + d2
      %         u \in [uMin, uMax]
      %         d \in [-dMax, dMax]
      %
      % Inputs:
      %   x      - state: [xpos; ypos]
      %   uMin   - minimum control
      %   uMax   - maximum control
      %   dMax   - disturbance bounds
      %
      % Output:
      %   obj       - a SCS2D object
      
      if numel(x) ~= obj.nx
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      if nargin < 2
        uMin = -2;
      end
      
      if nargin < 3
        uMax = 2;
      end
      
      if nargin < 4
        dMax = [0; 0];
      end
      
      if nargin < 5
        dims = 1:2;
      end
      
      % Basic vehicle properties
      obj.pdim = [find(dims == 1) find(dims == 2)]; % Position dimensions
      %obj.hdim = find(dims == 3);   % Heading dimensions
      obj.nx = length(dims);
      obj.nu = 1;
      obj.nd = 2;
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.uMin = uMin;
      obj.uMax = uMax;
      obj.dMax = dMax;
      obj.dims = dims;
    end
    
  end % end methods
end % end classdef
