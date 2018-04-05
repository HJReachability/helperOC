classdef Arm4D < DynSys
  properties
    dims    % Active dimensions
    l1      % Length of links
    l2      
    m1      % Mass of links
    m2     
    g       % Gravity constant
    q_min   % Joint limits
    q_max
    dq_min  % Velocity limits
    dq_max
    uMin    % Control bounds
    uMax
    alpha   % Constants for equations of motion
    beta
    delta
  end % end properties
  
  methods
    function obj = Arm4D(x, uMin, uMax, dims, l1, l2, m1, m2, grid_min, grid_max)
      % obj = Arm4D(x, uMin, uMax)
      %
      % Constructor. Creates a robot arm object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{th1} = \dot{th1}
      %    \dot{th2} = \dot{th2}
      %    [\ddot{th1},\ddot{th2}] = M(th)^{-1}(u + d - C(th,dth)*dth - N(th))
      %    uMin <= u_x <= uMax
      %
      % Inputs:   x   - state: [th2; th2; dth1; dth2]
      %           uMin - lower control bound [umin1; umin2]
      %           uMax - upper control bound [umax1; umax2]
      %           dims - number of dimentions 
      %           l1, l2 - link lengths
      %           m1, m2 - link masses
      % Output:   obj - a robot arm object
      
      % Make sure initial state is a column vector
      if ~iscolumn(x)
        x = x';
      end
      
      % Default control bounds if not provided
      if nargin < 2
        uMax = 3;
        uMin = -3;
      end
      
      % Default number of dims if not provided
      if nargin < 4
        dims = 1:4;
      end
      
      obj.x = x;
      obj.xhist = x;
      
      obj.uMax = uMax;
      obj.uMin = uMin;
      
      obj.l1 = l1;
      obj.l2 = l2;
      obj.m1 = m1;
      obj.m2 = m2;
      
      % Standard acceleration due to gravity
      obj.g = 9.81;

      % joint limits
      obj.q_min = grid_min(1:2); %[0; -pi/2];
      obj.q_max = grid_max(1:2); %[pi; pi/2];
      % veloicity limits
      obj.dq_min = grid_min(3:4); %[-20; -20];
      obj.dq_max = grid_max(3:4); %[20; 20];

      % moment of inertia for rod of length l and mass m rotating
      % about its center
      Ix1 = (m1*l1^2)/12.0;
      Ix2 = (m2*l2^2)/12.0;

      % compute constants in the matrix
      obj.alpha = Ix1 + Ix2 + m1*(l1/2.)^2 + m2*(l1^2 + (l2/2.)^2);
      obj.beta = m2*l1*(l2/2.);
      obj.delta = Ix2 + m2*(l2/2.)^2;
      
      %obj.vdim = [find(dims == 1) find(dims == 2)]; % Velocity dimensions
      %obj.adim = [find(dims == 3) find(dims == 4)]; % Acceleration dimensions
      
      obj.nu = 2;
      obj.dims = dims;
      obj.nx = length(dims);
      
      if numel(x) ~= obj.nx
        error('Initial state does not have right dimension!');
      end
      
    end % end constructor
    
    function [pos_elbow, pos_ee] = fwd_kinematics(obj, q_t1)
        % Returns the (x,y) position of elbow and end-effector
        %
        % Inputs:   q_t1        - current joint angles of robot
        % Outputs:  pos_elbow   - (x,y) position of elbow
        %           pos_ee      - (x,y) position of end-effector
        th1 = q_t1(1);
        th2 = q_t1(2);
        pos_elbow = [obj.l1*cos(th1); obj.l1*sin(th1)];
        pos_ee = [obj.l1*cos(th1) + obj.l2*cos(th1+th2); obj.l1*sin(th1) + obj.l2*sin(th1+th2)];
    end
    
    function M = get_M(obj, q_t1)
        % Computes the inertial matrix at time t for 2-link arm
        %
        % Inputs:   q_t1    - configuration of robot
        % Outputs:  M       - intertial matrix
        th2 = q_t1(2);
        M = [obj.alpha + 2*obj.beta*cos(th2) obj.delta + obj.beta*cos(th2);
             obj.delta + obj.beta*cos(th2)   obj.delta];
    end

    function C = get_C(obj, q_t1, dq_t1)
        %  Computes the coriolis and centrifugal forces acting on the joints
        %
        % Inputs:   q_t1    - configuration of robot
        %           dq_t1   - joint velocities of robot
        % Outputs:  C       - coriolis matrix
        dth1 = dq_t1(1);
        th2 = q_t1(2);
        dth2 = dq_t1(2);

        C = [-obj.beta*sin(th2)*dth2 -obj.beta*sin(th2)*(dth1+dth2);
             obj.beta*sin(th2)*dth1  0];
    end

    function N = get_N(obj, q_t1)
        %  Computes the effect of gravity on the links
        %
        % Inputs:   q_t1    - configuration of robot
        % Outputs:  N       - gravity matrix
        th1 = q_t1(1);
        th2 = q_t1(2);
        N = [(obj.m1+obj.m2)*obj.g*obj.l1*cos(th1)+obj.m2*obj.g*obj.l2*cos(th1 + th2);
             obj.m2*obj.g*obj.l2*cos(th1 + th2)];
    end

  end % end methods
end % end class