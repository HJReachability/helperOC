classdef InvertedPendulum < DynSys
  properties
    uMin
    uMax
    l
    m
    g
    b
    

  end
  
  methods
    function obj = InvertedPendulum(x, params)
      
      if numel(x) ~= 2
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.uMin = params.u_min;
      obj.uMax = params.u_max;
      
      obj.pdim = 1;
      
      obj.nx = 2;
      obj.nu = 1;
      
      obj.l = params.l;    % [m]        length of pendulum
      obj.m = params.m;    % [kg]       mass of pendulum
      obj.g = params.g; % [m/s^2]    acceleration of gravity
      obj.b = params.b; % [s*Nm/rad] friction coefficient
    end
    
  end % end methods
end % end classdef
