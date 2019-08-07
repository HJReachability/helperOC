classdef Example1D < DynSys
  properties
    % Bound for speed in x
    uMin
    uMax
    
    % Bound for speed in y
    dMin
    dMax
    
  end
  
  methods
    function obj = Example1D(x, uMin, uMax, dMin, dMax)
      % obj = Example1D(x, uMin, uMax, dMin, dMax)
      %
      % Constructor. Creates a 1D object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{x}_1 = u + d
      %         u \in [uMin, uMax]
      %         d \in [dMin, dMax]
      %
      % Inputs:
      %   x     - state: [xpos; ypos]
      %   uMin  - minimum control
      %   uMax  - maximum control
      %   dMin  - minimum disturbance
      %   dMax  - maximum disturbance
      %
      % Output:
      %   obj       - an Example1D object
      %
      
      if numel(x) ~= 1
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.uMin = uMin;
      obj.uMax = uMax;
      obj.dMin = dMin;
      obj.dMax = dMax;
      
      obj.pdim = 1;
      
      obj.nx = 1;
      obj.nu = 1;
      obj.nd = 1;
    end
    
  end % end methods
end % end classdef
