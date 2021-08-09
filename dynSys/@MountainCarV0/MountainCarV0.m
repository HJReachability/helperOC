classdef MountainCarV0 < DynSys
  properties
    gravity
    force
  end
  
  methods
    function obj = MountainCarV0(x, gravity, force)
      
      if numel(x) ~= 2
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.pdim = 1; % position dimensions
      
      obj.nx = 2; % number of state dimensions
      obj.nu = 1; % number of control dimensions
      
      obj.gravity = gravity; % gravity (default is 0.0025)
      obj.force = force; % force (default is 0.001)
      
    end
    
  end % end methods
end % end classdef
