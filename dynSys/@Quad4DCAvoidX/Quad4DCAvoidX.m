classdef Quad4DCAvoidX < DynSys
  
  properties
    aMax
    bMax
    
  end
  
  methods
    function obj = Quad4DCAvoidX(x, aMax, bMax)
      % obj = Quad4DCAvoid(x, aMax, bMax)
      %     [1 2] or [3 4] component of Quad4DAvoid
      %     aMax: x- or y-acceleration bound for vehicle A
      %     bMax: x- or y-acceleration bounds for vehicle B
      %
      % Dynamics:
      %     \dot{x}_1 = x_2
      %     \dot{x}_2 = uB - uA
      %       |uA| <= aMax
      %       |uB| <= bMax
      
      obj.pdim = 1;
      obj.vdim = 2;
      obj.nx = 2;
      obj.nu = 1;
      obj.nd = 1;
      
      if numel(x) ~= obj.nx
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.aMax = aMax;
      obj.bMax = bMax;
    end
  end
end