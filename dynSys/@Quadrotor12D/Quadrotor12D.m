classdef Quadrotor12D < dynSys
  properties
    % Control bounds
    uMin
    uMax
    
    % Turn rate and speed are both controls; however, if vrange is a
    % scalar, then the Plane has constant speed
    nx = 12;
    nu = 4;
    g = 9.81;
    
    % Position, velocity, dimensions
    pdim = 1:3;
    vdim = 4:6;
  end
  
  methods
    function obj = Quadrotor12D(pos, vel, uMin, uMax, aux_states, phys_params)
      % obj = Quadrotor12D(pos, uMin, uMax, aux_states)
      %
      % Constructor. Creates a Quadrotor12D object
      %
      % Dynamics:
      %     \dot x_1  = x_4
      %     \dot x_2  = x_5
      %     \dot x_3  = x_6
      %     \dot x_4  = -(\cos x_7 \sin x_8 \cos x_9 + \sin x_7 \sin x_9) u_1/m
      %     \dot x_5  = -(\cos x_7 \sin x_8 \sin x_9 - \sin x_7 \cos x_9) u_1/m
      %     \dot x_6  = g - (\cos x_7 \cos x_8) u_1/m
      %     \dot x_7  = x_10 + \sin x_7 \tan(x_8) x_11 + \cos x_7 \tan(x_8) x_12
      %     \dot x_8  = \cos x_7 x_11 - \sin x_7 x_12
      %     \dot x_9  = (\sin x_7/\cos x_8)*x_11 + (\cos x_7/\cos x_8) x_12
      %     \dot x_10 = x_11 x_12 (I_y - I_z)/I_x + L/I_x u_2
      %     \dot x_11 = x_10 x_12 (I_z - I_x)/I_y + L/I_y u_3
      %     \dot x_12 = x_10 x_11 (I_x - I_y)/I_z + 1/I_z u_4
      %
      % Inputs:
      %   x      - state: [xpos; ypos; theta]
      %   wMax   - maximum turn rate
      %   vrange - speed range
      %   dMax   - disturbance bounds
      %
      % Output:
      %   obj       - a Quadrotor12D object
      
      %% Process position
      if numel(pos) ~= 3
        error('Initial position does not have right dimension!');
      end
      
      if ~iscolumn(pos)
        pos = pos';
      end

      %% Process velocity
      if numel(vel) ~= 3
        error('Initial velocity does not have right dimension!');
      end      
      
      if ~iscolumn(vel)
        vel = vel';
      end
      
      %% Process input bounds
      if numel(uMin) ~= 4 || numel(uMax) ~= 4
        error('Control bounds do not have the right dimensions!')
      end
      
      if ~iscolumn(uMin)
        uMin = uMin';
      end      
      
      if ~iscolumn(uMax)
        uMax = uMax';
      end
      
      obj.uMin = uMin;
      obj.uMax = uMax;
      
      %% Process auxiliary states
      if nargin < 5
        aux_states = zeros(6,1);
      end
      
      if numel(aux_states) ~= 6
        error('Auxiliary states do not have the right dimension!')
      end
      
      if ~iscolumn(aux_states)
        aux_states = aux_states';
      end
      
      obj.x = [pos; vel; aux_states];
      obj.xhist = obj.x;
      
      %% Process physical parameters
      if nargin < 6
        phys_params.I = [2.3951e-5; 2.3951e-5; 3.2347e-5];
        phys_params.m = 35e-3; % 35g
        phys_params.L = 65e-3; % 65mm
      end
      
      obj.I = phys_params.I;
      obj.m = phys_params.m;
      obj.L = phys_params.L;
    end
  end % end method
end % end classdef
