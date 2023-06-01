classdef SimpleFloatingBoat < DynSys
    properties
        u_range
        dims
    end
    methods
        function obj = SimpleFloatingBoat()
            obj.nx = 2;
            obj.nu = 1;
            obj.u_range = [-1, 1];
            obj.dims = 1:obj.nx;
        end
        
        function dx = dynamics(obj, ~, x, u, ~)
            if iscell(x)
              dx = cell(length(obj.dims), 1);
              dx{1} = u;
              dx{2} = 1;
            else
              dx = [u; 1];
            end
        end
        
        function uOpt = optCtrl(obj, ~, ~, deriv, uMode)
            if nargin < 5
              uMode = 'min';
            end
            if ~iscell(deriv)
              deriv = num2cell(deriv);
            end
            if strcmp(uMode, 'max')
                uOpt = (deriv{1} > 0) * obj.u_range(2) + (deriv{1} < 0) * obj.u_range(1);
            elseif strcmp(uMode, 'min')
                uOpt = (deriv{1} < 0) * obj.u_range(2) + (deriv{1} > 0) * obj.u_range(1);
            else
                error('Unknown uMode')
            end
        end
    end
end
