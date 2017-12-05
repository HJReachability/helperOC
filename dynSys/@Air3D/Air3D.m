classdef Air3D < DynSys
  properties
    % Control bounds
    uMax    
    dMax
    
    % Vehicle speeds
    va
    vb

  end % end properties
 
  methods
    function obj = Air3D(x, uMax, dMax, va, vb)
      % obj = Air3D(x, aMax, bMax, va, vb)
      %
      
      %% Process initial state
      obj.x = x;
      obj.xhist = x;
  
      %% Process control range
      if nargin < 2
        uMax = 1;
        dMax = 1;
      end
      
      obj.uMax = uMax;
      obj.dMax = dMax;
      
      %% Process speeds
      if nargin < 4
        va = 5;
        vb = 5;
      end
      
      obj.va = va;
      obj.vb = vb;
      
      obj.nx = 3;
      obj.nu = 1;
      obj.nd = 1;
      
    end % end constructor
  end % end methods
end % end class