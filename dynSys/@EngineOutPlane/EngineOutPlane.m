classdef EngineOutPlane < DynSys
  properties
    g = 9.81 % Acceleration due to gravity
    m        % mass
    S        % Surface area
    rho      % Air density
  end
  
  methods
    function obj = EngineOutPlane(x)
      % obj = plane(ID, x, reachInfo)
      %
      % Constructor. Creates a plane object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{x}_1 = v_x = x_4 * cos(x_3)
      %    \dot{x}_2 = v_y = x_4 * sin(x_3)
      %    \dot{x}_3 = u_1 = u_1
      %    \dot{x}_4 = u_2 = u_2
      %         uMin <= u <= uMax
      %
      % Inputs:   ID        - unique ID of the plane
      %           x         - state: [xpos; ypos; theta; v]
      %           reachInfo - reachable set information
      %                    .uMax, .uMin - max and min angular velocity
      %                    .vMax - max speed (positive)
      %
      % Output:   obj       - a quadrotor object
      %
      % Mahesh Vashishtha, 2015-12-3
      
      if numel(x) ~= 4
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.pdim = 1:3;
      obj.vdim = 4;
      
      obj.nx = 6;
      obj.nu = 2;
    end
  end % end methods
end % end classdef
