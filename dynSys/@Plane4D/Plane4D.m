classdef Plane4D < DynSys
  properties
    % Angular control bounds (only applicable if using TFM)
    wMin = -2*pi/10
    wMax = 2*pi/10
    
    % acceleration control bounds (only applicable if using TFM)
    aMax = 3
    aMin = -3
  end
  
  methods
    function obj = Plane4D(x)
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
      
      obj.pdim = 1:2;
      obj.hdim = 3;
      obj.vdim = 4;
      
      obj.nx = 4;
      obj.nu = 2;
    end
    
    % given that control is right dimension and is numeric, 
    % check that it is a valid vector
    function valid = isvalidcontrol(obj,u) 
        valid = and([obj.wMin; obj.aMin] <= u,u <= [obj.wMax; obj.aMax]);
    end
    
    %%
    function collided = isCollided(obj, others, radius)
      % function collided = isCollided(obj, others,radius)
      % Check if any other Plane4s are within distance "radius" of this
      % plane
      %
      % Inputs:   obj - current Plane4s object
      %           others - other Plane4s whose positions should be checked
      %                    for collision; this should be a n x 1 or 1 x n
      %                    cell. All vehicles need to be of the same type
      %                    so that a single safeV can be used
      %           radius - positive number. iff distance between one 
      %                    of the Plane4's and this Plane4 is
      %                    <= radius, a collision has occured
      %
      %
      % Outputs:  collided - true iff distance between obj and any Plane4 
      %                      in  others is <= radius
      %
      % Mahesh Vashishtha, 2015-12-3
      others = checkVehiclesList(others, 'Plane4');
      relStates = obj.getRelativeStates(others);
      relPos = relStates(:,1:2);
      collided = false;
      for i = 1:length(others)
        collided = or(all(abs(relPos(i,1:2)) <= [radius radius]), collided);
      end
    end

  end % end methods
end % end classdef
