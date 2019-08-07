classdef DoubleIntMult < DynSys
  % Double integrator class; subclass of DynSys (dynamical system)
  properties
    uMin    % Control bounds
    uMax
    dMin
    dMax
    dims    % Active dimensions
    TIdim
    k
  end % end properties
  
  methods
    function obj = DoubleIntMult(x, urange, drange, k, dims, TIdim)
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
        urange = [-3 3];
      end
      
      if nargin <3
          drange = [0 0];
      end
      
      if nargin < 4
          k = 1;
      end
      
      if nargin <5
        dims = 1:2;
      end
      
      if nargin < 6
        TIdim = [];
      end
      
      %% Basic properties for bookkeepping
      obj.pdim = find(dims == 1);
      obj.vdim = find(dims == 2);
      obj.nx = length(dims);
      obj.nu = 1;
      obj.nd = 1;
      
      %% Process input
      % Make sure initial state is 2D
      if numel(x) ~= 2
        error('DoubleInt state must be 2D.')
      end
      
      % Make sure initial state is a column vector
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = x; % State history (only used for simulation)
      
      %% Process control range
      if numel(urange) ~= 2
        error('Control range must be 2D!')
      end
      
      if urange(2) <= urange(1)
        error('Control range vector must be strictly ascending!')
      end
      
      obj.uMin = urange(1);
      obj.uMax = urange(2);
      obj.dMin = drange(1);
      obj.dMax = drange(2);
      obj.k = k;
      obj.dims = dims;
      obj.TIdim = TIdim;
    end % end constructor
  end % end methods
end % end class