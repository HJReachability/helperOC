classdef Quad8D < DynSys
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
    g = 9.81
    
    m = 1.3     % Mass
    
    % active dimensions
    dims
  end
  
  methods
    function obj = Quad8D(x, uMin, uMax, dMin, dMax, dims)
      % obj = Quad10D(x, uMin, uMax)
      %     Constructor for a 8D quadrotor
      %
      %     Dynamics of the 8D Quadrotor 
      %       (same as Quad10D) without last two states)
      %         \dot x_1 = x_2 - d_1
      %         \dot x_2 = g * tan(x_3)
      %         \dot x_3 = -d1 * x_3 + x_4
      %         \dot x_4 = -d0 * x_3 + n0 * u1
      %         \dot x_5 = x_6 - d_2
      %         \dot x_6 = g * tan(x_7)
      %         \dot x_7 = -d1 * x_7 + x_8
      %         \dot x_8 = -d0 * x_7 + n0 * u2
      %              uMin <= [u1; u2] <= uMax
      %              dMin <= [d1; d2] <= dMax
      
      if nargin < 1
        x = zeros(obj.nx, 1);
      end
      
      if nargin < 2
        uMax = [ 10/180*pi;  10/180*pi];
        uMin = [-10/180*pi; -10/180*pi];
      end
      
      if nargin < 4
        dMax = [ 0.5;  0.5];
        dMin = [-0.5; -0.5];
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
      obj.nu = 2;
      obj.pdim = [1 5];
      obj.vdim = [2 6];      
    end
  end
end