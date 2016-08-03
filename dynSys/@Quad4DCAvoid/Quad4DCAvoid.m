classdef Quad4DCAvoid < DynSys
  
  properties
    aMax
    bMax
    
  end
  
  methods
    function obj = Quad4DCAvoid(x, aMax, bMax)
      % obj = Quad4DCAvoid(x, aMax, bMax)
      %     aMax: x- and y-acceleration bound for vehicle A
      %     bMax: x- and y-acceleration bounds for vehicle B
      %
      % Dynamics:
      %     \dot{x}_1 = x_2
      %     \dot{x}_2 = uB(1) - uA(1)
      %     \dot{x}_3 = x_4
      %     \dot{x}_4 = uB(2) - uA(2)
      %       |uA(i)| <= aMax(i)
      %       |uB(i)| <= bMax(i), i = 1,2
      
      obj.pdim = [1 3];
      obj.vdim = [2 4];
      obj.nx = 4;
      obj.nu = 2;
      obj.nd = 2;
      
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