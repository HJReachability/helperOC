classdef PlaneCAvoid < DynSys
  properties
    % Angular control bounds
    wMaxA
    wMaxB
    
    % Speed control bounds
    vRangeA
    vRangeB
    
    % Disturbance
    dMaxA
    dMaxB
  end
  
  methods
    function obj = PlaneCAvoid(x, wMaxA, vRangeA, wMaxB, vRangeB, dMaxA, dMaxB)
      % obj = PlaneCAvoid(x, wMaxE, vRangeE, wMaxP, vRangeP, dMax)
      %     System in relative coordinates between two Plane objects
      %
      % Dynamics of each plane:
      %    \dot{x}_1 = v * cos(x_3) + d1
      %    \dot{x}_2 = v * sin(x_3) + d2
      %    \dot{x}_3 = u            + d3
      %         v \in [vrange(1), vrange(2)]
      %         u \in [-wMax, wMax]
      %
      % Dynamics relative to Plane A:
      %     \dot{x}_1 = -vA + vB*cos(x_3) + wA*x_2 + d1
      %     \dot{x}_2 = vB*sin(x_3) - wA*x_1 + d2
      %     \dot{x}_3 = wB - wA + d3
      %         vA in vRangeA, vB in vRangeB
      %         wA in [-wMaxA, wMaxA], wB in [-wMaxB, wMaxB]
      %         norm(d1, d2) <= dMaxA(1) + dMaxB(1)
      %         abs(d3) <= dMaxA(2) + dMaxB(2)
      % 
      % Inputs:
      %   x                - state: [xpos; ypos; theta]
      %   wMaxA, wMaxB     - maximum turn rate of vehicle A and vehicle B
      %   vRangeA, vRangeB - speed ranges
      %   dMaxA, dMaxB     - disturbance bounds
      
      if numel(x) ~= 3
        error('Initial state does not have right dimension!');
      end
      
      if ~iscolumn(x)
        x = x';
      end
      
      obj.x = x;
      obj.xhist = obj.x;
      
      obj.wMaxA = wMaxA;
      obj.wMaxB = wMaxB;
      obj.vRangeA = vRangeA;
      obj.vRangeB = vRangeB;
      obj.dMaxA = dMaxA;
      obj.dMaxB = dMaxB;
      
      obj.pdim = 1:2;
      obj.hdim = 3;
      
      obj.nx = 3;
      obj.nu = 2;
      obj.nd = 5;
    end
    
  end % end methods
end % end classdef
