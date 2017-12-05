classdef PlanePursue2DKV < DynSys
  % PlanePursue2DKV: Dynamics of a plane pursuing a 2D kinematics vehicle
  properties
    %% Plane parameters
    % Angular control bounds
    wMaxA
    
    % Speed control bounds
    vRangeA
    
    % Disturbance
    dMaxA
    
    %% 2D Kinematic vehicle parameters
    vMaxB
  end
  
  methods
    function obj = PlanePursue2DKV(x, wMaxA, vRangeA, dMaxA, vMaxB)
      % obj = PlanePursue2DKV(x, plane, KinVeh2D)
      %
      % Constructor. Creates the dynamical system object with state x and
      % parameters from the input input objects
      %
      % Dynamics:
      %    \dot{x}_1 = v * cos(x_3) + d1 - v1
      %    \dot{x}_2 = v * sin(x_3) + d2 - v2
      %    \dot{x}_3 = u            + d3
      %         v \in [vrange(1), vrange(2)]
      %         u \in [-wMax, wMax]
      %         (v1, v2) \in vMax-ball
      %
      % Inputs:
      %   x        - state: [x error; y error; theta]
      %   wMax     - maximum turn rate
      %   vrange   - speed range
      %   dMax     - disturbance bounds
      %   (v1, v2) - velocity of kinematic vehicle
      %
      % Output:
      %   obj       - a PlanePursue2DKV object
      
      if numel(x) ~= 3
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.wMaxA = wMaxA;
      obj.vRangeA = vRangeA;
      obj.dMaxA = dMaxA;
      obj.vMaxB = vMaxB;
      
      obj.pdim = 1:2;
      obj.hdim = 3;
      
      obj.nx = 3;
      obj.nu = 2;
      obj.nd = 5;
    end
    
  end % end methods
end % end classdef
