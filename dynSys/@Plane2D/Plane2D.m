classdef Plane2D < DynSys
  properties
    % Bound for speed in x
    vxMin
    vxMax
    
    % Bound for speed in y
    vyMin
    vyMax
    
  end
  
  methods
    function obj = Plane2D(x, vxMin, vxMax, vyMin,vyMax)
      % obj = Plane(x, vxMax, vyMax)
      %
      % Constructor. Creates a plane object with a unique ID,
      % state x, and reachable set information reachInfo
      %
      % Dynamics:
      %    \dot{x}_1 = vx 
      %    \dot{x}_2 = vy 
      %         vx \in [-vxMax, vxMax]
      %         vy \in [-vyMax, vyMax]
      %
      % Inputs:
      %   x      - state: [xpos; ypos]
      %   vxMax  - maximum speed in x
      %   vyMax  - maximum speed in y
      %
      % Output:
      %   obj       - a Plane object
      %
      
      if numel(x) ~= 2
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.vxMin = vxMin;
      obj.vxMax = vxMax;
      obj.vyMin = vyMin;
      obj.vyMax = vyMax;
      
      obj.pdim = 1:2;
      
      obj.nx = 2;
      obj.nu = 2;
    end
    
  end % end methods
end % end classdef
