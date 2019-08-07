classdef TripleInt < DynSys
  % Double integrator class; subclass of DynSys (dynamical system)
  properties
    uMin    % Control bounds
    uMax
    dims    % Active dimensions
  end % end properties
  
  methods
    function obj = TripleInt(x, uMin, uMax, dims)
      % DoubleInt(x, urange)
      %     Constructor for the double integrator
      %
      % Inputs:
      %     x - initial state (ignored in reachability computations; only used
      %         for simulation)
      %     urange - control bounds
      %     dims - active dimensions
      
      if nargin < 1
        x = [0; 0];
      end
      
      if nargin < 2
        uMin = -3;
      end
      
      if nargin < 3
          uMax = 3;
      end
      
      if nargin <4
        dims = 1:3;
      end
      
      %% Basic properties for bookkeepping
      obj.pdim = find(dims == 1);
      obj.vdim = find(dims == 2);
      obj.nx = length(dims);
      obj.nu = 1;
      
      %% Process input
      % Make sure initial state is 3D
      if numel(x) ~= 3
        error('TripleInt state must be 3D.')
      end
      
      % Make sure initial state is a column vector
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = x; % State history (only used for simulation)
      
      %% Process control range
      
      obj.uMin = uMin;
      obj.uMax = uMax;
      obj.dims = dims;
    end % end constructor
  end % end methods
end % end class