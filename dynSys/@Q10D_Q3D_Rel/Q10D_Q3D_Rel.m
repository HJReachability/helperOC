classdef Q10D_Q3D_Rel < DynSys
  properties
    uMin        % Control bounds (3x1 vector)
    uMax
    dMin
    dMax        % virtual velocity bounds
    
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
    function obj = Q10D_Q3D_Rel(x, uMin, uMax, dMin, dMax, dims)
      % obj = Quad10D_Rel(x, uMin, uMax, dMin, dMax, dims)
      %     Constructor for a 10D quadrotor
      %
      % Dynamics:
      %     \dot x_1 = x_2
      %     \dot x_2 = g * tan(x_3)
      %     \dot x_3 = -d1 * x_3 + x_4
      %     \dot x_4 = -d0 x_3 + n0 * u1
      %     \dot x_5 = x_6
      %     \dot x_6 = g * tan(x_7)
      %     \dot x_7 = -d1 * x_7 + x_8
      %     \dot x_8 = -d0 x_7 + n0 * u2
      %     \dot x_9 = x_10
      %     \dot x_10 = kT * u3 - g
      %         uMin <= [u1; u2; u3] <= uMax
      
      % u(1,3,5) = simple player
      % u(2,4,6) = real player
      
      if ~iscolumn(x)
        x = x';
      end
      
      if nargin < 1
        x = zeros(obj.nx, 1);
      end
      
      if nargin < 2
        uMax = [.5; 10/180*pi; .5; 10/180*pi; .25; 2*obj.g];
        uMin = [-.5; -10/180*pi; -.5; -10/180*pi; -.25; 0];
      end
      
      if nargin<4
        dMax = [0.1; .1; .1];
        dMin = [-.1; -.1; -.1];
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
      obj.nu = 6;
      obj.nd = 3;
      obj.pdim = [find(dims == 1) find(dims == 5) find(dims == 9)]; % Position dimensions
      obj.vdim = [find(dims == 2) find(dims == 6) find(dims == 10)]; % Velocity dimensions   
    end
  end
end