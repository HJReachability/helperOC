classdef Quadrotor < Vehicle
  % Note: Since quadrotor is a "handle class", we can pass on
  % handles/pointers to other quadrotor objects
  % e.g. a.platoon.leader = b (passes b by reference, does not create a copy)
  % Also see constructor
  
  properties
    uMin = -3    % Control bounds
    uMax = 3
    
    vMax = 5       % Speed bounds
    vMin = -5
    
    % Waypoints to follow; 
    % Warning 1: For now this only comes up in getToPose, but eventually,
    % it may be a good idea to always use this.
    % Warning 2: Right now it's always a linear function; however, ideally
    % it should just be a few points
    waypoints = [] 
    
  end % end properties
  
  properties(Constant)
    % Dimensions of state and control
    nx = 4;
    nu = 2;
    
    % A and B matrices
    A = [0 1 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0];
    B = [0 0; 1 0; 0 0; 0 1];
    
    % Indices of position and velocity variables
    pdim = [1 3];
    vdim = [2 4];
  end % end properties(Constant)
  
  methods
    function obj = Quadrotor(x)
      % obj = quadrotor(x)
      %
      % Constructor. Creates a quadrotor object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{p}_x = v_x
      %    \dot{v}_x = u_x
      %    \dot{p}_y = v_y
      %    \dot{v}_y = u_y
      %       uMin <= u_x <= uMax
      %
      % Inputs:   x   - state: [xpos; xvel; ypos; yvel]
      % Output:   obj - a quadrotor object
      %
      % Mo Chen, Qie Hu, 2015-05-22
      % Modified by Mo Chen, 2015-07-06
      % Modified by Mo Chen, 2015-11-03
      
      % Make sure initial state is 4D
      if numel(x) ~= 4
        error('Quadrotor state must be 4D.')
      end

      % Make sure initial state is a column vector
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = x;
      
    end % end constructor
    function valid = isvalidcontrol(obj,u) 
        valid = and([obj.uMin; obj.uMin] <= u,u <= [obj.uMax; obj.uMax]);
    end
  end % end methods
end % end class