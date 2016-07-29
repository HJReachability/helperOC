classdef DoubleInt < DynSys
  properties
    uMin    % Control bounds
    uMax

  end % end properties
 
  methods
    function obj = DoubleInt(x, urange)
      %% Basic properties
      obj.pdim = 1;
      obj.vdim = 2;
      obj.nx = 2;
      obj.nu = 1;
    
      %% Process input
      if nargin < 1
        x = [0; 0];
      end
      
      % Make sure initial state is 2D
      if numel(x) ~= 2
        error('DoubleInt state must be 2D.')
      end

      % Make sure initial state is a column vector
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = x;
  
      %% Process control range
      if nargin < 2
        urange = [-3 3];
      end
      
      if numel(urange) ~= 2
        error('Control range must be 2D!')
      end
      
      if urange(2) <= urange(1)
        error('Control range vector must be strictly ascending!')
      end
      
      obj.uMin = urange(1);
      obj.uMax = urange(2);
      
    end % end constructor
  end % end methods
end % end class