classdef KinVehicleND < DynSys
  properties
    vMax
  end
  
  methods
    function obj = KinVehicleND(x, vMax)
      % obj = KinVehicleND(x, vMax)
      %
      % Dynamics: (2D example)
      %    \dot{x}_1 = v_x
      %    \dot{x}_2 = v_y
      %         v_x^2 + v_y^2 <= vMax^2
      
      %% State could be of any number of dimensions
      if ~iscolumn(x)
        x = x';
      end
      
      obj.nx = length(x);
      obj.nu = obj.nx;
      
      %% Velocity
      if nargin < 2
        vMax = 1;
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.vMax = vMax;
    end
    
  end % end methods
end % end classdef
