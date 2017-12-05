classdef Plane4D < DynSys
  properties
    % Angular control bounds
    wMax
    
    % Acceleration control bounds
    aRange
    
    % Disturbance bounds
    dMax
    
    % Active dimensions
    dims
  end
  
  methods
    function obj = Plane4D(x, wMax, aRange, dMax, dims)
      % obj = Plane4D(x, wMax, aRange, dMax)
      %     Dynamics of the Plane4D
      %         \dot{x}_1 = x_4 * cos(x_3) + d_1
      %         \dot{x}_2 = x_4 * sin(x_3) + d_2
      %         \dot{x}_3 = u_1 = w
      %         \dot{x}_4 = u_2 = a
      %           wMin <= w <= wMax
      %           aMin <= a <= aMax
      
      if nargin < 4
        dMax = [0; 0];
      end
      
      if nargin < 5
        dims = 1:4;
      end
      
      if numel(x) ~= 4
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.dims = dims;
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.wMax = wMax;
      obj.aRange = aRange;
      obj.dMax = dMax;
      
      obj.pdim = 1:2;
      obj.hdim = 3;
      obj.vdim = 4;
      
      obj.nx = length(dims);
      obj.nu = 2;
      obj.nd = 2;
    end
  end % end methods
end % end classdef
