classdef Quad4DCAvoid < DynSys
  
  properties
    aMax
    bMax
    dxMax
    dyMax
    dims % dimensions that are active
    
  end
  
  methods
    function obj = Quad4DCAvoid(x, aMax, bMax, dxMax, dyMax, dims)
      % obj = Quad4DCAvoid(x, aMax, bMax)
      %     aMax: x- and y-acceleration bound for vehicle A
      %     bMax: x- and y-acceleration bounds for vehicle B
      %
      % Dynamics:
      %     \dot{x}_1 = x_2 + dx
      %     \dot{x}_2 = uB(1) - uA(1)
      %     \dot{x}_3 = x_4 + dy
      %     \dot{x}_4 = uB(2) - uA(2)
      %       |uA(i)| <= aMax(i)
      %       |uB(i)| <= bMax(i), i = 1,2
      
      if ~iscolumn(x)
        x = x';
      end      
      
      if nargin < 4
        dxMax = 0;
        dyMax = 0;
      end
      
      if nargin < 5
        dims = [1 2 3 4];
      end
      
      obj.pdim = [find(dims == 1) find(dims == 3)]; % Position dimensions
      obj.vdim = [find(dims == 2) find(dims == 4)]; % Velocity dimensions

      obj.nu = 2;
      obj.nd = 4;
      obj.dims = dims;
      obj.nx = length(dims);
      
      if numel(x) ~= obj.nx
        error('Initial state does not have right dimension!');
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.aMax = aMax;
      obj.bMax = bMax;
      obj.dxMax = dxMax;
      obj.dyMax = dyMax;
    end
  end
end