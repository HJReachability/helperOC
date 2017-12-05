classdef Quad10D < DynSys
  properties
    uMin        % Control bounds (3x1 vector)
    uMax
    dMax
    dMin
    
    % Constants
    %   The choices of n0, d1, d0 actually results in a very large
    %   steady state error in the pitch/roll; this seems to be
    %   expected according to Pat's report
    n0 = 10     % Angular dynamics parameters
    d1 = 8
    d0 = 10
    
    kT = 0.91   % Thrust coefficient (vertical direction)
    g = 9.81    % Acceleration due to gravity (for convenience)
    m = 1.3     % Mass
    
    % active dimensions
    dims
  end
  
  methods
    function obj = Quad10D(x, uMin, uMax, dMin, dMax, dims)
      % obj = Quad10D(x, uMin, uMax)
      %     Constructor for a 10D quadrotor
      %
      %     Dynamics of the 10D Quadrotor
      %         \dot x_1 = x_2 - d_1
      %         \dot x_2 = g * tan(x_3)
      %         \dot x_3 = -d1 * x_3 + x_4
      %         \dot x_4 = -d0 * x_3 + n0 * u1
      %         \dot x_5 = x_6 - d_2
      %         \dot x_6 = g * tan(x_7)
      %         \dot x_7 = -d1 * x_7 + x_8
      %         \dot x_8 = -d0 * x_7 + n0 * u2
      %         \dot x_9 = x_10 - d_3
      %         \dot x_10 = kT * u3
      %              uMin <= [u1; u2; u3] <= uMax
      %              dMin <= [d1; d2; d3] <= dMax
      
      if nargin < 1
        x = zeros(obj.nx, 1);
      end
      
      if nargin < 2
        uMax = [10/180*pi; 10/180*pi; 2*obj.g];
        uMin = [-10/180*pi; -10/180*pi; 0];
      end
      
      if nargin < 4
        dMax = [0.5;0.5;0.5];
        dMin = [-0.5;-0.5;-0.5];
      end
      
      if nargin < 5
        dims = 1:4;
      end
      
      obj.x = x;
      obj.xhist = x;
      
      obj.uMax = uMax;
      obj.uMin = uMin;
      obj.dMax = dMax;
      obj.dMin = dMin;
      
      obj.dims = dims;
      obj.nx = length(dims);
      obj.nu = 3;
      obj.pdim = [1 5 9];
      obj.vdim = [2 6 10];      
    end
  end
end