classdef Plane < DynSys
  properties
    % Angular control bounds
    wMax
    
    % Speed control bounds
    vrange
    
    % Disturbance
    dMax
  end
  
  methods
    function obj = Plane(x, wMax, vrange, dMax)
      % obj = Plane(x, wMax, vrange, dMax)
      %
      % Constructor. Creates a plane object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{x}_1 = v * cos(x_3) + d1
      %    \dot{x}_2 = v * sin(x_3) + d2
      %    \dot{x}_3 = u            + d3
      %         v \in [vrange(1), vrange(2)]
      %         u \in [-wMax, wMax]
      %
      % Inputs:
      %   x      - state: [xpos; ypos; theta]
      %   wMax   - maximum turn rate
      %   vrange - speed range
      %   dMax   - disturbance bounds
      %
      % Output:
      %   obj       - a Plane object
      %
      % Mahesh Vashishtha, 2015-10-26
      % Modified, Mo Chen, 2016-05-22
      
      if numel(x) ~= 3
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      if nargin < 2
        wMax = 1;
      end
      
      if nargin < 3
        vrange = 5;
      end
      
      if nargin < 4
        dMax = [0 0];
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.wMax = wMax;
      obj.vrange = vrange;
      obj.dMax = dMax;
      
      obj.pdim = 1:2;
      obj.hdim = 3;
      
      obj.nx = 3;
      obj.nu = 2;
      obj.nd = 3;
    end
    
  end % end methods
end % end classdef
