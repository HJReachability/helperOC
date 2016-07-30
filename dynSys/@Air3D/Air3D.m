classdef Air3D < DynSys
  properties
    % Control bounds
    aMax    
    bMax
    
    % Vehicle speeds
    va
    vb

  end % end properties
 
  methods
    function obj = Air3D(x, aMax, bMax, va, vb)
      % obj = Air3D(x, aMax, bMax, va, vb)
      %
      
      %% Process initial state
      obj.x = x;
      obj.xhist = x;
  
      %% Process control range
      if nargin < 2
        aMax = 1;
        bMax = 1;
      end
      
      obj.aMax = aMax;
      obj.bMax = bMax;
      
      %% Process speeds
      if nargin < 4
        va = 5;
        vb = 5;
      end
      
      obj.va = va;
      obj.vb = vb;
      
    end % end constructor
  end % end methods
end % end class